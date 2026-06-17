-- NODES
local c = core
c.log("action", "[NODES] init.lua loaded")
local S = c.get_translator("nh_nodes")
 -- table_xyz and table x=y=z
local function xyz(x, y, z) if y == nil and z == nil then y, z = x, x end return {x = x, y = y, z = z} end
local function populate_true(names)
    local father = {}
    for _, name in ipairs(names) do father["nh_nodes:" .. name] = true end
    return father
end
local footstep_timer     = {}
local lava_damage_timer  = {}
local players_with_torch = {}
local portal_cooldown = {} -- evita teleporte no portal em loop
-- FLUTUAÇÃO E CORRENTEZA NAS ÁGUAS
local WATER_FULLNODES = populate_true({"water", "water2", "avalanche"})
local WATER_MIDNODES = populate_true({"water_flowing", "water2_flowing"})
local water_nodes = populate_true({"water", "water_flowing", "water2", "water2_flowing"})
local LAVA_NODES = populate_true({"lava", "lava_flowing", "bluelava", "bluelava_flowing"})
local BUCKET_FLOWING = populate_true({"water_flowing", "water2_flowing", "avalanche_flowing"})
local FLAME_ENTITIES = populate_true({"campfire_flame_entity", "torch_flame_entity", "palmstraw_flame_entity", "flame_entity"})
local LEAF_TYPES = populate_true({"leaves", "leaves_nut", "leaves_nut2", "leaves_nut3", "leaves_apple", "leaves_apple2", "leaves_apple3"})
local FLOATING_STUFF = populate_true({"oaktimber", "oaklog", "oakwood", "stick", "palmtimber", "palmlog", "coconut", "pinetimber", "pinelog", "pinewood", "pineraft", "ice", "ice2", "orb_empty"})
local DECORATIONS = populate_true({"smallgrass", "highgrass", "rush", "dandelion", "grassleaves", "grassleavesmedium", "micaceusfungus", "flyamanitafungus", "pebble", "white_pebble", "fallenstick"})
nodes = {}
-- Vetores de direção por facedir (face frontal do node) para portal e espelho
local facedir_to_dir = {
    [0] = xyz(0, 0, -1),  -- sul
    [1] = xyz(-1, 0, 0),  -- leste
    [2] = xyz(0, 0, 1),   -- norte
    [3] = xyz(1, 0, 0)}  -- oeste
local function detach_glow(player)
    -- busca e remove o entity de glow anterior
    for _, obj in ipairs(c.get_objects_inside_radius(player:get_pos(), 2)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "nh_nodes:glow_entity" then obj:remove() end
    end
end
-- ao trocar para litgrenade (no on_use do grenade):
local function attach_glow(player)
    -- remove glow anterior se existir
    detach_glow(player)
    local glow_obj = c.add_entity(player:get_pos(), "nh_nodes:glow_entity")
    if glow_obj then glow_obj:set_attach(player, "bone_RHand", xyz(1.25, 0, 0), xyz(0, 0, 0)) end
end
c.register_entity("nh_nodes:glow_entity", {
    initial_properties = {
        visual = "sprite", textures = { "spark_particle.png^[colorize:#FF8800:150" }, 
        visual_size = {x = 0.05, y = 0.05}, collisionbox = {0, 0, 0, 0, 0, 0}, 
        physical = false, static_save = false, glow = 14},
    on_step = function(self, dtime)
        local rot = self.object:get_rotation()
        self.object:set_rotation(xyz(rot.x, rot.y + 0.15, rot.z + 0.07))
    end,
})
c.register_globalstep(function(dtime)
    for _, player in ipairs(c.get_connected_players()) do
        local name = player:get_player_name()
        local pos  = player:get_pos()
        -- remove o glow se o player tirar a litgrenade da mão sem arremessar
        local item = player:get_wielded_item():get_name()
        if item ~= "nh_nodes:litgrenade" then detach_glow(player) end
        -- PASSOS
        footstep_timer[name] = (footstep_timer[name] or 0) + dtime
        if footstep_timer[name] >= 0.4 then
            footstep_timer[name] = 0
            local controls = player:get_player_control()
            if controls.up or controls.down or controls.left or controls.right then
                local props       = player:get_properties()
                local cb          = props and props.collisionbox
                local feet_offset = cb and cb[2] or -1
                local below       = xyz(math.floor(pos.x + 0.5), math.floor(pos.y + feet_offset), math.floor(pos.z + 0.5))
                local node        = c.get_node(below)
                local node_def    = c.registered_nodes[node.name]
                if node_def and node_def.sounds and node_def.sounds.footstep then
                    local snd = node_def.sounds.footstep
                    c.sound_play(snd.name, {pos = pos, gain = snd.gain or 0.5, max_hear_distance = 10})
                end
            end
        end
        -- DANO DA LAVA
        lava_damage_timer[name] = (lava_damage_timer[name] or 0) + dtime
        if lava_damage_timer[name] >= 1.0 then
            lava_damage_timer[name] = 0
            local feet_node = c.get_node(xyz(pos.x, pos.y, pos.z))
            local head_node = c.get_node(xyz(pos.x, pos.y + 1, pos.z))
            if LAVA_NODES[feet_node.name] or LAVA_NODES[head_node.name] then player:set_hp(player:get_hp() - 22) end
        end
        -- DANO DAS FOLHAS CAINDO
        local above_pos = xyz(pos.x, pos.y + 2, pos.z)
        for _, obj in pairs(c.get_objects_inside_radius(above_pos, 1.5)) do
            local entity = obj:get_luaentity()
            if entity and entity.name == "__builtin:falling_node" then
                local node = entity.node
                if node and LEAF_TYPES[node.name] then
                    local velocity = obj:get_velocity()
                    if velocity and velocity.y < -2 then player:set_hp(player:get_hp() - 1) end
                end
            end
        end
        -- TOCHA NA AGUA (troca torch2 por torch3)
        local head_pos  = xyz(pos.x, pos.y + 1, pos.z)
        local head_node = c.get_node(head_pos)
        if c.get_item_group(head_node.name, "water") > 0 then
            local inv = player:get_inventory()
            for i = 1, inv:get_size("main") do
                local stack = inv:get_stack("main", i)
                if stack:get_name() == "nh_nodes:torch2" then
                    stack:set_name("nh_nodes:torch3")
                    inv:set_stack("main", i, stack)
                end
            end
        end
        -- LUZ DA TOCHA / CRISTAL
        local wielded        = player:get_wielded_item()
        local light_pos_base = xyz(pos.x, pos.y + 1, pos.z)
        if wielded:get_name() == "nh_nodes:torch2" or wielded:get_name() == "nh_nodes:redcrystal" or wielded:get_name() == "nh_nodes:litgrenade" then
            if not players_with_torch[name] then players_with_torch[name] = {} end
            -- Remove luz antiga
            if players_with_torch[name].pos then
                local old_pos  = players_with_torch[name].pos
                local old_node = c.get_node(old_pos)
                if old_node.name == "nh_nodes:torch_light" or old_node.name == "nh_nodes:crystal_light" then
                    c.remove_node(old_pos)
                end
            end
            -- Coloca nova luz invisivel
            local light_pos  = vector.round(light_pos_base)
            local light_node = c.get_node(light_pos)
            if light_node.name == "air" then
                c.set_node(light_pos, { name = "nh_nodes:torch_light" })
                players_with_torch[name].pos = light_pos
            elseif light_node.name == "nh_nodes:water" then
                c.set_node(light_pos, { name = "nh_nodes:crystal_light" })
                players_with_torch[name].pos = light_pos
            end
        else
            -- Remove luz se parou de segurar
            if players_with_torch[name] and players_with_torch[name].pos then
                local old_pos  = players_with_torch[name].pos
                local old_node = c.get_node(old_pos)
                if old_node.name == "nh_nodes:torch_light" or old_node.name == "nh_nodes:crystal_light" then c.remove_node(old_pos)
                end
                players_with_torch[name] = nil
            end
        end
    end
end)
-- DESTRUIÇÃO DE DROPS NA LAVA
-- Destrói qualquer item (drop) cuja face inferior toca um node de lava,
-- emitindo partículas de fogo da base ao topo do node antes de removê-lo.
local function spawn_lava_burn_particles(pos)
    -- 'pos' é a posição do node de lava (canto inferior-esquerdo = pos - 0.5)
    -- As partículas sobem da base (pos.y - 0.5) até o topo (pos.y + 0.5) do node.
    local base_y = pos.y - 0.5
    c.add_particlespawner({
        amount             = 24,  -- quantidade de partículas por emissão
        time               = 0.4, -- duração total do spawner (segundos)
        -- Origem: espalhada na face superior do node de lava
        minpos             = xyz(pos.x - 0.4, base_y, pos.z - 0.4),
        maxpos             = xyz(pos.x + 0.4, base_y + 0.1, pos.z + 0.4),
        -- Velocidade: sobem do fundo ao topo do node (1 node = 1 unidade)
        minvel             = xyz(-0.15, 1.5, -0.15),
        maxvel             = xyz(0.15, 3.0, 0.15),
        -- Sem aceleração (fogo sobe naturalmente)
        minacc             = xyz(0, 0, 0),
        maxacc             = xyz(0, 0, 0),
        -- Vida das partículas: tempo suficiente para cruzar 1 node
        minexptime         = 0.2,
        maxexptime         = 0.5,
        -- Tamanho das fagulhas
        minsize            = 0.6,
        maxsize            = 1.4,
        texture            = "mobs_fire_particle.png",
        animation          = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.4},
        glow               = 14,
        collisiondetection = false,
    })
end
local lava_drop_timer = 0
c.register_globalstep(function(dtime)
    lava_drop_timer = lava_drop_timer + dtime
    if lava_drop_timer < 0.5 then return end
    lava_drop_timer = 0
    for _, obj in ipairs(c.get_objects_in_area(xyz(-30000, -30000, -30000), xyz(30000, 30000, 30000))) do
        if not obj:is_player() then
            local entity = obj:get_luaentity()
            if entity and entity.name == "__builtin:item" then
                local pos = obj:get_pos()
                if pos then
                    -- Node abaixo do drop (parte inferior do item)
                    local below = { x = math.floor(pos.x + 0.5), y = math.floor(pos.y), z = math.floor(pos.z + 0.5), }
                    local node_below = c.get_node(below)
                    if LAVA_NODES[node_below.name] then
                        -- Emite partículas antes de remover
                        spawn_lava_burn_particles(xyz(below.x, below.y + 0.5, below.z))
                        obj:remove()
                    end
                end
            end
        end
    end
end)
local gravity = tonumber(c.settings:get("movement_gravity")) or 9.81
-- Calcula a direção da corrente da água.
local function get_liquid_flow_dir(pos)
    local node_here = c.get_node(pos)
    local p2_here = node_here.param2
    -- Só opera em flowing (source não tem corrente direcional)
    if not WATER_MIDNODES[node_here.name] then return nil end
    -- Bit 3 (0x08) do param2 = "liquid_fall": a água despenca verticalmente.
    -- Nesse caso a direção é para baixo, sem componente horizontal.
    local falling = (p2_here >= 8)
    local p2_level = p2_here % 8
    local flow = xyz(0)
    if falling then flow.y = -1 end
    local dirs = {xyz(1, 0, 0), xyz(-1, 0, 0), xyz(0, 0, 1), xyz(0, 0, -1)}
    for _, d in ipairs(dirs) do
        local nb_pos = xyz(pos.x + d.x, pos.y, pos.z + d.z)
        local nb     = c.get_node(nb_pos)
        local nb_def = c.registered_nodes[nb.name]
        if not nb_def then goto next_dir end
        local is_flowing = WATER_MIDNODES[nb.name]
        -- Vizinho é source → nível máximo (param2 = 0 equivalente)
        -- Vizinho é flowing com param2 MENOR (= mais cheio) que o nosso
        -- Em ambos os casos a água VEM desse vizinho → flui para o OPOSTO
        local nb_level = nb.param2 % 8
        if (is_flowing and nb_level < p2_level) then
            -- Direção OPOSTA ao vizinho mais cheio
            flow.x = flow.x + d.x
            flow.z = flow.z + d.z
        end
        ::next_dir::
    end
    local hlen = math.sqrt(flow.x ^ 2 + flow.z ^ 2)
    if hlen > 0 then
        flow.x = flow.x / hlen
        flow.z = flow.z / hlen
    end
    if flow.x == 0 and flow.y == 0 and flow.z == 0 then return nil end
    return flow
end
local SPEED_CURRENT     = 2   -- velocidade horizontal da correnteza (m/s)
local SPEED_SINK        = 0.5 -- afundamento de drops normais (m/s)
local SPEED_FLOAT       = 0.3 -- subida de itens flutuantes (m/s)
local SPEED_FALL        = 2.0 -- queda em correnteza vertical (m/s)
-- Rastreia se o drop estava na água no tick anterior (para restaurar aceleração
-- de gravidade uma única vez ao sair, sem chamar set_acceleration toda tick)
local drop_was_in_water = {}
local drop_last_flow    = {} -- última direção de corrente detectada por drop
c.register_globalstep(function(dtime)
    for _, obj in ipairs(c.get_objects_in_area({ x = -30000, y = -30000, z = -30000 }, { x = 30000, y = 30000, z = 30000 })) do
        if obj:is_player() then goto drop_next end
        local entity = obj:get_luaentity()
        if not (entity and entity.name == "__builtin:item") then goto drop_next end
        local pos = obj:get_pos()
        if not pos then goto drop_next end
        local ipos     = xyz(math.floor(pos.x + 0.5), math.floor(pos.y + 0.5), math.floor(pos.z + 0.5))
        local node     = c.get_node(ipos)
        local in_full  = WATER_FULLNODES[node.name]
        local in_mid   = WATER_MIDNODES[node.name]
        local in_water = in_full or in_mid
        local uid      = tostring(obj)
        if not in_water then
            -- Saiu da água: restaura gravidade (uma vez só)
            if drop_was_in_water[uid] then
                drop_was_in_water[uid] = nil
                drop_last_flow[uid] = nil
                obj:set_acceleration(xyz(0, -gravity, 0))
            end
            goto drop_next
        end
        -- ── Dentro da água
        -- Zera aceleração para que set_velocity abaixo seja o movimento final
        if not drop_was_in_water[uid] then drop_was_in_water[uid] = true end
        obj:set_acceleration(xyz(0))
        local item_name = entity.itemstring or (entity.item and ItemStack(entity.item):get_name()) or ""
        local is_floating = FLOATING_STUFF[item_name]

        if in_full and not in_mid then
            -- Água source (parada)
            obj:set_velocity(xyz(0, is_floating and SPEED_FLOAT or -SPEED_SINK, 0))
        else
            -- Água flowing (corrente)
            local flow = get_liquid_flow_dir(ipos)
            if flow then drop_last_flow[uid] = flow -- Guarda direção para usar no último node (onde flow vira nil)
            else flow = drop_last_flow[uid] -- Último node da corrente: vizinho à frente é ar, flow==nil. -- Usa a última direção conhecida para continuar o movimento.
            end
            if flow then obj:set_velocity(xyz(
                flow.x * SPEED_CURRENT,
                (flow.y < 0) and -SPEED_FALL or (is_floating and SPEED_FLOAT or -SPEED_SINK),
                flow.z * SPEED_CURRENT))
            else obj:set_velocity(xyz(0, is_floating and SPEED_FLOAT or -SPEED_SINK, 0))
            end
        end
        ::drop_next::
    end
end)
local drop_rot_timer = 0
c.after(0, function()
    local item_ent = c.registered_entities["__builtin:item"]
    if not item_ent then return end
    -- Patch no set_item: é aqui que o automatic_rotate é definido pelo builtin
    local original_set_item = item_ent.set_item
    item_ent.set_item = function(self, item)
        original_set_item(self, item)
        -- Sobrescreve DEPOIS que o builtin definiu as propriedades
        self.object:set_properties({ automatic_rotate = 0 })
        self.object:set_rotation(xyz(0))
    end
    local original_on_step = item_ent.on_step
    item_ent.on_step = function(self, dtime, moveresult)
        if original_on_step then original_on_step(self, dtime, moveresult) end
        local tremor = (math.floor(drop_rot_timer * 16) % 2 == 0)
            and math.rad(1) or math.rad(-1)
        self.object:set_rotation({ x = math.rad(45) + tremor, y = tremor, z = math.rad(45) + tremor, })
    end
end)
c.register_globalstep(function(dtime) drop_rot_timer = drop_rot_timer + dtime end)
-- Limpeza unificada ao deslogar
c.register_on_leaveplayer(function(player)
    local name              = player:get_player_name()
    footstep_timer[name]    = nil
    lava_damage_timer[name] = nil
    if players_with_torch[name] and players_with_torch[name].pos then
        local old_pos  = players_with_torch[name].pos
        local old_node = c.get_node(old_pos)
        if old_node.name == "nh_nodes:torch_light" or old_node.name == "nh_nodes:crystal_light" then
            c.remove_node(old_pos)
        end
        players_with_torch[name] = nil
    end
end)
-- RECEITAS BASICAS (2x2) - Nodes do chão
recipes_floor = {
    {ingredients = {["nh_nodes:pebble"] = 1},
        output = "nh_nodes:chippedstone",
        required_tool = "nh_nodes:pebble" -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:pebble_item"] = 1},
        output = "nh_nodes:chippedstone",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:chippedstone"] = 1},
        output = "nh_nodes:stoneaxehead",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:stoneaxehead"] = 1},
        output = "nh_nodes:stonepickaxehead",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:stonepickaxehead"] = 1},
        output = "nh_nodes:stonehoehead",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:stonehoehead"] = 1},
        output = "nh_nodes:stoneadzehead",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:oakdowel"] = 1, ["nh_nodes:oakboard"] = 1},
        output = "nh_nodes:rowing"
    },
    {ingredients = {["nh_nodes:stoneaxehead"] = 1, ["nh_nodes:limb"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stoneaxe"
    },
    {ingredients = {["nh_nodes:stonepickaxehead"] = 1, ["nh_nodes:limb"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stonepickaxe"
    },
    {ingredients = {["nh_nodes:stonehoehead"] = 1, ["nh_nodes:limb"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stonehoe"
    },
    {ingredients = {["nh_nodes:stoneadzehead"] = 1, ["nh_nodes:limb"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stoneadze"
    },
    {ingredients = {["nh_nodes:obsidianpebble"] = 1},
        output = "nh_nodes:obsidianblade",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:obsidianpebble_item"] = 1},
        output = "nh_nodes:obsidianblade",
        required_tool = "nh_nodes:pebble_item", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:chippedstone"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:chippedstoneknife"
    },
    {ingredients = {["nh_nodes:obsidianblade"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:obsidianknife"
    },
    {ingredients = {["nh_nodes:pebble"] = 8},
        output = "nh_nodes:cobblestone"
    },
    {ingredients = {["nh_nodes:pebble_item"] = 8},
        output = "nh_nodes:cobblestone"
    },
    {ingredients = {["nh_nodes:cobblestone"] = 8},
        output = "nh_nodes:furnace"
    },
    {ingredients = {["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:campfiretinder"
    },
    {ingredients = {["nh_nodes:oaklog"] = 1},
        output = "nh_nodes:oakwood",
        required_tool = "nh_nodes:stoneadze", -- ← só faz com isso no slot
        tool_result = "nh_nodes:stoneadze",  -- ← devolve isso no slot tool
    },
    {ingredients = {["nh_nodes:oaklog"] = 1},
        output = "nh_nodes:oaktimberslice 16",
    },
    {ingredients = {["nh_nodes:pinelog"] = 1},
        output = "nh_nodes:pinewood",
        required_tool = "nh_nodes:stoneadze", -- ← só faz com isso no slot
        tool_result = "nh_nodes:stoneadze",  -- ← devolve isso no slot tool
    },
    {ingredients = {["nh_nodes:pinelog"] = 1},
        output = "nh_nodes:pinetimberslice 16",
    },
    {ingredients = {["nh_nodes:palmlog"] = 1},
        output = "nh_nodes:palmtimberslice 4",
    },
    {ingredients = {["nh_nodes:palmleaf"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:oakresin"] = 1, ["nh_nodes:grassleaves"] = 1},
        output = "nh_nodes:torch"
    },
    {ingredients = {["nh_nodes:oakwood"] = 1},
        output = "nh_nodes:oakboard 8"
    },
    {ingredients = {["nh_nodes:oakwood"] = 2},
        output = "nh_nodes:oakplank 4"
    },
    {ingredients = {["nh_nodes:oakboard"] = 1},
        output = "nh_nodes:oakdowel 8"
    },
    {ingredients = {["nh_nodes:oakdowel"] = 2, ["nh_nodes:oakboard"] = 2},
        output = "nh_nodes:craft_table"
    },
    {ingredients = {["nh_nodes:inksac"] = 1, ["nh_nodes:bottle"] = 1},
        output = "nh_nodes:inkbottle"
    },
    {ingredients = {["nh_items:writedpage"] = 1, ["nh_nodes:bottle"] = 1},
        output = "nh_nodes:messagebottle"
    },
}
-- RECEITAS DA BANCADA DE PRODUÇÃO (2x2x2) - craft_table
-- Inclui tudo do floor + itens avançados (espada, baú, porta, piões...)
recipes_table = {
    {ingredients = {["nh_nodes:oakboard"] = 5},
        output = "nh_nodes:bucket"
    },
    {ingredients = {["nh_nodes:oakboard"] = 6},
        output = "nh_nodes:oakchest"
    },
    {ingredients = {["nh_nodes:cowhide"] = 2, ["nh_nodes:oakdowel"] = 1},
        output = "nh_nodes:belt"
    },
    {ingredients = {["nh_nodes:cowhide"] = 2, ["nh_nodes:oakchest"] = 1},
        output = "nh_nodes:backchest"
    },
    {ingredients = {["nh_nodes:cowhide"] = 1},
        output = "nh_nodes:bookcover"
    },
    {ingredients = {["nh_nodes:rush"] = 6},
        output = "nh_items:page",
        required_tool = "nh_nodes:bucketwater", -- ← só faz com isso no slot
        tool_result = "nh_nodes:bucket",  -- ← devolve isso no slot tool
    },
    {ingredients = {["nh_nodes:rush"] = 6},
        output = "nh_items:page",
        required_tool = "nh_nodes:bucketwater2", -- ← só faz com isso no slot
        tool_result = "nh_nodes:bucket",  -- ← devolve isso no slot tool
    },
    {ingredients = {["nh_nodes:page"] = 8},
        output = "nh_nodes:book",
        required_tool = "nh_nodes:bookcover", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_items:page"] = 8},
        output = "nh_nodes:book",
        required_tool = "nh_nodes:bookcover", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:book"] = 1, ["nh_nodes:redcrystal"] = 1},
        output = "nh_nodes:archion",
        required_tool = "nh_nodes:sphere" -- ← só faz com isso no slot
    },
    {ingredients = { ["nh_nodes:shrimpclaw"] = 1},
        output = "nh_nodes:shrimpclaw2",
        required_tool = "nh_nodes:sphere" -- ← só faz com isso no slot
    },
    {ingredients = { ["nh_nodes:wings"] = 1},
        output = "nh_nodes:gravitywings",
        required_tool = "nh_nodes:sphere" -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:cowhide"] = 2},
        output = "nh_nodes:gloves"
    },
    {ingredients = {["nh_nodes:cowhide"] = 1, ["nh_nodes:gloves"] = 1},
        output = "nh_nodes:likeglove"
    },
    {ingredients = {["nh_nodes:cowhide"] = 2, ["nh_nodes:gloves"] = 1},
        output = "nh_nodes:pointglove"
    },
    {ingredients = {["nh_nodes:cowhide"] = 3},
        output = "nh_nodes:helm"
    },
    {ingredients = {["nh_nodes:cowhide"] = 4},
        output = "nh_nodes:boots"
    },
    {ingredients = {["nh_nodes:cowhide"] = 5},
        output = "nh_nodes:leggings"
    },
    {ingredients = {["nh_nodes:cowhide"] = 7},
        output = "nh_nodes:chestplate"
    },
    {ingredients = {["nh_nodes:oakboard"] = 3, ["nh_nodes:oakdowel"] = 2, ["nh_nodes:pebble"] = 2},
        output = "nh_nodes:oakdoor"
    },
    {ingredients = { ["nh_nodes:oaklog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble_item"] = 1},
        output = "nh_nodes:spinningtop"
    },
    {ingredients = { ["nh_nodes:palmlog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble_item"] = 1},
        output = "nh_nodes:spinningtop2"
    },
    {ingredients = { ["nh_nodes:pinelog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble_item"] = 1},
        output = "nh_nodes:spinningtop3"
    },
    {ingredients = { ["nh_nodes:oaklog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble"] = 1},
        output = "nh_nodes:spinningtop"
    },
    {ingredients = { ["nh_nodes:palmlog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble"] = 1},
        output = "nh_nodes:spinningtop2"
    },
    {ingredients = { ["nh_nodes:pinelog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble"] = 1},
        output = "nh_nodes:spinningtop3"
    },
    {ingredients = { ["nh_nodes:obsidianblade"] = 8},
        output = "nh_nodes:obsidiansword",
        required_tool = "nh_nodes:rowing" -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:oakdowel"] = 4, ["nh_nodes:oakboard"] = 2},
        output = "nh_nodes:advanced_bench"
    },
}
-- Injeta as receitas do floor no início das recitas da mesa
for i, r in ipairs(recipes_floor) do table.insert(recipes_table, i, r) end
-- RECEITAS DA advanced bench
recipes_table2 = {
    {ingredients = {["nh_nodes:cowhide"] = 6, ["nh_nodes:palmstraw"] = 3},
        output = "nh_nodes:sleepingbag"
    },
}
for _, r in ipairs(recipes_table) do table.insert(recipes_table2, r) end
-- RECEITAS DA FOGUEIRA (2x2)
-- Inclui: alimentos assados
recipes_campfire = {
    {ingredients = {["nh_nodes:chickenegg"] = 1},
        output = "nh_nodes:friedchickenegg"
    },
    {ingredients = {["nh_nodes:rawchicken"] = 1},
        output = "nh_nodes:roastchicken"
    },
    {ingredients = {["nh_nodes:rawtuna"] = 1},
        output = "nh_nodes:roasttuna"
    },
    {ingredients = {["nh_nodes:rawbeef"] = 1},
        output = "nh_nodes:roastbeef"
    },
}
-- RECEITAS DA FORNALHA (3x3)
-- Inclui: carvão, alimentos cozidos, fundição de metais, vidro
recipes_furnace = {
    {ingredients = {["nh_nodes:oaklog"] = 9},
        output = "nh_nodes:charcoal 9",
    },
    {ingredients = {["nh_nodes:pinelog"] = 9},
        output = "nh_nodes:charcoal 9",
    },
    {ingredients = {["nh_nodes:palmlog"] = 9},
        output = "nh_nodes:charcoal2 9",
    },
    {ingredients = {["nh_nodes:chickenegg"] = 9},
        output = "nh_nodes:friedchickenegg 9",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:rawchicken"] = 9},
        output = "nh_nodes:roastchicken 9",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:rawtuna"] = 9},
        output = "nh_nodes:roasttuna 9",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:rawbeef"] = 9},
        output = "nh_nodes:roastbeef 9",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:coppernugget"] = 3 },
        output = "nh_nodes:copperingot",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:copperingot"] = 2},
        output = "nh_nodes:coppergauntlets",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:copperingot"] = 3},
        output = "nh_nodes:copperhelmet",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:copperingot"] = 4},
        output = "nh_nodes:copperboots",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:copperingot"] = 5},
        output = "nh_nodes:nh_nodes:copperleggings",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:copperingot"] = 6},
        output = "nh_nodes:coppervambraces",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:copperingot"] = 7},
        output = "nh_nodes:copperchestplate",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:tinnugget"] = 3},
        output = "nh_nodes:tiningot",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:ironnugget"] = 3},
        output = "nh_nodes:ironingot",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:ironingot"] = 3, ["nh_nodes:coalnugget"] = 1, ["nh_nodes:page"] = 1},
        output = "nh_nodes:grenade",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:ironingot"] = 3, ["nh_nodes:coalnugget"] = 1, ["nh_items:page"] = 1},
        output = "nh_nodes:grenade",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:sand"] = 8},
        output = "nh_nodes:glass 8",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:glass"] = 3, ["nh_nodes:oakwood"] = 1},
        output = "nh_nodes:bottle 6",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    {ingredients = {["nh_nodes:glass"] = 4, ["nh_nodes:chromiumingot"] = 1},
        output = "nh_nodes:mirror 4",
        required_tool = "nh_nodes:coalnugget", -- ← só faz com isso no slot
    },
    --{
    --    ingredients = {["nh_nodes:ironingot"] = 3},
    --    output = "nh_nodes:stellingot 3"
    --    required_tool = "nh_nodes:coal",   -- ← só faz com isso no slot
    --},
}

-- SISTEMA GENÉRICO DE CRAFTING
local craft_stations = {}
-- Registra a entidade de display (compartilhada por todas as estações)
c.register_entity("nh_nodes:display_item", {
    initial_properties = {
        visual = "wielditem", visual_size = {x = 0.25, y = 0.25},
        physical = false, collide_with_objects = false,
        pointable = false, static_save = true,
        is_visible = true,
    },
    itemstring = "",
    station_pos = nil,
    item_visual_size = nil,  -- ← campo novo
    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data then
                self.itemstring = data.itemstring or ""
                self.station_pos = data.station_pos
                self.item_visual_size = data.item_visual_size  -- ← restaura tamanho
                local props = { wield_item = self.itemstring }
                if self.item_visual_size then props.visual_size = self.item_visual_size  -- ← aplica tamanho ao recarregar
                end
                self.object:set_properties(props)
            end
        end
    end,
    get_staticdata = function(self)
        return c.serialize({
            itemstring = self.itemstring,
            station_pos = self.station_pos,
            item_visual_size = self.item_visual_size,  -- ← salva tamanho
        })
    end,
    on_step = function(self, dtime)
        self.object:set_velocity(xyz(0))
        self.object:set_acceleration(xyz(0))
        local props = self.object:get_properties()
        if props.glow and props.glow > 0 then
            local rot = self.object:get_rotation()
            self.object:set_rotation(xyz(0, rot.y + 0.005, 0))
        end
    end,
})
-- FUNÇÕES AUXILIARES
-- Remove apenas entidades desta estação específica
local function remove_item_entities(pos)
    local objects = c.get_objects_inside_radius(pos, 2)
    for _, obj in pairs(objects) do
        local entity = obj:get_luaentity()
        if entity and entity.name == "nh_nodes:display_item" then
            -- Verifica se a entidade pertence a ESTA estação
            if entity.station_pos and vector.equals(entity.station_pos, pos) then obj:remove() end
        end
    end
end
local function update_item_entities(pos, config)
    local meta = c.get_meta(pos)
    local inv = meta:get_inventory()
    if not inv or inv:get_size("craft") == 0 then return end
    remove_item_entities(pos)
    local craft_list = inv:get_list("craft")
    local output_list = inv:get_list("output")
    if not craft_list or not output_list then return end
    -- Entidades dos slots de craft (sem mudança)
    for i = 1, config.grid_size do
        local stack = craft_list[i]
        if not stack:is_empty() then
            local item_pos = vector.add(pos, config.positions[i])
            local item_size = config.item_visual_size or {x = 0.25, y = 0.25}
            local obj = c.add_entity(item_pos, "nh_nodes:display_item")
            if obj then
                local entity = obj:get_luaentity()
                if entity then
                    entity.itemstring = stack:get_name()
                    entity.station_pos = pos
                    entity.item_visual_size = item_size  -- ← salva tamanho no campo da entidade
                    obj:set_properties({wield_item = stack:get_name(), visual_size = item_size})
                end
            end
        end
    end
    -- Entidade do slot de ferramenta (opcional)
    if config.show_tool_display and config.tool_position then
        local tool_stack = inv:get_stack("tool", 1)
        if tool_stack and not tool_stack:is_empty() then
            local tool_pos = vector.add(pos, config.tool_position)
            local obj = c.add_entity(tool_pos, "nh_nodes:display_item")
            if obj then
                local entity = obj:get_luaentity()
                if entity then
                    entity.itemstring = tool_stack:get_name()
                    entity.station_pos = pos
                    obj:set_properties({
                        wield_item = tool_stack:get_name(),
                        visual_size = {x = 0.3, y = 0.3},
                    })
                end
            end
        end
    end
    -- Entidade do output (sem mudança)
    local output_stack = output_list[1]
    if output_stack and not output_stack:is_empty() then
        local output_pos = vector.add(pos, config.output_position)
        local obj = c.add_entity(output_pos, "nh_nodes:display_item")
        if obj then
            local entity = obj:get_luaentity()
            if entity then
                entity.itemstring = output_stack:get_name()
                entity.station_pos = pos
                obj:set_properties({
                    wield_item = output_stack:get_name(),
                    visual_size = { x = 0.35, y = 0.35 },
                    glow = 1
                })
            end
        end
    end
end
local function check_recipe(inv, recipe)
    local craft_list = inv:get_list("craft")
    local counts = {}
    -- Conta os itens no grid
    for i = 1, #craft_list do
        local stack = craft_list[i]
        if not stack:is_empty() then
            local name = stack:get_name()
            counts[name] = (counts[name] or 0) + 1
        end
    end
    -- Verifica se a receita corresponde
    for item, required_count in pairs(recipe.ingredients) do if (counts[item] or 0) < required_count then return false end end
    -- Verifica se não há itens extras (receita exata)
    local total_required = 0
    for _, count in pairs(recipe.ingredients) do total_required = total_required + count end
    local total_in_grid = 0
    for _, count in pairs(counts) do total_in_grid = total_in_grid + count end
    return total_in_grid == total_required
end

local function check_and_craft(pos, config, player)
    local meta = c.get_meta(pos)
    local inv = meta:get_inventory()
    if config.can_craft then
        local ok, reason = config.can_craft(pos)
        if not ok then
            inv:set_stack("output", 1, ItemStack(""))
            c.after(0.01, function() update_item_entities(pos, config) end)
            if player and reason then c.chat_send_player(player:get_player_name(), reason) end
            return
        end
    end
    local tool_stack = inv:get_stack("tool", 1)
    local tool_name = tool_stack:get_name() -- "" se vazio
    for _, recipe in ipairs(config.recipes) do
        -- Se a receita exige ferramenta, verifica
        if recipe.required_tool then if tool_name ~= recipe.required_tool then goto continue end end -- pula esta receita
        if check_recipe(inv, recipe) then
            inv:set_stack("output", 1, ItemStack(recipe.output))
            c.after(0.01, function() update_item_entities(pos, config) end)
            return
        end
        ::continue::
    end
    inv:set_stack("output", 1, ItemStack(""))
    c.after(0.01, function() update_item_entities(pos, config) end)
end

local function consume_craft_materials(pos)
    local meta = c.get_meta(pos)
    local inv = meta:get_inventory()
    for i = 1, inv:get_size("craft") do
        local stack = inv:get_stack("craft", i)
        if not stack:is_empty() then
            stack:take_item(1)
            inv:set_stack("craft", i, stack)
        end
    end
end

-- Verifica se o jogador tem o backchest equipado no slot de costas
local function player_has_backchest_equipped(player)
    local inv = player:get_inventory()
    local back_list = inv:get_list("armor_back")
    if not back_list then return false end
    for _, stack in ipairs(back_list) do
        if stack:get_name() == "nh_nodes:backchest" then return true end
    end
    return false
end

local function show_craft_grid(player, pos, config)
    local player_name = player:get_player_name()
    local pos_string = c.pos_to_string(pos)
    local has_backchest = player_has_backchest_equipped(player) -- Verifica se o backchest está equipado para mostrar slots extras
    local form_height   = has_backchest and 9.7 or 7.5
    local formspec = "formspec_version[4]" .. "size[10.7," .. form_height .. "]" .. "label[0.5,0.5;" .. config.title .. "]"
    local y_offset = 1
    for _, layer in ipairs(config.layers) do
        formspec = formspec .. "label[" .. layer.x .. "," .. y_offset .. ";" .. layer.name .. "]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";craft;" .. layer.x ..
            "," .. (y_offset + 0.5) .. ";" .. layer.width .. "," .. layer.height .. ";" .. layer.start_index .. "]"
    end
    -- Posição do slot de ferramenta: usa a config se definida, senão calcula automaticamente
    local tool_x, tool_y
    if config.tool_slot_pos then
        tool_x = config.tool_slot_pos.x
        tool_y = config.tool_slot_pos.y
    else
        local grid_top = y_offset + 0.5
        local max_height = 0
        for _, layer in ipairs(config.layers) do if layer.height > max_height then max_height = layer.height end end
        tool_x = 3.3
        tool_y = grid_top + (max_height / 2) - 0.5
    end
    local player_slots
    if has_backchest then player_slots = -- Com backchest: mostra slots extras (8x2) + hotbar (8x1)
            "list[current_player;main;0.5,5.5;8,2;8]" ..
            "list[current_player;main;0.5,8.1;8,1;]"
    else player_slots = "list[current_player;main;0.5,6;8,1;]" -- Sem backchest: mostra apenas a hotbar (8x1)
    end
    formspec = formspec .. "label[" .. tool_x .. "," .. tool_y .. ";" .. S "Tool" .. "]" ..
        "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";tool;" .. tool_x .. "," .. (tool_y + 0.5) ..
        ";1,1;]" .. "label[7,1.5;" .. S "Produces" .. "]" .. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," ..
        pos.z .. ";output;7,2;1,1;]" .. "button[7,3.2;1,0.8;craft_one;" .. S "Single" .. "]" ..
        "button[7,4.1;1,0.8;craft_all;" .. S "All" .. "]" .. player_slots ..
        "listring[nodemeta:" .. pos.x .. "," .. pos.y ..
        "," .. pos.z .. ";craft]" .. "listring[current_player;main]"
    c.show_formspec(player_name, config.node_name .. "_" .. pos_string, formspec)
end
-- FUNÇÃO PRINCIPAL DE REGISTRO
function register_craft_station(node_name, config)
    -- Validação da configuração
    assert(config.description, "Config precisa de 'description'")
    assert(config.tiles, "Config precisa de 'tiles'")
    assert(config.grid_size, "Config precisa de 'grid_size'")
    assert(config.positions, "Config precisa de 'positions'")
    assert(config.output_position, "Config precisa de 'output_position'")
    assert(config.recipes, "Config precisa de 'recipes'")
    assert(config.layers, "Config precisa de 'layers'")
    assert(config.title, "Config precisa de 'title'")
    -- Armazena a configuração
    config.node_name = node_name
    craft_stations[node_name] = config
    -- Prepara as propriedades do node
    local node_def = {
        description = config.description,
        tiles = config.tiles,
        groups = config.groups or { choppy = 2, oddly_breakable_by_hand = 1 },
        paramtype2 = "facedir",
        sounds = config.sounds,
        -- Se tiver mesh, usa drawtype mesh, senão usa normal
        drawtype = config.mesh and "mesh" or "normal",
    }
    -- Adiciona mesh apenas se fornecido
    if config.mesh then node_def.mesh = config.mesh end
    -- Adiciona propriedades extras opcionais
    if config.drop then node_def.drop = config.drop end
    if config.sunlight_propagates ~= nil then node_def.sunlight_propagates = config.sunlight_propagates end
    if config.paramtype then node_def.paramtype = config.paramtype end
    if config.collision_box then node_def.collision_box = config.collision_box end
    if config.selection_box then node_def.selection_box = config.selection_box end
    -- Para blocos de craft segurados:
    if config.wielded_bone_position then node_def.wielded_bone_position = config.wielded_bone_position end
    if config.offhand_bone_position then node_def.offhand_bone_position = config.offhand_bone_position end
    if config.wielded_visual_size then node_def.wielded_visual_size = config.wielded_visual_size end
    -- Função auxiliar para garantir que o inventário existe
    local function ensure_inventory(pos)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        if inv:get_size("craft") == 0 then inv:set_size("craft", config.grid_size) end
        if inv:get_size("output") == 0 then inv:set_size("output", 1) end
        if inv:get_size("tool") == 0 then inv:set_size("tool", 1) end
    end
    -- PRESERVA CALLBACKS CUSTOMIZADOS
    -- Salva callbacks fornecidos no config
    local custom_on_construct = config.on_construct
    local custom_on_timer = config.on_timer
    local custom_on_punch = config.on_punch
    -- MODIFICA on_construct para executar AMBOS
    local original_on_construct = node_def.on_construct
    node_def.on_construct = function(pos)
        ensure_inventory(pos)
        --       EXECUTA O CALLBACK CUSTOMIZADO PRIMEIRO
        if custom_on_construct then custom_on_construct(pos) end
        -- Depois executa o padrão do crafting
        c.after(0.5, function()
            local node = c.get_node(pos)
            if node and node.name == node_name then update_item_entities(pos, config) end
        end)
    end
    -- MODIFICA on_timer para executar AMBOS
    node_def.on_timer = function(pos, elapsed)
        -- EXECUTA O CALLBACK CUSTOMIZADO PRIMEIRO
        if custom_on_timer then
            local result = custom_on_timer(pos, elapsed)
            if result == false then return false end -- Se retornou false, para aqui
        end
        return true -- Se não tem callback customizado ou retornou true, continua normal
    end
    -- Adiciona callbacks do crafting (alterado para não dar recursão [crash] com o mobsredo)
    node_def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local controls = clicker:get_player_control()
        if controls.aux1 then
            ensure_inventory(pos)
            show_craft_grid(clicker, pos, config)
            return itemstack
        end
        if itemstack and not itemstack:is_empty() then
            local item_def = c.registered_items[itemstack:get_name()]
            if item_def and item_def.type == "node" then
                local result = c.item_place_node(itemstack, clicker, pointed_thing)
                -- Toca o som de place manualmente
                if config.sounds and config.sounds.place then
                    c.sound_play(config.sounds.place.name, {pos = pointed_thing.above, gain = config.sounds.place.gain or 1, max_hear_distance = 16})
                end
                return result
            end
            -- Para spawn eggs e outros itens com on_place,
            -- chama on_place mas com under substituído por "air"
            -- para evitar recursão
            if item_def and item_def.on_place then
                local safe_pointed = {
                    type = pointed_thing.type,
                    under = pointed_thing.above, -- usa "above" como "under" falso
                    above = pointed_thing.above,
                }
                return item_def.on_place(itemstack, clicker, safe_pointed)
            end
        end
        -- Mão vazia e sem (E/Aux1): mostra dica
        if itemstack:is_empty() then c.chat_send_player(clicker:get_player_name(),
                S"I need to observe (hold 'E' or 'Aux1') and reach the ground (click 'place' with empty hands) to try to craft something...")
        end
        return itemstack
    end
    node_def.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "output" then return 0 end
        return stack:get_count()
    end
    node_def.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if to_list == "output" then return 0 end
        return count
    end
    node_def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "craft" or listname == "tool" then check_and_craft(pos, config, player) end
    end
    node_def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == "tool" then check_and_craft(pos, config)
        elseif listname == "craft" then check_and_craft(pos, config)
        elseif listname == "output" then
            local meta = c.get_meta(pos)
            local inv = meta:get_inventory()
            local player_inv = player:get_inventory()
            -- ► NOVO: verifica se a receita usada tem tool_result
            local function get_active_recipe()
                local tool_stack = inv:get_stack("tool", 1)
                local tool_name = tool_stack:get_name()
                for _, recipe in ipairs(config.recipes) do
                    if recipe.required_tool then
                        if tool_name ~= recipe.required_tool then goto continue end
                    end
                    if check_recipe(inv, recipe) then return recipe end
                    ::continue::
                end
                -- Receita recém-consumida: ingredientes ainda estão lá no 1º take,
                -- então tenta sem filtro de ferramenta para achar qual era
                return nil
            end
            local function consume_and_return_tool()
                -- Descobre a receita ANTES de consumir
                local tool_stack = inv:get_stack("tool", 1)
                local tool_name = tool_stack:get_name()
                local matched_recipe = nil
                for _, recipe in ipairs(config.recipes) do
                    if recipe.required_tool then
                        if tool_name ~= recipe.required_tool then goto skip end
                    end
                    if check_recipe(inv, recipe) then
                        matched_recipe = recipe
                        break
                    end
                    ::skip::
                end
                consume_craft_materials(pos)
                -- Se a receita tinha tool_result, substitui o slot tool
                if matched_recipe and matched_recipe.tool_result then
                    inv:set_stack("tool", 1, ItemStack(matched_recipe.tool_result))
                end
            end
            c.after(0.05, function()
                local max_crafts = 64
                local crafted = 1
                -- Primeiro craft (já tirado pelo jogador)
                consume_and_return_tool()  -- ← substitui consume_craft_materials(pos)
                while crafted < max_crafts do
                    local recipe_found = false
                    for _, recipe in ipairs(config.recipes) do
                        if check_recipe(inv, recipe) then
                            recipe_found = true
                            local result_stack = ItemStack(recipe.output)
                            local leftover = player_inv:add_item("main", result_stack)
                            if leftover:is_empty() then
                                consume_and_return_tool()  -- ← substitui consume_craft_materials(pos)
                                crafted = crafted + 1
                            else if not leftover:is_empty() then inv:set_stack("output", 1, leftover) end break 
                            end
                            break
                        end
                    end
                    if not recipe_found then break end
                end
                check_and_craft(pos, config)
            end)
        end
    end
    node_def.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if from_list == "craft" or to_list == "craft" then check_and_craft(pos, config) end
    end
    node_def.on_destruct = function(pos)
        -- Dropa os itens ANTES de destruir
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        -- Dropa todos os itens do grid de craft
        for i = 1, inv:get_size("craft") do
            local stack = inv:get_stack("craft", i)
            if not stack:is_empty() then c.add_item(pos, stack) end
        end
        local tool_stack = inv:get_stack("tool", 1)
        if not tool_stack:is_empty() then c.add_item(pos, tool_stack) end
        -- Dropa o item do output também (se houver)
        local output_stack = inv:get_stack("output", 1)
        if not output_stack:is_empty() then c.add_item(pos, output_stack) end
        -- Remove as entidades de display
        remove_item_entities(pos)
    end
    -- Registra o node com todas as propriedades
    if custom_on_punch then node_def.on_punch = custom_on_punch end
    c.register_node(node_name, node_def)
end

c.register_on_player_receive_fields(function(player, formname, fields)
    -- Verifica se é um formspec de craft station
    for node_name, config in pairs(craft_stations) do
        if formname:find(node_name) then
            -- Extrai a posição do formname
            local pos_string = formname:match("_(.+)$")
            if not pos_string then return end
            local pos = c.string_to_pos(pos_string)
            if not pos then return end
            local meta = c.get_meta(pos)
            local inv = meta:get_inventory()
            local player_inv = player:get_inventory()
            if fields.craft_one then
                local output_stack = inv:get_stack("output", 1)
                if not output_stack:is_empty() then
                    local leftover = player_inv:add_item("main", output_stack)
                    if leftover:is_empty() then
                        consume_craft_materials(pos)
                        check_and_craft(pos, config, player)   -- ← passa player
                    end
                end
            elseif fields.craft_all then
                -- Pega tudo que conseguir
                local max_crafts = 64
                local crafted = 0
                while crafted < max_crafts do
                    local output_stack = inv:get_stack("output", 1)
                    if output_stack:is_empty() then break end
                    local leftover = player_inv:add_item("main", output_stack)
                    if leftover:is_empty() then
                        consume_craft_materials(pos)
                        check_and_craft(pos, config, player) 
                        crafted = crafted + 1
                    else break
                    end
                end
            end
            return true
        end
    end
end)
-- FUNÇÃO AUXILIAR PARA DANO CONSECUTIVO
local function apply_poison_damage(player, damage_per_tick, total_damage, interval)
    local ticks = math.ceil(total_damage / damage_per_tick)
    local current_tick = 0
    local function apply_tick()
        if not player or not player:is_player() then return end
        current_tick = current_tick + 1
        -- Aplica o dano na VIDA (HP), não na fome
        local damage_to_apply = math.min(damage_per_tick, total_damage - (current_tick - 1) * damage_per_tick)
        local current_hp = player:get_hp()
        player:set_hp(current_hp - damage_to_apply)
        -- Efeito visual/sonoro de dano (opcional)
        c.sound_play("player_damage", {to_player = player:get_player_name(), gain = 0.5}, true)
        -- Se ainda há dano a aplicar, agenda o próximo tick
        if current_tick < ticks then c.after(interval, apply_tick) end
    end
    -- Inicia o primeiro tick
    apply_tick()
end

c.register_node("nh_nodes:dirt_ramp", {
    description         = S"Dirt Ramp",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_slope.obj",
    tiles               = {"dirt_slope.png"},
    groups              = {cracky = 3, soil = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:dirt",
    sunlight_propagates = true,
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5}, 
        dug = {name = "punchtimber3", gain = 0.5}, 
        dig = {name = "punchtimber3", gain = 0.5}, 
        place = {name = "punchtimber3", gain = 0.5}},
    selection_box       = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5}}},
    collision_box       = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5}}},
})
c.register_node("nh_nodes:dirt_corner", {
    description         = S"Dirt Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_vertix.obj",
    tiles               = {"dirt_slope.png"},
    groups              = {cracky = 3, soil = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:dirt",
    sunlight_propagates = true,
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug = {name = "punchtimber3", gain = 0.5},
        dig = {name = "punchtimber3", gain = 0.5},
        place = {name = "punchtimber3", gain = 0.5}},
    collision_box       = {type = "fixed", fixed = 
                {{ -0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, -- Topo
                {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5},     -- Base principal
                {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0},     -- Base braço 1
                {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
        
    selection_box       = {type = "fixed", fixed = 
                {{-0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, -- topo
                {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5},     -- Base principal
                {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0},     -- Base braço 1
                {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
})

c.register_node("nh_nodes:dirt_insidecorner", {
    description         = S"Dirt Inside Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grassinsidecorner.obj",
    tiles               = {"dirt_slope.png"},
    groups              = {cracky = 3, soil = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:dirt",
    sunlight_propagates = true,
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug = {name = "punchtimber3", gain = 0.5},
        dig = {name = "punchtimber3", gain = 0.5},
        place = {name = "punchtimber3", gain = 0.5}},
    collision_box = {type = "fixed", fixed = 
                {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- Base completa (metade inferior)
                {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5},       -- Topo braço 1: faixa traseira (Z-)
                {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0},       -- Topo braço 1: faixa traseira (Z-)
                {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}},   -- Topo braço 2: faixa lateral (X-)
    selection_box = {type = "fixed", fixed =
                {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
                {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5},
                {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0},
                {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}},
})
register_craft_station("nh_nodes:dirt", {
    description = S"Dirt",
    tiles = {"terra.png"},
    groups = {crumbly = 2},
    sounds = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug = {name = "punchtimber3", gain = 0.5},
        dig = {name = "punchtimber3", gain = 0.5},
        place = {name = "punchtimber3", gain = 0.5}},
    --paramtype = "light",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    on_construct = function(pos)
        local above = xyz(pos.x, pos.y + 1, pos.z)
        local node_above = c.get_node(above).name
        local light = c.get_node_light(above)
        if light and light > 4 then c.get_node_timer(pos):start(math.random(30, 60)) end
    end,

    on_timer = function(pos, elapsed)
        local above = xyz(pos.x, pos.y + 1, pos.z)
        local node_above = c.get_node(above).name
        local light = c.get_node_light(above)
        -- Bloco líquido ou lava acima impede virar grama
        local blocked_nodes = populate_true({ "water", "water_flowing", "water2", "water2_flowing", "lava",
            "lava_flowing", "bluelava", "bluelava_flowing" })
        -- Para o timer; terra fica como terra
        if blocked_nodes[node_above] then return false end
        if light and light <= 4 then return false end
        if light and light > 4 then
            -- (todo o seu código de vizinhos permanece igual)
            local neighbors = {xyz(pos.x + 1, pos.y, pos.z)}
            local has_grass_neighbor = false
            for _, npos in ipairs(neighbors) do
                local neighbor_name = c.get_node(npos).name
                if neighbor_name == "nh_nodes:grass" or neighbor_name == "nh_nodes:top_grass" then has_grass_neighbor = true break end
            end
            if has_grass_neighbor then c.set_node(pos, {name = "nh_nodes:top_grass"}) return false end
        end
        return true
    end,
    title = S "2x2 Craft on the Dirt", -- Campo obrigatório!
    grid_size = 4,
    positions = {xyz(-0.2, 0.9, -0.2), xyz(0.2, 0.9, -0.2), xyz(-0.2, 0.9, 0.2), xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S "2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})

c.register_node("nh_nodes:wetdirt", {
    description = S"Wet Dirt",
    tiles = {"wetdirt.png"},
    groups = {crumbly = 2},
    sounds = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug = {name = "punchtimber3", gain = 0.5},
        dig = {name = "punchtimber3", gain = 0.5},
        place = {name = "punchtimber3", gain = 0.5 },},
    --paramtype = "light",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    on_construct = function(pos)
        local above = xyz(pos.x, pos.y + 1, pos.z)
        local node_above = c.get_node(above).name
        local light = c.get_node_light(above)
        if light and light > 4 then c.get_node_timer(pos):start(math.random(30, 60)) end
    end,
    on_timer = function(pos, elapsed)
        --c.chat_send_all("⏰ TIMER disparou em " .. c.pos_to_string(pos))
        local above = { x = pos.x, y = pos.y + 1, z = pos.z }
        local node_above = c.get_node(above).name
        local light = c.get_node_light(above)
        if light and light <= 4 then return false end
        if light and light > 4 then
            local neighbors = {}
            for dx = -1, 1 do
                for dy = -1, 1 do
                    for dz = -1, 1 do
                        -- Ignora a posição central (o próprio bloco)
                        if not (dx == 0 and dy == 0 and dz == 0) then
                            table.insert(neighbors, xyz(pos.x + dx, pos.y + dy, pos.z + dz))
                        end
                    end
                end
            end
            local has_grass_neighbor = false
            local grass_found = ""
            for _, npos in ipairs(neighbors) do
                local neighbor_name = c.get_node(npos).name
                if neighbor_name == "nh_nodes:grass" or neighbor_name == "nh_nodes:top_grass" then
                    has_grass_neighbor = true
                    grass_found = neighbor_name .. " em " .. c.pos_to_string(npos)
                    break
                end
            end
            if has_grass_neighbor then c.set_node(pos, {name = "nh_nodes:top_grass"}) return false end
        end
        return true
    end,
})

c.register_node("nh_nodes:tilleddirt", {
    description = S "Tilled Dirt",
    tiles = { "tilleddirt.png", "terra.png" },
    groups = {crumbly = 2},
    drop = "nh_nodes:dirt",
    sounds = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug = {name = "punchtimber3", gain = 0.5},
        dig = {name = "punchtimber3", gain = 0.5}, 
        place = {name = "punchtimber3", gain = 0.5}},
    wielded_bone_position = { pos = xyz(0.5, 0.5, 1.65) },
    offhand_bone_position = { pos = xyz(1.5, 0, 0) },
    on_construct = function(pos) c.get_node_timer(pos):start(math.random(30, 60)) end,
    on_timer = function(pos, elapsed)
        local above = xyz(pos.x, pos.y + 1, pos.z)
        local node_above = c.get_node(above).name
        if node_above ~= "air" then return true end
        local laterals = {xyz(pos.x + 1, pos.y, pos.z), xyz(pos.x - 1, pos.y, pos.z), xyz(pos.x, pos.y, pos.z + 1), xyz(pos.x, pos.y, pos.z - 1),
            xyz(pos.x + 1, pos.y, pos.z + 1), xyz(pos.x + 1, pos.y, pos.z - 1), xyz(pos.x - 1, pos.y, pos.z + 1), xyz(pos.x - 1, pos.y, pos.z - 1)} -- diagonais
        local has_water = false
        for _, npos in ipairs(laterals) do
            local name = c.get_node(npos).name
            if name == "nh_nodes:water" or name == "nh_nodes:water2" or name == "nh_nodes:water_flowing" or name == "nh_nodes:water2_flowing" then
                has_water = true
                break
            end
        end
        if has_water then c.set_node(pos, {name = "nh_nodes:wettilleddirt"})
        else c.set_node(pos, {name = "nh_nodes:dirt"})
        end
        return false
    end,
})

c.register_node("nh_nodes:wettilleddirt", {
    description = S "Wet Tilled Dirt",
    tiles = {"wettilleddirt.png", "wetdirt.png"},
    groups = {crumbly = 2},
    drop = "nh_nodes:wetdirt",
    sounds = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug = {name = "punchtimber3", gain = 0.5},
        dig = {name = "punchtimber3", gain = 0.5},
        place = {name = "punchtimber3", gain = 0.5}},
    --paramtype = "light",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    on_construct = function(pos) c.get_node_timer(pos):start(math.random(60, 120)) end,
    on_timer = function(pos, elapsed)
        local above = {xyz(pos.x, pos.y + 1, pos.z)}
        local node_above = c.get_node(above).name
        -- tem bloco em cima, aguarda e tenta de novo
        if node_above ~= "air" then return true end
        c.set_node(pos, {name = "nh_nodes:wetdirt"})
        return false
    end,
})
c.register_node("nh_nodes:top_grass_ramp", {
    description         = "Grass Ramp",
    mesh                = "grass_slope.obj",
    tiles               = { "grass_slope.png" },
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    groups              = { cracky = 3, soil = 1, not_blocking_trains = 1 },
    drop                = "nh_nodes:dirt",
    sounds              = {
        footstep = {name = "GrassFootstep", gain = 0.5},
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    sunlight_propagates = true,
    selection_box       = { type = "fixed", fixed = {{ -0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5 }}},
    collision_box       = { type = "fixed", fixed = {{ -0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5 }}},
})

c.register_node("nh_nodes:top_grass_corner", {
    description         = "Grass Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_vertix.obj",
    tiles               = { "grass_slope.png" },
    groups              = { cracky = 3, soil = 1, not_blocking_trains = 1 },
    drop                = "nh_nodes:dirt",
    sounds              = {
        footstep = {name = "GrassFootstep", gain = 0.5},
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    sunlight_propagates = true,
    collision_box       = {type = "fixed", fixed = 
                {{-0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, -- Topo
                {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5},     -- Base principal
                {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0},     -- Base braço 1
                {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
    selection_box       = {type = "fixed", fixed = 
                {{-0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, -- topo
                {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5},     -- Base principal
                {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0},     -- Base braço 1
                {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
})

c.register_node("nh_nodes:top_grass_insidecorner", {
    description         = "Grass Inside Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grassinsidecorner.obj",
    tiles               = { "grass_slope.png" },
    groups              = { cracky = 3, soil = 1, not_blocking_trains = 1 },
    drop                = "nh_nodes:dirt",
    sunlight_propagates = true,
    sounds              = {
        footstep = { name = "GrassFootstep", gain = 0.5 },
        dug = { name = "GrassDig", gain = 0.5 },
        dig = { name = "GrassDig", gain = 0.5 },
        place = { name = "GrassDig", gain = 0.5 }, },
    collision_box       = {type = "fixed", fixed = 
                {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- Base completa (metade inferior)
                {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5},       -- Topo braço 1: faixa traseira (Z-
                {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0},       -- Topo braço 1: faixa traseira (Z-)
                {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}},      -- Topo braço 2: faixa lateral (X-)
        
    selection_box       = {type = "fixed", fixed = 
                {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, 
                {-0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, 
                {-0.5, 0.0, -0.5, 0.0, 0.5, 0.0}, 
                {0.5, 0.0, 0.0, 0.0, 0.5, 0.5}}},
})

register_craft_station("nh_nodes:top_grass", {
    description = S "Grass",
    tiles = {"grama.png", "terra.png", "grama_terra_lado.png"}, -- topo grama (0), embaixo terra (1) e lados terra/grama
    sounds = {
        footstep = {name = "GrassFootstep", gain = 0.5},
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    title = S "2x2 Craft on the Grass",
    groups = {crumbly = 1, soil = 1},
    drop = "nh_nodes:dirt",  -- Quando a grama quebrada vira terra
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    -- wielded_visual_size = xyz(0.25),
    on_timer = function(pos, elapsed)
        local above = {xyz(pos.x, pos.y + 1, pos.z)}
        local node_above = c.get_node(above).name
        -- Bloco líquido ou lava acima faz virar terra imediatamente
        local blocked_nodes = populate_true({ "water", "water_flowing", "water2", "water2_flowing", "lava",
            "lava_flowing", "bluelava", "bluelava_flowing"})
        if blocked_nodes[node_above] then c.set_node(pos, {name = "nh_nodes:dirt"}) return false end
        -- Se NÃO é ar, verifica luz
        if node_above ~= "air" then
            local light = c.get_node_light(above)
            if light and light <= 4 then c.set_node(pos, {name = "nh_nodes:dirt"}) return false end
        else return false -- Ar acima, sem ameaça, para o timer
        end
        return false
    end,
    grid_size = 4,
    positions = {
        xyz(-0.2, 0.9, -0.2),
        xyz(0.2, 0.9, -0.2),
        xyz(-0.2, 0.9, 0.2), 
        xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = {x = 3.1, y = 1}, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S "2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})

register_craft_station("nh_nodes:top_grass2", {
    description = S "Grass",
    tiles = { "grama.png", "terra.png"}, -- topo grama (0), embaixo e lados terra
    sounds = {
        footstep = {name = "GrassFootstep", gain = 0.5},
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    title = S "2x2 Craft on the Grass",
    groups = {crumbly = 1, soil = 1},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    -- Quando a grama é bloqueada da luz, vira terra
    drop = "nh_nodes:dirt",
    on_timer = function(pos, elapsed)
        local above = xyz(pos.x, pos.y + 1, pos.z)
        local node_above = c.get_node(above).name
        -- Bloco líquido ou lava acima faz virar terra imediatamente
        local blocked_nodes = populate_true({ "water", "water_flowing", "water2", "water2_flowing", "lava",
            "lava_flowing", "bluelava", "bluelava_flowing", })
        if blocked_nodes[node_above] then c.set_node(pos, { name = "nh_nodes:dirt" }) return false end -- Grama virou terra, para o timer
        -- Se NÃO é ar, verifica luz
        if node_above ~= "air" then
            local light = c.get_node_light(above)
            if light and light <= 4 then c.set_node(pos, {name = "nh_nodes:dirt"}) return false end
        else return false -- Ar acima, sem ameaça, para o timer
        end
        return false
    end,
    grid_size = 4,
    positions = {
        xyz(-0.2, 0.9, -0.2),
        xyz(0.2, 0.9, 0.2),
        xyz(-0.2, 0.9, 0.2), 
        xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S"2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})

register_craft_station("nh_nodes:grass", {
    description = S"Lawn",
    tiles = {"grama.png"},
    groups = {crumbly = 1},
    sunlight_propagates = false,
    drop = "nh_nodes:dirt",
    sounds = {
        footstep = {name = "GrassFootstep", gain = 0.5},
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    -- wielded_visual_size = xyz(0.25),
    on_timer = function(pos, elapsed)
        --c.chat_send_all("⏰ TIMER de morte da grama disparou em " .. c.pos_to_string(pos))
        -- Verifica se há um bloco bloqueando a luz acima
        local above = {xyz(pos.x, pos.y + 1, pos.z)}
        local node_above = c.get_node(above).name
        -- Se NÃO é ar, significa que está tampado
        if node_above ~= "air" then
            local light = c.get_node_light(above) -- Verifica se a luz está muito baixa
            if light and light <= 4 then c.set_node(pos, {name = "nh_nodes:dirt"}) return false end
        else return false -- Para o timer se o bloco foi removido
        end
        return false
    end,
    title = S "2x2 Craft on the Lawn", --       Campo obrigatório!
    grid_size = 4,
    positions = {
        xyz(-0.2, 0.9, -0.2),
        xyz(0.2, 0.9, -0.2),
        xyz(-0.2, 0.9, 0.2),
        xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = {x = 3.1, y = 1}, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S"2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})
-- SISTEMA DE DETECÇÃO DE BLOCOS ACIMA DA GRAMA
-- Callback global que detecta quando qualquer bloco é colocado
c.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    -- Verifica a posição ABAIXO do bloco que foi colocado
    local below = {xyz(pos.x, pos.y - 1, pos.z)}
    local node_below = c.get_node(below)
    -- Se o bloco abaixo é grama ou top_grass
    if node_below.name == "nh_nodes:grass" or node_below.name == "nh_nodes:top_grass" then
        c.get_node_timer(below):start(math.random(3, 6))
    end
end)
-- Callback global que detecta quando qualquer bloco é REMOVIDO
c.register_on_dignode(function(pos, oldnode, digger)
    -- Verifica a posição ABAIXO do bloco que foi removido
    local below = {xyz(pos.x, pos.y - 1, pos.z)}
    local node_below = c.get_node(below)
    -- Se o bloco abaixo é grama ou top_grass
    if node_below.name == "nh_nodes:grass" or node_below.name == "nh_nodes:top_grass" then c.get_node_timer(below):stop()
    elseif node_below.name == "nh_nodes:dirt" then c.get_node_timer(below):start(math.random(3, 6))
    end
end)
c.register_node("nh_nodes:sand_ramp", {
    description         = S "Sand Ramp",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_slope.obj",
    tiles               = { "sand_slope.png" },
    groups              = {crumbly = 3, soil = 1, falling_node = 1, not_blocking_trains = 1 },
    drop                = "nh_nodes:sand",
    sounds              = {
        footstep = { name = "punchtimber3", gain = 0.5 },
        dug = { name = "punchtimber3", gain = 0.5 },
        dig = { name = "punchtimber3", gain = 0.5 },
        place = { name = "punchtimber3", gain = 0.5 },},
    sunlight_propagates = true,
    selection_box       = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5}}},
    collision_box       = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5 }}},
})

c.register_node("nh_nodes:sand_corner", {
    description         = S "Sand Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_vertix.obj",
    tiles               = {"sand_slope.png"},
    groups              = {crumbly = 3, soil = 1, falling_node = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:sand",
    sounds              = {
        footstep = { name = "punchtimber3", gain = 0.5},
        dug = { name = "punchtimber3", gain = 0.5 },
        dig = { name = "punchtimber3", gain = 0.5 },
        place = { name = "punchtimber3", gain = 0.5 },},
    sunlight_propagates = true,
    collision_box       = {type = "fixed", fixed = 
                {{-0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, -- Topo
                {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5},     -- Base principal
                {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0},     -- Base braço 1
                {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}},     -- Base braço 2
    selection_box       = {type = "fixed", fixed =  
                {{-0.5, 0.0, 0.0, 0.0, 0.5, 0.5}, -- topo
                {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5},     -- Base principal
                {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0},     -- Base braço 1
                {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}},     -- Base braço 2
})
c.register_node("nh_nodes:sand_insidecorner", {
    description         = S"Sand Inside Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grassinsidecorner.obj",
    tiles               = {"sand_slope.png"},
    groups              = {crumbly = 3, soil = 1, falling_node = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:sand",
    sounds = {
        footstep = { name = "punchtimber3", gain = 0.5 },
        dug = { name = "punchtimber3", gain = 0.5 },
        dig = { name = "punchtimber3", gain = 0.5 },
        place = { name = "punchtimber3", gain = 0.5 }, },
    sunlight_propagates = true,
    collision_box = {type = "fixed", fixed = 
                {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- Base completa (metade inferior)
                {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5},       -- Topo braço 1: faixa traseira (Z-)
                {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0},       -- Topo braço 1: faixa traseira (Z-)
                {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}},   -- Topo braço 2: faixa lateral (X-)
        
    selection_box = { type = "fixed", fixed = 
                {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
                {-0.5, 0.0, 0.0, 0.0, 0.5, 0.5},
                {-0.5, 0.0, -0.5, 0.0, 0.5, 0.0},
                {0.5, 0.0, 0.0, 0.0, 0.5, 0.5}}},
})

register_craft_station("nh_nodes:sand", {
    description = S "Sand",
    mesh = nil,
    tiles = { "areia.png" },
    title = S "2x2 Craft on the Sand", -- Campo obrigatório!
    grid_size = 4,
    groups = {crumbly = 3, falling_node = 1},
    sounds = {
        footstep = { name = "punchtimber3", gain = 0.5 },
        dug = { name = "punchtimber3", gain = 0.5 },
        dig = { name = "punchtimber3", gain = 0.5 },
        place = { name = "punchtimber3", gain = 0.5 },},
    wielded_bone_position = {pos = { x = 0.5, y = 0.5, z = 1.65 }}, -- Configuração mão direita
    offhand_bone_position = {pos = { x = 1.5, y = 0, z = 0 }}, -- Configuração mão esquerda
    positions = { { x = -0.2, y = 0.9, z = -0.2 }, { x = 0.2, y = 0.9, z = -0.2 }, { x = -0.2, y = 0.9, z = 0.2 }, { x = 0.2, y = 0.9, z = 0.2 }, },
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S "2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})

register_craft_station("nh_nodes:wet_sand", {
    description = S "Wet Sand",
    tiles = { "areia_molhada.png" },
    title = S "2x2 Craft on the Wet Sand", --       Campo obrigatório!
    groups = { crumbly = 3 },
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    grid_size = 4,
    positions = {
        xyz(-0.2, 0.9, -0.2), xyz(0.2, 0.9, -0.2),
        xyz(-0.2, 0.9, 0.2), xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = {x = 3.1, y = 1}, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S "2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})
c.register_node("nh_nodes:saprolite", {
    description = S"Saprolite",
    tiles = {"saprolite.png"},
    groups = {cracky = 3},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})
register_craft_station("nh_nodes:gneiss", {
    description = S "Gneiss",
    tiles = {"pedra.png"},
    groups = {cracky = 1},
    drop = "nh_nodes:pebble_item 8",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    title = S "2x2 Craft on the Gneiss", --       Campo obrigatório!
    grid_size = 4,
    positions = {
        xyz(-0.2, 0.9, -0.2), xyz(0.2, 0.9, -0.2),
        xyz(-0.2, 0.9, 0.2), xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = {x = 3.1, y = 1}, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S"2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})

register_craft_station("nh_nodes:cobblestone", {
    description = S "Cobblestone",
    tiles = { "cobblestone.png" },
    groups = {cracky = 2},
    drop = "nh_nodes:pebble_item 8",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    title = "Produção 2x2 no Pedregulho", --       Campo obrigatório!
    grid_size = 4,
    positions = {
        xyz(-0.2, 0.9, -0.2), xyz(0.2, 0.9, -0.2),
        xyz(-0.2, 0.9, 0.2), xyz(0.2, 0.9, 0.2)},
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S"2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_floor
})
c.register_node("nh_nodes:charcoal", {
    description = S "Charcoal",
    tiles = {"topdowncharcoal.png", "topdowncharcoal.png", "charcoal.png"}, -- topo / base / lados (direita, esquerda, frente, trás)
    groups = { choppy = 3, armor_head = 1 },
    stack_max = 1,
    drop = "nh_nodes:charcoalnugget 8",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    paramtype = "light",
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    node_box = {type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    sounds = {dug = {name = "punchtimber", gain = 0.5}, dig = {name = "punchtimber", gain = 0.5}},
})
c.register_node("nh_nodes:charcoal2", {
    description = S "Smaller Charcoal",
    drawtype = "mesh",
    mesh = "palm_trunk.obj",
    tiles = { "charcoal2.png" },
    stack_max = 4,
    drop = "nh_nodes:charcoalnugget 2",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25}},
    node_box = { type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.5, 0.5, 0.25, 0.5}},
    -- Som tocado ao bater no tronco medio (2)
    sounds = {dug = {name = "punchtimber2", gain = 0.5}, dig = {name = "punchtimber2", gain = 0.5}}
})

c.register_node("nh_nodes:coal", {
    description = S "Black Coal" .. "\n" .. S "[Coal Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = { "coalore.png" },
    groups = {cracky = 2},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    drop = {items = {{items = {"nh_nodes:coalnugget 8"}}}},
})

c.register_node("nh_nodes:coalnugget", {
    description = S"Coal Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = { "coalnugget.png" },
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
    selection_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
})

c.register_node("nh_nodes:charcoalnugget", {
    description = S "Charcoal Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = { "charcoalnugget.png" },
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.35, 0.08 },},
    selection_box = {type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.35, 0.08 },},
})

c.register_node("nh_nodes:copper", {
    description = S "Chalcopyrite" .. "\n" .. S "[Copper Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = { "gneiss_copperore.png" },
    groups = {cracky = 3},
    drop = {items = {{items = {"nh_nodes:coppernugget"}}, {items = {"nh_nodes:pebble 3"}}}},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:coppernugget", {
    description = S"Copper Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = { "coppernugget.png" },
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.35, 0.08 },},
    selection_box = {type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.35, 0.08 },},
})

c.register_node("nh_nodes:copperingot", {
    description = S "Copper Ingot",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"copperingot.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.186, -0.5, -0.061, 0.186, -0.375, 0.061}},
})

c.register_node("nh_nodes:tin", {
    description = S "Cassiterite" .. "\n" .. S "[Tin Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = { "gneiss_tinore.png" },
    groups = {cracky = 3},
    drop = {items = {{ items = {"nh_nodes:tinnugget"}}, { items = {"nh_nodes:pebble 3"}}, }},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},  -- Configuração mão esquerda
})

c.register_node("nh_nodes:tinnugget", {
    description = S"Tin Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"tinnugget.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
    selection_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
})

c.register_node("nh_nodes:tiningot", {
    description = S"Tin Ingot",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = { "tiningot.png" },
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.186, -0.5, -0.061, 0.186, -0.375, 0.061}},
})

c.register_node("nh_nodes:iron", {
    description = S"Pyrite" .. "\n" .. S"[Iron Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_ironore.png"},
    groups = {cracky = 3},
    drop = {items = {{items = {"nh_nodes:ironnugget"}}, {items = {"nh_nodes:pebble 3"}}}},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:ironnugget", {
    description = S"Iron Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"ironnugget.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
    selection_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
})

c.register_node("nh_nodes:ironingot", {
    description = S"Iron Ingot",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"ironingot.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.186, -0.5, -0.061, 0.186, -0.375, 0.061}},
})

c.register_node("nh_nodes:nickel", {
    description = S"Garnierite" .. "\n" .. S"[Nickel Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_nickelore.png"},
    groups = {cracky = 3},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)},  -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},  -- Configuração mão esquerda
})

c.register_node("nh_nodes:nickelnugget", {
    description = S"Nickel Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"nickelnugget.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
    selection_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
})

c.register_node("nh_nodes:nickelingot", {
    description = S"Nickel Ingot",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"nickelingot.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.186, -0.5, -0.061, 0.186, -0.375, 0.061}},
})

c.register_node("nh_nodes:manganese", {
    description = S"Pyrolusite" .. "\n" .. S"[Manganese Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_manganeseore.png"},
    groups = {cracky = 3},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:manganesenugget", {
    description = S"Manganese Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"manganesenugget.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
    selection_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
})

c.register_node("nh_nodes:manganeseingot", {
    description = S"Manganese Ingot",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"manganeseingot.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.186, -0.5, -0.061, 0.186, -0.375, 0.061}},
})

c.register_node("nh_nodes:chromium", {
    description = S"Chromite" .. "\n" .. S"[Chromium Ore]",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_chromeore.png"},
    groups = {cracky = 3},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)},  -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},  -- Configuração mão esquerda
})

c.register_node("nh_nodes:chromiumnugget", {
    description = S"Chromium Nugget",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"chromiumnugget.png"},
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
    selection_box = {type = "fixed", fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08}},
})

c.register_node("nh_nodes:chromiumingot", {
    description = S "Chromium Ingot",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = { "chromiumingot.png" },
    groups = {oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.186, -0.5, -0.061, 0.186, -0.375, 0.061}},
})

c.register_node("nh_nodes:peridotite", {
    description = S "Peridotite",
    tiles = {"peridotite.png"},
    groups = {cracky = 3},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:redrock", {
    description = S "Ruborita",
    tiles = { "lava.png" },
    groups = {unbreakable = 1, not_in_creative_inventory = 1},
    drop = "",
    wielded_bone_position = {pos = { x = 0.5, y = 0.5, z = 1.65 }}, -- Configuração mão direita
    offhand_bone_position = {pos = { x = 1.5, y = 0, z = 0 }}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:bedrock", {
    description = S "Bridgmanite",
    tiles = {"matriz.png"},
    drawtype = "glasslike_framed_optional",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    groups = { cracky = 3 },
    wielded_bone_position = {pos = { x = 0.5, y = 0.5, z = 1.65 }},  -- Configuração mão direita
    offhand_bone_position = {pos = { x = 1.5, y = 0, z = 0 }},  -- Configuração mão esquerda
})

c.register_node("nh_nodes:obsidian", {
    description = S "Obsidian",
    tiles = {"obsidiana.png"},
    groups = {cracky = 3}, 
    drop = "nh_nodes:obsidianpebble 8",
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}}, -- Configuração mão esquerda
})


c.register_node("nh_nodes:oakresin", {
    description = S "Oak Resin",
    drawtype = "mesh",
    mesh = "oakresin.obj",
    tiles = { "oakresin.png" },
    --drawtype = "glasslike_framed_optional",
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    groups = {snappy = 3, oddly_breakable_by_hand = 3},
    collision_box = {type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, -0.45, 0.1 }},
    selection_box = {type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, -0.45, 0.1 }},
})

-- Função para verificar se um nó tem suporte sólido
local function has_solid_support(pos, checked)
    checked = checked or {}
    local hash = c.hash_node_position(pos)
    if checked[hash] then return false end
    checked[hash] = true
    if #checked > 100 then return false end
    local below = { x = pos.x, y = pos.y - 1, z = pos.z }
    local below_node = c.get_node(below)
    local def = c.registered_nodes[below_node.name]
    if not def then return false end
    -- Algo sólido que NÃO seja árvore
    if below_node.name ~= "air"
        and not def.groups.tree_trunk
        and not def.groups.tree_leaves then
        return true
    end
    -- Tronco abaixo → verifica recursivamente
    if def.groups.tree_trunk then return has_solid_support(below, checked) end
    return false
end


-- Função para fazer folhas caírem
local function make_leaves_fall(pos)
    local radius_horizontal = 8 -- Alcance lateral
    local radius_vertical = 20  -- Alcance vertical (para cima e para baixo)
    for x = -radius_horizontal, radius_horizontal do
        for y = radius_vertical, -radius_vertical, -1 do -- Aumentado para pegar folhas mais altas
            for z = -radius_horizontal, radius_horizontal do
                local check_pos = { x = pos.x + x, y = pos.y + y, z = pos.z + z }
                local node = c.get_node(check_pos)
                if c.get_item_group(node.name, "tree_leaves") > 0 then
                    local delay = math.random(2, 10) / 10
                    c.after(delay, function()
                        local current_node = c.get_node(check_pos)
                        if c.get_item_group(current_node.name, "tree_leaves") > 0 then c.remove_node(check_pos)
                            local obj = c.add_entity(check_pos, "__builtin:falling_node")
                            if obj then obj:get_luaentity():set_node(current_node) end
                        end
                    end)
                end
            end
        end
    end
end

-- Tronco
c.register_node("nh_nodes:oaktimber", {
    description = S "Oak Timber",
    tiles = { "oaktimber.png" },
    groups = {choppy = 1, falling_node = 1, armor_head = 1},
    stack_max = 1,
    drop = "nh_nodes:oaklog",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    -- wielded_visual_size = xyz(0.25),
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig = {name = "punchtimber", gain = 0.5}},
    -- Detecta quando o tronco é quebrado ou vai cair
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        -- Verifica se tinha suporte antes de ser quebrado
        -- Se não tinha, significa que vai cair
        local below = xyz(pos.x, pos.y - 1, pos.z)
        local below_node = c.get_node(below)
        -- Se abaixo é ar ou outro tronco/folha, faz folhas caírem
        if below_node.name == "air" or below_node.name == "nh_nodes:oaktimber" or below_node.name:find("nh_nodes:leaves") or below_node.name:find("nh_nodes:leaves_nut") or
            below_node.name:find("nh_nodes:leaves_nut2") or below_node.name:find("nh_nodes:leaves_nut3") or below_node.name:find("nh_nodes:oakbranch") then
            make_leaves_fall(pos)
        end
    end,
    -- Detecta quando o tronco começa a se mover
    on_construct = function(pos) c.get_node_timer(pos):start(0.5) end,
    on_timer = function(pos)
        local node = c.get_node(pos)
        if node.name == "nh_nodes:oaktimber" then
            -- Se não tem suporte, vai começar a cair
            if not has_solid_support(pos) then make_leaves_fall(pos) return false end -- False para o timer
            return true      -- Continua verificando
        end
        return false
    end,
})

-- Ramo
c.register_node("nh_nodes:oakbranch", {
    description = S "Oak Branch",
    drawtype = "mesh",
    mesh = "oakbranch.obj",
    tiles = { "oaktimber.png" },
    groups = { choppy = 3, tree_leaves = 1 },
    stack_max = 3,
    paramtype = "light",
    paramtype2 = "facedir",
    selection_box = {type = "fixed", fixed = { -0.2, -0.2, -0.5, 0.2, 0.5, 0.5 },},
    collision_box = {type = "fixed", fixed = { -0.2, -0.2, -0.5, 0.2, 0.5, 0.5 },},
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}},      -- Configuração mão esquerda
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },},
})

c.register_node("nh_nodes:oaklog", {
    description = S "Oak Log",
    tiles = {"topdownoaktimber.png", "topdownoaktimber.png", "oaktimber.png"}, -- topo/ base /lados (direita, esquerda, frente, trás)
    groups = { choppy = 3, armor_head = 1 },
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted",
        wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },},
    node_box = {type = "wallmounted",
        wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },},
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}}, -- Configuração mão esquerda
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },},
})

-- Tronco de macieira
c.register_node("nh_nodes:appletimber", {
    description = S "Apple Timber",
    drawtype = "mesh",
    mesh = "appletimber.obj",
    tiles = { "appletimber.png" },
    groups = {choppy = 3, falling_node = 1, armor_head = 1},
    stack_max = 1,
    paramtype = "light",
    sunlight_propagates = true,
    collision_box = {type = "fixed", fixed = { -0.095, -0.5, -0.095, 0.095, 0.5, 0.095 },},
    selection_box = {type = "fixed", fixed = { -0.095, -0.5, -0.095, 0.095, 0.5, 0.095 },},
    sounds = {
        dug = { name = "punchtimber3", gain = 0.5 },
        dig = { name = "punchtimber3", gain = 0.5 },},
    -- Detecta quando o tronco é quebrado ou vai cair
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local below = { x = pos.x, y = pos.y - 1, z = pos.z }
        local below_node = c.get_node(below)
        -- CORRIGIDO: Verifica TODAS as folhas de macieira
        if below_node.name == "air"
            or below_node.name == "nh_nodes:appletimber"
            or below_node.name == "nh_nodes:appleleaves"
            or below_node.name == "nh_nodes:leaves_apple"
            or below_node.name == "nh_nodes:leaves_apple2"
            or below_node.name == "nh_nodes:leaves_apple3" then
            make_leaves_fall(pos)
        end
    end,
    on_construct = function(pos) c.get_node_timer(pos):start(0.5) end,
    on_timer = function(pos)
        local node = c.get_node(pos)
        if node.name == "nh_nodes:appletimber" then
            if not has_solid_support(pos) then make_leaves_fall(pos) return false end
            return true
        end
        return false
    end,
})

-- Tronco 3
c.register_node("nh_nodes:pinetimber", {
    description = S "Pine Timber",
    tiles = { "pinetimber.png" },
    groups = {choppy = 1, falling_node = 1, armor_head = 1},
    stack_max = 1,
    drop = "nh_nodes:pinelog",
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },},
    -- Detecta quando o tronco é quebrado ou vai cair
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        -- Verifica se tinha suporte antes de ser quebrado
        -- Se não tinha, significa que vai cair
        local below = { x = pos.x, y = pos.y - 1, z = pos.z }
        local below_node = c.get_node(below)
        -- Se abaixo é ar ou outro tronco/folha, faz folhas caírem
        if below_node.name == "air" or below_node.name == "nh_nodes:pinetimber" or below_node.name:find("nh_nodes:leaves") then
            make_leaves_fall(pos)
        end
    end,
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}},  -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}}, -- Configuração mão esquerda
    -- Detecta quando o tronco começa a se mover
    on_construct = function(pos) c.get_node_timer(pos):start(0.5) end,
    on_timer = function(pos)
        local node = c.get_node(pos)
        if node.name == "nh_nodes:pinetimber" then
            -- Se não tem suporte, vai começar a cair
            if not has_solid_support(pos) then make_leaves_fall(pos) return false end -- Para o timer
            return true      -- Continua verificando
        end
        return false
    end,
})

c.register_node("nh_nodes:pinelog", {
    description = S "Pine Log",
    tiles = {"topdownpinetimber.png", "topdownpinetimber.png", "pinetimber.png"}, -- topo / base / lados (direita, esquerda, frente, trás)
    groups = { choppy = 3, armor_head = 1 },
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted",
        wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },},
    node_box = {type = "wallmounted",
        wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },},
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}},  -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}}, -- Configuração mão esquerda
    -- Som tocado ao bater no tronco
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },},
})

-- Madeira
c.register_node("nh_nodes:oakwood", {
    description = S "Oak Wood",
    tiles = { "oakwood.png" },
    groups = { choppy = 3 },
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },},
    wielded_bone_position = {pos = { x = 0.5, y = 0.5, z = 1.65 }}, -- Configuração mão direita
    offhand_bone_position = {pos = { x = 1.5, y = 0, z = 0 }}, -- Configuração mão esquerda
})

-- Madeira
c.register_node("nh_nodes:pinewood", {
    description = S "Pine Wood",
    tiles = { "pinewood.png" },
    groups = { choppy = 3 },
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig = {name = "punchtimber", gain = 0.5}},
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:bone", {
    description = S "Bone",
    drawtype = "mesh",
    mesh = "bone.obj",
    tiles = { "bone.png" },
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    stack_max = 8,
    paramtype = "light",
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted",
        wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },},
    node_box = {type = "wallmounted",
        wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },},
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },},
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.25, y = 0, z = 0},
        rot = {x = 90, y = 90, z = 90}},
})


-- slime
c.register_node("nh_nodes:slime", {
    description = S "Limu" .. "\n" .. S "[collectible]",
    drawtype = "mesh",
    mesh = "planaria_slime_small2.obj",
    tiles = { "planaria_slime2.png" },
    groups = { snappy = 3 },
    paramtype = "light",
    -- BRILHO NOS OLHOS
    glow = 5, -- Intensidade de 0 a 14 (14 = mais brilhante)
    use_texture_alpha = "blend",
    wielded_bone_position = {rot = {x = 0, y = 90, z = -90}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}, rot = {x = 0, y = 90, z = -90}}, -- Configuração mão esquerda
})

-- grilo
c.register_node("nh_nodes:cricket", {
    description = S "Cricket" .. "\n" .. S "[collectible]",
    drawtype = "mesh",
    mesh = "cricket.obj",
    tiles = {"cricket.png"},
    groups = {snappy = 3},
    paramtype = "light",
    use_texture_alpha = "clip",
    wielded_bone_position = {pos = {x = 0.5, y = 0.5, z = 1.65}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 1.5, y = 0, z = 0}}, -- Configuração mão esquerda
})

-- Madeira
c.register_node("nh_nodes:campfiretinder", {
    description = S "Campfire Tinder",
    drawtype = "mesh",
    mesh = "iscafogueira.obj",
    tiles = {"iscafogueira.png"},
    groups = {snappy = 3},
    use_texture_alpha = "blend",
    paramtype = "light",
    collision_box = {type = "fixed", fixed = { -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},
})

-- Tronco de carvalho fatiado
c.register_node("nh_nodes:oaktimberslice", {
    description = S "Oak Firewood",
    drawtype = "mesh",
    mesh = "oaktimberslice.obj",
    tiles = { "oaktimber.png" },
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 16,
    paramtype = "light",
    on_place = function(itemstack, placer, pointed_thing)
        -- Verifica se o jogador está agachado
        if placer and placer:is_player() and placer:get_player_control().sneak then
            return c.item_place(itemstack, placer, pointed_thing) -- Comportamento normal de colocação (com shift)
        end
        -- Se está clicando em um node (sem agachar)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = c.get_node(pos)
            -- Verifica qual estágio está e evolui (apenas se mirar em campfiretinder)
            if node.name == "nh_nodes:campfiretinder" then
                c.set_node(pos, { name = "nh_nodes:oaktimberslice1" })
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:oaktimberslice1" then
                c.set_node(pos, { name = "nh_nodes:oaktimberslice2" })
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:oaktimberslice2" then
                c.set_node(pos, { name = "nh_nodes:oaktimberslice3" })
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:oaktimberslice3" then
                c.set_node(pos, { name = "nh_nodes:campfire" })
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing) -- Comportamento normal de colocação para outros casos
    end,
})

-- Lenha de carvalho 1 - 1/4 firewood
c.register_node("nh_nodes:oaktimberslice1", {
    description = S "Firewood on the Campfire 1/4",
    drawtype = "mesh",
    mesh = "oaktimberslice1.obj",
    tiles = { "fogueira.png" },
    groups = {oddly_breakable_by_hand = 1},
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},

    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:oaktimberslice1" and itemstack:get_name() == "nh_nodes:oaktimberslice" then
                c.set_node(pos, {name = "nh_nodes:oaktimberslice2"})
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Lenha de carvalho 2 - 2/4 firewood
c.register_node("nh_nodes:oaktimberslice2", {
    description = S "Firewood on the Campfire 2/4",
    drawtype = "mesh",
    mesh = "oaktimberslice2.obj",
    tiles = {"fogueira.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice 2"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:oaktimberslice2" and itemstack:get_name() == "nh_nodes:oaktimberslice" then
                c.set_node(pos, { name = "nh_nodes:oaktimberslice3" })
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Lenha de carvalho 3 - 3/4 firewood
c.register_node("nh_nodes:oaktimberslice3", {
    description = S "Firewood on the Campfire 3/4",
    drawtype = "mesh",
    mesh = "oaktimberslice3.obj",
    tiles = { "fogueira.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice 3"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:oaktimberslice3" and itemstack:get_name() == "nh_nodes:oaktimberslice" then
                c.set_node(pos, { name = "nh_nodes:campfire" })
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Fogueira (estágio final) - Campfire - 4/4 firewood
register_craft_station("nh_nodes:campfire", {
    description = S "Campfire",
    drawtype = "mesh",
    mesh = "oaktimberslice4.obj",
    tiles = { "fogueira.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {choppy = 3, oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:oaktimberslice 4"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    title = "Produção 2x2 na Fogueira", -- Campo obrigatório!
    grid_size = 4,
    positions = {
        xyz(-0.4, 0.2, -0.25), xyz(0.4, 0.2, -0.25),
        xyz(-0.4, 0.2,  0.25), xyz(0.4, 0.2,  0.25)},
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S"2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_campfire,
    -- Quando a fogueira é colocada, verifica se deve criar chama
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        -- Se já tiver chama marcada, cria a entidade
        if meta:get_int("has_flame") == 1 then
            c.after(0.1, function()
                -- Verifica se não existe chama já
                local objs = c.get_objects_inside_radius(pos, 0.5)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:campfire_flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    local obj = c.add_entity(pos, "nh_nodes:campfire_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._straw_pos = pos end
                    end
                end
            end)
        end
    end,
    -- Quando a fogueira é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing) 
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:campfire_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._straw_pos = pos end
            end
            -- Efeito sonoro
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    can_craft = function(pos)
        local meta = c.get_meta(pos)
        if meta:get_int("has_flame") ~= 1 then return false, S "I forgot that a bonfire needs to be lit to prepare..." end
        return true
    end,
    -- Quando a fogueira for removida, remove as chamas
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:campfire_flame_entity" then obj:remove() end
        end
    end,
})

-- Tronco de carvalho fatiado
c.register_node("nh_nodes:pinetimberslice", {
    description = S "Pine Firewood",
    drawtype = "mesh",
    mesh = "oaktimberslice.obj",
    tiles = {"pinetimber.png"},
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 16,
    paramtype = "light",
    on_place = function(itemstack, placer, pointed_thing)
        -- Verifica se o jogador está agachado
        if placer and placer:is_player() and placer:get_player_control().sneak then
            return c.item_place(itemstack, placer, pointed_thing) -- Comportamento normal de colocação (com shift)
        end
        -- Se está clicando em um node (sem agachar)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = c.get_node(pos)
            -- Verifica qual estágio está e evolui (apenas se mirar em campfiretinder)
            if node.name == "nh_nodes:campfiretinder" then
                c.set_node(pos, { name = "nh_nodes:pinetimberslice1" })
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:pinetimberslice1" then
                c.set_node(pos, { name = "nh_nodes:pinetimberslice2" })
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:pinetimberslice2" then
                c.set_node(pos, { name = "nh_nodes:pinetimberslice3" })
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:pinetimberslice3" then
                c.set_node(pos, { name = "nh_nodes:pinecampfire" })
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing) -- Comportamento normal de colocação para outros casos
    end,
})
-- Lenha de pinheiro 1 - 1/4 firewood
c.register_node("nh_nodes:pinetimberslice1", {
    description = S "Firewood on the Campfire 1/4",
    drawtype = "mesh",
    mesh = "oaktimberslice1.obj",
    tiles = { "pinecampfire.png" },
    groups = {oddly_breakable_by_hand = 1},
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},

    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:pinetimberslice1" and itemstack:get_name() == "nh_nodes:pinetimberslice" then
                c.set_node(pos, {name = "nh_nodes:pinetimberslice2"})
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})
-- Lenha de pinheiro 2 - 2/4 firewood
c.register_node("nh_nodes:pinetimberslice2", {
    description = S "Firewood on the Campfire 2/4",
    drawtype = "mesh",
    mesh = "oaktimberslice2.obj",
    tiles = {"pinecampfire.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice 2"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:pinetimberslice2" and itemstack:get_name() == "nh_nodes:pinetimberslice" then
                c.set_node(pos, { name = "nh_nodes:pinetimberslice3" })
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})
-- Lenha de pinheiro 3 - 3/4 firewood
c.register_node("nh_nodes:pinetimberslice3", {
    description = S "Firewood on the Campfire 3/4",
    drawtype = "mesh",
    mesh = "oaktimberslice3.obj",
    tiles = { "pinecampfire.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice 3"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:pinetimberslice3" and itemstack:get_name() == "nh_nodes:pinetimberslice" then
                c.set_node(pos, { name = "nh_nodes:pinecampfire" })
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})
-- Fogueira (estágio final) - Campfire - 4/4 firewood
register_craft_station("nh_nodes:pinecampfire", {
    description = S "Campfire",
    drawtype = "mesh",
    mesh = "oaktimberslice4.obj",
    tiles = { "pinecampfire.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {choppy = 3, oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:pinetimberslice 4"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    title = "Produção 2x2 na Fogueira", -- Campo obrigatório!
    grid_size = 4,
    positions = {
        { x = -0.4, y = 0.2, z = -0.25 }, { x = 0.4, y = 0.2, z = -0.25 },
        { x = -0.4, y = 0.2, z = 0.25 }, { x = 0.4, y = 0.2, z = 0.25 },},
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S "2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_campfire,
    -- Quando a fogueira é colocada, verifica se deve criar chama
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        -- Se já tiver chama marcada, cria a entidade
        if meta:get_int("has_flame") == 1 then
            c.after(0.1, function()
                -- Verifica se não existe chama já
                local objs = c.get_objects_inside_radius(pos, 0.5)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:campfire_flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    local obj = c.add_entity(pos, "nh_nodes:campfire_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._straw_pos = pos end
                    end
                end
            end)
        end
    end,
    -- Quando a fogueira é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing) 
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:campfire_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._straw_pos = pos end
            end
            -- Efeito sonoro
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    can_craft = function(pos)
        local meta = c.get_meta(pos)
        if meta:get_int("has_flame") ~= 1 then return false, S "I forgot that a bonfire needs to be lit to prepare..." end
        return true
    end,
    -- Quando a fogueira for removida, remove as chamas
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:campfire_flame_entity" then obj:remove() end
        end
    end,
})

-- Tronco de coqueiro fatiado
c.register_node("nh_nodes:palmtimberslice", {
    description = S "Pine Firewood",
    drawtype = "mesh",
    mesh = "palmtimberslice.obj",
    tiles = {"coqueirotexture.png"},
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 16,
    paramtype = "light",
    on_place = function(itemstack, placer, pointed_thing)
        -- Verifica se o jogador está agachado
        if placer and placer:is_player() and placer:get_player_control().sneak then
            return c.item_place(itemstack, placer, pointed_thing) -- Comportamento normal de colocação (com shift)
        end
        -- Se está clicando em um node (sem agachar)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = c.get_node(pos)
            -- Verifica qual estágio está e evolui (apenas se mirar em campfiretinder)
            if node.name == "nh_nodes:campfiretinder" then
                c.set_node(pos, {name = "nh_nodes:palmtimberslice1"})
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:palmtimberslice1" then
                c.set_node(pos, {name = "nh_nodes:palmtimberslice2"})
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:palmtimberslice2" then
                c.set_node(pos, {name = "nh_nodes:palmtimberslice3"})
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:palmtimberslice3" then
                c.set_node(pos, {name = "nh_nodes:palmcampfire"})
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing) -- Comportamento normal de colocação para outros casos
    end,
})
-- Lenha de coqueiro 1 - 1/4 firewood
c.register_node("nh_nodes:palmtimberslice1", {
    description = S "Firewood on the Campfire 1/4",
    drawtype = "mesh",
    mesh = "oaktimberslice1.obj",
    tiles = {"palmcampfire.png"},
    groups = {oddly_breakable_by_hand = 1},
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:palmtimberslice"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:palmtimberslice1" and itemstack:get_name() == "nh_nodes:palmtimberslice" then
                c.set_node(pos, {name = "nh_nodes:palmtimberslice2"})
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})
-- Lenha de coqueiro 2 - 2/4 firewood
c.register_node("nh_nodes:palmtimberslice2", {
    description = S "Firewood on the Campfire 2/4",
    drawtype = "mesh",
    mesh = "oaktimberslice2.obj",
    tiles = {"palmcampfire.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:palmtimberslice 2"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:palmtimberslice2" and itemstack:get_name() == "nh_nodes:palmtimberslice" then
                c.set_node(pos, {name = "nh_nodes:palmtimberslice3"})
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})
-- Lenha de coqueiro 3 - 3/4 firewood
c.register_node("nh_nodes:palmtimberslice3", {
    description = S "Firewood on the Campfire 3/4",
    drawtype = "mesh",
    mesh = "oaktimberslice3.obj",
    tiles = {"palmcampfire.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:palmtimberslice 3"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then return itemstack end
        local pos = pointed_thing.under
        local node = c.get_node(pos)
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:palmtimberslice3" and itemstack:get_name() == "nh_nodes:palmtimberslice" then
                c.set_node(pos, {name = "nh_nodes:palmcampfire"})
                itemstack:take_item()
                return itemstack
            end
        end
        return c.item_place(itemstack, placer, pointed_thing)
    end,
})
-- Fogueira (estágio final) - Campfire - 4/4 firewood
register_craft_station("nh_nodes:palmcampfire", {
    description = S "Campfire",
    drawtype = "mesh",
    mesh = "oaktimberslice4.obj",
    tiles = {"palmcampfire.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {choppy = 3, oddly_breakable_by_hand = 1},
    stack_max = 1,
    drop = {items = {{items = {"nh_nodes:palmtimberslice 4"}}, {items = {"nh_nodes:campfiretinder"}},}},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }},
    title = "Produção 2x2 na Fogueira", -- Campo obrigatório!
    grid_size = 4,
    positions = {
        { x = -0.4, y = 0.2, z = -0.25 }, { x = 0.4, y = 0.2, z = -0.25 },
        { x = -0.4, y = 0.2, z = 0.25 }, { x = 0.4, y = 0.2, z = 0.25 }},
    tool_slot_pos = { x = 3.1, y = 1 }, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.4, 0),
    layers = {{name = S "2x2 Grid", x = 0.5, width = 2, height = 2, start_index = 0}},
    recipes = recipes_campfire,
    -- Quando a fogueira é colocada, verifica se deve criar chama
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        -- Se já tiver chama marcada, cria a entidade
        if meta:get_int("has_flame") == 1 then
            c.after(0.1, function()
                -- Verifica se não existe chama já
                local objs = c.get_objects_inside_radius(pos, 0.5)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:campfire_flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    local obj = c.add_entity(pos, "nh_nodes:campfire_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._straw_pos = pos end
                    end
                end
            end)
        end
    end,
    -- Quando a fogueira é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing) 
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:campfire_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._straw_pos = pos end
            end
            -- Efeito sonoro
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    can_craft = function(pos)
        local meta = c.get_meta(pos)
        if meta:get_int("has_flame") ~= 1 then return false, S "I forgot that a bonfire needs to be lit to prepare..." end
        return true
    end,
    -- Quando a fogueira for removida, remove as chamas
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:campfire_flame_entity" then obj:remove() end
        end
    end,
})

-- ENTIDADE DA CHAMA DA PALHA
c.register_entity("nh_nodes:campfire_flame_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        selectionbox = { -0.3, -0.3, -0.3, 0.3, 0.3, 0.3 },
        collisionbox = { -0.3, -0.3, -0.3, 0.3, 0.3, 0.3 },
        visual = "mesh",
        mesh = "flame.obj",
        textures = {"fire_basic_flame_animated.png"},
        visual_size = {x = 7, y = 7}, -- Menor que a chama da grama
        static_save = true,
        pointable = true,
        glow = 14,
    },
    _straw_pos = nil,
    _timer = 0,
    _anim_timer = 0,
    _current_frame = 0,
    on_activate = function(self, staticdata)
        if staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.straw_pos then self._straw_pos = data.straw_pos end
        end
        self._timer = 0
        self.object:set_sprite({x = 0, y = 0}, 1, 1, false)
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    get_staticdata = function(self) return c.serialize({ straw_pos = self._straw_pos }) end,
    -- Detecta quando é golpeado para acender tochas
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        -- Verifica se está segurando uma tocha apagada
        if wielded_name == "nh_nodes:torch" then
            wielded:take_item()
            puncher:set_wielded_item(wielded)
            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", "nh_nodes:torch2")
                if not leftover:is_empty() then
                    local pos = puncher:get_pos()
                    c.add_item(pos, leftover)
                end
            end
            c.sound_play("fire_flint_and_steel", {pos = self.object:get_pos(), gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    on_step = function(self, dtime)
        self._timer = self._timer + dtime
        self._anim_timer = self._anim_timer + dtime
        -- Anima a textura
        if self._anim_timer > (1.0 / 8) then
            self._anim_timer = 0
            self._current_frame = (self._current_frame + 1) % 8
            self.object:set_texture_mod("^[verticalframe:8:" .. self._current_frame)
        end
        -- Verifica se a palha ainda existe
        if self._timer > 0.5 then
            self._timer = 0
            if not self._straw_pos then self.object:remove() return end
            local node = c.get_node(self._straw_pos)
            -- Se a palha foi removida, remove a chama
            if node.name ~= "nh_nodes:campfire" and node.name ~= "nh_nodes:pinecampfire" and node.name ~= "nh_nodes:palmcampfire"
                then self.object:remove() return end
            -- Verifica se ainda deve ter chama
            local meta = c.get_meta(self._straw_pos)
            if meta:get_int("has_flame") ~= 1 then self.object:remove() return end
        end
    end,
})

c.register_node("nh_nodes:spinningtop", {
    description = S "Oak Spinningtop" .. "\n" .. S "[Battle Toy]",
    drawtype = "mesh",
    mesh = "piao.obj",
    tiles = { "oakpiao.png" },
    inventory_image = "oakpiaoinv.png",
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}},
    wielded_bone_position = {pos = {x = -0.25, y = 0.5, z = 0}, rot = {x = 0, y = 0, z = 45}}, -- Configuração mão direita
    wielded_visual_size = xyz(0.25),
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.above -- posição onde vai spawnar
        -- Spawna o mob
        local mob = c.add_entity(pos, "nh_mob:spinningtop")
        if mob then
            -- Aplica a rotação do jogador ao mob
            if placer then local yaw = placer:get_look_horizontal() mob:set_yaw(yaw) end
            itemstack:take_item() -- Consome o item da mão
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:spinningtop2", {
    description = S "Palm Spinningtop" .. "\n" .. S "[Battle Toy]",
    drawtype = "mesh",
    mesh = "piao.obj",
    tiles = { "palmpiao.png" },
    inventory_image = "palmpiaoinv.png",
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}},
    -- Configuração mão direita
    wielded_bone_position = {pos = {x = -0.25, y = 0.5, z = 0}, rot = {x = 0, y = 0, z = 45}},
    wielded_visual_size = xyz(0.25),
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.above -- posição onde vai spawnar
        -- Spawna o mob
        local mob = c.add_entity(pos, "nh_mob:spinningtop2")
        if mob then
            -- Aplica a rotação do jogador ao mob
            if placer then local yaw = placer:get_look_horizontal() mob:set_yaw(yaw) end
            itemstack:take_item() -- Consome o item da mão
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:spinningtop3", {
    description = S "Pine Spinningtop" .. "\n" .. S "[Battle Toy]",
    drawtype = "mesh",
    mesh = "piao.obj",
    tiles = { "pinepiao.png" },
    inventory_image = "pinepiaoinv.png",
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 }},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 }},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(-0.25, 0.5, 0), rot = xyz(0, 0, 45)},
    wielded_visual_size = xyz(0.25),
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.above -- posição onde vai spawnar
        -- Spawna o mob
        local mob = c.add_entity(pos, "nh_mob:spinningtop3")
        if mob then
            -- Aplica a rotação do jogador ao mob
            if placer then local yaw = placer:get_look_horizontal() mob:set_yaw(yaw) end
            itemstack:take_item() -- Consome o item da mão
        end
        return itemstack
    end,
})

-- Bancada de Produção 2x2x2 (original)
register_craft_station("nh_nodes:craft_table", {
    description = S "Production Bench",
    drawtype = "mesh",
    mesh = "craft_table.obj",
    tiles = {"craft_table.png"},
    title = "Bancada de Produção 2x2x2",
    grid_size = 8,
    paramtype = "light",
    paramtype2 = "facedir",
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
    positions = {
        xyz(-0.2, 0.7, -0.2), xyz(0.2, 0.7, -0.2),
        xyz(-0.2, 0.7,  0.2), xyz(0.2, 0.7,  0.2),
        xyz(-0.2, 1.1, -0.2), xyz(0.2, 1.1, -0.2),
        xyz(-0.2, 1.1,  0.2), xyz(0.2, 1.1,  0.2)},
    show_tool_display = true,         -- false para não exibir (padrão: não exibe)
    tool_position = xyz(0, 0, 0),     -- posição relativa ao node
    tool_slot_pos = {x = 5.6, y = 1}, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.7, 0),
    layers = {
        {name = "Camada Inferior", x = 0.5, width = 2, height = 2, start_index = 0},
        {name = "Camada Superior", x = 3,   width = 2, height = 2, start_index = 4}},
    recipes = recipes_table
})

-- Bancada Avançada 3x3x3 simples
register_craft_station("nh_nodes:advanced_bench", {
    description = S"Advanced Bench",
    drawtype = "mesh",
    mesh = "craft_table.obj",
    tiles = {"craft_table2.png"},
    title = S"3x3 Advanced Bench",
    grid_size = 9,
    paramtype = "light",
    paramtype2 = "facedir",
    item_visual_size = {x = 0.15, y = 0.15},
    positions = {
        xyz(-0.25, 0.61, -0.25), xyz(0, 0.61, -0.25), xyz(0.25, 0.61, -0.25),
        xyz(-0.25, 0.61, 0),     xyz(0, 0.61, 0),     xyz(0.25, 0.61, 0),
        xyz(-0.25, 0.61, 0.25),  xyz(0, 0.61, 0.25),  xyz(0.25, 0.61, 0.25)},
    show_tool_display = true,         -- false para não exibir (padrão: não exibe)
    tool_position = xyz(0, 0, 0),     -- posição relativa ao node
    tool_slot_pos = {x = 4.3, y = 1}, -- ajusta x e y até ficar no lugar certo
    output_position = xyz(0, 1.2, 0),
    layers = {{name = S"3x3 Grid", x = 0.5, width = 3, height = 3, start_index = 0}},
    recipes = recipes_table2
})

c.register_entity("nh_nodes:furnace_flame_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        selectionbox = { -0.3, -0.5, -0.3, 0.3, 0.5, 0.3 },
        collisionbox = { -0.3, -0.5, -0.3, 0.3, 0.5, 0.3 },
        visual = "mesh",
        mesh = "torchflame.obj",      -- reutiliza a mesh da tocha, troca se tiver uma específica
        textures = {"fire_basic_flame_animated.png"},
        visual_size = {x = 20, y = 5},
        static_save = true,
        pointable = false,
        glow = 14,
    },
    _furnace_pos = nil,
    _timer = 0,
    _anim_timer = 0,
    _current_frame = 0,
    on_activate = function(self, staticdata)
        if staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.furnace_pos then self._furnace_pos = data.furnace_pos end
        end
        self._timer = 0
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    get_staticdata = function(self) return c.serialize({furnace_pos = self._furnace_pos}) end,
    on_step = function(self, dtime)
        self._timer = self._timer + dtime
        self._anim_timer = self._anim_timer + dtime
        if self._anim_timer > (1.0 / 8) then
            self._anim_timer = 0
            self._current_frame = (self._current_frame + 1) % 8
            self.object:set_texture_mod("^[verticalframe:8:" .. self._current_frame)
        end
        if self._timer > 0.5 then
            self._timer = 0
            if not self._furnace_pos then self.object:remove() return end
            local node = c.get_node(self._furnace_pos)
            if node.name ~= "nh_nodes:furnace" then self.object:remove() return end
            -- Verifica combustível no slot tool
            local meta = c.get_meta(self._furnace_pos)
            local inv = meta:get_inventory()
            local fuel = inv:get_stack("tool", 1):get_name()
            if fuel ~= "nh_nodes:coalnugget" and fuel ~= "nh_nodes:charcoalnugget" then
                meta:set_int("has_flame", 0)  -- apaga o estado também
                self.object:remove()
                return
            end
        end
    end,
})

-- Fornalha 3x3 simples
register_craft_station("nh_nodes:furnace", {
    description = S"Furnace",
    title = S"3x3 Furnace",
    drawtype = "mesh",
    mesh = "furnace.obj",
    tiles = {"cobblestone_furnace.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.5}},
    wielded_bone_position = {pos = xyz(-2.5, -1, 0)},
    offhand_bone_position = {pos = xyz(-1.5, -1, 0)},
    grid_size = 9,
    positions = {
        xyz(-0.3, 0.9, -0.3), xyz(0, 0.9, -0.3), xyz(0.3, 0.9, -0.3),
        xyz(-0.3, 0.9, 0),    xyz(0, 0.9, 0),    xyz(0.3, 0.9, 0),
        xyz(-0.3, 0.9, 0.3),  xyz(0, 0.9, 0.3),  xyz(0.3, 0.9, 0.3)},
    show_tool_display = true,
    tool_position = xyz(0, 0.8, 0),
    tool_slot_pos = {x = 4.3, y = 1},
    output_position = xyz(0, 1.2, 0),
    layers = {{name = S"3x3 Grid", x = 0.5, width = 3, height = 3, start_index = 0}},
    recipes = recipes_furnace,
    -- Recria a chama ao carregar o chunk se já estava acesa
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        if meta:get_int("has_flame") == 1 then
            c.after(0.1, function()
                local objs = c.get_objects_inside_radius(pos, 1)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:furnace_flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    local obj = c.add_entity(pos, "nh_nodes:furnace_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._furnace_pos = pos end
                    end
                end
            end)
        end
    end,
    -- Acende com nh_nodes:torch2 (clicando na fornalha com a tocha na mão)
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local meta = c.get_meta(pos)
        -- Se já está acesa, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        local wielded = puncher:get_wielded_item()
        if wielded:get_name() == "nh_nodes:torch2" then
            meta:set_int("has_flame", 1)
            -- Posiciona a chama na boca da fornalha (ajuste o offset conforme o modelo)
            local flame_pos = vector.add(pos, xyz(0, 0.9, 0))
            local obj = c.add_entity(flame_pos, "nh_nodes:furnace_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._furnace_pos = pos end
            end
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    -- Bloqueia o output se não tiver chama OU se o slot tool estiver vazio/errado
    can_craft = function(pos)
        local meta = c.get_meta(pos)
        -- Verifica chama
        if meta:get_int("has_flame") ~= 1 then return false, S"The furnace needs to be lit with a torch first..." end
        -- Verifica combustível no slot tool
        local inv = meta:get_inventory()
        local tool_stack = inv:get_stack("tool", 1)
        local fuel = tool_stack:get_name()
        if fuel ~= "nh_nodes:coalnugget" and fuel ~= "nh_nodes:charcoalnugget" then
            return false, S"The furnace needs coal nuggets or charcoal nuggets as fuel..."
        end
        return true
    end,
    -- Remove a chama ao destruir a fornalha
    on_destruct = function(pos)
        local objs = c.get_objects_inside_radius(pos, 1)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:furnace_flame_entity" then obj:remove() end
        end
    end,
})

-- Prancha
c.register_node("nh_nodes:oakplank", {
    description = S "Oak Plank",
    drawtype = "mesh",
    mesh = "oakplank.obj",
    tiles = { "oakwood.png" },
    groups = { choppy = 3 },
    paramtype = "light",
    paramtype2 = "wallmounted",
    wielded_bone_position = {pos = {x = -0.5, y = -0.9, z = 0.2}}, -- Configuração mão direita
    offhand_bone_position = {pos = {x = 0, y = -0.9, z = -1}}, -- Configuração mão esquerda
    selection_box = {type = "wallmounted",
        wall_top = { -0.5, 0, -0.5, 0.5, 0.5, 0.5 },
        wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
        wall_side = { -0.5, -0.5, -0.5, 0, 0.5, 0.5 },},
    node_box = {type = "wallmounted",
        wall_top = { 0, 0, 0, 0, 0.5, 0 },
        wall_bottom = { 0, -0.5, 0, 0, 0, 0 },
        wall_side = { -0.5, 0, 0, -0.5, 0.5, 0 },},
})

-- Tábua
c.register_node("nh_nodes:oakboard", {
    description = S "Oak Board",
    drawtype = "mesh",
    mesh = "oakboard.obj",
    tiles = { "oakwood.png" },
    groups = { choppy = 3 },
    paramtype = "light",
    paramtype2 = "facedir",
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, 0.38, 0.5, 0.5, 0.5 },},
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.03, 0.5, 0.5, 0.5 },},
    wielded_bone_position = {pos = { x = 0, y = -0.9, z = -0.8 }}, -- Configuração mão direita
    offhand_bone_position = {pos = { x = 0, y = -0.9, z = -1.2 }}, -- Configuração mão esquerda
    on_place = function(itemstack, placer, pointed_thing)
        if not placer or not placer:is_player() then return itemstack end
        -- Detecta em qual face foi clicado
        local under = pointed_thing.under
        local above = pointed_thing.above
        local click_dir = vector.subtract(above, under)
        -- Pega a direção horizontal do jogador
        local yaw = placer:get_look_horizontal()
        local player_dir = c.yaw_to_dir(yaw)
        local player_facedir = c.dir_to_facedir(player_dir)
        local facedir
        if click_dir.y == 1 then facedir = player_facedir -- Clicado no topo (chão) - tábua em pe com a lateral fina pra mim
        elseif click_dir.y == -1 then facedir = player_facedir + 20 -- Clicado embaixo (teto) - tábua deitada invertida
        elseif click_dir.z ~= 0 then
            -- Parede Norte/Sul (eixo Z)
            local wall_facedir = c.dir_to_facedir(click_dir)
            facedir = wall_facedir + 4
        else
            -- Parede Leste/Oeste (eixo X)
            local wall_facedir = c.dir_to_facedir(click_dir)
            facedir = wall_facedir + 12 -- Valor diferente para paredes X
        end
        return c.item_place(itemstack, placer, pointed_thing, facedir)
    end,
})

-- Tarugo
c.register_node("nh_nodes:oakdowel", {
    description = S "Oak Dowel" .. "\n" .. S "Reach: +2",
    drawtype = "mesh",
    mesh = "oakdowel.obj",
    tiles = { "oakwood.png" },
    groups = {choppy = 2},
    range = 5,
    paramtype = "light",
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted",
        wall_top = {-0.1, -0.5, -0.1, 0.1, 0.5, 0.1},
        wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.5, 0.1},
        wall_side = {-0.5, -0.1, -0.1, 0.5, 0.1, 0.1}},
    node_box = {type = "wallmounted",
        wall_top = {-0.0625, 0.5 - 0.5625, -0.0625, 0.0625, 0.5, 0.0625},
        wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5 + 0.5625, 0.0625},
        wall_side = {-0.5, -0.0625, -0.0625, -0.5 + 0.28125, 0.5, 0.0625}},
})

c.register_node("nh_nodes:torch", {
    description = S "Torch",
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = { "torch.png" },
    --inventory_image = "tocha_inventario.png",
    --wield_image = "tocha_inventario.png",
    paramtype = "light",
    --paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    groups = { choppy = 2, oddly_breakable_by_hand = 3, flammable = 1 }, -- dig_immediate = 1, attached_node = 1
    collision_box = {type = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}},
    selection_box = {type = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}},
    --selection_box = {type = "wallmounted",
    --    wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
    --    wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
    --     wall_side = {-0.5, -0.1, -0.1, -0.5+0.3, 0.5, 0.1},
    --},
    --node_box = { type = "wallmounted",
    --    wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
    --    wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
    --    wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},
    --},
    -- Quando bater na tocha apagada com tocha acesa ou flame
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        -- Verifica se está batendo com tocha acesa ou flame
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Pega a orientação (facedir/wallmounted) da tocha apagada
            local param2 = node.param2
            -- Troca para tocha acesa mantendo a orientação
            c.set_node(pos, {name = "nh_nodes:torch2", param2 = param2})
            -- Adiciona a chama como entidade (mesmo código do after_place_node)
            local flame_pos = xyz(pos.x, pos.y + 1, pos.z)
            local obj = c.add_entity(flame_pos, "nh_nodes:torch_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._torch_pos = pos end
            end
            -- Efeito sonoro de acender fogo
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
            -- Partículas de faísca (opcional)
            c.add_particlespawner({
                amount = 5,
                time = 0.1,
                minpos = vector.subtract(pos, xyz(0.1)),
                maxpos = vector.add(pos, xyz(0.1, 0.3, 0.1)),
                minvel = xyz(-0.5, 0.5, -0.5),
                maxvel = xyz(0.5, 1.5, 0.5),
                minacc = xyz(0, -2, 0),
                maxacc = xyz(0, -1, 0),
                minexptime = 0.1,
                maxexptime = 0.3,
                minsize = 0.5,
                maxsize = 1,
                glow = 14,
                texture = "spark_particle.png^[colorize:#FF8800:150",
            })
        end
    end,
})

c.register_node("nh_nodes:torch2", {
    description = S "Torch Lit",
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = {"torchfire.png"}, -- Textura da madeira/base
    --inventory_image = "tocha_inventario.png",
    --wield_image = "tocha_inventario.png",
    paramtype = "light",
    --paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    stack_max = 1,                                                       -- limita a 1 tocha acesa por slot
    light_source = 13,                                                   -- Luminosidade (0-14, onde 14 é máximo)
    groups = { choppy = 2, oddly_breakable_by_hand = 3, flammable = 1 }, -- REMOVIDO: attached_node = 1, dig_immediate = 3
    collision_box = {type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, 0.37, 0.1 }},
    selection_box = {type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, 0.37, 0.1 }},
    --selection_box = {type = "wallmounted",
    --    wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
    --    wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
    --    wall_side = {-0.5, -0.1, -0.1, -0.5+0.3, 0.5, 0.1},},
    --node_box = {type = "wallmounted",
    --    wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
    --    wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
    --    wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},},
    -- Quando colocada, adiciona a chama no mesmo lugar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        -- Posição da chama (1 bloco acima)
        local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        -- Cria a ENTIDADE da chama
        local obj = c.add_entity(flame_pos, "nh_nodes:torch_flame_entity")
        if obj then
            local ent = obj:get_luaentity()
            if ent then ent._torch_pos = pos end
        end
    end,
    -- Quando a tocha é destruída, remove a entidade da chama
    after_destruct = function(pos)
        local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        local objs = c.get_objects_inside_radius(flame_pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:torch_flame_entity" then obj:remove() end
        end
    end,
})
-- Node invisível que emite luz
c.register_node("nh_nodes:torch_light", {
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    buildable_to = true,
    light_source = 13,
    groups = { not_in_creative_inventory = 1 },
})

-- Registra a entidade de luz
c.register_node("nh_nodes:crystal_light", {
    drawtype = "airlike", -- invisível, não cria bolsão
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    buildable_to = true,
    light_source = 13,
    groups = { not_in_creative_inventory = 1 },
})

c.register_node("nh_nodes:torch_flame", {
    description = "Torch Flame",
    drawtype = "mesh",
    mesh = "torchflame2.obj",
    tiles = {{name = "fire_basic_flame_animated.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.0},}},
    stack_max = 1,               -- limita a 1 tocha acesa por slot
    light_source = 10,
    paramtype = "light",
    paramtype2 = "facedir",     
    sunlight_propagates = true,
    use_texture_alpha = "blend", 
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    damage_per_second = 4,
    groups = { not_in_creative_inventory = 1 },
    drop = "",
})

-- ENTIDADE DA CHAMA DA TOCHA
c.register_entity("nh_nodes:torch_flame_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        -- Selection box maior e melhor posicionada
        selectionbox = {-0.2, -0.7, -0.2, 0.2, -0.3, 0.2},
        collisionbox = {-0.2, -0.7, -0.2, 0.2, -0.3, 0.2},
        visual = "mesh",
        mesh = "torchflame.obj",
        textures = {"fire_basic_flame_animated.png"},
        visual_size = {x = 10, y = 10},
        static_save = true,
        pointable = true,
        glow = 14,
    },
    _torch_pos = nil,
    _timer = 0,
    _anim_timer = 0,
    _current_frame = 0,
    on_activate = function(self, staticdata)
        if staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.torch_pos then self._torch_pos = data.torch_pos end
        end
        self._timer = 0
        -- Configura a animação da textura
        self.object:set_sprite({x = 0, y = 0}, 1, 1.0, false)
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    get_staticdata = function(self) return c.serialize({torch_pos = self._torch_pos}) end,
    -- Detecta quando é golpeado com tocha apagada
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        -- Verifica se está segurando uma tocha apagada
        if wielded_name == "nh_nodes:torch" then
            -- Remove a tocha apagada do inventário
            wielded:take_item()
            puncher:set_wielded_item(wielded)
            -- Adiciona a tocha acesa ao inventário
            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", "nh_nodes:torch2")
                -- Se o inventário estiver cheio, dropa no chão
                if not leftover:is_empty() then
                    local pos = puncher:get_pos()
                    c.add_item(pos, leftover)
                end
            end
            -- Efeito sonoro
            c.sound_play("fire_flint_and_steel", {pos = self.object:get_pos(), gain = 0.5, max_hear_distance = 8}, true)
            -- Partículas de faísca
            c.add_particlespawner({
                amount = 5,
                time = 0.1,
                minpos = vector.subtract(self.object:get_pos(), { x = 0.1, y = 0.1, z = 0.1 }),
                maxpos = vector.add(self.object:get_pos(), { x = 0.1, y = 0.1, z = 0.1 }),
                minvel = { x = -0.5, y = 0.5, z = -0.5 },
                maxvel = { x = 0.5, y = 1.5, z = 0.5 },
                minacc = { x = 0, y = -2, z = 0 },
                maxacc = { x = 0, y = -1, z = 0 },
                minexptime = 0.1,
                maxexptime = 0.3,
                minsize = 0.5,
                maxsize = 1,
                glow = 14,
                texture = "spark_particle.png^[colorize:#FF8800:150",
            })
        end
    end,
    on_step = function(self, dtime)
        self._timer = self._timer + dtime
        self._anim_timer = self._anim_timer + dtime
        -- Anima a textura (8 frames, 1 segundo de duração total)
        if self._anim_timer > (1.0 / 8) then
            self._anim_timer = 0
            self._current_frame = (self._current_frame + 1) % 8
            self.object:set_texture_mod("^[verticalframe:8:" .. self._current_frame)
        end
        -- Verifica se a tocha ainda existe
        if self._timer > 0.5 then
            self._timer = 0
            if not self._torch_pos then self.object:remove() return end
            local node = c.get_node(self._torch_pos)
            -- Se a tocha foi removida ou apagada, remove a chama
            if node.name ~= "nh_nodes:torch2" then self.object:remove() return end
        end
    end,
})

local portal_particles = {}
local linked_portals = {} -- Armazena os portais colocados
local storage = c.get_mod_storage() -- PERSISTÊNCIA
local mob_portal_cooldown = {} -- cooldown por entidade (usando ID do objeto) - para mobs
local function save_portals()
    local list = {}
    for _, p in ipairs(linked_portals) do
        table.insert(list, p.x .. "," .. p.y .. "," .. p.z)
    end
    storage:set_string("linked_portals", table.concat(list, ";"))
end
local function load_portals()
    linked_portals = {}
    local raw = storage:get_string("linked_portals")
    if raw == "" then return end
    for entry in raw:gmatch("[^;]+") do
        local x, y, z = entry:match("(-?%d+),(-?%d+),(-?%d+)")
        if x then table.insert(linked_portals, {x=tonumber(x), y=tonumber(y), z=tonumber(z)}) end
    end
end
load_portals() -- Carrega ao iniciar o mod
-- Recria partículas nos portais salvos ao iniciar
c.register_on_joinplayer(function(player)
    -- Pequeno delay pra garantir que os chunks carregaram
    c.after(3, function()
        -- Filtra portais que sumiram enquanto o servidor estava offline
        local valid = {}
        for _, pos in ipairs(linked_portals) do
            if c.get_node(pos).name == "nh_nodes:portal" then table.insert(valid, pos) end
        end
        -- Se algum portal sumiu, atualiza a lista salva
        if #valid ~= #linked_portals then linked_portals = valid
            save_portals()
        end
        -- Recria partículas só nos que ainda não têm spawner ativo
        for _, pos in ipairs(linked_portals) do
            local key = pos.x .. "," .. pos.y .. "," .. pos.z
            if not portal_particles[key] then
                portal_particles[key] = c.add_particlespawner({
                    amount = 25,
                    time = 0,
                    minpos = vector.subtract(pos, 0.25),
                    maxpos = vector.add(pos, 0.25),
                    minvel = xyz(-0.5, -0.5, -0.5),
                    maxvel = xyz(0.5, 0.5, 0.5),
                    minsize = 0.1,
                    maxsize = 0.2,
                    texture = "spark_particle.png^[colorize:#028dde:200^[opacity:120",
                    glow = 7
                })
            end
        end
    end)
end)
local function get_portal_front(pos, node)
    local dir = facedir_to_dir[node.param2 % 4] -- % 4 ignora rotações verticais
    if not dir then dir = {x=0, y=0, z=1} end
    return vector.add(pos, vector.multiply(dir, 1.2)) -- 1.2 nodes à frente
end
-- Bloco do portal normal
c.register_node("nh_nodes:portal", {
    description = "Portal",
    drawtype = "nodebox",
    tiles = {"blank.png", "blank.png", "blank.png", "blank.png", "blank.png",
        {name = "portal2_animated.png^[brighten",
        backface_culling = false,
        animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.5}}},
    overlay_tiles = {"", "", "", "", "",
        {name = "portal2_animated.png^[opacity:220",
        backface_culling = false,
        animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.5 }}},
    use_texture_alpha = "blend",
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    pointable = true,
    node_box = {type = "fixed", fixed = {-0.5, -0.5, 0.48, 0.5, 0.5, 0.5},}, -- plano fino
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, 0.5, 0.5, 1, 1}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, 0.48, 0.5, 0.5, 0.5}},
    light_source = 3,
    post_effect_color = { a = 150, r = 0, g = 0, b = 50 },
    pointable = true,
    groups = { cracky = 1, oddly_breakable_by_hand = 1 },
    on_construct = function(pos)
        -- Adiciona o portal à lista
        table.insert(linked_portals, pos)
        save_portals()  -- salva portais
        if #linked_portals == 2 then c.chat_send_all(S"[Connected Portals]") end -- Se houver dois portais, conectá-los
        local key = pos.x .. "," .. pos.y .. "," .. pos.z
        -- Efeito de partículas
        local spawner_id = c.add_particlespawner({
            amount = 25,
            time = 0,
            minpos = vector.subtract(pos, 0.25),
            maxpos = vector.add(pos, 0.25),
            minvel = xyz(-0.5, -0.5, -0.5),
            maxvel = xyz(0.5, 0.5, 0.5),
            minsize = 0.1,
            maxsize = 0.2,
            texture = "spark_particle.png^[colorize:#028dde:200^[opacity:120", -- opacidade completa de pintura sobre textura: 255 - hexa pra azul: #028dde
            glow = 7
        })
        portal_particles[key] = spawner_id
    end,
    on_destruct = function(pos)
        for i, p in ipairs(linked_portals) do
            if vector.equals(p, pos) then table.remove(linked_portals, i) break end
        end
        save_portals()  -- salva portais
        local key = pos.x .. "," .. pos.y .. "," .. pos.z
        if portal_particles[key] then
            c.delete_particlespawner(portal_particles[key])
            portal_particles[key] = nil
        end
    end,
})
c.register_globalstep(function(dtime)
    for _, player in ipairs(c.get_connected_players()) do
        local name = player:get_player_name()
        -- Cooldown
        if portal_cooldown[name] then
            portal_cooldown[name] = portal_cooldown[name] - dtime
            if portal_cooldown[name] <= 0 then portal_cooldown[name] = nil end
            goto continue
        end
        local pos = player:get_pos()
        -- Centro aproximado do player (pés + 0.9 = centro do corpo)
        local player_center = {x = pos.x, y = pos.y + 0.9, z = pos.z}
        for _, portal_pos in ipairs(linked_portals) do
            -- Checa se o player está dentro do voxel do portal (±0.5 em cada eixo)
            if math.abs(player_center.x - portal_pos.x) <= 0.5 and
               math.abs(player_center.y - portal_pos.y) <= 2.5 and
               math.abs(player_center.z - portal_pos.z) <= 0.5 then
                if #linked_portals < 2 then break end
                -- Acha o portal de destino
                local target_pos
                if vector.equals(portal_pos, linked_portals[1]) then target_pos = linked_portals[2]
                else target_pos = linked_portals[1] end
                local target_node = c.get_node(target_pos)
                local dir = facedir_to_dir[target_node.param2 % 4] or {x=0, y=0, z=1}
                local spawn = vector.add(target_pos, vector.multiply(dir, 1))
                local function dir_to_yaw(d) return math.atan2(-d.x, d.z) end
                player:set_look_horizontal(dir_to_yaw(dir))
                player:set_pos(spawn)
                c.chat_send_player(name, S "I entered the portal!")
                c.sound_play("vortex", {pos = portal_pos, gain = 0.1})
                portal_cooldown[name] = 3.0 -- segundos de cooldown após teleporte
                break
            end
        end
        ::continue::
    end
end)
-- TELEPORTE DE MOBS e drops NO PORTAL
c.register_globalstep(function(dtime)
    if #linked_portals < 2 then return end
    for id, timer in pairs(mob_portal_cooldown) do
        mob_portal_cooldown[id] = timer - dtime
        if mob_portal_cooldown[id] <= 0 then mob_portal_cooldown[id] = nil end
    end
    for _, portal_pos in ipairs(linked_portals) do
        if c.get_node(portal_pos).name ~= "nh_nodes:portal" then goto next_portal end
        local objects = c.get_objects_inside_radius(portal_pos, 1.0)
        for _, obj in ipairs(objects) do
            if obj:is_player() then goto next_obj end
            local lua = obj:get_luaentity()
            if not lua then goto next_obj end
            local is_mob = lua.type == "monster" or lua.type == "animal" or lua.type == "npc"
            local is_item = lua.name == "__builtin:item"
            if not is_mob and not is_item then goto next_obj end
            local obj_id = tostring(obj)
            if mob_portal_cooldown[obj_id] then goto next_obj end
            local target_pos
            if vector.equals(portal_pos, linked_portals[1]) then target_pos = linked_portals[2]
            else target_pos = linked_portals[1] end
            local target_node = c.get_node(target_pos)
            local dir = facedir_to_dir[target_node.param2 % 4] or {x=0, y=0, z=1}
            local spawn = vector.add(target_pos, vector.multiply(dir, 1))
            obj:set_pos(spawn)
            if is_mob then c.sound_play("vortex", {pos = portal_pos, gain = 0.1}) end
            mob_portal_cooldown[obj_id] = 3.0
            ::next_obj::
        end
        ::next_portal::
    end
end)

c.register_node("nh_nodes:flame", {
    description = "Flame",
    drawtype = "mesh",
    mesh = "flame.obj", -- Você precisará criar esse mesh
    tiles = {{name = "fire_basic_flame_animated.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1}}},
    light_source = 14,
    paramtype = "light",
    paramtype2 = "facedir",      
    sunlight_propagates = true,
    use_texture_alpha = "blend", 
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    damage_per_second = 4,
    groups = { not_in_creative_inventory = 1 },
    drop = "",
})

c.register_node("nh_nodes:torch3", {
    description = S"Torch Extinguished",
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = { "torch3.png" },
    --inventory_image = "tocha_inventario.png",
    --wield_image = "tocha_inventario.png",
    --paramtype = "light",
    --paramtype2 = "wallmounted",
    --sunlight_propagates = true,
    walkable = false,
    groups = { choppy = 2, oddly_breakable_by_hand = 3, flammable = 1 }, -- dig_immediate = 3, attached_node = 1
    collision_box = {type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, 0.37, 0.1 }},
    selection_box = {type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, 0.37, 0.1 }},
    --selection_box = {type = "wallmounted",
    --    wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
    --    wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
    --     wall_side = {-0.5, -0.1, -0.1, -0.5+0.3, 0.5, 0.1},},
    --node_box = {type = "wallmounted",
    --    wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
    --    wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
    --    wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},},
})

-- Folhas de carvalho
c.register_node("nh_nodes:leaves", {
    description = S "Oak Leaves",
    drawtype = "liquid",
    waving = 3,
    --drawtype = "mesh",
    -- mesh = "oakleaves.obj",
    tiles = { "oakleaves3.png" },
    groups = { snappy = 3, tree_leaves = 1 },
    drop = {items = {{ items = { "nh_nodes:limb" } },{ items = { "nh_nodes:oakresin" } },}},
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves",
    liquid_alternative_source = "nh_nodes:leaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
})

-- Registra uma versão "dentro d'água" (da folha de carvalho)
c.register_node("nh_nodes:leavesrelief", {
    description = S "Leaves Relief",
    drawtype = "plantlike_rooted",
    waving = 3,
    tiles = { "oakleaves3.png" },
    special_tiles = { { name = "leavesrelief.png", tileable_vertical = true } },
    inventory_image = "leavesrelief.png",
    wield_image = "leavesrelief.png",
    paramtype = "light",
    paramtype2 = "leveled",
    use_texture_alpha = "clip",
    groups = { snappy = 3, tree_leaves = 1 },
    walkable = false,
    drop = "", -- não dropa nada
    node_dig_prediction = "",
    node_placement_prediction = "",
    after_dig_node = function(pos, oldnode, oldmetadata, digger) c.set_node(pos, {name = "nh_nodes:leaves"}) end,
    on_construct = function(pos) c.get_node_timer(pos):start(1.0) end,
    on_timer = function(pos)
        local node = c.get_node(pos)
        if node.name ~= "nh_nodes:leavesrelief" then return false end
        -- O node "pai" do plantlike_rooted é o de BAIXO
        local below = {x = pos.x, y = pos.y + 2, z = pos.z}
        local below_name = c.get_node(below).name
        if below_name ~= "nh_nodes:leaves" and below_name ~= "nh_nodes:leavesrelief" then
            c.remove_node(pos)
            return false
        end
        return true
    end,
})

c.register_node("nh_nodes:leavesrelief", {
    description = S "Leaves Relief",
    drawtype = "plantlike_rooted",
    waving = 3,
    tiles = { "oakleaves3.png" },
    special_tiles = { { name = "leavesrelief.png", tileable_vertical = true } },
    inventory_image = "leavesrelief.png",
    wield_image = "leavesrelief.png",
    paramtype = "light",
    paramtype2 = "leveled",
    use_texture_alpha = "clip",
    groups = { snappy = 3, tree_leaves = 1 },
    walkable = false,
    drop = "", -- não dropa nada
    node_dig_prediction = "",
    node_placement_prediction = "",
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        c.set_node(pos, { name = "nh_nodes:leaves" })
    end,
    on_construct = function(pos)
        c.get_node_timer(pos):start(1.0)
    end,
    on_timer = function(pos)
        local node = c.get_node(pos)
        if node.name ~= "nh_nodes:leavesrelief" then return false end
        -- O node "pai" do plantlike_rooted é o de BAIXO
        local below = { x = pos.x, y = pos.y + 2, z = pos.z }
        local below_name = c.get_node(below).name
        if below_name ~= "nh_nodes:leaves" and below_name ~= "nh_nodes:leavesrelief" then
            c.remove_node(pos)
            return false
        end
        return true
    end,
})

c.register_node("nh_nodes:kelp", {
    description = S "Kelp" .. "\n" .. S "[Algae]",
    drawtype = "plantlike_rooted",
    waving = 1,
    tiles = { "areia_molhada.png" },
    special_tiles = { { name = "kelp.png", tileable_vertical = true } },
    inventory_image = "kelp.png",
    wield_image = "kelp.png",
    paramtype = "light",
    paramtype2 = "leveled",
    groups = { snappy = 3 },
    selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, {-0.125, 0.5, -0.125, 0.125, 3.5, 0.125},},},
    node_dig_prediction = "nh_nodes:wet_sand",
    node_placement_prediction = "nh_nodes:wet_sand",
    --sounds = default.node_sound_sand_defaults({
    --    dig = {name = "default_dig_snappy", gain = 0.2},
    --    dug = {name = "default_grass_footstep", gain = 0.25},
    --}),
    on_place = function(itemstack, placer, pointed_thing)
        -- Call on_rightclick if the pointed node defines it
        if pointed_thing.type == "node" and not (placer and placer:is_player()
            ) then
            local node_ptu = c.get_node(pointed_thing.under)
            local def_ptu = c.registered_nodes[node_ptu.name]
            if def_ptu and def_ptu.on_rightclick then
                return def_ptu.on_rightclick(pointed_thing.under, node_ptu, placer,
                    itemstack, pointed_thing)
            end
        end
        local pos = pointed_thing.under
        if c.get_node(pos).name ~= "nh_nodes:wet_sand" then
            return itemstack
        end
        local height = math.random(3, 6)
        local pos_top = { x = pos.x, y = pos.y + height, z = pos.z }
        local node_top = c.get_node(pos_top)
        local def_top = c.registered_nodes[node_top.name]
        local player_name = placer:get_player_name()
        if def_top and def_top.liquidtype == "source" and
            c.get_item_group(node_top.name, "water") > 0 then
            if not c.is_protected(pos, player_name) and
                not c.is_protected(pos_top, player_name) then
                c.set_node(pos, {name = "nh_nodes:kelp", param2 = height * 16})
                if not c.is_creative_enabled(player_name) then itemstack:take_item() end
            else
                c.chat_send_player(player_name, S "Node is protected")
                c.record_protection_violation(pos, player_name)
            end
        end
        return itemstack
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        c.set_node(pos, { name = "nh_nodes:wet_sand" })
    end
})

-- Folhas de pinheiro
c.register_node("nh_nodes:pineleaves", {
    description = S "Pine Leaves",
    drawtype = "mesh",
    mesh = "pineleaves.obj",
    tiles = { "pineleaves.png" },
    waving = 1,
    groups = { snappy = 3, tree_leaves = 1 },
    drop = {items = {{items = {"nh_nodes:limb"}}, {items = {"nh_nodes:oakresin"}},}},
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:pineleaves",
    liquid_alternative_source = "nh_nodes:pineleaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
})

-- Folhas de macieira
c.register_node("nh_nodes:appleleaves", {
    description = S "Apple Tree Leaves",
    drawtype = "mesh",
    mesh = "appleleaves.obj",
    tiles = { "appleleaves.png" },
    waving = 1,
    groups = { snappy = 3, tree_leaves = 1 },
    drop = {items = {{items = {"nh_nodes:stick"}},}},
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:appleleaves",
    liquid_alternative_source = "nh_nodes:appleleaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
})

-- Folhas com 1 maça
c.register_node("nh_nodes:leaves_apple", {
    description = S "Leaves with Apple",
    drawtype = "mesh",
    mesh = "leavesapple1.obj",
    tiles = { "appleleaves.png" },
    waving = 2,
    groups = { snappy = 3, tree_leaves = 1 },
    drop = {items = {{items = {"nh_nodes:apple"}}, {items = {"nh_nodes:stick"}},}},
    walkable = false,
    use_texture_alpha = "clip",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_apple",
    liquid_alternative_source = "nh_nodes:leaves_apple",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },

    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:apple") end
            -- Transforma o node em leaves_apple2
            c.set_node(pos, { name = "nh_nodes:appleleaves" })
        end
        return itemstack
    end,
})

-- Folhas com 2 maças
c.register_node("nh_nodes:leaves_apple2", {
    description = S "Leaves with 2 Apples",
    drawtype = "mesh",
    mesh = "leavesapple2.obj",
    tiles = { "appleleaves.png" },
    waving = 2,
    groups = { snappy = 3, tree_leaves = 1 },
    drop = {items = {{items = {"nh_nodes:apple 2"}}, {items = {"nh_nodes:stick"}},}},
    walkable = false,
    use_texture_alpha = "clip",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_apple2",
    liquid_alternative_source = "nh_nodes:leaves_apple2",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },

    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:apple") end
            -- Transforma o node em leaves_apple2
            c.set_node(pos, { name = "nh_nodes:leaves_apple" })
        end
        return itemstack
    end,
})

-- Folhas com 3 maças
c.register_node("nh_nodes:leaves_apple3", {
    description = S "Leaves with 3 Apples",
    drawtype = "mesh",
    mesh = "leavesapple3.obj",
    tiles = { "appleleaves.png" },
    waving = 2,
    groups = { snappy = 3, tree_leaves = 1 },
    drop = {items = {{items = {"nh_nodes:apple 3"}}, {items = {"nh_nodes:stick"}},}},
    walkable = false,
    use_texture_alpha = "clip",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_apple3",
    liquid_alternative_source = "nh_nodes:leaves_apple3",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
    wielded_bone_position = {pos = { x = 0.5, y = 0.5, z = 1.7 }},  -- Configuração mão direita
    offhand_bone_position = {pos = { x = 1, y = 0, z = 0 }}, -- Configuração mão esquerda
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:apple") end
            -- Transforma o node em leaves_apple2
            c.set_node(pos, { name = "nh_nodes:leaves_apple2" })
        end
        return itemstack
    end,
})

-- Folhas mirtilo
c.register_node("nh_nodes:blueberryleaves", {
    description = S "Blueberry Leaves",
    drawtype = "liquid",
    waving = 1,
    tiles = { "folhasmirtilo.png" },
    groups = { snappy = 3 },
    drop = "nh_nodes:stick",
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:blueberryleaves",
    liquid_alternative_source = "nh_nodes:blueberryleaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
})

-- Folhas com 4 blueberry
c.register_node("nh_nodes:leaves_blueberry4", {
    description = S "Leaves with 4 Blueberries",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = { "folhasmirtilo4.png" },
    groups = { snappy = 3 },
    drop = {items = {{ items = {"nh_nodes:blueberry 4"}}, {items = { "nh_nodes:stick"}}, }},
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_blueberry4",
    liquid_alternative_source = "nh_nodes:leaves_blueberry4",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },

    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:blueberry 4") end
            -- Transforma o node em leaves_apple2
            c.set_node(pos, { name = "nh_nodes:blueberryleaves" })
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:giantcrabstatue", {
    description = S "Giant Crab Statue" .. "\n" .. S "[Unknown]",
    drawtype = "mesh",
    mesh = "giantcrabstatue.obj",
    tiles = { "giantcrabstatue.png" }, --tiles = {{name = "giantcrabstatue.png", glow = 1}},
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { falling_node = 1 },
    light_source = 7,
    collision_box = {type = "fixed", fixed = { -1.75, -0.5, -1.5, 1.75, 3.75, 1.5 }},
    selection_box = {type = "fixed", fixed = { -1.75, -0.5, -2.5, 1.75, 3.75, 1.5 }},
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local item = puncher:get_wielded_item()
        local item_name = item:get_name()
        -- Verifica se o item na mão é a esfera (qualquer variante)
        if item_name ~= "nh_nodes:sphere" and item_name ~= "nh_nodes:sphere_placed" then
            c.chat_send_player(puncher:get_player_name(), S"This won't work... I need something more powerful")
            return
        end
        -- Efeito de partículas de destruição
        c.add_particlespawner({
            amount = 50,
            time = 2,
            minpos = { x = pos.x - 2.5, y = pos.y - 0.5, z = pos.z - 2.5 },
            maxpos = { x = pos.x + 2.5, y = pos.y + 4, z = pos.z + 2.5 },
            minvel = { x = -6, y = 6, z = -6 },
            maxvel = { x = 6, y = 12, z = 6 },
            minacc = { x = 0, y = -20, z = 0 },
            maxacc = { x = 0, y = -20, z = 0 },
            minexptime = 0.5,
            maxexptime = 1.5,
            minsize = 0.5,
            maxsize = 2,
            glow = 14,
            texture = {name = "spark_particle.png^[colorize:#76008d:150"}, -- purpura
        })
        -- Som de destruição (usa o som de dano do caranguejo)
        --c.sound_play("vulto_hurt", {pos = pos, gain = 1.0, max_hear_distance = 16})
        c.remove_node(pos) -- Remove a estátua
        -- Coloca areia na posição da estátua imediatamente
        c.set_node(pos, { name = "nh_nodes:wet_sand" })
        -- Spawna o Giant Crab na posição da estátua após 2.5 segundos
        c.after(0.25, function() c.add_entity(pos, "nh_mob:giantcrab") end)
        -- Consome a esfera da mão do jogador
        local inv = puncher:get_inventory()
        item:take_item(1)
        puncher:set_wielded_item(item)
        -- Avisa o jogador
        c.chat_send_player(puncher:get_player_name(), S "The statue shatters... something awakens!")
    end,
})

c.register_node("nh_nodes:redcrystal", {
    description = S "Red Crystal" .. "\n" .. S "[Light/Air]" .. "\n" .. S "(Squat down to breathe)",
    drawtype = "mesh",
    mesh = "redcrystal.obj",
    tiles = {"redcrystal.png"},
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    light_source = 14,
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    on_punch = function(pos, node, puncher, pointed_thing)
        -- Efeito de partículas de destruição
        c.add_particlespawner({
            amount = 50,
            time = 0.5,
            minpos = { x = pos.x - 2.5, y = pos.y - 0.5, z = pos.z - 2.5 },
            maxpos = { x = pos.x + 2.5, y = pos.y + 4, z = pos.z + 2.5 },
            minvel = { x = -6, y = 6, z = -6 },
            maxvel = { x = 6, y = 12, z = 6 },
            minacc = { x = 0, y = -20, z = 0 },
            maxacc = { x = 0, y = -20, z = 0 },
            minexptime = 0.5,
            maxexptime = 1.5,
            minsize = 0.5,
            maxsize = 2,
            glow = 14,
            texture = {name = "spark_particle.png^[colorize:#76008d:150"}, -- purpura
        })
        -- Som de destruição
        c.sound_play("tnt_explode", {pos = pos, gain = 1, max_hear_distance = 16})
    end,
})

c.register_node("nh_nodes:sentinelstatue", {
    description = S "Sentinel Statue" .. "\n" .. S "[Unknown]",
    drawtype = "mesh",
    mesh = "skydragon.obj",
    tiles = { "sentinelstatue.png" }, --tiles = {{name = "giantcrabstatue.png", glow = 1}},
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { falling_node = 1 },
    light_source = 7,
    collision_box = {type = "fixed", fixed = { -0.65, -0.5, -0.65, 0.65, 3.5, 0.65 }},
    selection_box = {type = "fixed", fixed = { -0.65, -0.5, -0.65, 0.65, 3.5, 0.65 }},
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local item = puncher:get_wielded_item()
        local item_name = item:get_name()
        -- Verifica se o item na mão é a esfera (qualquer variante)
        if item_name ~= "nh_nodes:sphere" and item_name ~= "nh_nodes:sphere_placed" then
            c.chat_send_player(puncher:get_player_name(), S "This won't work... I need something more powerful")
            return
        end
        -- Efeito de partículas de destruição
        c.add_particlespawner({
            amount = 50,
            time = 2,
            minpos = { x = pos.x - 2.5, y = pos.y - 0.5, z = pos.z - 2.5 },
            maxpos = { x = pos.x + 2.5, y = pos.y + 4, z = pos.z + 2.5 },
            minvel = { x = -6, y = 6, z = -6 },
            maxvel = { x = 6, y = 12, z = 6 },
            minacc = { x = 0, y = -20, z = 0 },
            maxacc = { x = 0, y = -20, z = 0 },
            minexptime = 0.5,
            maxexptime = 1.5,
            minsize = 0.5,
            maxsize = 2,
            glow = 1,
            texture = {
                name = "spark_particle.png^[colorize:#FF8800:150", -- dourado
            },
        })
        -- Som de destruição
        c.sound_play("tnt_explode", {pos = pos, gain = 1.0, max_hear_distance = 16})
        -- Remove a estátua
        c.remove_node(pos)
        -- Spawna o mob após 2 segundos
        c.after(0.25, function() c.add_entity(pos, "nh_mob:sentinel") end)
        -- Consome a esfera da mão do jogador
        local inv = puncher:get_inventory()
        item:take_item(1)
        puncher:set_wielded_item(item)
        -- Avisa o jogador
        c.chat_send_player(puncher:get_player_name(), S "The statue shatters... something awakens!")
    end,
})

c.register_node("nh_nodes:sphere", {
    description = S "Sphere of Vertices" .. "\n" .. S "[Unknown]",
    drawtype = "mesh",
    mesh = "ball_crystal.obj",
    tiles = { "ball2.png" },
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { oddly_breakable_by_hand = 1, not_in_creative_inventory = 0 },
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }},
    -- Ao colocar: troca para a versão invisível e spawna entidades
    after_place_node = function(pos, placer, itemstack)
        c.set_node(pos, { name = "nh_nodes:sphere_placed" })
        c.add_entity(pos, "nh_nodes:sphere_anim")
        c.add_entity(pos, "nh_nodes:crystal_anim")
    end,
})

-- Nó invisível (versão que fica no mundo)
c.register_node("nh_nodes:sphere_placed", {
    description = S "Bubble of Vertices" .. "\n" .. S "[Unknown]",
    drawtype = "mesh",
    mesh = "ball2.obj",
    tiles = { "empty.png" }, -- PNG 1x1 totalmente transparente

    sunlight_propagates = true,
    use_texture_alpha = "blend",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { oddly_breakable_by_hand = 1, not_in_creative_inventory = 1 },
    light_source = 9,
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }},
    drop = "", -- Sem drop automático (já feito manualmente abaixo)
    -- Ao quebrar: remove entidades e dropa o item original
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        for _, obj in ipairs(c.get_objects_inside_radius(pos, 0.6)) do
            local ent = obj:get_luaentity()
            if ent and (ent.name == "nh_nodes:sphere_anim" or ent.name == "nh_nodes:crystal_anim") then obj:remove() end
        end
        -- Dropa o item visível (com textura) em vez do invisível
        digger:get_inventory():add_item("main", "nh_nodes:sphere")
    end,
})

-- Entidade só visual, com a animação do GLB
c.register_entity("nh_nodes:sphere_anim", {
    initial_properties = {
        visual = "mesh",
        mesh = "ball.glb",
        textures = { "ball.png" },
        visual_size = { x = 10, y = 10 },
        collisionbox = { 0, 0, 0, 0, 0, 0 }, -- sem colisão própria
        physical = false,
        is_visible = true,
        glow = 4,
    },
    on_activate = function(self, staticdata)
        self.object:set_animation({ x = 0, y = 150 }, 15, 0, true)
    end,
    on_step = function(self, dtime) end,
    get_staticdata = function(self) return "saved" end,
})

-- Entidade só visual, com a animação do GLB
c.register_entity("nh_nodes:crystal_anim", {
    initial_properties = {
        visual = "mesh",
        mesh = "crystal.glb",
        textures = { "ball.png" },
        visual_size = { x = 10, y = 10 },
        collisionbox = { 0, 0, 0, 0, 0, 0 }, -- sem colisão própria
        physical = false,
        is_visible = true,
        --glow = 10,
    },
    on_activate = function(self, staticdata)
        self.object:set_animation({ x = 0, y = 150 }, 0.05, 0, true)
        self.object:set_properties({use_texture_alpha = true,})
    end,
    on_step = function(self, dtime) end,
    get_staticdata = function(self) return "saved" end,
})


c.register_node("nh_nodes:orb_empty", {
    description = S "Orb" .. S "(Empty)" .. "\n" .. S "[Mob Catcher]",
    drawtype = "mesh",
    mesh = "orb.obj",
    tiles = { "orb_node.png" },
    inventory_image = "orbspawner.png",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    wielded_bone_position = {pos = { x = 1.8, y = 0, z = 0 },}, -- Configuração mão direita
    wielded_visual_size = { x = 0.2, y = 0.2, z = 0.2 },
    collision_box = {type = "fixed", fixed = { -0.14, -0.5, -0.14, 0.14, 0, 0.14 }},
    selection_box = {type = "fixed", fixed = { -0.14, -0.5, -0.14, 0.14, -0.15, 0.14 }},
})

-- Função auxiliar para registrar o "ovo" como node com mesh
function register_orb_egg(mob_name, description, texture)
    -- "nh_mob:octopus" → "octopus_orb"
    local short_name = mob_name:match(":(.+)") .. "" -- "_orb"

    c.register_node("nh_mob:" .. short_name, {
        description = description .. "\n" .. S "[Mob Spawner]",
        drawtype = "mesh",
        mesh = "orb.obj",
        tiles = { texture or "orb_node.png" },
        inventory_image = "orbspawner.png",
        sunlight_propagates = true,
        use_texture_alpha = "blend",
        walkable = false,
        paramtype = "light",
        paramtype2 = "facedir",
        groups = { oddly_breakable_by_hand = 1 },
        collision_box = {type = "fixed", fixed = { -0.14, -0.5, -0.14, 0.14, 0, 0.14 }},
        selection_box = {type = "fixed", fixed = { -0.14, -0.5, -0.14, 0.14, -0.15, 0.14 }},
        -- Configuração mão direita
        wielded_bone_position = {pos = { x = 1.8, y = 0, z = 0 },},
        wielded_visual_size = { x = 0.2, y = 0.2, z = 0.2 },
        -- Ao clicar com o orbe em um node, spawna o mob
        on_place = function(itemstack, placer, pointed_thing)
            if pointed_thing.type ~= "node" then return end
            -- Só spawna se o player NÃO estiver agachado
            local controls = placer:get_player_control()
            -- Agachado: coloca o node normalmente
            if controls.sneak then return c.item_place(itemstack, placer, pointed_thing) end
            -- Em pé: spawna o mob
            local pos = pointed_thing.above
            c.add_entity(pos, mob_name)
            if not c.settings:get_bool("creative_mode") then itemstack:take_item() end
            return itemstack
        end,
    })
end

c.register_node("nh_nodes:nut", {
    description = S "Acorn" .. "\n" .. S "(Nut)" .. "\n" .. S "Nutrition: +1",
    drawtype = "mesh",
    mesh = "noz.obj",
    tiles = { "noz.png" },
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = { type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.30, 0.08 } },
    selection_box = { type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.30, 0.08 } },
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 1) -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

-- Folhas com 1 noz
c.register_node("nh_nodes:leaves_nut", {
    description = S "Leaves with Nut",
    drawtype = "allfaces_optional",
    waving = 3,
    tiles = { "leavesnut1.png" },
    groups = { snappy = 3, tree_leaves = 1 },
    drop = { items = { { items = { "nh_nodes:nut" } }, { items = { "nh_nodes:stick" } }, } },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_nut",
    liquid_alternative_source = "nh_nodes:leaves_nut",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:nut") end
            -- Transforma o node em leaves_apple2
            c.set_node(pos, { name = "nh_nodes:leaves" })
        end
        return itemstack
    end,
})

-- Folhas com 2 nozes
c.register_node("nh_nodes:leaves_nut2", {
    description = S "Leaves with 2 Nuts",
    drawtype = "allfaces_optional",
    waving = 3,
    tiles = { "leavesnut2.png" },
    groups = { snappy = 3, tree_leaves = 1 },
    drop = { items = { { items = { "nh_nodes:nut 2" } }, { items = { "nh_nodes:stick" } }, } },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_nut2",
    liquid_alternative_source = "nh_nodes:leaves_nut2",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:nut") end
            -- Transforma o node em leaves_apple2
            c.set_node(pos, { name = "nh_nodes:leaves_nut" })
        end
        return itemstack
    end,
})

-- Folhas com 3 nozes
c.register_node("nh_nodes:leaves_nut3", {
    description = S "Leaves with 3 Nuts",
    drawtype = "allfaces_optional",
    waving = 3,
    tiles = { "leavesnut3.png" },
    groups = { snappy = 3, tree_leaves = 1 },
    drop = { items = { { items = { "nh_nodes:nut 3" } }, { items = { "nh_nodes:stick" } }, } },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_nut3",
    liquid_alternative_source = "nh_nodes:leaves_nut3",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = { a = 15, r = 15, g = 15, b = 15 },
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then inv:add_item("main", "nh_nodes:nut") end
            -- Transforma o node em leaves_nut2
            c.set_node(pos, { name = "nh_nodes:leaves_nut2" })
        end
        return itemstack
    end,
})
c.register_node("nh_nodes:apple", {
    description = S "Apple" .. "\n" .. S "Nutrition: +2",
    drawtype = "mesh",
    mesh = "apple.obj",
    tiles = { "AppleTexture.png" },
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1, armor_head = 1, falling_node = 1 },
    collision_box = { type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 } },
    selection_box = { type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 } },
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 2) -- Restaura 4 pontos
        itemstack:take_item()
        return itemstack
    end,
})
c.register_node("nh_nodes:blueberry", {
    description = S "Blueberry" .. "\n" .. S "Nutrition: +1",
    --wield_scale = {x = 10, y = 10, z = 10},
    drawtype = "mesh",
    mesh = "blueberry.obj",
    tiles = { "BlueberryTexture.png" },
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = { type = "fixed", fixed = { -0.03, -0.5, -0.03, 0.03, -0.44, 0.03 } },
    selection_box = { type = "fixed", fixed = { -0.03, -0.5, -0.03, 0.03, -0.44, 0.03 } },
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 1) -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

c.register_node("nh_nodes:chickenegg", {
    description = S "Chicken Egg" .. "\n" .. S "Nutrition: +1",
    drawtype = "mesh",
    mesh = "chickenegg.obj",
    tiles = { "chickenegg.png" },
    paramtype = "light",
    walkable = false,
    groups = { oddly_breakable_by_hand = 1, falling_node = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = { type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0.1, 0.25 } },
    selection_box = { type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.28, 0.08 } },
    --visual_size = {x = 15, y = 15},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 1) -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

c.register_node("nh_nodes:friedchickenegg", {
    description = S "Fried Egg" .. "\n" .. S "(Chicken Egg)" .. "\n" .. S "Nutrition: +4",
    drawtype = "mesh",
    mesh = "friedegg.obj",
    tiles = { "friedegg.png" },
    paramtype = "light",
    walkable = false,
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0.1, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.08, -0.5, -0.08, 0.08, -0.28, 0.08 }},
    --visual_size = {x = 15, y = 15},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 4) -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})
c.register_node("nh_nodes:worm", {
    description = S "Worm" .. "\n" .. S "[Mob / Item]",
    drawtype = "mesh",
    mesh = "worm_node.obj",
    tiles = { "worm.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = { type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, -0.4, 0.1 } },
    selection_box = { type = "fixed", fixed = { -0.1, -0.5, -0.1, 0.1, -0.4, 0.1 } },
    visual_size = { x = 15, y = 15 },
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.above -- posição onde vai spawnar
        -- Spawna o mob
        local mob = c.add_entity(pos, "nh_mob:worm")
        if mob then
            -- Aplica a rotação do jogador ao mob
            if placer then
                local yaw = placer:get_look_horizontal()
                mob:set_yaw(yaw)
            end
            -- Consome o item da mão
            itemstack:take_item()
        end
        return itemstack
    end,
})
c.register_node("nh_nodes:chicken", {
    description = S "Chicken",
    drawtype = "mesh",
    mesh = "chicken_node.obj",
    tiles = { "chicken.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = { type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0, 0.25 } },
    selection_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0, 0.3 } },
    visual_size = { x = 15, y = 15 },

})

c.register_node("nh_nodes:rawchicken", {
    description = S "Raw Chicken" .. "\n" .. S "Nutrition: +4",
    drawtype = "mesh",
    mesh = "raw_chicken.obj",
    tiles = { "raw_chicken.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    max_stake = 1,
    groups = {oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0, 0.3 }},
    --visual_size = {x = 15, y = 15},
    --wield_scale = {x= 2, y= 2, z= 2},
    -- Tornar comestível e derrubar o osso no chão se 8 slots estiverem cheios (os pegos por comando se amontoam)
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 4)
        itemstack:take_item()
        local bone = ItemStack("nh_nodes:bone 2")
        if itemstack:is_empty() then return bone
        else add_item_to_visible_slots(user, bone) return itemstack
        end
    end,
})

c.register_node("nh_nodes:roastchicken", {
    description = S "Roast Chicken" .. "\n" .. S "Nutrition: +6",
    drawtype = "mesh",
    mesh = "raw_chicken.obj",
    tiles = { "roastchicken.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    max_stake = 1,
    groups = {oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = {-0.25, 0, -0.25, 0.25, 0, 0.25}},
    selection_box = {type = "fixed", fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}},
    visual_size = { x = 15, y = 15 },
    -- Tornar comestível e derrubar o osso no chão se 24 slots estiverem cheios (os pegos por comando se amontoam)
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 6)
        itemstack:take_item()
        local bone = ItemStack("nh_nodes:bone 2")
        if itemstack:is_empty() then return bone
        else add_item_to_visible_slots(user, bone) return itemstack
        end
    end,
})
c.register_node("nh_nodes:tuna", {
    description = S "Tuna",
    drawtype = "mesh",
    mesh = "rawtuna.obj",
    tiles = { "tuna.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    use_texture_alpha = "clip",
    walkable = false,
    --sounds = default.node_sound_wood_defaults(),
    collision_box = { type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0, 0.25 } },
    selection_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0, 0.3 } },
    pointabilities = {nodes = water_nodes},
    -- Spawna o mob ao colocar o node no chão ou na água
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.above -- posição onde vai spawnar
        -- Spawna o mob
        local mob = c.add_entity(pos, "nh_mob:tuna")
        if mob then
            -- Aplica a rotação do jogador ao mob
            if placer then
                local yaw = placer:get_look_horizontal()
                mob:set_yaw(yaw)
            end
            -- Consome o item da mão
            itemstack:take_item()
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:rawtuna", {
    description = S "Raw Tuna" .. "\n" .. "Nutrition: +4",
    drawtype = "mesh",
    mesh = "rawtuna.obj",
    tiles = { "rawtuna.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    use_texture_alpha = "clip",
    walkable = false,
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0, 0.3 }},
    --visual_size = {x = 15, y = 15},
    --wield_scale = {x= 2, y= 2, z= 2},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 4)
        itemstack:take_item()
    end,
})

c.register_node("nh_nodes:roasttuna", {
    description = S "Roast Tuna" .. "\n" .. S "Nutrition: +6",
    drawtype = "mesh",
    mesh = "rawtuna.obj",
    tiles = { "roasttuna.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    use_texture_alpha = "clip",
    walkable = false,
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.25, 0, -0.25, 0.25, 0, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0, 0.3 }},
    --visual_size = {x = 15, y = 15},
    --wield_scale = {x= 2, y= 2, z= 2},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 6)
        itemstack:take_item()
    end,
})

c.register_node("nh_nodes:bull", {
    description = S "Bull" .. "\n" .. S "[collectible]",
    drawtype = "mesh",
    mesh = "bull2.obj",
    tiles = { "bull.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1, armor_head = 1 },
    collision_box = {type = "fixed", fixed = { -0.7, -0.7, -0.7, 0.7, -0.7, 0.7 }},
    selection_box = {type = "fixed", fixed = { -0.7, -0.7, -0.7, 0.7, -0.7, 0.7 }},
})

c.register_node("nh_nodes:rawbeef", {
    description = S "Raw Beef" .. "\n" .. S "Nutrition: +3",
    drawtype = "mesh",
    mesh = "cowmeat.obj",
    tiles = { "cowmeat.png" },
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = { oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = { -0.15, -0.5, -0.25, 0.15, -0.375, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.15, -0.5, -0.25, 0.15, -0.375, 0.25 }},
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 3) -- Restaura 3 pontos
        itemstack:take_item()
        return itemstack
    end,
})

c.register_node("nh_nodes:roastbeef", {
    description = S "Roast Beef" .. "\n" .. S "Nutrition: +6",
    drawtype = "mesh",
    mesh = "cowmeat.obj",
    tiles = { "roastbeef.png" },
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = { oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = { -0.15, -0.5, -0.25, 0.15, -0.375, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.15, -0.5, -0.25, 0.15, -0.375, 0.25 }},
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 6) -- Restaura 6 pontos
        itemstack:take_item()
        return itemstack
    end,
})

c.register_node("nh_nodes:cowhide", {
    description = S"Bull Fur",
    drawtype = "mesh",
    mesh = "cowleather.obj",
    tiles = { "cowleather.png" },
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}},
})

c.register_node("nh_nodes:sleepingbag", {
    description = S("Sleeping Bag"),
    drawtype = "mesh",
    mesh = "sleepingbag.obj",
    tiles = {"sleepingbag.png"},
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -1.5, 0.5, -0.35, 1.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -1.5, 0.5, -0.35, 1.5}},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local time = minetest.get_timeofday()
        local is_night = time > 0.75 or time < 0.25 -- Noite: depois das 18h (0.75) ou antes das 6h (0.25)
        if not is_night then core.chat_send_player(clicker:get_player_name(), "I'll only be able to sleep at night!") return itemstack end
        core.set_timeofday(0.25) -- Avança o tempo para o amanhecer (6h da manhã = 0.25)
        core.chat_send_player(clicker:get_player_name(), "I slept and it's already dawn!")
        return itemstack
    end,
})

c.register_node("nh_nodes:inksac", {
    description = S"Ink Sack" .. "\n" .. S"Portion: 1",
    drawtype = "mesh",
    mesh = "inksac.obj",
    tiles = {"inksac.png"},
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    collision_box = {type = "fixed", fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}},
    selection_box = {type = "fixed", fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}},
})

-- VIDRO
c.register_node("nh_nodes:glass", {
    description = S"Glass",
    drawtype = "glasslike",
    tiles = {"glass.png"},
    groups = {cracky = 3},
    walkable = true,
    --is_ground_content = true,
    use_texture_alpha = "blend", --blend
    --alpha = 200,
    paramtype = "light",
    sunlight_propagates = true, -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice"},
})

-- Calcula posição da entidade na frente do espelho
local function get_surface_pos(mirror_pos, param2)
    local dir = facedir_to_dir[param2 % 4] or facedir_to_dir[0]
    return vector.add(mirror_pos, vector.multiply(dir, -0.435)) -- 0.435 para ficar colado na face frontal do mesh
end

-- Busca o node sólido mais próximo abaixo
local function get_node_below(pos)
    for dy = 1, 16 do
        local candidate_pos = xyz(pos.x, pos.y - dy, pos.z)
        local node = c.get_node(candidate_pos)
        if node.name ~= "air"
            and node.name ~= "ignore"
            and node.name ~= "nh_nodes:mirror"
            and node.name ~= "nh_nodes:ulexite" then
            return node
        end
    end
    return nil
end

-- Retorna a textura do topo de um node
local function get_top_texture(node_name)
    local def = c.registered_nodes[node_name]
    if not def or not def.tiles then return nil end
    local tile = def.tiles[1]
    if type(tile) == "string" then
        return tile
    elseif type(tile) == "table" then
        return tile.name
    end
    return nil
end

local function mirror_has_surface(mirror_pos, param2)
    local epos = get_surface_pos(mirror_pos, param2)
    for _, obj in ipairs(c.get_objects_inside_radius(epos, 0.15)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "nh_nodes:mirror_surface" then
            return true
        end
    end
    return false
end

-- Spawna a entidade visual na frente do espelho
-- Função auxiliar agora também guarda mirror_pos na entidade
local function spawn_surface(mirror_pos, param2)
    local below = get_node_below(mirror_pos)
    if not below then return end
    local tex = get_top_texture(below.name)
    if not tex then return end
    local epos = get_surface_pos(mirror_pos, param2)
    local ent = c.add_entity(epos, "nh_nodes:mirror_surface")
    if not ent then return end
    local luaent = ent:get_luaentity()
    if luaent then luaent._mirror_pos = mirror_pos end -- mirror_pos salva referência ao dono
    local dir = facedir_to_dir[param2 % 4] or facedir_to_dir[0]
    ent:set_yaw(math.atan2(-dir.x, -dir.z))
    ent:set_properties({ textures = { tex } })
end

-- Entidade visual (sprite colado na frente do espelho)
c.register_entity("nh_nodes:mirror_surface", {
    initial_properties = {
        visual               = "upright_sprite",
        visual_size          = { x = 1.0, y = 1.0 },
        textures             = { "blank.png" },
        physical             = false,
        collide_with_objects = false,
        pointable            = false,
        static_save          = false, 
    },

    on_activate = function(self, staticdata, dtime_s)
        -- Ao recarregar do staticdata, verifica se o espelho ainda existe
        if staticdata and staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.mirror_pos then
                self._mirror_pos = data.mirror_pos
                local node = c.get_node(data.mirror_pos)
                if node.name ~= "nh_nodes:mirror" then
                    -- Espelho foi quebrado enquanto chunk estava fora
                    self.object:remove()
                    return
                end
            end
        end
    end,
    get_staticdata = function(self) return c.serialize({ mirror_pos = self._mirror_pos }) end, -- Salva a posição do espelho dono junto com a entidade
    on_step = function(self, dtime)
        self._timer = (self._timer or 0) + dtime
        if self._timer < 1.0 then return end
        self._timer = 0
        if not self._mirror_pos then self.object:remove() return end
        local node = c.get_node(self._mirror_pos)
        if node.name ~= "nh_nodes:mirror" then self.object:remove() end
    end,
})

-- Node do espelho
c.register_node("nh_nodes:mirror", {
    description         = S "Mirror",
    drawtype            = "mesh",
    mesh                = "mirror.obj",
    tiles               = { "mirror.png" },
    paramtype           = "light",
    paramtype2          = "facedir",
    sunlight_propagates = true,
    walkable            = false,
    collision_box       = {type = "fixed", fixed = { -0.5, -0.5, 0.435, 0.5, 0.5, 0.5 }},
    selection_box       = {type = "fixed", fixed = { -0.5, -0.5, 0.435, 0.5, 0.5, 0.5 }},
    groups              = { cracky = 2, oddly_breakable_by_hand = 1 },
    after_place_node    = function(pos, placer, itemstack, pointed_thing)
        local node = c.get_node(pos)
        -- Salva param2 nos metadados para poder recriar depois
        local meta = c.get_meta(pos)
        meta:set_int("param2", node.param2)
        spawn_surface(pos, node.param2)
    end,
    on_destruct = function(pos)
        for _, obj in ipairs(c.get_objects_inside_radius(pos, 0.6)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:mirror_surface" then
                -- Calcula qual espelho "dono" desta entidade seria
                -- verificando se ela está próxima o suficiente do pos destruído
                -- e NÃO está na frente de outro espelho vizinho
                local epos = obj:get_pos()
                if not epos then
                    obj:remove()
                else
                    -- Checa se algum espelho vizinho reivindica esta entidade
                    local claimed_by_neighbor = false
                    local neighbors = {
                        xyz(pos.x + 1, pos.y, pos.z),
                        xyz(pos.x - 1, pos.y, pos.z),
                        xyz(pos.x, pos.y, pos.z + 1),
                        xyz(pos.x, pos.y, pos.z - 1),
                    }
                    for _, npos in ipairs(neighbors) do
                        local nnode = c.get_node(npos)
                        if nnode.name == "nh_nodes:mirror" then
                            local expected = get_surface_pos(npos, nnode.param2)
                            if vector.distance(epos, expected) < 0.1 then claimed_by_neighbor = true break end
                        end
                    end
                    if not claimed_by_neighbor then
                        obj:remove()
                    end
                end
            end
        end
    end,

    -- Suporte a reload de mundo: spawna entidade se sumir
    on_construct        = function(pos)
        -- Usado apenas em construção manual/worldedit, não duplica com after_place_node
    end,
})

-- ABM: recria entidades de espelhos que perderam a superfície
-- (acontece ao recarregar chunks / reentrar no mundo)
c.register_abm({
    label     = "Mirror surface restore",
    nodenames = { "nh_nodes:mirror" },
    interval  = 1,
    chance    = 1,
    action    = function(pos, node)
        if not mirror_has_surface(pos, node.param2) then spawn_surface(pos, node.param2) end
    end,
})

c.register_node("nh_nodes:bottle", {
    description = S "Bottle",
    inventory_image = "bottle.png",
    drawtype = "mesh",
    mesh = "emptybottle.obj",
    tiles = { "bottletexture.png" },
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
    selection_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
})

local function is_water_near(pos)
    local offsets = {xyz(0),
        { x = 1, y = 0, z = 0 }, { x = -1, y = 0, z = 0 },
        { x = 0, y = 1, z = 0 }, { x = 0, y = -1, z = 0 },
        { x = 0, y = 0, z = 1 }, { x = 0, y = 0, z = -1 },}
    for _, off in ipairs(offsets) do
        local p = vector.add(pos, off)
        local node = c.get_node(p)
        if node and node.name then
            if node.name == "nh_nodes:water"
                or node.name == "nh_nodes:water_flowing"
                or node.name == "nh_nodes:water2"
                or node.name == "nh_nodes:water2_flowing" then
                return true
            end
        end
    end
    return false
end

-- ============================================================
--  ULEXITE – entidade de superfície (topo do bloco abaixo)

-- ── Helpers (reutilizados do espelho, mas isolados para ulexita) ──────────────

-- Retorna a textura do topo do node (tiles[1])
local function ulexite_get_top_texture(node_name)
    local def = c.registered_nodes[node_name]
    if not def or not def.tiles then return nil end
    local tile = def.tiles[1]
    if type(tile) == "string" then return tile
    elseif type(tile) == "table" then return tile.name
    end
    return nil
end

-- Posição onde a entidade fica: topo da ulexita (y + 0.501, levemente acima)
local function ulexite_surface_pos(ulexite_pos)
    return xyz(ulexite_pos.x, ulexite_pos.y + 0.501, ulexite_pos.z)
end

-- Verifica se já existe uma entidade de superfície sobre esta ulexita
local function ulexite_has_surface(ulexite_pos)
    local epos = ulexite_surface_pos(ulexite_pos)
    for _, obj in ipairs(c.get_objects_inside_radius(epos, 0.15)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "nh_nodes:ulexite_surface" then return true end
    end
    return false
end

-- Spawna a entidade visual deitada no topo da ulexita
local function ulexite_spawn_surface(ulexite_pos)
    local below = get_node_below(ulexite_pos)
    if not below then return end
    local tex = ulexite_get_top_texture(below.name)
    if not tex then return end
    local epos = ulexite_surface_pos(ulexite_pos)
    local ent  = c.add_entity(epos, "nh_nodes:ulexite_surface")
    if not ent then return end
    ent:set_properties({ textures = { tex } })
    local luaent = ent:get_luaentity()
    if luaent then luaent._ulexite_pos = ulexite_pos end
end

-- ── Entidade visual ───────────────────────────────────────────────────────────

c.register_entity("nh_nodes:ulexite_surface", {
    initial_properties = {
        -- upright_sprite igual ao mirror; rotação 90° em X o deita horizontalmente
        visual               = "upright_sprite",
        visual_size          = { x = 1.0, y = 1.0 },
        textures             = { "blank.png" },
        physical             = false,
        collide_with_objects = false,
        pointable            = false,
        static_save          = false,
    },

    on_activate = function(self, staticdata, dtime_s)
        -- Inclina o sprite 90° para ficar "deitado" (horizontal)
        self.object:set_rotation({ x = math.pi / 2, y = 0, z = 0 })
        if staticdata and staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.ulexite_pos then
                self._ulexite_pos = data.ulexite_pos
                local node = c.get_node(data.ulexite_pos)
                if node.name ~= "nh_nodes:ulexite" then self.object:remove() return end
                -- Restaura textura
                local below = get_node_below(data.ulexite_pos)
                if below then
                    local tex = ulexite_get_top_texture(below.name)
                    if tex then self.object:set_properties({textures = {tex}}) end
                end
            end
        end
    end,

    get_staticdata = function(self) return c.serialize({ulexite_pos = self._ulexite_pos}) end,
    on_step = function(self, dtime)
        self._timer = (self._timer or 0) + dtime
        if self._timer < 1.0 then return end
        self._timer = 0
        if not self._ulexite_pos then self.object:remove() return end
        -- Remove se a ulexita sumiu
        local node = c.get_node(self._ulexite_pos)
        if node.name ~= "nh_nodes:ulexite" then self.object:remove() return end
        -- Atualiza textura caso o bloco abaixo tenha mudado
        local below = get_node_below(self._ulexite_pos)
        if below then
            local tex = ulexite_get_top_texture(below.name)
            if tex then
                local cur = self.object:get_properties().textures
                if not cur or cur[1] ~= tex then self.object:set_properties({textures = {tex}}) end
            end
        end
    end,
})

-- Node da ulexite
c.register_node("nh_nodes:ulexite", {
    description = S "Ulexite",
    drawtype = "normal",
    tiles = { "ulexitetopdown.png", "ulexitetopdown.png", "ulexitesides.png" },
    groups = { cracky = 3 },
    use_texture_alpha = "blend",
    paramtype = "light",
    sunlight_propagates = true,
    after_place_node = function(pos, placer, itemstack, pointed_thing) ulexite_spawn_surface(pos) end,
    on_destruct = function(pos)
        local epos = ulexite_surface_pos(pos)
        for _, obj in ipairs(c.get_objects_inside_radius(epos, 0.15)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:ulexite_surface" then obj:remove() end
        end
    end,
})

-- ── ABM: recria entidades que sumiram ao recarregar chunks ────────────────────

c.register_abm({
    label     = "Ulexite surface restore",
    nodenames = { "nh_nodes:ulexite" },
    interval  = 2,
    chance    = 1,
    action    = function(pos, node)
        if not ulexite_has_surface(pos) then ulexite_spawn_surface(pos) end
    end,
})

c.register_node("nh_nodes:messagebottle", {
    description = S "Bottle with Message" .. "\n" .. S "[Floating Item]",
    inventory_image = "bottlepage.png",
    drawtype = "mesh",
    mesh = "bottlepage.obj",
    tiles = { "bottlepagetexture.png" },
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype2 = "facedir",
    groups = { oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
    selection_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
    pointabilities = {nodes = water_nodes},
    -- Quando o nó é colocado, verifica se está na água
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer and placer:is_player() then
            local ctrl = placer:get_player_control()
            if ctrl.sneak then
                return
            end
        end
        -- Sem agachar: vira entidade normalmente
        if is_water_near(pos) then
            c.remove_node(pos)
            c.add_entity(pos, "nh_mob:messagebottle")
        end
    end,

    -- Cobre o caso de água chegar até o nó depois que ele já está parado
    on_flood = function(pos, oldnode, newnode)
        c.remove_node(pos)
        c.add_entity(pos, "nh_mob:messagebottle")
        return false
    end,
})

c.register_node("nh_nodes:fireflybottle", {
    description = S "Bottle with Firefly",
    inventory_image = "bottlefirefly.png",
    drawtype = "mesh",
    mesh = "bottlefirefly.obj",
    tiles = { "bottlefireflytexture.png" },
    paramtype = "light",
    light_source = 5,
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    backface_culling = false,
    walkable = false,
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1 },
    collision_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
    selection_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
    wielded_bone_position = {pos = xyz(1.6, 0, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.6, 0, 0)},
})

c.register_node("nh_nodes:coconutlinked", {
    description = S"Fixed Coconut",
    drawtype = "mesh",
    mesh = "coconutlinked.obj",
    tiles = { "CocoTexture.png" },
    waving = 2,
    drop = "nh_nodes:coconut",
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, tree_leaves = 1, oddly_breakable_by_hand = 1, falling_node = 1},
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.25, 0, -0.5, 0.25, 0.5, 0}},
    selection_box = {type = "fixed", fixed = { -0.25, 0, -0.5, 0.25, 0.5, 0}},
})

c.register_node("nh_nodes:coconut", {
    description = S"Coconut" .. "\n" .. S "Nutrition: +3" .. "\n" .. S "Floating Item",
    drawtype = "mesh",
    mesh = "coconut.obj",
    tiles = {"CocoTexture.png"},
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, tree_leaves = 1, oddly_breakable_by_hand = 1, falling_node = 1},
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.25, -0.5, -0.25, 0.25, 0, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.25, -0.5, -0.25, 0.25, 0, 0.25 }},
    pointabilities = {nodes = water_nodes},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 3) -- Restaura 3 pontos
        itemstack:take_item()
        return itemstack
    end,
    -- Quando o nó é colocado, verifica se está na água
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer and placer:is_player() then
            local ctrl = placer:get_player_control()
            if ctrl.sneak then return end
        end
        -- Sem agachar: vira entidade normalmente
        if is_water_near(pos) then
            c.remove_node(pos)
            c.add_entity(pos, "nh_mob:coconut")
        end
    end,
    -- Cobre o caso de água chegar até o nó depois que ele já está parado
    on_flood = function(pos, oldnode, newnode)
        c.remove_node(pos)
        c.add_entity(pos, "nh_mob:coconut")
        return false
    end,
})

c.register_node("nh_nodes:palmtimber", {
    description = S "Palm Trunk",
    drawtype = "mesh",
    mesh = "palm_trunk.obj",
    tiles = { "coqueirotexture.png" },
    stack_max = 4,
    drop = "nh_nodes:palmlog",
    --waving = 2,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 2, oddly_breakable_by_hand = 1, falling_node = 1, tree_trunk = 1},
    collision_box = {type = "fixed", fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 }},
    selection_box = {type = "fixed", fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 }},
    sounds = {
        dug = { name = "punchtimber2", gain = 0.5 },
        dig = { name = "punchtimber2", gain = 0.5 },},
    after_dig_node = function(pos)
        local below = xyz(pos.x, pos.y - 1, pos.z)
        local below_node = c.get_node(below)
        if below_node.name == "air"
            or c.get_item_group(below_node.name, "tree_trunk") > 0
            or c.get_item_group(below_node.name, "tree_leaves") > 0 then
            make_leaves_fall(pos)
        end
    end,
    on_construct = function(pos) c.get_node_timer(pos):start(0.5) end,
    on_timer = function(pos)
        if not has_solid_support(pos) then make_leaves_fall(pos) return false end
        return true
    end,
})


c.register_node("nh_nodes:palmstraws", {
    description = S"Palm Trunk with Straws",
    drawtype = "mesh",
    mesh = "coconutstraws.obj",
    tiles = { "strawstimbertexture.png" },
    stack_max = 4,
    waving = 2,
    drop = {items = {{items = {"nh_nodes:palmtimber"}}, {items = {"nh_nodes:palmstraw 4"}}}},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3, falling_node = 1, tree_trunk = 1},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},-- Porta na lateral quando aberta
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},-- Colisão fina na lateral
    -- Som tocado ao bater no tronco medio (2)
    sounds = {dug = {name = "punchtimber2", gain = 0.5}, dig = {name = "punchtimber2", gain = 0.5}},
})

c.register_node("nh_nodes:palmlog", {
    description = S "Palm Log",
    drawtype = "mesh",
    mesh = "palm_trunk.obj",
    tiles = { "coqueirotexture.png" },
    stack_max = 4,
    paramtype = "light",
    paramtype2 = "wallmounted",
    groups = {snappy = 3, oddly_breakable_by_hand = 1,
        --falling_node = 1,
        --tree_trunk = 1
    },
    selection_box = {type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25}},
    node_box = {type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25}},
    -- Som tocado ao bater no tronco medio (2)
    sounds = {
        dug = { name = "punchtimber2", gain = 0.5 },
        dig = { name = "punchtimber2", gain = 0.5 },},
})

c.register_node("nh_nodes:palmleafstalks", {
    description = S "Palm Leaves Stalks",
    drawtype = "mesh",
    mesh = "TaloCoqueiro.obj",
    tiles = { "PalmLeafTexture.png" },
    waving = 2,
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    shaded = false,           -- Desabilita sombreamento por face
    backface_culling = false, -- Renderiza ambos os lados das faces
    use_texture_alpha = "blend",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1, tree_leaves = 1, armor_head = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, -0.3, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, -0.3, 0.5 }},
})

-- Registrar o node da folha de coqueiro
c.register_node("nh_nodes:palmleaf", {
    description = S "Palm Leaf",
    drawtype = "mesh",
    mesh = "palm_leaf.obj",
    tiles = { "PalmLeafTexture.png" },
    waving = 2,
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    shaded = false,
    backface_culling = false,
    use_texture_alpha = "blend",
    paramtype2 = "facedir",
    groups = { snappy = 3, oddly_breakable_by_hand = 1, tree_leaves = 1, armor_head = 1 },
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, -0.3, 0.5 }},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, -0.3, 0.5 }},
    -- Quando o node é colocado, iniciar o timer
    on_place = function(itemstack, placer, pointed_thing)
        -- Primeiro, fazer o placement normal
        local pos = c.item_place(itemstack, placer, pointed_thing)
        -- Se o placement foi bem-sucedido, iniciar o timer
        if pos then
            local timer = c.get_node_timer(pointed_thing.above)
            timer:start(60) -- 60 segundos = 1 minuto
        end
        return itemstack
    end,
    -- Quando o timer terminar
    on_timer = function(pos)
        -- Verificar se está sob luz do sol
        local light_level = c.get_node_light(pos, 0.5)
        if light_level and light_level >= 12 then -- 12+ é luz solar direta
            c.set_node(pos, {name = "nh_nodes:palmstraw"}) -- Trocar para o node de palha
            return false -- Não reiniciar o timer
        else return true -- Se não estiver no sol, reiniciar o timer
        end
    end,
})

-- NODE DE PALHA COM CHAMAS
c.register_node("nh_nodes:palmstraw", {
    description = S "Palm Straw",
    drawtype = "mesh",
    mesh = "palmstraw.obj",
    tiles = { "PalmStrawTexture.png" },
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    shaded = false,
    backface_culling = false,
    use_texture_alpha = "blend",
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1, tree_leaves = 1, flammable = 3 },
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}},
    -- Quando a palha é colocada, verifica se deve criar chama
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        -- Se já tiver chama marcada, cria a entidade
        if meta:get_int("has_flame") == 1 then
            c.after(0.1, function()
                -- Verifica se não existe chama já
                local objs = c.get_objects_inside_radius(pos, 0.5)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:palmstraw_flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    local obj = c.add_entity(pos, "nh_nodes:palmstraw_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._straw_pos = pos end
                    end
                end
            end)
        end
    end,
    -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:palmstraw_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._straw_pos = pos end
            end
            -- Efeito sonoro (opcional)
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,

    -- Quando a palha for removida, remove as chamas
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:palmstraw_flame_entity" then obj:remove() end
        end
    end,
})

-- ENTIDADE DA CHAMA DA PALHA
c.register_entity("nh_nodes:palmstraw_flame_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        selectionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
        collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
        visual = "mesh",
        mesh = "flame.obj",
        textures = {"fire_basic_flame_animated.png"},
        visual_size = {x = 10, y = 10}, -- Menor que a chama da grama
        static_save = true,
        pointable = true,
        glow = 14,
    },
    _straw_pos = nil,
    _timer = 0,
    _anim_timer = 0,
    _current_frame = 0,
    on_activate = function(self, staticdata)
        if staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.straw_pos then self._straw_pos = data.straw_pos end
        end
        self._timer = 0
        self.object:set_sprite({x = 0, y = 0}, 1, 1, false)
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    get_staticdata = function(self) return c.serialize({straw_pos = self._straw_pos}) end,
    -- Detecta quando é golpeado para acender tochas
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        -- Verifica se está segurando uma tocha apagada
        if wielded_name == "nh_nodes:torch" then
            wielded:take_item()
            puncher:set_wielded_item(wielded)
            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", "nh_nodes:torch2")
                if not leftover:is_empty() then
                    local pos = puncher:get_pos()
                    c.add_item(pos, leftover)
                end
            end
            c.sound_play("fire_flint_and_steel", {pos = self.object:get_pos(), gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    on_step = function(self, dtime)
        self._timer = self._timer + dtime
        self._anim_timer = self._anim_timer + dtime
        -- Anima a textura
        if self._anim_timer > (1.0 / 8) then
            self._anim_timer = 0
            self._current_frame = (self._current_frame + 1) % 8
            self.object:set_texture_mod("^[verticalframe:8:" .. self._current_frame)
        end
        -- Verifica se a palha ainda existe
        if self._timer > 0.5 then
            self._timer = 0
            if not self._straw_pos then self.object:remove() return end
            local node = c.get_node(self._straw_pos)
            -- Se a palha foi removida, remove a chama
            if node.name ~= "nh_nodes:palmstraw" then self.object:remove() return end
            -- Verifica se ainda deve ter chama
            local meta = c.get_meta(self._straw_pos)
            if meta:get_int("has_flame") ~= 1 then self.object:remove() return end
        end
    end,
})

c.register_node("nh_nodes:fireice", {
    description = S "Fire Ice",
    tiles = { "neve.png" },
    drawtype = "normal",
    groups = {crumbly = 2, falling_node = 1}, -- como areia, mas sem fluir
    --sounds = default.node_sound_snow_defaults(),
})

c.register_node("nh_nodes:snow_ramp", {
    description         = S"Snow Ramp",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_slope.obj",
    tiles               = {"snow_slope.png"},
    groups              = {crumbly = 2, soil = 1, falling_node = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:sand",
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug      = {name = "punchtimber3", gain = 0.5},
        dig      = {name = "punchtimber3", gain = 0.5},
        place    = {name = "punchtimber3", gain = 0.5}},
    sunlight_propagates = true,
    selection_box       = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0,  0.0,  0.5, 0.5, 0.5}}},
    collision_box       = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0,  0.0,  0.5, 0.5, 0.5}}},
})

c.register_node("nh_nodes:snow_corner", {
    description         = S"Snow Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_vertix.obj",
    tiles               = {"snow_slope.png"},
    groups              = {crumbly = 2, soil = 1, falling_node = 1, not_blocking_trains = 1 },
    drop                = "nh_nodes:sand",
    sunlight_propagates = true,
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug      = {name = "punchtimber3", gain = 0.5},
        dig      = {name = "punchtimber3", gain = 0.5},
        place    = {name = "punchtimber3", gain = 0.5},
    },
    collision_box       = {type = "fixed", fixed = {
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5}, -- Topo
            {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5}, -- Base principal
            {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0}, -- Base braço 1
            {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
    selection_box       = {type = "fixed", fixed = {
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5}, -- topo
            {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5}, -- Base principal
            {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0}, -- Base braço 1
            {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
})

c.register_node("nh_nodes:snow_insidecorner", {
    description         = S "Snow Inside Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grassinsidecorner.obj",
    tiles               = {"snow_slope.png"},
    groups              = {crumbly = 2, soil = 1, falling_node = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:sand",
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug      = {name = "punchtimber3", gain = 0.5},
        dig      = {name = "punchtimber3", gain = 0.5},
        place    = {name = "punchtimber3", gain = 0.5}},
    sunlight_propagates = true,
    collision_box       = {type = "fixed", fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- Base completa (metade inferior)
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5}, -- Topo braço 1: faixa traseira (Z-) -- faixa Z-
            {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0}, -- Topo braço 1: faixa traseira (Z-)-- faixa Z-
            {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}}, -- Topo braço 2: faixa lateral (X-)-- faixa X-
        
    selection_box       = {type = "fixed", fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5},
            {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0},
            {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}},
})

c.register_node("nh_nodes:snow", {
    description = S "Snow",
    tiles = {"neve.png"},
    drawtype = "normal",
    groups = {crumbly = 2, falling_node = 1}, -- como areia, mas sem fluir
    sounds = {
        footstep = { name = "punchtimber3", gain = 0.5 },
        dug      = { name = "punchtimber3", gain = 0.5 },
        dig      = { name = "punchtimber3", gain = 0.5 },
        place    = { name = "punchtimber3", gain = 0.5 },},
})

c.register_node("nh_nodes:avalanche", {
    description = S "Avalanche",
    liquidtype = "source",
    drawtype = "liquid",
    tiles = {"neve.png"},
    groups = {liquid = 3, crumbly = 2, falling_node = 1}, -- como areia e flui
    sounds = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug      = {name = "punchtimber3", gain = 0.5},
        dig      = {name = "punchtimber3", gain = 0.5},
        place    = {name = "punchtimber3", gain = 0.5}},
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquid_alternative_flowing = "nh_nodes:avalanche_flowing",
    liquid_alternative_source = "nh_nodes:avalanche",
    liquid_viscosity = 0,
    liquid_renewable = false,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    drop = "nh_nodes:snow",
})

c.register_node("nh_nodes:avalanche_flowing", {
    description = S "Flowing Avalanche",
    liquidtype = "flowing",
    drawtype = "flowingliquid",
    tiles = {"neve.png"},
    groups = {liquid = 3, not_in_creative_inventory = 1},
    special_tiles = {{name = "neve_flowing_animated.png", backface_culling = false,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}},
        {name = "neve_flowing_animated.png", backface_culling = true,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}}},
    --use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquid_alternative_flowing = "nh_nodes:avalanche_flowing",
    liquid_alternative_source = "nh_nodes:avalanche",
    liquid_viscosity = 0,
    liquid_renewable = false,
})

c.register_node("nh_nodes:water", {
    description = S "Water",
    drawtype = "liquid",
    liquidtype = "source",
    tiles = { "agua.png" },
    tiles = {{name = "agua_animated.png", backface_culling = false,
        animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 10}}, "agua.png"}, -- resto das faces
    paramtype = "light",
    waving = 3,
    liquid_renewable = false,
    use_texture_alpha = "blend",
    --paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquid_alternative_flowing = "nh_nodes:water_flowing",
    liquid_alternative_source = "nh_nodes:water",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 0, g = 0, b = 255},
    drowning = 1, -- ADICIONE ESTA LINHA (dano por segundo quando sem ar)
    groups = { water = 1, liquid = 1 },
    after_place_node = function(pos)
        local neighbors = {xyz(1, 0, 0), xyz(-1, 0, 0), xyz(0, 1, 0), xyz(0, -1, 0), xyz(0, 0, 1), xyz(0, 0, -1)}
        for _, d in ipairs(neighbors) do
            local npos = vector.add(pos, d)
            local node = c.get_node(npos)
            -- força remesh do vizinho
            c.swap_node(npos, node)
        end
    end,
})

c.register_node("nh_nodes:water_flowing", {
    description = S "Flowing Water",
    drawtype = "flowingliquid",
    tiles = { "agua.png" },
    special_tiles = {
        {name = "agua_flowing_animated.png",
            backface_culling = false,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9}},
        {name = "agua_flowing_animated.png",
            backface_culling = true,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9}}},
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_flowing = "nh_nodes:water_flowing",
    liquid_alternative_source = "nh_nodes:water",
    liquid_viscosity = 1,
    post_effect_color = { a = 64, r = 0, g = 0, b = 255 },
    drowning = 1, -- ADICIONEI ESSA LINHA
    groups = {water = 1, liquid = 1, not_in_creative_inventory = 1},
})

c.register_node("nh_nodes:bucket", {
    description = S("Bucket"),
    drawtype = "mesh",
    mesh = "bucket.obj",
    tiles = { "bucket.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    groups = {dig_immediate = 1, falling_node = 1},
    collision_box = { type = "fixed", fixed = { -0.35, -0.5, -0.35, 0.35, 0.5, 0.35 } },
    selection_box = { type = "fixed", fixed = { -0.35, -0.5, -0.35, 0.35, 0.33, 0.35 } },
    wielded_bone_position = {pos = xyz(0.5, -1.2, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    pointabilities = {nodes = WATER_FULLNODES},
    on_place = function(itemstack, placer, pointed_thing)
        if placer:get_player_control().sneak then return c.item_place(itemstack, placer, pointed_thing)
        elseif pointed_thing.type ~= "node" then return itemstack
        end
        local name = c.get_node(pointed_thing.under).name
        if name == "nh_nodes:water" then c.remove_node(pointed_thing.under) return ItemStack("nh_nodes:bucketwater")
        elseif name == "nh_nodes:water2" then c.remove_node(pointed_thing.under) return ItemStack("nh_nodes:bucketwater2")
        elseif name == "nh_nodes:avalanche" or name == "nh_nodes:snow" or name == "nh_nodes:snow_ramp"
            or name == "nh_nodes:snow_corner" or name == "nh_nodes:snow_insidecorner"
            then c.remove_node(pointed_thing.under) return ItemStack("nh_nodes:bucketsnow")
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:bucketwater", {
    description = S("Bucket with Water"),
    drawtype = "mesh",
    mesh = "bucket.obj",
    tiles = { "bucketwater.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    groups = {dig_immediate = 1, falling_node = 1},
    collision_box = {type = "fixed", fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}},
    selection_box = {type = "fixed", fixed = {-0.35, -0.5, -0.35, 0.35, 0.33, 0.35}},
    wielded_bone_position = {pos = xyz(0.5, -1.2, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    pointabilities = {nodes = BUCKET_FLOWING},
    on_place = function(itemstack, placer, pointed_thing)
        if placer:get_player_control().sneak then return c.item_place(itemstack, placer, pointed_thing)
        elseif pointed_thing.type ~= "node" then return itemstack
        end
        local under = pointed_thing.under
        local under_name = c.get_node(under).name
        -- Se apontou num flowing, substitui ele diretamente
        local pos, name
        if under_name == "nh_nodes:water_flowing" or under_name == "nh_nodes:water2_flowing" or under_name == "nh_nodes:avalanche_flowing" then
            pos  = under
            name = under_name
        else
            pos  = pointed_thing.above
            name = c.get_node(pos).name
        end
        if name == "air" or name == "nh_nodes:water_flowing" or name == "nh_nodes:water2_flowing" or name == "nh_nodes:avalanche_flowing"
            then c.set_node(pos, {name = "nh_nodes:water"}) return ItemStack("nh_nodes:bucket")
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:bucketwater2", {
    description = S("Bucket with Fresh Water"),
    drawtype = "mesh",
    mesh = "bucket.obj",
    tiles = {"bucketwater2.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    groups = {dig_immediate = 1, falling_node = 1},
    collision_box = {type = "fixed", fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}},
    selection_box = {type = "fixed", fixed = {-0.35, -0.5, -0.35, 0.35, 0.33, 0.35}},
    wielded_bone_position = {pos = xyz(0.5, -1.2, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    pointabilities = {nodes = BUCKET_FLOWING},
    on_place = function(itemstack, placer, pointed_thing)
        if placer:get_player_control().sneak then return c.item_place(itemstack, placer, pointed_thing)
        elseif pointed_thing.type ~= "node" then return itemstack
        end
        local under = pointed_thing.under
        local under_name = c.get_node(under).name
        -- Se apontou num flowing, substitui ele diretamente
        local pos, name
        if under_name == "nh_nodes:water_flowing" or under_name == "nh_nodes:water2_flowing" or under_name == "nh_nodes:avalanche_flowing" then
            pos  = under
            name = under_name
        else
            pos  = pointed_thing.above
            name = c.get_node(pos).name
        end
        if name == "air" or name == "nh_nodes:water_flowing" or name == "nh_nodes:water2_flowing" or name == "nh_nodes:avalanche_flowing"
            then c.set_node(pos, {name = "nh_nodes:water2"}) return ItemStack("nh_nodes:bucket")
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:bucketsnow", {
    description = S("Bucket with Snow"),
    drawtype = "mesh",
    mesh = "bucket.obj",
    tiles = { "bucketsnow.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 1,
    groups = {dig_immediate = 1, falling_node = 1},
    collision_box = { type = "fixed", fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}},
    selection_box = { type = "fixed", fixed = {-0.35, -0.5, -0.35, 0.35, 0.33, 0.35}},
    wielded_bone_position = {pos = xyz(0.5, -1.2, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)},
    pointabilities = {nodes = BUCKET_FLOWING},
    on_place = function(itemstack, placer, pointed_thing)
        if placer:get_player_control().sneak then return c.item_place(itemstack, placer, pointed_thing)
        elseif pointed_thing.type ~= "node" then return itemstack
        end
        local under = pointed_thing.under
        local under_name = c.get_node(under).name
        -- Se apontou num flowing, substitui ele diretamente
        local pos, name
        if under_name == "nh_nodes:water_flowing" or under_name == "nh_nodes:water2_flowing" or under_name == "nh_nodes:avalanche_flowing" then
            pos  = under
            name = under_name
        else
            pos  = pointed_thing.above
            name = c.get_node(pos).name
        end
        if name == "air" or name == "nh_nodes:water_flowing" or name == "nh_nodes:water2_flowing" or name == "nh_nodes:avalanche_flowing"
            then c.set_node(pos, {name = "nh_nodes:snow"}) return ItemStack("nh_nodes:bucket")
        end
        return itemstack
    end,
})

c.register_node("nh_nodes:barrier", {
    description = S"Barrier",
    drawtype = "glasslike",
    tiles = {"ice2.png"},
    groups = {not_in_creative_inventory = 1},
    --is_ground_content = true,
    use_texture_alpha = "clip", --blend
    --alpha = 200,
    paramtype = "light",
    walkable = true,
    pointable = false,          -- não pode ser selecionado
    diggable = false,           -- inquebrável
    buildable_to = false,
    sunlight_propagates = true, -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice"},
})

c.register_chatcommand("cleardome", {
    privs = {server = true},
    func = function(name)
        local player = c.get_player_by_name(name)
        local pos = player:get_pos()
        local count = 0
        for x = -80, 80 do
            for y = -80, 80 do
                for z = -80, 80 do
                    local p = xyz(math.floor(pos.x + x), math.floor(pos.y + y), math.floor(pos.z + z))
                    if c.get_node(p).name == "nh_nodes:barrier" then
                        c.set_node(p, {name = "air"})
                        count = count + 1
                    end
                end
            end
        end
        return true, count .. " " .. S"barriers removed."
    end
})

-- Gelo
c.register_node("nh_nodes:ice", {
    description = S"Ice",
    drawtype = "glasslike",
    tiles = { "ice2.png" },
    groups = { cracky = 3, slippery = 3 },
    walkable = true,
    --is_ground_content = true,
    use_texture_alpha = "clip", --blend
    --alpha = 200,
    paramtype = "light",
    sunlight_propagates = true, -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice"},
    drop = "nh_nodes:ice2",
})

c.register_node("nh_nodes:ice2", {
    description = S "Ice",
    drawtype = "glasslike",
    tiles = { "ice.png" },
    groups = {cracky = 3, slippery = 3},
    walkable = true,
    --is_ground_content = true,
    use_texture_alpha = "blend", --blend
    --alpha = 200,
    paramtype = "light",
    sunlight_propagates = true, -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice"},
    pointabilities = {nodes = water_nodes},
    -- Quando o nó é colocado, verifica se está na água
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer and placer:is_player() then
            local ctrl = placer:get_player_control()
            if ctrl.sneak then return end
        end
        -- Sem agachar: vira entidade normalmente
        if is_water_near(pos) then
            c.remove_node(pos)
            c.add_entity(pos, "nh_mob:iceberg")
        end
    end,
    -- Cobre o caso de água chegar até o nó depois que ele já está parado
    on_flood = function(pos, oldnode, newnode)
        c.remove_node(pos)
        c.add_entity(pos, "nh_mob:iceberg")
        return false
    end,
})

c.register_node("nh_nodes:ice2ramp", {
    description = S "Ice Ramp",
    drawtype = "mesh",
    mesh = "grass_slope.obj",
    tiles = {"ice2ramp.png"},
    groups = {cracky = 3, slippery = 3},
    walkable = true,
    --is_ground_content = true,
    use_texture_alpha = "blend", --blend
    --alpha = 200,
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true, -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice2"},
    selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0,  0.0,  0.5, 0.5, 0.5}}},
    collision_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, {-0.5, 0.0,  0.0,  0.5, 0.5, 0.5}}},
    pointabilities = {nodes = water_nodes},
    -- Quando o nó é colocado, verifica se está na água
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer and placer:is_player() then
            local ctrl = placer:get_player_control()
            if ctrl.sneak then return end
        end
        -- Sem agachar: vira entidade normalmente
        if is_water_near(pos) then
            c.remove_node(pos)
            c.add_entity(pos, "nh_mob:iceberg")
        end
    end,
    -- Cobre o caso de água chegar até o nó depois que ele já está parado
    on_flood = function(pos, oldnode, newnode)
        c.remove_node(pos)
        c.add_entity(pos, "nh_mob:iceberg")
        return false
    end,
})

c.register_node("nh_nodes:water2", {
    description = S "Fresh Water",
    drawtype = "liquid",
    tiles = { "water2.png" },
    tiles = {{name = "water2_animated.png",
        backface_culling = false,
        animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 4 }}, "water2.png"},
    --special_tiles = {{name = "agua2_animated.png", animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=0.9}},},
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:water2_flowing",
    liquid_alternative_source = "nh_nodes:water2",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 0, g = 0, b = 255},
    drowning = 1, 
    groups = {water = 1, liquid = 1},
})

c.register_node("nh_nodes:water2_flowing", {
    description = S "Flowing Fresh Water",
    drawtype = "flowingliquid",
    tiles = { "water2.png" },
    special_tiles = {
        {name = "agua2_flowing_animated.png",
            backface_culling = false,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9}},
        {name = "agua2_flowing_animated.png", -- Corrigido (estava agua_flowing)
            backface_culling = true,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9}},
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_flowing = "nh_nodes:water2_flowing",
    liquid_alternative_source = "nh_nodes:water2",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 0, g = 0, b = 255},
    drowning = 1, 
    groups = {water = 1, liquid = 1, not_in_creative_inventory = 1},
})


c.register_node("nh_nodes:basalt", {
    description = S "Basalt",
    tiles = { "basalt.png" },
    groups = {cracky = 2},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})

c.register_node("nh_nodes:basalt_ramp", {
    description = S "Basalt Ramp",
    paramtype   = "light",
    paramtype2  = "facedir",
    drawtype    = "mesh",
    mesh        = "grass_slope.obj",
    tiles       = { "basalt_slope.png" },
    groups      = {cracky = 2, soil = 1, falling_node = 1, not_blocking_trains = 1 },
    drop        = "nh_nodes:basalt",
    sounds      = {
        footstep = { name = "punchtimber3", gain = 0.5 },
        dug      = { name = "punchtimber3", gain = 0.5 },
        dig      = { name = "punchtimber3", gain = 0.5 },
        place    = { name = "punchtimber3", gain = 0.5 },},
    sunlight_propagates = true,
    --sounds = nh_nodes.sounds.dirt,
    selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5 }, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5}}},
    collision_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5 }, {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5}}},
})

c.register_node("nh_nodes:basalt_corner", {
    description         = S"Basalt Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grass_vertix.obj",
    tiles               = {"basalt_slope.png"},
    groups              = {cracky = 2, soil = 1, falling_node = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:basalt",
    sounds              = {
        footstep = { name = "punchtimber3", gain = 0.5 },
        dug      = { name = "punchtimber3", gain = 0.5 },
        dig      = { name = "punchtimber3", gain = 0.5 },
        place    = { name = "punchtimber3", gain = 0.5 },},
    sunlight_propagates = true,
    --sounds = nh_nodes.sounds.dirt,

    collision_box       = {type = "fixed", fixed = {
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5}, -- Topo
            {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5}, -- Base principal
            {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0}, -- Base braço 1
            {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
    selection_box       = {type = "fixed", fixed = {
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5}, -- topo
            {-0.5, -0.5, 0.0,  0.0, 0.0, 0.5}, -- Base principal
            {-0.5, -0.5, -0.5, 0.0, 0.0, 0.0}, -- Base braço 1
            {0.5,  -0.5, 0.0,  0.0, 0.0, 0.5}}}, -- Base braço 2
})

c.register_node("nh_nodes:basalt_insidecorner", {
    description         = S "Basalt Inside Corner",
    paramtype           = "light",
    paramtype2          = "facedir",
    drawtype            = "mesh",
    mesh                = "grassinsidecorner.obj",
    tiles               = {"basalt_slope.png"},
    groups              = {cracky = 3, soil = 1, falling_node = 1, not_blocking_trains = 1},
    drop                = "nh_nodes:basalt",
    sounds              = {
        footstep = {name = "punchtimber3", gain = 0.5},
        dug      = {name = "punchtimber3", gain = 0.5},
        dig      = {name = "punchtimber3", gain = 0.5},
        place    = {name = "punchtimber3", gain = 0.5}},
    sunlight_propagates = true,
    --sounds = nh_nodes.sounds.dirt,  -- ajuste para o som correto do seu mod
    collision_box       = {type = "fixed", fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- Base completa (metade inferior)
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5}, -- Topo braço 1: faixa traseira (Z-)
            {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0}, -- Topo braço 1: faixa traseira (Z-)
            {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}}, -- Topo braço 2: faixa lateral (X-)
    selection_box       = {type = "fixed", fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
            {-0.5, 0.0,  0.0,  0.0, 0.5, 0.5},
            {-0.5, 0.0,  -0.5, 0.0, 0.5, 0.0},
            {0.5,  0.0,  0.0,  0.0, 0.5, 0.5}}},
})

c.register_node("nh_nodes:magma", {
    description = S "Magma",
    tiles = { "magma.png" },
    groups = {cracky = 1, hot = 1},
    wielded_bone_position = {pos = xyz(0.5, 0.5, 1.65)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1.5, 0, 0)}, -- Configuração mão esquerda
})

-- ABM: Lava + água fluindo = basalto
c.register_abm({
    label = "Lava solidifica em basalto ou obsidiana",
    nodenames = { "nh_nodes:lava", "nh_nodes:lava_flowing", "nh_nodes:bluelava", "nh_nodes:bluelava_flowing" },
    neighbors = { "nh_nodes:water", "nh_nodes:water2", "nh_nodes:water_flowing", "nh_nodes:water2_flowing" },
    interval = 1,
    chance = 1,
    action = function(pos, node)
        local directions = {
            xyz(0, 1,  0), xyz(1,  0, 0), xyz(0, 0, 1),
            xyz(0, -1, 0), xyz(-1, 0, 0), xyz(0, 0, -1)}
        local is_source = (node.name == "nh_nodes:lava" or node.name == "nh_nodes:bluelava")
        local is_flowing = (node.name == "nh_nodes:lava_flowing" or node.name == "nh_nodes:bluelava_flowing")
        for _, dir in ipairs(directions) do
            local neighbor_pos = vector.add(pos, dir)
            local neighbor = c.get_node(neighbor_pos)
            local is_water_source = (neighbor.name == "nh_nodes:water" or neighbor.name == "nh_nodes:water2")
            local is_water_flowing = (neighbor.name == "nh_nodes:water_flowing" or neighbor.name == "nh_nodes:water2_flowing")
            if is_source and is_water_source then
                -- Lava/bluelava source + água source = obsidiana, água some
                c.set_node(pos, { name = "nh_nodes:obsidian" })
                c.set_node(neighbor_pos, { name = "air" })
                return
            elseif is_source and is_water_flowing then
                -- Lava/bluelava source + água flowing = obsidiana, água some
                c.set_node(pos, { name = "nh_nodes:obsidian" })
                c.set_node(neighbor_pos, { name = "air" })
                return
            elseif is_flowing and is_water_source then
                -- Lava/bluelava flowing + qualquer água = gneiss, água some
                c.set_node(pos, { name = "nh_nodes:basalt" })
                c.set_node(neighbor_pos, { name = "air" })
                return
            elseif is_flowing and is_water_flowing then
                -- Lava/bluelava flowing + qualquer água = gneiss, água some
                c.set_node(pos, { name = "nh_nodes:gneiss" })
                c.set_node(neighbor_pos, { name = "air" })
                return
            end
        end
    end,
})

c.register_node("nh_nodes:lava", {
    description = S "Lava",
    drawtype = "liquid",
    tiles = { "lava.png" },
    tiles = {{name = "lava_animated.png",
        backface_culling = false,
        animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}}, "lava.png"}, -- resto das faces
    use_texture_alpha = "blend",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:lava_flowing",
    liquid_alternative_source = "nh_nodes:lava",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 255, g = 0, b = 0},
    groups = {lava = 1, liquid = 1, hot = 1},
})

c.register_node("nh_nodes:lava_flowing", {
    description = S "Flowing Lava",
    drawtype = "flowingliquid",
    tiles = { "lava.png" },
    special_tiles = {
        {name = "lava_flowing_animated.png",
            backface_culling = false,
            animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9 }},
        {name = "lava_flowing_animated.png",
            backface_culling = true,
            animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9 }},
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_flowing = "nh_nodes:lava_flowing",
    liquid_alternative_source = "nh_nodes:lava",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 255, g = 0, b = 0},
    groups = {lava = 1, liquid = 1, hot = 1, not_in_creative_inventory = 1},
})

c.register_node("nh_nodes:bluelava", {
    description = S "Blue Lava",
    drawtype = "liquid",
    tiles = { "bluelava.png" },
    tiles = {{name = "bluelava_animated.png",
        backface_culling = false,
        animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 4.0}}, "bluelava.png"}, -- resto das faces
    use_texture_alpha = "blend",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:bluelava_flowing",
    liquid_alternative_source = "nh_nodes:bluelava",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 255, g = 0, b = 0},
    groups = {lava = 1, liquid = 1, hot = 1},
})

c.register_node("nh_nodes:bluelava_flowing", {
    description = S "Flowing Blue Lava",
    drawtype = "flowingliquid",
    tiles = {"bluelava.png"},
    special_tiles = {
        {name = "bluelava_flowing_animated.png",
            backface_culling = false,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9}},
        {name = "bluelava_flowing_animated.png",
            backface_culling = true,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.9}},
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_flowing = "nh_nodes:bluelava_flowing",
    liquid_alternative_source = "nh_nodes:bluelava",
    liquid_viscosity = 1,
    post_effect_color = {a = 64, r = 255, g = 0, b = 0},
    groups = {lava = 1, liquid = 1, hot = 1, not_in_creative_inventory = 1},
})

-- ABM que verifica jogadores próximos ao nó de magma
c.register_abm({
    label = "Magma damage",
    nodenames = { "nh_nodes:magma" },
    interval = 1.0, -- checa a cada 1 segundo
    chance = 1,     -- 100% de chance de executar
    action = function(pos, node)
        -- Pega todos os objetos em raio de 1 bloco (toca as faces)
        local objects = c.get_objects_inside_radius(pos, 1.1)
        for _, obj in ipairs(objects) do
            if obj:is_player() then obj:set_hp(obj:get_hp() - 2) end -- tira 1 coração por segundo
        end
    end,
})

-- Limpa o timer quando jogador sai
c.register_on_leaveplayer(function(player)
    lava_damage_timer[player:get_player_name()] = nil
    portal_cooldown[player:get_player_name()] = nil
end)

c.register_abm({
    label = "Lava damage",
    nodenames = {"nh_nodes:lava", "nh_nodes:lava_flowing"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node)
        local objects = c.get_objects_inside_radius(pos, 1.1)
        for _, obj in ipairs(objects) do
            if obj:is_player() then
                -- Evita double damage se já está dentro (coberto pelo globalstep)
                local ppos = obj:get_pos()
                local feet = c.get_node(xyz(ppos.x, ppos.y, ppos.z))
                local head = c.get_node(xyz(ppos.x, ppos.y + 1, ppos.z))
                local inside = feet.name == "nh_nodes:lava" or
                    feet.name == "nh_nodes:lava_flowing" or
                    head.name == "nh_nodes:lava" or
                    head.name == "nh_nodes:lava_flowing"
                if not inside then obj:set_hp(obj:get_hp() - 11) end
            end
        end
    end,
})

-- Node para Pena (deitada no chão, orientada ao player em Y)
c.register_node("nh_nodes:feather", {
    description = S"Feather",
    drawtype = "nodebox",
    tiles = {"feathernode.png"},
    inventory_image = "feather.png",
    wield_image = "feather.png",
    wield_scale = xyz(0.4, 0.4, 0.01),
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "blend",
    node_box = {type = "fixed", fixed = {-0.15, -0.5, -0.45, 0.15, -0.48, 0.45}},
    selection_box = {type = "fixed", fixed = {-0.15, -0.5, -0.45, 0.15, -0.45, 0.45}},
    groups = {dig_immediate = 1, flammable = 2, not_in_creative_inventory = 1}, 
    drop = "",
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:feather")
            if inv:room_for_item("main", itemstack) then inv:add_item("main", itemstack)
            else c.add_item(pos, itemstack)
            end
        end
    end,
})
c.override_item("nh_items:feather", {
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local under = pointed_thing.under
        local above = pointed_thing.above
        local dir = vector.subtract(above, under)
        if dir.y ~= 1 then return itemstack end
        if c.is_protected(above, placer:get_player_name()) then return itemstack end
        if c.get_node(above).name ~= "air" then return itemstack end
        local yaw = placer:get_look_horizontal()
        local idx = math.floor((yaw + math.pi / 4) / (math.pi / 2)) % 4
        local yaw_to_facedir = {[0] = 0, [1] = 3, [2] = 2, [3] = 1}
        local param2 = yaw_to_facedir[idx] or 0
        c.set_node(above, {name = "nh_nodes:feather", param2 = param2})
        c.sound_play("default_place_node", {pos = above, gain = 0.6})
        if not c.is_creative_enabled(placer:get_player_name()) then itemstack:take_item() end
        return itemstack
    end,
})

c.register_node("nh_nodes:inkbottle", {
    description = S "Bottle with Ink",
    inventory_image = "inkbottle.png",
    drawtype = "mesh",
    mesh = "bottle.obj",
    tiles = { "inkbottletexture.png" },
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    collision_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
    selection_box = {type = "fixed", fixed = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 }},
})

-- Função auxiliar para verificar se o jogador tem os itens necessários
-- Retorna quantos slots da hotbar estão ativos para este jogador
local function get_active_hotbar_size(player)
    local inv = player:get_inventory()
    local waist_stack = inv:get_stack("armor_waist", 1)
    local has_belt = not waist_stack:is_empty()
    return has_belt and 8 or 2
end
writing_utils = {}
function writing_utils.player_has_writing_tools(player)
    local inv = player:get_inventory()
    local has_feather = false
    local has_ink = false
    local slots = get_active_hotbar_size(player)
    for i = 1, slots do
        local stack = inv:get_stack("main", i)
        if stack:get_name() == "nh_items:feather" then has_feather = true break end
    end
    if inv:contains_item("main", "nh_nodes:inkbottle") then has_ink = true end
    return has_feather, has_ink
end
function writing_utils.consume_ink(player)
    local inv = player:get_inventory()
    inv:remove_item("main", "nh_nodes:inkbottle")
    inv:add_item("main", "nh_nodes:bottle")
end
function player_has_writing_tools(player)
    local inv = player:get_inventory()
    local has_feather = false
    local has_ink = false
    local slots = get_active_hotbar_size(player)
    -- Verifica se tem pena nos slots visíveis da hotbar
    for i = 1, slots do
        local stack = inv:get_stack("main", i)
        if stack:get_name() == "nh_items:feather" then has_feather = true break end
    end
    -- Verifica se tem tinta em qualquer lugar do inventário
    if inv:contains_item("main", "nh_nodes:inkbottle") then has_ink = true end
    return has_feather, has_ink
end
function consume_ink(player)
    local inv = player:get_inventory()
    -- Remove um frasco de tinta e devolve frasco vazio
    inv:remove_item("main", "nh_nodes:inkbottle")
    inv:add_item("main", "nh_nodes:bottle")
end

-- Papeis
-- Node para Página em branco
c.register_node("nh_nodes:page", {
    description = S"Paper",
    drawtype = "mesh",
    mesh = "page.obj",
    tiles = { "page.png" },
    inventory_image = "page.png",
    wield_image = "page.png",
    wield_scale = xyz(0.5, 0.5, 0.01),
    visual_scale = 1.0,
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "clip",
    selection_box = {type = "wallmounted",
        wall_top = {-0.31, -0.49, -0.44, 0.31, -0.45, 0.44},
        wall_bottom = {-0.31, 0.5, -0.44, 0.31, 0.49, 0.44},
        wall_side = {0.5, -0.44, -0.31, 0.49, 0.44, 0.31}},
    groups = {oddly_breakable_by_hand = 3, flammable = 3, not_in_creative_inventory = 1},
    drop = "",
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local node_meta = c.get_meta(pos)
        local node_draft = node_meta:get_string("text") or ""
        local pos_key = "node:" .. c.pos_to_string(pos)
        local session = items.editing_pages[player_name]
        -- Só reusa sessão se veio deste mesmo node
        local draft = (session and session.source == pos_key and session.text ~= "" and session.text) or node_draft
        items.editing_pages[player_name] = {text = draft, source = pos_key}
        local has_feather, has_ink = writing_utils.player_has_writing_tools(clicker)
        if not has_feather or not has_ink then
            local read_text = draft ~= "" and draft or ""
            local title = draft ~= "" and S"Paper" .. c.colorize("#4af", " [" .. S"Draft" .. "]") or S"Blank Paper"
            c.show_formspec(player_name, "nh_nodes:page_reader:" .. c.pos_to_string(pos),
                "size[10,13.5]" ..
                "label[0.3,0;" .. c.formspec_escape(title) .. "]" ..
                "textarea[0.3,0.5;10,14;page_text;;" .. c.formspec_escape(read_text) .. "]" ..
                "button_exit[4,12.5;2,1;close;" .. S"Close" .. "]")
            local msg = S"I think I need "
            if not has_feather and not has_ink then msg = msg .. S"a feather in the main hotbar and an ink bottle in the inventory to write."
            elseif not has_feather then msg = msg .. S"a feather in the main hotbar to write."
            else msg = msg .. S"an ink bottle in the inventory to write."
            end
            c.chat_send_player(player_name, msg)
            return
        end
        -- Sincroniza sessão com o rascunho mais recente ao abrir
        items.editing_pages[player_name].text = draft
        local subtitle_label = ""
        if draft ~= "" then subtitle_label = c.colorize("#4af", "[" .. S"Draft" .. "]") end
        c.show_formspec(player_name, "nh_nodes:page_writer:" .. c.pos_to_string(pos),
            "size[10,14.5]" ..
            "label[0.3,0;" .. S"Blank Paper" .. "]" ..
            "label[0.3,0.3;" .. c.formspec_escape(subtitle_label) .. "]" ..
            "button_exit[8,0.1;2,0.8;close;" .. S"Close" .. "]" ..
            "textarea[0.3,1;10,14;page_text;;" .. c.formspec_escape(draft) .. "]" ..
            "button[3,13;2,1;save;" .. S"Save" .. "]" ..
            "button[5,13;2,1;finish;" .. S"Finish" .. "]" ..
            "label[3.3,13.9;" .. S"Save to avoid losing the draft" .. "]")
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:page")
            local draft = oldmetadata.fields.text or ""
            if draft ~= "" then
                local player_name = digger:get_player_name()
                -- Só sobrescreve a sessão se não houver rascunho mais recente nela
                local session = items.editing_pages[player_name]
                if not session or session.text == "" then items.editing_pages[player_name] = {text = draft, source = "item"} end
                items.update_page_draft(itemstack, draft)
            end
            if inv:room_for_item("main", itemstack) then inv:add_item("main", itemstack)
            else c.add_item(pos, itemstack)
            end
        end
    end,
})

c.register_node("nh_nodes:page_floor", {
    -- mesmas propriedades do nh_nodes:page...
    description = S"Paper",
    drawtype = "mesh",
    mesh = "page.obj",
    tiles = { "page.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "clip",
    selection_box = {type = "fixed", fixed = {-0.31, 0.5, -0.44, 0.31, 0.46, 0.44}},
    groups = {oddly_breakable_by_hand = 3, flammable = 3, not_in_creative_inventory = 1},
    drop = "",
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local node_meta = c.get_meta(pos)
        local node_draft = node_meta:get_string("text") or ""
        local pos_key = "node:" .. c.pos_to_string(pos)
        local session = items.editing_pages[player_name]
        -- Só reusa sessão se veio deste mesmo node
        local draft = (session and session.source == pos_key and session.text ~= "" and session.text) or node_draft
        items.editing_pages[player_name] = {text = draft, source = pos_key}
        local has_feather, has_ink = writing_utils.player_has_writing_tools(clicker)
        if not has_feather or not has_ink then
            local read_text = draft ~= "" and draft or ""
            local title = draft ~= "" and S"Paper" .. c.colorize("#4af", " [" .. S"Draft" .. "]") or S"Blank Paper"
            c.show_formspec(player_name, "nh_nodes:page_floor_reader:" .. c.pos_to_string(pos),
                "size[10,13.5]" ..
                "label[0.3,0;" .. c.formspec_escape(title) .. "]" ..
                "textarea[0.3,0.5;10,14;page_text;;" .. c.formspec_escape(read_text) .. "]" ..
                "button_exit[4,12.5;2,1;close;" .. S"Close" .. "]")
            local msg = S"I think I need "
            if not has_feather and not has_ink then msg = msg .. S"a feather in the hotbar and an ink bottle in the inventory to write."
            elseif not has_feather then msg = msg .. S"a feather in the hotbar to write."
            else msg = msg .. S"an ink bottle in the inventory to write."
            end
            c.chat_send_player(player_name, msg)
            return
        end
        -- Sincroniza sessão com o rascunho mais recente ao abrir
        items.editing_pages[player_name].text = draft
        local subtitle_label = ""
        if draft ~= "" then subtitle_label = c.colorize("#4af", "[" .. S"Draft" .. "]") end
        c.show_formspec(player_name, "nh_nodes:page_writer:" .. c.pos_to_string(pos),
            "size[10,14.5]" ..
            "label[0.3,0;" .. S"Blank Paper" .. "]" ..
            "label[0.3,0.3;" .. c.formspec_escape(subtitle_label) .. "]" ..
            "button_exit[8,0.1;2,0.8;close;" .. S"Close" .. "]" ..
            "textarea[0.3,1;10,14;page_text;;" .. c.formspec_escape(draft) .. "]" ..
            "button[3,13;2,1;save;" .. S"Save" .. "]" ..
            "button[5,13;2,1;finish;" .. S"Finish" .. "]" ..
            "label[3.3,13.9;" .. S"Save to avoid losing the draft" .. "]")
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:page")
            local draft = oldmetadata.fields.text or ""
            if draft ~= "" then
                local player_name = digger:get_player_name()
                -- Só sobrescreve a sessão se não houver rascunho mais recente nela
                local session = items.editing_pages[player_name]
                if not session or session.text == "" then items.editing_pages[player_name] = {text = draft, source = "item"} end
                items.update_page_draft(itemstack, draft)
            end
            if inv:room_for_item("main", itemstack) then inv:add_item("main", itemstack)
            else c.add_item(pos, itemstack)
            end
        end
    end,
})
 
c.override_item("nh_items:page", {
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local under = pointed_thing.under
        local above = pointed_thing.above
        if c.is_protected(above, placer:get_player_name()) then return itemstack end
        local node = c.get_node(above)
        if node.name ~= "air" then return itemstack end
        local dir = vector.subtract(above, under)
        local wallmounted = c.dir_to_wallmounted(dir)
        if wallmounted == 0 then
            -- Chão: face top para cima (facedir face 5 = índice 20-23)
            local yaw = placer:get_look_horizontal()
            local rot = math.floor((yaw + math.pi / 4) / (math.pi / 2)) % 4
            c.set_node(above, { name = "nh_nodes:page_floor", param2 = 20 + rot })
        elseif wallmounted == 1 then
            -- Teto: face bottom para baixo (facedir face 4 = índice 16-19)
            local yaw = placer:get_look_horizontal()
            local rot = math.floor((yaw + math.pi / 4) / (math.pi / 2)) % 4
            c.set_node(above, { name = "nh_nodes:page_floor", param2 = 16 + rot })
        else c.set_node(above, { name = "nh_nodes:page", param2 = wallmounted })
        end
        local player_name = placer:get_player_name()
        local session = items.editing_pages[player_name]
        local draft = (session and session.text ~= "" and session.text) or itemstack:get_meta():get_string("text") or ""
        if draft ~= "" then
            local meta = c.get_meta(above)
            meta:set_string("text", draft)
            meta:set_string("infotext", S"Paper" .. " [" .. S"Draft" .. "]")
        end
        c.sound_play("default_place_node", {pos = above, gain = 1})
        if not c.is_creative_enabled(player_name) then itemstack:take_item() end
        return itemstack
    end,
})
 
c.register_node("nh_nodes:writedpage", {
    description = S"Written Paper",
    drawtype = "mesh",
    mesh = "page2.obj",
    tiles = {"writedpage.png"},
    inventory_image = "writedpage.png",
    wield_image = "writedpage.png",
    wield_scale = xyz(0.5, 0.5, 0.01),
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "clip",
    selection_box = { type = "wallmounted",
        wall_top = {-0.31, -0.49, -0.44, 0.31, -0.45, 0.44},
        wall_bottom = {-0.31, 0.5, -0.44, 0.31, 0.49, 0.44},
        wall_side = {0.5, -0.44, -0.31, 0.49, 0.44, 0.31}},
    groups = {oddly_breakable_by_hand = 3, flammable = 3, not_in_creative_inventory = 1},
    drop = "",
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local meta = c.get_meta(pos)
        local text = meta:get_string("text")
        if text == "" then text = S"Blank Paper" end
        c.show_formspec(player_name, "nh_nodes:page_reader",
            "size[10,13.5]" ..
            "label[0.3,0;" .. S"Written Paper" .. "]" ..
            "textarea[0.3,0.5;10,14;page_text;;" .. c.formspec_escape(text) .. "]" ..
            "button_exit[4,12.5;2,1;close;" .. S"Close" .. "]")
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:writedpage")
            local meta = itemstack:get_meta()
            meta:set_string("text", oldmetadata.fields.text or "")
            if inv:room_for_item("main", itemstack) then inv:add_item("main", itemstack)
            else c.add_item(pos, itemstack)
            end
        end
    end,
})

c.register_node("nh_nodes:writedpage_floor", {
    -- mesmas propriedades do nh_nodes:page...
    description = S"Paper",
    drawtype = "mesh",
    mesh = "page2.obj",
    tiles = {"writedpage.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "clip",
    selection_box = {type = "fixed", fixed = {-0.31, 0.5, -0.44, 0.31, 0.46, 0.44}},
    groups = {oddly_breakable_by_hand = 3, flammable = 3, not_in_creative_inventory = 1},
    drop = "",
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local meta = c.get_meta(pos)
        local text = meta:get_string("text")
        if text == "" then text = S"Blank Paper" end
        c.show_formspec(player_name, "nh_nodes:page_reader",
            "size[10,13.5]" ..
            "label[0.3,0;" .. S"Written Paper" .. "]" ..
            "textarea[0.3,0.5;10,14;page_text;;" .. c.formspec_escape(text) .. "]" ..
            "button_exit[4,12.5;2,1;close;" .. S"Close" .. "]")
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:writedpage")
            local meta = itemstack:get_meta()
            meta:set_string("text", oldmetadata.fields.text or "")
            if inv:room_for_item("main", itemstack) then inv:add_item("main", itemstack)
            else c.add_item(pos, itemstack)
            end
        end
    end,
})
 
c.override_item("nh_items:writedpage", {
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local under = pointed_thing.under
        local above = pointed_thing.above
        if c.is_protected(above, placer:get_player_name()) then return itemstack end
        local node = c.get_node(above)
        if node.name ~= "air" then return itemstack end
        local dir = vector.subtract(above, under)
        local wallmounted = c.dir_to_wallmounted(dir)
        if wallmounted == 0 then
            -- Chão: face top para cima (facedir face 5 = índice 20-23)
            local yaw = placer:get_look_horizontal()
            local rot = math.floor((yaw + math.pi / 4) / (math.pi / 2)) % 4
            c.set_node(above, {name = "nh_nodes:writedpage_floor", param2 = 20 + rot})
        elseif wallmounted == 1 then
            -- Teto: face bottom para baixo (facedir face 4 = índice 16-19)
            local yaw = placer:get_look_horizontal()
            local rot = math.floor((yaw + math.pi / 4) / (math.pi / 2)) % 4
            c.set_node(above, { name = "nh_nodes:writedpage_floor", param2 = 16 + rot })
        else c.set_node(above, {name = "nh_nodes:writedpage", param2 = wallmounted})
        end
        c.sound_play("default_place_node", {pos = above, gain = 1})
        local item_meta = itemstack:get_meta()
        local node_meta = c.get_meta(above)
        node_meta:set_string("text", item_meta:get_string("text"))
        if not c.is_creative_enabled(placer:get_player_name()) then itemstack:take_item() end
        return itemstack
    end,
})
 
if not nodes then nodes = {} end
 
function nodes.place_written_page(pos, text, facedir)
    c.set_node(pos, {name = "nh_nodes:writedpage", param2 = facedir})
    local meta = c.get_meta(pos)
    meta:set_string("text", text)
end
 
-- Handler para o formspec do node nh_nodes:page
c.register_on_player_receive_fields(function(player, formname, fields)
    local prefix = "nh_nodes:page_writer:"
    if formname:sub(1, #prefix) ~= prefix then return end
    local player_name = player:get_player_name()
    local pos_str = formname:sub(#prefix + 1)
    local pos = c.string_to_pos(pos_str)
    -- Sempre sincroniza o texto digitado com a sessão compartilhada
    if fields.page_text ~= nil then
        local session = items.editing_pages[player_name] or {}
        items.editing_pages[player_name] = {text = fields.page_text, source = session.source}
    end
    if fields.quit or fields.close then return end
    -- SAVE: persiste o rascunho tanto na sessão quanto na meta do node
    if fields.save then
        local text = (items.editing_pages[player_name] and items.editing_pages[player_name].text) or ""
        if text == "" then c.chat_send_player(player_name, S"I didn't write anything!") return end
        if pos then
            local node = c.get_node(pos)
            if node.name == "nh_nodes:page" or node.name == "nh_nodes:page_floor" then
                local meta = c.get_meta(pos)
                meta:set_string("text", text)
                meta:set_string("infotext", S"Paper" .. " [" .. S"Draft" .. "]")
            end
        end
        local subtitle_label = c.colorize("#4af", "[" .. S"Draft" .. "]")
        c.show_formspec(player_name, formname,
            "size[10,14.5]" ..
            "label[0.3,0;" .. S"Blank Paper" .. "]" ..
            "label[0.3,0.3;" .. c.formspec_escape(subtitle_label) .. "]" ..
            "button_exit[8,0.1;2,0.8;close;" .. S"Close" .. "]" ..
            "textarea[0.3,1;10,14;page_text;;" .. c.formspec_escape(text) .. "]" ..
            "button[3,13;2,1;save;" .. S"Save" .. "]" ..
            "button_exit[5,13;2,1;finish;" .. S"Finish" .. "]" ..
            "label[3.3,13.9;" .. S"Save to avoid losing the draft" .. "]")
        c.chat_send_player(player_name, S"Draft saved!")
        return
    end
    -- FINISH: converte o node nh_nodes:page em nh_nodes:writedpage definitivamente
    if fields.finish then
        local text = (items.editing_pages[player_name] and items.editing_pages[player_name].text) or ""
        if text == "" then c.chat_send_player(player_name, S"I didn't write anything!") return end
        local has_feather, has_ink = writing_utils.player_has_writing_tools(player)
        if not has_feather or not has_ink then c.chat_send_player(player_name, S"I no longer have the necessary items!") return end
        if not pos then return end
        local node = c.get_node(pos)
        local target_node = nil
        if node.name == "nh_nodes:page" then target_node = "nh_nodes:writedpage"
        elseif node.name == "nh_nodes:page_floor" then target_node = "nh_nodes:writedpage_floor"
        end
        if target_node then
            c.set_node(pos, {name = target_node, param2 = node.param2})
            local meta = c.get_meta(pos)
            meta:set_string("text", text)
            meta:set_string("infotext", "")
            writing_utils.consume_ink(player)
            items.editing_pages[player_name] = nil
            c.chat_send_player(player_name, S"Paper written successfully!")
        end
        return
    end
end)
 

-- Helpers locais para livros
local MAX_PAGES = 8
local editing_books = {}
-- Sistema de entidades animadas para livros
-- Mapa: node_name → textura da entidade
local BOOK_ENTITY_TEXTURES = {
    ["nh_nodes:book"]        = "blankbook.png",
    ["nh_nodes:writedbook"]  = "bookwritten.png",
    ["nh_nodes:craftguide"]  = "manual.png"}
-- Guarda: player_name → {entity, node_pos, node_param2, node_name}
local open_book_entities = {}
-- Converte facedir → yaw (igual ao do Archion)
local function facedir_to_yaw(param2) local dir = c.facedir_to_dir(param2) return math.atan2(-dir.x, dir.z) end
c.register_node("nh_nodes:book_invisible", {
    description    = "Invisible Book Placeholder",
    drawtype       = "airlike",
    paramtype      = "light",
    paramtype2     = "facedir",
    sunlight_propagates = true,
    walkable       = false,
    pointable      = false,
    diggable       = false,
    buildable_to   = false,
    groups         = {not_in_creative_inventory = 1},
    drop           = "",
})
-- Entidade genérica de livro animado
c.register_entity("nh_nodes:book_entity", {
    initial_properties = {
        visual       = "mesh",
        mesh         = "grimorie.glb",
        textures     = {"blankbook.png"}, -- substituída ao spawnar
        visual_size  = {x = 10, y = 10},
        collisionbox = {0, 0, 0, 0, 0, 0},
        physical     = false,
        static_save  = false},
    on_activate = function(self, staticdata)
        -- Animação de abertura (igual ao Archion)
        self.object:set_animation({x = 0, y = 0.5}, 30, 0, false)
        self._closing = false
    end,
    on_step = function(self, dtime)
        if not self._closing then return end
        self._close_timer = (self._close_timer or 0) + dtime
        if self._close_timer >= 0.6 then
            if self._node_pos and self._node_name then
                local current = c.get_node(self._node_pos)
                -- Só restaura se ainda for o placeholder invisível
                if current.name == "nh_nodes:book_invisible" then
                    c.swap_node(self._node_pos, {name = self._node_name, param2 = self._node_param2 or 0})
                end
            end
            self.object:remove()
        end
    end,
})

--- Spawna a entidade animada sem substituir o node por air.
local function spawn_book_entity(pos, node_name, player_name)
    local node      = c.get_node(pos)
    local node_param2 = node.param2
    local texture   = BOOK_ENTITY_TEXTURES[node_name] or "blankbook.png"
    -- Troca para invisível SEM apagar a meta
    c.swap_node(pos, {name = "nh_nodes:book_invisible", param2 = node_param2})
    local obj = c.add_entity(pos, "nh_nodes:book_entity")
    if not obj then c.swap_node(pos, {name = node_name, param2 = node_param2}) return nil end
    obj:set_properties({textures = {texture}})
    obj:set_yaw(facedir_to_yaw(node_param2 % 4))
    local ent         = obj:get_luaentity()
    ent._node_pos     = vector.copy(pos)
    ent._node_param2  = node_param2
    ent._node_name    = node_name
    ent._player_name  = player_name
    open_book_entities[player_name] = {
        entity      = obj,
        node_pos    = vector.copy(pos),
        node_param2 = node_param2,
        node_name   = node_name,
    }
    return obj
end


--- Fecha a entidade animada (animação de fechamento + restaura node).
local function close_book_entity(player_name)
    local data = open_book_entities[player_name]
    if not data then return end
    local obj = data.entity
    if obj and obj:get_pos() then
        local ent = obj:get_luaentity()
        if ent then
            obj:set_animation({x = 0.5, y = 1}, 30, 0, false)
            ent._closing     = true
            ent._close_timer = 0
        else obj:remove()
        end
    end
    open_book_entities[player_name] = nil
end

-- Limpeza ao deslogar
c.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    local data = open_book_entities[name]
    if data then
        if data.entity and data.entity:get_pos() then data.entity:remove() end
        -- Restaura se ainda for o placeholder
        local current = c.get_node(data.node_pos)
        if current.name == "nh_nodes:book_invisible" then
            c.swap_node(data.node_pos, {name = data.node_name, param2 = data.node_param2})
        end
        open_book_entities[name] = nil
    end
    local pos = player:get_pos()
    if pos then
        for _, obj in ipairs(c.get_objects_inside_radius(pos, 10)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:book_entity" and ent._player_name == name then
                if ent._node_pos and ent._node_name then
                    local current = c.get_node(ent._node_pos)
                    if current.name == "nh_nodes:book_invisible" then
                        c.swap_node(ent._node_pos, {name = ent._node_name, param2 = ent._node_param2 or 0})
                    end
                end
                obj:remove()
            end
        end
    end
    editing_books[name] = nil
end)

-- ─── Formspecs ─────────────────────────────────────────────────────────────
local function book_formspec(title, title2, title3, pages, current, editable)
    local page_text = pages[current] or ""
    local nav_prev  = current > 1        and "button[0.1,13;1.5,0.8;prev;<]"  or ""
    local nav_next  = current < MAX_PAGES and "button[8.4,13;1.5,0.8;next;>]" or ""
    local page_label = S"Page" .. " " .. current .. "/" .. MAX_PAGES

    if editable then return
        "size[10,14.5]" ..
        "label[0.3,-0.1;"  .. c.formspec_escape(title)      .. "]" ..
        "label[0.3,0.2;"   .. c.formspec_escape(title2)     .. "]" ..
        "label[4.1,1;"     .. page_label                    .. "]" ..
        "field[2.5,0.3;5,0.8;title_input;;" .. c.formspec_escape(title3) .. "]" ..
        "label[3.3,13.9;"  .. S"Save to avoid losing the draft" .. "]" ..
        "textarea[0.3,1.5;10,13;page_text;;" .. c.formspec_escape(page_text) .. "]" ..
        nav_prev ..
        "button_exit[8,0.1;2,0.8;close;" .. S"Close" .. "]" ..
        "button[3,13;2,0.8;save;"   .. S"Save"   .. "]" ..
        "button[5,13;2,0.8;finish;" .. S"Finish" .. "]" ..
        nav_next
    else return
        "size[10,14]" ..
        "label[0.3,-0.1;" .. c.formspec_escape(title)  .. "]" ..
        "label[0.3,0.2;"  .. c.formspec_escape(title3) .. "]" ..
        "label[4.1,0.3;"  .. page_label                .. "]" ..
        "textarea[0.3,0.8;10,14;page_text;;" .. c.formspec_escape(page_text) .. "]" ..
        nav_prev ..
        "button_exit[4,13;2,0.8;close;" .. S"Close" .. "]" ..
        nav_next
    end
end

local function book_confirm_formspec() return 
    "size[6,3]" ..
    "label[0.5,0.3;" .. c.formspec_escape(S"No title was given to this book.") .. "]" ..
    "label[0.5,0.9;" .. c.formspec_escape(S"Continue without a title?")        .. "]" ..
    "button[0.5,1.8;2,0.8;confirm_back;"   .. S"Return" .. "]" ..
    "button_exit[3.5,1.8;2,0.8;confirm_finish;" .. S"Finish" .. "]"
end

-- Serialização de páginas
local function pages_to_string(pages)
    local parts = {}
    for i = 1, MAX_PAGES do parts[i] = pages[i] or "" end
    return table.concat(parts, "\31")
end

local function string_to_pages(str)
    local pages = {}
    local i = 1
    for part in (str .. "\31"):gmatch("(.-)\31") do
        pages[i] = part
        i = i + 1
        if i > MAX_PAGES then break end
    end
    for j = i, MAX_PAGES do pages[j] = "" end
    return pages
end

local function meta_read_book(meta)
    local pages   = string_to_pages(meta:get_string("pages"))
    local current = tonumber(meta:get_int("current_page")) or 1
    if current < 1 then current = 1 end
    if current > MAX_PAGES then current = MAX_PAGES end
    return pages, current
end

-- ─── Helper: abre o formspec E spawna a entidade ────────────────────────────
-- Centraliza a lógica de "fecha o anterior, spawna o novo, exibe o formspec"
local function open_book_with_animation(pos, node_name, player, formname, title, title2, title3, pages, current, editable)
    local player_name = player:get_player_name()
    -- Fecha eventual entidade já aberta por este jogador
    close_book_entity(player_name)
    -- Spawna animação
    spawn_book_entity(pos, node_name, player_name)
    -- Salva sessão
    editing_books[player_name] = {
        pos     = vector.new(pos),
        pages   = table.copy(pages),
        current = current,
        title   = title,
        title2  = title2,
        title3  = title3,
    }
    -- Exibe formspec
    c.show_formspec(player_name, formname .. ":" .. c.pos_to_string(pos),
        book_formspec(title, title2, title3, pages, current, editable))
end

-- ─── Hook: fecha a entidade quando o formspec é fechado ─────────────────────
-- Captura o "quit" de QUALQUER formspec de livro para fechar a entidade
c.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    -- Detecta formspecs de livro (reader, writer, confirm)
    local is_book_form = formname:find("^nh_nodes:book_reader:") or formname:find("^nh_nodes:book_writer:") or formname:find("^nh_nodes:book_confirm:")
    if is_book_form and (fields.quit or fields.close) then close_book_entity(name) end
end)

-- CAPA (bookcover)
c.register_node("nh_nodes:bookcover", {
    description           = S("Book Cover"),
    drawtype              = "mesh",
    mesh                  = "grimorie.obj",
    tiles                 = {"bookcover.png"},
    paramtype             = "light",
    paramtype2            = "facedir",
    sunlight_propagates   = true,
    walkable              = false,
    use_texture_alpha     = "clip",
    wielded_bone_position = {pos = xyz(0.5, -1, 1.15),  rot = xyz(90, 0, 90)},
    wielded_visual_size   = xyz(0.2),
    offhand_bone_position = {pos = xyz(0.5, -1, -1.15), rot = xyz(-90, 0, 270)},
    collision_box         = {type = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}},
    selection_box         = {type = "fixed", fixed = {-0.375, -0.5, -0.5, 0.375, -0.25, 0.5}},
    groups                = {oddly_breakable_by_hand = 3, flammable = 3},
    on_rightclick         = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        c.chat_send_player(clicker:get_player_name(), S("Just a book cover..."))
    end,
})

-- LIVRO EM BRANCO (book)
c.register_node("nh_nodes:book", {
    description           = S("Blank Book"),
    drawtype              = "mesh",
    mesh                  = "grimorie.obj",
    tiles                 = {"blankbook.png"},
    stack_max             = 8,
    paramtype             = "light",
    paramtype2            = "facedir",
    sunlight_propagates   = true,
    walkable              = false,
    use_texture_alpha     = "clip",
    wielded_bone_position = {pos = xyz(0.5, -1, 1.15),  rot = xyz(90, 0, 90)},
    wielded_visual_size   = xyz(0.2),
    offhand_bone_position = {pos = xyz(0.5, -1, -1.15), rot = xyz(-90, 0, 270)},
    collision_box         = {type = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}},
    selection_box         = {type = "fixed", fixed = {-0.375, -0.5, -0.5, 0.375, -0.25, 0.5}},
    groups                = {oddly_breakable_by_hand = 3, flammable = 3},
    drop                  = "",
    on_rightclick         = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local meta        = c.get_meta(pos)
        local pages, current = meta_read_book(meta)
        local has_content = false
        local title       = meta:get_string("title")
        for _, p in ipairs(pages) do if p ~= "" then has_content = true; break end end
        local title2        = has_content and c.colorize("#4af", S("Draft")) or ""
        local saved_subtitle = meta:get_string("subtitle")
        local title3_edit   = saved_subtitle ~= "" and saved_subtitle or S"Title"
        local title3_read   = saved_subtitle ~= "" and c.colorize("#4af", S"Draft" .. ": " .. saved_subtitle) or ""
        if title == "" then title = S"Blank Book" end
        -- Verifica ferramentas de escrita
        local has_feather, has_ink = writing_utils.player_has_writing_tools(clicker)
        if not has_feather or not has_ink then
            local msg = S"I think I need "
            if not has_feather and not has_ink then msg = msg .. S"a feather in the hotbar and an ink bottle in the inventory to write."
            elseif not has_feather then msg = msg .. S"a feather in the hotbar to write."
            else msg = msg .. S"an ink bottle in the inventory to write."
            end
            c.chat_send_player(player_name, msg)
            -- Leitura mesmo sem ferramentas — com animação
            open_book_with_animation(pos, "nh_nodes:book", clicker, "nh_nodes:book_reader", title, title2, title3_read, pages, current, false)
            return
        end
        -- Modo edição — com animação
        open_book_with_animation(pos, "nh_nodes:book", clicker, "nh_nodes:book_writer", title, title2, title3_edit, pages, current, true)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv      = digger:get_inventory()
            local drop     = ItemStack("nh_nodes:book")
            local dmeta    = drop:get_meta()
            local subtitle = oldmetadata.fields.subtitle or ""
            dmeta:set_string("pages",    oldmetadata.fields.pages or "")
            dmeta:set_string("title",    oldmetadata.fields.title or "")
            dmeta:set_string("subtitle", subtitle)
            dmeta:set_int   ("current_page", 1)
            local desc = S"Blank Book"
            if subtitle ~= "" then desc = desc .. "\n" .. c.colorize("#9f0", "[" .. S"Draft" .. "] " .. subtitle) end
            dmeta:set_string("description", desc)
            if inv:room_for_item("main", drop) then inv:add_item("main", drop)
            else c.add_item(pos, drop) end
        end
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local pos = pointed_thing.above
        if not pos then return itemstack end
        local imeta = itemstack:get_meta()
        c.set_node(pos, {name = "nh_nodes:book", param2 = c.dir_to_facedir(placer:get_look_dir())})
        local nmeta = c.get_meta(pos)
        nmeta:set_string("pages",    imeta:get_string("pages"))
        nmeta:set_string("title",    imeta:get_string("title"))
        nmeta:set_string("subtitle", imeta:get_string("subtitle"))
        nmeta:set_int   ("current_page", 1)
        itemstack:take_item()
        return itemstack
    end,
})

-- ─── LIVRO ESCRITO (writedbook) ─────────────────────────────────────────────
c.register_node("nh_nodes:writedbook", {
    description           = S"Written Book",
    drawtype              = "mesh",
    mesh                  = "grimorie.obj",
    tiles                 = {"bookwritten.png"},
    stack_max             = 1,
    paramtype             = "light",
    paramtype2            = "facedir",
    sunlight_propagates   = true,
    walkable              = false,
    use_texture_alpha     = "clip",
    wielded_bone_position = {pos = xyz(0.5, -1, 1.15),  rot = xyz(90, 0, 90)},
    wielded_visual_size   = xyz(0.2),
    offhand_bone_position = {pos = xyz(0.5, -1, -1.15), rot = xyz(-90, 0, 270)},
    collision_box         = {type = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}},
    selection_box         = {type = "fixed", fixed = {-0.375, -0.5, -0.5, 0.375, -0.25, 0.5}},
    groups                = {oddly_breakable_by_hand = 3, flammable = 3},
    drop                  = "",
    on_rightclick         = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local meta        = c.get_meta(pos)
        local pages, current = meta_read_book(meta)
        local title  = meta:get_string("title")
        if title == "" then title = S"Written Book" end
        local title2 = meta:get_string("author")
        local title3 = c.colorize("#4af", meta:get_string("subtitle"))
        -- Leitura com animação
        open_book_with_animation(pos, "nh_nodes:writedbook", clicker, "nh_nodes:book_reader", title, title2, title3, pages, current, false)
    end,
    after_dig_node        = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv      = digger:get_inventory()
            local drop     = ItemStack("nh_nodes:writedbook")
            local dmeta    = drop:get_meta()
            local subtitle = oldmetadata.fields.subtitle or ""
            dmeta:set_string("pages",    oldmetadata.fields.pages or "")
            dmeta:set_string("title",    oldmetadata.fields.title or "")
            dmeta:set_string("subtitle", subtitle)
            dmeta:set_string("author",   oldmetadata.fields.author or "")
            dmeta:set_int   ("current_page", 1)
            local desc = S("Written Book")
            if subtitle ~= "" then desc = desc .. ":\n" .. c.colorize("#9f0", subtitle) end
            dmeta:set_string("description", desc)
            if inv:room_for_item("main", drop) then inv:add_item("main", drop)
            else c.add_item(pos, drop) end
        end
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local pos = pointed_thing.above
        if not pos then return itemstack end
        local imeta = itemstack:get_meta()
        c.set_node(pos, {name = "nh_nodes:writedbook", param2 = c.dir_to_facedir(placer:get_look_dir())})
        local nmeta = c.get_meta(pos)
        nmeta:set_string("pages",    imeta:get_string("pages"))
        nmeta:set_string("title",    imeta:get_string("title"))
        nmeta:set_string("subtitle", imeta:get_string("subtitle"))
        nmeta:set_string("author",   imeta:get_string("author"))
        nmeta:set_int   ("current_page", 1)
        itemstack:take_item()
        return itemstack
    end,
})

-- HANDLERS DE FORMSPEC DOS LIVROS
c.register_on_player_receive_fields(function(player, formname, fields)
    -- ── Leitor genérico (writedbook + book sem ferramentas + craftguide) ──
    local reader_prefix = "nh_nodes:book_reader:"
    if formname:sub(1, #reader_prefix) == reader_prefix then
        local pos_str = formname:sub(#reader_prefix + 1)
        local pos     = c.string_to_pos(pos_str)
        if not pos then return end
        local meta    = c.get_meta(pos)
        local name    = player:get_player_name()
        local session = editing_books[name]
        if not session then
            local p, cpage = meta_read_book(meta)
            local t = meta:get_string("title")
            if t == "" then t = S("Written Book") end
            session = {pos = vector.new(pos), pages = table.copy(p), current = cpage, title = t}
            editing_books[name] = session
        end
        local title  = session.title
        local title2 = session.title2 or ""
        local title3 = session.title3 or ""
        local node_name = c.get_node(pos).name
        -- Se o node virou "air" (entidade spawnou), usa o nome guardado na sessão
        if node_name == "air" then
            local data = open_book_entities[name]
            if data then node_name = data.node_name end
        end
        if node_name == "nh_nodes:book" and title3 ~= "" then title3 = c.colorize("#4af", S"Draft" .. ": " .. title3)
        end
        local pages   = session.pages
        local current = session.current
        if fields.quit or fields.close then
            close_book_entity(name)
            editing_books[name] = nil
            return
        elseif fields.prev and current > 1 then
            current = current - 1
            session.current = current
            meta:set_int("current_page", current)
            c.show_formspec(name, formname, book_formspec(title, title2, title3, pages, current, false))
        elseif fields.next and current < MAX_PAGES then
            current = current + 1
            session.current = current
            meta:set_int("current_page", current)
            c.show_formspec(name, formname, book_formspec(title, title2, title3, pages, current, false))
        end
        return
    end

    -- ── Editor (book com ferramentas) ──
    local writer_prefix = "nh_nodes:book_writer:"
    if formname:sub(1, #writer_prefix) == writer_prefix then
        local pos_str = formname:sub(#writer_prefix + 1)
        local pos     = c.string_to_pos(pos_str)
        if not pos then return end
        local player_name = player:get_player_name()
        local session     = editing_books[player_name]
        if not session then return end
        local meta  = c.get_meta(pos)
        local title = meta:get_string("title")
        if title == "" then title = S("Blank Book") end
        -- Persiste page_text sempre que chegar, inclusive no quit
        if fields.page_text ~= nil then
            session.pages[session.current] = fields.page_text
            meta:set_string("pages", pages_to_string(session.pages))
            meta:set_int("current_page", session.current)
        end
        if fields.quit then
            meta:set_string("pages", pages_to_string(session.pages))
            meta:set_int("current_page", session.current)
            close_book_entity(player_name)
            return
        elseif fields.close then
            meta:set_string("pages", pages_to_string(session.pages))
            meta:set_int("current_page", session.current)
            close_book_entity(player_name)
            editing_books[player_name] = nil
            return
        elseif fields.save then
            -- Persiste o texto da página atual ANTES de tudo
            if fields.page_text ~= nil then
                session.pages[session.current] = fields.page_text
            end
            if fields.title_input ~= nil then
                session.title3 = fields.title_input
                meta:set_string("subtitle", fields.title_input)
            end
            -- Salva páginas na meta do node (que pode estar como air, mas a meta persiste)
            meta:set_string("pages", pages_to_string(session.pages))
            meta:set_int("current_page", session.current)
            local title2 = session.title2 or ""
            local title3 = session.title3 or ""
            c.chat_send_player(player_name, S"Draft saved!")
            c.show_formspec(player_name, formname, book_formspec(session.title, title2, title3, session.pages, session.current, true))
        elseif fields.finish then
            if fields.page_text then session.pages[session.current] = fields.page_text end
            if fields.title_input ~= nil then session.title3 = fields.title_input end
            local input_title = session.title3 or ""
            if input_title == "" or input_title == S"Title" then
                -- Salva sessão na meta antes de trocar de formspec
                meta:set_string("pages", pages_to_string(session.pages))
                c.show_formspec(player_name, "nh_nodes:book_confirm:" .. c.pos_to_string(pos), book_confirm_formspec())
            else
                local data   = open_book_entities[player_name]
                local param2 = data and data.node_param2 or 0
                writing_utils.consume_ink(player)
                close_book_entity(player_name)
                c.set_node(pos, {name = "nh_nodes:writedbook", param2 = param2})
                local new_meta = c.get_meta(pos)
                new_meta:set_string("pages",    pages_to_string(session.pages))  -- DA SESSÃO
                new_meta:set_string("subtitle", input_title)
                new_meta:set_string("author",   player_name)
                new_meta:set_int   ("current_page", 1)
                editing_books[player_name] = nil
            end
            return
        elseif fields.prev and session.current > 1 then
            if fields.title_input ~= nil then
                session.title3 = fields.title_input
                meta:set_string("subtitle", fields.title_input)
            end
            session.current = session.current - 1
            meta:set_string("pages", pages_to_string(session.pages))
            meta:set_int("current_page", session.current)
            c.show_formspec(player_name, formname,
                book_formspec(session.title, session.title2 or "", session.title3 or "", session.pages, session.current, true))
        elseif fields.next and session.current < MAX_PAGES then
            if fields.title_input ~= nil then
                session.title3 = fields.title_input
                meta:set_string("subtitle", fields.title_input)
            end
            session.current = session.current + 1
            meta:set_string("pages", pages_to_string(session.pages))
            meta:set_int("current_page", session.current)
            c.show_formspec(player_name, formname,
                book_formspec(session.title, session.title2 or "", session.title3 or "", session.pages, session.current, true))
        end
        return
    end

    -- ── Confirmação de finalização sem título ──
    local confirm_prefix = "nh_nodes:book_confirm:"
    if formname:sub(1, #confirm_prefix) == confirm_prefix then
        local pos_str = formname:sub(#confirm_prefix + 1)
        local pos     = c.string_to_pos(pos_str)
        if not pos then return end
        local player_name = player:get_player_name()
        local session     = editing_books[player_name]
        if not session then return end
        local meta = c.get_meta(pos)
        if fields.confirm_back then c.show_formspec(player_name, "nh_nodes:book_writer:" .. c.pos_to_string(pos),
            book_formspec(session.title, session.title2 or "", session.title3 or "", session.pages, session.current, true))
elseif fields.confirm_finish or fields.quit then
    local final_title = (session.title3 == nil or session.title3 == "" or session.title3 == S("Title")) and "?" or session.title3
    -- USA A SESSÃO, não meta:get_string("pages") que pode estar corrompida
    local pages_data  = pages_to_string(session.pages)
    local data        = open_book_entities[player_name]
    local param2      = data and data.node_param2 or 0
    writing_utils.consume_ink(player)
    close_book_entity(player_name)
    c.set_node(pos, {name = "nh_nodes:writedbook", param2 = param2})
    local new_meta = c.get_meta(pos)
    new_meta:set_string("pages",    pages_data)
    new_meta:set_string("subtitle", final_title)
    new_meta:set_string("author",   player_name)
    new_meta:set_int   ("current_page", 1)
    editing_books[player_name] = nil
        end
        return
    end
end)

-- ─── Função utilitária geral ────────────────────────────────────────────────
if not nodes then nodes = {} end
function nodes.place_written_book(pos, title, pages_table, facedir)
    c.set_node(pos, {name = "nh_nodes:writedbook", param2 = facedir or 0})
    local meta = c.get_meta(pos)
    meta:set_string("title",  title or "")
    meta:set_string("pages",  pages_to_string(pages_table or {}))
    meta:set_int   ("current_page", 1)
end

-- ─── GUIA DE PRODUÇÃO (craftguide) ─────────────────────────────────────────
local craftguide_pages = {
    -- Page 1
    "\n" .. S"PRODUCTION GUIDE"
    .. "\n\n" .. S"CRAFTING:"
    .. "\n" .. S"The recipes ahead do not depend on position in the grid. Only quantities and tools matter.",
    -- Page 2
    "\n" .. S"1. GROUND CRAFTS"
    .. "\n\n" .. S"Hold E (or Aux1) and click the ground with the place button."
    .. "\n\n" .. S"Production Items:"
    .. "\n" .. S"(1) Gray Pebble [tool] + (1) Gray Pebble     → Chipped Stone"
    .. "\n" .. S"(1) Gray Pebble [tool] + (1) Obsidian Pebble → Obsidian Blade"
    .. "\n" .. S"(1) Gray Pebble [tool] + (1) Chipped Stone   → Stone Axe Head"
    .. "\n" .. S"(1) Gray Pebble [tool] + (1) Axe Head        → Stone Pickaxe Head"
    .. "\n" .. S"(1) Gray Pebble [tool] + (1) Pickaxe Head    → Stone Hoe Head"
    .. "\n" .. S"(1) Gray Pebble [tool] + (1) Hoe Head        → Stone Adze Head"
    .. "\n" .. S"(8) Gray Pebble → Cobblestone",
    -- Page 3
    "\n" .. S"3. GROUND CRAFTS"
    .. "\n\n" .. S"Basic Tools:"
    .. "\n" .. S"(1) Axe Head + (1) Limb + (1) Palm Straw   → Stone Axe"
    .. "\n" .. S"(1) Pickaxe Head + (1) Limb + (1) Palm Straw → Stone Pickaxe"
    .. "\n" .. S"(1) Hoe Head + (1) Limb + (1) Palm Straw   → Stone Hoe"
    .. "\n" .. S"(1) Adze Head + (1) Limb + (1) Palm Straw  → Stone Adze"
    .. "\n" .. S"(1) Chipped Stone + (1) Stick + (1) Palm Straw → Chipped Stone Knife"
    .. "\n" .. S"(1) Obsidian Blade + (1) Stick + (1) Palm Straw → Obsidian Knife"
    .. "\n" .. S"(1) Stick + (1) Palm Straw → Campfire Tinder"
    .. "\n" .. S"(1) Palm Leaf + (1) Stick + (1) Oak Resin + (1) Grass Leaves → Torch"
    .. "\n" .. S"(1) Ink Sack + (1) Bottle → Bottle with Ink"
    .. "\n" .. S"(1) Writed Paper + (1) Bottle → Bottle with Message",
    -- Page 4
    "\n" .. S"4. GROUND CRAFTS"
    .. "\n\n" .. S"(1) Oak Log → (16) Oak Firewood"
    .. "\n" .. S"(1) Pine Log → (16) Pine Firewood"
    .. "\n" .. S"(1) Palm Log → (4) Palm Firewood"
    .. "\n" .. S"(1) Oak Log + (1) Stone Adze (TOOL) → Oak Wood"
    .. "\n" .. S"(1) Pine Log + (1) Stone Adze (TOOL) → Pine Wood",
    -- Page 5
    "\n" .. S"5. GROUND CRAFTS"
    .. "\n\n" .. S"Worked Wood Items:"
    .. "\n" .. S"(1) Oak Wood → (8) Oak Board"
    .. "\n" .. S"(2) Oak Wood → (4) Oak Plank"
    .. "\n" .. S"(1) Oak Board → (8) Oak Dowel"
    .. "\n" .. S"(3) Board + (2) Dowel + (2) Gray Pebble → Oak Door"
    .. "\n" .. S"(1) Oak Dowel + (1) Oak Board → Rowing"
    .. "\n" .. S"(8) Obsidian Blade + (1) Rowing (TOOL) → Obsidian Sword"
    .. "\n" .. S"(2) Dowel + (2) Board → Production Bench",
    -- Page 6
    "\n" .. S"PRODUCTION BENCH"
    .. "\n" .. S"(also includes ground craft recipes)"
    .. "\n\n" .. S"(5) Oak Board → Bucket"
    .. "\n" .. S"(6) Oak Board → Oak Chest"
    .. "\n\n" .. S"Stationery:"
    .. "\n" .. S"(1) Bull Fur → Book Cover"
    .. "\n" .. S"(6) Rush + (1) Bucket with Water (TOOL) → Paper"
    .. "\n" .. S"(8) Paper + (1) Book Cover (TOOL) → Book"
    .. "\n\n" .. S"Specials:"
    .. "\n" .. S"(1) Book + (1) Red Crystal + (1) Sphere (TOOL) → Archion"
    .. "\n" .. S"(1) Shrimp Claw + (1) Sphere (TOOL) → Dimensional Claw"
    .. "\n" .. S"(1) Wings + (1) Sphere (TOOL) → Gravity Wings"
    .. "\n\n" .. S"Basic Clothing:"
    .. "\n" .. S"(2) Bull Fur → Leather Gloves"
    .. "\n" .. S"(1) Bull Fur + (1) Gloves → Like Glove"
    .. "\n" .. S"(2) Bull Fur + (1) Gloves → Point Glove"
    .. "\n" .. S"(2) Bull Fur + (1) Dowel → Basic Belt"
    .. "\n" .. S"(2) Belt + (1) Chest → Backpack Chest"
    .. "\n" .. S"(3) Bull Fur → Leather Helmet"
    .. "\n" .. S"(4) Bull Fur → Leather Boots"
    .. "\n" .. S"(5) Bull Fur → Leather Leggings"
    .. "\n" .. S"(7) Bull Fur → Leather Chestplate"
    .. "\n" .. S"(8) Cobblestone → Furnace",
    -- Page 7
    "\n" .. S"CAMPFIRE"
    .. "\n" .. S"(Only works when lit)"
    .. "\n\n" .. S"How to make a campfire:"
    .. "\n" .. S"1. Place a Campfire Tinder on the ground"
    .. "\n" .. S"2. Place 4 identical Firewood pieces on the tinder"
    .. "\n" .. S"3. Use a Lit Torch to ignite the campfire"
    .. "\n\n" .. S"Recipes:"
    .. "\n" .. S"(1) Chicken Egg → Fried Egg"
    .. "\n" .. S"(1) Raw Chicken → Roast Chicken"
    .. "\n" .. S"(1) Raw Tuna    → Roast Tuna"
    .. "\n" .. S"(1) Raw Beef    → Roast Beef",
    -- Page 8
    "\n" .. S"FURNACE"
    .. "\n\n" .. S"Direct Production:"
    .. "\n" .. S"(9) Oak Log   → (9) Charcoal"
    .. "\n" .. S"(9) Pine Log  → (9) Charcoal"
    .. "\n" .. S"(9) Palm Log  → (9) Smaller Charcoal"
    .. "\n\n" .. S"Costs 1 Charcoal:"
    .. "\n" .. S"(9) Chicken Egg   → (9) Fried Eggs"
    .. "\n" .. S"(9) Raw Chicken   → (9) Roast Chicken"
    .. "\n" .. S"(9) Raw Tuna      → (9) Roast Tuna"
    .. "\n" .. S"(9) Raw Beef      → (9) Roast Beef"
    .. "\n\n" .. S"Costs 1 Coal Nugget:"
    .. "\n" .. S"(3) Copper Nugget → Copper Ingot"
    .. "\n" .. S"(3) Tin Nugget    → Tin Ingot"
    .. "\n" .. S"(3) Iron Nugget   → Iron Ingot"
    .. "\n" .. S"(2) Copper Ingot → Copper Gauntlets"
    .. "\n" .. S"(3) Copper Ingot → Copper Helmet"
    .. "\n" .. S"(4) Copper Ingot → Copper Sabatons"
    .. "\n" .. S"(5) Copper Ingot → Copper Leggings"
    .. "\n" .. S"(6) Copper Ingot → Copper Vambraces"
    .. "\n" .. S"(7) Copper Ingot → Copper Chestplate"
    .. "\n" .. S"(3) Iron Ingot + (1) Coal Nugget + (1) Paper → Grenade"
    .. "\n" .. S"(8) Sand   → (8) Glass"
    .. "\n" .. S"(3) Glass + (1) Dowel → (6) Bottle"
    .. "\n" .. S"(4) Glass + (1) Chromium Ingot → (4) Mirror",
}

c.register_node("nh_nodes:craftguide", {
    description           = S("Craft Guide"),
    drawtype              = "mesh",
    mesh                  = "grimorie.obj",
    tiles                 = {"manual.png"},
    stack_max             = 1,
    paramtype             = "light",
    paramtype2            = "facedir",
    sunlight_propagates   = true,
    walkable              = false,
    use_texture_alpha     = "clip",
    wielded_bone_position = {pos = xyz(0.5, -1, 1.15),  rot = xyz(90, 0, 90)},
    wielded_visual_size   = xyz(0.2),
    offhand_bone_position = {pos = xyz(0.5, -1, -1.15), rot = xyz(-90, 0, 270)},
    collision_box = {type = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}},
    selection_box = {type = "fixed", fixed = {-0.375, -0.5, -0.5, 0.375, -0.25, 0.5}},
    groups = {oddly_breakable_by_hand = 3, flammable = 3},
    drop = "nh_nodes:craftguide",
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end
        local player_name = clicker:get_player_name()
        local meta        = c.get_meta(pos)
        local pages, current = meta_read_book(meta)
        local title  = S("Craft Guide")
        local title2 = S("The Survivor's Handbook")
        local title3 = c.colorize("#4af", S"Recipes & Crafting")
        -- Leitura com animação
        open_book_with_animation(pos, "nh_nodes:craftguide", clicker,
            "nh_nodes:book_reader", title, title2, title3, pages, current, false)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv  = digger:get_inventory()
            local drop = ItemStack("nh_nodes:craftguide")
            if inv:room_for_item("main", drop) then inv:add_item("main", drop)
            else c.add_item(pos, drop) end
        end
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local pos = pointed_thing.above
        if not pos then return itemstack end
        c.set_node(pos, {name = "nh_nodes:craftguide", param2 = c.dir_to_facedir(placer:get_look_dir())})
        local nmeta = c.get_meta(pos)
        nmeta:set_string("pages",    pages_to_string(craftguide_pages))
        nmeta:set_string("title",    "Craft Guide")
        nmeta:set_string("subtitle", "Recipes & Crafting")
        nmeta:set_string("author",   "System")
        nmeta:set_int   ("current_page", 1)
        itemstack:take_item()
        return itemstack
    end,
})

function nodes.place_craftguide(pos, facedir)
    c.set_node(pos, {name = "nh_nodes:craftguide", param2 = facedir or 0})
    local meta = c.get_meta(pos)
    meta:set_string("pages",    pages_to_string(craftguide_pages))
    meta:set_string("title",    "Craft Guide")
    meta:set_string("subtitle", "Recipes & Crafting")
    meta:set_string("author",   "System")
    meta:set_int   ("current_page", 1)
end

-- GRIMÓRIO DE MATERIALIZAÇÃO (Archion)
local ITEMS_PER_PAGE  = 40
local GRID_W          = 8
local GRID_H          = 5
local item_cache      = {}
local item_desc_index = {} -- [lang_code][item_name] = {desc_traduzida, desc_original}
local function build_item_cache()
    if next(item_cache) then return end
    for name, def in pairs(c.registered_items) do
        if name ~= "" and not ((def.groups or {}).not_in_creative_inventory == 1) then table.insert(item_cache, name) end
    end
    table.sort(item_cache)
end

local function ensure_desc_index(lang_code)
    if item_desc_index[lang_code] then return end
    item_desc_index[lang_code] = {}
    for _, name in ipairs(item_cache) do
        local def        = c.registered_items[name]
        local raw_desc   = (def and def.description) or ""
        -- Traduz a description completa para o idioma do jogador
        local translated = c.get_translated_string(lang_code, raw_desc)
        local original   = raw_desc
        -- Indexa TODAS as linhas (nome principal + subtítulos como [Mob Spawner])
        local terms      = {}
        for line in (translated .. "\n"):gmatch("([^\n]*)\n") do
            local trimmed = line:match("^%s*(.-)%s*$") -- remove espaços
            if trimmed ~= "" then table.insert(terms, trimmed:lower()) end
        end
        -- Adiciona também as linhas originais em inglês como fallback
        for line in (original .. "\n"):gmatch("([^\n]*)\n") do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" then table.insert(terms, trimmed:lower()) end
        end
        item_desc_index[lang_code][name] = terms
    end
end

local function filter_items(search, lang_code)
    build_item_cache()
    if not search or search == "" then return item_cache end
    lang_code = lang_code or "en"
    ensure_desc_index(lang_code)
    local result = {}
    local term   = search:lower()
    local index  = item_desc_index[lang_code]
    for _, name in ipairs(item_cache) do
        local matched = name:lower():find(term, 1, true)
        if not matched and index[name] then
            for _, desc in ipairs(index[name]) do
                if desc:find(term, 1, true) then matched = true break end
            end
        end
        if matched then table.insert(result, name) end -- corrigido: era `matched` por engano
    end
    return result
end


-- ─── Entidade Grimório ─────────────────────────────────
c.register_entity("nh_nodes:grimoire_entity", {
    initial_properties = {
        visual       = "mesh",
        mesh         = "grimorie.glb",
        textures     = {"grimorie.png"},
        visual_size  = {x = 10, y = 10},
        collisionbox = {0, 0, 0, 0, 0, 0}, -- sem colisão
        physical     = false,
        static_save  = false,                -- não persiste ao reiniciar
    },
    on_activate = function(self, staticdata)
        -- Animação de abertura
        self.object:set_animation({ x = 0, y = 0.5 }, 30, 0, false) -- intervalo de frames, fps, frame_blend,loop
        self._closing = false
    end,
    on_step = function(self, dtime)
        if not self._closing then return end
        self._close_timer = (self._close_timer or 0) + dtime
        if self._close_timer >= 0.6 then
            if self._node_pos then
                local current = c.get_node(self._node_pos)
                if current.name == "nh_nodes:book_invisible" then
                    c.swap_node(self._node_pos, {name = "nh_nodes:archion", param2 = self._node_param2 or 0})
                end
            end
            self.object:remove()
        end
    end,
})
-- Helpers de swap
-- Guarda: player_name → {entity, node_pos, node_param2}
local open_grimoires = {}
local function spawn_grimoire_entity(pos, param2, player_name)
    local node_param2 = c.get_node(pos).param2
    -- swap em vez de set_node — preserva a meta
    c.swap_node(pos, {name = "nh_nodes:book_invisible", param2 = node_param2})
    local obj = c.add_entity(pos, "nh_nodes:grimoire_entity")
    if not obj then c.swap_node(pos, {name = "nh_nodes:archion", param2 = node_param2}) return nil end
    local function facedir_to_yaw(param2)
        local dir = c.facedir_to_dir(param2)
        return math.atan2(-dir.x, dir.z)
    end
    obj:set_yaw(facedir_to_yaw(param2 % 4))
    local ent                   = obj:get_luaentity()
    ent._node_pos               = vector.copy(pos)
    ent._node_param2            = node_param2
    ent._player_name            = player_name
    open_grimoires[player_name] = {entity = obj, node_pos = vector.copy(pos), node_param2 = node_param2}
    return obj
end
local function close_grimoire_entity(player_name)
    local data = open_grimoires[player_name]
    if not data then return end
    local obj = data.entity
    if not obj or not obj:get_pos() then
        local current = c.get_node(data.node_pos)
        if current.name == "nh_nodes:book_invisible" then
            c.swap_node(data.node_pos, {name = "nh_nodes:archion", param2 = data.node_param2})
        end
        open_grimoires[player_name] = nil
        return
    end
    local ent = obj:get_luaentity()
    if not ent then
        obj:remove()
        local current = c.get_node(data.node_pos)
        if current.name == "nh_nodes:book_invisible" then
            c.swap_node(data.node_pos, {name = "nh_nodes:archion", param2 = data.node_param2})
        end
        open_grimoires[player_name] = nil
        return
    end
    obj:set_animation({x = 0.5, y = 1}, 30, 0, false)
    ent._closing     = true
    ent._close_timer = 0
    open_grimoires[player_name] = nil
end
-- Formspec
function show_grimoire(player, page, search)
    page            = page or 1
    search          = search or ""
    local name      = player:get_player_name()
    -- Pega o lang_code do jogador (ex: "pt", "en", "de")
    local info      = c.get_player_information(name)
    local lang_code = (info and info.lang_code) or "en"
    local items     = filter_items(search, lang_code) -- <-- passa lang_code
    local max_page  = math.max(1, math.ceil(#items / ITEMS_PER_PAGE))
    page            = math.min(page, max_page)
    local start     = (page - 1) * ITEMS_PER_PAGE + 1
    -- Verifica se o backchest está equipado para mostrar slots extras
    local has_backchest = player_has_backchest_equipped(player)
    local form_height   = has_backchest and 12 or 9.7
    local fs        = {
        "formspec_version[4]",
        "size[10.4," .. form_height .. "]",
        "label[0.3,0.5;" .. "Archion - " .. S "Complete Materialization Grimoire" .. "]",
        "field[0.3,0.9;6.3,0.8;search;;" .. c.formspec_escape(search) .. "]",
        "field_close_on_enter[search;false]",
        "button[6.7,0.9;1.2,0.8;do_search;" .. S "Search" .. "]",
        "button[8,0.9;1,0.8;prev;<]",
        "label[8.9,0.5;" .. page .. "/" .. max_page .. "]",
        "button[9.1,0.9;1,0.8;next;>]",
    }
    local x0, y0 = 0.3, 2
    local gap     = 1  -- espaço extra no centro
    local half    = GRID_W / 2  -- 4 colunas de cada lado
    local i       = start
    for y = 0, GRID_H - 1 do
        for x = 0, GRID_W - 1 do
            if not items[i] then break end
            local offset = x >= half and gap or 0
            local item_name = items[i]
            local def       = c.registered_items[item_name]
            -- Monta a descrição base já traduzida (ou o displayname como fallback)
            local base_desc = (def and def.description) or item_name
            local translated_desc = c.get_translated_string(lang_code, base_desc)
            -- Acrescenta o nome técnico na última linha
            local tooltip_text = translated_desc .. "\n" .. item_name
            table.insert(fs,
                "item_image_button[" ..
                (x0 + x * 1.1 + offset) .. "," ..
                (y0 + y * 1.1) .. ";1.1,1.1;" ..
                item_name .. ";item_" .. i .. ";]")
            table.insert(fs, "tooltip[item_" .. i .. ";" .. c.formspec_escape(tooltip_text) .. "]")
            i = i + 1 
        end
    end
    if has_backchest then -- Com backchest: mostra slots extras (8x2) + hotbar (8x1)
        table.insert(fs, "list[current_player;main;0.3,7.9;8,2;8]") 
        table.insert(fs, "list[current_player;main;0.3,10.4;8,1;]")
    else table.insert(fs, "list[current_player;main;0.3,8.2;8,1;]") -- Sem backchest: mostra apenas a hotbar (8x1)
    end
    table.insert(fs, "listring[current_player;main]")
    c.show_formspec(name, "nh_nodes:materialization", table.concat(fs))
end
-- Node do grimorio
c.register_node("nh_nodes:archion", {
    description           = S "Archion" .. "\n" .. S "Grimoire of Materialization" .. "\n" .. S "(completed)" .. "\n" .. S "[only active in creative mode]",
    drawtype              = "mesh",
    mesh                  = "grimorie.obj",
    tiles                 = { "grimorie.png" },
    walkable              = false,
    max_stake             = 1,
    paramtype             = "light",
    paramtype2            = "facedir",
    groups                = {oddly_breakable_by_hand = 3, falling_node = 1},
    wielded_bone_position = {pos = xyz(0.5, -1, 1.15), rot = xyz(90, 0, 90)},  -- Configuração mão direita
    wielded_visual_size   = xyz(0.2),
    offhand_bone_position = {pos = xyz(0.5, -1, -1.15), rot = xyz(-90, 0, 270)},
    -- wielded_visual_size = xyz(0.25),
    collision_box         = {type  = "fixed", fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}},
    selection_box         = {type  = "fixed", fixed = {-0.375, -0.5, -0.5, 0.375, -0.25, 0.5}},
    on_rightclick         = function(pos, node, player, itemstack, pointed_thing)
        local controls = player:get_player_control()
        if controls.aux1 then
            if not c.is_creative_enabled(player:get_player_name()) then
                c.chat_send_player(player:get_player_name(), S "[Archion only works in creative mode]")
                return itemstack
            end
            -- Spawna a entidade e abre o formspec
            spawn_grimoire_entity(pos, node.param2, player:get_player_name())
            show_grimoire(player, 1, "")
            return itemstack
        end
        if itemstack and not itemstack:is_empty() then
            local item_def = c.registered_items[itemstack:get_name()]
            if item_def and item_def.type == "node" then return c.item_place_node(itemstack, player, pointed_thing) end
            if item_def and item_def.on_place then
                local safe_pointed = {type  = pointed_thing.type,
                    under = pointed_thing.above,
                    above = pointed_thing.above}
                return item_def.on_place(itemstack, player, safe_pointed)
            end
        end
        if itemstack:is_empty() then c.chat_send_player(player:get_player_name(),
            S "I need to observe (hold 'E' or 'Aux1') and reach the book (click 'place' with empty hands) to open...")
        end
        return itemstack
    end,
})
-- Recebimento de campos 
local player_state = {}
c.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "nh_nodes:materialization" then return end
    local name = player:get_player_name()
    player_state[name] = player_state[name] or { page = 1, search = "" }
    local state = player_state[name]
    -- Fechamento do formspec (clique em X ou pressiona Esc)
    if fields.quit then close_grimoire_entity(name) return end
    if fields.do_search or fields.key_enter_field == "search" then
        state.search = fields.search or ""
        state.page   = 1
        show_grimoire(player, state.page, state.search)
        return
    end
    if fields.next then
        state.page = state.page + 1
        show_grimoire(player, state.page, state.search)
        return
    end
    if fields.prev then
        state.page = math.max(1, state.page - 1)
        show_grimoire(player, state.page, state.search)
        return
    end
    for field, _ in pairs(fields) do
        if field:sub(1, 5) == "item_" then
            local index     = tonumber(field:sub(6))
            local info      = c.get_player_information(name)
            local lang_code = (info and info.lang_code) or "en"
            local items     = filter_items(state.search, lang_code)
            local item      = items[index]
            if item then player:get_inventory():add_item("main", item) end
            return
        end
    end
end)
-- Limpeza ao deslogar 
c.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    -- Caso 1: form ainda aberto — entidade registrada em open_grimoires
    local data = open_grimoires[name]
    if data then
        if data.entity and data.entity:get_pos() then data.entity:remove() end
        c.set_node(data.node_pos, { name = "nh_nodes:archion", param2 = data.node_param2 })
        open_grimoires[name] = nil
    end
    -- Caso 2: animação de fechamento em andamento — close_grimoire_entity já limpou
    -- open_grimoires, mas o on_step ainda não restaurou o node. Varre entidades próximas.
    local pos = player:get_pos()
    if pos then
        for _, obj in ipairs(c.get_objects_inside_radius(pos, 10)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:grimoire_entity"
               and ent._player_name == name
               and ent._node_pos then
                local current = c.get_node(ent._node_pos)
                if current.name == "nh_nodes:book_invisible" then
                    c.swap_node(ent._node_pos, {name = "nh_nodes:archion", param2 = ent._node_param2 or 0})
                end
                obj:remove()
            end
        end
    end
    player_state[name] = nil
end)

c.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    local page = ItemStack("nh_items:writedpage")
    local meta = page:get_meta()
    meta:set_string("text",
        S "THE NEW HORIZON" .. "\n\n" ..
        S "If you're reading this, it's because you've lost your memory or perhaps you've never experienced this before..." .. "\n\n" ..
        S "Walk (directional keys / WASD), jump (hold ↑ / space) and sneak (hold ↓ / shift) to explore." .. "\n" ..
        S "Anywhere you can also:" .. "\n" ..
        "- " .. S "Wall jump (Quick jump x2 in front of small walls, to climb them)" .. "\n\n" ..
        "- " .. S("Vertical climbing (hold jump in front of walls or tree trunks at least 4 blocks high) [If you can't reach a foothold but keep holding jump in contact with the vertical surface, you will fall more slowly sliding down it]") .. "\n\n" ..
        "- " .. S "Crawl (press sneak + hold sneak)" .. "\n" ..
        "- " .. S "Sit (hold sneak + 2x Aux1 / E)" .. "\n" ..
        "- " .. S "Lie down (sitting press: 2x Aux1 / E) [Return to sitting: 2x Aux1 / E]" .. "\n\n" ..
        S "General guide:" .. "\n\n" ..
        "- " .. S "Collect pebbles on the ground to craft a tool" .. "\n" ..
        "- " .. S "Some pebbles create sparks when struck together" .. "\n" ..
        "- " .. S "Try to make fire by spreading a spark onto nearby material" .. "\n" ..
        "- " .. S "Light torches by using them on fire" .. "\n" ..
        "- " .. S "Activate your observation (Aux1 / E) and touch ground blocks to idealize crafts" .. "\n" ..
        "- " .. S("Crafting doesn't depend on the arrangement of the items. Just spread the correct quantities across the grid slots.") .. "\n" ..
        "- " .. S "There are hidden chests around the world, but don't expect great rewards" .. "\n" ..
        "- " .. S "They say there is a lost book called Archion that can grant everything this world has to offer" .. "\n" ..
        "- " .. S "Press T to open the chat and type '/o ' followed by your text if you want to chat with a being called Oz" .. "\n" ..
        "- " .. S "Someone could have summoned the book using their unlimited creative power by saying: '/grantme all' and '/giveme nh_nodes:archion'" .. "\n" ..
        "- " .. S "According to legend, there are also creatures that only appear in specific locations" .. "\n" ..
        "- " .. S "Some tried to escape, but couldn't — this world seems to have no limits." .. "\n" ..
        "- " .. S "Check the other pages if in doubt" .. "\n\n" ..
        S "Good luck..." .. "\n\n" .. 
        "                                                                                                 9")
    inv:set_stack("main", 2, page)
end)

---------
-- Baú geral
-- Monta o formspec do baú dinamicamente conforme o backchest estar equipado
local function build_chest_formspec(clicker)
    local chest_slots = "list[current_name;main;0,0.3;8,2;]"
    local player_slots

    if player_has_backchest_equipped(clicker) then
        player_slots =
            "list[current_player;main;0,5.85;8,2;8]" ..
            "list[current_player;main;0,8.05;8,1;]" ..
            "listring[current_name;main]" ..
            "listring[current_player;main]"
    else
        player_slots =
            "list[current_player;main;0,8.05;8,1;]" ..
            "listring[current_name;main]" ..
            "listring[current_player;main]"
    end

    return "size[8,9]" .. chest_slots .. player_slots
end

-- Função para atualizar itens visuais no baú
-- Mapa de node aberto → nome da entidade do baú correspondente
local CHEST_ENTITY_BY_NODE = {
    ["nh_nodes:oak_chest_open"]  = "nh_nodes:oak_chest_entity",
    ["nh_nodes:back_chest_open"] = "nh_nodes:back_chest_entity",
}

function chest_update_items(pos)
    local node = c.get_node(pos)
    local entity_name = CHEST_ENTITY_BY_NODE[node.name]
    if not entity_name then
        return
    end

    local meta    = c.get_meta(pos)
    local inv     = meta:get_inventory()

    -- Remover entidades de itens antigas
    local objects = c.get_objects_inside_radius(pos, 1)
    for _, obj in ipairs(objects) do
        if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:chest_item" then
            obj:remove()
        end
    end

    -- Procurar a entidade do baú aberto para anexar os itens
    local chest_entity = nil
    for _, obj in ipairs(objects) do
        local luaent = obj:get_luaentity()
        if luaent and luaent.name == entity_name then
            chest_entity = obj
            break
        end
    end

    -- Se não houver entidade do baú, criar uma invisível para servir de base
    if not chest_entity then
        chest_entity = c.add_entity(pos, entity_name)
        if chest_entity and chest_entity:get_luaentity() then
            local luaent        = chest_entity:get_luaentity()
            luaent.node_pos     = pos
            luaent.is_invisible = true
            -- Aplicar rotação
            local yaw           = c.facedir_to_dir(node.param2)
            chest_entity:set_yaw(c.dir_to_yaw(yaw))
        end
    end

    if not chest_entity then
        return
    end

    -- Criar novas entidades para cada item (máximo 16 bones)
    for i = 1, math.min(16, inv:get_size("main")) do
        local stack = inv:get_stack("main", i)
        if not stack:is_empty() then
            local entity = c.add_entity(pos, "nh_nodes:chest_item")
            if entity and entity:get_luaentity() then
                local luaent      = entity:get_luaentity()
                luaent.chest_pos  = pos
                luaent.slot_index = i
                luaent:update_item(stack:get_name())
                -- Anexar ao bone correspondente do baú
                entity:set_attach(chest_entity, "bone" .. i, xyz(0), xyz(0))
            end
        end
    end
end

-- Aliases para compatibilidade retroativa (redirecionam para chest_update_items)
oak_chest_update_items  = chest_update_items
back_chest_update_items = chest_update_items

-- Entidade para representar itens no baú
c.register_entity("nh_nodes:chest_item", {
    initial_properties = {
        visual = "wielditem",
        wield_item = "air",
        visual_size = { x = 0.15, y = 0.15 }, -- Tamanho reduzido (o tamanho do modelo é 10 e dos bones 1)
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
    },
    chest_pos = nil,
    slot_index = 0,
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
    end,
    update_item = function(self, item_name)
        self.object:set_properties({wield_item = item_name})
    end,
    on_step = function(self, dtime)
        -- Verificar se o baú ainda existe
        if not self.chest_pos then self.object:remove() return end
        local node = c.get_node(self.chest_pos)
        if node.name ~= "nh_nodes:oak_chest_open" and node.name ~= "nh_nodes:back_chest_open" then
            self.object:remove()
        end
    end,
})

c.register_node("nh_nodes:oak_chest_open", {
    drawtype = "mesh",
    mesh = "chestopen.obj",         -- modelo sem tampa
    tiles = { "ChestTexture.png" }, -- mesma textura
    walkable = true,
    pointable = true,
    paramtype = "light",
    paramtype2 = "facedir",
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    groups = {not_in_creative_inventory = 1},
    -- Quando clicar no baú aberto, mostrar inventário
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = c.get_meta(pos)
        local player_name = clicker:get_player_name()
        -- Marcar que o jogador está usando o baú
        meta:set_string("current_user", player_name)
        c.show_formspec(player_name, "nh_nodes:oak_chest_" .. c.pos_to_string(pos), build_chest_formspec(clicker))
        return itemstack
    end,
    -- Atualizar itens visuais quando o node é construído
    on_construct = function(pos)
        c.after(0.1, function() oak_chest_update_items(pos) end)
    end,
    -- Atualizar itens visuais após colocar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        c.after(0.1, function() oak_chest_update_items(pos) end)
    end,
})

c.register_node("nh_nodes:oakchest", {
    description = S "Oak Chest",
    drawtype = "mesh",
    mesh = "chest.glb",
    tiles = { "ChestTexture.png" },
    walkable = true,
    pointable = true,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { choppy = 2, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    -- Criar inventário quando o node é construído
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        -- Criar inventário com 32 slots (8x4)
        inv:set_size("main", 8 * 2) -- O bau é quadrado escolhi 4x4, mas na forma do inventário 8x2
        -- Definir formspec do inventário
        meta:set_string("formspec",
            "size[8,9]" ..
            "list[current_name;main;0,0.3;8,2;]" ..
            "list[current_player;main;0,5.85;8,2;8]" ..
            "list[current_player;main;0,8.05;8,1;]" ..
            "listring[current_name;main]" ..
            "listring[current_player;main]"
        )
        meta:set_string("infotext", S "Oak Chest")
    end,
    -- Verificar se pode cavar (não permitir se tiver itens)
    can_dig = function(pos, player)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,
    -- Ao clicar com botão direito
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Tocar som de abertura
        --c.sound_play("default_chest_open", {
        --    pos = pos,
        --    gain = 0.3,
        --    max_hear_distance = 10,
        --}, true)
        -- Substitui o node pelo baú aberto
        local current_node = c.get_node(pos)
        c.swap_node(pos, { name = "nh_nodes:oak_chest_open", param2 = current_node.param2 })
        -- Retira a entidade baú depois da animação
        local objects = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objects) do
            if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:oak_chest_entity" then
                obj:remove()
            end
        end
        -- Criar entidade para animação
        local entity = c.add_entity(pos, "nh_nodes:oak_chest_entity")
        if entity and entity:get_luaentity() then
            local luaentity = entity:get_luaentity()
            luaentity.node_pos = pos
            luaentity.original_param2 = current_node.param2
            -- Aplicar a rotação do baú à entidade
            local yaw = c.facedir_to_dir(current_node.param2)
            entity:set_yaw(c.dir_to_yaw(yaw))
            entity:set_animation({ x = 0, y = 0.25 }, 1, 0, false) -- 0 a 0.25s a 30fps = frames 0-7.5
        end
        -- Abrir inventário
        local meta = c.get_meta(pos)
        local player_name = clicker:get_player_name()
        -- Marcar que o jogador está usando o baú
        meta:set_string("current_user", player_name)
        -- Atualizar itens visuais
        oak_chest_update_items(pos)
        c.show_formspec(player_name, "nh_nodes:oak_chest_" .. c.pos_to_string(pos), build_chest_formspec(clicker))
        return itemstack
    end,

    -- Preservar inventário ao cavar
    preserve_metadata = function(pos, oldnode, oldmeta, drops)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        local items = {}
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if not stack:is_empty() then table.insert(items, stack:to_string()) end
        end
        if #items > 0 then drops[1]:get_meta():set_string("items", c.serialize(items)) end
    end,
    -- Restaurar inventário ao colocar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = c.get_meta(pos)
        local item_meta = itemstack:get_meta()
        local items = item_meta:get_string("items")
        if items ~= "" then
            items = c.deserialize(items)
            local inv = meta:get_inventory()
            for i, item_str in ipairs(items) do inv:set_stack("main", i, ItemStack(item_str)) end
        end
    end,
})

c.register_node("nh_nodes:oak_chest", {
    description = S "Oak Chest" .. "\n" .. S "[with items]",
    drawtype = "mesh",
    mesh = "chest.glb",
    tiles = { "ChestTexture.png" },
    walkable = true,
    pointable = true,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { choppy = 2, oddly_breakable_by_hand = 1 },
    --sounds = default.node_sound_wood_defaults(),
    collision_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    selection_box = {type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    drop = "nh_nodes:oakchest", -- sem "_"
    -- Criar inventário quando o node é construído
    on_construct = function(pos)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        -- Criar inventário com 32 slots (8x4)
        inv:set_size("main", 8 * 2) -- O bau é quadrado escolhi 4x4, mas na forma do inventário 8x2
        -- Adiciona páginas com textos pré-definidos
        local page1 = items.create_page_with_text(S"Day 1: I found this abandoned place. It seems someone lived here a long time ago.")
        local page2 = items.create_page_with_text(S"Day 15: Supplies are running out. I need to find a way out before it's too late.")
        local page3 = items.create_page_with_text(S"Day 30: I heard strange sounds during the night. I'm not alone here...")
        inv:set_stack("main", 1, page1)
        inv:set_stack("main", 2, page2)
        inv:set_stack("main", 3, page3)
        -- Adiciona páginas em branco
        inv:set_stack("main", 4, ItemStack("nh_items:page 5"))      -- 5 páginas em branco
        inv:set_stack("main", 5, ItemStack("nh_items:feather"))     -- pena de escrever
        inv:set_stack("main", 6, ItemStack("nh_nodes:inkbottle"))   -- frasco com tinta
        inv:set_stack("main", 7, ItemStack("nh_nodes:torch2"))      -- tocha acesa

        inv:set_stack("main", 8, ItemStack("nh_nodes:apple 2"))     -- 2 maças
        inv:set_stack("main", 9, ItemStack("nh_nodes:blueberry 2")) -- 2 mitilos
        inv:set_stack("main", 10, ItemStack("nh_nodes:coconut 2"))  -- 2 cocos
        inv:set_stack("main", 11, ItemStack("nh_nodes:palmlog 1"))
        inv:set_stack("main", 12, ItemStack("nh_nodes:palmleaf 1"))
        
        local book = ItemStack("nh_nodes:writedbook")
        local bmeta = book:get_meta()
        bmeta:set_string("subtitle", "Dolorem Ipsum")
        bmeta:set_string("author", "Marcus")
        bmeta:set_string("pages", pages_to_string({
            "Dolor atque labor pars vitae sunt.",
            "Neque enim quisquam dolorem ipsum propter se appetit aut amat.",
            "Sed saepe labores et aerumnas sustinemus ut aliquod bonum consequamur.",
            "Homines officiis suis incumbunt fructus rerum quaerentes.",
            "Multi errores multique dolores ex cupiditate voluptatis oriuntur.",
            "Sed ratione ac virtute superandi sunt.",
            "Qui cupiditatibus inconsultis se vinci patiuntur atque officia sua deserunt.",
            "Tandem effectus factorum suorum experiuntur."
        }))
        inv:set_stack("main", 13, book)

        -- Definir formspec do inventário
        meta:set_string("formspec",
            "size[8,9]" ..
            "list[current_name;main;0,0.3;8,2;]" ..
            "list[current_player;main;0,5.85;8,2;8]" ..
            "list[current_player;main;0,8.05;8,1;]" ..
            "listring[current_name;main]" ..
            "listring[current_player;main]"
        )
        meta:set_string("infotext", S "Lost Oak Chest")
    end,
    -- Verificar se pode cavar (não permitir se tiver itens)
    can_dig = function(pos, player)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Tocar som de abertura
        --c.sound_play("default_chest_open", {
        --    pos = pos,
        --    gain = 0.3,
        --    max_hear_distance = 10,
        --}, true)

        -- Substitui o node pelo baú aberto
        local current_node = c.get_node(pos)
        c.swap_node(pos, { name = "nh_nodes:oak_chest_open", param2 = current_node.param2 })
        -- Retira a entidade baú depois da animação
        local objects = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objects) do
            if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:oak_chest_entity" then obj:remove() end
        end
        -- Criar entidade para animação
        local entity = c.add_entity(pos, "nh_nodes:oak_chest_entity")
        if entity and entity:get_luaentity() then
            local luaentity = entity:get_luaentity()
            luaentity.node_pos = pos
            luaentity.original_param2 = current_node.param2
            -- Aplicar a rotação do baú à entidade
            local yaw = c.facedir_to_dir(current_node.param2)
            entity:set_yaw(c.dir_to_yaw(yaw))
            entity:set_animation({ x = 0, y = 0.25 }, 1, 0, false) -- 0 a 0.25s a 30fps = frames 0-7.5
        end
        -- Abrir inventário
        local meta = c.get_meta(pos)
        local player_name = clicker:get_player_name()
        -- Marcar que o jogador está usando o baú
        meta:set_string("current_user", player_name)
        -- Atualizar itens visuais
        oak_chest_update_items(pos)
        c.show_formspec(player_name, "nh_nodes:oak_chest_" .. c.pos_to_string(pos), build_chest_formspec(clicker))
        return itemstack
    end,
    -- Preservar inventário ao cavar
    preserve_metadata = function(pos, oldnode, oldmeta, drops)
        local meta = c.get_meta(pos)
        local inv = meta:get_inventory()
        local items = {}
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if not stack:is_empty() then table.insert(items, stack:to_string()) end
        end
        if #items > 0 then drops[1]:get_meta():set_string("items", c.serialize(items)) end
    end,
    -- Restaurar inventário ao colocar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = c.get_meta(pos)
        local item_meta = itemstack:get_meta()
        local items = item_meta:get_string("items")
        if items ~= "" then
            items = c.deserialize(items)
            local inv = meta:get_inventory()
            for i, item_str in ipairs(items) do inv:set_stack("main", i, ItemStack(item_str)) end
        end
    end,
})

-- Entidade invisível para animação
c.register_entity("nh_nodes:oak_chest_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "chest.glb",
        textures = { "ChestTexture.png" },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
        paramtype = "light",
        paramtype2 = "facedir",
    },
    node_pos = nil,
    original_param2 = 0,
    timer = 0,
    animation_finished = false,
    is_invisible = false,
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
    end,
    on_step = function(self, dtime)
        if self.is_invisible then return end -- Se for invisível (só para anexar itens), não fazer nada
        self.timer = self.timer + dtime
        -- Após a animação, congelar no último frame
        if self.timer > 0.3 and not self.animation_finished then
            self.animation_finished = true
            -- Congelar no último frame da animação
            self.object:set_animation({ x = 0.25, y = 0.25 }, 0, 0, false)
        end
    end,
})

-- Entidade para animação de fechamento
c.register_entity("nh_nodes:oak_chest_close_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "chest.glb",
        textures = { "ChestTexture.png" },
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
        paramtype = "light",
        paramtype2 = "facedir",
    },

    node_pos = nil,
    original_param2 = 0,
    timer = 0,

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
    end,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime

        -- Remover entidade e fechar baú após a animação
        if self.timer > 0.3 then
            -- Remover todos os itens anexados
            if self.node_pos then
                local objects = c.get_objects_inside_radius(self.node_pos, 1)
                for _, obj in ipairs(objects) do
                    local luaent = obj:get_luaentity()
                    if luaent and luaent.name == "nh_nodes:chest_item" then
                        obj:remove()
                    end
                end
            end

            self.object:remove()

            -- Trocar para node fechado
            if self.node_pos then
                local node = c.get_node(self.node_pos)
                if node.name == "nh_nodes:oak_chest_open" then
                    c.swap_node(self.node_pos, { name = "nh_nodes:oak_chest", param2 = self.original_param2 })
                end
            end
        end
    end,
})

-- Detectar quando o jogador fecha o formspec
c.register_on_player_receive_fields(function(player, formname, fields)
    local prefix = "nh_nodes:oak_chest_"
    -- Verificar se é um formspec de baú
    if formname:sub(1, #prefix) == "nh_nodes:oak_chest_" then
        local pos_string = formname:sub(#prefix + 1)
        local pos = c.string_to_pos(pos_string)

        if pos then
            local node = c.get_node(pos)

            -- Se o baú estiver aberto, fechá-lo
            if node.name == "nh_nodes:oak_chest_open" then
                local meta = c.get_meta(pos)
                local current_user = meta:get_string("current_user")
                local player_name = player:get_player_name()

                -- Verificar se é o jogador que estava usando
                if current_user == player_name then
                    -- Limpar usuário atual
                    meta:set_string("current_user", "")

                    -- Remover apenas a entidade da animação de abertura (mas manter os itens)
                    local objects = c.get_objects_inside_radius(pos, 0.5)
                    local chest_entity = nil

                    for _, obj in ipairs(objects) do
                        local luaent = obj:get_luaentity()
                        if luaent and luaent.name == "nh_nodes:oak_chest_entity" then
                            chest_entity = obj
                            break
                        end
                    end

                    -- Criar entidade para animação de fechamento
                    local close_entity = c.add_entity(pos, "nh_nodes:oak_chest_close_entity")
                    if close_entity and close_entity:get_luaentity() then
                        local luaentity = close_entity:get_luaentity()
                        luaentity.node_pos = pos
                        luaentity.original_param2 = node.param2

                        -- Transferir os itens anexados para a entidade de fechamento
                        if chest_entity then
                            for _, obj in ipairs(objects) do
                                local luaent = obj:get_luaentity()
                                if luaent and luaent.name == "nh_nodes:chest_item" then
                                    -- Re-anexar ao novo baú (fechamento)
                                    local slot = luaent.slot_index
                                    obj:set_attach(close_entity, "bone" .. slot, xyz(0), xyz(0))
                                end
                            end
                            -- Remover a entidade antiga do baú
                            chest_entity:remove()
                        end

                        -- Aplicar a rotação do baú à entidade
                        local yaw = c.facedir_to_dir(node.param2)
                        close_entity:set_yaw(c.dir_to_yaw(yaw))
                        -- Animação de fechamento (do frame aberto para fechado)
                        close_entity:set_animation({ x = 0.25, y = 0 }, 30, 0, false)
                    end
                end
            end
        end
    end
end)

-- Detectar mudanças no inventário do baú
c.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action ~= "move" and action ~= "put" and action ~= "take" then
        return
    end

    if inventory_info.to_list ~= "main" and inventory_info.from_list ~= "main" then
        return
    end

    local player_name = player:get_player_name()
    local player_pos = player:get_pos()
    if not player_pos then return end

    local objects = c.get_objects_inside_radius(player_pos, 10)

    for _, obj in ipairs(objects) do
        if obj:is_player() then
            goto continue
        end

        local pos = obj:get_pos()
        if not pos then
            goto continue
        end

        local node = c.get_node_or_nil(pos)
        if not node then
            goto continue
        end

        if node.name == "nh_nodes:oak_chest_open" then
            local meta = c.get_meta(pos)
            if meta:get_string("current_user") == player_name then
                oak_chest_update_items(pos)
            end
        end

        ::continue::
    end
end)

-- Som de fechamento ao sair do formspec (opcional)
--c.register_on_player_receive_fields(function(player, formname, fields)
--    if formname:find("nh_nodes:oak_chest_") then
--        if fields.quit then
--            local pos_str = formname:gsub("nh_nodes:oak_chest_", "")
--            local pos = c.string_to_pos(pos_str)
--
--            if pos then
--                c.sound_play("default_chest_close", {
--                    pos = pos,
--                    gain = 0.3,
--                    max_hear_distance = 10,
--                }, true)
--            end
--        end
--    end
--end)


------------
-- Porta
------------

--c.register_node("nh_nodes:oak_door", {
--    description = "Porta de Carvalho",
--    initial_properties = {
--        visual = "mesh",
--        mesh = "porta_tablada_carvalho.obj",
--        textures = {"porta_tablada_carvalho.png"},
--        --visual_size = {x=1, y=2}, -- ajuste
--        groups = {choppy = 2},
--    },
--})

---------------------------
-- FUNÇÃO DE ARREMESSO
---------------------------
local function throw_pebble(itemstack, user)
    local pos = user:get_pos()
    local dir = user:get_look_dir()
    pos.y = pos.y + 2.25 -- altura dos olhos
    local obj = c.add_entity(pos, "nh_nodes:pebble_entity")
    if obj then
        obj:set_velocity(vector.multiply(dir, 13))
        obj:set_acceleration({ x = 0, y = -9.81, z = 0 })
        local ent = obj:get_luaentity()
        if ent then
            ent._shooter = user
        end
    end
    itemstack:take_item()
    return itemstack
end

---------------------------
-- ITEM ARREMESSÁVEL
---------------------------

-- FUNÇÃO DE ARREMESSO
local function throw_pebble(itemstack, placer)
    if not placer or not placer:is_player() then return itemstack end
    local pos = placer:get_pos()
    pos.y = pos.y + 1.5 -- altura dos olhos
    local dir = placer:get_look_dir()
    local obj = c.add_entity(pos, "nh_nodes:pebble_entity")
    if obj then
        obj:set_velocity(vector.multiply(dir, 18))
        obj:set_acceleration(xyz(0, -10, 0))
        -- Define o atirador para não se machucar
        local ent = obj:get_luaentity()
        if ent then ent._shooter = placer end
    end
    -- Remove 1 item do stack
    itemstack:take_item(1)
    return itemstack
end

-- ITEM SEIXO ARREMESSÁVEL
local function update_neighbors(pos)
    local offsets = {
        xyz(0,  1,  0), xyz(1,  0,  0), xyz(0,  0,  1),
        xyz(0,  -1, 0), xyz(-1, 0,  0), xyz(0,  0,  -1)}
    for _, off in ipairs(offsets) do
        local npos = vector.add(pos, off)
        -- Dispara física de falling_node (areia, cascalho, neve, etc.)
        c.check_for_falling(npos)
    end
end

c.register_craftitem("nh_nodes:pebble_item", {
    description = S"Pebble" .. "\n" .. S"[Throwable]" .. "\n" .. S"Damage: +1" .. "\n" .. S"(Throw: Q / drop)",
    inventory_image = "seixoarremessavel.png",
    wield_image = "seixoarremessavel.png",
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(0.5, -0.25, 0)},
    wielded_visual_size = xyz(0.15),
    tool_capabilities = {full_punch_interval = 1.5, max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 2.50, [2] = 2, [3] = 1}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 2}},
    -- Botão direito = arremessa
    on_place = function(itemstack, placer, pointed_thing) return throw_pebble(itemstack, placer) end,
    -- Ao soltar = arremessa
    on_drop = function(itemstack, dropper, pos) return throw_pebble(itemstack, dropper) end
})

-- ENTIDADE DO PROJÉTIL
c.register_entity("nh_nodes:pebble_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        visual = "wielditem",
        visual_size = {x = 0.5, y = 0.5},
        textures = {"nh_nodes:pebble"},
    },
    _stuck = false,
    _timer = 0,
    _stuck_timer = 0,
    _last_pos = nil,
    _shooter = nil, --       Declarado aqui para ficar visível
    on_activate = function(self, staticdata)
        self._timer = 0
        self._stuck = false
        self._stuck_timer = 0
        self._shooter = nil
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then self.object:remove() return end
        -- Timer geral para remover após muito tempo
        self._timer = self._timer + dtime
        if self._timer > 60 then self.object:remove() return end
        -- Se já está grudado
        if self._stuck then
            self._stuck_timer = self._stuck_timer + dtime
            -- Após 0.1 segundo grudado, vira node
            if self._stuck_timer >= 0.1 then
                local node_pos = vector.round(pos)
                local node = c.get_node(node_pos)
                if node.name == "air" or not c.registered_nodes[node.name].walkable then
                    c.set_node(node_pos, { name = "nh_nodes:pebble" })
                    update_neighbors(node_pos)
                else
                    local offsets = {
                        xyz(0,  1,  0), xyz(1,  0,  0), xyz(0,  0,  1),
                        xyz(0,  -1, 0), xyz(-1, 0,  0), xyz(0,  0,  -1),
                    }
                    local placed = false
                    for _, offset in ipairs(offsets) do
                        local try_pos = vector.add(node_pos, offset)
                        local try_node = c.get_node(try_pos)
                        if try_node.name == "air" then
                            c.set_node(try_pos, { name = "nh_nodes:pebble" })
                            update_neighbors(try_pos)
                            placed = true
                            break
                        end
                    end
                    if not placed then c.add_item(pos, "nh_nodes:pebble_item") end
                end
                self.object:remove()
            end
            return
        end
        local vel = self.object:get_velocity()
        if not vel then self.object:remove() return end
        local speed = vector.length(vel)
        -- Se a velocidade é muito baixa (parou de se mover)
        if speed < 0.5 then
            self._stuck = true
            self.object:set_velocity((xyz(0)))
            self.object:set_acceleration((xyz(0)))
            return
        end
        -- Verifica colisão com blocos sólidos via raycast manual
        local step_dir = vector.normalize(vel)
        local check_distance = math.min(speed * dtime * 2, 1)
        local steps = math.ceil(check_distance / 0.2)
        for i = 1, steps do
            local check_pos = vector.add(pos, vector.multiply(step_dir, i * 0.2))
            local node = c.get_node(check_pos)
            if node and node.name and c.registered_nodes[node.name] then
                if c.registered_nodes[node.name].walkable then
                    self._stuck = true
                    self.object:set_pos(check_pos)
                    self.object:set_velocity((xyz(0)))
                    self.object:set_acceleration((xyz(0)))
                    return
                end
                if node.name == "nh_nodes:coconutlinked" then
                    c.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    c.set_node(check_pos, {name = "nh_nodes:coconut"})
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut" then
                    c.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    c.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    c.add_item(check_pos, {name = "nh_nodes:nut"})
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut2" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut", count = 2 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut3" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut", count = 3 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple2" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple", count = 2 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple3" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple", count = 3 })
                    update_neighbors(check_pos)
                    return
                end
            end
        end

        local objs = c.get_objects_inside_radius(pos, 1.2) -- Raio aumentado de 0.6 para 1.2 para não passar pelo mob
        for _, obj in ipairs(objs) do
            -- Ignora o próprio projétil e o atirador
            if obj ~= self.object and obj ~= self._shooter then
                local is_target = obj:is_player()

                if not is_target then
                    local ent = obj:get_luaentity()
                    -- Usa get_hp() no lugar de ent.hp_max, compatível com MobsRedo
                    if ent and ent.name ~= "nh_nodes:pebble_entity" then
                        local hp = obj:get_hp()
                        if hp and hp > 0 then is_target = true end
                    end
                end
                if is_target then
                    c.log("action", "[Seixo] Acertou alvo em " .. c.pos_to_string(pos))
                    c.sound_play("default_dig_cracky", { pos = pos, gain = 0.5 })
                    obj:punch(self.object, 1, {full_punch_interval = 1, damage_groups = { fleshy = 2 }}, vel)
                    c.add_item(pos, "nh_nodes:pebble_item")
                    self.object:remove()
                    return
                end
            end
        end
        self._last_pos = pos
    end,
})

c.register_node("nh_nodes:limb", {
    description = S"Limb" .. "\n" .. S"Reach: +2" .. "\n" .. S"Damage: +2" .. "\n" .. S"Uses: 10",
    drawtype = "mesh",
    mesh = "branch.obj",
    tiles = { "branchtex.png" }, --oaktimber.png
    paramtype = "light",
    range = 5, -- AUMENTA O ALCANCE
    collision_box = {type = "fixed", fixed = {-0.06, -0.5, -0.12, 0.06, 1.05, 0.07}},
    selection_box = {type = "fixed", fixed = {-0.06, -0.5, -0.12, 0.06, 1.05, 0.07}},
    groups = {oddly_breakable_by_hand = 3, falling_node = 1},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- desgasta ao cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 6552 -- ~10 usos (65535 / 10)
        itemstack:set_wear(wear)
        return itemstack
    end,
})

c.register_node("nh_nodes:stick", {
    description = S "Stick" .. "\n" .. S "Reach: +1" .. "\n" .. S "Uses: 5",
    drawtype = "mesh",
    mesh = "stick.obj",
    tiles = {"stick.png"},
    range = 4,
    groups = {dig_immediate = 1, flammable = 2, falling_node = 1},
    paramtype = "light",
    collision_box = {type = "fixed", fixed = {-0.04, -0.5, -0.12, 0.04, 0.5, 0.07}},
    selection_box = {type = "fixed", fixed = {-0.04, -0.5, -0.12, 0.04, 0.5, 0.07}},
    -- desgasta ao cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 13107 -- ~5 usos (65535 / 5)
        itemstack:set_wear(wear)
        return itemstack
    end,
})

c.register_node("nh_nodes:fallenstick", {
    description = S "Fallen stick",
    drawtype = "mesh",
    mesh = "stick2.obj",
    tiles = { "stick.png" },
    drop = "nh_nodes:stick",
    paramtype = "light",
    walkable = false,
    groups = {oddly_breakable_by_hand = 1, flammable = 2, falling_node = 1},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.12, 0.5, -0.435, 0.065}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.12, 0.5, -0.435, 0.065}},
})

-- NODE DO SEIXO DE OBSIDIANA
c.register_node("nh_nodes:obsidianpebble", {
    description = S"Obsidian Pebble" .. "\n" .. S"Damage: +1",
    drawtype = "mesh",
    mesh = "pebble.obj",         --
    tiles = { "obsidiana.png" }, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    drop = "nh_nodes:obsidianpebble_item",
    groups = {oddly_breakable_by_hand = 3, falling_node = 1, attached_node = 1, not_in_creative_inventory = 1},
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    -- FAZ O SEIXO CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.3, [2] = 0.9, [3] = 0.5}, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 2.5, [2] = 2, [3] = 1.5}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 2}},
})

---------------------------
-- FUNÇÃO DE ARREMESSO
---------------------------
local function throw_pebble(itemstack, placer)
    if not placer or not placer:is_player() then return itemstack end
    local pos = placer:get_pos()
    pos.y = pos.y + 1.5 -- altura dos olhos
    local dir = placer:get_look_dir()
    local obj = c.add_entity(pos, "nh_nodes:obsidianpebble_entity")
    if obj then
        obj:set_velocity(vector.multiply(dir, 18))
        obj:set_acceleration(xyz(0, -10, 0))
        -- Define o atirador para não se machucar
        local ent = obj:get_luaentity()
        if ent then ent._shooter = placer end
    end
    -- Remove 1 item do stack
    itemstack:take_item(1)
    return itemstack
end

-- ITEM
c.register_craftitem("nh_nodes:obsidianpebble_item", {
    description = S "Obsidian Pebble" .. "\n" .. S "[Throwable]" .. "\n" .. S "Damage: +1" .. "\n" .. S "(Throw: Q / drop)",
    inventory_image = "obsidiana_seixo_arremessavel.png",
    wield_image = "obsidiana_seixo_arremessavel.png",
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(0.5, -0.25, 0)},
    wielded_visual_size = xyz(0.15),
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.3, [2] = 0.9, [3] = 0.5}, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 2.5, [2] = 2, [3] = 1.5}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 2}},
    -- Botão direito = arremessa
    on_place = function(itemstack, placer, pointed_thing) return throw_pebble(itemstack, placer) end,
    -- Ao soltar = arremessa
    on_drop = function(itemstack, dropper, pos) return throw_pebble(itemstack, dropper) end,
})


-- ENTIDADE DO PROJÉTIL
c.register_entity("nh_nodes:obsidianpebble_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        visual = "wielditem",
        visual_size = {x = 0.5, y = 0.5 },
        textures = {"nh_nodes:obsidianpebble"},
    },
    _stuck = false,
    _timer = 0,
    _stuck_timer = 0,
    _last_pos = nil,
    _shooter = nil, --       Declarado aqui para ficar visível
    on_activate = function(self, staticdata)
        self._timer = 0
        self._stuck = false
        self._stuck_timer = 0
        self._shooter = nil
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then self.object:remove() return end
        -- Timer geral para remover após muito tempo
        self._timer = self._timer + dtime
        if self._timer > 60 then self.object:remove() return end
        -- Se já está grudado
        if self._stuck then
            self._stuck_timer = self._stuck_timer + dtime
            -- Após 0.1 segundo grudado, vira node
            if self._stuck_timer >= 0.1 then
                local node_pos = vector.round(pos)
                local node = c.get_node(node_pos)
                if node.name == "air" or not c.registered_nodes[node.name].walkable then
                    c.set_node(node_pos, { name = "nh_nodes:obsidianpebble" })
                else
                    local offsets = {
                        xyz(0, 1,  0), xyz(1,  0, 0), xyz(0,  0,  1),
                        xyz(0, -1, 0), xyz(-1, 0, 0), xyz(0,  0, -1)}
                    local placed = false
                    for _, offset in ipairs(offsets) do
                        local try_pos = vector.add(node_pos, offset)
                        local try_node = c.get_node(try_pos)
                        if try_node.name == "air" then
                            c.set_node(try_pos, { name = "nh_nodes:obsidianpebble" })
                            placed = true
                            break
                        end
                    end
                    if not placed then c.add_item(pos, "nh_nodes:obsidianpebble_item") end
                end
                self.object:remove()
            end
            return
        end

        local vel = self.object:get_velocity()
        if not vel then self.object:remove() return end
        local speed = vector.length(vel)
        -- Se a velocidade é muito baixa (parou de se mover)
        if speed < 0.5 then
            self._stuck = true
            self.object:set_velocity((xyz(0)))
            self.object:set_acceleration((xyz(0)))
            return
        end
        -- Verifica colisão com blocos sólidos via raycast manual
        local step_dir = vector.normalize(vel)
        local check_distance = math.min(speed * dtime * 2, 1)
        local steps = math.ceil(check_distance / 0.2)
        for i = 1, steps do
            local check_pos = vector.add(pos, vector.multiply(step_dir, i * 0.2))
            local node = c.get_node(check_pos)
            if node and node.name and c.registered_nodes[node.name] then
                if c.registered_nodes[node.name].walkable then
                    self._stuck = true
                    self.object:set_pos(check_pos)
                    self.object:set_velocity((xyz(0)))
                    self.object:set_acceleration((xyz(0)))
                    return
                end
                if node.name == "nh_nodes:coconutlinked" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:coconut" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut2" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut", count = 2 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut3" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut", count = 3 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple2" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple", count = 2 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple3" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple", count = 3 })
                    update_neighbors(check_pos)
                    return
                end
            end
        end
        --       Raio aumentado de 0.6 para 1.2 para não passar pelo mob
        local objs = c.get_objects_inside_radius(pos, 1.2)
        for _, obj in ipairs(objs) do
            -- Ignora o próprio projétil e o atirador
            if obj ~= self.object and obj ~= self._shooter then
                local is_target = obj:is_player()
                if not is_target then
                    local ent = obj:get_luaentity()
                    -- Usa get_hp() no lugar de ent.hp_max, compatível com MobsRedo
                    if ent and ent.name ~= "nh_nodes:obsidianpebble_entity" then
                        local hp = obj:get_hp()
                        if hp and hp > 0 then is_target = true end
                    end
                end
                if is_target then
                    c.log("action", "[Seixo de Obsidiana] Acertou alvo em " .. c.pos_to_string(pos))
                    c.sound_play("default_dig_cracky", {pos = pos, gain = 0.5})
                    obj:punch(self.object, 1.0, {full_punch_interval = 1.0, damage_groups = {fleshy = 2}}, vel)
                    c.add_item(pos, "nh_nodes:obsidianpebble_item")
                    self.object:remove()
                    return
                end
            end
        end
        self._last_pos = pos
    end,
})

-- NODE DO SEIXO DE OBSIDIANA
c.register_node("nh_nodes:obsidianblade", {
    description = S"Obsidian Blade",
    drawtype = "mesh",
    mesh = "obsidianblade.obj",  --
    tiles = { "obsidiana.png" }, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {dig_immediate = 1, falling_node = 1, attached_node = 1},
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    -- FAZ O SEIXO CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
})

-- NODE DA FERRAMENTA REMO
c.register_node("nh_nodes:rowing", {
    description = S"Rowing" .. "\n" .. S "Reach: +3" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "rowing.obj",       --
    tiles = { "oakwood.png" }, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {dig_immediate = 1, falling_node = 1,},
    range = 6, -- AUMENTA O ALCANCE
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50 }, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 4, [2] = 3, [3] = 2}, uses = 0, maxlevel = 1}},
        damage_groups = {fleshy = 2},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.5, 0.125, -0.435, 1.35}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.5, 0.125, -0.435, 1.35}},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(3, 0, 1.8), rot = xyz(90, 0, -90)},
    wielded_visual_size = xyz(0.25),
})

-- ENTIDADE DA JANGADA (versão navegável)
c.register_entity("nh_nodes:pineraft_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "pineraft_entity.obj",
        textures = { "pineraft.png" },
        visual_size = xyz(2.5),
        collisionbox = {-1, 0, -1.5, 1, 0.9, 1.5},
        physical = true,
        is_visible = true,
        hp_max = 4, -- "durabilidade": quantos socos para quebrar
        automatic_face_movement_dir = false,
        stepheight = 0.5,
        gravity = xyz(0, -9.81, 0),
    },
    driver = nil,
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 0, fleshy = 100})
        self.object:set_hp(8)
        self.object:set_velocity((xyz(0)))
        self.object:set_acceleration(xyz(0, -9.81, 0))
    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        -- Desmonta se for o motorista
        if self.driver and puncher == self.driver then
            riding_players = riding_players or {}
            riding_players[self.driver:get_player_name()] = nil  
            self.driver:set_detach()
            self.driver:set_eye_offset(xyz(0), xyz(0))           
            if self._driver_visual_size then
                self.driver:set_properties({visual_size = self._driver_visual_size, eye_height = 2.3})
                self._driver_visual_size = nil
            end
            self.driver = nil
            return
        end
        -- Só permite quebrar com a mão (sem ferramenta)
        local item = puncher:get_wielded_item()
        if item:get_name() ~= "" then return end
        local hp = self.object:get_hp()
        hp = hp - 1
        if hp <= 0 then
            -- Dropa o item da jangada
            local pos = self.object:get_pos()
            c.add_item(pos, "nh_nodes:pineraft")
            self.object:remove()
        else self.object:set_hp(hp)
            -- Feedback visual: pisca (opcional)
            -- self.object:punch(puncher, ...) -- deixa o engine piscar
        end
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then return end
        local node_at     = c.get_node(xyz(pos.x, pos.y + 0.5, pos.z))
        local node_below  = c.get_node(xyz(pos.x, pos.y - 0.5, pos.z))
        local node_below2 = c.get_node(xyz(pos.x, pos.y + 0.35, pos.z)) -- logo abaixo do centro
        local submerged   = water_nodes[node_at.name]                       -- entidade está dentro da água
        local on_surface  = water_nodes[node_below2.name] and not submerged -- entidade está na superfície
        local vel         = self.object:get_velocity()
        if submerged then
            self.object:set_acceleration((xyz(0)))
            self.object:set_velocity(xyz(vel.x, 2, vel.z))
        elseif on_surface then
            self.object:set_acceleration((xyz(0)))
            self.object:set_velocity(xyz(vel.x, 0, vel.z))
        else self.object:set_acceleration(xyz(0, -9.81, 0)) -- No ar: gravidade age normalmente
            if vel.y > 0 then self.object:set_velocity(xyz(vel.x, 0, vel.z))
            end
        end
        if self.driver then
            -- Verifica se o jogador tem o remo na hotbar
            local has_oar = false
            local inv = self.driver:get_inventory()
            if inv then
                local hotbar_size = 8
                if self.driver.hud_get_hotbar_itemcount then hotbar_size = self.driver:hud_get_hotbar_itemcount() end
                for i = 1, hotbar_size do
                    local stack = inv:get_stack("main", i)
                    if stack:get_name() == "nh_nodes:rowing" then has_oar = true break end
                end
                for i = 1, hotbar_size do
                    local stack = inv:get_stack("main", i)
                    if stack:get_name() == "nh_nodes:rowing" then has_oar = true break end
                end
                -- Mensagem FORA do loop, e só envia uma vez usando um cooldown
                if not has_oar then
                    if not self._oar_msg_timer or self._oar_msg_timer <= 0 then
                        c.chat_send_player(self.driver:get_player_name(), S"I think I need a paddle to move the raft...")
                        self._oar_msg_timer = 5 -- segundos antes de repetir
                    end
                end
                if self._oar_msg_timer and self._oar_msg_timer > 0 then
                    self._oar_msg_timer = self._oar_msg_timer - dtime
                end
            end
            local speed = 3
            local raft_yaw = self.object:get_yaw()
            if has_oar then
                local ctrl       = self.driver:get_player_control()
                local mouse_yaw  = self.driver:get_look_horizontal()
                local turn_speed = 1.5
                -- Rotação suave em direção ao mouse
                local diff       = mouse_yaw - raft_yaw
                while diff > math.pi do diff = diff - 2 * math.pi end
                while diff < -math.pi do diff = diff + 2 * math.pi end
                local new_yaw = raft_yaw + diff * turn_speed * dtime
                if ctrl.left then new_yaw = new_yaw + 0.05 end
                if ctrl.right then new_yaw = new_yaw - 0.05 end
                self.object:set_yaw(new_yaw)
                local vx, vz = 0, 0
                if ctrl.up then vx = math.sin(-new_yaw) * speed; vz = math.cos(-new_yaw) * speed end
                if ctrl.down then vx = -math.sin(-new_yaw) * speed; vz = -math.cos(-new_yaw) * speed end
                local vel = self.object:get_velocity()
                self.object:set_velocity(xyz(vx, vel.y, vz))
            else
                -- Sem remo: para a jangada gradualmente (atrito)
                local vel = self.object:get_velocity()
                self.object:set_velocity(xyz(vel.x * 0.85, vel.y, vel.z * 0.85))
            end
        end
        local half_width = 2.7  --/ 2
        local half_length = 2.9 --/ 2
        local half_height = 1.5 --/ 2
        local search_radius = 4 -- só para busca inicial (ligeiramente maior)
        local being_pushed = false
        for _, obj in ipairs(c.get_objects_inside_radius(pos, search_radius)) do
            if obj:is_player() and obj ~= self.driver then
                local ppos = obj:get_pos()
                local dx = ppos.x - pos.x
                local dy = ppos.y - pos.y
                local dz = ppos.z - pos.z
                -- filtro retangular (caixa)
                if math.abs(dx) <= half_width and
                    math.abs(dy) <= half_height and
                    math.abs(dz) <= half_length then
                    local pvel = obj:get_velocity()
                    local speed_sq = pvel.x * pvel.x + pvel.z * pvel.z
                    if speed_sq > 0.1 then
                        local spd = math.sqrt(speed_sq)
                        local force = 1.75
                        local cur_vel = self.object:get_velocity()
                        self.object:set_velocity(xyz(
                            cur_vel.x + (pvel.x / spd) * force * dtime,
                            cur_vel.y,
                            cur_vel.z + (pvel.z / spd) * force * dtime))
                        being_pushed = true
                    end
                end
            end
        end
        -- Atrito só quando ninguém está empurrando e não há driver
        if not self.driver and not being_pushed then
            local cur_vel = self.object:get_velocity()
            self.object:set_velocity(xyz(cur_vel.x * 0.93, cur_vel.y, cur_vel.z * 0.93)) -- suave, desliza um pouco
        end
    end,
    on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        if self.driver == nil then
            self.driver = clicker
            -- Salva as propriedades originais do player
            self._driver_visual_size = clicker:get_properties().visual_size
            -- sinaliza para o body mod ignorar este player
            riding_players = riding_players or {}
            riding_players[clicker:get_player_name()] = true
            clicker:set_attach(self.object, "", xyz(0, 3.5, 0), xyz(0))
            clicker:set_eye_offset(xyz(0, 0.5, 5), xyz(0, 7, -7))
            clicker:set_properties({ visual_size = xyz(0.4), eye_height = 3})
        elseif self.driver == clicker then
            riding_players = riding_players or {}
            riding_players[clicker:get_player_name()] = nil
            clicker:set_detach()
            clicker:set_eye_offset(xyz(0), xyz(0))
            clicker:set_properties({visual_size = self._driver_visual_size, eye_height = 2.3})
            self.driver = nil
            -- Restaura as propriedades originais
            if self._driver_visual_size then
                clicker:set_properties({visual_size = self._driver_visual_size})
                self._driver_visual_size = nil
            end
        end
    end,
    on_death = function(self)
        if self.driver then
            riding_players = riding_players or {}
            riding_players[self.driver:get_player_name()] = nil  
            self.driver:set_detach()
            self.driver:set_eye_offset(xyz(0), xyz(0))      
            if self._driver_visual_size then
                self.driver:set_properties({visual_size = self._driver_visual_size, eye_height = 2.3})
                self._driver_visual_size = nil
            end
            self.driver = nil
        end
        local pos = self.object:get_pos()
        if pos then c.add_item(pos, "nh_nodes:pineraft") end
    end,
})

-- NODE DA JANGADA PRIMITIVA
c.register_node("nh_nodes:pineraft", {
    description = S"Pine Raft",
    drawtype = "mesh",
    mesh = "pineraft.obj",
    tiles = { "pineraft.png" }, -- tiles = {"pedra.png"},
    inventory_image = "pineraft_inv.png",
    groups = {oddly_breakable_by_hand = 1}, --falling_node = 1,
    collision_box = {type = "fixed", fixed = {-1, -0.5, -1.5, 1, 0.5, 1.5}},
    selection_box = {type = "fixed", fixed = {-1, -0.5, -1.5, 1, 0.5, 1.5}},
    wielded_bone_position = {pos = xyz(-2, -2, 1.8), rot = xyz(90, 0, -90)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(0, -1, -0.5), rot = xyz(90, 0, 90)},  -- Configuração mão esquerda
    pointabilities = {nodes = water_nodes},
    -- Quando o nó é colocado, verifica se está na água
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        -- Se segurou agachar, deixa como nó estático (não vira entidade)
        if placer and placer:is_player() then
            local ctrl = placer:get_player_control()
            if ctrl.sneak then return end -- coloca normalmente como nó, não faz nada
        end
        -- Sem agachar: vira entidade normalmente
        c.remove_node(pos)
        c.add_entity(pos, "nh_nodes:pineraft_entity")
    end,
    -- Cobre o caso de água chegar até o nó depois que ele já está parado
    on_flood = function(pos, oldnode, newnode)
        c.add_entity(pos, "nh_nodes:pineraft_entity")
        return false
    end,
})

---------------------------
-- NODE DA ESPADA DE OBSIDIANA
---------------------------
c.register_node("nh_nodes:obsidiansword", {
    description = S "Obsidian Sword" .. "\n" .. S "Reach: +3" .. "\n" .. S "Damage: +6" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "obsidiansword.obj",      --
    tiles = { "obsidiansword.png" }, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {oddly_breakable_by_hand = 3, falling_node = 1},
    range = 6, -- AUMENTA O ALCANCE
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 1.20, [2] = 0.80, [3] = 0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 7}},
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = { -0.125, -0.5, -0.5, 0.125, -0.435, 1.35 },},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.5, 0.125, -0.435, 1.35 },},
    wielded_bone_position = {pos = xyz(3, 0, 1.8), rot = xyz(90, 0, -90)}, -- Configuração mão direita
    wielded_visual_size = xyz(0.25),
})

-- NODE DO SEIXO NO CHÃO
c.register_node("nh_nodes:pebble", {
    description = S "Pebble" .. "\n" .. S "Damage: +1",
    drawtype = "mesh",
    mesh = "pebble.obj",     --
    tiles = {"seixo.png"}, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {oddly_breakable_by_hand = 3, falling_node = 1, attached_node = 1, not_in_creative_inventory = 1}, -- falling_node faz ele cair, attached_node previne ficar flutuando encostado
    collision_box = {type = "fixed", fixed = {{ -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},
    drop = "nh_nodes:pebble_item",
    -- FAZ O SEIXO CAIR SOZINHO
    on_construct = function(pos)
        c.check_for_falling(pos)
    end,
    after_place_node = function(pos)
        c.check_for_falling(pos)
    end,
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig = {name = "punchtimber", gain = 0.5},
        place = {name = "punchtimber", gain = 0.5}},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            choppy = {times = {[1] = 25, [2] = 20, [3] = 15 }, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50 }, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50 }, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 1.40, [2] = 1.00, [3] = 0.60 }, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 2}},
})

-- NODE DA PEDRA LASCADA (FERRAMENTA E ITEM DE FERRAMENTA)
c.register_node("nh_nodes:chippedstone", {
    description = S "Chipped Stone" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "pedralascada.obj",
    tiles = {"pedralascada.png"},             -- Ícone 2D no inventário
    inventory_image = "inv_stoneknifehead.png", -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {dig_immediate = 1, falling_node = 1}, -- falling_node faz ele cair,
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 7, [2] = 5, [3] = 3}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },

    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- FAZ CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
})

-- NODE DA CABEÇA DE MACHADO DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
c.register_node("nh_nodes:stoneaxehead", {
    description = S "Stone Axe Head" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stoneaxehead.obj",
    tiles = { "pedralascada.png" },       -- Ícone 2D no inventário
    inventory_image = "pedralascada.png", -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {dig_immediate = 1, falling_node = 1}, -- falling_node faz ele cair,
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 2, [2] = 2, [3] = 2}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = { -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},
    -- FAZ CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
})

-- NODE DA CABEÇA DE PICARETA DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
c.register_node("nh_nodes:stonepickaxehead", {
    description = S "Stone Pickaxe Head" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stonepickaxehead.obj",
    tiles = { "pedralascada.png" },               -- Ícone 2D no inventário
    inventory_image = "inv_stonepickaxehead.png", -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {dig_immediate = 1, falling_node = 1},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 6, [2] = 4, [3] = 2}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = {{ -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.095, 0.125, -0.435, 0.095 },},
    -- FAZ O SEIXO CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
})

-- NODE DA CABEÇA DE PICARETA DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
c.register_node("nh_nodes:stonehoehead", {
    description = S "Stone Pickaxe Head" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stonehoehead.obj",
    tiles = { "pedralascada.png" },           -- Ícone 2D no inventário
    inventory_image = "inv_stonehoehead.png", -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {dig_immediate = 1, falling_node = 1},
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 7, [2] = 5, [3] = 3}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- FAZ O SEIXO CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
})


---------------------------
-- NODE DA CABEÇA DE PICARETA DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
c.register_node("nh_nodes:stoneadzehead", {
    description = S "Stone Adze Head" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stoneadzehead.obj",
    tiles = { "pedralascada.png" },            -- Ícone 2D no inventário
    inventory_image = "inv_stoneadzehead.png", -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {dig_immediate = 1, falling_node = 1},
    collision_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095}},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- FAZ O SEIXO CAIR SOZINHO
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
})

-- NODE DA ESPADA ENFERRUJADA (FERRAMENTA)
c.register_node("nh_nodes:rustironsword", {
    description = S "Rusty Iron Sword" .. "\n" .. S "Reach: +3" .. "\n" .. S "Damage: +4" .. "\n" .. S "Uses: 10",
    drawtype = "mesh",
    mesh = "rustsword.obj",
    tiles = { "rustsword.png" },
    paramtype = "light",
    use_texture_alpha = "clip",
    backface_culling = false,
    sunlight_propagates = true,
    walkable = false,
    range = 6, -- AUMENTA O ALCANCE
    -- falling_node faz ele cair,
    groups = {dig_immediate = 1},
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.05, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.03, -0.5, -0.115, 0.03, 0.5, 0.115}},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 1.20, [2] = 0.80, [3] = 0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 5},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 6552 -- ~10 usos (65535 / 10)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 6552
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- Configuração mão direita
    wielded_bone_position = {pos = { x = 1.3, y = 0, z = 0}, rot = {x = 270, y = -90, z = 0}},
    wielded_visual_size = {x = 0.325, y = 0.325, z = 0.325},
})


c.register_node("nh_nodes:stoneaxe", {
    description = S "Stone Axe" .. "\n" .. S "Reach: +2" .. "\n" .. S "Damage: +3" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stoneaxe.obj",
    tiles = { "stoneaxe.png" },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    range = 5,
    groups = {dig_immediate = 1, falling_node = 1}, -- falling_node faz ele cair,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03}},
    wielded_bone_position = {pos = xyz(1.1, 0, 0.1)}, -- Configuração mão direita
    wielded_visual_size = xyz(0.25),
    tool_capabilities = {full_punch_interval = 2, max_drop_level = 1,
        groupcaps = {
            choppy = {times = {[1] = 5, [2] = 2.5, [3] = 1}, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 7, [3] = 6}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 4},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
})

c.register_node("nh_nodes:stonepickaxe", {
    description = S "Stone Pickaxe" .. "\n" .. S "Reach: +2" .. "\n" .. S "Damage: +3" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stonepickaxe.obj",
    tiles = { "stonepickaxe.png" },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    range = 5,
    groups = {dig_immediate = 1, falling_node = 1}, -- falling_node faz ele cair
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03}},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(1.1, 0, 0.1)},
    wielded_visual_size = xyz(0.25),
    tool_capabilities = {full_punch_interval = 2, max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 6, [2] = 3, [3] = 2}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 15, [2] = 10, [3] = 5}, uses = 10, maxlevel = 1},
            cracky = {times = {[1] = 20, [2] = 15, [3] = 10}, uses = 10, maxlevel = 1},
            choppy = {times = {[1] = 30, [2] = 25, [3] = 20}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 4},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
})

c.register_node("nh_nodes:stoneadze", {
    description = S "Stone Adze" .. "\n" .. S "Reach: +2" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stoneadze.obj",
    tiles = { "stoneadze.png" },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    range = 5,
    groups = {dig_immediate = 1, falling_node = 1}, -- falling_node faz ele cair,
    tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 1,
        groupcaps = {
            choppy = {times = {[1] = 20, [2] = 15, [3] = 10.00 }, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50 }, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.40, [2] = 1.00, [3] = 0.60 }, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 7, [2] = 5, [3] = 3}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- bater em node / transformar em terra arada
    node_placement_prediction = "",
    on_place = function(itemstack, puncher, pointed_thing)
        local controls = puncher:get_player_control()
        if controls.sneak then
            if pointed_thing.type == "node" then
                local pos = pointed_thing.under
                local node = c.get_node(pos)
                -- Mapeamento: tora -> madeira
                local conversions = {["nh_nodes:oaklog"]  = "nh_nodes:oakwood", ["nh_nodes:pinelog"] = "nh_nodes:pinewood"}
                local result = conversions[node.name]
                if result then
                    c.set_node(pos, { name = result })
                    local wear = itemstack:get_wear()
                    itemstack:set_wear(wear + 4369)
                end
            end
            return itemstack
        else return c.item_place(itemstack, puncher, pointed_thing)
        end
    end,
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03}},
    wielded_bone_position = {pos = xyz(1.1, 0, 0.1)}, -- Configuração mão direita
    wielded_visual_size = xyz(0.25),
})

c.register_node("nh_nodes:stonehoe", {
    description = S "Stone Hoe" .. "\n" .. S "Reach: +2" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "stonehoe.obj",
    tiles = { "stonehoe.png" },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    range = 5,
    groups = {dig_immediate = 1, falling_node = 1},
    tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.40, [2] = 1.00, [3] = 0.60}, uses = 10, maxlevel = 1},
            choppy = {times = {[1] = 20, [2] = 15, [3] = 10.00}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 6, [2] = 3, [3] = 2}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- bater em node / transformar em terra arada
    node_placement_prediction = "",
    on_place = function(itemstack, puncher, pointed_thing)
        local controls = puncher:get_player_control()
        if controls.sneak then
            if pointed_thing.type == "node" then
                local pos = pointed_thing.under
                local node = c.get_node(pos)
                local convertible = {
                    ["nh_nodes:dirt"]      = true,
                    ["nh_nodes:grass"]     = true,
                    ["nh_nodes:top_grass"] = true,
                }
                if convertible[node.name] then
                    c.set_node(pos, { name = "nh_nodes:tilleddirt" })
                    local wear = itemstack:get_wear()
                    wear = wear + 4369
                    itemstack:set_wear(wear)
                end
            end
            return itemstack -- Sempre cancela o place quando agachado
        else return c.item_place(itemstack, puncher, pointed_thing) end
    end,
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    --after_punch = function(itemstack, user, target)
    --    local wear = itemstack:get_wear()
    --     wear = wear + 4369
    --     itemstack:set_wear(wear)
    --     return itemstack
    --end,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03}},
    wielded_bone_position = { pos = xyz(1.1, 0, 0.1)}, -- Configuração mão direita
    wielded_visual_size = xyz(0.25),
})


---------------------------
-- NODE DA PEDRA LASCADA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
c.register_node("nh_nodes:chippedstoneknife", {
    description = S "Chipped Stone Knife" .. "\n" .. S "Reach: +1" .. "\n" .. S "Damage: +2" .. "\n" .. S "Uses: 15",
    drawtype = "mesh",
    mesh = "chippedstoneknife.obj",
    tiles = { "chippedstoneknife.png" },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    range = 4,
    groups = {oddly_breakable_by_hand = 3, falling_node = 1},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 1.20, [2] = 0.80, [3] = 0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 7, [2] = 5, [3] = 3}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 3},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 4369 -- ~15 usos (65535 / 15)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.05, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.075, -0.5, -0.03, 0.075, 0.05, 0.03}},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(1.1, 0, 0.1)},
})


c.register_node("nh_nodes:obsidianknife", {
    description = S "Obsidian Knife" .. "\n" .. S "Reach: +1" .. "\n" .. S "Damage: +4" .. "\n" .. S "Uses: 10",
    drawtype = "mesh",
    mesh = "obsidianknife.obj",
    tiles = { "obsidianknife.png" },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    range = 4,
    groups = {oddly_breakable_by_hand = 3, falling_node = 1},
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            snappy = {times = {[1] = 1.20, [2] = 0.80, [3] = 0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 7, [2] = 5, [3] = 3}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 5},
    },
    -- cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 6552 -- ~10 usos (65535 / 10)
        itemstack:set_wear(wear)
        return itemstack
    end,
    -- bater em mob
    after_punch = function(itemstack, user, target)
        local wear = itemstack:get_wear()
        wear = wear + 4369
        itemstack:set_wear(wear)
        return itemstack
    end,
    collision_box = {type = "fixed", fixed = {-0.08, -0.5, -0.035, 0.08, 0.05, 0.035}},
    selection_box = {type = "fixed", fixed = {-0.075, -0.5, -0.03, 0.075, 0.05, 0.03}},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(1.1, 0, 0.1)},
})

-- FUNÇÃO DE ARREMESSO (SEIXO branco)
local function throw_white_pebble(itemstack, user)
    local pos = user:get_pos()
    local dir = user:get_look_dir()
    pos.y = pos.y + 2.25
    local obj = c.add_entity(pos, "nh_nodes:white_pebble_entity")
    if obj then
        obj:set_velocity(vector.multiply(dir, 13))
        obj:set_acceleration(xyz(0, -9.81, 0))
        local ent = obj:get_luaentity()
        if ent then ent._shooter = user end
    end
    itemstack:take_item()
    return itemstack
end

---------------------------
-- ITEM ARREMESSÁVEL (SEIXO branco)
---------------------------
c.register_craftitem("nh_nodes:white_pebble_item", {
    description = S "White Pebble" .. "\n" .. S "[Throwable]" .. "\n" .. S "Damage: +1" .. "\n" .. S "(Throw: Q / drop)",
    inventory_image = "white_seixo_arremessavel.png", -- Use uma textura diferente
    wielded_bone_position = {pos = {x = 0.5, y = -0.25, z = 0}}, -- Configuração mão direita
    wielded_visual_size = xyz(0.15),
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 2.50, [2] = 2, [3] = 1}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 2},
    },
    on_place = function(itemstack, placer, pointed_thing) return throw_white_pebble(itemstack, placer) end,
    on_drop = function(itemstack, dropper, pos) return throw_white_pebble(itemstack, dropper) end,
})

-- ENTIDADE DO PROJÉTIL (SEIXO branco)
c.register_entity("nh_nodes:white_pebble_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
        visual = "wielditem",
        visual_size = { x = 0.2, y = 0.2 },
        textures = { "nh_nodes:white_pebble" },
    },
    _stuck = false,
    _timer = 0,
    _stuck_timer = 0,
    _last_pos = nil,
    _shooter = nil, --       Declarado aqui para ficar visível
    on_activate = function(self, staticdata)
        self._timer = 0
        self._stuck = false
        self._stuck_timer = 0
        self._shooter = nil
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then self.object:remove() return end
        -- Timer geral para remover após muito tempo
        self._timer = self._timer + dtime
        if self._timer > 60 then self.object:remove() return end
        -- Se já está grudado
        if self._stuck then self._stuck_timer = self._stuck_timer + dtime
            -- Após 0.1 segundo grudado, vira node
            if self._stuck_timer >= 0.1 then
                local node_pos = vector.round(pos)
                local node = c.get_node(node_pos)

                if node.name == "air" or not c.registered_nodes[node.name].walkable then
                    c.set_node(node_pos, { name = "nh_nodes:white_pebble" })
                else
                    local offsets = {
                        { x = 0,  y = 1,  z = 0 },
                        { x = 0,  y = -1, z = 0 },
                        { x = 1,  y = 0,  z = 0 },
                        { x = -1, y = 0,  z = 0 },
                        { x = 0,  y = 0,  z = 1 },
                        { x = 0,  y = 0,  z = -1 },}
                    local placed = false
                    for _, offset in ipairs(offsets) do
                        local try_pos = vector.add(node_pos, offset)
                        local try_node = c.get_node(try_pos)
                        if try_node.name == "air" then
                            c.set_node(try_pos, { name = "nh_nodes:white_pebble" })
                            placed = true
                            break
                        end
                    end
                    if not placed then c.add_item(pos, "nh_nodes:white_pebble_item") end
                end
                self.object:remove()
            end
            return
        end
        local vel = self.object:get_velocity()
        if not vel then self.object:remove() return end
        local speed = vector.length(vel)
        -- Se a velocidade é muito baixa (parou de se mover)
        if speed < 0.5 then
            self._stuck = true
            self.object:set_velocity((xyz(0)))
            self.object:set_acceleration((xyz(0)))
            return
        end
        -- Verifica colisão com blocos sólidos via raycast manual
        local step_dir = vector.normalize(vel)
        local check_distance = math.min(speed * dtime * 2, 1)
        local steps = math.ceil(check_distance / 0.2)
        for i = 1, steps do
            local check_pos = vector.add(pos, vector.multiply(step_dir, i * 0.2))
            local node = c.get_node(check_pos)
            if node and node.name and c.registered_nodes[node.name] then
                if c.registered_nodes[node.name].walkable then
                    self._stuck = true
                    self.object:set_pos(check_pos)
                    self.object:set_velocity((xyz(0)))
                    self.object:set_acceleration((xyz(0)))
                    return
                end
                if node.name == "nh_nodes:coconutlinked" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:coconut" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut2" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut", count = 2 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut3" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:nut", count = 3 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple" })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple2" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple", count = 2 })
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple3" then
                    c.sound_play("default_dig_cracky", { pos = check_pos, gain = 0.5 })
                    c.set_node(check_pos, { name = "nh_nodes:fallenstick" })
                    c.add_item(check_pos, { name = "nh_nodes:apple", count = 3 })
                    update_neighbors(check_pos)
                    return
                end
            end
        end
        --       Raio aumentado de 0.6 para 1.2 para não passar pelo mob
        local objs = c.get_objects_inside_radius(pos, 1.2)
        for _, obj in ipairs(objs) do
            -- Ignora o próprio projétil e o atirador
            if obj ~= self.object and obj ~= self._shooter then
                local is_target = obj:is_player()

                if not is_target then
                    local ent = obj:get_luaentity()
                    -- Usa get_hp() no lugar de ent.hp_max, compatível com MobsRedo
                    if ent and ent.name ~= "nh_nodes:white_pebble_entity" then
                        local hp = obj:get_hp()
                        if hp and hp > 0 then is_target = true end
                    end
                end
                if is_target then
                    c.log("action", "[Seixo Branco] Acertou alvo em " .. c.pos_to_string(pos))
                    c.sound_play("default_dig_cracky", { pos = pos, gain = 0.5 })
                    obj:punch(self.object, 1.0, {full_punch_interval = 1.0, damage_groups = { fleshy = 2 }, }, vel)
                    c.add_item(pos, "nh_nodes:white_pebble_item")
                    self.object:remove()
                    return
                end
            end
        end
        self._last_pos = pos
    end,
})

---------------------------
-- ENTIDADE DA CHAMA
c.register_entity("nh_nodes:flame_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        selectionbox = { -0.5, 0, -0.5, 0.5, 1.5, 0.5 },
        collisionbox = { -0.5, 0, -0.5, 0.5, 1.5, 0.5 },
        visual = "mesh",
        mesh = "flame.obj",
        textures = { "fire_basic_flame_animated.png" },
        visual_size = { x = 5, y = 5 },
        static_save = true,
        pointable = true,
        glow = 14, -- Emite luz
    },
    _grass_pos = nil,
    _timer = 0,
    _anim_timer = 0,
    _current_frame = 0,
    on_activate = function(self, staticdata)
        if staticdata ~= "" then
            local data = c.deserialize(staticdata)
            if data and data.grass_pos then self._grass_pos = data.grass_pos end
        end
        self._timer = 0
        -- Configura a animação da textura
        self.object:set_sprite({ x = 0, y = 0 }, 1, 1.0, false) -- Posição inicial / Número de frames (colunas) / Duração do frame / Não usar alpha
        -- Define a animação de textura
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,

    get_staticdata = function(self) return c.serialize({ grass_pos = self._grass_pos }) end,

    -- Detecta quando é golpeado
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        -- Verifica se está segurando uma tocha apagada
        if wielded_name == "nh_nodes:torch" then
            -- Remove a tocha apagada do inventário
            wielded:take_item()
            puncher:set_wielded_item(wielded)
            -- Adiciona a tocha acesa ao inventário
            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", "nh_nodes:torch2")
                -- Se o inventário estiver cheio, dropa no chão
                if not leftover:is_empty() then
                    local pos = puncher:get_pos()
                    c.add_item(pos, leftover)
                end
            end
            -- Efeito sonoro
            c.sound_play("fire_flint_and_steel", {pos = self.object:get_pos(), gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    on_step = function(self, dtime)
        self._timer = self._timer + dtime
        self._anim_timer = self._anim_timer + dtime
        -- Anima a textura (16 frames, 1 segundo de duração total)
        if self._anim_timer > (1.0 / 8) then
            self._anim_timer = 0
            self._current_frame = (self._current_frame + 1) % 8
            self.object:set_texture_mod("^[verticalframe:8:" .. self._current_frame)
        end
        -- Verifica a cada 0.5 segundo se a grama ainda existe
        if self._timer > 0.5 then
            self._timer = 0
            if not self._grass_pos then self.object:remove() return end
            local node = c.get_node(self._grass_pos)
            -- Se a grama foi removida, remove a chama
            if node.name ~= "nh_nodes:grassleaves" then self.object:remove() return end
        end
    end,
})

-- NODE DO SEIXO BRANCO NO CHÃO
c.register_node("nh_nodes:white_pebble", {
    description = S "White Pebble",
    tiles = { "whitepebble.png" },
    inventory_image = "seixo_branco.png",
    wield_image = "seixo_branco.png",
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {oddly_breakable_by_hand = 3, falling_node = 1, attached_node = 1, not_in_creative_inventory = 1},
    node_box = {type = "fixed", fixed = {{ -0.15, -0.5, -0.2, 0.15, -0.4, 0.15 },},},
    selection_box = {type = "fixed", fixed = { -0.15, -0.5, -0.2, 0.15, -0.4, 0.15 },},
    drop = "nh_nodes:white_pebble_item",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times = {[1] = 1.30, [2] = 0.90, [3] = 0.50}, uses = 10, maxlevel = 1},
            snappy = {times = {[1] = 2.50, [2] = 2, [3] = 1}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1] = 8, [2] = 6, [3] = 4}, uses = 10, maxlevel = 1}},
        damage_groups = {fleshy = 2},
    },
    sounds = {
        dug = { name = "punchtimber", gain = 0.5 },
        dig = { name = "punchtimber", gain = 0.5 },
        place = { name = "punchtimber", gain = 0.5 },},
    on_construct = function(pos) c.check_for_falling(pos) end,
    after_place_node = function(pos) c.check_for_falling(pos) end,
    -- Quando bater em um seixo branco com outro seixo branco
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher then return end
        -- Verifica se está batendo com outro seixo branco
        local wielded = puncher:get_wielded_item()
        if wielded:get_name() ~= "nh_nodes:white_pebble_item" then return end
        -- Som de impacto
        c.sound_play("GrassFootstep", {pos = pos, gain = 0.2})
        -- PARTÍCULAS AMARELAS LUMINOSAS (FAÍSCAS)
        c.add_particlespawner({
            amount = 10, -- Quantidade de partículas
            time = 0.3,  -- Duração do spawn
            minpos = vector.subtract(pos, xyz(0.2, 0.2, 0.2)),
            maxpos = vector.add(pos, xyz(0.2, 0.2, 0.2)),
            minvel = xyz(-2, 1, -2), -- Velocidade mínima
            maxvel = xyz(2, 4, 2),   -- Velocidade máxima (para cima)
            minacc = xyz(0, -3, 0),  -- Aceleração (gravidade)
            maxacc = xyz(0, -2, 0),
            minexptime = 0.1,                   -- Tempo mínimo de vida
            maxexptime = 0.3,                   -- Tempo máximo de vida
            minsize = 0.1,                      -- Tamanho mínimo
            maxsize = 0.3,                      -- Tamanho máximo
            collisiondetection = true,
            collision_removal = false,
            glow = 14,                          -- Brilho máximo (importante para o efeito luminoso)
            texture = {name = "spark_particle.png^[colorize:#FFAA00:150"}, -- Dourado
        })
        -- Verifica todas as direções adjacentes para acender grama
        local directions = {
            xyz(1,  0,  0),  -- Leste
            xyz(-1, 0,  0),  -- Oeste
            xyz(0,  1,  0),  -- Cima
            xyz(0, -1,  0),  -- Baixo
            xyz(0,  0,  1),  -- Sul
            xyz(0,  0, -1), -- Norte
            xyz(0,  1,  1),
            xyz(0, -1, -1),
            xyz(1,  0,  1),
            xyz(-1, 0, -1),
            xyz(-1, 0,  1),
            xyz(1,  0, -1)}
        for _, dir in ipairs(directions) do
            local check_pos = vector.add(pos, dir)
            local check_node = c.get_node(check_pos)
            -- ACENDE GRAMA
            if check_node.name == "nh_nodes:grassleaves" then
                local has_flame = false
                local objs = c.get_objects_inside_radius(check_pos, 0.5)
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    local flame_pos = xyz(check_pos.x, check_pos.y, check_pos.z)
                    local obj = c.add_entity(flame_pos, "nh_nodes:flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._grass_pos = check_pos end
                    end
                end
            end
            -- ACENDE PALHA
            if check_node.name == "nh_nodes:palmstraw" then
                local meta = c.get_meta(check_pos)
                -- Se a palha já tem chama, não faz nada
                if meta:get_int("has_flame") == 1 then goto continue end
                -- Verifica se já não tem uma chama nessa posição
                local has_flame = false
                local objs = c.get_objects_inside_radius(check_pos, 0.5)
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:palmstraw_flame_entity" then has_flame = true break end
                end
                if not has_flame then
                    -- Marca que tem chama
                    meta:set_int("has_flame", 1)
                    -- Cria a entidade da chama
                    local obj = c.add_entity(check_pos, "nh_nodes:palmstraw_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then ent._straw_pos = check_pos end
                    end
                    -- Efeito sonoro (opcional)
                    c.sound_play("fire_flint_and_steel", {pos = check_pos, gain = 0.5, max_hear_distance = 8}, true)
                end
            end
            ::continue::
        end
    end,
})

-- FUNÇÃO DE ARREMESSO
local function throw_grenade(itemstack, placer, lit)
    if not placer or not placer:is_player() then return itemstack end
    detach_glow(placer)
    local pos = placer:get_pos()
    pos.y = pos.y + 1.5
    local dir = placer:get_look_dir()
    local entity_name = lit and "nh_nodes:litgrenade_entity" or "nh_nodes:grenade_entity"
    local obj = c.add_entity(pos, entity_name)
    if obj then
        obj:set_velocity(vector.multiply(dir, 14))
        obj:set_acceleration(xyz(0, -10, 0))
        local ent = obj:get_luaentity()
        if ent then ent._shooter = placer end
    end
    itemstack:take_item(1)
    return itemstack
end

c.register_node("nh_nodes:grenade", {
    description = S "Grenade",
    drawtype = "mesh",
    mesh = "grenade.obj",
    tiles = { "fusegrenade.png" },
    walkable = false,
    paramtype = "light",
    groups = { snappy = 3, oddly_breakable_by_hand = 1, falling_node = 1 },
    collision_box = {type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 }},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 }},
    on_place = function(itemstack, placer, pointed_thing) return throw_grenade(itemstack, placer, false) end,
    on_drop = function(itemstack, dropper, pos) return throw_grenade(itemstack, dropper, false) end,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "object" then
            local ent = pointed_thing.ref:get_luaentity()
            if ent and FLAME_ENTITIES[ent.name] then
                itemstack:set_name("nh_nodes:litgrenade")
                attach_glow(user)
                -- toca tnt_ignite uma única vez ao acender
                c.sound_play("tnt_ignite", {pos = user:get_pos(), gain = 1, max_hear_distance = 16}, true)
                return itemstack
            end
        end
    end,
})

c.register_entity("nh_nodes:grenade_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        pointable = true,
        static_save = false,
        visual = "mesh",
        mesh = "grenade.obj",
        textures = {"fusegrenade.png"},
        visual_size = {x = 10, y = 10},
        collisionbox = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125},
    },
    _timer = 0,
    _shooter = nil,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then return end
        self._timer = self._timer + dtime
        -- rotação
        local rot = self.object:get_rotation()
        self.object:set_rotation(xyz(rot.x + 0.003, rot.y + 0.2, rot.z))
        local vel = self.object:get_velocity()
        -- se praticamente parou OU timer expirou, vira node
        if vector.length(vel) < 0.2 or self._timer >= 5 then
            local place_pos = vector.round(xyz(pos.x, pos.y - 0.1, pos.z))
            local node = c.get_node(place_pos)
            if DECORATIONS[node.name] or node.name == "air" then
                -- substitui a decoração pela granada
                c.set_node(place_pos, { name = "nh_nodes:grenade" })
            else
                -- node sólido abaixo: coloca no air acima
                local above_pos = vector.round(xyz(pos.x, pos.y + 0.9, pos.z))
                local above_node = c.get_node(above_pos)
                if above_node.name == "air" then c.set_node(above_pos, {name = "nh_nodes:grenade"}) end
            end
            self.object:remove()
            return
        end
    end
})

c.register_node("nh_nodes:litgrenade", {
    description = S "Lit Grenade",
    drawtype = "mesh",
    mesh = "grenade.obj",
    tiles = { "litgrenade.png" },
    walkable = false,
    paramtype = "light",
    groups = { snappy = 3, oddly_breakable_by_hand = 1, falling_node = 1 },
    collision_box = {type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 }},
    selection_box = {type = "fixed", fixed = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 }},
    on_place = function(itemstack, placer, pointed_thing) return throw_grenade(itemstack, placer, true) end,
    on_drop = function(itemstack, dropper, pos) return throw_grenade(itemstack, dropper, true) end,
})

c.register_entity("nh_nodes:litgrenade_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        pointable = true,
        static_save = false,
        visual = "mesh",
        mesh = "grenade.obj",
        textures = { "litgrenade.png" },
        glow = 8,
        visual_size = { x = 10, y = 10 },
        collisionbox = { -0.125, -0.5, -0.125, 0.125, -0.25, 0.125 },
    },
    _timer = 0,
    _shooter = nil,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then return end
        self._timer = self._timer + dtime
        local rot = self.object:get_rotation()
        self.object:set_rotation(xyz(rot.x + 0.003, rot.y + 0.2, rot.z))
        -- explode após 5 segundos
        if self._timer >= 5 then
            c.sound_play("tnt_explode", {pos = pos, gain = 1.0, max_hear_distance = 32})
            c.add_particlespawner({
                amount = 50,
                time = 0.3,
                glow = 14,
                minpos = vector.subtract(pos, 0.5),
                maxpos = vector.add(pos, 0.5),
                minvel = xyz(-4, -4, -4),
                maxvel = xyz(4, 4, 4),
                minexptime = 0.5,
                maxexptime = 1.5,
                minsize = 0.5,
                maxsize = 1,
                texture = "spark_particle.png^[colorize:#FF8800:150",
            })
            -- dano em área
            for _, obj in ipairs(c.get_objects_inside_radius(pos, 4)) do
                if obj ~= self.object then obj:punch(self.object, 1.0, {damage_groups = {fleshy = 12}}) end
            end
            -- transforma neve em avalanche
            local radius = 4
            for x = -radius, radius do
                for y = -radius, radius do
                    for z = -radius, radius do
                        local p = xyz(pos.x + x, pos.y + y, pos.z + z)
                        if vector.distance(pos, p) <= radius then
                            local node = c.get_node(p)
                            if node.name == "nh_nodes:snow_ramp"
                                or node.name == "nh_nodes:snow_insidecorner"
                                or node.name == "nh_nodes:snow_corner" then
                                c.set_node(p, {name = "nh_nodes:avalanche"})
                            end
                        end
                    end
                end
            end
            self.object:remove()
            return
        end
        -- colisão com parede/chão
        local node = c.get_node(vector.round(pos))
        if c.registered_nodes[node.name]
            and c.registered_nodes[node.name].walkable then
            self.object:set_velocity(xyz(0, 0, 0))
            self.object:set_acceleration(xyz(0, 0, 0))
        end
    end,
})

-- NODE DAS FOLHAS DE GRAMA
c.register_node("nh_nodes:grassleaves", {
    --drawtype = "mesh",
    --mesh = "grassleaves.obj",
    --tiles = {"grassleaves.png"},
    description = S "Grass Leaves" .. "\n" .. S "[Small]",
    drawtype = "plantlike",
    tiles = { "grassleavesbasic.png" },
    waving = 1,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}},
    sounds = {
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._grass_pos = pos end
            end
            -- Efeito sonoro (opcional)
            c.sound_play("fire_flint_and_steel", { pos = pos, gain = 0.5, max_hear_distance = 8, }, true)
        end
    end,
    -- Quando a grama for removida, remove as chamas nela
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:flame_entity" then obj:remove() end
        end
    end,
})

-- FOLHAS DE GRAMA - ALTURA MEDIA
c.register_node("nh_nodes:grassleavesmedium", {
    description = S "Grass Leaves" .. "\n" .. S "[Medium]",
    --drawtype = "mesh",
    --mesh = "grassleavesmedium.obj",
    --tiles = {"grama.png"},
    drawtype = "plantlike",
    tiles = { "grassleavesbasic2.png" },
    waving = 1,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}},
    sounds = {
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._grass_pos = pos end
            end
            -- Efeito sonoro (opcional)
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    -- Quando a grama for removida, remove as chamas nela
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:flame_entity" then obj:remove() end
        end
    end,
})

-- FOLHAS DE GRAMA - BAIXA
c.register_node("nh_nodes:smallgrass", {
    description = S"Short Grass",
    drawtype = "mesh",
    mesh = "smallgrass.obj",
    tiles = {"highgrass.png"},
    --drawtype = "plantlike",
    --tiles = {"grassleavesbasic2.png"},
    waving = 1,
    use_texture_alpha = "clip",
    paramtype = "light",
    walkable = false,
    --buildable_to = true,
    groups = {snappy = 2, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
    sounds = {
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            meta:set_int("has_flame", 1) -- Marca que tem chama
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._grass_pos = pos end
            end
            -- Efeito sonoro (opcional)
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    -- Quando a grama for removida, remove as chamas nela
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:flame_entity" then obj:remove() end
        end
    end,
})

c.register_node("nh_nodes:highgrass", {
    description = S "Tall Grass",
    drawtype = "mesh",
    mesh = "highgrass.obj",
    tiles = { "highgrass.png" },
    --drawtype = "plantlike",
    --tiles = {"grassleavesbasic2.png"},
    waving = 1,
    use_texture_alpha = "clip",
    paramtype = "light",
    walkable = false,
    --buildable_to = true,
    groups = {snappy = 2, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.5}},
    sounds = {
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
    -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then return end
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = c.get_meta(pos)
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then return end
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            -- Cria a entidade da chama
            local obj = c.add_entity(pos, "nh_nodes:flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then ent._grass_pos = pos end
            end
            -- Efeito sonoro (opcional)
            c.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
        end
    end,
    -- Quando a grama for removida, remove as chamas nela
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:flame_entity" then obj:remove() end
        end
    end,
})

-- NODE DAS FLORES DE DENTE DE LEAO
c.register_node("nh_nodes:dandelion", {
    description = S "Dandelion",
    drawtype = "mesh",
    mesh = "dandelion.obj",
    tiles = { "dandelion.png" },
    --waving = 1,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 2, flammable = 2 },
    selection_box = {type = "fixed", fixed = {-0.3, -0.5, -0.3, 0.3, -0.1, 0.3}},
    sounds = {
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
})

-- NODE DE JUNCO
c.register_node("nh_nodes:rush", {
    description = S "Rush",
    drawtype = "plantlike",
    tiles = { "rushplant.png" },
    waving = 1,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 1, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}},
    sounds = {
        dug = {name = "GrassDig", gain = 0.5},
        dig = {name = "GrassDig", gain = 0.5},
        place = {name = "GrassDig", gain = 0.5}},
})

-- NODE DO COGUMELO MICACEUS
c.register_node("nh_nodes:micaceusfungus", {
    description = S "Micaceus Fungus",
    drawtype = "mesh",
    mesh = "micaceusfungus.obj",
    tiles = { "micaceusfungus.png" },
    --waving = 1,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.06, -0.5, -0.06, 0.06, -0.19, 0.06}},
    -- Tornar não comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, -2)               -- retira 2 pontos de fome
        apply_poison_damage(user, 0.5, 1, 1.0) -- 0.5 de dano a cada 1 segundo = 4 ticks para completar 2 pontos
        itemstack:take_item()
        return itemstack
    end,
})

-- NODE DO COGUMELO AMANITA (VERMELHO)
c.register_node("nh_nodes:flyamanitafungus", {
    description = S "Fly Agaric Fungus",
    drawtype = "mesh",
    mesh = "flyagaricfungus.obj",
    tiles = {"flyagaricfungus.png"},
    --waving = 1,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    selection_box = {type = "fixed", fixed = {-0.125, -0.5, -0.125, 0.125, -0.22, 0.125}},
    -- Tornar não comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, -4)             -- retira 4 pontos de fome
        apply_poison_damage(user, 1, 2, 1.0) -- 1 ponto de dano a cada 1 segundo = 4 ticks para completar 4 pontos
        itemstack:take_item()
        return itemstack
    end,
})

-- Cinto
c.register_node("nh_nodes:belt", {
    description = S "Basic Belt",
    inventory_image = "belt_icon.png",
    --wield_image = "belt_icon2.png",
    drawtype = "mesh",
    mesh = "belt.obj",
    tiles = { "belt_overlay.png" },
    groups = {oddly_breakable_by_hand = 1, armor_waist = 1},
    stack_max = 1, -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {type = "fixed", fixed = {{-0.28, -0.5, -0.18, 0.28, -0.32, 0.18}}},
    selection_box = {type = "fixed", fixed = {-0.28, -0.5, -0.18, 0.28, -0.32, 0.18}},
    wielded_bone_position = {pos = xyz(0, 1, 0.6), rot = xyz(0, 180, 0)}, -- Configuração mão direita
    wielded_visual_size = xyz(0.2, 0.2, 0.2),
    offhand_bone_position = {pos = xyz(0, -0.8, -1.6), rot = xyz(-90, 0, 90)},
})

-- Mochila: BACKCHEST – funciona exatamente como o oakchest
-- Tabela global: armazena conteúdo de backchests quebrados
-- Chave: ID único (string) gravado no meta do item dropado
backchest_stored_items = backchest_stored_items or {}
local function backchest_new_id() return tostring(os.time()) .. "_" .. tostring(math.random(1, 999999)) end -- ID baseado em tempo + número aleatório para ser único
local function backchest_save_inv(pos)
    local meta  = c.get_meta(pos)
    local inv   = meta:get_inventory()
    local slots = {}
    for i = 1, inv:get_size("main") do
        local stack = inv:get_stack("main", i)
        -- Salva todos os slots (vazios como ""), preservando posições exatas
        slots[i] = stack:to_string()
    end
    return slots
end

local function backchest_restore_inv(pos, slots)
    local meta = c.get_meta(pos)
    local inv  = meta:get_inventory()
    for i, item_str in ipairs(slots) do
        inv:set_stack("main", i, ItemStack(item_str))
    end
end

-- Função auxiliar: atualiza itens visuais no backchest aberto
-- Node: backchest aberto (estado intermediário)
c.register_node("nh_nodes:back_chest_open", {
    drawtype         = "mesh",
    mesh             = "backchest_open.obj",
    tiles            = { "BackChest.png" },
    walkable         = true,
    pointable        = true,
    paramtype        = "light",
    paramtype2       = "facedir",
    selection_box    = { type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } },
    collision_box    = { type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } },
    groups           = { not_in_creative_inventory = 1 },
    on_rightclick    = function(pos, node, clicker, itemstack, pointed_thing)
        local meta        = c.get_meta(pos)
        local player_name = clicker:get_player_name()
        meta:set_string("current_user", player_name)
        c.show_formspec(player_name,
            "nh_nodes:back_chest_" .. c.pos_to_string(pos),
            build_chest_formspec(clicker))
        return itemstack
    end,
    on_construct     = function(pos)
        c.after(0.1, function() back_chest_update_items(pos) end)
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        c.after(0.1, function() back_chest_update_items(pos) end)
    end,
    -- Permite quebrar o baú mesmo estando aberto
    can_dig          = function(pos, player) return true end,
    -- Mesma lógica de salvamento do node fechado
    on_dig           = function(pos, node, digger)
        local meta      = c.get_meta(pos)
        local inv       = meta:get_inventory()
        local has_items = not inv:is_empty("main")
        local chest_id  = meta:get_string("chest_id")
        if chest_id == "" then chest_id = backchest_new_id() end
        if has_items then backchest_stored_items[chest_id] = backchest_save_inv(pos)
        else
            backchest_stored_items[chest_id] = nil
            chest_id = ""
        end
        local drop = ItemStack("nh_nodes:backchest")
        if chest_id ~= "" then
            local drop_meta = drop:get_meta()
            drop_meta:set_string("chest_id", chest_id)
            drop_meta:set_string("description",
                S "Backpack Chest" .. "\n" .. S "(contains items)")
        end
        c.remove_node(pos)
        c.add_item(pos, drop)
        -- Remove todas as entidades visuais ligadas ao baú aberto
        for _, obj in ipairs(c.get_objects_inside_radius(pos, 1)) do
            local ent = obj:get_luaentity()
            if ent and (ent.name == "nh_nodes:chest_item" or
                    ent.name == "nh_nodes:back_chest_entity" or
                    ent.name == "nh_nodes:back_chest_close_entity")
                    then obj:remove()
            end
        end
    end,
})

-- Entidade de animação de abertura do backchest
c.register_entity("nh_nodes:back_chest_entity", {
    initial_properties = {
        visual               = "mesh",
        mesh                 = "backchest.glb",
        textures             = { "BackChest.png" },
        physical             = false,
        collide_with_objects = false,
        pointable            = false,
        static_save          = false,
        paramtype            = "light",
        paramtype2           = "facedir",
    },
    node_pos           = nil,
    original_param2    = 0,
    timer              = 0,
    animation_finished = false,
    is_invisible       = false,
    on_activate        = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
    end,
    on_step            = function(self, dtime)
        if self.is_invisible then return end
        self.timer = self.timer + dtime
        if self.timer > 0.3 and not self.animation_finished then
            self.animation_finished = true
            self.object:set_animation({ x = 0.25, y = 0.25 }, 0, 0, false)
        end
    end,
})

-- Entidade de animação de fechamento do backchest
c.register_entity("nh_nodes:back_chest_close_entity", {
    initial_properties = {
        visual               = "mesh",
        mesh                 = "backchest.glb",
        textures             = { "BackChest.png" },
        physical             = false,
        collide_with_objects = false,
        pointable            = false,
        static_save          = false,
        paramtype            = "light",
        paramtype2           = "facedir",
    },
    node_pos           = nil,
    original_param2    = 0,
    timer              = 0,
    on_activate        = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
    end,
    on_step            = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 0.3 then
            -- Remove itens visuais
            if self.node_pos then
                local objects = c.get_objects_inside_radius(self.node_pos, 1)
                for _, obj in ipairs(objects) do
                    local luaent = obj:get_luaentity()
                    if luaent and luaent.name == "nh_nodes:chest_item" then obj:remove() end
                end
            end
            self.object:remove()
            -- Troca de volta para node fechado
            if self.node_pos then
                local node = c.get_node(self.node_pos)
                if node.name == "nh_nodes:back_chest_open" then
                    c.swap_node(self.node_pos, { name = "nh_nodes:backchest", param2 = self.original_param2 })
                end
            end
        end
    end,
})

-- Detectar fechamento do formspec do backchest
c.register_on_player_receive_fields(function(player, formname, fields)
    local prefix = "nh_nodes:back_chest_"
    if formname:sub(1, #prefix) ~= prefix then return end
    local pos_string = formname:sub(#prefix + 1)
    local pos        = c.string_to_pos(pos_string)
    if not pos then return end
    local node = c.get_node(pos)
    if node.name ~= "nh_nodes:back_chest_open" then return end
    local meta         = c.get_meta(pos)
    local current_user = meta:get_string("current_user")
    local player_name  = player:get_player_name()
    if current_user ~= player_name then return end
    meta:set_string("current_user", "")
    local objects      = c.get_objects_inside_radius(pos, 0.5)
    local chest_entity = nil
    for _, obj in ipairs(objects) do
        local luaent = obj:get_luaentity()
        if luaent and luaent.name == "nh_nodes:back_chest_entity" then chest_entity = obj break end
    end
    local close_entity = c.add_entity(pos, "nh_nodes:back_chest_close_entity")
    if close_entity and close_entity:get_luaentity() then
        local luaentity           = close_entity:get_luaentity()
        luaentity.node_pos        = pos
        luaentity.original_param2 = node.param2
        if chest_entity then
            for _, obj in ipairs(objects) do
                local luaent = obj:get_luaentity()
                if luaent and luaent.name == "nh_nodes:chest_item" then
                    local slot = luaent.slot_index
                    obj:set_attach(close_entity, "bone" .. slot, (xyz(0)), (xyz(0)))
                end
            end
            chest_entity:remove()
        end
        local yaw = c.facedir_to_dir(node.param2)
        close_entity:set_yaw(c.dir_to_yaw(yaw) + math.pi)
        close_entity:set_animation({ x = 0.25, y = 0 }, 30, 0, false)
    end
end)

-- Detectar mudanças no inventário do backchest (atualiza itens visuais)
c.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action ~= "move" and action ~= "put" and action ~= "take" then return end
    if inventory_info.to_list ~= "main" and inventory_info.from_list ~= "main" then return end
    local player_name = player:get_player_name()
    local player_pos  = player:get_pos()
    if not player_pos then return end
    for _, obj in ipairs(c.get_objects_inside_radius(player_pos, 10)) do
        if obj:is_player() then goto backcontinue end
        local pos = obj:get_pos()
        if not pos then goto backcontinue end
        local node = c.get_node_or_nil(pos)
        if not node then goto backcontinue end
        if node.name == "nh_nodes:back_chest_open" then
            local meta = c.get_meta(pos)
            if meta:get_string("current_user") == player_name then back_chest_update_items(pos) end
        end
        ::backcontinue::
    end
end)

-- Node principal: backchest (fechado)
c.register_node("nh_nodes:backchest", {
    description           = S "Backpack Chest",
    drawtype              = "mesh",
    mesh                  = "backchest.obj",
    tiles                 = { "BackChest.png" },
    walkable              = true,
    pointable             = true,
    paramtype             = "light",
    paramtype2            = "facedir",
    groups                = {oddly_breakable_by_hand = 1, armor_back = 1 },
    stack_max             = 1,
    -- Configuração mão direita
    wielded_bone_position = {pos = { x = 0.5, y = 0.5, z = 1.7 }},
    offhand_bone_position = {pos = { x = -1, y = -0.5, z = 1.8 }},
    collision_box         = { type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } },
    selection_box         = { type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } },
    -- Criar inventário ao construir
    on_construct          = function(pos)
        local meta = c.get_meta(pos)
        local inv  = meta:get_inventory()
        inv:set_size("main", 8 * 2)
        meta:set_string("formspec",
            "size[8,9]" ..
            "list[current_name;main;0,0.3;8,2;]" ..
            "list[current_player;main;0,5.85;8,2;8]" ..
            "list[current_player;main;0,8.05;8,1;]" ..
            "listring[current_name;main]" ..
            "listring[current_player;main]"
        )
        meta:set_string("infotext", S "Backpack Chest")
    end,
    -- Permite quebrar mesmo com itens dentro
    can_dig               = function(pos, player)
        return true
    end,
    -- Ao quebrar: salva o conteúdo na tabela global e grava o ID no item dropado
    on_dig                = function(pos, node, digger)
        local meta      = c.get_meta(pos)
        local inv       = meta:get_inventory()
        local has_items = not inv:is_empty("main")
        -- Gera ou reutiliza ID existente (caso o baú já tenha sido colocado antes)
        local chest_id  = meta:get_string("chest_id")
        if chest_id == "" then
            chest_id = backchest_new_id()
        end
        if has_items then
            -- Salva todos os slots na tabela global
            backchest_stored_items[chest_id] = backchest_save_inv(pos)
        else
            -- Sem itens: limpa entrada antiga se existir
            backchest_stored_items[chest_id] = nil
            chest_id = ""
        end
        -- Remove o node e dropa o item
        local drop = ItemStack("nh_nodes:backchest")
        if chest_id ~= "" then
            local drop_meta = drop:get_meta()
            drop_meta:set_string("chest_id", chest_id)
            -- Mostra indicação visual no item de que tem conteúdo
            drop_meta:set_string("description",
                S "Backpack Chest" .. "\n" .. S "(contains items)")
        end
        c.remove_node(pos)
        c.add_item(pos, drop)
        -- Remove entidades visuais que possam ter sobrado
        for _, obj in ipairs(c.get_objects_inside_radius(pos, 1)) do
            local ent = obj:get_luaentity()
            if ent and (
                    ent.name == "nh_nodes:chest_item" or
                    ent.name == "nh_nodes:back_chest_entity" or
                    ent.name == "nh_nodes:back_chest_close_entity"
                ) then
                obj:remove()
            end
        end
    end,
    -- Abrir baú ao clicar
    on_rightclick         = function(pos, node, clicker, itemstack, pointed_thing)
        local current_node = c.get_node(pos)
        c.swap_node(pos, { name = "nh_nodes:back_chest_open", param2 = current_node.param2 })

        -- Remove entidades de animação antigas
        local objects = c.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objects) do
            if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:back_chest_entity" then
                obj:remove()
            end
        end
        -- Cria entidade de animação de abertura
        local entity = c.add_entity(pos, "nh_nodes:back_chest_entity")
        if entity and entity:get_luaentity() then
            local luaentity           = entity:get_luaentity()
            luaentity.node_pos        = pos
            luaentity.original_param2 = current_node.param2
            local yaw                 = c.facedir_to_dir(current_node.param2)
            entity:set_yaw(c.dir_to_yaw(yaw) + math.pi)
            entity:set_animation({ x = 0, y = 0.25 }, 1, 0, false)
        end
        local meta        = c.get_meta(pos)
        local player_name = clicker:get_player_name()
        meta:set_string("current_user", player_name)
        back_chest_update_items(pos)
        c.show_formspec(player_name, "nh_nodes:back_chest_" .. c.pos_to_string(pos), build_chest_formspec(clicker))
        return itemstack
    end,
    -- Ao colocar: restaura inventário a partir da tabela global via ID do item
    after_place_node      = function(pos, placer, itemstack, pointed_thing)
        local item_meta = itemstack:get_meta()
        local chest_id  = item_meta:get_string("chest_id")
        if chest_id ~= "" and backchest_stored_items[chest_id] then
            local meta = c.get_meta(pos)
            -- Grava o mesmo ID no node para futuras quebras
            meta:set_string("chest_id", chest_id)
            backchest_restore_inv(pos, backchest_stored_items[chest_id])
            -- Libera da tabela: agora o inventário vive no node
            backchest_stored_items[chest_id] = nil
        end
    end,
})


-- Luva legal
c.register_node("nh_nodes:likeglove", {
    description = S "Like Glove",
    drawtype = "mesh",
    mesh = "likeglove.obj",
    tiles = { "likeglove.png" },
    stack_max = 1, -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {armor_hands = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5},
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.85, 0, 0), rot = xyz(0, -90, -90)}, -- Posição customizada quando equipado
})

-- Luva apontar
c.register_node("nh_nodes:pointglove", {
    description = S "Point Glove",
    drawtype = "mesh",
    mesh = "pointglove.obj",
    tiles = { "pointglove.png" },
    stack_max = 1, -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {armor_hands = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5, },
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.85, 0, 0), rot = xyz(0, -90, -90)}, -- Posição customizada quando equipado
})

-- Luvas de cobre
c.register_node("nh_nodes:gloves", {
    description = S "Lether Gloves",
    drawtype = "mesh",
    mesh = "glove.obj",
    tiles = { "likeglove.png" },
    stack_max = 1,  -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = {armor_hands = 2, oddly_breakable_by_hand = 3},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.85, 0, 0), rot = xyz(90, -90, -180)}, -- Posição customizada quando equipado
})

-- Luvas de cobre
c.register_node("nh_nodes:coppergauntlets", {
    description = S "Copper Gauntlets",
    drawtype = "mesh",
    mesh = "glove.obj",
    tiles = {"copperglove.png"},
    stack_max = 1,  -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = {armor_hands = 2, oddly_breakable_by_hand = 3},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.85, 0, 0), rot = xyz(90, -90, -180)}, -- Posição customizada quando equipado
})

-- Arma garra de tiro de plasma
c.register_node("nh_nodes:shrimpclaw", {
    description = S "Shrimp Claw",
    drawtype = "mesh",
    mesh = "shrimpclaw.obj",
    tiles = { "shrimp.png" },
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {dig_immediate = 1},
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    wielded_bone_position = {pos = xyz(0.5, 0, 0), rot = xyz(-90, -90, 0)},
    offhand_bone_position = {pos = xyz(1.2, -1, 0.5), rot = xyz(-90, 180, 0)},
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end
        local name = user:get_player_name()
        if get_hunger(user) < 4 then c.chat_send_player(name, S("Estou sem energia suficiente para atirar...")) return itemstack end
        restore_hunger(user, -4)
        local pos = user:get_pos()
        if not pos then return end
        local eye_offset = user:get_eye_offset()
        pos.y = pos.y + 1.5 + (eye_offset and eye_offset.y or 0)
        local dir = user:get_look_dir()
        local spawn_pos = vector.add(pos, vector.multiply(dir, 1.5))
        -- Cria o projétil
        local arrow = c.add_entity(spawn_pos, "nh_mob:plasma")
        if arrow then
            arrow:set_velocity(vector.multiply(dir, 25))
            arrow:set_yaw(user:get_look_horizontal())
            -- Acessa a entidade
            local ent = arrow:get_luaentity()
            if ent then
                ent._owner_obj = user
                ent._lifetime_timer = 0
            end
        end
        itemstack:add_wear(0)
        return itemstack
    end,
})

-- Arma garra de tiro de plasma
c.register_node("nh_nodes:shrimpclaw2", {
    description = S "Dimensional Claw",
    drawtype = "mesh",
    mesh = "shrimpclaw.obj",
    tiles = { "shrimp.png^[colorize:#6600FF:160" },
    light_source = 5,
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {dig_immediate = 1},
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    wielded_bone_position = {pos = xyz(0.5, 0, 0), rot = xyz(-90, -90, 0)},
    offhand_bone_position = {pos = xyz(1.2, -1, 0.5), rot = xyz(-90, 180, 0)},
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end
        local name = user:get_player_name()
        if get_hunger(user) < 4 then c.chat_send_player(name, S"Estou sem energia suficiente para atirar...") return itemstack end
        restore_hunger(user, -4)
        local pos = user:get_pos()
        if not pos then return end
        local eye_offset = user:get_eye_offset()
        pos.y = pos.y + 1.5 + (eye_offset and eye_offset.y or 0)
        local dir = user:get_look_dir()
        local spawn_pos = vector.add(pos, vector.multiply(dir, 1.5))
        -- Cria o projétil
        local arrow = c.add_entity(spawn_pos, "nh_mob:plasma2")
        if arrow then
            arrow:set_velocity(vector.multiply(dir, 25))
            arrow:set_yaw(user:get_look_horizontal())
            -- Acessa a entidade
            local ent = arrow:get_luaentity()
            if ent then
                ent._owner_obj = user
                ent._lifetime_timer = 0
            end
        end
        itemstack:add_wear(0)
        return itemstack
    end,
})

-- Capacete de cobre
c.register_node("nh_nodes:helm", {
    description = S "Leather Helm",
    drawtype = "mesh",
    mesh = "helm.obj",
    tiles = { "leatherhelm.png" },
    stack_max = 1, -- limita a 1 por slot
    groups = {armor_head = 1, oddly_breakable_by_hand = 3},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = { x = 0, y = 2.7, z = 0 }, rot = { x = 0, y = -90, z = 0 }}, -- Posição quando equipado
    --armor_groups = {fleshy = 5},  -- Proteção
})

-- Capacete de cobre
c.register_node("nh_nodes:copperhelmet", {
    description = S "Copper Helmet",
    drawtype = "mesh",
    mesh = "helmet.obj",
    tiles = { "copperhelmet.png" },
    stack_max = 1, -- limita a 1 por slot
    groups = {armor_head = 1, oddly_breakable_by_hand = 3},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = { x = 0, y = 2.7, z = 0 }, rot = { x = 0, y = -90, z = 0 }},   -- Posição quando equipado
    --armor_groups = {fleshy = 5},  -- Proteção
})

-- Armadura peitoral de cobre
c.register_node("nh_nodes:chestplate", {
    description = S "Leather Chestplate",
    drawtype = "mesh",
    mesh = "chestplate.obj",
    tiles = { "leatherchest.png" },
    stack_max = 1, -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {armor_torso = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5},
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.6, 4.1, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
})

-- Armadura peitoral de cobre
c.register_node("nh_nodes:copperchestplate", {
    description = S "Copper Chestplate",
    drawtype = "mesh",
    mesh = "chestplate.obj",
    tiles = { "copperchest.png" },
    stack_max = 1, -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {armor_torso = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5},
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.6, 4.1, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
})

-- Calça de cobre
c.register_node("nh_nodes:coppervambraces", {
    description = S "Copper Vambraces",
    drawtype = "mesh",
    tiles = { "copperlegging.png" },
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = { armor_arms = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5 },
    selection_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 } },
    collision_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 } },
    armor_bone_position = {pos = xyz(0.6, 2.1, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
    armor_skip_main_piece = true,
    -- As 4 peças nos braços
    armor_extra_pieces = {
        {bone = "bone_LArm", mesh = "armsLR.obj", -- braço esquerdo
            pos  = xyz(0, 0.5, 0.5), rot  = xyz(0, -90, 0), size = xyz(5)},
        {bone = "bone_RArm", mesh = "armsLR.obj", -- braço direito
            pos  = xyz(0, 0.5, -0.5), rot  = xyz(0, -90, 0), size = xyz(5)},
        {bone = "bone_LArm_down", mesh = "armsLR.obj", -- antebraço esquerdo
            pos  = xyz(0.5, 0, 0), rot  = xyz(0, -90, 0), size = xyz(4)},
        {bone = "bone_RArm_down", mesh = "armsLR.obj", -- antebraço direito
            pos  = xyz(0.5, 0, 0), rot  = xyz(0, -90, 0), size = xyz(4)},
    },
})

-- Armadura de cintura de cobre
c.register_node("nh_nodes:fauld", {
    description = S "Copper Fauld",
    drawtype = "mesh",
    mesh = "leggings.obj",
    tiles = { "copperlegging.png" },
    stack_max = 1, -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = {armor_waist = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.6, 2.1, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
})

-- Calça de couro
c.register_node("nh_nodes:leggings", {
    description = S "Leather Leggings",
    drawtype = "mesh",
    mesh = "leggings.obj",       -- parte da cintura (já funciona)
    tiles = { "leatherlegging.png" },
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = { armor_legs = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5 },
    selection_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 } },
    collision_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 } },
    armor_bone_position = {pos = xyz(0.6, 2.1, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
    -- As 4 peças nas pernas
    armor_extra_pieces = {
        {bone = "bone_LLeg", mesh = "leggingsLRup.obj", -- coxa esquerda
            pos  = xyz(0, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4.5)},
        {bone = "bone_RLeg", mesh = "leggingsLRup.obj", -- coxa direita
            pos  = xyz(0, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4.5)},
        {bone = "bone_LLeg_down", mesh = "leggingsLRup.obj", -- canela esquerda
            pos  = xyz(-0.5, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4)},
        {bone = "bone_RLeg_down", mesh = "leggingsLRup.obj", -- canela direita
            pos  = xyz(-0.5, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4)},
    },
})

-- Calça de cobre
c.register_node("nh_nodes:copperleggings", {
    description = S "Copper Leggings",
    drawtype = "mesh",
    mesh = "leggings.obj",       -- parte da cintura (já funciona)
    tiles = { "copperlegging.png" },
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = { armor_legs = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5 },
    selection_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 } },
    collision_box = { type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 } },
    armor_bone_position = {pos = xyz(0.6, 2.1, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
    -- As 4 peças nas pernas
    armor_extra_pieces = {
        {bone = "bone_LLeg", mesh = "leggingsLRup.obj", -- coxa esquerda
            pos  = xyz(0, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4.5)},
        {bone = "bone_RLeg", mesh = "leggingsLRup.obj", -- coxa direita
            pos  = xyz(0, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4.5)},
        {bone = "bone_LLeg_down", mesh = "leggingsLRup.obj", -- canela esquerda
            pos  = xyz(-0.5, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4)},
        {bone = "bone_RLeg_down", mesh = "leggingsLRup.obj", -- canela direita
            pos  = xyz(-0.5, -1, 0), rot  = xyz(0, -90, 0), size = xyz(4)},
    },
})

-- Botas de cobre
c.register_node("nh_nodes:boots", {
    description = S "Leather Boots" .. " " .. S "[Footwear]",
    drawtype = "mesh",
    mesh = "boots.obj",
    tiles = { "copperlegging.png" },
    stack_max = 1,  -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = {armor_feet = 1, oddly_breakable_by_hand = 3},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.6, 1.2, 0), rot = xyz(0, -90, 0)} -- Posição customizada quando equipado
})

-- Botas de cobre
c.register_node("nh_nodes:copperboots", {
    description = S "Copper Sabatons" .. " " .. S "[Footwear]",
    drawtype = "mesh",
    mesh = "boots.obj",
    tiles = { "copperlegging.png" },
    stack_max = 1,  -- limita a 1 por slot
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    groups = {armor_feet = 1, oddly_breakable_by_hand = 3},
    selection_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    collision_box = {type = "fixed", fixed = { -0.3, -0.5, -0.3, 0.3, 0.1, 0.3 }},
    armor_bone_position = {pos = xyz(0.6, 1.2, 0), rot = xyz(0, -90, 0)} -- Posição customizada quando equipado
})

-- Asas
c.register_node("nh_nodes:closedwings", {
    description = S "Wings",
    drawtype = "mesh",
    mesh = "closedwings.obj",
    tiles = {"sentinelstatue.png"},
    stack_max = 1, -- limita a 1 por slot
    groups = {oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = { -0.55, -0.5, -0.02, 0.55, 1.7, 0.11 }},
    collision_box = {type = "fixed", fixed = { -0.55, -0.5, -0.02, 0.55, 1.7, 0.11 }},
    armor_bone_position = {pos = xyz(-0.25, -0.5, 0), rot = xyz(0, -90, 0)}, -- Posição customizada quando equipado
    wielded_bone_position = {pos = xyz(-2, 0, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(-2, 0, -0.25)},
    drop = "nh_nodes:wings"
})

c.register_node("nh_nodes:wings", {
    description = S "Wings",
    drawtype = "mesh",
    mesh = "wings.obj",
    tiles = {"sentinelstatue.png"},
    stack_max = 1, -- limita a 1 por slot
    groups = {armor_back = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = { -1.5, -0.5, 0, 1.5, 1.5, 0.1 }},
    collision_box = {type = "fixed", fixed = { -1.5, -0.5, 0, 1.5, 1.5, 0.1 }},
    -- Define posição customizada quando equipado
    armor_bone_position = {pos = xyz(-0.25, -0.5, 0), rot = xyz(0, -90, 0)},
    -- Configuração mão direita
    wielded_bone_position = {pos = { x = -2, y = 0, z = 0 }},
    offhand_bone_position = {pos = { x = -2, y = 0, z = -0.25 }},
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        -- Substitui o nó colocado pelo closedwings, mantendo o facedir
        local node = c.get_node(pos)
        c.set_node(pos, {name = "nh_nodes:closedwings", param2 = node.param2}) -- param2 preserva a rotação/direção
    end,
})

-- ASAS NORMAIS: voo estilo elytra (planador)
local players_with_elytra = {}   -- name -> true quando asas equipadas
local players_gliding     = {}   -- name -> true quando está planando ativamente
local GLIDE_SPEED_MAX    = 18    -- velocidade horizontal máxima (m/s)
local GLIDE_SPEED_MIN    = 2     -- velocidade mínima para manter planando
local GLIDE_GRAVITY      = 0.15  -- gravidade reduzida enquanto planando
local GLIDE_LIFT_FACTOR  = 0.8   -- quanto o olhar para cima converte em sustentação
local GLIDE_DRAG         = 0.97  -- arrasto por tick (desaceleração suave)

local function has_elytra_equipped(player)
    local inv = player:get_inventory()
    local back_list = inv:get_list("armor_back")
    if not back_list then return false end
    for _, stack in ipairs(back_list) do
        if stack:get_name() == "nh_nodes:wings" then return true end
    end
    return false
end

local function is_player_on_ground(player)
    -- Verifica se há nó sólido logo abaixo do player
    local pos = player:get_pos()
    local below = {x = pos.x, y = pos.y - 0.1, z = pos.z}
    local node = c.get_node(below)
    local def = c.registered_nodes[node.name]
    return def and (def.walkable ~= false)
end

c.register_globalstep(function(dtime)
    for _, player in ipairs(c.get_connected_players()) do
        local name = player:get_player_name()
        local wearing = has_elytra_equipped(player)
        -- Equipou / desequipou
        if wearing and not players_with_elytra[name] then
            players_with_elytra[name] = true
            c.chat_send_player(name, S "Wings equipped! Jump while falling to glide.")
        elseif not wearing and players_with_elytra[name] then
            players_with_elytra[name] = nil
            if players_gliding[name] then
                players_gliding[name] = nil
                player:set_physics_override({ gravity = 1.0, speed = 1.0 })
            end
        end
        if not players_with_elytra[name] then goto continue end
        local vel = player:get_velocity()
        local on_ground = is_player_on_ground(player)
        local ctrl = player:get_player_control()
        -- Inicia o planamento: player no ar + velocidade vertical negativa (caindo)
        -- A tecla "jump" ativa o planamento (igual ao Minecraft: pressionar espaço no ar)
        if not players_gliding[name] then
            -- Ativa ao pular estando no ar e em queda
            if ctrl.jump and not on_ground and vel.y < -1.0 then
                players_gliding[name] = true
                c.chat_send_player(name, S "Gliding!")
            end
        else
            -- Desativa ao tocar o chão ou apertar sneak
            if on_ground or ctrl.sneak then
                players_gliding[name] = nil
                player:set_physics_override({ gravity = 1.0, speed = 1.0 })
                goto continue
            end
        end
        if not players_gliding[name] then goto continue end
        -- FÍSICA DE PLANAMENTO
        local look = player:get_look_dir()  -- vetor normalizado da direção do olhar
        -- Velocidade horizontal atual
        local hspeed = math.sqrt(vel.x * vel.x + vel.z * vel.z)
        -- Olhar para baixo (pitch > 0 = baixo) acelera; olhar para cima desacelera mas dá lift
        local pitch = player:get_look_vertical()  -- radianos; positivo = olhando para baixo
        -- Velocidade alvo baseada na inclinação do olhar
        -- Olhar para baixo (pitch positivo): ganha velocidade e perde altitude
        -- Olhar para cima (pitch negativo): perde velocidade e ganha/mantém altitude
        local target_hspeed = hspeed + (pitch * 8.0 * dtime)
        target_hspeed = math.max(GLIDE_SPEED_MIN, math.min(GLIDE_SPEED_MAX, target_hspeed))
        -- Aplica arrasto suave
        target_hspeed = target_hspeed * (GLIDE_DRAG ^ (dtime * 20))
        -- Direção horizontal do olhar (normalizada no plano XZ)
        local hlen = math.sqrt(look.x * look.x + look.z * look.z)
        local dir_x, dir_z = 0, 0
        if hlen > 0.001 then
            dir_x = look.x / hlen
            dir_z = look.z / hlen
        end
        -- Velocidade vertical: pitch para cima gera lift (reduz queda), pitch para baixo mergulha
        -- lift_y: quanto o olhar para cima compensa a queda
        local lift_y = -pitch * GLIDE_LIFT_FACTOR * target_hspeed * dtime
        local new_vy = vel.y + lift_y - (9.8 * GLIDE_GRAVITY * dtime)
        new_vy = math.max(-10, math.min(3, new_vy))  -- limita velocidade vertical
        -- Aplica velocidade final
        player:set_velocity({
            x = dir_x * target_hspeed,
            y = new_vy,
            z = dir_z * target_hspeed,
        })
        -- Suprime a física padrão do motor enquanto planando
        player:set_physics_override({gravity = 0.1, speed = 0.0}) -- desliga gravidade do motor (controlamos manualmente) / movimento de teclado horizontal (controlamos nós)        
        ::continue::
    end
end)

-- Limpa ao deslogar
c.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    players_with_elytra[name] = nil
    if players_gliding[name] then
        players_gliding[name] = nil
        player:set_physics_override({gravity = 1.0, speed = 1.0})
    end
end)

c.register_node("nh_nodes:closedgravitywings", {
    description = S "Gravity Wings",
    drawtype = "mesh",
    mesh = "closedwings.obj",
    tiles = {"sentinelstatue.png^[colorize:#6600FF:160"},
    stack_max = 1, -- limita a 1 por slot
    groups = {oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.55, -0.5, -0.02, 0.55, 1.7, 0.11}},
    collision_box = {type = "fixed", fixed = {-0.55, -0.5, -0.02, 0.55, 1.7, 0.11}},
    armor_bone_position = {pos = xyz(-0.25, -0.5, 0), rot = xyz(0, -90, 0)}, -- Posição quando equipado
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(-2, 0, 0)},
    offhand_bone_position = {pos = xyz(-2, 0, -0.25)},
    drop = "nh_nodes:gravitywings"
})

c.register_node("nh_nodes:gravitywings", {
    description = S "Gravity Wings",
    drawtype = "mesh",
    mesh = "wings.obj",
    tiles = {"sentinelstatue.png^[colorize:#6600FF:160"},
    stack_max = 1, -- limita a 1 por slot
    groups = {armor_back = 1, oddly_breakable_by_hand = 3, snappy = 3, fleshy = 5},
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    selection_box = {type = "fixed", fixed = { -1.5, -0.5, 0, 1.5, 1.5, 0.1 }},
    collision_box = {type = "fixed", fixed = { -1.5, -0.5, 0, 1.5, 1.5, 0.1 }},
    -- Define posição customizada quando equipado
    armor_bone_position = {pos = xyz(-0.25, -0.5, 0), rot = xyz(0, -90, 0)},
    -- Configuração mão direita
    wielded_bone_position = {pos = xyz(-2, 0, 0)},
    offhand_bone_position = {pos = xyz(-2, 0, -0.25)},
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        -- Substitui o nó colocado pelo closedwings, mantendo o facedir
        local node = c.get_node(pos)
        c.set_node(pos, {name = "nh_nodes:closedwings", param2 = node.param2}) -- param2 preserva a rotação/direção
    end,
})

-- ASAS: concede voo enquanto equipado nas costas
local players_with_wings = {}
local players_flying_active = {}
local function has_wings_equipped(player)
    local inv = player:get_inventory()
    local back_list = inv:get_list("armor_back")
    if not back_list then return false end
    for _, stack in ipairs(back_list) do
        if stack:get_name() == "nh_nodes:gravitywings" then return true end
    end
    return false
end
c.register_globalstep(function(dtime)
    for _, player in ipairs(c.get_connected_players()) do
        local name = player:get_player_name()
        local wearing = has_wings_equipped(player)
        local privs = c.get_player_privs(name)
        if wearing and not players_with_wings[name] then
            players_with_wings[name] = true
            privs.fly = true
            c.set_player_privs(name, privs)
            player:set_physics_override({ gravity = 0.5 })
            c.chat_send_player(name, S "The gravity wings are active! Use [flight] (k or enable in the menu) to fly.")
        elseif not wearing and players_with_wings[name] then
            players_with_wings[name] = nil
            players_flying_active[name] = nil  -- limpa estado de voo
            privs.fly = nil
            c.set_player_privs(name, privs)
            player:set_physics_override({ gravity = 1.0 })
            c.chat_send_player(name, S "The gravity wings were removed.")
        end
        -- Detecta se o voo está ativo: asas equipadas + velocidade vertical (não caindo normalmente)
        if players_with_wings[name] then
            local vel = player:get_velocity()
            -- O player está voando se tiver velocidade vertical positiva ou estiver
            -- suspendo no ar sem queda livre normal (gravity reduzida já indica isso)
            -- A forma mais confiável: checar se o priv fly está ativo E o player está no ar
            local on_ground = player:get_physics_override().gravity == 0  -- placeholder
            -- Detecção real: velocidade Y próxima de zero mas longe do chão = flutuando
            local abs_vy = math.abs(vel.y)
            players_flying_active[name] = (abs_vy < 5 and abs_vy > 0.05) or (vel.y > 0.1)  -- subindo
        end
    end
end)

-- Garante que o voo é removido ao deslogar
c.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if players_with_wings[name] then
        players_with_wings[name] = nil
        local privs = c.get_player_privs(name)
        privs.fly = nil
        c.set_player_privs(name, privs)
    end
end)

-- PORTA DE CARVALHO 3x1
-- Porta fechada
c.register_node("nh_nodes:oakdoor", {
    description = S "Oak Door",
    drawtype = "mesh",
    mesh = "oakdoor_closed.obj", -- Um único mesh 3x1
    tiles = {"oakwood3x1.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3, door = 1},
    --sounds = default.node_sound_wood_defaults(),
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, -0.375}}, -- 3 blocos de altura, fina
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.3, 0.5, 2.5, 0.05}},
    wielded_bone_position = {pos = xyz(-2, -0.9, 1.35)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(3, -1, 0.7), rot = xyz(0, 0, 90)}, -- Configuração mão esquerda
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        c.set_node(pos, {name = "nh_nodes:oakdoor_open", param2 = node.param2}) -- Abre a porta
        c.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
    end,
})

-- Porta aberta
c.register_node("nh_nodes:oakdoor_open", {
    description = S "Oak Door" .. "\n" .. S "(Open)",
    drawtype = "mesh",
    mesh = "oakdoor_open.obj", -- Mesmo mesh mas rotacionado/aberto
    tiles = { "oakwood3x1.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { choppy = 3, door = 1, not_in_creative_inventory = 1 },
    drop = "nh_nodes:oakdoor",
    --sounds = default.node_sound_wood_defaults(),
    walkable = false,
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.38, -0.375, 2.5, 0.63}}, -- Porta na lateral quando aberta
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.38, -0.375, 2.5, 0.63}}, -- Colisão fina na lateral
    wielded_bone_position = {pos = xyz(-2, -1, 1.35), rot = xyz(0, -90, -90)},  -- Configuração mão direita
    offhand_bone_position = {pos = xyz(3, -1, -1.4), rot = xyz(0, 90, 90)},  -- Configuração mão esquerda
    -- wielded_visual_size = xyz(0.25),
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        c.set_node(pos, {name = "nh_nodes:oakdoor", param2 = node.param2}) -- Fecha a porta
        c.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
    end,
})
