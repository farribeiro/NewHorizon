local c = core
c.log("action", "[BODY] NH init.lua loaded")
local S = c.get_translator("nh_body")
local function xyz(x, y, z) if y == nil and z == nil then y, z = x, x end return {x = x, y = y, z = z} end
-- TABELAS GLOBAIS
local last_wielded = {}
local last_wield_index = {}
local player_states = {}
local wielded_entities = {}
local offhand_entities = {}
local armor_entities = {}
local belt_entities = {}
local last_belt_items = {}
local last_armor_items = {}
local last_sneak = {}
local last_backpack_state = {}
local body_entities = {}

-- Persistência em disco para backchest vestida
local _bc_storage = core.get_mod_storage()
local function bc_disk_save(chest_id, slots)
    if not chest_id or chest_id == "" then return end
    _bc_storage:set_string("bc_" .. chest_id, core.serialize(slots))
end
local function bc_disk_load(chest_id)
    if not chest_id or chest_id == "" then return nil end
    local raw = _bc_storage:get_string("bc_" .. chest_id)
    if not raw or raw == "" then return nil end
    return core.deserialize(raw)
end
local function bc_disk_delete(chest_id)
    if not chest_id or chest_id == "" then return end
    _bc_storage:set_string("bc_" .. chest_id, "")
end
-- BACKCHEST ↔ SLOTS main[9..24]
local BC_OFFSET = 8   -- main[9] .. main[24]
local BC_COUNT  = 16
local bc_sync_lock = {}   -- evita loops recursivos por player

local function bc_has_backchest(player)
    local stack = player:get_inventory():get_stack("armor_back", 1)
    return not stack:is_empty() and stack:get_name() == "nh_nodes:backchest"
end

-- Lê slots 9..24 e persiste na backchest equipada (tabela global + meta do item)
local function bc_save(player)
    if not bc_has_backchest(player) then return end
    local inv   = player:get_inventory()
    local stack = inv:get_stack("armor_back", 1)
    local meta  = stack:get_meta()
    local chest_id = meta:get_string("chest_id")
    if chest_id == "" then
        chest_id = tostring(os.time()) .. "_" .. tostring(math.random(1, 999999))
        meta:set_string("chest_id", chest_id)
    end
    if not backchest_stored_items then backchest_stored_items = {} end
    local slots, has = {}, false
    for i = 1, BC_COUNT do
        local s = inv:get_stack("main", BC_OFFSET + i)
        slots[i] = s:to_string()
        if not s:is_empty() then has = true end
    end
    if has then
        backchest_stored_items[chest_id] = slots
        bc_disk_save(chest_id, slots)
        meta:set_string("description", "Backpack Chest\n(contains items)")
    else
        backchest_stored_items[chest_id] = nil
        bc_disk_delete(chest_id)
        meta:set_string("description", "")
        meta:set_string("chest_id", "")
    end
    inv:set_stack("armor_back", 1, stack)
end

-- Carrega conteúdo da backchest equipada → slots main[9..24]
local function bc_load(player)
    if bc_sync_lock[player:get_player_name()] then return end
    bc_sync_lock[player:get_player_name()] = true
    local inv   = player:get_inventory()
    local stack = inv:get_stack("armor_back", 1)
    local chest_id = stack:get_meta():get_string("chest_id")
    local stored = (chest_id ~= "" and backchest_stored_items and backchest_stored_items[chest_id]) or {}
    -- Tenta RAM primeiro, depois disco (recover após restart)
    local stored = (chest_id ~= "" and backchest_stored_items and backchest_stored_items[chest_id]) or bc_disk_load(chest_id) or {}
    -- Se veio do disco, repõe na RAM e limpa o disco
    if chest_id ~= "" and not (backchest_stored_items and backchest_stored_items[chest_id]) and #stored > 0 then
        backchest_stored_items = backchest_stored_items or {}
        backchest_stored_items[chest_id] = stored
        bc_disk_delete(chest_id)   -- agora vive na RAM / node, não precisa mais do disco
    end
    for i = 1, BC_COUNT do inv:set_stack("main", BC_OFFSET + i, ItemStack(stored[i] or "")) end
    bc_sync_lock[player:get_player_name()] = false
end

-- Salva e zera os slots main[9..24] IMEDIATAMENTE (síncrono)
local function bc_unload(player)
    if bc_sync_lock[player:get_player_name()] then return end
    bc_sync_lock[player:get_player_name()] = true
    bc_save(player)   -- persiste antes de apagar
    local inv = player:get_inventory()
    for i = 1, BC_COUNT do inv:set_stack("main", BC_OFFSET + i, ItemStack("")) end
    bc_sync_lock[player:get_player_name()] = false
end
local armor_slots = {
    head = S("head"),
    torso = S("torso"),
    arms = S("arms"),
    legs = S("legs"),
    back = S("back"),
    waist = S("waist"),
    hands = S("hands"),
    feet = S("feet")
}
-- TABELA PARA CONTROLAR ANIMAÇÕES DE SOCO
local punch_timers = {}
local punch_loop_timers = {}
local is_punching = {}
local is_placing = {}
local last_place_time = {}
-- TABELAS PARA ANIMAÇÃO DE SENTAR
local sit_state = {}          -- estado da máquina por player
local sit_sneak_count = {}    -- quantas vezes agachou nesta sequência
local sit_sneak_held = {}     -- tempo (em segundos) que a 3ª agachada está sendo segurada
local sit_last_sneak = {}     -- estado do sneak no step anterior (para detectar borda)
local sit_anim_timer = {}     -- tempo decorrido dentro da animação de sentar
-- forward declarations (OBRIGATÓRIO)
local set_player_animation
local trigger_punch
local trigger_punch_loop
local stop_punch_loop
local rotate_head_to_look
-- REGISTRA A ENTIDADE DO CORPO DO PLAYER
c.register_entity("nh_body:player_body", {
    initial_properties = {
        visual = "mesh",
        mesh = "character11.glb",
        textures = { "skin.png" },
        visual_size = { x = 1, y = 1, z = 1 },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
        shaded = true,
        makes_footstep_sound = false,
    },
    on_activate = function(self, staticdata)
        self.last_anim = nil
        self.last_bone_head = nil
        self.last_bone_torso = nil
        self.last_bone_legs = nil
        self.last_bone_feet = nil
    end,
    on_step = function(self, dtime)
        if not self.player_name then self.object:remove() return end
        local player = c.get_player_by_name(self.player_name)
        if not player then self.object:remove() return end
        -- Sincroniza rotações dos bones apenas se mudaram
        local head_rot  = player:get_bone_override("bone_All_Head").rotation.vec
        local torso_rot = player:get_bone_override("bone_TorsoArms").rotation.vec
        local legs_rot  = player:get_bone_override("bone_Legs").rotation.vec
        local feet_rot  = player:get_bone_override("bone_Feet").rotation.vec
        if not self.last_bone_head or not vector.equals(head_rot, self.last_bone_head.rot) then -- Verifica se a rotação da cabeça mudou
            self.object:set_bone_override("bone_All_Head", {rotation = {vec = head_rot}})
            self.last_bone_head = {rot = head_rot}
        end
        if not self.last_bone_torso or not vector.equals(torso_rot, self.last_bone_torso.rot) then -- Verifica se a rotação do torso mudou
            self.object:set_bone_override("bone_TorsoArms", {rotation = {vec = torso_rot}})
            self.last_bone_torso = {rot = torso_rot}
        end
        if not self.last_bone_legs or not vector.equals(legs_rot, self.last_bone_legs.rot) then -- Verifica se a rotação das pernas mudou
            self.object:set_bone_override("bone_Legs", {rotation = {vec = legs_rot}})
            self.last_bone_legs = {rot = legs_rot}
        end
        if not self.last_bone_feet or not vector.equals(legs_rot, self.last_bone_feet.rot) then -- Verifica se a rotação das pernas mudou
            self.object:set_bone_override("bone_Feet", {rotation = {vec = feet_rot}})
            self.last_bone_feet = {rot = feet_rot}
        end
    end,
})
-- FUNÇÃO PARA CRIAR O CORPO VISÍVEL
local function create_player_body(player)
    if not player then return end
    local player_name = player:get_player_name()
    -- Remove corpo anterior se existir
    if body_entities[player_name] then
        body_entities[player_name]:remove()
        body_entities[player_name] = nil
    end
    local pos = player:get_pos()
    local body = c.add_entity(pos, "nh_body:player_body")
    if body then
        local luaentity = body:get_luaentity()
        luaentity.player_name = player_name
        -- Anexa ao player na mesma posição
        body:set_attach(player, "", xyz(0), xyz(0), true) -- "" Bone principal (corpo todo)
        -- ★ SINCRONIZA OS BONES IMEDIATAMENTE ★
        c.after(0.1, function()
            if not body or not body:get_luaentity() then return end
            if not player or not player:is_player() then return end
            -- Copia rotações dos bones do player para o corpo
            local head_rot  = player:get_bone_override("bone_All_Head").rotation.vec
            local torso_rot = player:get_bone_override("bone_TorsoArms").rotation.vec
            local legs_rot  = player:get_bone_override("bone_Legs").rotation.vec
            body:set_bone_override("bone_All_Head", { rotation = { vec = head_rot } })
            body:set_bone_override("bone_TorsoArms", { rotation = { vec = torso_rot } })
            body:set_bone_override("bone_Legs", { rotation = { vec = legs_rot } })
            -- Força atualização da animação atual
            local state = player_states[player_name]
            if state and state.current_anim then
                local anim_name = state.current_anim
                state.current_anim = nil -- Reset para forçar re-aplicação
                set_player_animation(player, anim_name)
            end
        end)
        body_entities[player_name] = body
        c.log("action", "[body] Visible body created for " .. player_name)
    else
        c.log("action", "[body] ERROR: Could not create visible body for " .. player_name)
    end
