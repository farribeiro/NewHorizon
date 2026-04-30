print("[body] Mod carregado")
-- TABELAS GLOBAIS
--local shadow_objects = {}
local zeroaxys = { x = 0, y = 0, z = 0 }
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
local armor_slots = {
    head = "Cabeça",
    torso = "Tronco",
    arms = "Braços",
    legs = "Pernas",
    back = "Costas",
    waist = "Cintura",
    hands = "Mãos",
    feet = "Pés"
}
-- TABELA PARA CONTROLAR ANIMAÇÕES DE SOCO
local punch_timers = {}
local punch_loop_timers = {}
local is_punching = {}
local is_placing = {}
local last_place_time = {}
-- forward declarations (OBRIGATÓRIO)
local set_player_animation
local trigger_punch
local trigger_punch_loop
local stop_punch_loop
local rotate_head_to_look
-- REGISTRA A ENTIDADE DO CORPO DO PLAYER
core.register_entity("nh_body:player_body", {
    initial_properties = {
        visual = "mesh",
        mesh = "character5.glb",
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
    end,
    on_step = function(self, dtime)
        if not self.player_name then
            self.object:remove()
            return
        end
        local player = core.get_player_by_name(self.player_name)
        if not player then
            self.object:remove()
            return
        end
        -- Sincroniza rotações dos bones apenas se mudaram
        local head_rot  = player:get_bone_override("bone_All_Head").rotation.vec
        local torso_rot = player:get_bone_override("bone_TorsoArms").rotation.vec
        local legs_rot  = player:get_bone_override("bone_Legs").rotation.vec
        if not self.last_bone_head or not vector.equals(head_rot, self.last_bone_head.rot) then -- Verifica se a rotação da cabeça mudou
            self.object:set_bone_override("bone_All_Head", { rotation = { vec = head_rot } })
            self.last_bone_head = { rot = head_rot }
        end
        if not self.last_bone_torso or not vector.equals(torso_rot, self.last_bone_torso.rot) then -- Verifica se a rotação do torso mudou
            self.object:set_bone_override("bone_TorsoArms", { rotation = { vec = torso_rot } })
            self.last_bone_torso = { rot = torso_rot }
        end
        if not self.last_bone_legs or not vector.equals(legs_rot, self.last_bone_legs.rot) then -- Verifica se a rotação das pernas mudou
            self.object:set_bone_override("bone_Legs", { rotation = { vec = legs_rot } })
            self.last_bone_legs = { rot = legs_rot }
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
    local body = core.add_entity(pos, "nh_body:player_body")
    if body then
        local luaentity = body:get_luaentity()
        luaentity.player_name = player_name
        -- Anexa ao player na mesma posição
        body:set_attach(player, "", -- Bone principal (corpo todo)
            zeroaxys, zeroaxys, true)
        -- ★ SINCRONIZA OS BONES IMEDIATAMENTE ★
        core.after(0.1, function()
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
        print("[body] Corpo visível criado para " .. player_name)
    else
        print("[body] ERRO: Não foi possível criar corpo visível para " .. player_name)
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
            local item_def = core.registered_items[item_name]
            if item_def and item_def.armor_texture then table.insert(textures, item_def.armor_texture) end
        end
    end
    body:set_properties({ textures = textures }) -- Atualiza textura do corpo visível
end
-- REGISTRA A ENTIDADE DO ITEM NA CINTURA
core.register_entity("nh_body:belt_item", {
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
        local player = core.get_player_by_name(self.player_name)
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
                local entity = core.add_entity(pos, "nh_body:belt_item")
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
-- core.register_craftitem(":",
--     {
--         type = "none",
--         wield_image = "",
--         wield_scale = zeroaxys,
--         range = 4,
--         inventory_image = "",
--         tool_capabilities = hand_capabilities,
--         visual_scale = 0,
--         pointable = false,
--     })
core.override_item("", { -- "" é o itemstring da mão sem itens
    wield_image = "",
    wield_scale = zeroaxys,
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
    local item_def = core.registered_items[item_name]
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
    local entity = core.add_entity(pos, "nh_body:wielded_item")
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
    local item_def = core.registered_items[offhand_name]
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
    local entity = core.add_entity(pos, "nh_body:offhand_item")
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
core.register_entity("nh_body:wielded_item", {
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
        local player = core.get_player_by_name(self.player_name)
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
core.register_entity("nh_body:offhand_item", {
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
        local player = core.get_player_by_name(self.player_name)
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
core.register_entity("nh_body:armor_piece", {
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
        local player = core.get_player_by_name(self.player_name)
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
    local player = core.get_player_by_name(player_name)
    if not player then return "" end
    local inv = player:get_inventory()
    local backpack_stack = inv:get_stack("armor_back", 1)
    local has_backpack = not backpack_stack:is_empty() and backpack_stack:get_name() == "nh_nodes:backchest"
    return table.concat(
        { "size[9,9.5]", "bgcolor[#00000000;true]", "background[0,0;9,9.5;gui_formbg.png]",
            "label[0.5,0.5;Cabeça]", "list[current_player;armor_head;0.5,0.5;1,1;]",
            "label[0.5,1.6;Tronco]", "list[current_player;armor_torso;0.5,1.6;1,1;]",
            "label[0.5,2.7;Pernas]", "list[current_player;armor_legs;0.5,2.7;1,1;]",
            "label[0.5,3.8;Pés]", "list[current_player;armor_feet;0.5,3.8;1,1;]",
            "model[1.25,0.5;3,6;player_model;character5.glb;skin.png;0,180;false;true]",
            "label[1.75,4.8;" .. core.formspec_escape(player_name) .. "]",
            "label[3.5,0.5;Costas]", "list[current_player;armor_back;3.5,0.5;1,1;]",
            "label[3.5,1.6;Braços]", "list[current_player;armor_arms;3.5,1.6;1,1;]",
            "label[3.5,2.7;Mãos]", "list[current_player;armor_hands;3.5,2.7;1,1;]",
            "label[3.5,3.8;Cintura]",
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
core.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "move" then
        local from_list = inventory_info.from_list
        local to_list = inventory_info.to_list
        if to_list:match("^armor_") then
            local slot_type = to_list:gsub("armor_", "")
            local stack = inventory:get_stack(from_list, inventory_info.from_index)
            local item_name = stack:get_name()
            local item_def = core.registered_items[item_name]
            if not item_def or not item_def.groups or not item_def.groups["armor_" .. slot_type] then return 0 end
            return stack:get_count()
        end
    elseif action == "put" then
        local listname = inventory_info.listname
        if listname:match("^armor_") then
            local slot_type = listname:gsub("armor_", "")
            local stack = inventory_info.stack
            local item_name = stack:get_name()
            local item_def = core.registered_items[item_name]
            if not item_def or not item_def.groups or not item_def.groups["armor_" .. slot_type] then return 0 end
            return stack:get_count()
        end
    end
    if inventory_info.count then
        return inventory_info.count
    elseif inventory_info.stack then
        return inventory_info.stack:get_count()
    else
        return 1
    end
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
        head = {
            bone = "bone_All_Head",
            pos = { x = 0, y = 4.75, z = 0 },
            rot = zeroaxys,
            size = { x = 0.3, y = 0.3, z = 0.3 },
        },
        torso = {
            bone = "bone_TorsoArms",
            pos = zeroaxys,
            rot = zeroaxys,
            size = { x = 0.35, y = 0.35, z = 0.35 }
        },
        waist = {
            bone = "bone_TorsoArms",
            pos = { x = 0.5, y = 2.5, z = 0 },
            rot = { x = 0, y = -90, z = 0 },
            size = { x = 0.3, y = 0.3, z = 0.3 }
        },
        legs = {
            bone = "bone_Legs",
            pos = zeroaxys,
            rot = zeroaxys,
            size = { x = 0.3, y = 0.3, z = 0.3 }
        },
        back = {
            bone = "bone_TorsoArms",
            pos = { x = -2.5, y = 2.5, z = 0 },
            rot = { x = 0, y = -90, z = 0 },
            size = { x = 0.3, y = 0.3, z = 0.3 }
        },
        arms = {
            bone = "bone_TorsoArms",
            pos = { x = 0, y = -2, z = 0 },
            rot = zeroaxys,
            size = { x = 0.25, y = 0.25, z = 0.25 }
        },
        hands = {
            bone = "bone_RHand",
            pos = zeroaxys,
            rot = zeroaxys,
            size = { x = 0.2, y = 0.2, z = 0.2 }
        },
        feet = {
            bone = "bone_Legs",
            pos = { x = 0, y = -4, z = 0 },
            rot = zeroaxys,
            size = { x = 0.25, y = 0.25, z = 0.25 }
        }
    }
    for slot, config in pairs(armor_bones) do
        local stack = inv:get_stack("armor_" .. slot, 1)
        if not stack:is_empty() then
            local item_name = stack:get_name()
            local item_def = core.registered_items[item_name]
            -- COPIA OS VALORES PADRÃO
            local final_pos = config.pos
            local final_rot = config.rot
            local final_size = config.size
            -- SOBRESCREVE COM VALORES CUSTOMIZADOS SE EXISTIREM
            if item_def then
                -- Suporte para armor_bone_position
                if item_def.armor_bone_position then
                    final_pos = item_def.armor_bone_position.pos or final_pos
                    final_rot = item_def.armor_bone_position.rot or final_rot
                end
                final_size = item_def.armor_visual_size or final_size -- Suporte para armor_visual_size
            end
            local visual_item = item_name
            if item_def and item_def.armor_model then visual_item = item_def.armor_model end
            local pos = player:get_pos()
            local entity = core.add_entity(pos, "nh_body:armor_piece")
            if entity then
                local luaentity = entity:get_luaentity()
                luaentity.player_name = player_name
                luaentity.slot = slot
                entity:set_attach(player, config.bone, final_pos, -- USA POSIÇÃO CUSTOMIZADA
                    final_rot,                                    -- USA ROTAÇÃO CUSTOMIZADA
                    true)
                entity:set_properties({
                    wield_item = visual_item,
                    visual = "wielditem",
                    visual_size = final_size -- USA TAMANHO CUSTOMIZADO
                })
                armor_entities[player_name][slot] = entity
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
            local item_def = core.registered_items[item_name]
            if item_def and item_def.armor_texture then table.insert(textures, item_def.armor_texture) end
        end
    end
    player:set_properties({ textures = textures })
    update_armor_visuals(player)
    update_player_formspec(player)
    update_body_textures(player) -- ATUALIZA CORPO VISÍVEL
end
core.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "move" or action == "put" or action == "take" then
        local listname = inventory_info.listname or inventory_info.to_list or inventory_info.from_list
        if listname and listname:match("^armor_") then update_armor_textures(player) end -- ATUALIZA ARMADURAS
        if listname == "main" then                                                       -- ATUALIZA ITENS NAS MÃOS quando inventário main muda
            local to_index = inventory_info.to_index or inventory_info.index
            local from_index = inventory_info.from_index
            -- Verifica se a mudança afeta os slots 1 ou 2
            if (to_index and (to_index == 1 or to_index == 2)) or (from_index and (from_index == 1 or from_index == 2)) then
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
        mesh = "character5.glb",
        textures = { "blank.png" }, -- textura vazia, invisivel
        visual_size = { x = 1, y = 1, z = 1 },
        collisionbox = { -0.45, 0.0, -0.45, 0.45, 2.7, 0.45 },
        stepheight = 0.6,
        eye_height = 2.5,
        -- shaded = true,
        makes_footstep_sound = false,                                               -- Torna o modelo do player invisível
    })
    player:set_nametag_attributes({ color = { a = 0, r = 255, g = 255, b = 255 } }) -- Torna o nametag invisível (opcional)
    -- Ajusta a câmera para ficar à frente da cabeça
    player:set_eye_offset(
        { x = 0, y = -1, z = 3 }, -- Primeira pessoa: move 3 unidades para frente (Z negativo)
        { x = 0, y = 7, z = -7 }  -- Terceira pessoa
    )
    print("[body] Modelo invisível aplicado para " .. player_name)
end
-- FUNÇÃO PARA A ANIMAÇÃO DE BATER PLAYER
local function trigger_punch(player)
    if not player then return end
    local name = player:get_player_name()
    local item = player:get_wielded_item():get_name()
    local has_item = item ~= "" and item ~= ":"
    if punch_timers[name] then return end -- evita spam
    if has_item then set_player_animation(player, "holding_punch") else set_player_animation(player, "punch") end
    punch_timers[name] = true
    core.after(0.35, function()
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
        core.after(0.45, loop)
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
        { rotation = { vec = { x = 0, y = head_yaw * 0.01, z = head_pitch * 0.02 } } })
    player:set_bone_override("bone_TorsoArms", { rotation = { vec = zeroaxys } })
    player:set_bone_override("bone_Legs", { rotation = { vec = zeroaxys } })
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
        anim_data = { { x = 0, y = 1 }, 0.25, 0, true }
    elseif anim == "jump" then
        anim_data = { { x = 2.08, y = 2.63 }, 4, 0, false }
    elseif anim == "climb" then
        anim_data = { { x = 2.08, y = 2.63 }, 1, 0, true }
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
        anim_data = { { x = 4.91, y = 2.91 }, 0.8, 0, true }
    elseif anim == "crawling" then
        anim_data = { { x = 5.25, y = 5.5 }, 0.8, 5.5, false }
    elseif anim == "crawling_walk" then
        anim_data = { { x = 5.58, y = 6.08 }, 0.8, 0, true }
    elseif anim == "swimming" then
        anim_data = { { x = 9, y = 9.5 }, 0.8, 0, true }
    elseif anim == "holding" then
        anim_data = { { x = 9.54, y = 10.5 }, 7, 0, false }
    elseif anim == "holding_punch" then
        anim_data = { { x = 10.5, y = 11 }, 7, 0, false }
    elseif anim == "punch" then
        anim_data = { { x = 11.54, y = 12 }, 7, 0, false }
    end
    if anim_data then
        player:set_animation(anim_data[1], anim_data[2], anim_data[3], anim_data[4]) -- Aplica animação no player invisível
        -- Aplica a MESMA animação no corpo visível
        local body = body_entities[player_name]
        if body and body:get_luaentity() then body:set_animation(anim_data[1], anim_data[2], anim_data[3], anim_data[4]) end
    end
end
core.register_on_punchnode(function(pos, node, puncher, pointed_thing) -- ATUALIZA QUANDO O JOGADOR MUDA O ITEM SELECIONADO
    if puncher and puncher:is_player() then
        trigger_punch(puncher)
        update_wielded_item(puncher)
    end
end)
core.register_on_punchplayer(function(player, hitter) if hitter and hitter:is_player() then trigger_punch(hitter) end end)
core.register_on_placenode(function(pos, newnode, placer)
    if not placer or not placer:is_player() then return end
    local name = placer:get_player_name()
    -- marca atividade de place
    last_place_time[name] = core.get_gametime()
    is_placing[name] = true
    trigger_punch(placer)                                              -- animação única de place
    if not punch_loop_timers[name] then trigger_punch_loop(placer) end -- inicia loop se ainda não estiver ativo
end)
-- GLOBALSTEP PARA ATUALIZAR ANIMAÇÕES E ROTAÇÕES
local last_lmb = {}
core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do
        local function setplayeranimation(opts) set_player_animation(player, opts) end
        local player_name = player:get_player_name()
        -- ✅ Garante que fleshy (sofrer dano) nunca seja perdido
        local armor = player:get_armor_groups()
        if not armor.fleshy or armor.fleshy == 0 then player:set_armor_groups({ fleshy = 100 }) end
        local item = player:get_wielded_item()
        local item_name = item:get_name()
        local has_item = item_name ~= "" and item_name ~= ":"
        local name = player:get_player_name()
        local ctrl = player:get_player_control()
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
        -- VERIFICA MUDANÇA NA MOCHILA (sempre executa)
        local backpack_stack = inv:get_stack("armor_back", 1)
        local has_backpack = not backpack_stack:is_empty() and backpack_stack:get_name() == "nh_nodes:backchest"
        if last_backpack_state[player_name] == nil then last_backpack_state[player_name] = false end
        if last_backpack_state[player_name] ~= has_backpack then
            last_backpack_state[player_name] = has_backpack
            update_player_formspec(player)
        end
        if player_states[player_name] then
            if punch_timers[player_name] then goto continue end -- não sobrescreve animação durante punch
            rotate_head_to_look(player)
            local ctrl = player:get_player_control()
            local vel = player:get_velocity()
            if ctrl.jump and vel.y >= 0 then
                set_player_animation(player, "jump")
            else
                local props = player:get_properties()
                local is_crawling = props.eye_height <= 0.7
                if is_crawling then
                    player:set_eye_offset(
                        { x = 0, y = -0.5, z = 7.5 }, -- ajusta para crawling
                        { x = 0, y = 7, z = -7 }
                    )
                    local horizontal = { x = vel.x, y = 0, z = vel.z }
                    local speed = vector.length(horizontal)
                    if speed > 0.1 then setplayeranimation("crawling_walk") else setplayeranimation("crawling") end
                elseif ctrl.sneak and vel.x < 0.1 and vel.z < 0.1 then
                    set_player_animation(player, "sneak")
                    -- player:set_properties({ collisionbox = {-0.6, 0.0, -0.6, 0.6, 2.7, 0.6} })
                    player:set_eye_offset(
                        { x = 0, y = 8, z = 10 }, -- ajusta para sneak
                        { x = 0, y = 7, z = -7 }
                    )
                else
                    player:set_properties({ collisionbox = { -0.45, 0.0, -0.45, 0.45, 2.7, 0.45 }, })
                    player:set_eye_offset({ x = 0, y = -1, z = 3 }, { x = 0, y = 7, z = -7 })
                    local is_moving_back = ctrl.down
                    local is_moving = ctrl.up or ctrl.left or ctrl.right
                    local horizontal = { x = vel.x, y = 0, z = vel.z }
                    local speed = vector.length(horizontal)
                    if is_moving_back then
                        if ctrl.sneak and speed >= 0.1 then
                            setplayeranimation("sneak_walk_back")
                            player:set_eye_offset(
                                { x = 0, y = 8, z = 10 }, -- ajusta para sneak
                                { x = 0, y = 7, z = -7 }
                            )
                        elseif ctrl.aux1 or speed >= 4 then
                            setplayeranimation("run_back")
                        elseif speed < 4 and speed > 0 then
                            setplayeranimation("walk_back")
                        end
                    elseif is_moving then
                        if ctrl.sneak and speed >= 0.1 then
                            setplayeranimation("sneak_walk")
                            player:set_eye_offset(
                                { x = 0, y = 8, z = 10 }, -- ajusta para sneak
                                { x = 0, y = 7, z = -7 }
                            )
                        elseif ctrl.aux1 or speed >= 4 then
                            setplayeranimation("run")
                        elseif speed < 4 and speed > 0 then
                            setplayeranimation("walk")
                        end
                    else
                        player:set_eye_offset({ x = 0, y = -1, z = 3 }, { x = 0, y = 7, z = -7 })
                        if has_item then setplayeranimation("holding") else setplayeranimation("idle") end
                    end
                end
            end
            ::continue::
        end
    end
end) -- EVENTOS DE JOGADOR
core.register_on_joinplayer(function(player)
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
        if props.eye_height ~= 2.5 and check_count < max_checks then core.after(0.2, verify_and_apply) end
    end
    core.after(0.3, function()
        if player and player:is_player() then
            verify_and_apply()
            create_player_body(player) -- CRIA CORPO VISÍVEL
            update_wielded_item(player)
            update_offhand_item(player)
            update_armor_visuals(player)
            update_belt_items(player)
        end
    end)
end)
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    player_states[player_name] = nil
    last_wielded[player_name] = nil
    last_wield_index[player_name] = nil
    last_belt_items[player_name] = nil
    last_armor_items[player_name] = nil
    last_backpack_state[player_name] = nil
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
    -- if shadow_objects[player_name] then
    --     shadow_objects[player_name]:remove()
    --     shadow_objects[player_name] = nil
    -- end
end)
core.register_on_dieplayer(function(player)
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
    -- if shadow_objects[player_name] then
    --     shadow_objects[player_name]:remove()
    --     shadow_objects[player_name] = nil
    -- end
end)
core.register_on_respawnplayer(function(player)
    core.after(0.5, function()
        if player and player:is_player() then
            apply_custom_model(player)
            create_player_body(player)
        end
    end)
end)