end
-- FUNÇÃO PARA ATUALIZAR TEXTURAS DO CORPO VISÍVEL
local function update_body_textures(player)
    if not player then return end
    local player_name = player:get_player_name()
    local body = body_entities[player_name]
    if not body then return end
    local inv = player:get_inventory()
    local textures = { "skin.png" }
    -- Adiciona texturas de armadura
    for slot, _ in pairs(armor_slots) do
        local stack = inv:get_stack("armor_" .. slot, 1)
        if not stack:is_empty() then
            local item_name = stack:get_name()
            local item_def = c.registered_items[item_name]
            if item_def and item_def.armor_texture then table.insert(textures, item_def.armor_texture) end
        end
    end
    body:set_properties({ textures = textures }) -- Atualiza textura do corpo visível
end
c.register_entity("nh_body:armor_mesh_piece", {
    initial_properties = {
        visual = "mesh",
        mesh = "leggingsLRup.obj",        -- placeholder; sobrescrito no attach
        textures = { "copperlegging.png" }, -- placeholder; sobrescrito no attach
        --visual_size = { x = 1, y = 1, z = 1 },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
        shaded = true,
    },
    on_step = function(self, dtime)
        if not self.player_name then self.object:remove() return end
        local player = c.get_player_by_name(self.player_name)
        if not player then self.object:remove() return end
    end,
})
-- REGISTRA A ENTIDADE DO ITEM NA CINTURA
c.register_entity("nh_body:belt_item", {
    initial_properties = {
        visual = "wielditem",
        visual_size = { x = 0.15, y = 0.15, z = 0.15 },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
    },
    on_step = function(self, dtime)
        if not self.player_name then
            self.object:remove()
            return
        end
        local player = c.get_player_by_name(self.player_name)
        if not player then
            self.object:remove()
            return
        end
    end,
})
-- FUNÇÃO PARA ATUALIZAR ITENS NA CINTURA
local function update_belt_items(player)
    if not player then return end
    local player_name = player:get_player_name()
    local inv = player:get_inventory()
    if belt_entities[player_name] then
        for slot_num, entity in pairs(belt_entities[player_name]) do
            if entity and entity:get_luaentity() then entity:remove() end
        end
        belt_entities[player_name] = nil
    end
    -- VERIFICAÇÃO: Checar se há um cinto equipado
    -- Ajuste o nome do inventário e slot conforme seu sistema
    -- Exemplos comuns: "armor", "belt", "equipment"
    local belt_stack = inv:get_stack("armor_waist", 1) -- Ajuste o índice conforme necessário
    if belt_stack:is_empty() then return end           -- Se não houver cinto equipado, retornar sem criar entidades
    local belt_item = belt_stack:get_name()            -- Opcional: verificar se o item é realmente um cinto
    if not belt_item:match("belt") then return end     -- Ajuste conforme a nomenclatura dos seus cintos
    belt_entities[player_name] = {}
    local belt_slots = {
        [3] = { bone = "bone1", pos = { x = 0.1, y = 0.2, z = 0 }, rot = { x = 0, y = -90, z = 0 } },
        [4] = { bone = "bone2", pos = { x = 0.1, y = 0.2, z = 0 }, rot = { x = 0, y = -90, z = 0 } },
        [5] = { bone = "bone3", pos = { x = 0.1, y = 0.2, z = 0 }, rot = { x = 0, y = -90, z = 0 } },
        [6] = { bone = "bone4", pos = { x = 0.1, y = 0.2, z = 0 }, rot = { x = 0, y = -90, z = 0 } },
        [7] = { bone = "bone5", pos = { x = 0.1, y = 0.2, z = 0 }, rot = { x = 0, y = -90, z = 0 } },
        [8] = { bone = "bone6", pos = { x = 0.1, y = 0.2, z = 0 }, rot = { x = 0, y = -90, z = 0 } },
    }

    for slot_num, config in pairs(belt_slots) do
        local stack = inv:get_stack("main", slot_num)
        if not stack:is_empty() then
            local item_name = stack:get_name()
            if item_name ~= "" and item_name ~= ":" then
                local pos = player:get_pos()
                local entity = c.add_entity(pos, "nh_body:belt_item")
                if entity then
                    local luaentity = entity:get_luaentity()
                    luaentity.player_name = player_name
                    luaentity.slot_num = slot_num
                    entity:set_attach(player, config.bone, config.pos, config.rot, true)
                    entity:set_properties({ wield_item = item_name, visual = "wielditem", visual_size = { x = 0.035, y = 0.035, z = 0.035 } })
                    belt_entities[player_name][slot_num] = entity
                end
            end
        end
    end
end
-- CAPACIDADES DA MÃO INVISÍVEL
local hand_capabilities = {
    full_punch_interval = 0.9,
    max_drop_level = 0,
    groupcaps = {
        crumbly = { times = { [2] = 2.00, [3] = 0.70 }, uses = 0, maxlevel = 1 },
        cracky = { times = { [3] = 4.00, [6] = 8.00 }, uses = 0, maxlevel = 1 },
        snappy = { times = { [3] = 0.40 }, uses = 0, maxlevel = 1 },
        -- choppy = {times = {[3] = 2.5}, uses = 0, maxlevel = 1},
        oddly_breakable_by_hand = { times = { [1] = 3.50, [2] = 2.00, [3] = 0.70 }, uses = 0 },
        dig_immediate = { times = { [1] = 0 }, uses = 0 },
    },
    damage_groups = { fleshy = 1 },
}
-- REGISTRA O ITEM DA MÃO (SEM IMAGEM VISÍVEL)
-- c.register_craftitem(":",
--     {
--         type = "none",
--         wield_image = "",
--         wield_scale = xyz(0),
--         range = 4,
--         inventory_image = "",
--         tool_capabilities = hand_capabilities,
--         visual_scale = 0,
--         pointable = false,
--     })
c.override_item("", { -- "" é o itemstring da mão sem itens
    wield_image = "",
    wield_scale = xyz(0),
    range = 3,
    tool_capabilities = hand_capabilities,
})
-- FUNÇÃO PARA ATUALIZAR ITEM NA MÃO DIREITA (com configurações customizadas)
local function update_wielded_item(player)
    if not player then return end
    local player_name = player:get_player_name()
    local item = player:get_wielded_item()
    local item_name = item:get_name()
    if wielded_entities[player_name] then
        wielded_entities[player_name]:remove()
        wielded_entities[player_name] = nil
    end
    if item_name == "" or item_name == ":" then return end
    local item_def = c.registered_items[item_name]
    -- VALORES PADRÃO
    local default_pos = { x = 1.5, y = 0, z = 0 }
    local default_rot = { x = 0, y = 0, z = -90 }
    local default_size = { x = 0.15, y = 0.15, z = 0.15 }
    -- VALORES FINAIS (podem ser sobrescritos)
    local final_pos = default_pos
    local final_rot = default_rot
    local final_size = default_size
    -- SOBRESCREVE COM VALORES CUSTOMIZADOS SE EXISTIREM
    if item_def then
        if item_def.wielded_bone_position then
            final_pos = item_def.wielded_bone_position.pos or final_pos
            final_rot = item_def.wielded_bone_position.rot or final_rot
        end
        final_size = item_def.wielded_visual_size or final_size
    end
    local pos = player:get_pos()
    local entity = c.add_entity(pos, "nh_body:wielded_item")
    if entity then
        local luaentity = entity:get_luaentity()
        luaentity.player_name = player_name
        luaentity.item_name = item_name
        entity:set_attach(player, "bone_RHand",
            final_pos, -- USA POSIÇÃO CUSTOMIZADA
            final_rot, -- USA ROTAÇÃO CUSTOMIZADA
            true)
        entity:set_properties({
            wield_item = item_name,
            visual = "wielditem",
            visual_size = final_size -- USA TAMANHO CUSTOMIZADO
        })
        wielded_entities[player_name] = entity
    end
end
-- FUNÇÃO PARA ATUALIZAR ITEM NA MÃO ESQUERDA (com configurações customizadas)
local function update_offhand_item(player)
    if not player then return end
    local player_name = player:get_player_name()
    local inv = player:get_inventory()
    local wield_index = player:get_wield_index()
    if offhand_entities[player_name] then
        offhand_entities[player_name]:remove()
        offhand_entities[player_name] = nil
    end
    local offhand_index
    if wield_index == 1 then offhand_index = 2 elseif wield_index == 2 then offhand_index = 1 else return end
    local offhand_item = inv:get_stack("main", offhand_index)
    local offhand_name = offhand_item:get_name()
    if offhand_name == "" or offhand_name == ":" then return end
    local item_def = c.registered_items[offhand_name]
    -- VALORES PADRÃO PARA OFFHAND
    local default_pos = { x = 1.5, y = 0, z = 0 }
    local default_rot = { x = 0, y = 0, z = -90 }
    local default_size = { x = 0.15, y = 0.15, z = 0.15 }
    -- VALORES FINAIS (podem ser sobrescritos)
    local final_pos = default_pos
    local final_rot = default_rot
    local final_size = default_size
    -- SOBRESCREVE COM VALORES CUSTOMIZADOS SE EXISTIREM
    if item_def then
        if item_def.offhand_bone_position then -- Primeiro tenta usar configuração específica de offhand
            final_pos = item_def.offhand_bone_position.pos or final_pos
            final_rot = item_def.offhand_bone_position.rot or final_rot
        elseif item_def.wielded_bone_position then -- Senão, usa a mesma configuração do wielded
            final_pos = item_def.wielded_bone_position.pos or final_pos
            final_rot = item_def.wielded_bone_position.rot or final_rot
        end
        -- Tamanho pode ser específico de offhand ou compartilhado
        final_size = item_def.offhand_visual_size and item_def.offhand_visual_size or item_def.wielded_visual_size
    end
    local pos = player:get_pos()
    local entity = c.add_entity(pos, "nh_body:offhand_item")
    if entity then
        local luaentity = entity:get_luaentity()
        luaentity.player_name = player_name
        luaentity.item_name = offhand_name
        luaentity.slot_index = offhand_index
        entity:set_attach(player, "bone_LHand", final_pos, -- USA POSIÇÃO CUSTOMIZADA
            final_rot,                                     -- USA ROTAÇÃO CUSTOMIZADA
            true)
        entity:set_properties({
            wield_item = offhand_name,
            visual = "wielditem",
            visual_size = final_size -- USA TAMANHO CUSTOMIZADO
        })
        offhand_entities[player_name] = entity
    end
end
-- REGISTRA A ENTIDADE DO ITEM SEGURADO
c.register_entity("nh_body:wielded_item", {
    initial_properties = {
        visual = "wielditem",
        visual_size = { x = 0.25, y = 0.25, z = 0.25 },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
        shaded = true,
    },
    on_step = function(self, dtime)
        if not self.player_name then
            self.object:remove()
            return
        end
        local player = c.get_player_by_name(self.player_name)
        if not player then
            self.object:remove()
            wielded_entities[self.player_name] = nil
            return
        end
        local current_item = player:get_wielded_item():get_name()
        if current_item ~= self.item_name then
            update_wielded_item(player)
            update_offhand_item(player)
        end
    end,
})
c.register_entity("nh_body:offhand_item", {
    initial_properties = {
        visual = "wielditem",
        visual_size = { x = 0.15, y = 0.15, z = 0.15 },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
        shaded = true,
    },
    on_step = function(self, dtime)
        if not self.player_name then
            self.object:remove()
            return
        end
        local player = c.get_player_by_name(self.player_name)
        if not player then
            self.object:remove()
            offhand_entities[self.player_name] = nil
            return
        end
        local inv = player:get_inventory()
        local current_item = inv:get_stack("main", self.slot_index):get_name()
        local wield_index = player:get_wield_index()
        if current_item ~= self.item_name or (wield_index ~= 1 and wield_index ~= 2) or wield_index == self.slot_index then
            update_offhand_item(player)
        end
    end,
})
-- REGISTRA A ENTIDADE DE PEÇA DE ARMADURA
c.register_entity("nh_body:armor_piece", {
    initial_properties = {
        visual = "wielditem",
        visual_size = { x = 0.3, y = 0.3, z = 0.3 },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
    },
    on_step = function(self, dtime)
        if not self.player_name then
            self.object:remove()
            return
        end
        local player = c.get_player_by_name(self.player_name)
        if not player then
            self.object:remove()
            return
        end
    end,
})
-- INVENTÁRIO DE VESTUÁRIO
local function create_armor_inventory(player)
    if not player then return end
    local inv = player:get_inventory()
    for slot, _ in pairs(armor_slots) do inv:set_size("armor_" .. slot, 1) end
end
local function get_armor_formspec(player_name)
    local player = c.get_player_by_name(player_name)
    if not player then return "" end
    local inv = player:get_inventory()
    local backpack_stack = inv:get_stack("armor_back", 1)
    local has_backpack = not backpack_stack:is_empty() and backpack_stack:get_name() == "nh_nodes:backchest"
    return table.concat(
        { "size[9,9.5]", "bgcolor[#00000000;true]", "background[0,0;9,9.5;gui_formbg.png]",
           "label[0.5,0.5;" .. S("Head") .. "]", "list[current_player;armor_head;0.5,0.5;1,1;]",
           "label[0.5,1.6;" .. S("Torso") .. "]", "list[current_player;armor_torso;0.5,1.6;1,1;]",
           "label[0.5,2.7;" .. S("Legs") .. "]", "list[current_player;armor_legs;0.5,2.7;1,1;]",
           "label[0.5,3.8;" .. S("Feet") .. "]", "list[current_player;armor_feet;0.5,3.8;1,1;]",
           "model[1.25,0.5;3,6;player_model;character11.glb;skin.png;0,180;false;true]",
           "label[1.75,4.8;" .. c.formspec_escape(player_name) .. "]",
           "label[3.5,0.5;" .. S("Back")  .. "]", "list[current_player;armor_back;3.5,0.5;1,1;]",
           "label[3.5,1.6;" .. S("Arms")  .. "]", "list[current_player;armor_arms;3.5,1.6;1,1;]",
           "label[3.5,2.7;" .. S("Hands") .. "]", "list[current_player;armor_hands;3.5,2.7;1,1;]",
           "label[3.5,3.8;" .. S("Waist") .. "]",
            "list[current_player;armor_waist;3.5,3.8;1,1;]",
            has_backpack and "list[current_player;main;0.5,5.7;8,2;8] list[current_player;main;0.5,7.9;8,1;]" or
            "list[current_player;main;0.5,7.9;8,1;]",
            "listring[current_player;main]", "listring[current_player;armor_head]",
            "listring[current_player;armor_torso]", "listring[current_player;armor_waist]",
            "listring[current_player;armor_legs]", "listring[current_player;armor_back]",
            "listring[current_player;armor_arms]", "listring[current_player;armor_hands]",
            "listring[current_player;armor_feet]"
        }, " ")
end
local function update_player_formspec(player)
    if not player then return end
    local player_name = player:get_player_name()
    player:set_inventory_formspec(get_armor_formspec(player_name))
end
c.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    -- Bloqueia os slots main[9..24] quando não há backchest equipada
    local function is_bc_slot(list, idx)
        return list == "main" and idx >= BC_OFFSET + 1 and idx <= BC_OFFSET + BC_COUNT
    end

    -- Bloqueia mover o próprio backchest para dentro dos slots 9..24,
    -- independente de estar equipado (o bloqueio de armor_back → main[9..24]
    -- ocorreria só DEPOIS da ação, causando o bug)
    if action == "move" then
        if is_bc_slot(inventory_info.to_list, inventory_info.to_index) then
            local moving = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
            if moving:get_name() == "nh_nodes:backchest" then
            c.chat_send_player(player:get_player_name(), S("I can't put a backpack chest inside itself, nor another one inside this one on my back while I'm wearing it..."))
            return 0 end
        end
    elseif action == "put" then
        if is_bc_slot(inventory_info.listname or "", inventory_info.index or 0) then
            local putting = inventory_info.stack
            if putting and putting:get_name() == "nh_nodes:backchest" then return 0 end
        end
    end

    if not bc_has_backchest(player) then
        if action == "move" then
            if is_bc_slot(inventory_info.from_list, inventory_info.from_index) or
               is_bc_slot(inventory_info.to_list,   inventory_info.to_index) then
                return 0
            end
        elseif action == "put" then
            if is_bc_slot(inventory_info.listname or "", inventory_info.index or 0) then return 0 end
        elseif action == "take" then
            if is_bc_slot(inventory_info.listname or "", inventory_info.index or 0) then return 0 end
        end
    end
    -- Validação de slot de armadura
    if action == "move" then
        local to_list = inventory_info.to_list
        if to_list:match("^armor_") then
            local slot_type = to_list:gsub("armor_", "")
            local stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
            local item_def = c.registered_items[stack:get_name()]
            if not item_def or not item_def.groups or not item_def.groups["armor_" .. slot_type] then return 0 end
            return stack:get_count()
        end
    elseif action == "put" then
        local listname = inventory_info.listname
        if listname and listname:match("^armor_") then
            local slot_type = listname:gsub("armor_", "")
            local item_def = c.registered_items[inventory_info.stack:get_name()]
            if not item_def or not item_def.groups or not item_def.groups["armor_" .. slot_type] then return 0 end
            return inventory_info.stack:get_count()
        end
    end
    if inventory_info.count then return inventory_info.count
    elseif inventory_info.stack then return inventory_info.stack:get_count()
    else return 1 end
end)
local function update_armor_visuals(player)
    if not player then return end
    local player_name = player:get_player_name()
    local inv = player:get_inventory()
    if armor_entities[player_name] then
        for slot, entity in pairs(armor_entities[player_name]) do
            if entity and entity:get_luaentity() then entity:remove() end
        end
        armor_entities[player_name] = nil
    end
    armor_entities[player_name] = {}
    local armor_bones = {
        head = {bone = "bone_All_Head",
            pos = { x = 0, y = 4.75, z = 0 },
            rot = xyz(0),
            size = { x = 0.3, y = 0.3, z = 0.3 }},
        torso = {bone = "bone_TorsoArms",
            pos = xyz(0),
            rot = xyz(0),
            size = { x = 0.35, y = 0.35, z = 0.35 }},
        waist = {bone = "bone_TorsoArms",
            pos = { x = 0.5, y = 2.5, z = 0 },
            rot = { x = 0, y = -90, z = 0 },
            size = { x = 0.3, y = 0.3, z = 0.3 }},
        legs = {bone = "bone_TorsoArms", -- "bone_Legs",
            pos = xyz(0),
            rot = xyz(0),
            size = { x = 0.3, y = 0.3, z = 0.3 }},
        back = {bone = "bone_TorsoArms",
            pos = { x = -2.5, y = 2.5, z = 0 },
            rot = { x = 0, y = -90, z = 0 },
            size = { x = 0.3, y = 0.3, z = 0.3 }},
        arms = {bone = "bone_TorsoArms",
            pos = { x = 0, y = -2, z = 0 },
            rot = xyz(0),
            size = { x = 0.25, y = 0.25, z = 0.25 } },
        hands = {bone = "bone_RHand", bone_l = "bone_LHand",
            pos = xyz(0),
            rot = xyz(0),
            size = { x = 0.2, y = 0.2, z = 0.2 }},
        feet = {bone = "bone_LLeg_foot", bone_r = "bone_RLeg_foot", -- bone do pé ESQUERDO / bone do pé DIREITO
            pos = xyz(0),
            rot = xyz(0),
            size = { x = 0.25, y = 0.25, z = 0.25 }}
    }
    for slot, config in pairs(armor_bones) do
        local stack = inv:get_stack("armor_" .. slot, 1)
        if not stack:is_empty() then
            local item_name = stack:get_name()
            local item_def = c.registered_items[item_name]
            local final_pos  = config.pos
            local final_rot  = config.rot
            local final_size = config.size
            -- Permite que o item sobrescreva posição/rotação
            if item_def then
                if item_def.armor_bone_position then
                    final_pos = item_def.armor_bone_position.pos or final_pos
                    final_rot = item_def.armor_bone_position.rot or final_rot
                end
                final_size = item_def.armor_visual_size or final_size
            end
            local visual_item = item_name
            if item_def and item_def.armor_model then visual_item = item_def.armor_model end
            -- Lista de bones para este slot (pés têm dois; outros têm um)
            local bones_to_attach = { config.bone }
            if config.bone_r then bones_to_attach[2] = config.bone_r end
            -- dual hands: gauntlets e itens com armor_dual_hands = true aparecem nas duas mãos
            if config.bone_l and item_def and (item_def.groups and item_def.groups.armor_hands == 2) then
                local left_bone = config.bone_l
                local left_pos  = (item_def.armor_bone_position_l and item_def.armor_bone_position_l.pos) or final_pos
                local left_rot  = (item_def.armor_bone_position_l and item_def.armor_bone_position_l.rot) or final_rot
                -- Espelha no eixo X invertendo visual_size.x
                local left_size = {
                    x = -final_size.x,  -- negativo = espelho
                    y =  final_size.y,
                    z =  final_size.z,
                }
                local left_entity = c.add_entity(player:get_pos(), "nh_body:armor_piece")
                if left_entity then
                    local elu = left_entity:get_luaentity()
                    elu.player_name = player_name
                    elu.slot = slot .. "_left"
                    left_entity:set_attach(player, left_bone, left_pos, left_rot, true)
                    left_entity:set_properties({
                        wield_item = visual_item,
                        visual = "wielditem",
                        visual_size = left_size
                    })
                    armor_entities[player_name][elu.slot] = left_entity
                end
            end
            -- Se o item declarar armor_skip_main_piece = true, pula a entidade principal
            -- (útil para itens que usam APENAS armor_extra_pieces em múltiplos bones)
            if not (item_def and item_def.armor_skip_main_piece) then
                for bi, bone_name in ipairs(bones_to_attach) do
                    -- Permite que o item sobrescreva o bone também (opcional)
                    local use_bone = (item_def and item_def.armor_bone) or bone_name
                    local pos = player:get_pos()
                    local entity = c.add_entity(pos, "nh_body:armor_piece")
                    if entity then
                        local luaentity = entity:get_luaentity()
                        luaentity.player_name = player_name
                        luaentity.slot = slot .. (bi > 1 and ("_" .. bi) or "")
                        entity:set_attach(player, use_bone, final_pos, final_rot, true)
                        entity:set_properties({
                            wield_item = visual_item,
                            visual = "wielditem",
                            visual_size = final_size
                        })
                        armor_entities[player_name][luaentity.slot] = entity
                    end
                end
            end
            -- PEÇAS EXTRAS (partes adicionais da mesma armadura em outros bones)
if item_def and item_def.armor_extra_pieces then
    for ei, extra in ipairs(item_def.armor_extra_pieces) do
        local epos  = extra.pos  or xyz(0)
        local erot  = extra.rot  or xyz(0)
        local esize = extra.size or final_size
        local ebone = extra.bone
        -- pega textura: do extra, ou do item principal
        local etex  = extra.texture or (item_def.tiles and item_def.tiles[1]) or "copperlegging.png"
        local emesh = extra.mesh   -- OBRIGATÓRIO: nome do .obj

        if emesh and ebone then
            local eentity = c.add_entity(player:get_pos(), "nh_body:armor_mesh_piece")
            if eentity then
                local elu = eentity:get_luaentity()
                elu.player_name = player_name
                elu.slot = slot .. "_extra_" .. ei
                eentity:set_attach(player, ebone, epos, erot, true)
                eentity:set_properties({
                    visual      = "mesh",
                    mesh        = emesh,
                    textures    = { etex },
                    visual_size = esize,
                })
                armor_entities[player_name][elu.slot] = eentity
            end
        end
    end
end
        end
    end
end
local function update_armor_textures(player)
    if not player then return end
    local inv = player:get_inventory()
    local textures = { "skin.png" }
    for slot, _ in pairs(armor_slots) do
        local stack = inv:get_stack("armor_" .. slot, 1)
        if not stack:is_empty() then
            local item_name = stack:get_name()
            local item_def = c.registered_items[item_name]
            if item_def and item_def.armor_texture then table.insert(textures, item_def.armor_texture) end
        end
    end
    player:set_properties({ textures = textures })
    update_armor_visuals(player)
    update_player_formspec(player)
    update_body_textures(player) -- ATUALIZA CORPO VISÍVEL
end
c.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "move" or action == "put" or action == "take" then
        local listname   = inventory_info.listname or inventory_info.to_list or inventory_info.from_list
        local player_name = player:get_player_name()

        -- Armadura: atualiza visuais
        if listname and listname:match("^armor_") then
            update_armor_textures(player)
            -- Detecta equipar/desequipar backchest de forma SÍNCRONA
            -- (o slot já foi alterado aqui, pois on_* roda após a ação)
            if listname == "armor_back" then
                if bc_has_backchest(player) then
                    bc_load(player)
                else
                    -- bc_unload não pode ser chamado aqui pois a armadura já foi removida,
                    -- logo bc_save não encontraria mais o item. Os slots foram zerados
                    -- no globalstep abaixo no tick anterior. Força limpeza imediata:
                    if not bc_sync_lock[player_name] then
                        bc_sync_lock[player_name] = true
                        local inv = player:get_inventory()
                        for i = 1, BC_COUNT do
                            inv:set_stack("main", BC_OFFSET + i, ItemStack(""))
                        end
                        bc_sync_lock[player_name] = false
                    end
                end
                update_player_formspec(player)
            end
        end

        -- main: persiste mudança em slots da backchest; atualiza mãos se slot 1/2
        if listname == "main" and not bc_sync_lock[player_name] then
            local idx = inventory_info.to_index or inventory_info.from_index or inventory_info.index
            if idx and idx >= BC_OFFSET + 1 and idx <= BC_OFFSET + BC_COUNT then
                bc_save(player)
            end
            if (inventory_info.to_index == 1 or inventory_info.to_index == 2 or
                inventory_info.from_index == 1 or inventory_info.from_index == 2 or
                inventory_info.index == 1 or inventory_info.index == 2) then
                update_wielded_item(player)
                update_offhand_item(player)
            end
        end
    end
end)
local function apply_custom_model(player) -- FUNÇÃO PARA APLICAR O MODELO INVISÍVEL NO PLAYER
    if not player then return end
    local player_name = player:get_player_name()
    if not player_states[player_name] then player_states[player_name] = { body_yaw = 0, current_anim = nil } end
    player:set_properties({ -- Aplica modelo INVISÍVEL (nametag_color com alpha 0)
        visual = "mesh",
        mesh = "character11.glb",
        textures = { "blank.png" }, -- textura vazia, invisivel
        visual_size = xyz(1, 1, 1),
        collisionbox = {-0.45, 0.0, -0.45, 0.45, 2.7, 0.45},
        stepheight = 0.6,
        eye_height = 2.3,
        -- shaded = true,
        makes_footstep_sound = false,                                               -- Torna o modelo do player invisível
    })
    player:set_nametag_attributes({ color = { a = 0, r = 255, g = 255, b = 255 } }) -- Torna o nametag invisível (opcional)
    -- Ajusta a câmera para ficar à frente da cabeça
    --player:set_eye_offset(
    --    { x = 0, y = -1, z = 3 }, -- Primeira pessoa: move 3 unidades para frente (Z negativo)
    --    { x = 0, y = 7, z = -7 }  -- Terceira pessoa
    --)
end
    c.log("action", "[BODY MOD] Invisible player body applyed to player")

-- FUNÇÃO PARA A ANIMAÇÃO DE BATER PLAYER
local function trigger_punch(player)
    if not player then return end
    local name = player:get_player_name()
    local item = player:get_wielded_item():get_name()
    local has_item = item ~= "" and item ~= ":"
    if punch_timers[name] then return end -- evita spam
    if has_item then set_player_animation(player, "holding_punch") else set_player_animation(player, "punch") end
    punch_timers[name] = true
    c.after(0.35, function()
        if not player or not player:is_player() then return end
        punch_timers[name] = nil
    end)
end
local function trigger_punch_loop(player)
    if not player then return end
    local name = player:get_player_name()
    if punch_loop_timers[name] then return end
    punch_loop_timers[name] = true
    local function loop()
        if not is_punching[name] then
            punch_loop_timers[name] = nil
            return
        end
        trigger_punch(player)
        c.after(0.45, loop)
    end
    loop()
end
local function stop_punch_loop(player)
    if not player then return end
    local name = player:get_player_name()
    is_punching[name] = false
    punch_loop_timers[name] = nil
end
-- FUNÇÃO PARA ROTACIONAR CABEÇA E CORPO DO PLAYER
local function rotate_head_to_look(player)
    if not player then return end
    local player_name = player:get_player_name()
    local state = player_states[player_name]
    if not state then return end
    local look_pitch = player:get_look_vertical()
    local look_yaw = player:get_look_horizontal()
    local ctrl = player:get_player_control()
    local is_moving_keys = ctrl.up or ctrl.down or ctrl.left or ctrl.right
    if is_moving_keys then state.body_yaw = look_yaw end
    local yaw_diff = look_yaw - state.body_yaw
    while yaw_diff > math.pi do yaw_diff = yaw_diff - 2 * math.pi end
    while yaw_diff < -math.pi do yaw_diff = yaw_diff + 2 * math.pi end
    local head_pitch = math.deg(-look_pitch)
    local head_yaw_raw = math.deg(-yaw_diff)
    local head_limit = 45
    local head_yaw
    if is_moving_keys then head_yaw = 0 else head_yaw = math.max(-head_limit, math.min(head_limit, head_yaw_raw)) end
    head_pitch = math.max(-60, math.min(60, head_pitch))
    player:set_bone_override("bone_All_Head",
        {rotation = {vec = {x = 0, y = head_yaw * 0.01, z = head_pitch * 0.02}}})
    player:set_bone_override("bone_TorsoArms", { rotation = {vec = xyz(0)}})
    player:set_bone_override("bone_Legs", {rotation = {vec = xyz(0)}})
end
-- FUNÇÃO PARA DEFINIR ANIMAÇÃO DO PLAYER
set_player_animation = function(player, anim)
    if not player then return end
    local player_name = player:get_player_name()
    local state = player_states[player_name]
    if not state then return end
    if state.current_anim == anim then return end
    state.current_anim = anim
    local anim_data
    if anim == "idle" then
        anim_data = {{x = 0, y = 1}, 0.25, 0, true}
    elseif anim == "jump" then
        anim_data = {{x = 2.08, y = 2.63}, 4, 0, false}
    elseif anim == "climb" then
        anim_data = {{x = 2.08, y = 2.63}, 1, 0, true}
    elseif anim == "walk" then
        anim_data = { { x = 1, y = 2 }, 2, 0, true }
    elseif anim == "walk_back" then
        anim_data = { { x = 2, y = 1 }, 2, 0, true }
    elseif anim == "run" then
        anim_data = { { x = 1, y = 2 }, 6, 0, true }
    elseif anim == "run_back" then
        anim_data = { { x = 2, y = 1 }, 6, 0, true }
    elseif anim == "sneak" then
        anim_data = { { x = 2.63, y = 2.88 }, 2, 0, false }
    elseif anim == "sneak_walk" then
        anim_data = { { x = 2.91, y = 4.91 }, 0.8, 0, true }
    elseif anim == "sneak_walk_back" then
        anim_data = {{x = 4.91, y = 2.91 }, 0.8, 0, true}
    elseif anim == "crawling" then
        anim_data = {{x = 5.25, y = 5.5 }, 0.8, 5.5, false}
    elseif anim == "crawling_walk" then
        anim_data = {{x = 5.58, y = 6.08}, 0.8, 0, true}
    elseif anim == "swimming" then
        anim_data = {{x = 9, y = 9.5 }, 0.8, 0, true}
    elseif anim == "holding" then
        anim_data = {{x = 9.54, y = 10.5}, 7, 0, false}
    elseif anim == "holding_punch" then
        anim_data = {{x = 10.5, y = 11}, 5, 0, false}
    elseif anim == "punch" then
        anim_data = {{x = 11.54, y = 12}, 5, 0, false}
    elseif anim == "sit_down" then
        -- Faixa 12~12.5s do GLB: animação de sentar (não loop, não repete)
        anim_data = {{x = 12, y = 12.5}, 1, 0, false}
    elseif anim == "sit_idle" then
        -- Congela no frame 12.5s (pose sentado)
        anim_data = {{x = 12.5, y = 12.5}, 1, 0, false}
    elseif anim == "lie_down" then
        -- Faixa 12.5~13s do GLB: animação de deitar (não loop, não repete)
        anim_data = {{x = 12.5, y = 13}, 1, 0, false}
    elseif anim == "lie_idle" then
        -- Congela no frame 13s (pose deitado)
        anim_data = {{x = 13, y = 13 }, 1, 0, false}
    elseif anim == "fly_idle" then
        anim_data = {{x = 0, y = 0}, 1, 0, false}
    elseif anim == "fly_move" then
        anim_data = {{x = 5.375, y = 5.375}, 4, 0, true}
    end
    if anim_data then
        player:set_animation(anim_data[1], anim_data[2], anim_data[3], anim_data[4]) -- Aplica animação no player invisível
        -- Aplica a MESMA animação no corpo visível
        local body = body_entities[player_name]
        if body and body:get_luaentity() then body:set_animation(anim_data[1], anim_data[2], anim_data[3], anim_data[4]) end
    end
end
c.register_on_punchnode(function(pos, node, puncher, pointed_thing) -- ATUALIZA QUANDO O JOGADOR MUDA O ITEM SELECIONADO
    if puncher and puncher:is_player() then
        trigger_punch(puncher)
        update_wielded_item(puncher)
    end
end)
c.register_on_punchplayer(function(player, hitter) if hitter and hitter:is_player() then trigger_punch(hitter) end end)
c.register_on_placenode(function(pos, newnode, placer)
    if not placer or not placer:is_player() then return end
    local name = placer:get_player_name()
    -- marca atividade de place
    last_place_time[name] = c.get_gametime()
    is_placing[name] = true
    trigger_punch(placer)                                              -- animação única de place
    if not punch_loop_timers[name] then trigger_punch_loop(placer) end -- inicia loop se ainda não estiver ativo
end)
-- GLOBALSTEP PARA ATUALIZAR ANIMAÇÕES E ROTAÇÕES
local last_lmb = {}
local eye_sit =  {x=0, y=-0.2, z=3.5}
local eye_sit3 = {x=0, y=4, z=-7}
local eye_lie =  {x=0, y=-0.7, z=-6}
local eye_lie3 = {x=0, y=4, z=-7}
c.register_globalstep(function(dtime)     
    for _, player in ipairs(c.get_connected_players()) do    
        local function setplayeranimation(opts) set_player_animation(player, opts) end
        local player_name = player:get_player_name()
        -- Garante que fleshy (sofrer dano) nunca seja perdido
        local armor = player:get_armor_groups()
        if not armor.fleshy or armor.fleshy == 0 then player:set_armor_groups({ fleshy = 100 }) end
        local item = player:get_wielded_item()
        local item_name = item:get_name()
        local has_item = item_name ~= "" and item_name ~= ":"
        local name = player:get_player_name()
        local ctrl = player:get_player_control()
        local pos = player:get_pos()
	-- Ajuste leve no Y para verificar o nó na altura do corpo/pés
	local node_at_pos = c.get_node({x = pos.x, y = pos.y + 0.5, z = pos.z})
	local node_def = c.registered_nodes[node_at_pos.name]
	local is_climbable = node_def and node_def.climbable
        if last_sneak[player_name] ~= ctrl.sneak then last_sneak[player_name] = ctrl.sneak end
        -- BOTÃO ESQUERDO (bater)
        if ctrl.LMB then
            if not last_lmb[name] then
                is_punching[name] = true
                trigger_punch(player)
                trigger_punch_loop(player)
            end
        else
            if last_lmb[name] then stop_punch_loop(player) end
        end
        last_lmb[name] = ctrl.LMB
        if last_wielded[player_name] ~= item_name then
            last_wielded[player_name] = item_name
            update_wielded_item(player)
            update_offhand_item(player)
        end
        local inv = player:get_inventory()
        -- DETECTA MUDANÇA NOS SLOTS DE CINTO (3-8)
        local current_belt = {}
        for i = 3, 8 do
            local stack = inv:get_stack("main", i)
            current_belt[i] = stack:get_name()
        end
        local belt_changed = false
        if not last_belt_items[player_name] then
            belt_changed = true
            last_belt_items[player_name] = {}
        else
            for i = 3, 8 do
                if last_belt_items[player_name][i] ~= current_belt[i] then
                    belt_changed = true
                    break
                end
            end
        end
        -- DETECTA MUDANÇA EM TODAS AS ARMADURAS (incluindo cintura)
        local current_armor = {}
        for slot, _ in pairs(armor_slots) do
            local stack = inv:get_stack("armor_" .. slot, 1)
            current_armor[slot] = stack:get_name()
        end
        local armor_changed = false
        if not last_armor_items[player_name] then
            armor_changed = true
            last_armor_items[player_name] = {}
        else
            for slot, _ in pairs(armor_slots) do
                if last_armor_items[player_name][slot] ~= current_armor[slot] then
                    armor_changed = true
                    break
                end
            end
        end
        -- ATUALIZA ARMADURAS SE HOUVER MUDANÇA
        if armor_changed then
            last_armor_items[player_name] = current_armor
            update_armor_visuals(player)
            update_belt_items(player) -- Atualiza itens da cintura (verifica se cinto foi removido)
        end
        -- ATUALIZA ITENS DA CINTURA SE OS SLOTS MUDARAM (apenas se armor não mudou)
        if belt_changed then
            last_belt_items[player_name] = current_belt
            if not armor_changed then update_belt_items(player) end -- Só chama se armor_changed não chamou antes
        end
        -- VERIFICA MUDANÇA NA MOCHILA — síncrono, sem c.after
        local backpack_stack = inv:get_stack("armor_back", 1)
        local has_backpack = not backpack_stack:is_empty() and backpack_stack:get_name() == "nh_nodes:backchest"
        if last_backpack_state[player_name] == nil then last_backpack_state[player_name] = false end
        if last_backpack_state[player_name] ~= has_backpack then
            last_backpack_state[player_name] = has_backpack
            if has_backpack then
                bc_load(player)
            else
                -- Salva antes: neste ponto o item ainda está no inventário do player
                -- como drop (foi para o inventário principal), então buscamos pelo
                -- chest_id diretamente nos slots main[9..24] já preenchidos
                if not bc_sync_lock[player_name] then
                    bc_sync_lock[player_name] = true
                    -- Encontra o item backchest recem retirado no inventario do player
                    -- para poder salvar com o chest_id correto
                    local found_stack = nil
                    for si = 1, inv:get_size("main") do
                        local s = inv:get_stack("main", si)
                        if s:get_name() == "nh_nodes:backchest" then
                            found_stack = s
                            break
                        end
                    end
                    -- Persiste usando o item encontrado
                    if found_stack then
                        local meta     = found_stack:get_meta()
                        local chest_id = meta:get_string("chest_id")
                        if chest_id == "" then
                            chest_id = tostring(os.time()) .. "_" .. tostring(math.random(1, 999999))
                            meta:set_string("chest_id", chest_id)
                        end
                        if not backchest_stored_items then backchest_stored_items = {} end
                        local slots, has = {}, false
                        for i = 1, BC_COUNT do
                            local s = inv:get_stack("main", BC_OFFSET + i)
                            slots[i] = s:to_string()
                            if not s:is_empty() then has = true end
                        end
                        if has then
                            backchest_stored_items[chest_id] = slots
                            meta:set_string("description", "Backpack Chest\n(contains items)")
                        else
                            backchest_stored_items[chest_id] = nil
                            meta:set_string("description", "")
                            meta:set_string("chest_id", "")
                        end
                        -- Regrava o item no inventário com o meta atualizado
                        for si = 1, inv:get_size("main") do
                            local s = inv:get_stack("main", si)
                            if s:get_name() == "nh_nodes:backchest" then
                                inv:set_stack("main", si, found_stack)
                                break
                            end
                        end
                    end
                    -- Zera os slots imediatamente
                    for i = 1, BC_COUNT do
                        inv:set_stack("main", BC_OFFSET + i, ItemStack(""))
                    end
                    bc_sync_lock[player_name] = false
                end
            end
            update_player_formspec(player)
        end
        if player_states[player_name] then
            if punch_timers[player_name] then goto continue end -- não sobrescreve animação durante punch
            rotate_head_to_look(player)
            local ctrl = player:get_player_control()
            local vel = player:get_velocity()

            -- ══════════════════════════════════════════════════════════════
            -- SISTEMA DE ANIMAÇÃO DE SENTAR (máquina de estados)
            -- Gatilho: segurar sneak + pressionar aux1 duas vezes
            -- ══════════════════════════════════════════════════════════════
            
            -- Inicializa estado para este player se ainda não existe
            if not sit_state[player_name] then
                sit_state[player_name]       = "idle"
                sit_sneak_count[player_name] = 0   -- contagem de aux1 enquanto segura sneak
                sit_sneak_held[player_name]  = 0   -- não usado neste gatilho (mantido para compatibilidade)
                sit_last_sneak[player_name]  = false
                sit_anim_timer[player_name]  = 0
            end
            -- Reutilizamos sit_sneak_count para contar os cliques de aux1
            -- e adicionamos sit_last_aux1 para detectar borda do aux1
            if sit_state[player_name .. "_last_aux1"] == nil then
                sit_state[player_name .. "_last_aux1"] = false
            end

            local ss        = sit_state[player_name]
            local sneak_now = ctrl.sneak
            local sneak_was = sit_last_sneak[player_name]
            local aux1_now  = ctrl.aux1
            local aux1_was  = sit_state[player_name .. "_last_aux1"]
            -- Borda de descida do aux1 (acabou de pressionar)
            local aux1_press = aux1_now and not aux1_was
            -- Borda de descida do sneak (acabou de pressionar — nova pressão)
            local sneak_press = sneak_now and not sneak_was

            -- Qualquer tecla de movimento cancela o estado de sentar
            local movement_key = ctrl.up or ctrl.down or ctrl.left or ctrl.right or ctrl.jump
                               
                    local eye_first, eye_third = player:get_eye_offset()
                    local first_str = c.serialize(eye_first)
                    local third_str = c.serialize(eye_third)
                    --c.log(player_name, "[SITTING DEBUG] " .. " eye_offset_1st=" .. first_str .. " eye_offset_3rd=" .. third_str) 

            -- ── Estado: sentado (pose congelada) ─────────────────────────
            if ss == "sitting" then
                --c.log(player_name, "IN sitting | sneak_now=" .. tostring(sneak_now) .. " sneak_press=" .. tostring(sneak_press) .. " movement=" .. tostring(movement_key) .. " jump=" .. tostring(ctrl.jump)) -- aqui
                -- Sai APENAS por: movimento, pulo, ou nova pressão de sneak
                -- (segurar sneak continuamente desde antes NÃO cancela)
                if movement_key or ctrl.jump or sneak_press then
                    sit_state[player_name]       = "idle"
                    sit_sneak_count[player_name] = 0
                    -- A lógica abaixo vai selecionar a animação correta
                    --c.log(player_name, "Applying NORMAL camera")
                elseif aux1_press then
                    -- Conta duplo clique de aux1 para deitar
                    sit_sneak_count[player_name] = (sit_sneak_count[player_name] or 0) + 1
                    if sit_sneak_count[player_name] >= 2 then
                        -- Duplo aux1 no sitting → inicia animação de deitar
                        sit_state[player_name]       = "lie_anim"
                        sit_anim_timer[player_name]  = 0
                        sit_sneak_count[player_name] = 0
                        set_player_animation(player, "lie_down")
                        sit_last_sneak[player_name]          = sneak_now
                        sit_state[player_name .. "_last_aux1"] = aux1_now
                        goto continue
                    end
                    set_player_animation(player, "sit_idle")
                    sit_last_sneak[player_name]          = sneak_now
                    sit_state[player_name .. "_last_aux1"] = aux1_now
                    player:set_properties({eye_height = 1})
                    player:set_eye_offset(eye_sit, eye_sit3)
                    goto continue
                else
                    -- Mantém pose sentado, bloqueia o resto da lógica
                    set_player_animation(player, "sit_idle")
                    sit_last_sneak[player_name]          = sneak_now
                    sit_state[player_name .. "_last_aux1"] = aux1_now
                    player:set_properties({eye_height = 1})
                    player:set_eye_offset(eye_sit,eye_sit3)
                    --c.log(player_name, "Applying sitting camera (sitting and no movement_key or ctrl.jump or sneak_press)")
                    goto continue
                end

            -- ── Estado: reproduzindo animação de deitar (transição) ───────
            elseif ss == "lie_anim" then
                if movement_key or ctrl.jump or sneak_press then
                    sit_state[player_name]       = "idle"
                    sit_sneak_count[player_name] = 0
                else
                    sit_anim_timer[player_name] = sit_anim_timer[player_name] + dtime
                    -- Animação de deitar dura 0.5s (12.5~13s no GLB)
                    if sit_anim_timer[player_name] >= 0.7 then
                        sit_state[player_name] = "lying"
                    end
                    set_player_animation(player, "lie_down")
                    player:set_properties({eye_height = 0.7})
                    player:set_eye_offset(eye_lie, eye_lie3)
                    sit_last_sneak[player_name]          = sneak_now
                    sit_state[player_name .. "_last_aux1"] = aux1_now
                    goto continue
                end

            -- ── Estado: deitado (pose congelada) ──────────────────────────
            elseif ss == "lying" then
                -- Sai pelas mesmas teclas que saem do sitting:
                -- movimento, pulo, nova pressão de sneak, ou duplo aux1
                if movement_key or ctrl.jump or sneak_press then
                    sit_state[player_name]       = "idle"
                    sit_sneak_count[player_name] = 0
                elseif aux1_press then
                    -- Conta duplo clique de aux1 para voltar ao sitting
                    sit_sneak_count[player_name] = (sit_sneak_count[player_name] or 0) + 1
                    if sit_sneak_count[player_name] >= 2 then
                        -- Duplo aux1 no lying → volta ao sitting
                        sit_state[player_name]       = "sitting"
                        sit_sneak_count[player_name] = 0
                        set_player_animation(player, "sit_idle")
                        sit_last_sneak[player_name]          = sneak_now
                        sit_state[player_name .. "_last_aux1"] = aux1_now
                        player:set_properties({eye_height = 1})
                        player:set_eye_offset(eye_sit, eye_sit3)
                        goto continue
                    end
                    set_player_animation(player, "lie_idle")
                    sit_last_sneak[player_name]          = sneak_now
                    sit_state[player_name .. "_last_aux1"] = aux1_now
                    player:set_properties({eye_height = 0.7})
                    player:set_eye_offset(eye_lie, eye_lie3)
                    goto continue
                else
                    -- Mantém pose deitado
                    set_player_animation(player, "lie_idle")
                    sit_last_sneak[player_name]          = sneak_now
                    sit_state[player_name .. "_last_aux1"] = aux1_now
                    player:set_properties({eye_height = 0.7})
                    player:set_eye_offset(eye_lie, eye_lie3)
                    goto continue
                end

            -- ── Estado: reproduzindo animação de sentar (transição) ───────
            elseif ss == "sit_anim" then
                -- Mesma regra: só cancela por movimento/pulo/nova pressão sneak
                if movement_key or ctrl.jump or sneak_press then
                    sit_state[player_name]       = "idle"
                    sit_sneak_count[player_name] = 0
                    -- cai para lógica normal abaixo
                else
                    sit_anim_timer[player_name] = sit_anim_timer[player_name] + dtime
                    -- Animação dura 0.5s (de 12 a 12.5 no GLB → velocidade 1 = 0.5s)
                    if sit_anim_timer[player_name] >= 0.5 then
                        -- Transição completa → congela na pose final
                        sit_state[player_name]       = "sitting"
                        sit_sneak_count[player_name] = 0  -- reseta contador para o duplo aux1
                        player:set_eye_offset(eye_sit,eye_sit3)
                    end
                    set_player_animation(player, "sit_down")
                    player:set_eye_offset(eye_sit,eye_sit3)
                    sit_last_sneak[player_name]          = sneak_now
                    sit_state[player_name .. "_last_aux1"] = aux1_now
                    --c.log(player_name, "Applying sitting camera (sit_anim and no movement_key or ctrl.jump or sneak_press)")
                    goto continue
                end

            -- ── Estado: idle — aguardando o gatilho ───────────────────────
            elseif ss == "idle" then
                -- Só inicia contagem se sneak estiver pressionado
                if sneak_now and aux1_press then
                    sit_sneak_count[player_name] = 1
                    sit_state[player_name]       = "counting"
                end
                -- Movimento sem sneak reseta tudo (garantia)
                if movement_key and not sneak_now then
                    sit_sneak_count[player_name] = 0
                end

            -- ── Estado: counting — sneak segurado, contando aux1 ─────────
            elseif ss == "counting" then
                if not sneak_now then
                    -- Soltou o sneak antes de completar → reseta
                    sit_state[player_name]       = "idle"
                    sit_sneak_count[player_name] = 0
                elseif movement_key then
                    -- Moveu → reseta
                    sit_state[player_name]       = "idle"
                    sit_sneak_count[player_name] = 0
                elseif aux1_press then
                    sit_sneak_count[player_name] = sit_sneak_count[player_name] + 1
                    if sit_sneak_count[player_name] >= 2 then
                        -- 2º clique de aux1 com sneak segurado → ativa sentar!
                        sit_state[player_name]       = "sit_anim"
                        sit_anim_timer[player_name]  = 0
                        sit_sneak_count[player_name] = 0
                        set_player_animation(player, "sit_down")
                        player:set_eye_offset(eye_offset_first, eye_offset_third)
                        sit_last_sneak[player_name]          = sneak_now
                        sit_state[player_name .. "_last_aux1"] = aux1_now
                        goto continue
                    end
                end
            end

            sit_last_sneak[player_name]          = sneak_now
            sit_state[player_name .. "_last_aux1"] = aux1_now
            
            -- END OF SITTING SYSTEM — normal animation logic below
            -- ══════════════════════════════════════════════════════════════
            
            local vel = player:get_velocity()
            local is_moving_vertically = math.abs(vel.y) > 0.1
            -- Lê o estado de climb do mod moves (tabela global separada, não mexe em player_states deste mod)
            local is_wall_climbing = moves_player_states and moves_player_states[name] == "climb"
            -- ANIMAÇÃO DE VOO COM ASAS
            local inv = player:get_inventory()
            local back_stack = inv:get_stack("armor_back", 1)
            local has_wings = not back_stack:is_empty() and back_stack:get_name() == "nh_nodes:wings" or back_stack:get_name() == "nh_nodes:gravitywings"
            local fly_privs = c.get_player_privs(name)
            if has_wings and fly_privs and fly_privs.fly then
                -- Dobra a velocidade de movimento com asas
                player:set_physics_override({ speed = 6, jump = 3 })
                local horizontal_speed = math.sqrt(vel.x * vel.x + vel.z * vel.z)
                local vertical_speed = math.abs(vel.y)
                local fly_eye_offset_third = {x=0, y=6, z=-7}
                if ctrl.sneak then
                    set_player_animation(player, "sneak")
                    player:set_properties({eye_height = 1})
                    player:set_eye_offset({x=0, y=6, z=9}, fly_eye_offset_third)
                elseif horizontal_speed > 0.1 or vertical_speed > 0.1 then
                    set_player_animation(player, "fly_move")
                    player:set_properties({eye_height = 1})
                    player:set_eye_offset({x=0, y=-1, z=5}, fly_eye_offset_third)
                else set_player_animation(player, "idle")
                    player:set_properties({eye_height = 2.3})
                    player:set_eye_offset({x=0, y=-0.2, z=3.5}, fly_eye_offset_third)
                end
                goto continue
            end
            -- Animação de wall climb enquanto o jogador estiver subindo na parede
            if is_wall_climbing then set_player_animation(player, "climb")
                -- Reseta quando soltar o pulo
                if not ctrl.jump then moves_player_states[name] = nil end
            elseif is_climbable and (ctrl.up or ctrl.down or ctrl.jump or ctrl.sneak) then
                set_player_animation(player, "climb")
                -- Opcional: Forçar movimento vertical se o motor não estiver fazendo sozinho
                -- Isso garante que a animação de climb rode enquanto ele sobe/desce
                if ctrl.jump then player:set_velocity({x=vel.x, y=3, z=vel.z}) -- Velocidade de subida
                elseif ctrl.sneak and is_climbable then player:set_velocity({x=vel.x, y=-3, z=vel.z}) -- Velocidade de descida
                end
            elseif ctrl.jump and vel.y >= 0.1 and not is_climbable then
                set_player_animation(player, "jump")
            else
                local props = player:get_properties()
                local is_crawling = props.eye_height <= 0.7
                local horizontal = {x = vel.x, y = 0, z = vel.z}
                local speed = vector.length(horizontal)
                local is_moving_back = ctrl.down
                local is_moving = ctrl.up or ctrl.left or ctrl.right
                -- ANIMAÇÕES
                if is_crawling then
                    if speed > 0.1 then setplayeranimation("crawling_walk") else setplayeranimation("crawling") end
                elseif ctrl.sneak and vel.x < 0.1 and vel.z < 0.1 then
                    set_player_animation(player, "sneak")
                    -- player:set_properties({ collisionbox = {-0.6, 0.0, -0.6, 0.6, 2.7, 0.6} })
                else
                    player:set_properties({ collisionbox = {-0.45, 0.0, -0.45, 0.45, 2.7, 0.45 }})
                    if is_moving_back then
                        if ctrl.sneak and speed >= 0.1 then setplayeranimation("sneak_walk_back")
                        elseif ctrl.aux1 or speed >= 4 then setplayeranimation("run_back")
                        elseif speed < 4 and speed > 0 then setplayeranimation("walk_back")
                        end
                    elseif is_moving then
                        if ctrl.sneak and speed >= 0.1 then setplayeranimation("sneak_walk")
                        elseif ctrl.aux1 or speed >= 4 then setplayeranimation("run")
                        elseif speed < 4 and speed > 0 then setplayeranimation("walk")
                        end
                    else if has_item then setplayeranimation("holding") else setplayeranimation("idle") end end
                end
                if riding_players and riding_players[player:get_player_name()] then goto continue end
                -- EYE OFFSET: definido uma única vez, após determinar o estado
                local eye_offset_first
                local eye_offset_third = xyz(0, 6, -7)
                if is_crawling then eye_offset_first = xyz(0, -0.7, 7.5)
                elseif ctrl.sneak then  eye_offset_first = xyz(0, 6, 9)
                else player:set_properties({eye_height = 2.3})
                    eye_offset_first = xyz(0, -0.2, 3.5)
                end
                player:set_eye_offset(eye_offset_first, eye_offset_third)
            end
            ::continue::
        end
    end
end) -- EVENTOS DE JOGADOR
c.register_on_joinplayer(function(player)
    player:hud_set_flags({ wielditem = false })
    player:set_lighting({ shadows = { intensity = 0.33 } })
    local player_name = player:get_player_name()
    player_states[player_name] = { body_yaw = 0, current_anim = nil }
    create_armor_inventory(player)
    player:set_inventory_formspec(get_armor_formspec(player_name))

    local check_count = 0
    local max_checks = 10
    local function verify_and_apply()
        if not player or not player:is_player() then return end
        check_count = check_count + 1
        apply_custom_model(player)
        local props = player:get_properties()
        if props.eye_height ~= 2.6 and check_count < max_checks then c.after(0.2, verify_and_apply) end
    end
    -- Delay maior para garantir que o mundo carregou no cliente
    c.after(0.3, function()
        if not (player and player:is_player()) then return end
        verify_and_apply()
        create_player_body(player)
        update_wielded_item(player)
        update_offhand_item(player)
        update_armor_visuals(player)
        update_belt_items(player)
        -- Restaura itens da backchest se estiver equipada
        if bc_has_backchest(player) then bc_load(player) end
    end)
    -- Segunda tentativa de segurança: recria o corpo se não existir após 3s
    c.after(2.0, function()
        if not (player and player:is_player()) then return end
        if not body_entities[player_name] or not body_entities[player_name]:get_luaentity() then
            c.log("action", "[BODY MOD] Body not found after 2 seconds, recreating for " .. player_name)
            create_player_body(player)
        end
    end)
    -- Terceira tentativa de segurança: recria o corpo se não existir após 3s
    c.after(4.0, function()
        if not (player and player:is_player()) then return end
        if not body_entities[player_name] or not body_entities[player_name]:get_luaentity() then
            c.log("action", "[BODY MOD] Body not found after 4 seconds, recreating for " .. player_name)
            create_player_body(player)
        end
    end)
end)
c.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    -- Persiste itens da backchest e limpa os slots antes de sair
    if bc_has_backchest(player) then
        bc_save(player)
        local inv = player:get_inventory()
        for i = 1, BC_COUNT do inv:set_stack("main", BC_OFFSET + i, ItemStack("")) end
    end
    player_states[player_name] = nil
    last_wielded[player_name] = nil
    last_wield_index[player_name] = nil
    last_belt_items[player_name] = nil
    last_armor_items[player_name] = nil
    last_backpack_state[player_name] = nil
    -- Limpa estado de sentar
    sit_state[player_name]       = nil
    sit_sneak_count[player_name] = nil
    sit_sneak_held[player_name]  = nil
    sit_last_sneak[player_name]  = nil
    sit_anim_timer[player_name]  = nil
    if wielded_entities[player_name] then
        wielded_entities[player_name]:remove()
        wielded_entities[player_name] = nil
    end
    if offhand_entities[player_name] then
        offhand_entities[player_name]:remove()
        offhand_entities[player_name] = nil
    end
    if belt_entities[player_name] then
        for slot_num, entity in pairs(belt_entities[player_name]) do
            if entity and entity:get_luaentity() then entity:remove() end
        end
        belt_entities[player_name] = nil
    end
    if armor_entities[player_name] then
        for slot, entity in pairs(armor_entities[player_name]) do
            if entity and entity:get_luaentity() then entity:remove() end
        end
        armor_entities[player_name] = nil
    end
    if body_entities[player_name] then
        body_entities[player_name]:remove()
        body_entities[player_name] = nil
    end
end)
c.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    if wielded_entities[player_name] then
        wielded_entities[player_name]:remove()
        wielded_entities[player_name] = nil
    end
    if offhand_entities[player_name] then
        offhand_entities[player_name]:remove()
        offhand_entities[player_name] = nil
    end
    if armor_entities[player_name] then
        for slot, entity in pairs(armor_entities[player_name]) do
            if entity and entity:get_luaentity() then entity:remove() end
        end
        armor_entities[player_name] = nil
    end
    if body_entities[player_name] then
        body_entities[player_name]:remove()
        body_entities[player_name] = nil
    end
end)
c.register_on_respawnplayer(function(player)
    c.after(0.5, function()
        if player and player:is_player() then
            apply_custom_model(player)
            create_player_body(player)
        end
    end)
end)

-- SISTEMA DE INVENTÁRIO: primeiros 8 slots + backchest
-- Verifica se os 8 primeiros slots do inventário principal estão cheios
local function main8_is_full(inv)
    for i = 1, 8 do
        local s = inv:get_stack("main", i)
        if s:is_empty() then return false end
        -- slot com item mas sem stack cheio também é espaço disponível
        local item_def = c.registered_items[s:get_name()]
        local max = (item_def and item_def.stack_max) or 99
        if s:get_count() < max then return false end
    end
    return true
end

-- Tenta inserir um ItemStack nos 8 primeiros slots.
-- Retorna o leftover (o que não coube).
local function insert_into_main8(inv, stack)
    local leftover = ItemStack(stack)
    for i = 1, 8 do
        if leftover:is_empty() then break end
        local slot = inv:get_stack("main", i)
        -- Slot vazio: coloca tudo que couber
        if slot:is_empty() then
            local max = leftover:get_definition().stack_max or 99
            local to_add = math.min(leftover:get_count(), max)
            local new_stack = ItemStack(leftover)
            new_stack:set_count(to_add)
            inv:set_stack("main", i, new_stack)
            leftover:set_count(leftover:get_count() - to_add)
        elseif slot:get_name() == leftover:get_name() then
            -- Mesmo item: empilha
            local max = slot:get_definition().stack_max or 99
            local space = max - slot:get_count()
            if space > 0 then
                local to_add = math.min(leftover:get_count(), space)
                slot:set_count(slot:get_count() + to_add)
                inv:set_stack("main", i, slot)
                leftover:set_count(leftover:get_count() - to_add)
            end
        end
    end
    return leftover
end

-- Item quebrado: dropa e avisa quando os 8 primeiros slots estão cheios
-- Injeta `after_use` em todas as ferramentas após todos os mods carregarem.
c.after(0, function()
    -- Injeta after_use em todas as ferramentas para capturar quebra
    for name, def in pairs(c.registered_tools) do
        local original_after_use = def.after_use
        c.override_item(name, {
            after_use = function(itemstack, user, node, digparams)
                -- Chama o after_use original se existir
                if original_after_use then itemstack = original_after_use(itemstack, user, node, digparams) or itemstack
                else itemstack:add_wear(digparams and digparams.wear or 0) -- Comportamento padrão: aplica desgaste
                end
                -- Se quebrou (stack vazio após desgaste)
                if itemstack:is_empty() and user and user:is_player() then
                    local inv = user:get_inventory()
                    -- Verifica se os 8 primeiros slots estão cheios
                    -- (se não estiverem, o motor devolve o item normalmente — não há nada a dropar)
                    -- Quando a ferramenta quebra ela simplesmente some; não há item para dropar
                    -- a menos que o jogo defina um `on_tool_broken`. Emitimos mensagem apenas.
                    if main8_is_full(inv) then
                        c.chat_send_player(user:get_player_name(), S"I pulled that off, but dropped it. There's no room to hold on to!")
                    end
                end
                return itemstack
            end
        })
    end
end)

-- Drop clicado no chão: controle de coleta
c.register_on_item_pickup(function(itemstack, picker, pointed_thing, time_from_last_punch, ...)
    if not picker or not picker:is_player() then return end
    local inv = picker:get_inventory()
    local player_name = picker:get_player_name()
    local leftover = insert_into_main8(inv, itemstack) -- Tenta inserir nos 8 primeiros slots
    if leftover:is_empty() then return ItemStack("") end -- Tudo coube nos 8 primeiros slots — coleta normal -- retorna stack vazio = item coletado
    -- Não coube tudo nos 8 primeiros slots.
    -- Verifica se há backchest equipada.
    if bc_has_backchest(picker) then
        -- Tenta colocar o restante nos slots da backchest (main[9..24])
        local bc_leftover2 = ItemStack(leftover)
        for i = BC_OFFSET + 1, BC_OFFSET + BC_COUNT do
            if bc_leftover2:is_empty() then break end
            local slot = inv:get_stack("main", i)
            if slot:is_empty() then
                local max = bc_leftover2:get_definition().stack_max or 99
                local to_add = math.min(bc_leftover2:get_count(), max)
                local ns = ItemStack(bc_leftover2)
                ns:set_count(to_add)
                inv:set_stack("main", i, ns)
                bc_leftover2:set_count(bc_leftover2:get_count() - to_add)
            elseif slot:get_name() == bc_leftover2:get_name() then
                local max = slot:get_definition().stack_max or 99
                local space = max - slot:get_count()
                if space > 0 then
                    local to_add = math.min(bc_leftover2:get_count(), space)
                    slot:set_count(slot:get_count() + to_add)
                    inv:set_stack("main", i, slot)
                    bc_leftover2:set_count(bc_leftover2:get_count() - to_add)
                end
            end
        end
        bc_save(picker) -- persiste na backchest
        if bc_leftover2:is_empty() then return ItemStack("") -- tudo coube (hotbar + backchest)
        else c.chat_send_player(player_name, S"My pockets and backpack chest are full!") return bc_leftover2 -- devolve o que não coube
        end -- Nem a backchest tinha espaço; deixa o que sobrou no chão
    else c.chat_send_player(player_name, S"My pockets are full! I need some equipment to carry more.") -- Sem backchest: os 8 slots estão cheios, não coleta
        return itemstack -- devolve o stack inteiro (não coleta nada)
    end
end)
