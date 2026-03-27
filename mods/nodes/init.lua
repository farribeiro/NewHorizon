-----------------------------
-- NODES
-----------------------------
core.log("action", "[nodes] init.lua carregado")

-----
-- Receitas
-----

-- --------------------------------------------------
-- RECEITAS BASICAS (2x2)
-- Usada por: Nodes do chão
-- Inclui crafts básicos
-- --------------------------------------------------

recipes_floor = {
    {
        ingredients = {["nh_nodes:pebble"] = 2},
        output = "nh_nodes:chippedstone"
    },
    {
        ingredients = {["nh_nodes:pebble_item"] = 2},
        output = "nh_nodes:chippedstone"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:chippedstone"] = 1},
        output = "nh_nodes:stoneaxehead"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:stoneaxehead"] = 1},
        output = "nh_nodes:stonepickaxehead"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:stonepickaxehead"] = 1},
        output = "nh_nodes:stonehoehead"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:stonehoehead"] = 1},
        output = "nh_nodes:stoneadzehead"
    },
    {
        ingredients = {["nh_nodes:oakdowel"] = 1, ["nh_nodes:oakboard"] = 1},
        output = "nh_nodes:rowing"
    },
    {
        ingredients = {["nh_nodes:stoneaxehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stoneaxe"
    },
    {
        ingredients = {["nh_nodes:stonepickaxehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stonepickaxe"
    },
    {
        ingredients = {["nh_nodes:stonehoehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stonehoe"
    },
    {
        ingredients = {["nh_nodes:stoneadzehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stoneadze"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:obsidianpebble"] = 1},
        output = "nh_nodes:obsidianblade"
    },
    {
        ingredients = {["nh_nodes:chippedstone"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:chippedstoneknife"
    },
    {
        ingredients = {["nh_nodes:obsidianblade"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:obsidianknife"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 8},
        output = "nh_nodes:cobblestone"
    },
    {
        ingredients = {["nh_nodes:pebble_item"] = 8},
        output = "nh_nodes:cobblestone"
    },
    {
        ingredients = {["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:campfiretinder"
    },
    {
        ingredients = {["nh_nodes:oaklog"] = 1},
        output = "nh_nodes:oakwood",
        required_tool = "nh_nodes:stoneadze",   -- ← só funciona com isso no slot
    },
    {
        ingredients = {["nh_nodes:pinelog"] = 1},
        output = "nh_nodes:pinewood",
        required_tool = "nh_nodes:stoneadze",   -- ← só funciona com isso no slot
    },
    {
        ingredients = {["nh_nodes:palmleaf"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:oakresin"] = 1, ["nh_nodes:grassleaves"] = 1},
        output = "nh_nodes:torch"
    },
    {
        ingredients = {["nh_nodes:oakwood"] = 1},
        output = "nh_nodes:oakboard 8"
    },
    {
        ingredients = {["nh_nodes:oakwood"] = 2},
        output = "nh_nodes:oakplank 4"
    },
    {
        ingredients = {["nh_nodes:oakboard"] = 1},
        output = "nh_nodes:oakdowel 8"
    },
    {
        ingredients = {["nh_nodes:oakdowel"] = 2, ["nh_nodes:oakboard"] = 2},
        output = "nh_nodes:craft_table"
    },
    {
        ingredients = {["nh_nodes:inksac"] = 1, ["nh_nodes:bottle"] = 1},
        output = "nh_nodes:inkbottle"
    },
    {
        ingredients = {["nh_items:writedpage"] = 1, ["nh_nodes:bottle"] = 1},
        output = "nh_nodes:messagebottle"
    },
}

-- --------------------------------------------------
-- RECEITAS DA BANCADA DE PRODUÇÃO (2x2x2)
-- Usada por: craft_table
-- Inclui tudo do floor + itens avançados (espada, baú, porta, piões...)
-- --------------------------------------------------

recipes_table = {
    {
        ingredients = {["nh_nodes:pebble"] = 2},
        output = "nh_nodes:chippedstone"
    },
    {
        ingredients = {["nh_nodes:pebble_item"] = 2},
        output = "nh_nodes:chippedstone"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:chippedstone"] = 1},
        output = "nh_nodes:stoneaxehead"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:stoneaxehead"] = 1},
        output = "nh_nodes:stonepickaxehead"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:stonepickaxehead"] = 1},
        output = "nh_nodes:stonehoehead"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:stonehoehead"] = 1},
        output = "nh_nodes:stoneadzehead"
    },
    {
        ingredients = {["nh_nodes:oakdowel"] = 1, ["nh_nodes:oakboard"] = 1},
        output = "nh_nodes:rowing"
    },
    {
        ingredients = {["nh_nodes:pinelog"] = 6, ["nh_nodes:palmstraw"] = 2},
        output = "nh_nodes:pineraft",
        required_tool = "nh_nodes:palmstraw",   -- ← só funciona com isso no slot
    },
    {
        ingredients = {["nh_nodes:stoneaxehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stoneaxe"
    },
    {
        ingredients = {["nh_nodes:stonepickaxehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stonepickaxe"
    },
    {
        ingredients = {["nh_nodes:stonehoehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stonehoe"
    },
    {
        ingredients = {["nh_nodes:stoneadzehead"] = 1, ["nh_nodes:branch"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:stoneadze"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 1, ["nh_nodes:obsidianpebble"] = 1},
        output = "nh_nodes:obsidianblade"
    },
    {
        ingredients = {["nh_nodes:chippedstone"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:chippedstoneknife"
    },
    {
        ingredients = {["nh_nodes:obsidianblade"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:obsidianknife"
    },
    {
        ingredients = {["nh_nodes:oakboard"] = 1, ["nh_nodes:obsidianblade"] = 7},
        output = "nh_nodes:obsidiansword"
    },
    {
        ingredients = {["nh_nodes:pebble"] = 8},
        output = "nh_nodes:cobblestone"
    },
    {
        ingredients = {["nh_nodes:pebble_item"] = 8},
        output = "nh_nodes:cobblestone"
    },
    {
        ingredients = {["nh_nodes:stick"] = 1, ["nh_nodes:palmstraw"] = 1},
        output = "nh_nodes:campfiretinder"
    },
    {
        ingredients = {["nh_nodes:oaklog"] = 1},
        output = "nh_nodes:oakwood",
        required_tool = "nh_nodes:stoneadze",   -- ← só funciona com isso no slot
    },
    {
        ingredients = {["nh_nodes:pinelog"] = 1},
        output = "nh_nodes:pinewood",
        required_tool = "nh_nodes:stoneadze",   -- ← só funciona com isso no slot
    },
    {
        ingredients = {["nh_nodes:palmleaf"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:oakresin"] = 1, ["nh_nodes:grassleaves"] = 1},
        output = "nh_nodes:torch"
    },
    {
        ingredients = {["nh_nodes:oakwood"] = 1},
        output = "nh_nodes:oakboard 8"
    },
    {
        ingredients = {["nh_nodes:oakwood"] = 2},
        output = "nh_nodes:oakplank 4"
    },
    {
        ingredients = {["nh_nodes:oakboard"] = 1},
        output = "nh_nodes:oakdowel 8"
    },
    {
        ingredients = {["nh_nodes:oakdowel"] = 2, ["nh_nodes:oakboard"] = 2},
        output = "nh_nodes:craft_table"
    },
    {
        ingredients = {["nh_nodes:inksac"] = 1, ["nh_nodes:bottle"] = 1},
        output = "nh_nodes:inkbottle"
    },
    {
        ingredients = {["nh_items:writedpage"] = 1, ["nh_nodes:bottle"] = 1},
        output = "nh_nodes:messagebottle"
    },
    {
        ingredients = {["nh_nodes:oakboard"] = 6},
        output = "nh_nodes:oakchest"
    },
    {
        ingredients = {["nh_nodes:cowfur"] = 2, ["nh_nodes:oakdowel"] = 1},
        output = "nh_nodes:belt"
    },
    {
        ingredients = {["nh_nodes:cowfur"] = 2, ["nh_nodes:oakchest"] = 1},
        output = "nh_nodes:backchest"
    },
    {
        ingredients = {["nh_nodes:cowfur"] = 5},
        output = "nh_nodes:likeglove"
    },
    {
        ingredients = {["nh_nodes:cowfur"] = 6},
        output = "nh_nodes:pointglove"
    },
    {
        ingredients = {["nh_nodes:oakboard"] = 3, ["nh_nodes:oakdowel"] = 2, ["nh_nodes:pebble"] = 2},
        output = "nh_nodes:oakdoor_closed"
    },
    {
        ingredients = {["nh_nodes:oaklog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble"] = 1},
        output = "nh_nodes:spinningtop"
    },
    {
        ingredients = {["nh_nodes:palmlog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble"] = 1},
        output = "nh_nodes:spinningtop2"
    },
    {
        ingredients = {["nh_nodes:pinelog"] = 1, ["nh_nodes:stick"] = 1, ["nh_nodes:white_pebble"] = 1},
        output = "nh_nodes:spinningtop3"
    },
}


-- --------------------------------------------------
-- RECEITAS DA FORNALHA (3x3)
-- Usada por: furnace
-- Inclui: carvão, alimentos cozidos, fundição de metais, vidro
-- --------------------------------------------------
recipes_campfire = {
        {
            ingredients = {["nh_nodes:chicken_egg"] = 1},
            output = "nh_nodes:friedchickenegg"
        },
        {
            ingredients = {["nh_nodes:raw_chicken"] = 1},
            output = "nh_nodes:roastchicken"
        },
        {
            ingredients = {["nh_nodes:cowmeat"] = 1},
            output = "nh_nodes:roastbeef"
        },
}

-- --------------------------------------------------
-- RECEITAS DA FORNALHA (3x3)
-- Usada por: furnace
-- Inclui: carvão, alimentos cozidos, fundição de metais, vidro
-- --------------------------------------------------
recipes_furnace = {
    {
        ingredients = {["nh_nodes:oaklog"] = 1},
        output = "nh_nodes:charcoal"
    },
    {
        ingredients = {["nh_nodes:pinelog"] = 1},
        output = "nh_nodes:charcoal"
    },
    {
        ingredients = {["nh_nodes:palmlog"] = 1},
        output = "nh_nodes:charcoal2"
    },
    {
        ingredients = {["nh_nodes:chicken_egg"] = 1},
        output = "nh_nodes:friedchickenegg"
    },
    {
        ingredients = {["nh_nodes:raw_chicken"] = 1},
        output = "nh_nodes:roastchicken"
    },
    {
        ingredients = {["nh_nodes:cowmeat"] = 1},
        output = "nh_nodes:roastbeef"
    },
    {
        ingredients = {["nh_nodes:coppernugget"] = 3},
        output = "nh_nodes:copperingot"
    },
    {
        ingredients = {["nh_nodes:copperingot"] = 3},
        output = "nh_nodes:copperhelmet"
    },
    {
        ingredients = {["nh_nodes:copperingot"] = 8},
        output = "nh_nodes:copperchestplate"
    },
    {
        ingredients = {["nh_nodes:tinnugget"] = 3},
        output = "nh_nodes:tiningot"
    },
    {
        ingredients = {["nh_nodes:ironnugget"] = 3},
        output = "nh_nodes:ironingot"
    },
    {
        ingredients = {["nh_nodes:sand"] = 3},
        output = "nh_nodes:bottle"
    },
    {
        ingredients = {["default:steel_ingot"] = 9},
        output = "default:steel_block"
    },
}

-- ========================================
-- SISTEMA GENÉRICO DE CRAFTING
-- ========================================

local craft_stations = {}

-- Registra a entidade de display (compartilhada por todas as estações)
core.register_entity("nh_nodes:display_item", {
    initial_properties = {
        visual = "wielditem",
        visual_size = {x=0.25, y=0.25},
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = true,  -- Salva entre sessões
        is_visible = true,
    },
    
    itemstring = "",
    station_pos = nil,
    
    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            local data = core.deserialize(staticdata)
            if data then
                self.itemstring = data.itemstring or ""
                self.station_pos = data.station_pos
                self.object:set_properties({wield_item = self.itemstring})
            end
        end
    end,
    
    get_staticdata = function(self)
        return core.serialize({
            itemstring = self.itemstring,
            station_pos = self.station_pos
        })
    end,
    
    on_step = function(self, dtime)
        self.object:set_velocity({x=0, y=0, z=0})
        self.object:set_acceleration({x=0, y=0, z=0})
        local props = self.object:get_properties()
        if props.glow and props.glow > 0 then
            local rot = self.object:get_rotation()
            self.object:set_rotation({x=0, y=rot.y + 0.005, z=0})
        end
    end,
})

-- ========================================
-- FUNÇÕES AUXILIARES
-- ========================================

-- Remove apenas entidades desta estação específica
local function remove_item_entities(pos)
    local objects = core.get_objects_inside_radius(pos, 2)
    for _, obj in pairs(objects) do
        local entity = obj:get_luaentity()
        if entity and entity.name == "nh_nodes:display_item" then
            -- Verifica se a entidade pertence a ESTA estação
            if entity.station_pos and vector.equals(entity.station_pos, pos) then
                obj:remove()
            end
        end
    end
end

local function update_item_entities(pos, config)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    
    -- Verifica se o inventário existe antes de continuar
    if not inv or inv:get_size("craft") == 0 then
        return
    end
    
    remove_item_entities(pos)
    
    local craft_list = inv:get_list("craft")
    local output_list = inv:get_list("output")
    
    -- Proteção adicional
    if not craft_list or not output_list then
        return
    end
    
    -- Cria entidades para os slots de craft
    for i = 1, config.grid_size do
        local stack = craft_list[i]
        if not stack:is_empty() then
            local item_pos = vector.add(pos, config.positions[i])
            local obj = core.add_entity(item_pos, "nh_nodes:display_item")
            
            if obj then
                local entity = obj:get_luaentity()
                if entity then
                    entity.itemstring = stack:get_name()
                    entity.station_pos = pos  -- Marca a estação dona
                    obj:set_properties({wield_item = stack:get_name()})
                end
            end
        end
    end
    
    -- Cria entidade para o resultado
    local output_stack = output_list[1]
    if output_stack and not output_stack:is_empty() then
        local output_pos = vector.add(pos, config.output_position)
        local obj = core.add_entity(output_pos, "nh_nodes:display_item")
        
        if obj then
            local entity = obj:get_luaentity()
            if entity then
                entity.itemstring = output_stack:get_name()
                entity.station_pos = pos  -- Marca a estação dona
                obj:set_properties({
                    wield_item = output_stack:get_name(),
                    visual_size = {x=0.35, y=0.35},
                    glow = 1,	   
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
    for item, required_count in pairs(recipe.ingredients) do
        if (counts[item] or 0) < required_count then
            return false
        end
    end
    
    -- Verifica se não há itens extras (receita exata)
    local total_required = 0
    for _, count in pairs(recipe.ingredients) do
        total_required = total_required + count
    end
    
    local total_in_grid = 0
    for _, count in pairs(counts) do
        total_in_grid = total_in_grid + count
    end
    
    return total_in_grid == total_required
end

local function check_and_craft(pos, config)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()

    -- Lê a ferramenta no slot extra
    local tool_stack = inv:get_stack("tool", 1)
    local tool_name = tool_stack:get_name()  -- "" se vazio

    for _, recipe in ipairs(config.recipes) do
        -- Se a receita exige ferramenta, verifica
        if recipe.required_tool then
            if tool_name ~= recipe.required_tool then
                goto continue   -- pula esta receita
            end
        end

        if check_recipe(inv, recipe) then
            inv:set_stack("output", 1, ItemStack(recipe.output))
            core.after(0.01, function()
                update_item_entities(pos, config)
            end)
            return
        end

        ::continue::
    end

    inv:set_stack("output", 1, ItemStack(""))
    core.after(0.01, function()
        update_item_entities(pos, config)
    end)
end

local function consume_craft_materials(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    
    for i = 1, inv:get_size("craft") do
        local stack = inv:get_stack("craft", i)
        if not stack:is_empty() then
            stack:take_item(1)
            inv:set_stack("craft", i, stack)
        end
    end
end

local function show_craft_grid(player, pos, config)
    local player_name = player:get_player_name()
    local pos_string = core.pos_to_string(pos)
    
    local formspec = "formspec_version[4]" ..
        "size[10.7,9.7]" ..
        "label[0.5,0.5;" .. config.title .. "]"
    
    local y_offset = 1
    for _, layer in ipairs(config.layers) do
        formspec = formspec ..
            "label[" .. layer.x .. "," .. y_offset .. ";" .. layer.name .. "]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";craft;" ..
            layer.x .. "," .. (y_offset + 0.5) .. ";" .. layer.width .. "," .. layer.height .. ";" .. layer.start_index .. "]"
    end

    -- Posição do slot de ferramenta: usa a config se definida, senão calcula automaticamente
    local tool_x, tool_y
    if config.tool_slot_pos then
        tool_x = config.tool_slot_pos.x
        tool_y = config.tool_slot_pos.y
    else
        local grid_top = y_offset + 0.5
        local max_height = 0
        for _, layer in ipairs(config.layers) do
            if layer.height > max_height then max_height = layer.height end
        end
        tool_x = 3.3
        tool_y = grid_top + (max_height / 2) - 0.5
    end

    formspec = formspec ..
        "label[" .. tool_x .. "," .. tool_y .. ";Usar]" ..
        "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";tool;" .. tool_x .. "," .. (tool_y + 0.5) .. ";1,1;]"

    formspec = formspec ..
        "label[7,1.5;Produz]" ..
        "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";output;7,2;1,1;]" ..
        "button[7,3.2;1,0.8;craft_one;Único]" ..
        "button[7,4.1;1,0.8;craft_all;Todos]" ..
        "list[current_player;main;0.5,5.5;8,2;8]" ..
        "list[current_player;main;0.5,8.1;8,1;]" ..
        "listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";craft]" ..
        "listring[current_player;main]"
    
    core.show_formspec(player_name, config.node_name .. "_" .. pos_string, formspec)
end
-- ========================================
-- FUNÇÃO PRINCIPAL DE REGISTRO
-- ========================================

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
        groups = config.groups or {choppy = 2, oddly_breakable_by_hand = 1},
        paramtype2 = "facedir",
        sounds = config.sounds,
        -- Se tiver mesh, usa drawtype mesh, senão usa normal
        drawtype = config.mesh and "mesh" or "normal",
    }
    
    -- Adiciona mesh apenas se fornecido
    if config.mesh then
        node_def.mesh = config.mesh
    end
    
    -- Adiciona propriedades extras opcionais
    if config.drop then
        node_def.drop = config.drop
    end
    if config.sunlight_propagates ~= nil then
        node_def.sunlight_propagates = config.sunlight_propagates
    end
    if config.paramtype then
        node_def.paramtype = config.paramtype
    end
if config.collision_box then
    node_def.collision_box = config.collision_box
end
if config.selection_box then
    node_def.selection_box = config.selection_box
end

-- Para blocos de craft segurados:
if config.wielded_bone_position then
    node_def.wielded_bone_position = config.wielded_bone_position
end
if config.offhand_bone_position then
    node_def.offhand_bone_position = config.offhand_bone_position
end
if config.wielded_visual_size then
    node_def.wielded_visual_size = config.wielded_visual_size
end
    
    
    -- Função auxiliar para garantir que o inventário existe
local function ensure_inventory(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    
    if inv:get_size("craft") == 0 then
        inv:set_size("craft", config.grid_size)
    end
    if inv:get_size("output") == 0 then
        inv:set_size("output", 1)
    end
    if inv:get_size("tool") == 0 then
        inv:set_size("tool", 1)
    end
end
    
    
    -- ========================================
-- PRESERVA CALLBACKS CUSTOMIZADOS
-- ========================================
-- Salva callbacks fornecidos no config
local custom_on_construct = config.on_construct
local custom_on_timer = config.on_timer

-- MODIFICA on_construct para executar AMBOS
local original_on_construct = node_def.on_construct
node_def.on_construct = function(pos)
    ensure_inventory(pos)
    
    -- ✅ EXECUTA O CALLBACK CUSTOMIZADO PRIMEIRO
    if custom_on_construct then
        custom_on_construct(pos)
    end
    
    -- Depois executa o padrão do crafting
    core.after(0.5, function()
        local node = core.get_node(pos)
        if node and node.name == node_name then
            update_item_entities(pos, config)
        end
    end)
end

-- MODIFICA on_timer para executar AMBOS
node_def.on_timer = function(pos, elapsed)
    -- ✅ EXECUTA O CALLBACK CUSTOMIZADO PRIMEIRO
    if custom_on_timer then
        local result = custom_on_timer(pos, elapsed)
        -- Se retornou false, para aqui
        if result == false then
            return false
        end
    end
    
    -- Se não tem callback customizado ou retornou true, continua normal
    return true
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
        local item_def = core.registered_items[itemstack:get_name()]
        
        if item_def and item_def.type == "node" then
            return core.item_place_node(itemstack, clicker, pointed_thing)
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
    if itemstack:is_empty() then
        core.chat_send_player(
            clicker:get_player_name(),
            "Preciso observar (segurar 'E' ou 'Aux1') e alcançar o chão (clicar 'colocar' de mãos vazias) pra tentar produzir alguma coisa..."
        )
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
        if listname == "craft" or listname == "tool" then
            check_and_craft(pos, config)
        end
    end
    
node_def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
    if listname == "tool" then
        check_and_craft(pos, config)
    elseif listname == "craft" then
        check_and_craft(pos, config)
    elseif listname == "output" then
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local player_inv = player:get_inventory()
        
        -- Consome materiais do primeiro craft
        consume_craft_materials(pos)
        
        -- Tenta craftar em loop (funciona tanto para click normal quanto shift)
        local max_crafts = 64
        local crafted = 1
        
        -- Pequeno delay para garantir que o primeiro item já foi movido
        core.after(0.05, function()
            while crafted < max_crafts do
                local recipe_found = false
                
                -- Verifica se ainda há receita válida
                for _, recipe in ipairs(config.recipes) do
                    if check_recipe(inv, recipe) then
                        recipe_found = true
                        
                        -- Verifica se o jogador tem espaço antes de craftar
                        local result_stack = ItemStack(recipe.output)
                        
                        -- Tenta adicionar ao inventário do jogador
                        local leftover = player_inv:add_item("main", result_stack)
                        
                        -- Se conseguiu adicionar completamente
                        if leftover:is_empty() then
                            consume_craft_materials(pos)
                            crafted = crafted + 1
                        else
                            -- Inventário cheio ou sem espaço suficiente
                            -- Coloca de volta no output se sobrou algo
                            if not leftover:is_empty() then
                                inv:set_stack("output", 1, leftover)
                            end
                            break
                        end
                        
                        break -- sai do loop de receitas
                    end
                end
                
                -- Se não encontrou receita válida, para
                if not recipe_found then
                    break
                end
            end
            
            -- Atualiza o crafting após o loop
            check_and_craft(pos, config)
        end)
    end
end
    
    node_def.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if from_list == "craft" or to_list == "craft" then
            check_and_craft(pos, config)
        end
    end
    
    node_def.on_destruct = function(pos)
        -- Dropa os itens ANTES de destruir
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        
        -- Dropa todos os itens do grid de craft
        for i = 1, inv:get_size("craft") do
            local stack = inv:get_stack("craft", i)
            if not stack:is_empty() then
                core.add_item(pos, stack)
            end
        end
        
        local tool_stack = inv:get_stack("tool", 1)
	if not tool_stack:is_empty() then
    	    core.add_item(pos, tool_stack)
	end
        
        -- Dropa o item do output também (se houver)
        local output_stack = inv:get_stack("output", 1)
        if not output_stack:is_empty() then
            core.add_item(pos, output_stack)
        end
        
        -- Remove as entidades de display
        remove_item_entities(pos)
    end
    
    -- Registra o node com todas as propriedades
    core.register_node(node_name, node_def)
end

core.register_on_player_receive_fields(function(player, formname, fields)
    -- Verifica se é um formspec de craft station
    for node_name, config in pairs(craft_stations) do
        if formname:find(node_name) then
            -- Extrai a posição do formname
            local pos_string = formname:match("_(.+)$")
            if not pos_string then return end
            
            local pos = core.string_to_pos(pos_string)
            if not pos then return end
            
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            local player_inv = player:get_inventory()
            
            if fields.craft_one then
                -- Pega apenas 1
                local output_stack = inv:get_stack("output", 1)
                if not output_stack:is_empty() then
                    local leftover = player_inv:add_item("main", output_stack)
                    if leftover:is_empty() then
                        consume_craft_materials(pos)
                        check_and_craft(pos, config)
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
                        check_and_craft(pos, config)
                        crafted = crafted + 1
                    else
                        break
                    end
                end
            end
            
            return true
        end
    end
end)

---------------------------
-- FUNÇÃO AUXILIAR PARA DANO CONSECUTIVO
---------------------------
local function apply_poison_damage(player, damage_per_tick, total_damage, interval)
    local ticks = math.ceil(total_damage / damage_per_tick)
    local current_tick = 0
    
    local function apply_tick()
        if not player or not player:is_player() then
            return
        end
        
        current_tick = current_tick + 1
        
        -- Aplica o dano na VIDA (HP), não na fome
        local damage_to_apply = math.min(damage_per_tick, total_damage - (current_tick - 1) * damage_per_tick)
        local current_hp = player:get_hp()
        player:set_hp(current_hp - damage_to_apply)
        
        -- Efeito visual/sonoro de dano (opcional)
        minetest.sound_play("player_damage", {
            to_player = player:get_player_name(),
            gain = 0.5,
        }, true)
        
        -- Se ainda há dano a aplicar, agenda o próximo tick
        if current_tick < ticks then
            minetest.after(interval, apply_tick)
        end
    end
    
    -- Inicia o primeiro tick
    apply_tick()
end


register_craft_station("nh_nodes:dirt", {
    description = "Terra",
    tiles = {"terra.png"},
    groups = {crumbly = 2},
    
    sounds = {
	dug = {name = "punchtimber3", gain = 0.5},
	dig  = {name = "punchtimber3", gain = 0.5},
    },
    
    -- Mecânica opcional: grama morrer na sombra
    --paramtype = "light",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
  
on_construct = function(pos)
    local above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local node_above = core.get_node(above).name
    local light = core.get_node_light(above)
    
    --core.chat_send_all("🟤 DIRT construído em " .. core.pos_to_string(pos))
   -- core.chat_send_all("   Bloco acima: " .. node_above)

    if  light and light > 4 then
        core.get_node_timer(pos):start(math.random(30, 60))
       -- core.chat_send_all("   ✅ Timer iniciado!")
    else
        --core.chat_send_all("   ❌ Timer NÃO iniciado (tem bloco escurecendo em cima)")
    end
end,

on_timer = function(pos, elapsed)
    --core.chat_send_all("⏰ TIMER disparou em " .. core.pos_to_string(pos))
    
    local above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local node_above = core.get_node(above).name
    local light = core.get_node_light(above)
    
    --core.chat_send_all("   Bloco acima: " .. node_above)
    
    if light and light <= 4 then
        --core.chat_send_all("   ❌ Tem bloco em cima escurecendo, parando timer")
        return false
    end
    
    --local light = core.get_node_light(pos)
    --core.chat_send_all("   Luz: " .. tostring(light))
    
    if light and light > 4 then
        local neighbors = {
                -- Laterais
                {x = pos.x + 1, y = pos.y, z = pos.z},
                {x = pos.x - 1, y = pos.y, z = pos.z},
                {x = pos.x, y = pos.y, z = pos.z + 1},
                {x = pos.x, y = pos.y, z = pos.z - 1},
                -- Diagonais
                {x = pos.x + 1, y = pos.y, z = pos.z + 1},
                {x = pos.x + 1, y = pos.y, z = pos.z - 1},
                {x = pos.x - 1, y = pos.y, z = pos.z + 1},
                {x = pos.x - 1, y = pos.y, z = pos.z - 1},
                -- Laterais abaixo
                {x = pos.x + 1, y = pos.y - 1, z = pos.z},
                {x = pos.x - 1, y = pos.y - 1, z = pos.z},
                {x = pos.x, y = pos.y - 1, z = pos.z + 1},
                {x = pos.x, y = pos.y - 1, z = pos.z - 1},
                -- Diagonais abaixo
                {x = pos.x + 1, y = pos.y - 1, z = pos.z + 1},
                {x = pos.x + 1, y = pos.y - 1, z = pos.z - 1},
                {x = pos.x - 1, y = pos.y - 1, z = pos.z + 1},
                {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
                -- Laterais acima
                {x = pos.x + 1, y = pos.y + 1, z = pos.z},
                {x = pos.x - 1, y = pos.y + 1, z = pos.z},
                {x = pos.x, y = pos.y + 1, z = pos.z + 1},
                {x = pos.x, y = pos.y + 1, z = pos.z - 1},
                -- Diagonais acima
                {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
                {x = pos.x + 1, y = pos.y + 1, z = pos.z - 1},
                {x = pos.x - 1, y = pos.y + 1, z = pos.z + 1},
                {x = pos.x - 1, y = pos.y + 1, z = pos.z - 1},
            }
        
        local has_grass_neighbor = false
        local grass_found = ""
        
        for _, npos in ipairs(neighbors) do
            local neighbor_name = core.get_node(npos).name
            if neighbor_name == "nh_nodes:grass" or neighbor_name == "nh_nodes:top_grass" then
                has_grass_neighbor = true
                grass_found = neighbor_name .. " em " .. core.pos_to_string(npos)
                break
            end
        end
        
        --core.chat_send_all("   Grama encontrada: " .. tostring(has_grass_neighbor))
        if has_grass_neighbor then
            --core.chat_send_all("   🌱 " .. grass_found)
        end
        
        if has_grass_neighbor then
            core.set_node(pos, {name = "nh_nodes:top_grass"})
            --core.chat_send_all("   🟩 CONVERTEU PARA GRAMA!")
            return false
        else
            --core.chat_send_all("   ⏳ Sem grama ao redor, tentando novamente...")
        end
    else
        --core.chat_send_all("   🌙 Pouca luz (precisa > 4)")
    end
    
    return true
end,
  
    
    title = "Produção 2x2 na Terra",  -- Campo obrigatório!
    
    
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})

core.register_node("nh_nodes:wetdirt", {
    description = "Terra Molhada",
    tiles = {"wetdirt.png"},
    groups = {crumbly = 2},
    
    sounds = {
	dug = {name = "punchtimber3", gain = 0.5},
	dig  = {name = "punchtimber3", gain = 0.5},
    },
    
    -- Mecânica opcional: grama morrer na sombra
    --paramtype = "light",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
  
on_construct = function(pos)
    local above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local node_above = core.get_node(above).name
    local light = core.get_node_light(above)
    
    --core.chat_send_all("🟤 DIRT construído em " .. core.pos_to_string(pos))
   -- core.chat_send_all("   Bloco acima: " .. node_above)

    if  light and light > 4 then
        core.get_node_timer(pos):start(math.random(30, 60))
       -- core.chat_send_all("   ✅ Timer iniciado!")
    else
        --core.chat_send_all("   ❌ Timer NÃO iniciado (tem bloco escurecendo em cima)")
    end
end,

on_timer = function(pos, elapsed)
    --core.chat_send_all("⏰ TIMER disparou em " .. core.pos_to_string(pos))
    
    local above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local node_above = core.get_node(above).name
    local light = core.get_node_light(above)
    
    --core.chat_send_all("   Bloco acima: " .. node_above)
    
    if light and light <= 4 then
        --core.chat_send_all("   ❌ Tem bloco em cima escurecendo, parando timer")
        return false
    end
    
    --local light = core.get_node_light(pos)
    --core.chat_send_all("   Luz: " .. tostring(light))
    
    if light and light > 4 then
        local neighbors = {
                -- Laterais
                {x = pos.x + 1, y = pos.y, z = pos.z},
                {x = pos.x - 1, y = pos.y, z = pos.z},
                {x = pos.x, y = pos.y, z = pos.z + 1},
                {x = pos.x, y = pos.y, z = pos.z - 1},
                -- Diagonais
                {x = pos.x + 1, y = pos.y, z = pos.z + 1},
                {x = pos.x + 1, y = pos.y, z = pos.z - 1},
                {x = pos.x - 1, y = pos.y, z = pos.z + 1},
                {x = pos.x - 1, y = pos.y, z = pos.z - 1},
                -- Laterais abaixo
                {x = pos.x + 1, y = pos.y - 1, z = pos.z},
                {x = pos.x - 1, y = pos.y - 1, z = pos.z},
                {x = pos.x, y = pos.y - 1, z = pos.z + 1},
                {x = pos.x, y = pos.y - 1, z = pos.z - 1},
                -- Diagonais abaixo
                {x = pos.x + 1, y = pos.y - 1, z = pos.z + 1},
                {x = pos.x + 1, y = pos.y - 1, z = pos.z - 1},
                {x = pos.x - 1, y = pos.y - 1, z = pos.z + 1},
                {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
                -- Laterais acima
                {x = pos.x + 1, y = pos.y + 1, z = pos.z},
                {x = pos.x - 1, y = pos.y + 1, z = pos.z},
                {x = pos.x, y = pos.y + 1, z = pos.z + 1},
                {x = pos.x, y = pos.y + 1, z = pos.z - 1},
                -- Diagonais acima
                {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
                {x = pos.x + 1, y = pos.y + 1, z = pos.z - 1},
                {x = pos.x - 1, y = pos.y + 1, z = pos.z + 1},
                {x = pos.x - 1, y = pos.y + 1, z = pos.z - 1},
            }
        
        local has_grass_neighbor = false
        local grass_found = ""
        
        for _, npos in ipairs(neighbors) do
            local neighbor_name = core.get_node(npos).name
            if neighbor_name == "nh_nodes:grass" or neighbor_name == "nh_nodes:top_grass" then
                has_grass_neighbor = true
                grass_found = neighbor_name .. " em " .. core.pos_to_string(npos)
                break
            end
        end
        
        --core.chat_send_all("   Grama encontrada: " .. tostring(has_grass_neighbor))
        if has_grass_neighbor then
            --core.chat_send_all("   🌱 " .. grass_found)
        end
        
        if has_grass_neighbor then
            core.set_node(pos, {name = "nh_nodes:top_grass"})
            --core.chat_send_all("   🟩 CONVERTEU PARA GRAMA!")
            return false
        else
            --core.chat_send_all("   ⏳ Sem grama ao redor, tentando novamente...")
        end
    else
        --core.chat_send_all("   🌙 Pouca luz (precisa > 4)")
    end
    
    return true
end,
})

core.register_node("nh_nodes:tilleddirt", {
    description = "Terra Arada",
    tiles = {"tilleddirt.png","terra.png"},
    groups = {crumbly = 2},
    
    drop = "nh_nodes:dirt",  
    
    sounds = {
        dug = {name = "punchtimber3", gain = 0.5},
        dig  = {name = "punchtimber3", gain = 0.5},
    },
    
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
    },
    
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
    },
  
    on_construct = function(pos)
        core.get_node_timer(pos):start(math.random(30, 60))
    end,

    on_timer = function(pos, elapsed)
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        local node_above = core.get_node(above).name
        if node_above ~= "air" then
            return true
        end

        local laterals = {
            {x = pos.x + 1, y = pos.y, z = pos.z},
            {x = pos.x - 1, y = pos.y, z = pos.z},
            {x = pos.x,     y = pos.y, z = pos.z + 1},
            {x = pos.x,     y = pos.y, z = pos.z - 1},
            -- diagonais
            {x = pos.x + 1, y = pos.y, z = pos.z + 1},
            {x = pos.x + 1, y = pos.y, z = pos.z - 1},
            {x = pos.x - 1, y = pos.y, z = pos.z + 1},
            {x = pos.x - 1, y = pos.y, z = pos.z - 1},
        }

        local has_water = false
        for _, npos in ipairs(laterals) do
            local name = core.get_node(npos).name
            if name == "nh_nodes:water" or name == "nh_nodes:water2"
            or name == "nh_nodes:water_flowing" or name == "nh_nodes:water2_flowing" then
                has_water = true
                break
            end
        end

        if has_water then
            core.set_node(pos, {name = "nh_nodes:wettilleddirt"})
        else
            core.set_node(pos, {name = "nh_nodes:dirt"})
        end
        return false
    end,
})

core.register_node("nh_nodes:wettilleddirt", {
    description = "Terra Arada",
    tiles = {"wettilleddirt.png","wetdirt.png"},
    groups = {crumbly = 2},
    
    drop = "nh_nodes:wetdirt",  
    
    sounds = {
	dug = {name = "punchtimber3", gain = 0.5},
	dig  = {name = "punchtimber3", gain = 0.5},
    },
    
    -- Mecânica opcional: grama morrer na sombra
    --paramtype = "light",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
  
    on_construct = function(pos)
        core.get_node_timer(pos):start(math.random(60, 120))
    end,

    on_timer = function(pos, elapsed)
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        local node_above = core.get_node(above).name

        if node_above ~= "air" then
            return true -- tem bloco em cima, aguarda e tenta de novo
        end

        core.set_node(pos, {name = "nh_nodes:wetdirt"})
        return false
    end,
})


register_craft_station("nh_nodes:grass", {
    description = "Gramado",
    tiles = {"grama.png"},
    groups = {crumbly = 3},
    sunlight_propagates = false,
    drop = "nh_nodes:dirt",    
    
            -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    on_timer = function(pos, elapsed)
        --core.chat_send_all("⏰ TIMER de morte da grama disparou em " .. core.pos_to_string(pos))
        
        -- Verifica se há um bloco bloqueando a luz acima
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        local node_above = core.get_node(above).name
        
        --core.chat_send_all("   Bloco acima: " .. node_above)
        
        -- Se NÃO é ar, significa que está tampado
        if node_above ~= "air" then
            -- Verifica se a luz está muito baixa
            local light = core.get_node_light(above)
            --core.chat_send_all("   Luz: " .. tostring(light))
            
            if light and light <= 4 then
                -- Converte para terra
                core.set_node(pos, {name = "nh_nodes:dirt"})
                --core.chat_send_all("   🟫 GRAMA VIROU TERRA (sem luz)")
                return false  -- Para o timer
            else
                --core.chat_send_all("   ☀️ Ainda tem luz suficiente")
            end
        else
            --core.chat_send_all("   ✅ Ar acima, cancelando timer")
            return false  -- Para o timer se o bloco foi removido
        end
        
        -- Continua verificando
        --core.chat_send_all("   Não se torna terra, terminada a verificação")
        return false
    end,
    
    
    
    title = "Produção 2x2 no Gramado",  -- ✅ Campo obrigatório!
    
    
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})


register_craft_station("nh_nodes:top_grass", {
    description = "Grama",
    -- 6 texturas → top, bottom, right, left, back, front
    tiles = {
        "grama.png",      -- topo (0)
        "terra.png",           -- embaixo (1)
        "grama_terra_lado.png",     -- lado direito (2)
        "grama_terra_lado.png",     -- lado esquerdo (3)
        "grama_terra_lado.png",     -- lado atrás (4)
        "grama_terra_lado.png"      -- lado frente (5)
    },
        title = "Produção 2x2 na Grama",  -- ✅ Campo obrigatório!
    groups = {crumbly = 3, soil = 1},
    -- Quando a grama é bloqueada da luz, vira terra
    drop = "nh_nodes:dirt",
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    on_timer = function(pos, elapsed)
        --core.chat_send_all("⏰ TIMER de morte da grama disparou em " .. core.pos_to_string(pos))
        
        -- Verifica se há um bloco bloqueando a luz acima
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        local node_above = core.get_node(above).name
        
        --core.chat_send_all("   Bloco acima: " .. node_above)
        
        -- Se NÃO é ar, significa que está tampado
        if node_above ~= "air" then
            -- Verifica se a luz está muito baixa
            local light = core.get_node_light(above)
            --core.chat_send_all("   Luz: " .. tostring(light))
            
            if light and light <= 4 then
                -- Converte para terra
                core.set_node(pos, {name = "nh_nodes:dirt"})
                --core.chat_send_all("   🟫 GRAMA VIROU TERRA (sem luz)")
                return false  -- Para o timer
            else
                --core.chat_send_all("   ☀️ Ainda tem luz suficiente")
            end
        else
            --core.chat_send_all("   ✅ Ar acima, cancelando timer")
            return false  -- Para o timer se o bloco foi removido
        end
        
        -- Continua verificando
        --core.chat_send_all("   Não se torna terra, terminada a verificação")
        return false
    end,
    
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})

-- ========================================
-- SISTEMA DE DETECÇÃO DE BLOCOS ACIMA DA GRAMA
-- ========================================

-- Callback global que detecta quando qualquer bloco é colocado
core.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    -- Verifica a posição ABAIXO do bloco que foi colocado
    local below = {x = pos.x, y = pos.y - 1, z = pos.z}
    local node_below = core.get_node(below)
    
    -- Se o bloco abaixo é grama ou top_grass
    if node_below.name == "nh_nodes:grass" or node_below.name == "nh_nodes:top_grass" then
        --core.chat_send_all("📦 Bloco colocado acima da grama em " .. core.pos_to_string(below))
        
        -- Inicia o timer de morte da grama
        core.get_node_timer(below):start(math.random(3, 6))
        --core.chat_send_all("   ⏰ Timer de morte iniciado!")
    end
end)

-- Callback global que detecta quando qualquer bloco é REMOVIDO
core.register_on_dignode(function(pos, oldnode, digger)
    -- Verifica a posição ABAIXO do bloco que foi removido
    local below = {x = pos.x, y = pos.y - 1, z = pos.z}
    local node_below = core.get_node(below)
    
    -- Se o bloco abaixo é grama ou top_grass
    if node_below.name == "nh_nodes:grass" or node_below.name == "nh_nodes:top_grass" then
        --core.chat_send_all("🌞 Bloco removido de cima da grama em " .. core.pos_to_string(below))
        
        -- PARA o timer (a grama voltou a ter luz)
        core.get_node_timer(below):stop()
        --core.chat_send_all("   ⏸️ Timer cancelado (grama exposta à luz novamente)")
   -- end
    
    -- Se o bloco abaixo é terra
    elseif node_below.name == "nh_nodes:dirt" then
        --core.chat_send_all("🌞 Bloco removido de cima da terra em " .. core.pos_to_string(below))
        
        -- PARA o timer (a grama voltou a ter luz)
        core.get_node_timer(below):start(math.random(3, 6))
        --core.chat_send_all("   ⏸️ Timer iniciado (terra exposta à luz)")
    end
end)


register_craft_station("nh_nodes:sand", {
    description = "Areia",
    mesh = nil,
    tiles = {"areia.png"},
    title = "Produção 2x2 na Areia",  -- ✅ Campo obrigatório!
    grid_size = 4,
    groups = {crumbly = 2, falling_node = 1},
    
    sounds = {
	dug = {name = "punchtimber3", gain = 0.5},
	dig  = {name = "punchtimber3", gain = 0.5},
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
        
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})

register_craft_station("nh_nodes:wet_sand", {
    description = "Areia molhada",
    tiles = {"areia_molhada.png"},
    title = "Produção 2x2 na Areia Molhada",  -- ✅ Campo obrigatório!
    groups = {crumbly = 2},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})


core.register_node("nh_nodes:saprolite", {
    description = "Saprólito",
    tiles = {"saprolite.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:basalt", {
    description = "Basalto",
    tiles = {"basalt.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:magma", {
    description = "Basalto",
    tiles = {"magma.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

register_craft_station("nh_nodes:gneiss", {
    description = "Gnaisse",
    tiles = {"pedra.png"},
    groups = {cracky = 3},
    drop = "nh_nodes:pebble_item 8",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    
    title = "Produção 2x2 no Gnaisse",  -- ✅ Campo obrigatório!
    
    
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})

register_craft_station("nh_nodes:cobblestone", {
    description = "Pedregulho",
    tiles = {"cobblestone.png"},
    groups = {cracky = 3},
    drop = "nh_nodes:pebble_item 8",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    title = "Produção 2x2 no Pedregulho",  -- ✅ Campo obrigatório!
    
    
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_floor
})

core.register_node("nh_nodes:charcoal", {
    description = "Carvão Vegetal",
    tiles = {
        "topdowncharcoal.png",   -- topo
        "topdowncharcoal.png",   -- base
        "charcoal.png",       -- lados (direita, esquerda, frente, trás)
    },
    groups = {choppy = 3, armor_head = 1},
    stack_max = 1,
    drop = "nh_nodes:charcoalnugget 8",

    paramtype = "light",
    paramtype2 = "wallmounted",
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },


    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},

    -- Som tocado ao bater no tronco
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig  = {name = "punchtimber", gain = 0.5},
    },
})

core.register_node("nh_nodes:charcoal2", {
    description = "Carvão Vegetal Menor",
    drawtype = "mesh",
    mesh = "palm_trunk.obj",
    tiles = {"charcoal2.png"},
    stack_max = 4,
    drop = "nh_nodes:charcoalnugget 2",
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {
        snappy = 3,
        oddly_breakable_by_hand = 1,
    },
    
    paramtype = "light",
    paramtype2 = "wallmounted",
    
        
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.5, 0.5, 0.25, 0.5},
    },
    
    -- Som tocado ao bater no tronco medio (2)
    sounds = {
        dug = {name = "punchtimber2", gain = 0.5},
        dig  = {name = "punchtimber2", gain = 0.5},
    },
})



core.register_node("nh_nodes:coal", {
    description = "Hulha\nCarvão Mineral",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"coalore.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    drop =  {
        items = {
            {items = {"nh_nodes:coalnugget 8"}},
        }
    },
})

core.register_node("nh_nodes:coalnugget", {
    description = "Pedra de Carvão Mineral",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"coalnugget.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
    },
})

core.register_node("nh_nodes:charcoalnugget", {
    description = "Pedra de Carvão Vegetal",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"charcoalnugget.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
    },
})

core.register_node("nh_nodes:copper", {
    description = "Calcopirita\nMinério de Cobre",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_copperore.png"},
    groups = {cracky = 3},
    drop =  {
        items = {
            {items = {"nh_nodes:coppernugget"}},
            {items = {"nh_nodes:pebble 3"}},
        }
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:coppernugget", {
    description = "Pepita de Cobre",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"coppernugget.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
    },
})

core.register_node("nh_nodes:copperingot", {
    description = "Lingote de Cobre",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"copperingot.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
})

core.register_node("nh_nodes:tin", {
    description = "Cassiterita\nMinério de Estanho",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_tinore.png"},
    groups = {cracky = 3},
    drop =  {
        items = {
            {items = {"nh_nodes:tinnugget"}},
            {items = {"nh_nodes:pebble 3"}},
        }
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:tinnugget", {
    description = "Pepita de Estanho",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"tinnugget.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
    },
})

core.register_node("nh_nodes:tiningot", {
    description = "Lingote de Estanho",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"tiningot.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
})

core.register_node("nh_nodes:iron", {
    description = "Pirita\nMinério de Ferro",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_ironore.png"},
    groups = {cracky = 3},
    drop =  {
        items = {
            {items = {"nh_nodes:ironnugget"}},
            {items = {"nh_nodes:pebble 3"}},
        }
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:ironnugget", {
    description = "Pepita de Ferro",
    drawtype = "mesh",
    mesh = "metalnugget.obj",
    tiles = {"ironnugget.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.35, 0.08},
    },
})

core.register_node("nh_nodes:ironingot", {
    description = "Lingote de Ferro",
    drawtype = "mesh",
    mesh = "metalingot.obj",
    tiles = {"ironingot.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    paramtype = "light",
    walkable = false,
})

core.register_node("nh_nodes:nickel", {
    description = "Garnierita\nMinério de Níquel",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_nickelore.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:manganese", {
    description = "Pirolusita\nMinério de Manganês",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_manganeseore.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:chromium", {
    description = "Cromita\nMinério de Cromo",
    drawtype = "mesh",
    mesh = "copperore.obj",
    tiles = {"gneiss_chromeore.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


core.register_node("nh_nodes:peridotite", {
    description = "Peridotito",
    tiles = {"peridotite.png"},
    groups = {cracky = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:redrock", {
    description = "Ruborita",
    tiles = {"lava.png"},
    groups = {unbreakable = 1, not_in_creative_inventory = 1}, --{unbreakable = 1, not_in_creative_inventory = 1},
    drop = "",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


core.register_node("nh_nodes:bedrock", {
    description = "Bridgmanita",
    tiles = {"matriz.png"},
    drawtype = "glasslike_framed_optional",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    groups = {cracky = 3}, --{cracky = 1, oddly_breakable_by_hand = 1},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:obsidian", {
    description = "Obsidiana",
    tiles = {"obsidiana.png"},
    groups = {cracky = 3}, --{cracky = 1, oddly_breakable_by_hand = 1},
    
    drop = "nh_nodes:obsidianpebble 8",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


core.register_node("nh_nodes:oakresin", {
    description = "Goma de Carvalho",
    drawtype = "mesh",
    mesh = "oakresin.obj",
    tiles = {"oakresin.png"},
    --drawtype = "glasslike_framed_optional",
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    groups = {snappy = 3,
        oddly_breakable_by_hand = 3},
        
        collision_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}
    },
})

-- Função para verificar se um nó tem suporte sólido
local function has_solid_support(pos, checked)
    checked = checked or {}
    local hash = core.hash_node_position(pos)

    if checked[hash] then return false end
    checked[hash] = true
    if #checked > 100 then return false end

    local below = {x = pos.x, y = pos.y - 1, z = pos.z}
    local below_node = core.get_node(below)
    local def = core.registered_nodes[below_node.name]
    if not def then return false end

    -- Algo sólido que NÃO seja árvore
    if below_node.name ~= "air"
       and not def.groups.tree_trunk
       and not def.groups.tree_leaves then
        return true
    end

    -- Tronco abaixo → verifica recursivamente
    if def.groups.tree_trunk then
        return has_solid_support(below, checked)
    end

    return false
end


-- Função para fazer folhas caírem
local function make_leaves_fall(pos)
    local radius_horizontal = 8  -- Alcance lateral
    local radius_vertical = 20   -- Alcance vertical (para cima e para baixo)
    
    for x = -radius_horizontal, radius_horizontal do
        for y = radius_vertical, -radius_vertical, -1 do  -- Aumentado para pegar folhas mais altas
            for z = -radius_horizontal, radius_horizontal do
                local check_pos = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                local node = core.get_node(check_pos)
                
                if core.get_item_group(node.name, "tree_leaves") > 0 then
                    local delay = math.random(2, 10) / 10
                    core.after(delay, function()
                        local current_node = core.get_node(check_pos)
                        if core.get_item_group(current_node.name, "tree_leaves") > 0 then
                            core.remove_node(check_pos)
                            local obj = core.add_entity(check_pos, "__builtin:falling_node")
                            if obj then
                                obj:get_luaentity():set_node(current_node)
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- Tronco 
core.register_node("nh_nodes:oaktimber", {
    description = "Tronco de Carvalho",
    tiles = {"oaktimber.png"},
    groups = {choppy = 3, falling_node = 1, armor_head = 1},
    stack_max = 1,

    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},

    -- Som tocado ao bater no tronco
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig  = {name = "punchtimber", gain = 0.5},
    },
    
    -- Detecta quando o tronco é quebrado ou vai cair
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        -- Verifica se tinha suporte antes de ser quebrado
        -- Se não tinha, significa que vai cair
        local below = {x = pos.x, y = pos.y - 1, z = pos.z}
        local below_node = core.get_node(below)
        
        -- Se abaixo é ar ou outro tronco/folha, faz folhas caírem
        if below_node.name == "air" or below_node.name == "nh_nodes:oaktimber" or below_node.name:find("nh_nodes:leaves") or below_node.name:find("nh_nodes:leaves_nut") or below_node.name:find("nh_nodes:leaves_nut2") or below_node.name:find("nh_nodes:leaves_nut3") then
            make_leaves_fall(pos)
        end
    end,
    
    -- Detecta quando o tronco começa a se mover
    on_construct = function(pos)
        core.get_node_timer(pos):start(0.5)
    end,
    
    on_timer = function(pos)
        local node = core.get_node(pos)
        if node.name == "nh_nodes:oaktimber" then
            -- Se não tem suporte, vai começar a cair
            if not has_solid_support(pos) then
                make_leaves_fall(pos)
                return false  -- Para o timer
            end
            return true  -- Continua verificando
        end
        return false
    end,
        
    drop = "nh_nodes:oaklog",
})

core.register_node("nh_nodes:oaklog", {
    description = "Tora de Carvalho",
    tiles = {
        "topdownoaktimber.png",   -- topo
        "topdownoaktimber.png",   -- base
        "oaktimber.png",       -- lados (direita, esquerda, frente, trás)
    },
    groups = {choppy = 3, armor_head = 1},
    stack_max = 1,

    paramtype = "light",
    paramtype2 = "wallmounted",
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },


    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},

    -- Som tocado ao bater no tronco
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig  = {name = "punchtimber", gain = 0.5},
    },
})

-- Tronco de macieira
core.register_node("nh_nodes:appletimber", {
    description = "Tronco de Macieira",
    drawtype = "mesh",
    mesh = "appletimber.obj",
    tiles = {"appletimber.png"},
    groups = {choppy = 3, falling_node = 1, armor_head = 1},
    stack_max = 1,
    paramtype = "light",
    sunlight_propagates = true,
    
    collision_box = {
        type = "fixed",
        fixed = {-0.095, -0.5, -0.095, 0.095, 0.5, 0.095},
    },
    
    selection_box = {
        type = "fixed",
        fixed = {-0.095, -0.5, -0.095, 0.095, 0.5, 0.095},
    },
    
    sounds = {
    dug = {name = "punchtimber3", gain = 0.5},
    dig  = {name = "punchtimber3", gain = 0.5},
},
    

    
    -- Detecta quando o tronco é quebrado ou vai cair
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local below = {x = pos.x, y = pos.y - 1, z = pos.z}
        local below_node = core.get_node(below)
        
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
    
    on_construct = function(pos)
        core.get_node_timer(pos):start(0.5)
    end,
    
    on_timer = function(pos)
        local node = core.get_node(pos)
        if node.name == "nh_nodes:appletimber" then
            if not has_solid_support(pos) then
                make_leaves_fall(pos)
                return false
            end
            return true
        end
        return false
    end,
})

-- Tronco 3
core.register_node("nh_nodes:pinetimber", {
    description = "Tronco de Pinheiro",
    tiles = {"pinetimber.png"},
    groups = {choppy = 3, falling_node = 1, armor_head = 1},
    stack_max = 1,
    
    -- Som tocado ao bater no tronco
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig  = {name = "punchtimber", gain = 0.5},
    },
    
    -- Detecta quando o tronco é quebrado ou vai cair
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        -- Verifica se tinha suporte antes de ser quebrado
        -- Se não tinha, significa que vai cair
        local below = {x = pos.x, y = pos.y - 1, z = pos.z}
        local below_node = core.get_node(below)
        
        -- Se abaixo é ar ou outro tronco/folha, faz folhas caírem
        if below_node.name == "air" or below_node.name == "nh_nodes:pinetimber" or below_node.name:find("nh_nodes:leaves") then
            make_leaves_fall(pos)
        end
    end,
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    
    -- Detecta quando o tronco começa a se mover
    on_construct = function(pos)
        core.get_node_timer(pos):start(0.5)
    end,
    
    on_timer = function(pos)
        local node = core.get_node(pos)
        if node.name == "nh_nodes:pinetimber" then
            -- Se não tem suporte, vai começar a cair
            if not has_solid_support(pos) then
                make_leaves_fall(pos)
                return false  -- Para o timer
            end
            return true  -- Continua verificando
        end
        return false
    end,
    
        
    drop = "nh_nodes:pinelog",
})

core.register_node("nh_nodes:pinelog", {
    description = "Tora de Pinheiro",
    tiles = {
        "topdownpinetimber.png",   -- topo
        "topdownpinetimber.png",   -- base
        "pinetimber.png",       -- lados (direita, esquerda, frente, trás)
    },
    groups = {choppy = 3, armor_head = 1},
    stack_max = 1,

    paramtype = "light",
    paramtype2 = "wallmounted",
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },

    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},

    -- Som tocado ao bater no tronco
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig  = {name = "punchtimber", gain = 0.5},
    },
})

-- Madeira
core.register_node("nh_nodes:oakwood", {
    description = "Madeira de Carvalho",
    tiles = {"oakwood.png"},
    groups = {choppy = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

-- Madeira
core.register_node("nh_nodes:pinewood", {
    description = "Madeira de Pinheiro",
    tiles = {"pinewood.png"},
    groups = {choppy = 3},
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:bone", {
    description = "Osso",
    drawtype = "mesh",
    mesh = "bone.obj",
    tiles = {"bone.png"},
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    stack_max = 8,

    paramtype = "light",
    paramtype2 = "wallmounted",
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },

    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.25, y = 0, z = 0},
        rot = {x = 90, y = 90, z = 90},
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    --offhand_bone_position = {
    --    pos = {x = 0, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    --},
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},

    -- Som tocado ao bater no tronco
    sounds = {
        dug = {name = "punchtimber", gain = 0.5},
        dig  = {name = "punchtimber", gain = 0.5},
    },
})


-- slime 
core.register_node("nh_nodes:slime", {
    description = "Slime colecionável",
    drawtype = "mesh",
    mesh = "planaria_slime_small2.obj",
    tiles = {"planaria_slime2.png"},
    groups = {snappy = 3},
    
    paramtype = "light",
        -- BRILHO NOS OLHOS
    glow = 5,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    -- TRANSPARENCIA
    use_texture_alpha = "blend",
    
        -- Configuração mão direita
    wielded_bone_position = {
        --pos = {x = 0, y = 0, z = 1.5},
        rot = {x = 0, y = 90, z = -90}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0},
        rot = {x = 0, y = 90, z = -90}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

-- grilo 
core.register_node("nh_nodes:cricket", {
    description = "Grilo colecionável",
    drawtype = "mesh",
    mesh = "cricket.obj",
    tiles = {"cricket.png"},
    groups = {snappy = 3},
    
    paramtype = "light",
    use_texture_alpha = "clip",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

-- Madeira
core.register_node("nh_nodes:campfiretinder", {
    description = "Isca de fogueira",
    drawtype = "mesh",
    mesh = "iscafogueira.obj",
    tiles = {"iscafogueira.png"},
    groups = {snappy = 3},
    use_texture_alpha = "blend",
    paramtype = "light",
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },
})


-- Tronco de carvalho fatiado
core.register_node("nh_nodes:oaktimberslice", {
    description = "Lenha de Carvalho",
    drawtype = "mesh",
    mesh = "oaktimberslice.obj",
    tiles = {"oaktimber.png"},
    groups = {choppy = 3},
    stack_max = 16,
    
    on_place = function(itemstack, placer, pointed_thing)
        -- Verifica se o jogador está agachado
        if placer and placer:is_player() and placer:get_player_control().sneak then
            -- Comportamento normal de colocação (com shift)
            return core.item_place(itemstack, placer, pointed_thing)
        end
        
        -- Se está clicando em um node (sem agachar)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = core.get_node(pos)
            
            -- Verifica qual estágio está e evolui (apenas se mirar em campfiretinder)
            if node.name == "nh_nodes:campfiretinder" then
                core.set_node(pos, {name = "nh_nodes:oaktimberslice1"})
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:oaktimberslice1" then
                core.set_node(pos, {name = "nh_nodes:oaktimberslice2"})
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:oaktimberslice2" then
                core.set_node(pos, {name = "nh_nodes:oaktimberslice3"})
                itemstack:take_item()
                return itemstack
            elseif node.name == "nh_nodes:oaktimberslice3" then
                core.set_node(pos, {name = "nh_nodes:campfire"})
                itemstack:take_item()
                return itemstack
            end
        end
        
        -- Comportamento normal de colocação para outros casos
        return core.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Lenha de carvalho 1 - 1/4 firewood
core.register_node("nh_nodes:oaktimberslice1", {
    description = "Lenha na Fogueira 1",
    drawtype = "mesh",
    mesh = "oaktimberslice1.obj",
    tiles = {"fogueira.png"},
    groups = {choppy = 3},
    use_texture_alpha = "blend",
    paramtype = "light",
    stack_max = 16,
    drop = "nh_nodes:oaktimberslice",
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then
            return itemstack
        end
        
        local pos = pointed_thing.under
        local node = core.get_node(pos)
        
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:oaktimberslice1" and itemstack:get_name() == "nh_nodes:oaktimberslice" then
                core.set_node(pos, {name = "nh_nodes:oaktimberslice2"})
                itemstack:take_item()
                return itemstack
            end
        end
        
        return core.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Lenha de carvalho 2 - 2/4 firewood
core.register_node("nh_nodes:oaktimberslice2", {
    description = "Lenha na Fogueira 2",
    drawtype = "mesh",
    mesh = "oaktimberslice2.obj",
    tiles = {"fogueira.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {choppy = 3},
    stack_max = 16,
    drop = "nh_nodes:oaktimberslice 2",
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then
            return itemstack
        end
        
        local pos = pointed_thing.under
        local node = core.get_node(pos)
        
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:oaktimberslice2" and itemstack:get_name() == "nh_nodes:oaktimberslice" then
                core.set_node(pos, {name = "nh_nodes:oaktimberslice3"})
                itemstack:take_item()
                return itemstack
            end
        end
        
        return core.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Lenha de carvalho 3 - 3/4 firewood
core.register_node("nh_nodes:oaktimberslice3", {
    description = "Lenha na Fogueira 3",
    drawtype = "mesh",
    mesh = "oaktimberslice3.obj",
    tiles = {"fogueira.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    groups = {choppy = 3},
    stack_max = 16,
    drop = "nh_nodes:oaktimberslice 3",
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing.type == "node" then
            return itemstack
        end
        
        local pos = pointed_thing.under
        local node = core.get_node(pos)
        
        if placer and placer:is_player() and placer:get_player_control().sneak then
            if node.name == "nh_nodes:oaktimberslice3" and itemstack:get_name() == "nh_nodes:oaktimberslice" then
                core.set_node(pos, {name = "nh_nodes:campfire"})
                itemstack:take_item()
                return itemstack
            end
        end
        
        return core.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Fogueira (estágio final) - Campfire - 4/4 firewood
register_craft_station("nh_nodes:campfire", {
    description = "Fogueira",
    drawtype = "mesh",
    mesh = "oaktimberslice4.obj",
    tiles = {"fogueira.png"},
    use_texture_alpha = "blend",
    
    paramtype = "light",
    groups = {choppy = 3},
    stack_max = 1,
    drop = {
        items = {
            {items = {"nh_nodes:oaktimberslice 4"}},
            {items = {"nh_nodes:campfiretinder"}},
        }
    },
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },

    
    title = "Produção 2x2 na Fogueira",  -- ✅ Campo obrigatório!
    
        grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_campfire,

        -- Quando a fogueira é colocada, verifica se deve criar chama
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        -- Se já tiver chama marcada, cria a entidade
        if meta:get_int("has_flame") == 1 then
            core.after(0.1, function()
                -- Verifica se não existe chama já
                local objs = core.get_objects_inside_radius(pos, 0.5)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:campfire_flame_entity" then
                        has_flame = true
                        break
                    end
                end
                
                if not has_flame then
                    local obj = core.add_entity(pos, "nh_nodes:campfire_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then
                            ent._straw_pos = pos
                        end
                    end
                end
            end)
        end
    end,
    
    -- Quando a fogueira é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then
            return
        end
        
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = core.get_meta(pos)
        
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then
            return
        end
        
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            
            -- Cria a entidade da chama
            local obj = core.add_entity(pos, "nh_nodes:campfire_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then
                    ent._straw_pos = pos
                end
            end
            
            -- Efeito sonoro (opcional)
            core.sound_play("fire_flint_and_steel", {
                pos = pos,
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
        end
    end,
    
    -- Quando a fogueira for removida, remove as chamas
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = core.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:campfire_flame_entity" then
                obj:remove()
            end
        end
    end,
})

---------------------------
-- ENTIDADE DA CHAMA DA PALHA
---------------------------
core.register_entity("nh_nodes:campfire_flame_entity", {
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
            local data = core.deserialize(staticdata)
            if data and data.straw_pos then
                self._straw_pos = data.straw_pos
            end
        end
        self._timer = 0
        
        self.object:set_sprite(
            {x = 0, y = 0},
            1,
            1.0,
            false
        )
        
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    
    get_staticdata = function(self)
        return core.serialize({straw_pos = self._straw_pos})
    end,
    
    -- Detecta quando é golpeado para acender tochas
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then
            return
        end
        
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
                    core.add_item(pos, leftover)
                end
            end
            
            core.sound_play("fire_flint_and_steel", {
                pos = self.object:get_pos(),
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
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
            
            if not self._straw_pos then
                self.object:remove()
                return
            end
            
            local node = core.get_node(self._straw_pos)
            
            -- Se a palha foi removida, remove a chama
            if node.name ~= "nh_nodes:campfire" then
                self.object:remove()
                return
            end
            
            -- Verifica se ainda deve ter chama
            local meta = core.get_meta(self._straw_pos)
            if meta:get_int("has_flame") ~= 1 then
                self.object:remove()
                return
            end
        end
    end,
})     

core.register_node("nh_nodes:spinningtop", {
    description = "Pião de Carvalho\n[Item de Spawn]",
    drawtype = "mesh",
    mesh = "piao.obj",
    tiles = {"oakpiao.png"},
    inventory_image = "oakpiaoinv.png",
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -0.25, y = 0.5, z = 0},
        rot = {x = 0, y = 0, z = 45},
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Tornar comestível
    --on_use = function(itemstack, user, pointed_thing)
        --restore_hunger(user, 2)  -- Restaura 4 pontos
        --itemstack:take_item()
        --return itemstack
    --end,
    
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local pos = pointed_thing.above  -- posição onde vai spawnar
        
        -- Spawna o mob
        local mob = minetest.add_entity(pos, "nh_mob:spinningtop")
        
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

core.register_node("nh_nodes:spinningtop2", {
    description = "Pião de Coqueiro\n[Item de Spawn]",
    drawtype = "mesh",
    mesh = "piao.obj",
    tiles = {"palmpiao.png"},
    inventory_image = "palmpiaoinv.png",
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -0.25, y = 0.5, z = 0},
        rot = {x = 0, y = 0, z = 45},
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
 
    
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local pos = pointed_thing.above  -- posição onde vai spawnar
        
        -- Spawna o mob
        local mob = minetest.add_entity(pos, "nh_mob:spinningtop2")
        
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

core.register_node("nh_nodes:spinningtop3", {
    description = "Pião de Pinheiro\n[Item de Spawn]",
    drawtype = "mesh",
    mesh = "piao.obj",
    tiles = {"pinepiao.png"},
    inventory_image = "pinepiaoinv.png",
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -0.25, y = 0.5, z = 0},
        rot = {x = 0, y = 0, z = 45},
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Tornar comestível
    --on_use = function(itemstack, user, pointed_thing)
        --restore_hunger(user, 2)  -- Restaura 4 pontos
        --itemstack:take_item()
        --return itemstack
    --end,
    
    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local pos = pointed_thing.above  -- posição onde vai spawnar
        
        -- Spawna o mob
        local mob = minetest.add_entity(pos, "nh_mob:spinningtop3")
        
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


-- ========================================
-- EXEMPLOS DE USO
-- ========================================

-- Exemplo 1: Mesa de Craft 2x2x2 (original)
register_craft_station("nh_nodes:craft_table", {
    description = "Bancada de Produção",
    drawtype = "mesh",
    mesh = "craft_table.obj",
    tiles = {"craft_table.png"},
    title = "Bancada de Produção 2x2x2",
    grid_size = 8,
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1.5, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    positions = {
        {x=-0.2, y=0.7, z=-0.2}, {x=0.2, y=0.7, z=-0.2},
        {x=-0.2, y=0.7, z=0.2},  {x=0.2, y=0.7, z=0.2},
        {x=-0.2, y=1.1, z=-0.2}, {x=0.2, y=1.1, z=-0.2},
        {x=-0.2, y=1.1, z=0.2},  {x=0.2, y=1.1, z=0.2},
    },
    
    tool_slot_pos = {x = 5.6, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.7, z=0},
    
    layers = {
        {name="Camada Inferior", x=0.5, width=2, height=2, start_index=0},
        {name="Camada Superior", x=3, width=2, height=2, start_index=4},
    },
    
    recipes = recipes_table
})

-- Exemplo 2: Fornalha 3x3 simples (SEM mesh, usando drawtype normal)
register_craft_station("nh_nodes:furnace", {
    description = "Fornalha",
    title = "Fornalha 3x3",
    drawtype = "mesh",
    mesh = "furnace.obj",
    tiles = {"stonefurnace.png"}, --cobblestone.png
    paramtype = "light",  -- Necessário para iluminação correta
    paramtype2 = "facedir",  -- IMPORTANTE: paramtype2, não paramtype
 
        -- Caixas de colisão e seleção
    collision_box = {
        type = "fixed",  
        fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.5}
    },
    selection_box = {
        type = "fixed",  
        fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.5}
    },
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -2.5, y = -1, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = -1.5, y = -1, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    grid_size = 9,
    
    positions = {
        {x=-0.3, y=0.9, z=-0.3}, {x=0, y=0.9, z=-0.3}, {x=0.3, y=0.9, z=-0.3},
        {x=-0.3, y=0.9, z=0},    {x=0, y=0.9, z=0},    {x=0.3, y=0.9, z=0},
        {x=-0.3, y=0.9, z=0.3},  {x=0, y=0.9, z=0.3},  {x=0.3, y=0.9, z=0.3},
    },
    
    tool_slot_pos = {x = 4.3, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.2, z=0},
    
    layers = {
        {name="Grid 3x3", x=0.5, width=3, height=3, start_index=0},
    },
    
    recipes = recipes_furnace
})

-- Bancada Avançada 3x3x3 simples (SEM mesh)
register_craft_station("nh_nodes:advanced_bench", {
    description = "Bancada Avançada",
    -- mesh = nil,  -- Opcional
    tiles = {""}, --advanced_bench.png
    title = "Bancada Avançada 3x3x3",
    grid_size = 4,
    
    positions = {
        {x=-0.2, y=0.9, z=-0.2}, {x=0.2, y=0.9, z=-0.2},
        {x=-0.2, y=0.9, z=0.2},  {x=0.2, y=0.9, z=0.2},
    },
    
    tool_slot_pos = {x = 3.1, y = 1},  -- ajusta x e y até ficar no lugar certo
    
    output_position = {x=0, y=1.4, z=0},
    
    layers = {
        {name="Grid 2x2", x=0.5, width=2, height=2, start_index=0},
    },
    
    recipes = recipes_table
})


-- Prancha
core.register_node("nh_nodes:oakplank", {
    description = "Prancha de Carvalho",
    drawtype = "mesh",
    mesh = "oakplank.obj",
    tiles = {"oakwood.png"},
    groups = {choppy = 3},

    paramtype = "light",
    paramtype2 = "wallmounted",
    
        -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -0.5, y = -0.9, z = 0.2}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 0, y = -0.9, z = -1}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        wall_side = {-0.5, -0.5, -0.5, 0, 0.5, 0.5},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {0, 0, 0, 0, 0.5, 0},
        wall_bottom = {0, -0.5, 0, 0, 0, 0},
        wall_side = {-0.5, 0, 0, -0.5, 0.5, 0},
    },    
})

-- Tábua
core.register_node("nh_nodes:oakboard", {
    description = "Tábua de Carvalho",
    drawtype = "mesh",
    mesh = "oakboard.obj",
    tiles = {"oakwood.png"},
    groups = {choppy = 3},
    paramtype = "light",
    paramtype2 = "facedir",
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, 0.38, 0.5, 0.5, 0.5},
    },
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.06, 0.5, 0.5, 0.06},
    },
    
            -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0, y = -0.9, z = -0.8}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 0, y = -0.9, z = -1.2}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    on_place = function(itemstack, placer, pointed_thing)
        if not placer or not placer:is_player() then
            return itemstack
        end
        
        -- Detecta em qual face foi clicado
        local under = pointed_thing.under
        local above = pointed_thing.above
        local click_dir = vector.subtract(above, under)
        
        -- Pega a direção horizontal do jogador
        local yaw = placer:get_look_horizontal()
        local player_dir = core.yaw_to_dir(yaw)
        local player_facedir = core.dir_to_facedir(player_dir)
        
        local facedir
        
        if click_dir.y == 1 then
            -- Clicado no topo (chão) - tábua em pe com a lateral fina pra mim
            facedir = player_facedir
        elseif click_dir.y == -1 then
            -- Clicado embaixo (teto) - tábua deitada invertida
            facedir = player_facedir + 20
        elseif click_dir.z ~= 0 then
            -- Parede Norte/Sul (eixo Z)
            local wall_facedir = core.dir_to_facedir(click_dir)
            facedir = wall_facedir + 4
        else
            -- Parede Leste/Oeste (eixo X)
            local wall_facedir = core.dir_to_facedir(click_dir)
            facedir = wall_facedir + 12  -- Valor diferente para paredes X
        end
        
        return core.item_place(itemstack, placer, pointed_thing, facedir)
    end,
})

-- Tarugo
core.register_node("nh_nodes:oakdowel", {
    description = "Tarugo de Carvalho\nAlcance: +2",
    drawtype = "mesh",
    mesh = "oakdowel.obj",
    tiles = {"oakwood.png"},
    groups = {choppy = 3},
    
    range = 5,
    
    paramtype = "light",
    paramtype2 = "wallmounted",
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.1, -0.5, -0.1, 0.1, 0.5, 0.1},
        wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.5, 0.1},
        wall_side = {-0.5, -0.1, -0.1, 0.5, 0.1, 0.1},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
        wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
        wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},
    },
})

core.register_node("nh_nodes:torch", {
    description = "Tocha",
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = {"torch.png"},
    --inventory_image = "tocha_inventario.png",
    --wield_image = "tocha_inventario.png",
    
    paramtype = "light",
    --paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    
    groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 1}, -- dig_immediate = 3, attached_node = 1
    
    collision_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}
    },
    
    --selection_box = {
    --    type = "wallmounted",
    --    wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
    --    wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
   --     wall_side = {-0.5, -0.1, -0.1, -0.5+0.3, 0.5, 0.1},
    --},
    
    --node_box = {
    --    type = "wallmounted",
    --    wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
    --    wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
    --    wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},
    --},
    
    -- Quando bater na tocha apagada com tocha acesa ou flame
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then
            return
        end
        
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        
        -- Verifica se está batendo com tocha acesa ou flame
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Pega a orientação (facedir/wallmounted) da tocha apagada
            local param2 = node.param2
            
            -- Troca para tocha acesa mantendo a orientação
            core.set_node(pos, {name = "nh_nodes:torch2", param2 = param2})
            
            -- Adiciona a chama como entidade (mesmo código do after_place_node)
            local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
            local obj = core.add_entity(flame_pos, "nh_nodes:torch_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then
                    ent._torch_pos = pos
                end
            end
            
            -- Efeito sonoro de acender fogo
            core.sound_play("fire_flint_and_steel", {
                pos = pos,
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
            
            -- Partículas de faísca (opcional)
            core.add_particlespawner({
                amount = 5,
                time = 0.1,
                minpos = vector.subtract(pos, {x=0.1, y=0.1, z=0.1}),
                maxpos = vector.add(pos, {x=0.1, y=0.3, z=0.1}),
                minvel = {x=-0.5, y=0.5, z=-0.5},
                maxvel = {x=0.5, y=1.5, z=0.5},
                minacc = {x=0, y=-2, z=0},
                maxacc = {x=0, y=-1, z=0},
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

core.register_node("nh_nodes:torch2", {
    description = "Tocha acesa",
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = {
    "torchfire.png",  -- Textura da madeira/base
	},
    --inventory_image = "tocha_inventario.png",
    --wield_image = "tocha_inventario.png",
    
    paramtype = "light",
    --paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    stack_max = 1,  -- limita a 1 tocha acesa por slot
    
    light_source = 13,  -- Luminosidade (0-14, onde 14 é máximo)
    
    groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 1},   -- REMOVIDO: attached_node = 1, dig_immediate = 3
    
    collision_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}
    },
    
    --selection_box = {
    --    type = "wallmounted",
    --    wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
    --    wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
   --     wall_side = {-0.5, -0.1, -0.1, -0.5+0.3, 0.5, 0.1},
    --},
    
    --node_box = {
    --    type = "wallmounted",
    --    wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
    --    wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
    --    wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},
    --},
    
    -- Quando colocada, adiciona a chama no mesmo lugar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        -- Posição da chama (1 bloco acima)
        local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        
        -- Cria a ENTIDADE da chama
        local obj = core.add_entity(flame_pos, "nh_nodes:torch_flame_entity")
        if obj then
            local ent = obj:get_luaentity()
            if ent then
                ent._torch_pos = pos
            end
        end
    end,
    
    -- Quando a tocha é destruída, remove a entidade da chama
    after_destruct = function(pos)
        local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        local objs = core.get_objects_inside_radius(flame_pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:torch_flame_entity" then
                obj:remove()
            end
        end
    end,
})
-- Node invisível que emite luz
core.register_node("nh_nodes:torch_light", {
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    buildable_to = true,
    light_source = 13,
    groups = {not_in_creative_inventory = 1},
})

core.register_node("nh_nodes:torch_flame", {
    drawtype = "mesh",
    mesh = "torchflame.obj",  -- Você precisará criar esse mesh
    tiles = {
        {
            name = "fire_basic_flame_animated.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1.0,
            },
        }
    },
    stack_max = 1,  -- limita a 1 tocha acesa por slot
    paramtype = "light",
    paramtype2 = "facedir",  -- ADICIONEI: necessário para meshes com transparência
    sunlight_propagates = true,
    use_texture_alpha = "blend",  -- ADICIONEI: ativa a transparência
    walkable = false,
    pointable = true,
    diggable = false,
    buildable_to = false,
    damage_per_second = 4,
    groups = {not_in_creative_inventory = 1},
    drop = "",
    
    --visual_scale = 1,

})


---------------------------
-- ENTIDADE DA CHAMA DA TOCHA
---------------------------
core.register_entity("nh_nodes:torch_flame_entity", {
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
            local data = core.deserialize(staticdata)
            if data and data.torch_pos then
                self._torch_pos = data.torch_pos
            end
        end
        self._timer = 0
        
        -- Configura a animação da textura
        self.object:set_sprite(
            {x = 0, y = 0},
            1,
            1.0,
            false
        )
        
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    
    get_staticdata = function(self)
        return core.serialize({torch_pos = self._torch_pos})
    end,
    
    -- Detecta quando é golpeado com tocha apagada
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then
            return
        end
        
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
                    core.add_item(pos, leftover)
                end
            end
            
            -- Efeito sonoro
            core.sound_play("fire_flint_and_steel", {
                pos = self.object:get_pos(),
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
            
            -- Partículas de faísca
            core.add_particlespawner({
                amount = 5,
                time = 0.1,
                minpos = vector.subtract(self.object:get_pos(), {x=0.1, y=0.1, z=0.1}),
                maxpos = vector.add(self.object:get_pos(), {x=0.1, y=0.1, z=0.1}),
                minvel = {x=-0.5, y=0.5, z=-0.5},
                maxvel = {x=0.5, y=1.5, z=0.5},
                minacc = {x=0, y=-2, z=0},
                maxacc = {x=0, y=-1, z=0},
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
            
            if not self._torch_pos then
                self.object:remove()
                return
            end
            
            local node = core.get_node(self._torch_pos)
            
            -- Se a tocha foi removida ou apagada, remove a chama
            if node.name ~= "nh_nodes:torch2" then
                self.object:remove()
                return
            end
        end
    end,
})

core.register_node("nh_nodes:flame", {
    drawtype = "mesh",
    mesh = "flame.obj",  -- Você precisará criar esse mesh
    tiles = {
        {
            name = "fire_basic_flame_animated.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1.0,
            },
        }
    },
    paramtype = "light",
    paramtype2 = "facedir",  -- ADICIONEI: necessário para meshes com transparência
    sunlight_propagates = true,
    use_texture_alpha = "blend",  -- ADICIONEI: ativa a transparência
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    damage_per_second = 4,
    groups = {not_in_creative_inventory = 1},
    drop = "",
    
    --visual_scale = 1,

})

core.register_node("nh_nodes:torch3", {
    description = "Tocha",
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = {"torch3.png"},
    --inventory_image = "tocha_inventario.png",
    --wield_image = "tocha_inventario.png",
    
    --paramtype = "light",
    --paramtype2 = "wallmounted",
    --sunlight_propagates = true,
    walkable = false,
    
    groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 1}, -- dig_immediate = 3, attached_node = 1
    
    collision_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, 0.37, 0.1}
    },
    
    --selection_box = {
    --    type = "wallmounted",
    --    wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
    --    wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
   --     wall_side = {-0.5, -0.1, -0.1, -0.5+0.3, 0.5, 0.1},
    --},
    
    --node_box = {
    --    type = "wallmounted",
    --    wall_top = {-0.0625, 0.5-0.5625, -0.0625, 0.0625, 0.5, 0.0625},
    --    wall_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.5+0.5625, 0.0625},
    --    wall_side = {-0.5, -0.0625, -0.0625, -0.5+0.28125, 0.5, 0.0625},
    --},
})

-- Folhas de carvalho
core.register_node("nh_nodes:leaves", {
    description = "Folhas",
    drawtype = "liquid",
    waving = 1,
    tiles = {"oakleaves3.png"}, --tiles = {"folhas.png"},
    groups = {snappy = 3, tree_leaves = 1},
    drop =  {
        items = {
            {items = {"nh_nodes:stick"}},
            {items = {"nh_nodes:oakresin"}},
        }
    },
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves",
    liquid_alternative_source = "nh_nodes:leaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},

})

-- Folhas de carvalho
core.register_node("nh_nodes:pineleaves", {
    description = "Folhas de pinheiro",
    drawtype = "mesh",
    mesh = "pineleaves.obj", 
    tiles = {"pineleaves.png"},
    waving = 1,
    groups = {snappy = 3, tree_leaves = 1},
    drop =  {
        items = {
            {items = {"nh_nodes:stick"}},
            {items = {"nh_nodes:oakresin"}},
        }
    },
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:pineleaves",
    liquid_alternative_source = "nh_nodes:pineleaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},

})

-- Folhas de macieira
core.register_node("nh_nodes:appleleaves", {
    description = "Folhas de Macieira",
    drawtype = "mesh",
    mesh = "appleleaves.obj", 
    tiles = {"appleleaves.png"},
    waving = 1,
    groups = {snappy = 3, tree_leaves = 1},
    drop =  {
        items = {
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:appleleaves",
    liquid_alternative_source = "nh_nodes:appleleaves",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
})

-- Folhas com 1 maça
core.register_node("nh_nodes:leaves_apple", {
    description = "Folhas com Maçã",
    drawtype = "mesh",
    drawtype = "mesh",
    mesh = "leavesapple1.obj",
    tiles = {"appleleaves.png"},
    waving = 1,
    groups = {snappy = 3, tree_leaves = 1},
    drop = {
        items = {
            {items = {"nh_nodes:apple"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_apple",
    liquid_alternative_source = "nh_nodes:leaves_apple",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:apple")
            end
            
            -- Transforma o node em leaves_apple2
            core.set_node(pos, {name = "nh_nodes:appleleaves"})
        end
        return itemstack
    end,
})

-- Folhas com 2 maças
core.register_node("nh_nodes:leaves_apple2", {
    description = "Folhas com 2 maçãs",
    drawtype = "mesh",
    mesh = "leavesapple2.obj",
    tiles = {"appleleaves.png"},
    waving = 1,
    groups = {snappy = 3, tree_leaves = 1},
    drop = {
        items = {
            {items = {"nh_nodes:apple 2"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_apple2",
    liquid_alternative_source = "nh_nodes:leaves_apple2",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
        -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:apple")
            end
            
            -- Transforma o node em leaves_apple2
            core.set_node(pos, {name = "nh_nodes:leaves_apple"})
        end
        return itemstack
    end,
})

-- Folhas com 3 maças
core.register_node("nh_nodes:leaves_apple3", {
    description = "Folhas com 3 maçãs",
    drawtype = "mesh",
    mesh = "leavesapple3.obj",
    tiles = {"appleleaves.png"},
    waving = 1,
    groups = {snappy = 3, tree_leaves = 1},
    drop = {
        items = {
            {items = {"nh_nodes:apple 3"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = "clip",
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_apple3",
    liquid_alternative_source = "nh_nodes:leaves_apple3",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.7}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 1, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:apple")
            end
            
            -- Transforma o node em leaves_apple2
            core.set_node(pos, {name = "nh_nodes:leaves_apple2"})
        end
        return itemstack
    end,
})

-- Folhas mirtilo
core.register_node("nh_nodes:blueberryleaves", {
    description = "Folhas de Mirtilo",
    drawtype = "liquid",
    waving = 1,
    tiles = {"folhasmirtilo.png"},
    groups = {snappy = 3},
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
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
})

-- Folhas com 4 blueberry
core.register_node("nh_nodes:leaves_blueberry4", {
    description = "Folhas com 4 mirtilos",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"folhasmirtilo4.png"},
    groups = {snappy = 3},
    drop = {
        items = {
            {items = {"nh_nodes:blueberry 4"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_blueberry4",
    liquid_alternative_source = "nh_nodes:leaves_blueberry4",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
        -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:blueberry 4")
            end
            
            -- Transforma o node em leaves_apple2
            core.set_node(pos, {name = "nh_nodes:blueberryleaves"})
        end
        return itemstack
    end,
})

core.register_node("nh_nodes:nut", {
    description = "Noz\n(Bolota)\nNutrição: +1",
    drawtype = "mesh",
    mesh = "noz.obj",
    tiles = {"noz.png"},
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.30, 0.08}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.30, 0.08}
    },
    
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 1)  -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

-- Folhas com 1 noz
core.register_node("nh_nodes:leaves_nut", {
    description = "Folhas com noz",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"folhasnoz.png"},
    groups = {snappy = 3, tree_leaves = 1},
    drop = {
        items = {
            {items = {"nh_nodes:nut"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_nut",
    liquid_alternative_source = "nh_nodes:leaves_nut",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
    -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:nut")
            end
            
            -- Transforma o node em leaves_apple2
            core.set_node(pos, {name = "nh_nodes:leaves"})
        end
        return itemstack
    end,
})

-- Folhas com 2 nozes
core.register_node("nh_nodes:leaves_nut2", {
    description = "Folhas com 2 nozes",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"folhasnoz2.png"},
    groups = {snappy = 3, tree_leaves = 1},
    drop = {
        items = {
            {items = {"nh_nodes:nut 2"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_nut2",
    liquid_alternative_source = "nh_nodes:leaves_nut2",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
        -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:nut")
            end
            
            -- Transforma o node em leaves_apple2
            core.set_node(pos, {name = "nh_nodes:leaves_nut"})
        end
        return itemstack
    end,
})

-- Folhas com 3 nozes
core.register_node("nh_nodes:leaves_nut3", {
    description = "Folhas com 3 nozes",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"folhasnoz3.png"},
    groups = {snappy = 3, tree_leaves = 1},
    drop = {
        items = {
            {items = {"nh_nodes:nut 3"}},
            {items = {"nh_nodes:stick"}},
        }
    },
    walkable = false,
    use_texture_alpha = 30,
    paramtype = "light",
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:leaves_nut3",
    liquid_alternative_source = "nh_nodes:leaves_nut3",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 0,
    post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    
        -- Callback ao clicar com botão direito (pegar maçã)
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            -- Adiciona a maçã ao inventário do jogador
            local inv = clicker:get_inventory()
            if inv then
                inv:add_item("main", "nh_nodes:nut")
            end
            
            -- Transforma o node em leaves_nut2
            core.set_node(pos, {name = "nh_nodes:leaves_nut2"})
        end
        return itemstack
    end,
})


-- Sistema alternativo de dano (caso on_fall_damage não funcione)
-- Verifica folhas caindo e causa dano aos jogadores
local players_with_torch = {}

core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        
        -- ==== SISTEMA DE DANO DAS FOLHAS ====
        local above_pos = {x = pos.x, y = pos.y + 2, z = pos.z}
        local objects = core.get_objects_inside_radius(above_pos, 1.5)
        for _, obj in pairs(objects) do
            local entity = obj:get_luaentity()
            if entity and entity.name == "__builtin:falling_node" then
                local node = entity.node
                if node and node.name then
                    -- Lista de todos os tipos de folhas que podem cair
                    local leaf_types = {
                        "nh_nodes:leaves",
                        "nh_nodes:leaves_nut",
                        "nh_nodes:leaves_nut2",
                        "nh_nodes:leaves_nut3",
                        "nh_nodes:leaves_apple",
                        "nh_nodes:leaves_apple2",
                        "nh_nodes:leaves_apple3"
                    }
                    
                    -- Verifica se o node é algum tipo de folha
                    local is_leaf = false
                    for _, leaf_name in ipairs(leaf_types) do
                        if node.name == leaf_name then
                            is_leaf = true
                            break
                        end
                    end
                    
                    if is_leaf then
                        local velocity = obj:get_velocity()
                        if velocity and velocity.y < -2 then
                            player:set_hp(player:get_hp() - 1)
                        end
                    end
                end
            end
        end
        
        -- Registrar o globalstep para verificar se o player está na água
	core.register_globalstep(function(dtime)
	    for _, player in ipairs(core.get_connected_players()) do
		local pos = player:get_pos()
		pos.y = pos.y + 1  -- Verifica na altura da cabeça
		
		local node = core.get_node(pos)
		
		-- Verifica se está na água
		if core.get_item_group(node.name, "water") > 0 then
		    local inv = player:get_inventory()
		    
		    -- Percorre todo o inventário
		    for i = 1, inv:get_size("main") do
		        local stack = inv:get_stack("main", i)
		        
		        -- Se encontrar tocha2, troca por tocha3
		        if stack:get_name() == "nh_nodes:torch2" then
		            stack:set_name("nh_nodes:torch3")
		            inv:set_stack("main", i, stack)
		        end
		    end
		end
	    end
	end)
        
        -- ==== SISTEMA DE LUZ DA TOCHA ====
        local wielded = player:get_wielded_item()
        local player_name = player:get_player_name()
        local light_pos_base = {x = pos.x, y = pos.y + 1, z = pos.z}
        
        if wielded:get_name() == "nh_nodes:torch2" then
            -- Cria luz temporária
            if not players_with_torch[player_name] then
                players_with_torch[player_name] = {}
            end
            
            -- Remove luz antiga
            if players_with_torch[player_name].pos then
                local old_pos = players_with_torch[player_name].pos
                local node = core.get_node(old_pos)
                if node.name == "nh_nodes:torch_light" then
                    core.remove_node(old_pos)
                end
            end
            
            -- Coloca nova luz invisível
            local light_pos = vector.round(light_pos_base)
            local node = core.get_node(light_pos)
            if node.name == "air" then
                core.set_node(light_pos, {name = "nh_nodes:torch_light"})
                players_with_torch[player_name].pos = light_pos
            end
        else
            -- Remove luz se não está mais segurando
            if players_with_torch[player_name] and players_with_torch[player_name].pos then
                local old_pos = players_with_torch[player_name].pos
                local node = core.get_node(old_pos)
                if node.name == "nh_nodes:torch_light" then
                    core.remove_node(old_pos)
                end
                players_with_torch[player_name] = nil
            end
        end
    end
end)

-- Limpa luz quando jogador sai
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    if players_with_torch[player_name] and players_with_torch[player_name].pos then
        local pos = players_with_torch[player_name].pos
        local node = core.get_node(pos)
        if node.name == "nh_nodes:torch_light" then
            core.remove_node(pos)
        end
        players_with_torch[player_name] = nil
    end
end)

-- Limpa luz quando jogador sai
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    if players_with_torch[player_name] and players_with_torch[player_name].pos then
        local pos = players_with_torch[player_name].pos
        local node = core.get_node(pos)
        if node.name == "nh_nodes:torch_light" then
            core.remove_node(pos)
        end
        players_with_torch[player_name] = nil
    end
end)


core.register_node("nh_nodes:apple", {
    description = "Maçã\nNutrição: +2",
    drawtype = "mesh",
    mesh = "apple.obj",
    tiles = {"AppleTexture.png"},
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, armor_head = 1, falling_node = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}
    },
    
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 2)  -- Restaura 4 pontos
        itemstack:take_item()
        return itemstack
    end,
})

core.register_node("nh_nodes:blueberry", {
    description = "Mirtilo\nNutrição: +1",
    --wield_scale = {x = 10, y = 10, z = 10},
    drawtype = "mesh",
    mesh = "blueberry.obj",
    tiles = {"BlueberryTexture.png"},
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.03, -0.5, -0.03, 0.03, -0.44, 0.03}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.03, -0.5, -0.03, 0.03, -0.44, 0.03}
    },
    
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 1)  -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

core.register_node("nh_nodes:chicken_egg", {
    description = "Ovo de Galinha\nNutrição: +1",
    drawtype = "mesh",
    mesh = "chickenegg.obj",
    tiles = {"chickenegg.png"},
    
    paramtype = "light",
    walkable = false,
    groups = {oddly_breakable_by_hand = 1, falling_node = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.25, 0.25, 0.1, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.28, 0.08}
    },
    --visual_size = {x = 15, y = 15},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 1)  -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

core.register_node("nh_nodes:friedchickenegg", {
    description = "Ovo Frito\n(Ovo de Galinha)\nNutrição: +4",
    drawtype = "mesh",
    mesh = "friedegg.obj",
    tiles = {"friedegg.png"},
    
    paramtype = "light",
    walkable = false,
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.25, 0.25, 0.1, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.08, -0.5, -0.08, 0.08, -0.28, 0.08}
    },
    --visual_size = {x = 15, y = 15},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 4)  -- Restaura 1 ponto
        itemstack:take_item()
        return itemstack
    end,
})

core.register_node("nh_nodes:worm", {
    description = "Minhoca\n[Mob e Item]",
    drawtype = "mesh",
    mesh = "worm_node.obj",
    tiles = {"worm.png"},
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, -0.4, 0.1}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.1, -0.5, -0.1, 0.1, -0.4, 0.1}
    },
    visual_size = {x = 15, y = 15},

    -- Spawna o mob ao colocar o node no chão
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local pos = pointed_thing.above  -- posição onde vai spawnar
        
        -- Spawna o mob
        local mob = minetest.add_entity(pos, "nh_mob:worm")
        
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

core.register_node("nh_nodes:chicken", {
    description = "Galinha",
    drawtype = "mesh",
    mesh = "chicken_node.obj",
    tiles = {"chicken.png"},
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.25, 0.25, 0, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
    },
    visual_size = {x = 15, y = 15},

})

core.register_node("nh_nodes:raw_chicken", {
    description = "Frango Cru\nNutrição: +4",
    drawtype = "mesh",
    mesh = "raw_chicken.obj",
    tiles = {"raw_chicken.png"},
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.25, 0.25, 0, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
    },
    --visual_size = {x = 15, y = 15},
    --wield_scale = {x= 2, y= 2, z= 2},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 4)
        itemstack:take_item()
    
        local bone = ItemStack("nh_nodes:bone 2")
    
        if itemstack:is_empty() then
            return bone
        else
            add_item_to_visible_slots(user, bone)
            return itemstack
        end
    end,
})

core.register_node("nh_nodes:roastchicken", {
    description = "Frango Assado\nNutrição: +6",
    drawtype = "mesh",
    mesh = "raw_chicken.obj",
    tiles = {"roastchicken.png"},
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.25, 0.25, 0, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
    },
    visual_size = {x = 15, y = 15},
    -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 6)
        itemstack:take_item()
    
        local bone = ItemStack("nh_nodes:bone 2")
    
        if itemstack:is_empty() then
            return bone
        else
            add_item_to_visible_slots(user, bone)
            return itemstack
        end
    end,
})

core.register_node("nh_nodes:bull", {
    description = "Touro",
 
    drawtype = "mesh",
    mesh = "bull2.obj",
    tiles = {"bull.png"},
    
    paramtype = "light",

    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, armor_head = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.7, -0.7, -0.7, 0.7, -0.7, 0.7}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.7, -0.7, -0.7, 0.7, -0.7, 0.7}
    },
    
})

core.register_node("nh_nodes:cowmeat", {
    description = "Carne Bovina Crua\nNutrição: +3",
 
    drawtype = "mesh",
    mesh = "cowmeat.obj",
    tiles = {"cowmeat.png"},
    
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}
    },
    
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 3)  -- Restaura 3 pontos
        itemstack:take_item()
        return itemstack
    end,
})

core.register_node("nh_nodes:roastbeef", {
    description = "Carne Bovina Assada\nNutrição: +6",
 
    drawtype = "mesh",
    mesh = "cowmeat.obj",
    tiles = {"roastbeef.png"},
    
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}
    },
    
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 6)  -- Restaura 6 pontos
        itemstack:take_item()
        return itemstack
    end,
})


core.register_node("nh_nodes:cowfur", {
    description = "Pele de Touro",
 
    drawtype = "mesh",
    mesh = "cowleather.obj",
    tiles = {"cowleather.png"},
    
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, armor_head = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
})

core.register_node("nh_nodes:inksac", {
    description = "Bolsa de Tinta\nPorção: 1",
 
    drawtype = "mesh",
    mesh = "inksac.obj",
    tiles = {"inksac.png"},
    
    paramtype = "light",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.25, 0.15, -0.375, 0.25}
    },
})

core.register_node("nh_nodes:bottle", {
    description = "Frasco",
    inventory_image = "bottle.png",
    drawtype = "mesh",
    mesh = "emptybottle.obj",
    tiles = {"bottletexture.png"},
    
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
})

local function is_water_near(pos)
    local offsets = {
        {x=0,y=0,z=0},
        {x=1,y=0,z=0}, {x=-1,y=0,z=0},
        {x=0,y=1,z=0}, {x=0,y=-1,z=0},
        {x=0,y=0,z=1}, {x=0,y=0,z=-1},
    }

    for _, off in ipairs(offsets) do
        local p = vector.add(pos, off)
        local node = core.get_node(p)

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

core.register_node("nh_nodes:messagebottle", {
    description = "Frasco com Mensagem\n[Item de Spawn]",
    inventory_image = "bottlepage.png",
    drawtype = "mesh",
    mesh = "bottlepage.obj",
    tiles = {"bottlepagetexture.png"},
    
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
    
    pointabilities = {
        nodes = {
            ["nh_nodes:water"]         = true,
            ["nh_nodes:water_flowing"] = true,
            ["nh_nodes:water2"]        = true,
            ["nh_nodes:water2_flowing"] = true,
        }
    },
 
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
        core.remove_node(pos)
        core.add_entity(pos, "nh_mob:messagebottle")
    end
end,  
    
-- Cobre o caso de água chegar até o nó depois que ele já está parado
on_flood = function(pos, oldnode, newnode)
    core.remove_node(pos)
    core.add_entity(pos, "nh_mob:messagebottle")
    return false
end,
})

core.register_node("nh_nodes:fireflybottle", {
    description = "Frasco com Vaga-lume",
    inventory_image = "bottlefirefly.png",
    drawtype = "mesh",
    mesh = "bottlefirefly.obj",
    tiles = {"bottlefireflytexture.png"},
    
    paramtype = "light",
    light_source = 5,
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    backface_culling = false,
    walkable = false,
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
    
            -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.6, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    offhand_bone_position = {
        pos = {x = 1.6, y = 0, z = 0}
        --rot = {x = 0, y = 0, z = -110}
    },
})

core.register_node("nh_nodes:inkbottle", {
    description = "Frasco com Tinta",
    inventory_image = "inkbottle.png",
    drawtype = "mesh",
    mesh = "bottle.obj",
    tiles = {"inkbottletexture.png"},
    
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    walkable = false,
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18}
    },
})


-- Função auxiliar para verificar se o jogador tem os itens necessários
writing_utils = {}
function writing_utils.player_has_writing_tools(player)
    local inv = player:get_inventory()
    local has_feather = false
    local has_ink = false
    
    for i = 1, 8 do
        local stack = inv:get_stack("main", i)
        if stack:get_name() == "nh_items:feather" then
            has_feather = true
            break
        end
    end
    
    if inv:contains_item("main", "nh_nodes:inkbottle") then
        has_ink = true
    end
    
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
    
    -- Verificar se tem pena na hotbar (slots 1-8)
    for i = 1, 8 do
        local stack = inv:get_stack("main", i)
        if stack:get_name() == "nh_items:feather" then
            has_feather = true
            break
        end
    end
    
    -- Verificar se tem tinta em qualquer lugar do inventário
    if inv:contains_item("main", "nh_nodes:inkbottle") then
        has_ink = true
    end
    
    return has_feather, has_ink
end

function consume_ink(player)
    local inv = player:get_inventory()
    -- Remover um frasco de tinta e devolver frasco vazio
    inv:remove_item("main", "nh_nodes:inkbottle")
    inv:add_item("main", "nh_nodes:bottle")
end



core.register_node("nh_nodes:coconutlinked", {
    description = "Coco Ligado",
    drawtype = "mesh",
    mesh = "coconutlinked.obj",
    tiles = {"CocoTexture.png"},
    
    drop = "nh_nodes:coconut",
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, tree_leaves = 1, oddly_breakable_by_hand = 1, falling_node = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.5, 0.25, 0.5, 0}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.25, 0, -0.5, 0.25, 0.5, 0}
    },
})


core.register_node("nh_nodes:coconut", {
    description = "Coco\nNutrição: +3",
    drawtype = "mesh",
    mesh = "coconut.obj",
    tiles = {"CocoTexture.png"},
    
    walkable = false,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy = 3, tree_leaves = 1, oddly_breakable_by_hand = 1, falling_node = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0, 0.25}
    },

    pointabilities = {
        nodes = {
            ["nh_nodes:water"]         = true,
            ["nh_nodes:water_flowing"] = true,
            ["nh_nodes:water2"]        = true,
            ["nh_nodes:water2_flowing"] = true,
        }
    },
 
     -- Tornar comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, 3)  -- Restaura 3 pontos
        itemstack:take_item()
        return itemstack
    end,
 
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
        core.remove_node(pos)
        core.add_entity(pos, "nh_mob:coconut")
    end
end,  
    
-- Cobre o caso de água chegar até o nó depois que ele já está parado
on_flood = function(pos, oldnode, newnode)
    core.remove_node(pos)
    core.add_entity(pos, "nh_mob:coconut")
    return false
end,
})

core.register_node("nh_nodes:palmtimber", {
    description = "Tronco de coqueiro",
    drawtype = "mesh",
    mesh = "palm_trunk.obj",
    tiles = {"coqueirotexture.png"},
    stack_max = 4, 
    drop = "nh_nodes:palmlog",
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {
        snappy = 3,
        oddly_breakable_by_hand = 1,
        falling_node = 1,
        tree_trunk = 1
    },

    collision_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}
    },
    
    -- Som tocado ao bater no tronco medio (2)
    sounds = {
        dug = {name = "punchtimber2", gain = 0.5},
        dig  = {name = "punchtimber2", gain = 0.5},
    },
    
after_dig_node = function(pos)
    local below = {x = pos.x, y = pos.y - 1, z = pos.z}
    local below_node = core.get_node(below)

    if below_node.name == "air"
       or core.get_item_group(below_node.name, "tree_trunk") > 0
       or core.get_item_group(below_node.name, "tree_leaves") > 0 then
        make_leaves_fall(pos)
    end
end,

on_construct = function(pos)
    core.get_node_timer(pos):start(0.5)
end,

on_timer = function(pos)
    if not has_solid_support(pos) then
        make_leaves_fall(pos)
        return false
    end
    return true
end,
})


core.register_node("nh_nodes:palmstraws", {
    description = "Tronco de Coqueiro com Palheiro",
    drawtype = "mesh",
    mesh = "coconutstraws.obj",
    tiles = {"strawstimbertexture.png"},
    stack_max = 4, 
    
    drop = {
        items = {
            {items = {"nh_nodes:palmtimber"}},
            {items = {"nh_nodes:palmstraw 4"}},
        }
    },
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {
        choppy = 3,
        falling_node = 1,
        tree_trunk = 1
    },
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}  -- Porta na lateral quando aberta
    },
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}  -- Colisão fina na lateral
    },
    
    -- Som tocado ao bater no tronco medio (2)
    sounds = {
        dug = {name = "punchtimber2", gain = 0.5},
        dig  = {name = "punchtimber2", gain = 0.5},
    },
})

core.register_node("nh_nodes:palmlog", {
    description = "Tora de coqueiro",
    drawtype = "mesh",
    mesh = "palm_trunk.obj",
    tiles = {"coqueirotexture.png"},
    stack_max = 4, 
    
    paramtype = "light",
    paramtype2 = "wallmounted",
    groups = {
        snappy = 3,
        oddly_breakable_by_hand = 1,
        --falling_node = 1,
        --tree_trunk = 1
    },
    
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25},
    },
    
    node_box = {
        type = "wallmounted",
        wall_top = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
        wall_side = {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25},
    },
    
    -- Som tocado ao bater no tronco medio (2)
    sounds = {
        dug = {name = "punchtimber2", gain = 0.5},
        dig  = {name = "punchtimber2", gain = 0.5},
    },
})

core.register_node("nh_nodes:palmleafstalks", {
    description = "Folha central de coqueiro",

    drawtype = "mesh",
    mesh = "TaloCoqueiro.obj",
    tiles = {"PalmLeafTexture.png"},
    
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    shaded = false,  -- Desabilita sombreamento por face
    backface_culling = false,  -- Renderiza ambos os lados das faces
    use_texture_alpha = "blend",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, tree_leaves = 1, armor_head = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
})

-- Registrar o node da folha de coqueiro
core.register_node("nh_nodes:palmleaf", {
    description = "Folha de coqueiro",
 
    drawtype = "mesh",
    mesh = "palm_leaf.obj",
    tiles = {"PalmLeafTexture.png"},
    
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    shaded = false,
    backface_culling = false,
    use_texture_alpha = "blend",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, tree_leaves = 1, armor_head = 1},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
    
    -- Quando o node é colocado, iniciar o timer
    on_place = function(itemstack, placer, pointed_thing)
        -- Primeiro, fazer o placement normal
        local pos = core.item_place(itemstack, placer, pointed_thing)
        
        -- Se o placement foi bem-sucedido, iniciar o timer
        if pos then
            local timer = core.get_node_timer(pointed_thing.above)
            timer:start(60) -- 60 segundos = 1 minuto
        end
        
        return itemstack
    end,
    
    -- Quando o timer terminar
    on_timer = function(pos)
        -- Verificar se está sob luz do sol
        local light_level = core.get_node_light(pos, 0.5)
        
        if light_level and light_level >= 12 then -- 12+ é luz solar direta
            -- Trocar para o node de palha
            core.set_node(pos, {name = "nh_nodes:palmstraw"})
            return false -- Não reiniciar o timer
        else
            -- Se não estiver no sol, reiniciar o timer
            return true
        end
    end,
})

---------------------------
-- NODE DE PALHA COM CHAMAS
---------------------------
core.register_node("nh_nodes:palmstraw", {
    description = "Palha de coqueiro",
    
    drawtype = "mesh",
    mesh = "palmstraw.obj",
    tiles = {"PalmStrawTexture.png"},
    
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    shaded = false,
    backface_culling = false,
    use_texture_alpha = "blend",
    paramtype2 = "facedir",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, tree_leaves = 1, flammable = 3},
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
    },
    
    -- Quando a palha é colocada, verifica se deve criar chama
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        -- Se já tiver chama marcada, cria a entidade
        if meta:get_int("has_flame") == 1 then
            core.after(0.1, function()
                -- Verifica se não existe chama já
                local objs = core.get_objects_inside_radius(pos, 0.5)
                local has_flame = false
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:palmstraw_flame_entity" then
                        has_flame = true
                        break
                    end
                end
                
                if not has_flame then
                    local obj = core.add_entity(pos, "nh_nodes:palmstraw_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then
                            ent._straw_pos = pos
                        end
                    end
                end
            end)
        end
    end,
    
    -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then
            return
        end
        
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = core.get_meta(pos)
        
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then
            return
        end
        
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            
            -- Cria a entidade da chama
            local obj = core.add_entity(pos, "nh_nodes:palmstraw_flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then
                    ent._straw_pos = pos
                end
            end
            
            -- Efeito sonoro (opcional)
            core.sound_play("fire_flint_and_steel", {
                pos = pos,
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
        end
    end,
    
    -- Quando a palha for removida, remove as chamas
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = core.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:palmstraw_flame_entity" then
                obj:remove()
            end
        end
    end,
})

---------------------------
-- ENTIDADE DA CHAMA DA PALHA
---------------------------
core.register_entity("nh_nodes:palmstraw_flame_entity", {
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
            local data = core.deserialize(staticdata)
            if data and data.straw_pos then
                self._straw_pos = data.straw_pos
            end
        end
        self._timer = 0
        
        self.object:set_sprite(
            {x = 0, y = 0},
            1,
            1.0,
            false
        )
        
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    
    get_staticdata = function(self)
        return core.serialize({straw_pos = self._straw_pos})
    end,
    
    -- Detecta quando é golpeado para acender tochas
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then
            return
        end
        
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
                    core.add_item(pos, leftover)
                end
            end
            
            core.sound_play("fire_flint_and_steel", {
                pos = self.object:get_pos(),
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
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
            
            if not self._straw_pos then
                self.object:remove()
                return
            end
            
            local node = core.get_node(self._straw_pos)
            
            -- Se a palha foi removida, remove a chama
            if node.name ~= "nh_nodes:palmstraw" then
                self.object:remove()
                return
            end
            
            -- Verifica se ainda deve ter chama
            local meta = core.get_meta(self._straw_pos)
            if meta:get_int("has_flame") ~= 1 then
                self.object:remove()
                return
            end
        end
    end,
})


core.register_node("nh_nodes:snow", {
    description = "Neve",
    tiles = {"neve.png"},
    drawtype = "normal",
    groups = {crumbly = 3, falling_node = 1}, -- como areia, mas sem fluir
    --sounds = default.node_sound_snow_defaults(),
})

core.register_node("nh_nodes:snow_flowing", {
    description = "Avalanche",
    drawtype = "flowingliquid",
    tiles = {"neve.png"},
    special_tiles = {
        {
            name = "neve_flowing_animated.png",
            backface_culling = false,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
        },
        {
            name = "neve_flowing_animated.png",
            backface_culling = true,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
        },
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "none",  -- ❗ Para NÃO deixar fluir automaticamente
    groups = {not_in_creative_inventory=1},
})

core.register_node("nh_nodes:water", {
    description = "Água",
    drawtype = "liquid",
    tiles = {"agua.png"},
    tiles = {
    {name = "agua_animated.png", backface_culling = false, 
    animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=10.0}},
    "agua.png"}, -- resto das faces
 
liquid_renewable = false,
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:water_flowing",
    liquid_alternative_source = "nh_nodes:water",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=0, g=0, b=255},
    drowning = 1,  -- ADICIONE ESTA LINHA (dano por segundo quando sem ar)
    groups = {water=1, liquid=1},
    
    after_place_node = function(pos)
    local neighbors = {
        {x=1,y=0,z=0},{x=-1,y=0,z=0},
        {x=0,y=1,z=0},{x=0,y=-1,z=0},
        {x=0,y=0,z=1},{x=0,y=0,z=-1},
    }
    for _, d in ipairs(neighbors) do
        local npos = vector.add(pos, d)
        local node = core.get_node(npos)
        -- força remesh do vizinho
        core.swap_node(npos, node)
    end
end,
})

core.register_node("nh_nodes:water_flowing", {
    description = "Água Corrente",
    drawtype = "flowingliquid",
    tiles = {"agua.png"},
    special_tiles = {
        {
            name = "agua_flowing_animated.png",
            backface_culling = false,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
        },
        {
            name = "agua_flowing_animated.png",
            backface_culling = true,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
        },
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_flowing = "nh_nodes:water_flowing",
    liquid_alternative_source = "nh_nodes:water",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=0, g=0, b=255},
    drowning = 1,  -- ADICIONEI ESSA LINHA
    groups = {water=1, liquid=1, not_in_creative_inventory=1},
})

-- Gelo
core.register_node("nh_nodes:ice", {
    description = "Gelo",
    drawtype = "glasslike",
    tiles = {"ice2.png"}, 
    groups = {cracky = 3},
    walkable = true,
    --is_ground_content = true,
    use_texture_alpha = "clip", --blend
    --alpha = 200,
    paramtype = "light",
    sunlight_propagates = true,   -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice"},

    drop = "nh_nodes:ice2",
})

core.register_node("nh_nodes:ice2", {
    description = "Gelo",
    drawtype = "glasslike",
    tiles = {"ice.png"}, 
    groups = {cracky = 3},
    walkable = true,
    --is_ground_content = true,
    use_texture_alpha = "blend", --blend
    --alpha = 200,
    paramtype = "light",
    sunlight_propagates = true,   -- deixa a luz passar, como gelo real         -- não flui
    --post_effect_color = {a = 15, r = 15, g = 15, b = 15},
    --connects_to = {"nh_nodes:ice"},


    pointabilities = {
        nodes = {
            ["nh_nodes:water"]         = true,
            ["nh_nodes:water_flowing"] = true,
            ["nh_nodes:water2"]        = true,
            ["nh_nodes:water2_flowing"] = true,
        }
    },

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
        core.remove_node(pos)
        core.add_entity(pos, "nh_mob:iceberg")
    end
end,  
    
-- Cobre o caso de água chegar até o nó depois que ele já está parado
on_flood = function(pos, oldnode, newnode)
    core.remove_node(pos)
    core.add_entity(pos, "nh_mob:iceberg")
    return false
end,
})

core.register_node("nh_nodes:water2", {
    description = "Água doce",
    drawtype = "liquid",
    tiles = {"agua2.png"},
    special_tiles = {
        { name = "agua2_animated.png", animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0} },
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_flowing = "nh_nodes:water2_flowing",
    liquid_alternative_source = "nh_nodes:water2",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=0, g=0, b=255},
    drowning = 1,  -- ADICIONE ESTA LINHA
    groups = {water=1, liquid=1},
})

core.register_node("nh_nodes:water2_flowing", {
    description = "Água Doce Corrente",
    drawtype = "flowingliquid",
    tiles = {"agua2.png"},
    special_tiles = {
        {
            name = "agua2_flowing_animated.png",
            backface_culling = false,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
        },
        {
            name = "agua2_flowing_animated.png",  -- Corrigido (estava agua_flowing)
            backface_culling = true,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
        },
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
    post_effect_color = {a=64, r=0, g=0, b=255},
    drowning = 1,  -- ADICIONE ESTA LINHA
    groups = {water=1, liquid=1, not_in_creative_inventory=1},
})
    
    
    core.register_node("nh_nodes:lava", {
    description = "Lava",
    drawtype = "liquid",
    tiles = {"lava.png"},
    special_tiles = {
        { name = "lava_animated.png", animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0} },
    },
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
    post_effect_color = {a=64, r=255, g=0, b=0},
    groups = {lava=1, liquid=1},
})

core.register_node("nh_nodes:lava_flowing", {
    description = "Lava corrente",
    drawtype = "flowingliquid",
    tiles = {"lava.png"},
    special_tiles = {
        {
            name = "lava_flowing_animated.png",
            backface_culling = false,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
        },
        {
            name = "lava_flowing_animated.png",
            backface_culling = true,
            animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
        },
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    pointable = false,
    liquidtype = "flowing",
    liquid_alternative_flowing = "nh_nodes:lava_flowing",
    liquid_alternative_source = "nh_nodes:lava",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=255, g=0, b=0},
    groups = {lava=1, liquid=1, not_in_creative_inventory=1},

})

-------
-- Papeis
-------

-- Node para Página em branco
core.register_node("nh_nodes:page_node", {
    description = "Página",
    drawtype = "mesh",
    mesh = "page.obj",
    tiles = {"page.png"},
    inventory_image = "page.png",
    wield_image = "page.png",
    wield_scale = {x = 0.5, y = 0.5, z = 0.01},
    visual_scale = 1.0,
    paramtype = "light",
    paramtype2 = "wallmounted",  -- MUDOU PARA WALLMOUNTED
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "clip",
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.31, -0.49, -0.44, 0.31, -0.45, 0.44},
        wall_bottom = {-0.31, 0.5, -0.44, 0.31, 0.49, 0.44},
        wall_side = {0.5, -0.44, -0.31, 0.49, 0.44, 0.31},
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 3},
    drop = "",
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then
            return
        end
        
        local player_name = clicker:get_player_name()
        local has_feather, has_ink = writing_utils.player_has_writing_tools(clicker)
        
        if not has_feather or not has_ink then
            local msg = "Acho que preciso de "
            if not has_feather and not has_ink then
                msg = msg .. "uma pena na hotbar e um frasco de tinta no inventário para escrever."
            elseif not has_feather then
                msg = msg .. "uma pena na hotbar para escrever."
            else
                msg = msg .. "um frasco de tinta no inventário para escrever."
            end
            core.chat_send_player(player_name, msg)
            return
        end
        
        core.show_formspec(player_name, "nh_nodes:page_writer:" .. core.pos_to_string(pos),
            "size[8,6]" ..
            "label[0.3,0;Escrever na Página:]" ..
            "textarea[0.3,0.5;8,4.5;page_text;;]" ..
            "button[2,5;2,1;save;Salvar]" ..
            "button[4,5;2,1;cancel;Cancelar]"
        )
    end,
    
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:page")
            if inv:room_for_item("main", itemstack) then
                inv:add_item("main", itemstack)
            else
                core.add_item(pos, itemstack)
            end
        end
    end,
})

-- Node para Página escrita
core.register_node("nh_nodes:writedpage_node", {
    description = "Página escrita",
    drawtype = "mesh",
    mesh = "page.obj",
    tiles = {"writedpage.png"},
    inventory_image = "writedpage.png",
    wield_image = "writedpage.png",
    wield_scale = {x = 0.5, y = 0.5, z = 0.01},
    paramtype = "light",
    paramtype2 = "wallmounted",  
    sunlight_propagates = true,
    walkable = false,
    use_texture_alpha = "clip",
    selection_box = {
        type = "wallmounted",
        wall_top = {-0.31, -0.49, -0.44, 0.31, -0.45, 0.44},
        wall_bottom = {-0.31, 0.5, -0.44, 0.31, 0.49, 0.44},
        wall_side = {0.5, -0.44, -0.31, 0.49, 0.44, 0.31},
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 3, not_in_creative_inventory = 1},
    drop = "",
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then
            return
        end
        
        local player_name = clicker:get_player_name()
        local meta = core.get_meta(pos)
        local text = meta:get_string("text")
        
        if text == "" then
            text = "Página em branco"
        end
        
        core.show_formspec(player_name, "nh_nodes:page_reader",
            "size[8,6]" ..
            "textarea[0.3,0.3;8,5;page_text;;" .. core.formspec_escape(text) .. "]" ..
            "button_exit[3,5.3;2,1;close;Fechar]"
        )
    end,
    
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local itemstack = ItemStack("nh_items:writedpage")
            local meta = itemstack:get_meta()
            meta:set_string("text", oldmetadata.fields.text or "")
            
            if inv:room_for_item("main", itemstack) then
                inv:add_item("main", itemstack)
            else
                core.add_item(pos, itemstack)
            end
        end
    end,
})

-- Modificar os craftitems originais para colocar os nodes
core.override_item("nh_items:page", {
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end
        
        local under = pointed_thing.under
        local above = pointed_thing.above
        
        if core.is_protected(above, placer:get_player_name()) then
            return itemstack
        end
        
        local node = core.get_node(above)
        if node.name ~= "air" then
            return itemstack
        end
        
        -- Calcular wallmounted - MUITO MAIS SIMPLES
        local dir = vector.subtract(above, under)
        local wallmounted = core.dir_to_wallmounted(dir)
        
        core.set_node(above, {name = "nh_nodes:page_node", param2 = wallmounted})
        core.sound_play("default_place_node", {pos = above, gain = 1.0})
        
        if not core.is_creative_enabled(placer:get_player_name()) then
            itemstack:take_item()
        end
        
        return itemstack
    end,
})

core.override_item("nh_items:writedpage", {
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end
        
        local under = pointed_thing.under
        local above = pointed_thing.above
        
        if core.is_protected(above, placer:get_player_name()) then
            return itemstack
        end
        
        local node = core.get_node(above)
        if node.name ~= "air" then
            return itemstack
        end
        
        local dir = vector.subtract(above, under)
        local wallmounted = core.dir_to_wallmounted(dir)
        
        core.set_node(above, {name = "nh_nodes:writedpage_node", param2 = wallmounted})
        core.sound_play("default_place_node", {pos = above, gain = 1.0})
        
        local item_meta = itemstack:get_meta()
        local node_meta = core.get_meta(above)
        node_meta:set_string("text", item_meta:get_string("text"))
        
        if not core.is_creative_enabled(placer:get_player_name()) then
            itemstack:take_item()
        end
        
        return itemstack
    end,
})

if not nodes then nodes = {} end

function nodes.place_written_page(pos, text, facedir)
    core.set_node(pos, {
        name = "nh_nodes:writedpage_node",
        param2 = facedir
    })
    local meta = core.get_meta(pos)
    meta:set_string("text", text)
end


-- Handler para salvar o texto
core.register_on_player_receive_fields(function(player, formname, fields)
local prefix = "nh_items:page_writer:"
    if formname:sub(1, #prefix) == "nh_items:page_writer:" then
        if fields.save and fields.page_text then
            local pos_str = formname:sub(#prefix + 1)
            local pos = core.string_to_pos(pos_str)
            
            if pos then
                local node = core.get_node(pos)
                if node.name == "nh_nodes:page_node" then
                    -- Substituir por página escrita mantendo a rotação
                    core.set_node(pos, {name = "nh_nodes:writedpage_node", param2 = node.param2})
                    local meta = core.get_meta(pos)
                    meta:set_string("text", fields.page_text)
                    
                    -- Consumir tinta (adapte conforme sua função)
                    if consume_ink then
                        writing_utils.consume_ink(player)
                    end
                    
                    core.chat_send_player(player:get_player_name(), "Texto salvo na página!")
                end
            end
        end
    end
end)


---------
-- Baú geral
--------

-- Função para atualizar itens visuais no baú
function oak_chest_update_items(pos)
    local node = core.get_node(pos)
    if node.name ~= "nh_nodes:oak_chest_open" then
        return
    end
    
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    
    -- Remover entidades de itens antigas
    local objects = core.get_objects_inside_radius(pos, 1)
    for _, obj in ipairs(objects) do
        if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:chest_item" then
            obj:remove()
        end
    end
    
    -- Procurar a entidade do baú aberto para anexar os itens
    local chest_entity = nil
    for _, obj in ipairs(objects) do
        local luaent = obj:get_luaentity()
        if luaent and luaent.name == "nh_nodes:oak_chest_entity" then
            chest_entity = obj
            break
        end
    end
    
    -- Se não houver entidade do baú, criar uma invisível para servir de base
    if not chest_entity then
        chest_entity = core.add_entity(pos, "nh_nodes:oak_chest_entity")
        if chest_entity and chest_entity:get_luaentity() then
            local luaent = chest_entity:get_luaentity()
            luaent.node_pos = pos
            luaent.is_invisible = true
            
            -- Aplicar rotação
            local yaw = core.facedir_to_dir(node.param2)
            chest_entity:set_yaw(core.dir_to_yaw(yaw))
        end
    end
    
    if not chest_entity then
        return
    end
    
    -- Criar novas entidades para cada item (máximo 16 bones)
    for i = 1, math.min(16, inv:get_size("main")) do
        local stack = inv:get_stack("main", i)
        if not stack:is_empty() then
            local entity = core.add_entity(pos, "nh_nodes:chest_item")
            if entity and entity:get_luaentity() then
                local luaent = entity:get_luaentity()
                luaent.chest_pos = pos
                luaent.slot_index = i
                luaent:update_item(stack:get_name())
                
                -- Anexar ao bone correspondente do baú
                entity:set_attach(chest_entity, "bone"..i, {x=0, y=0, z=0}, {x=0, y=0, z=0})
            end
        end
    end
end

-- Entidade para representar itens no baú
core.register_entity("nh_nodes:chest_item", {
    initial_properties = {
        visual = "wielditem",
        wield_item = "air",
        visual_size = {x=0.1, y=0.1},  -- Tamanho reduzido (era 0.25)
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
    },
    
    chest_pos = nil,
    slot_index = 0,
    
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal=1})
    end,
    
    update_item = function(self, item_name)
        self.object:set_properties({
            wield_item = item_name
        })
    end,
    
    on_step = function(self, dtime)
        -- Verificar se o baú ainda existe
        if not self.chest_pos then
            self.object:remove()
            return
        end
        
        local node = core.get_node(self.chest_pos)
        if node.name ~= "nh_nodes:oak_chest_open" then
            self.object:remove()
        end
    end,
})

core.register_node("nh_nodes:oak_chest_open", {
    drawtype = "mesh",
    mesh = "chestopen.obj",  -- modelo sem tampa
    tiles = {"ChestTexture.png"}, -- mesma textura
    walkable = true,
    pointable = true,
    paramtype = "light",
    paramtype2 = "facedir",

    selection_box = {
        type = "fixed",
        fixed = {-0.5,-0.5,-0.5, 0.5,0.5,0.5}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.5,-0.5,-0.5, 0.5,0.5,0.5}
    },

    groups = {not_in_creative_inventory = 1},
    
    -- Quando clicar no baú aberto, mostrar inventário
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = core.get_meta(pos)
        local player_name = clicker:get_player_name()
        
        -- Marcar que o jogador está usando o baú
        meta:set_string("current_user", player_name)
        
        core.show_formspec(player_name, "nh_nodes:oak_chest_"..core.pos_to_string(pos),
            meta:get_string("formspec"))
        
        return itemstack
    end,
    
    -- Atualizar itens visuais quando o node é construído
    on_construct = function(pos)
        core.after(0.1, function()
            oak_chest_update_items(pos)
        end)
    end,
    
    -- Atualizar itens visuais após colocar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        core.after(0.1, function()
            oak_chest_update_items(pos)
        end)
    end,
})

core.register_node("nh_nodes:oakchest", {
    description = "Baú de Carvalho",
    drawtype = "mesh",
    mesh = "chest.glb",
    tiles = {"ChestTexture.png"},
    walkable = true,
    pointable = true,
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    },
    
    -- Criar inventário quando o node é construído
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        
        -- Criar inventário com 32 slots (8x4)
        inv:set_size("main", 8*2) -- O bau é quadrado escolhi 4x4, mas na forma do inventário 8x2  
        
        -- Definir formspec do inventário
        meta:set_string("formspec",
            "size[8,9]"..
            "list[current_name;main;0,0.3;8,2;]"..
            "list[current_player;main;0,4.85;8,1;]"..
            "list[current_player;main;0,6.08;8,3;8]"..
            "listring[current_name;main]"..
            "listring[current_player;main]"
        )
        
        meta:set_string("infotext", "Baú de Carvalho")
    end,
    
    -- Verificar se pode cavar (não permitir se tiver itens)
    can_dig = function(pos, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,
    
    -- Ao clicar com botão direito
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Tocar som de abertura
        --core.sound_play("default_chest_open", {
        --    pos = pos,
        --    gain = 0.3,
        --    max_hear_distance = 10,
        --}, true)
        
        -- Substitui o node pelo baú aberto
        local current_node = core.get_node(pos)
        core.swap_node(pos, {name = "nh_nodes:oak_chest_open", param2 = current_node.param2})
        
        -- Retira a entidade baú depois da animação
        local objects = core.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objects) do
            if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:oak_chest_entity" then
                obj:remove()
            end
        end
        
        -- Criar entidade para animação
        local entity = core.add_entity(pos, "nh_nodes:oak_chest_entity")
        if entity and entity:get_luaentity() then
            local luaentity = entity:get_luaentity()
            luaentity.node_pos = pos
            luaentity.original_param2 = current_node.param2
            -- Aplicar a rotação do baú à entidade
            local yaw = core.facedir_to_dir(current_node.param2)
            entity:set_yaw(core.dir_to_yaw(yaw))
            entity:set_animation({x=0, y=0.25}, 1, 0, false) -- 0 a 0.25s a 30fps = frames 0-7.5
        end
        
        -- Abrir inventário
        local meta = core.get_meta(pos)
        local player_name = clicker:get_player_name()
        
        -- Marcar que o jogador está usando o baú
        meta:set_string("current_user", player_name)
        
        -- Atualizar itens visuais
        oak_chest_update_items(pos)
        
        core.show_formspec(player_name, "nh_nodes:oak_chest_"..core.pos_to_string(pos),
            meta:get_string("formspec"))
        
        return itemstack
    end,
    
    -- Preservar inventário ao cavar
    preserve_metadata = function(pos, oldnode, oldmeta, drops)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local items = {}
        
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if not stack:is_empty() then
                table.insert(items, stack:to_string())
            end
        end
        
        if #items > 0 then
            drops[1]:get_meta():set_string("items", core.serialize(items))
        end
    end,
    
    -- Restaurar inventário ao colocar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = core.get_meta(pos)
        local item_meta = itemstack:get_meta()
        local items = item_meta:get_string("items")
        
        if items ~= "" then
            items = core.deserialize(items)
            local inv = meta:get_inventory()
            
            for i, item_str in ipairs(items) do
                inv:set_stack("main", i, ItemStack(item_str))
            end
        end
    end,
})

core.register_node("nh_nodes:oak_chest", {
    description = "Baú de Carvalho",
    drawtype = "mesh",
    mesh = "chest.glb",
    tiles = {"ChestTexture.png"},
    walkable = true,
    pointable = true,
    
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    },
    drop = "nh_nodes:oakchest", -- sem "_"
    
    -- Criar inventário quando o node é construído
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        
        -- Criar inventário com 32 slots (8x4)
        inv:set_size("main", 8*2) -- O bau é quadrado escolhi 4x4, mas na forma do inventário 8x2  
        
        -- Adiciona páginas com textos pré-definidos
        local page1 = items.create_page_with_text(
            "Dia 1: Encontrei este lugar abandonado. " ..
            "Parece que alguém viveu aqui há muito tempo atrás."
        )
        
        local page2 = items.create_page_with_text(
            "Dia 15: Os suprimentos estão acabando. " ..
            "Preciso encontrar uma saída antes que seja tarde demais."
        )
        
        local page3 = items.create_page_with_text(
            "Dia 30: Ouvi sons estranhos durante a noite. " ..
            "Não estou sozinho aqui..."
        )
        
        inv:set_stack("main", 1, page1)
        inv:set_stack("main", 2, page2)
        inv:set_stack("main", 3, page3)
        
	-- Adiciona páginas em branco
	inv:set_stack("main", 4, ItemStack("nh_items:page 5"))  -- 5 páginas em branco
	
	inv:set_stack("main", 5, ItemStack("nh_items:feather"))  -- pena de escrever
	inv:set_stack("main", 6, ItemStack("nh_items:inkbottle"))  -- frasco com tinta
	inv:set_stack("main", 7, ItemStack("nh_nodes:torch2"))  -- tocha acesa
        
        inv:set_stack("main", 8, ItemStack("nh_nodes:apple 2"))  -- 2 maças
        inv:set_stack("main", 9, ItemStack("nh_nodes:blueberry 2"))  -- 2 mitilos
        inv:set_stack("main", 10, ItemStack("nh_nodes:coconut 2"))  -- 2 cocos
        inv:set_stack("main", 11, ItemStack("nh_nodes:palmlog 1"))
        inv:set_stack("main", 12, ItemStack("nh_nodes:palmleaf 1"))
        
        -- Definir formspec do inventário
        meta:set_string("formspec",
            "size[8,9]"..
            "list[current_name;main;0,0.3;8,2;]"..
            "list[current_player;main;0,4.85;8,1;]"..
            "list[current_player;main;0,6.08;8,3;8]"..
            "listring[current_name;main]"..
            "listring[current_player;main]"
        )
        
        meta:set_string("infotext", "Baú de Carvalho")
    end,
    
    -- Verificar se pode cavar (não permitir se tiver itens)
    can_dig = function(pos, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,
    
    -- Ao clicar com botão direito
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Tocar som de abertura
        --core.sound_play("default_chest_open", {
        --    pos = pos,
        --    gain = 0.3,
        --    max_hear_distance = 10,
        --}, true)
        
        -- Substitui o node pelo baú aberto
        local current_node = core.get_node(pos)
        core.swap_node(pos, {name = "nh_nodes:oak_chest_open", param2 = current_node.param2})
        
        -- Retira a entidade baú depois da animação
        local objects = core.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objects) do
            if obj:get_luaentity() and obj:get_luaentity().name == "nh_nodes:oak_chest_entity" then
                obj:remove()
            end
        end
        
        -- Criar entidade para animação
        local entity = core.add_entity(pos, "nh_nodes:oak_chest_entity")
        if entity and entity:get_luaentity() then
            local luaentity = entity:get_luaentity()
            luaentity.node_pos = pos
            luaentity.original_param2 = current_node.param2
            -- Aplicar a rotação do baú à entidade
            local yaw = core.facedir_to_dir(current_node.param2)
            entity:set_yaw(core.dir_to_yaw(yaw))
            entity:set_animation({x=0, y=0.25}, 1, 0, false) -- 0 a 0.25s a 30fps = frames 0-7.5
        end
        
        -- Abrir inventário
        local meta = core.get_meta(pos)
        local player_name = clicker:get_player_name()
        
        -- Marcar que o jogador está usando o baú
        meta:set_string("current_user", player_name)
        
        -- Atualizar itens visuais
        oak_chest_update_items(pos)
        
        core.show_formspec(player_name, "nh_nodes:oak_chest_"..core.pos_to_string(pos),
            meta:get_string("formspec"))
        
        return itemstack
    end,
    
    -- Preservar inventário ao cavar
    preserve_metadata = function(pos, oldnode, oldmeta, drops)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local items = {}
        
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if not stack:is_empty() then
                table.insert(items, stack:to_string())
            end
        end
        
        if #items > 0 then
            drops[1]:get_meta():set_string("items", core.serialize(items))
        end
    end,
    
    -- Restaurar inventário ao colocar
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = core.get_meta(pos)
        local item_meta = itemstack:get_meta()
        local items = item_meta:get_string("items")
        
        if items ~= "" then
            items = core.deserialize(items)
            local inv = meta:get_inventory()
            
            for i, item_str in ipairs(items) do
                inv:set_stack("main", i, ItemStack(item_str))
            end
        end
    end,
})

-- Entidade invisível para animação
core.register_entity("nh_nodes:oak_chest_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "chest.glb",
        textures = {"ChestTexture.png"},
        visual_size = {x=1, y=1, z=1},
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
        self.object:set_armor_groups({immortal=1})
    end,
    
    on_step = function(self, dtime)
        -- Se for invisível (só para anexar itens), não fazer nada
        if self.is_invisible then
            return
        end
        
        self.timer = self.timer + dtime
        
        -- Após a animação, congelar no último frame
        if self.timer > 0.3 and not self.animation_finished then
            self.animation_finished = true
            -- Congelar no último frame da animação
            self.object:set_animation({x=0.25, y=0.25}, 0, 0, false)
        end
    end,
})

-- Entidade para animação de fechamento
core.register_entity("nh_nodes:oak_chest_close_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "chest.glb",
        textures = {"ChestTexture.png"},
        visual_size = {x=1, y=1, z=1},
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
        self.object:set_armor_groups({immortal=1})
    end,
    
    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        
        -- Remover entidade e fechar baú após a animação
        if self.timer > 0.3 then
            -- Remover todos os itens anexados
            if self.node_pos then
                local objects = core.get_objects_inside_radius(self.node_pos, 1)
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
                local node = core.get_node(self.node_pos)
                if node.name == "nh_nodes:oak_chest_open" then
                    core.swap_node(self.node_pos, {name = "nh_nodes:oak_chest", param2 = self.original_param2})
                end
            end
        end
    end,
})

-- Detectar quando o jogador fecha o formspec
core.register_on_player_receive_fields(function(player, formname, fields)
local prefix = "nh_nodes:oak_chest_"
    -- Verificar se é um formspec de baú
    if formname:sub(1, #prefix) == "nh_nodes:oak_chest_" then
        local pos_string = formname:sub(#prefix + 1)
        local pos = core.string_to_pos(pos_string)
        
        if pos then
            local node = core.get_node(pos)
            
            -- Se o baú estiver aberto, fechá-lo
            if node.name == "nh_nodes:oak_chest_open" then
                local meta = core.get_meta(pos)
                local current_user = meta:get_string("current_user")
                local player_name = player:get_player_name()
                
                -- Verificar se é o jogador que estava usando
                if current_user == player_name then
                    -- Limpar usuário atual
                    meta:set_string("current_user", "")
                    
                    -- Remover apenas a entidade da animação de abertura (mas manter os itens)
                    local objects = core.get_objects_inside_radius(pos, 0.5)
                    local chest_entity = nil
                    
                    for _, obj in ipairs(objects) do
                        local luaent = obj:get_luaentity()
                        if luaent and luaent.name == "nh_nodes:oak_chest_entity" then
                            chest_entity = obj
                            break
                        end
                    end
                    
                    -- Criar entidade para animação de fechamento
                    local close_entity = core.add_entity(pos, "nh_nodes:oak_chest_close_entity")
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
                                    obj:set_attach(close_entity, "bone"..slot, {x=0, y=0, z=0}, {x=0, y=0, z=0})
                                end
                            end
                            
                            -- Remover a entidade antiga do baú
                            chest_entity:remove()
                        end
                        
                        -- Aplicar a rotação do baú à entidade
                        local yaw = core.facedir_to_dir(node.param2)
                        close_entity:set_yaw(core.dir_to_yaw(yaw))
                        -- Animação de fechamento (do frame aberto para fechado)
                        close_entity:set_animation({x=0.25, y=0}, 30, 0, false)
                    end
                end
            end
        end
    end
end)



-- Detectar mudanças no inventário do baú
core.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action ~= "move" and action ~= "put" and action ~= "take" then
        return
    end

    if inventory_info.to_list ~= "main" and inventory_info.from_list ~= "main" then
        return
    end

    local player_name = player:get_player_name()
    local player_pos = player:get_pos()
    if not player_pos then return end

    local objects = core.get_objects_inside_radius(player_pos, 10)

    for _, obj in ipairs(objects) do
        if obj:is_player() then
            goto continue
        end

        local pos = obj:get_pos()
        if not pos then
            goto continue
        end

        local node = core.get_node_or_nil(pos)
        if not node then
            goto continue
        end

        if node.name == "nh_nodes:oak_chest_open" then
            local meta = core.get_meta(pos)
            if meta:get_string("current_user") == player_name then
                oak_chest_update_items(pos)
            end
        end

        ::continue::
    end
end)

-- Som de fechamento ao sair do formspec (opcional)
--core.register_on_player_receive_fields(function(player, formname, fields)
--    if formname:find("nh_nodes:oak_chest_") then
--        if fields.quit then
--            local pos_str = formname:gsub("nh_nodes:oak_chest_", "")
--            local pos = core.string_to_pos(pos_str)
--            
--            if pos then
--                core.sound_play("default_chest_close", {
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

--core.register_node("nh_nodes:oak_door", {
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
    local obj = core.add_entity(pos, "nh_nodes:pebble_entity")
    if obj then
        obj:set_velocity(vector.multiply(dir, 13))
        obj:set_acceleration({x = 0, y = -9.81, z = 0})
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
---------------------------
-- FUNÇÃO DE ARREMESSO
---------------------------
local function throw_pebble(itemstack, placer)
    if not placer or not placer:is_player() then
        return itemstack
    end

    local pos = placer:get_pos()
    pos.y = pos.y + 1.5  -- altura dos olhos

    local dir = placer:get_look_dir()
    local obj = core.add_entity(pos, "nh_nodes:pebble_entity")

    if obj then
        obj:set_velocity(vector.multiply(dir, 18))
        obj:set_acceleration({x = 0, y = -10, z = 0})

        -- ✅ Define o atirador para não se machucar
        local ent = obj:get_luaentity()
        if ent then
            ent._shooter = placer
        end
    end

    -- Remove 1 item do stack
    itemstack:take_item(1)
    return itemstack
end

---------------------------
-- ITEM SEIXO ARREMESSÁVEL
---------------------------
local function update_neighbors(pos)
    local offsets = {
        {x=0, y=1, z=0},
        {x=0, y=-1, z=0},
        {x=1, y=0, z=0},
        {x=-1, y=0, z=0},
        {x=0, y=0, z=1},
        {x=0, y=0, z=-1},
    }
    for _, off in ipairs(offsets) do 
        local npos = vector.add(pos, off)
        -- Dispara física de falling_node (areia, cascalho, neve, etc.)
        core.check_for_falling(npos)
    end
end

core.register_craftitem("nh_nodes:pebble_item", {
    description = "Seixo\n[Arremessável]\nDano: +1\n(Arremesso: Q / dropar)",
    inventory_image = "seixoarremessavel.png",
    wield_image = "seixoarremessavel.png",
    wield_scale = {x = 0.5, y = 0.5, z = 0.5},

    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = { 
            cracky = {times = {[2] = 2.0, [3] = 1.0}, uses = 20, maxlevel = 1},
            crumbly = {times = {[1] = 1.5, [2] = 0.9, [3] = 0.5}, uses = 20, maxlevel = 1},
        },
        damage_groups = {fleshy = 2},
    },

    -- Botão direito = arremessa
    on_place = function(itemstack, placer, pointed_thing)
        return throw_pebble(itemstack, placer)
    end,

    -- Ao soltar = arremessa
    on_drop = function(itemstack, dropper, pos)
        return throw_pebble(itemstack, dropper)
    end

})

---------------------------
-- ENTIDADE DO PROJÉTIL
---------------------------
core.register_entity("nh_nodes:pebble_entity", {
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
    _shooter = nil,  -- ✅ Declarado aqui para ficar visível

    on_activate = function(self, staticdata)
        self._timer = 0
        self._stuck = false
        self._stuck_timer = 0
        self._shooter = nil
    end,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then
            self.object:remove()
            return
        end

        -- Timer geral para remover após muito tempo
        self._timer = self._timer + dtime
        if self._timer > 60 then
            self.object:remove()
            return
        end

        -- Se já está grudado
        if self._stuck then
            self._stuck_timer = self._stuck_timer + dtime

            -- Após 0.1 segundo grudado, vira node
            if self._stuck_timer >= 0.1 then
                local node_pos = vector.round(pos)
                local node = core.get_node(node_pos)

                if node.name == "air" or not core.registered_nodes[node.name].walkable then
                    core.set_node(node_pos, {name = "nh_nodes:pebble"})
                    update_neighbors(node_pos)
                else
                    local offsets = {
                        {x=0, y=1, z=0},
                        {x=0, y=-1, z=0},
                        {x=1, y=0, z=0},
                        {x=-1, y=0, z=0},
                        {x=0, y=0, z=1},
                        {x=0, y=0, z=-1},
                    }

                    local placed = false
                    for _, offset in ipairs(offsets) do
                        local try_pos = vector.add(node_pos, offset)
                        local try_node = core.get_node(try_pos)
                        if try_node.name == "air" then
                            core.set_node(try_pos, {name = "nh_nodes:pebble"})
                            update_neighbors(try_pos)
                            placed = true
                            break
                        end
                    end

                    if not placed then
                        core.add_item(pos, "nh_nodes:pebble_item")
                    end
                end

                self.object:remove()
            end
            return
        end

        local vel = self.object:get_velocity()
        if not vel then
            self.object:remove()
            return
        end

        local speed = vector.length(vel)

        -- Se a velocidade é muito baixa (parou de se mover)
        if speed < 0.5 then
            self._stuck = true
            self.object:set_velocity({x=0, y=0, z=0})
            self.object:set_acceleration({x=0, y=0, z=0})
            return
        end

        -- Verifica colisão com blocos sólidos via raycast manual
        local step_dir = vector.normalize(vel)
        local check_distance = math.min(speed * dtime * 2, 1)
        local steps = math.ceil(check_distance / 0.2)

        for i = 1, steps do
            local check_pos = vector.add(pos, vector.multiply(step_dir, i * 0.2))
            local node = core.get_node(check_pos)

            if node and node.name and core.registered_nodes[node.name] then
                if core.registered_nodes[node.name].walkable then
                    self._stuck = true
                    self.object:set_pos(check_pos)
                    self.object:set_velocity({x=0, y=0, z=0})
                    self.object:set_acceleration({x=0, y=0, z=0})
                    return
                end
                if node.name == "nh_nodes:coconutlinked" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:coconut"})
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    core.add_item(check_pos, {name = "nh_nodes:nut"})
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut2" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    core.add_item(check_pos, {name = "nh_nodes:nut", count = 2})
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_nut3" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    core.add_item(check_pos, {name = "nh_nodes:nut", count = 3})
                    update_neighbors(check_pos)
                    return
                end
                if node.name == "nh_nodes:leaves_apple" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    core.add_item(check_pos, {name = "nh_nodes:apple"})
                    update_neighbors(check_pos)
                    return
                end 
                if node.name == "nh_nodes:leaves_apple2" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    core.add_item(check_pos, {name = "nh_nodes:apple", count = 2})
                    update_neighbors(check_pos)
                    return
                end              
                if node.name == "nh_nodes:leaves_apple3" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:fallenstick"})
                    core.add_item(check_pos, {name = "nh_nodes:apple", count = 3})
                    update_neighbors(check_pos)
                    return
                end
            end
        end

        -- ✅ Raio aumentado de 0.6 para 1.2 para não passar pelo mob
        local objs = core.get_objects_inside_radius(pos, 1.2)
        for _, obj in ipairs(objs) do
            -- Ignora o próprio projétil e o atirador
            if obj ~= self.object and obj ~= self._shooter then

                local is_target = obj:is_player()

                if not is_target then
                    local ent = obj:get_luaentity()
                    -- ✅ Usa get_hp() no lugar de ent.hp_max, compatível com MobsRedo
                    if ent and ent.name ~= "nh_nodes:pebble_entity" then
                        local hp = obj:get_hp()
                        if hp and hp > 0 then
                            is_target = true
                        end
                    end
                end

                if is_target then
                    core.log("action", "[Seixo] Acertou alvo em " .. core.pos_to_string(pos))

                    core.sound_play("default_dig_cracky", {pos = pos, gain = 0.5})

                    obj:punch(self.object, 1.0, {
                        full_punch_interval = 1.0,
                        damage_groups = {fleshy = 2},
                    }, vel)

                    core.add_item(pos, "nh_nodes:pebble_item")
                    self.object:remove()
                    return
                end
            end
        end

        self._last_pos = pos
    end,
})

core.register_node("nh_nodes:branch", {
    description = "Galho\nAlcance: +2\nDano: +2\nUsos: 10",
    drawtype = "mesh",
    mesh = "stick.obj",
    tiles = {"stick.png"},

    range = 5, -- AUMENTA O ALCANCE
	
    groups = {

        oddly_breakable_by_hand = 3,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

        damage_groups = {fleshy = 3},
    },
    
    -- desgasta ao cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 6552 -- ~10 usos (65535 / 10)
        itemstack:set_wear(wear)
        return itemstack
    end,
    
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.04, -0.5, -0.12, 0.04, 0.5, 0.07},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.04, -0.5, -0.12, 0.04, 0.5, 0.07},
    },
})

core.register_node("nh_nodes:stick", {
    description = "Graveto\nAlcance: +1\nUsos: 5",
    drawtype = "mesh",
    mesh = "stick.obj",
    tiles = {"stick.png"},

    range = 4,

    groups = {oddly_breakable_by_hand = 1, flammable = 2, falling_node = 1},

    paramtype = "light",
	
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.04, -0.5, -0.12, 0.04, 0.5, 0.07},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.04, -0.5, -0.12, 0.04, 0.5, 0.07},
    },
    
        -- desgasta ao cavar node
    after_use = function(itemstack, user, node, digparams)
        local wear = itemstack:get_wear()
        wear = wear + 13107 -- ~5 usos (65535 / 5)
        itemstack:set_wear(wear)
        return itemstack
    end,
})

core.register_node("nh_nodes:fallenstick", {
    description = "Graveto caído",
    drawtype = "mesh",
    mesh = "stick2.obj",
    tiles = {"stick.png"},

    drop = "nh_nodes:stick",

    paramtype = "light",
    walkable = false,

    groups = {oddly_breakable_by_hand = 1, flammable = 2, falling_node = 1},

    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.12, 0.5, -0.435, 0.065},
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.12, 0.5, -0.435, 0.065},
    },
})


---------------------------
-- NODE DO SEIXO DE OBSIDIANA
---------------------------
core.register_node("nh_nodes:obsidianpebble", {
    description = "Seixo de Obsidiana\nDano: +1",
    drawtype = "mesh",
    mesh = "pebble.obj",  -- 
    tiles = {"obsidiana.png"}, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    drop = "nh_nodes:obsidianpebble_item",

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        oddly_breakable_by_hand = 3,
        falling_node = 1,
        attached_node = 1,
    },

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
    
   tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            snappy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

        damage_groups = {fleshy = 2},
    },
})

---------------------------
-- FUNÇÃO DE ARREMESSO
---------------------------
local function throw_pebble(itemstack, placer)
    if not placer or not placer:is_player() then
        return itemstack
    end

    local pos = placer:get_pos()
    pos.y = pos.y + 1.5  -- altura dos olhos

    local dir = placer:get_look_dir()
    local obj = core.add_entity(pos, "nh_nodes:obsidianpebble_entity")

    if obj then
        obj:set_velocity(vector.multiply(dir, 18))
        obj:set_acceleration({x = 0, y = -10, z = 0})

        -- ✅ Define o atirador para não se machucar
        local ent = obj:get_luaentity()
        if ent then
            ent._shooter = placer
        end
    end

    -- Remove 1 item do stack
    itemstack:take_item(1)
    return itemstack
end

---------------------------
-- ITEM
---------------------------
core.register_craftitem("nh_nodes:obsidianpebble_item", {
    description = "Seixo de Obsidiana\n[Arremessável]\nDano: +1\n(Arremesso: Q / dropar)",
    inventory_image = "obsidiana_seixo_arremessavel.png",
    wield_image = "obsidiana_seixo_arremessavel.png",
    wield_scale = {x = 0.5, y = 0.5, z = 0.5},

    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            cracky = {times = {[2] = 2.0, [3] = 1.0}, uses = 20, maxlevel = 1},
            crumbly = {times = {[1] = 1.5, [2] = 0.9, [3] = 0.5}, uses = 20, maxlevel = 1},
            snappy = {times = {[2] = 1.0, [3] = 0.5}, uses = 20, maxlevel = 1},
        },
        damage_groups = {fleshy = 2},
    },

    -- Botão direito = arremessa
    on_place = function(itemstack, placer, pointed_thing)
        return throw_pebble(itemstack, placer)
    end,

    -- Ao soltar = arremessa
    on_drop = function(itemstack, dropper, pos)
        return throw_pebble(itemstack, dropper)
    end,
})


---------------------------
-- ENTIDADE DO PROJÉTIL
---------------------------
core.register_entity("nh_nodes:obsidianpebble_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        visual = "wielditem",
        visual_size = {x = 0.5, y = 0.5},
        textures = {"nh_nodes:obsidianpebble"},
    },

    _stuck = false,
    _timer = 0,
    _stuck_timer = 0,
    _last_pos = nil,
    _shooter = nil,  -- ✅ Declarado aqui para ficar visível

    on_activate = function(self, staticdata)
        self._timer = 0
        self._stuck = false
        self._stuck_timer = 0
        self._shooter = nil
    end,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then
            self.object:remove()
            return
        end

        -- Timer geral para remover após muito tempo
        self._timer = self._timer + dtime
        if self._timer > 60 then
            self.object:remove()
            return
        end

        -- Se já está grudado
        if self._stuck then
            self._stuck_timer = self._stuck_timer + dtime

            -- Após 0.1 segundo grudado, vira node
            if self._stuck_timer >= 0.1 then
                local node_pos = vector.round(pos)
                local node = core.get_node(node_pos)

                if node.name == "air" or not core.registered_nodes[node.name].walkable then
                    core.set_node(node_pos, {name = "nh_nodes:obsidianpebble"})
                else
                    local offsets = {
                        {x=0, y=1, z=0},
                        {x=0, y=-1, z=0},
                        {x=1, y=0, z=0},
                        {x=-1, y=0, z=0},
                        {x=0, y=0, z=1},
                        {x=0, y=0, z=-1},
                    }

                    local placed = false
                    for _, offset in ipairs(offsets) do
                        local try_pos = vector.add(node_pos, offset)
                        local try_node = core.get_node(try_pos)
                        if try_node.name == "air" then
                            core.set_node(try_pos, {name = "nh_nodes:obsidianpebble"})
                            placed = true
                            break
                        end
                    end

                    if not placed then
                        core.add_item(pos, "nh_nodes:obsidianpebble_item")
                    end
                end

                self.object:remove()
            end
            return
        end

        local vel = self.object:get_velocity()
        if not vel then
            self.object:remove()
            return
        end

        local speed = vector.length(vel)

        -- Se a velocidade é muito baixa (parou de se mover)
        if speed < 0.5 then
            self._stuck = true
            self.object:set_velocity({x=0, y=0, z=0})
            self.object:set_acceleration({x=0, y=0, z=0})
            return
        end

        -- Verifica colisão com blocos sólidos via raycast manual
        local step_dir = vector.normalize(vel)
        local check_distance = math.min(speed * dtime * 2, 1)
        local steps = math.ceil(check_distance / 0.2)

        for i = 1, steps do
            local check_pos = vector.add(pos, vector.multiply(step_dir, i * 0.2))
            local node = core.get_node(check_pos)

            if node and node.name and core.registered_nodes[node.name] then
                if core.registered_nodes[node.name].walkable then
                    self._stuck = true
                    self.object:set_pos(check_pos)
                    self.object:set_velocity({x=0, y=0, z=0})
                    self.object:set_acceleration({x=0, y=0, z=0})
                    return
                end
                if node.name == "nh_nodes:coconutlinked" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:coconut"})
                    update_neighbors(check_pos)
                    return
                end
            end
        end

        -- ✅ Raio aumentado de 0.6 para 1.2 para não passar pelo mob
        local objs = core.get_objects_inside_radius(pos, 1.2)
        for _, obj in ipairs(objs) do
            -- Ignora o próprio projétil e o atirador
            if obj ~= self.object and obj ~= self._shooter then

                local is_target = obj:is_player()

                if not is_target then
                    local ent = obj:get_luaentity()
                    -- ✅ Usa get_hp() no lugar de ent.hp_max, compatível com MobsRedo
                    if ent and ent.name ~= "nh_nodes:obsidianpebble_entity" then
                        local hp = obj:get_hp()
                        if hp and hp > 0 then
                            is_target = true
                        end
                    end
                end

                if is_target then
                    core.log("action", "[Seixo de Obsidiana] Acertou alvo em " .. core.pos_to_string(pos))

                    core.sound_play("default_dig_cracky", {pos = pos, gain = 0.5})

                    obj:punch(self.object, 1.0, {
                        full_punch_interval = 1.0,
                        damage_groups = {fleshy = 2},
                    }, vel)

                    core.add_item(pos, "nh_nodes:obsidianpebble_item")
                    self.object:remove()
                    return
                end
            end
        end

        self._last_pos = pos
    end,
})


---------------------------
-- NODE DO SEIXO DE OBSIDIANA
---------------------------
core.register_node("nh_nodes:obsidianblade", {
    description = "Lâmina de Obsidiana",
    drawtype = "mesh",
    mesh = "obsidianblade.obj",  -- 
    tiles = {"obsidiana.png"}, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        snappy = 3,
        oddly_breakable_by_hand = 3,
        falling_node = 1,
        attached_node = 1,
    },

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
})

---------------------------
-- NODE DA FERRAMENTA REMO
---------------------------
core.register_node("nh_nodes:rowing", {
    description = "Remo\nAlcance: +3\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "rowing.obj",  -- 
    tiles = {"oakwood.png"}, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
    
    range = 6, -- AUMENTA O ALCANCE
 
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

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


    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.5, 0.125, -0.435, 1.35},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.5, 0.125, -0.435, 1.35},
    },

    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 3, y = 0, z = 1.8},
        rot = {x = 90, y = 0, z = -90},
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


---------------------------
-- ENTIDADE DA JANGADA (versão navegável)
---------------------------
core.register_entity("nh_nodes:pineraft_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "pineraft_entity.obj",
        textures = {"pineraft.png"},
        visual_size = {x = 2.5, y = 2.5, z = 2.5},
        collisionbox = {-1, 0, -1.5, 1, 0.9, 1.5},
        physical = true,
        is_visible = true,
        hp_max = 4, -- "durabilidade": quantos socos para quebrar
            -- Adicione isso:
    automatic_face_movement_dir = false,
    stepheight = 0.5,
    gravity = {x = 0, y = -9.81, z = 0},
    },

    driver = nil,

on_activate = function(self, staticdata)
    self.object:set_armor_groups({immortal = 0, fleshy = 100})
    self.object:set_hp(8)
    self.object:set_velocity({x = 0, y = 0, z = 0})
    self.object:set_acceleration({x = 0, y = -9.81, z = 0})
end,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        -- Desmonta se for o motorista
	if self.driver and puncher == self.driver then
	    self.driver:set_detach()
	    if self._driver_visual_size then
		self.driver:set_properties({ visual_size = self._driver_visual_size })
		self._driver_visual_size = nil
	    end
	    self.driver = nil
	    return
	end

        -- Só permite quebrar com a mão (sem ferramenta)
        local item = puncher:get_wielded_item()
        if item:get_name() ~= "" then
            -- tem ferramenta na mão, não quebra (opcional, remova se quiser)
            return
        end

        local hp = self.object:get_hp()
        hp = hp - 1

        if hp <= 0 then
            -- Dropa o item da jangada
            local pos = self.object:get_pos()
            core.add_item(pos, "nh_nodes:pineraft")
            self.object:remove()
        else
            self.object:set_hp(hp)
            -- Feedback visual: pisca (opcional)
            -- self.object:punch(puncher, ...) -- deixa o engine piscar
        end
    end,

    on_step = function(self, dtime)
	    local pos = self.object:get_pos()
	    if not pos then return end

	    local node_at    = core.get_node({x=pos.x, y=pos.y + 0.5, z=pos.z})
	    local node_below = core.get_node({x=pos.x, y=pos.y - 0.5, z=pos.z})
	    local node_below2 = core.get_node({x=pos.x, y=pos.y + 0.35, z=pos.z})  -- logo abaixo do centro

	    local water_nodes = {
		["nh_nodes:water"]          = true,
		["nh_nodes:water_flowing"]  = true,
		["nh_nodes:water2"]         = true,
		["nh_nodes:water2_flowing"] = true,
	    }

	    local submerged  = water_nodes[node_at.name]    -- entidade está dentro da água
	    local on_surface = water_nodes[node_below2.name] and not submerged -- entidade está na superfície

	local vel = self.object:get_velocity()

	if submerged then
	    self.object:set_acceleration({x = 0, y = 0, z = 0})
	    self.object:set_velocity({x = vel.x, y = 2, z = vel.z})
	elseif on_surface then
	    self.object:set_acceleration({x = 0, y = 0, z = 0})
	    self.object:set_velocity({x = vel.x, y = 0, z = vel.z})
	else
	    -- No ar: gravidade age normalmente
	    self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	    if vel.y > 0 then
		self.object:set_velocity({x = vel.x, y = 0, z = vel.z})
	    end
	end
	if self.driver then
	    -- Verifica se o jogador tem o remo na hotbar
	    local has_oar = false
	    local inv = self.driver:get_inventory()
	    if inv then
		local hotbar_size = 8
		if self.driver.hud_get_hotbar_itemcount then
		    hotbar_size = self.driver:hud_get_hotbar_itemcount()
		end
		for i = 1, hotbar_size do
		    local stack = inv:get_stack("main", i)
		    if stack:get_name() == "nh_nodes:rowing" then
		        has_oar = true
		        break
		    end
		end
		for i = 1, hotbar_size do
		    local stack = inv:get_stack("main", i)
		    if stack:get_name() == "nh_nodes:rowing" then
			has_oar = true
			break
		    end
		end

		-- Mensagem FORA do loop, e só envia uma vez usando um cooldown
		if not has_oar then
		    if not self._oar_msg_timer or self._oar_msg_timer <= 0 then
			core.chat_send_player(self.driver:get_player_name(), "Acho que preciso de um remo pra mover a jangada...")
			self._oar_msg_timer = 5 -- segundos antes de repetir
		    end
		end

		if self._oar_msg_timer and self._oar_msg_timer > 0 then
		    self._oar_msg_timer = self._oar_msg_timer - dtime
		end
	    end

	    local speed   = 3
	    local raft_yaw = self.object:get_yaw()

	    if has_oar then
		local ctrl       = self.driver:get_player_control()
		local mouse_yaw  = self.driver:get_look_horizontal()
		local turn_speed = 1.5

		-- Rotação suave em direção ao mouse
		local diff = mouse_yaw - raft_yaw
		while diff >  math.pi do diff = diff - 2 * math.pi end
		while diff < -math.pi do diff = diff + 2 * math.pi end
		local new_yaw = raft_yaw + diff * turn_speed * dtime

		if ctrl.left  then new_yaw = new_yaw + 0.05 end
		if ctrl.right then new_yaw = new_yaw - 0.05 end

		self.object:set_yaw(new_yaw)

		local vx, vz = 0, 0
		if ctrl.up   then vx =  math.sin(-new_yaw) * speed; vz =  math.cos(-new_yaw) * speed end
		if ctrl.down then vx = -math.sin(-new_yaw) * speed; vz = -math.cos(-new_yaw) * speed end

		local vel = self.object:get_velocity()
		self.object:set_velocity({x=vx, y=vel.y, z=vz})
	    else
		-- Sem remo: para a jangada gradualmente (atrito)
		local vel = self.object:get_velocity()
		self.object:set_velocity({
		    x = vel.x * 0.85,
		    y = vel.y,
		    z = vel.z * 0.85,
		})
	    end
	end
	
local half_width = 2.7 --/ 2
local half_length = 2.9 --/ 2
local half_height = 1.5 --/ 2

local search_radius = 4 -- só para busca inicial (ligeiramente maior)

local being_pushed = false

for _, obj in ipairs(core.get_objects_inside_radius(pos, search_radius)) do

    if obj:is_player() and obj ~= self.driver then

        local ppos = obj:get_pos()

        local dx = ppos.x - pos.x
        local dy = ppos.y - pos.y
        local dz = ppos.z - pos.z

        -- ✅ filtro retangular (caixa)
        if math.abs(dx) <= half_width and
           math.abs(dy) <= half_height and
           math.abs(dz) <= half_length then

            local pvel = obj:get_velocity()
            local speed_sq = pvel.x * pvel.x + pvel.z * pvel.z

            if speed_sq > 0.1 then

                local spd = math.sqrt(speed_sq)
                local force = 1.75
                local cur_vel = self.object:get_velocity()

                self.object:set_velocity({
                    x = cur_vel.x + (pvel.x / spd) * force * dtime,
                    y = cur_vel.y,
                    z = cur_vel.z + (pvel.z / spd) * force * dtime,
                })

                being_pushed = true
            end
        end
    end
end

-- Atrito só quando ninguém está empurrando e não há driver
if not self.driver and not being_pushed then
    local cur_vel = self.object:get_velocity()
    self.object:set_velocity({
        x = cur_vel.x * 0.93,  -- suave, desliza um pouco
        y = cur_vel.y,
        z = cur_vel.z * 0.93,
    })
end





    end,

on_rightclick = function(self, clicker)
    if not clicker or not clicker:is_player() then return end

    if self.driver == nil then
        self.driver = clicker

        -- Salva as propriedades originais do player
        self._driver_visual_size = clicker:get_properties().visual_size

        -- Contra-escala: 1 / 2.5 = 0.4
        -- Assim o player aparece no tamanho normal mesmo dentro da entidade escalonada
        clicker:set_properties({
            visual_size = {
                x = 1 / 2.5,
                y = 1 / 2.5,
                z = 1 / 2.5,
            }
        })

        clicker:set_attach(self.object, "", {x=0, y=3, z=0}, {x=0, y=0, z=0})

    elseif self.driver == clicker then
        clicker:set_detach()
        self.driver = nil

        -- Restaura as propriedades originais
        if self._driver_visual_size then
            clicker:set_properties({
                visual_size = self._driver_visual_size
            })
            self._driver_visual_size = nil
        end
    end
end,

on_death = function(self)
    if self.driver then
        self.driver:set_detach()
        if self._driver_visual_size then
            self.driver:set_properties({ visual_size = self._driver_visual_size })
            self._driver_visual_size = nil
        end
        self.driver = nil
    end
    local pos = self.object:get_pos()
    if pos then
        core.add_item(pos, "nh_nodes:pineraft")
    end
end,
})

---------------------------
-- NODE DA JANGADA PRIMITIVA
---------------------------
core.register_node("nh_nodes:pineraft", {
    description = "Jangada de Pinheiro",
    drawtype = "mesh",
    mesh = "pineraft.obj",  -- 
    tiles = {"pineraft.png"}, -- tiles = {"pedra.png"},
    inventory_image = "pineraft_inv.png",

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        oddly_breakable_by_hand = 1,
        --falling_node = 1,
    },


    collision_box = {
        type = "fixed",
        fixed = {-1, -0.5, -1.5, 1, 0.5, 1.5},
    },

    selection_box = {
        type = "fixed",
        fixed = {-1, -0.5, -1.5, 1, 0.5, 1.5},
    },

    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -2, y = -2, z = 1.8},
        rot = {x = 90, y = 0, z = -90},
    },
    --wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 0, y = -1, z = -0.5},
        rot = {x = 90, y = 0, z = 90},
    },
    
    pointabilities = {
        nodes = {
            ["nh_nodes:water"]         = true,
            ["nh_nodes:water_flowing"] = true,
            ["nh_nodes:water2"]        = true,
            ["nh_nodes:water2_flowing"] = true,
        }
    },
    
    -- Quando o nó é colocado, verifica se está na água
after_place_node = function(pos, placer, itemstack, pointed_thing)
    -- Se segurou agachar, deixa como nó estático (não vira entidade)
    if placer and placer:is_player() then
        local ctrl = placer:get_player_control()
        if ctrl.sneak then
            return -- coloca normalmente como nó, não faz nada
        end
    end
    -- Sem agachar: vira entidade normalmente
    core.remove_node(pos)
    core.add_entity(pos, "nh_nodes:pineraft_entity")
end,
    
-- Cobre o caso de água chegar até o nó depois que ele já está parado
on_flood = function(pos, oldnode, newnode)
    core.add_entity(pos, "nh_nodes:pineraft_entity")
    return false
end,
})

---------------------------
-- NODE DA ESPADA DE OBSIDIANA
---------------------------
core.register_node("nh_nodes:obsidiansword", {
    description = "Espada de Obsidiana\nAlcance: +3\nDano: +6\nUsos: 15",
    drawtype = "mesh",
    mesh = "obsidiansword.obj",  -- 
    tiles = {"obsidiansword.png"}, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        --fleshy = 1, -- mobs, carne
        --snappy  = 2, -- folhas, plantas
        --crumbly = 3, -- terra, areia, argila
        oddly_breakable_by_hand = 3,
        falling_node = 1,
    },
    
    range = 6, -- AUMENTA O ALCANCE
 
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

        damage_groups = {fleshy = 7},
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


    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.5, 0.125, -0.435, 1.35},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.5, 0.125, -0.435, 1.35},
    },

    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 3, y = 0, z = 1.8},
        rot = {x = 90, y = 0, z = -90},
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


---------------------------
-- NODE DO SEIXO NO CHÃO
---------------------------
core.register_node("nh_nodes:pebble", {
    description = "Seixo\nDano: +1",
    drawtype = "mesh",
    mesh = "pebble.obj",  -- 
    tiles = {"seixo.png"}, -- tiles = {"pedra.png"},
    --inventory_image = "seixo.png",
    --wield_image = "seixo.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        oddly_breakable_by_hand = 3,
        falling_node = 1,
        attached_node = 1,
    },

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    drop = "nh_nodes:pebble_item",

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
    
   tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

        damage_groups = {fleshy = 2},
    },
})


---------------------------
-- NODE DA PEDRA LASCADA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
core.register_node("nh_nodes:chippedstone", {
    description = "Pedra Lascada\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "pedralascada.obj",
    tiles = {"pedralascada.png"},  -- Ícone 2D no inventário
    inventory_image = "inv_stoneknifehead.png",  -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
    
        tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
})


---------------------------
-- NODE DA CABEÇA DE MACHADO DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
core.register_node("nh_nodes:stoneaxehead", {
    description = "Cabeça de Machado de Pedra\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "stoneaxehead.obj",
    tiles = {"pedralascada.png"},  -- Ícone 2D no inventário
    inventory_image = "pedralascada.png",  -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
    
        tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
})


---------------------------
-- NODE DA CABEÇA DE PICARETA DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
core.register_node("nh_nodes:stonepickaxehead", {
    description = "Cabeça de Picareta de Pedra\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "stonepickaxehead.obj",
    tiles = {"pedralascada.png"},  -- Ícone 2D no inventário
    inventory_image = "inv_stonepickaxehead.png",  -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
    
        tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
})


---------------------------
-- NODE DA CABEÇA DE PICARETA DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
core.register_node("nh_nodes:stonehoehead", {
    description = "Cabeça de Enxada de Pedra\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "stonehoehead.obj",
    tiles = {"pedralascada.png"},  -- Ícone 2D no inventário
    inventory_image = "inv_stonehoehead.png",  -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
    
        tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
})


---------------------------
-- NODE DA CABEÇA DE PICARETA DE PEDRA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
core.register_node("nh_nodes:stoneadzehead", {
    description = "Cabeça de Enxó de Pedra\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "stoneadzehead.obj",
    tiles = {"pedralascada.png"},  -- Ícone 2D no inventário
    inventory_image = "inv_stoneadzehead.png",  -- Ícone 2D no inventário
    --wield_image = "pedralascada.png",       -- Ou deixe vazio para não mostrar nada na mão
    --wield_scale = {x = 0.5, y = 0.5, z = 0.5},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
    
        tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.095, 0.125, -0.435, 0.095},
    },

    -----------------------------
    -- FAZ O SEIXO CAIR SOZINHO
    -----------------------------
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,

    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
})



---------------------------
-- NODE DA ESPADA ENFERRUJADA (FERRAMENTA)
---------------------------
core.register_node("nh_nodes:rustironsword", {
    description = "Espada de Ferro Enferrujado\nAlcance: +3\nDano: +4\nUsos: 10",
    drawtype = "mesh",
    mesh = "rustsword.obj",
    tiles = {"rustsword.png"}, 
    paramtype = "light",
    use_texture_alpha = "clip",
    backface_culling = false,
    sunlight_propagates = true,
    walkable = false,

    range = 6, -- AUMENTA O ALCANCE
        
    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
    },
    
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

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
    
    --drop = "nh_items:rustironsword",

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.05, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.03, -0.5, -0.115, 0.03, 0.5, 0.115},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.3, y = 0, z = 0},
        rot = {x = 270, y = -90, z = 0},
    },
     wielded_visual_size = {x = 0.325, y = 0.325, z = 0.325},
})


core.register_node("nh_nodes:stoneaxe", {
    description = "Machado de Pedra\nAlcance: +2\nDano: +3\nUsos: 15",
    drawtype = "mesh",
    mesh = "stoneaxe.obj",
    tiles = {"stoneaxe.png"}, 
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    range = 5,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 1,

        groupcaps = {
            choppy = {times = {[1]=20, [2]=15, [3]=10.00}, uses = 10, maxlevel = 1},
            snappy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.50, [2]=1.10, [3]=0.70}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.1, y = 0, z = 0.1}
        --rot = {x = 0, y = 0, z = -110}
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


core.register_node("nh_nodes:stonepickaxe", {
    description = "Picareta de Pedra\nAlcance: +2\nDano: +3\nUsos: 15",
    drawtype = "mesh",
    mesh = "stonepickaxe.obj",
    tiles = {"stonepickaxe.png"}, 
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    range = 5,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        --fleshy = 1, -- mobs, carne
        --snappy  = 2, -- folhas, plantas
        --crumbly = 3, -- terra, areia, argila
        --oddly_breakable_by_hand = 3,
        dig_immediate = 1,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 1,

        groupcaps = {
            crumbly = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 10, maxlevel = 1},
            snappy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
            cracky = {times = {[1]=20, [2]=15, [3]=10}, uses = 10, maxlevel = 1},
            choppy = {times = {[1]=30, [2]=25, [3]=20}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.1, y = 0, z = 0.1}
        --rot = {x = 0, y = 0, z = -110}
    },
     wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:stoneadze", {
    description = "Enxó de Pedra\nAlcance: +2\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "stoneadze.obj",
    tiles = {"stoneadze.png"}, 
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    range = 5,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 1,

        groupcaps = {
            choppy = {times = {[1]=20, [2]=15, [3]=10.00}, uses = 10, maxlevel = 1},
            snappy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.50, [2]=1.10, [3]=0.70}, uses = 10, maxlevel = 1},
        },

        damage_groups = {fleshy = 3},
    },
    
        -- bater em node / transformar em terra arada
node_placement_prediction = "",

on_place = function(itemstack, puncher, pointed_thing)
    local controls = puncher:get_player_control()
    
    if controls.sneak then
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = core.get_node(pos)
            
            -- Mapeamento: tora -> madeira
            local conversions = {
                ["nh_nodes:oaklog"]  = "nh_nodes:oakwood",
                ["nh_nodes:pinelog"] = "nh_nodes:pinewood",
            }
            
            local result = conversions[node.name]
            if result then
                core.set_node(pos, {name = result})
                local wear = itemstack:get_wear()
                itemstack:set_wear(wear + 4369)
            end
        end
        return itemstack
    else
        return core.item_place(itemstack, puncher, pointed_thing)
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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.1, y = 0, z = 0.1}
        --rot = {x = 0, y = 0, z = -110}
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

core.register_node("nh_nodes:stonehoe", {
    description = "Enxada de Pedra\nAlcance: +2\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "stonehoe.obj",
    tiles = {"stonehoe.png"}, 
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    range = 5,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        dig_immediate = 1,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 1,

        groupcaps = {
            choppy = {times = {[1]=20, [2]=15, [3]=10.00}, uses = 10, maxlevel = 1},
            snappy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.50, [2]=1.10, [3]=0.70}, uses = 10, maxlevel = 1},
        },

        damage_groups = {fleshy = 3},
    },
    
    -- bater em node / transformar em terra arada
node_placement_prediction = "",

on_place = function(itemstack, puncher, pointed_thing)
    local controls = puncher:get_player_control()
    
    if controls.sneak then
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = core.get_node(pos)
            local convertible = {
                ["nh_nodes:dirt"]     = true,
                ["nh_nodes:grass"]    = true,
                ["nh_nodes:top_grass"] = true,
            }
            if convertible[node.name] then
                core.set_node(pos, {name = "nh_nodes:tilleddirt"})
                local wear = itemstack:get_wear()
                wear = wear + 4369
                itemstack:set_wear(wear)
            end
        end
        return itemstack  -- Sempre cancela o place quando agachado
    else
        return core.item_place(itemstack, puncher, pointed_thing)
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
    --after_punch = function(itemstack, user, target)
    --    local wear = itemstack:get_wear()
   --     wear = wear + 4369
   --     itemstack:set_wear(wear)
   --     return itemstack
    --end,

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.25, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.075, -0.5, -0.03, 0.075, 0.25, 0.03},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.1, y = 0, z = 0.1}
        --rot = {x = 0, y = 0, z = -110}
    },
    wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


---------------------------
-- NODE DA PEDRA LASCADA (FERRAMENTA E ITEM DE FERRAMENTA)
---------------------------
core.register_node("nh_nodes:chippedstoneknife", {
    description = "Faca de Pedra Lascada\nAlcance: +1\nDano: +2\nUsos: 15",
    drawtype = "mesh",
    mesh = "chippedstoneknife.obj",
    tiles = {"chippedstoneknife.png"}, 
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    range = 4,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        --fleshy = 1, -- mobs, carne
        --snappy  = 2, -- folhas, plantas
        --crumbly = 3, -- terra, areia, argila
        oddly_breakable_by_hand = 3,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.05, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.075, -0.5, -0.03, 0.075, 0.05, 0.03},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.1, y = 0, z = 0.1}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


core.register_node("nh_nodes:obsidianknife", {
    description = "Faca de Obsidiana\nAlcance: +1\nDano: +4\nUsos: 10",
    drawtype = "mesh",
    mesh = "obsidianknife.obj",
    tiles = {"obsidianknife.png"}, 
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,

    range = 4,

    -- falling_node faz ele cair,
    -- attached_node previne ficar flutuando encostado
    groups = {
        --fleshy = 1, -- mobs, carne
        --snappy  = 2, -- folhas, plantas
        --crumbly = 3, -- terra, areia, argila
        oddly_breakable_by_hand = 3,
        falling_node = 1,
    },
 
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,

        groupcaps = {
            snappy = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 10, maxlevel = 1},
            fleshy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 10, maxlevel = 1},
            crumbly = {times = {[1]=1.40, [2]=1.00, [3]=0.60}, uses = 10, maxlevel = 1},
        },

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

    collision_box = {
        type = "fixed",
        fixed = {
            {-0.08, -0.5, -0.035, 0.08, 0.05, 0.035},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.075, -0.5, -0.03, 0.075, 0.05, 0.03},
    },
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 1.1, y = 0, z = 0.1}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


---------------------------
-- FUNÇÃO DE ARREMESSO (SEIXO branco)
---------------------------
local function throw_white_pebble(itemstack, user)
    local pos = user:get_pos()
    local dir = user:get_look_dir()
    pos.y = pos.y + 2.25
    local obj = core.add_entity(pos, "nh_nodes:white_pebble_entity")
    if obj then
        obj:set_velocity(vector.multiply(dir, 13))
        obj:set_acceleration({x = 0, y = -9.81, z = 0})
        local ent = obj:get_luaentity()
        if ent then
            ent._shooter = user
        end
    end
    itemstack:take_item()
    return itemstack
end

---------------------------
-- ITEM ARREMESSÁVEL (SEIXO branco)
---------------------------
core.register_craftitem("nh_nodes:white_pebble_item", {
    description = "Seixo Branco\n[Arremessável]\nDano: +1\n(Arremesso: Q / dropar)",
    inventory_image = "white_seixo_arremessavel.png", -- Use uma textura diferente

    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            cracky = {times = {[2] = 2.0, [3] = 1.0}, uses = 20, maxlevel = 1},
            crumbly = {times = {[1] = 1.5, [2] = 0.9, [3] = 0.5}, uses = 20, maxlevel = 1},
            snappy = {times = {[2] = 1.0, [3] = 0.5}, uses = 20, maxlevel = 1},
        },
        damage_groups = {fleshy = 2},
    },

    on_place = function(itemstack, placer, pointed_thing)
        return throw_white_pebble(itemstack, placer)
    end,
    
    on_drop = function(itemstack, dropper, pos)
        return throw_white_pebble(itemstack, dropper)
    end,
})

---------------------------
-- ENTIDADE DO PROJÉTIL (SEIXO branco)
---------------------------
core.register_entity("nh_nodes:white_pebble_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        visual = "wielditem",
        visual_size = {x = 0.2, y = 0.2},
        textures = {"nh_nodes:white_pebble"},
    },
    
    _stuck = false,
    _timer = 0,
    _stuck_timer = 0,
    _last_pos = nil,
    _shooter = nil,  -- ✅ Declarado aqui para ficar visível

    on_activate = function(self, staticdata)
        self._timer = 0
        self._stuck = false
        self._stuck_timer = 0
        self._shooter = nil
    end,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then
            self.object:remove()
            return
        end

        -- Timer geral para remover após muito tempo
        self._timer = self._timer + dtime
        if self._timer > 60 then
            self.object:remove()
            return
        end

        -- Se já está grudado
        if self._stuck then
            self._stuck_timer = self._stuck_timer + dtime

            -- Após 0.1 segundo grudado, vira node
            if self._stuck_timer >= 0.1 then
                local node_pos = vector.round(pos)
                local node = core.get_node(node_pos)

                if node.name == "air" or not core.registered_nodes[node.name].walkable then
                    core.set_node(node_pos, {name = "nh_nodes:white_pebble"})
                else
                    local offsets = {
                        {x=0, y=1, z=0},
                        {x=0, y=-1, z=0},
                        {x=1, y=0, z=0},
                        {x=-1, y=0, z=0},
                        {x=0, y=0, z=1},
                        {x=0, y=0, z=-1},
                    }

                    local placed = false
                    for _, offset in ipairs(offsets) do
                        local try_pos = vector.add(node_pos, offset)
                        local try_node = core.get_node(try_pos)
                        if try_node.name == "air" then
                            core.set_node(try_pos, {name = "nh_nodes:white_pebble"})
                            placed = true
                            break
                        end
                    end

                    if not placed then
                        core.add_item(pos, "nh_nodes:white_pebble_item")
                    end
                end

                self.object:remove()
            end
            return
        end

        local vel = self.object:get_velocity()
        if not vel then
            self.object:remove()
            return
        end

        local speed = vector.length(vel)

        -- Se a velocidade é muito baixa (parou de se mover)
        if speed < 0.5 then
            self._stuck = true
            self.object:set_velocity({x=0, y=0, z=0})
            self.object:set_acceleration({x=0, y=0, z=0})
            return
        end

        -- Verifica colisão com blocos sólidos via raycast manual
        local step_dir = vector.normalize(vel)
        local check_distance = math.min(speed * dtime * 2, 1)
        local steps = math.ceil(check_distance / 0.2)

        for i = 1, steps do
            local check_pos = vector.add(pos, vector.multiply(step_dir, i * 0.2))
            local node = core.get_node(check_pos)

            if node and node.name and core.registered_nodes[node.name] then
                if core.registered_nodes[node.name].walkable then
                    self._stuck = true
                    self.object:set_pos(check_pos)
                    self.object:set_velocity({x=0, y=0, z=0})
                    self.object:set_acceleration({x=0, y=0, z=0})
                    return
                end
                if node.name == "nh_nodes:coconutlinked" then
                    core.sound_play("default_dig_cracky", {pos = check_pos, gain = 0.5})
                    core.set_node(check_pos, {name = "nh_nodes:coconut"})
                    update_neighbors(check_pos)
                    return
                end
            end
        end

        -- ✅ Raio aumentado de 0.6 para 1.2 para não passar pelo mob
        local objs = core.get_objects_inside_radius(pos, 1.2)
        for _, obj in ipairs(objs) do
            -- Ignora o próprio projétil e o atirador
            if obj ~= self.object and obj ~= self._shooter then

                local is_target = obj:is_player()

                if not is_target then
                    local ent = obj:get_luaentity()
                    -- ✅ Usa get_hp() no lugar de ent.hp_max, compatível com MobsRedo
                    if ent and ent.name ~= "nh_nodes:white_pebble_entity" then
                        local hp = obj:get_hp()
                        if hp and hp > 0 then
                            is_target = true
                        end
                    end
                end

                if is_target then
                    core.log("action", "[Seixo Branco] Acertou alvo em " .. core.pos_to_string(pos))

                    core.sound_play("default_dig_cracky", {pos = pos, gain = 0.5})

                    obj:punch(self.object, 1.0, {
                        full_punch_interval = 1.0,
                        damage_groups = {fleshy = 2},
                    }, vel)

                    core.add_item(pos, "nh_nodes:white_pebble_item")
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
---------------------------
core.register_entity("nh_nodes:flame_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        selectionbox = {-0.5, 0, -0.5, 0.5, 1.5, 0.5},
        collisionbox = {-0.5, 0, -0.5, 0.5, 1.5, 0.5},
        visual = "mesh",
        mesh = "flame.obj",
        textures = {"fire_basic_flame_animated.png"},
        visual_size = {x = 5, y = 5},
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
            local data = core.deserialize(staticdata)
            if data and data.grass_pos then
                self._grass_pos = data.grass_pos
            end
        end
        self._timer = 0
        
        -- Configura a animação da textura
        self.object:set_sprite(
            {x = 0, y = 0}, -- Posição inicial
            1,              -- Número de frames (colunas)
            1.0,            -- Duração do frame
            false           -- Não usar alpha
        )
        
        -- Define a animação de textura
        self.object:set_texture_mod("^[verticalframe:8:0")
    end,
    
    get_staticdata = function(self)
        return core.serialize({grass_pos = self._grass_pos})
    end,
    
        -- NOVO: Detecta quando é golpeado
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then
            return
        end
        
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
                    core.add_item(pos, leftover)
                end
            end
            
            -- Efeito sonoro (opcional)
            core.sound_play("fire_flint_and_steel", {
                pos = self.object:get_pos(),
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
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
            
            if not self._grass_pos then
                self.object:remove()
                return
            end
            
            local node = core.get_node(self._grass_pos)
            
            -- Se a grama foi removida, remove a chama
            if node.name ~= "nh_nodes:grassleaves" then
                self.object:remove()
                return
            end
        end
    end,
})


---------------------------
-- NODE DO SEIXO BRANCO NO CHÃO
---------------------------
core.register_node("nh_nodes:white_pebble", {
    description = "Seixo branco",
    tiles = {"whitepebble.png"},
    inventory_image = "seixo_branco.png",
    wield_image = "seixo_branco.png",
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {
        snappy = 3,
        oddly_breakable_by_hand = 3,
        falling_node = 1,
        attached_node = 1,
    },
    node_box = {
        type = "fixed",
        fixed = {
            {-0.15, -0.5, -0.2, 0.15, -0.4, 0.15},
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.2, 0.15, -0.4, 0.15},
    },
    drop = "nh_nodes:white_pebble_item",
    
    on_construct = function(pos)
        core.check_for_falling(pos)
    end,
    
    after_place_node = function(pos)
        core.check_for_falling(pos)
    end,
    
    -- Quando bater em um seixo branco com outro seixo branco
    on_punch = function(pos, node, puncher, pointed_thing)
    if not puncher then return end
    
    -- Verifica se está batendo com outro seixo branco
    local wielded = puncher:get_wielded_item()
    if wielded:get_name() ~= "nh_nodes:white_pebble_item" then
        return
    end
    
    -- Som de fricção/faísca
    core.sound_play("default_dig_cracky", {
        pos = pos,
        gain = 0.7,
    })
    
    -- PARTÍCULAS AMARELAS LUMINOSAS (FAÍSCAS)
    core.add_particlespawner({
        amount = 10,  -- Quantidade de partículas
        time = 0.3,   -- Duração do spawn
        minpos = vector.subtract(pos, {x=0.2, y=0.2, z=0.2}),
        maxpos = vector.add(pos, {x=0.2, y=0.2, z=0.2}),
        minvel = {x=-2, y=1, z=-2},  -- Velocidade mínima
        maxvel = {x=2, y=4, z=2},      -- Velocidade máxima (para cima)
        minacc = {x=0, y=-3, z=0},     -- Aceleração (gravidade)
        maxacc = {x=0, y=-2, z=0},
        minexptime = 0.1,  -- Tempo mínimo de vida
        maxexptime = 0.3,  -- Tempo máximo de vida
        minsize = 0.1,     -- Tamanho mínimo
        maxsize = 0.3,     -- Tamanho máximo
        collisiondetection = true,
        collision_removal = false,
        glow = 14,  -- Brilho máximo (importante para o efeito luminoso)
        texture = {
            name = "spark_particle.png^[colorize:#FFAA00:150",  -- Dourado
            -- Se não tiver a textura spark_particle.png, use:
            -- name = "default_item_smoke.png^[colorize:#FFFF00:200",
        },
    })
    
    -- Verifica todas as direções adjacentes para acender grama
    local directions = {
        {x = 1, y = 0, z = 0},   -- Leste
        {x = -1, y = 0, z = 0},  -- Oeste
        {x = 0, y = 1, z = 0},   -- Cima
        {x = 0, y = -1, z = 0},  -- Baixo
        {x = 0, y = 0, z = 1},   -- Sul
        {x = 0, y = 0, z = -1},  -- Norte
        {x = 0, y = 1, z = 1},
        {x = 0, y = -1, z = -1},
        {x = 1, y = 0, z = 1},
        {x = -1, y = 0, z = -1},
        {x = -1, y = 0, z = 1},
        {x = 1, y = 0, z = -1},
    }
    
    for _, dir in ipairs(directions) do
            local check_pos = vector.add(pos, dir)
            local check_node = core.get_node(check_pos)
            
            -- ACENDE GRAMA
            if check_node.name == "nh_nodes:grassleaves" then
                local has_flame = false
                local objs = core.get_objects_inside_radius(check_pos, 0.5)
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:flame_entity" then
                        has_flame = true
                        break
                    end
                end
                
                if not has_flame then
                    local flame_pos = {
                        x = check_pos.x,
                        y = check_pos.y,
                        z = check_pos.z
                    }
                    
                    local obj = core.add_entity(flame_pos, "nh_nodes:flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then
                            ent._grass_pos = check_pos
                        end
                    end
                end
            end
            
            -- ACENDE PALHA
            if check_node.name == "nh_nodes:palmstraw" then
                local meta = core.get_meta(check_pos)
                
                -- Se a palha já tem chama, não faz nada
                if meta:get_int("has_flame") == 1 then
                    goto continue
                end
                
                -- Verifica se já não tem uma chama nessa posição
                local has_flame = false
                local objs = core.get_objects_inside_radius(check_pos, 0.5)
                for _, obj in ipairs(objs) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == "nh_nodes:palmstraw_flame_entity" then
                        has_flame = true
                        break
                    end
                end
                
                if not has_flame then
                    -- Marca que tem chama
                    meta:set_int("has_flame", 1)
                    
                    -- Cria a entidade da chama
                    local obj = core.add_entity(check_pos, "nh_nodes:palmstraw_flame_entity")
                    if obj then
                        local ent = obj:get_luaentity()
                        if ent then
                            ent._straw_pos = check_pos
                        end
                    end
                    
                    -- Efeito sonoro (opcional)
                    core.sound_play("fire_flint_and_steel", {
                        pos = check_pos,
                        gain = 0.5,
                        max_hear_distance = 8,
                    }, true)
                end
            end
            
            ::continue::
        end
    end,
})

---------------------------
-- NODE DAS FOLHAS DE GRAMA
---------------------------
core.register_node("nh_nodes:grassleaves", {
    --drawtype = "mesh",
    --mesh = "grassleaves.obj",
    --tiles = {"grassleaves.png"},
        drawtype = "plantlike",
        tiles = {"grassleavesbasic.png"},
        
    waving = 1,
    
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
    },
    
        -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then
            return
        end
        
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = core.get_meta(pos)
        
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then
            return
        end
        
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            
            -- Cria a entidade da chama
            local obj = core.add_entity(pos, "nh_nodes:flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then
                    ent._grass_pos = pos
                end
            end
            
            -- Efeito sonoro (opcional)
            core.sound_play("fire_flint_and_steel", {
                pos = pos,
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
        end
    end,
    
    -- Quando a grama for removida, remove as chamas nela
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = core.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:flame_entity" then
                obj:remove()
            end
        end
    end,
})


---------------------------
-- NODE DAS FOLHAS DE GRAMA
---------------------------
core.register_node("nh_nodes:grassleavesmedium", {
    description = "Folhas de grama media",
    --drawtype = "mesh",
    --mesh = "grassleavesmedium.obj",
    --tiles = {"grama.png"},
        drawtype = "plantlike",
        tiles = {"grassleavesbasic2.png"},
    
    waving = 1,
    
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
    },
    
        -- Quando a palha é atingida com tocha
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher or not puncher:is_player() then
            return
        end
        
        local wielded = puncher:get_wielded_item()
        local wielded_name = wielded:get_name()
        local meta = core.get_meta(pos)
        
        -- Se já tem chama, não faz nada
        if meta:get_int("has_flame") == 1 then
            return
        end
        
        -- Verifica se está segurando uma tocha acesa
        if wielded_name == "nh_nodes:torch2" or wielded_name == "nh_nodes:flame" then
            -- Marca que tem chama
            meta:set_int("has_flame", 1)
            
            -- Cria a entidade da chama
            local obj = core.add_entity(pos, "nh_nodes:flame_entity")
            if obj then
                local ent = obj:get_luaentity()
                if ent then
                    ent._grass_pos = pos
                end
            end
            
            -- Efeito sonoro (opcional)
            core.sound_play("fire_flint_and_steel", {
                pos = pos,
                gain = 0.5,
                max_hear_distance = 8,
            }, true)
        end
    end,
    
    -- Quando a grama for removida, remove as chamas nela
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local objs = core.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "nh_nodes:flame_entity" then
                obj:remove()
            end
        end
    end,
})

---------------------------
-- NODE DAS FLORES DE DENTE DE LEAO
---------------------------
core.register_node("nh_nodes:dandelion", {
    description = "Dente-de-leão",
    drawtype = "mesh",
    mesh = "dandelion.obj",
    tiles = {"dandelion.png"},
    
    --waving = 1,
    
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
    },
    
})


---------------------------
-- NODE DE JUNCO
---------------------------
core.register_node("nh_nodes:rush", {
    description = "Junco",
        drawtype = "plantlike",
        tiles = {"rushplant.png"},
    
    waving = 1,
    
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
    },
    
})

---------------------------
-- NODE DO COGUMELO MICACEUS
---------------------------
core.register_node("nh_nodes:micaceusfungus", {
    description = "Cogumelo Micaceus",
    drawtype = "mesh",
    mesh = "micaceusfungus.obj",
    tiles = {"micaceusfungus.png"},
    
    --waving = 1,
    
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
    },
    
        -- Tornar não comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, -2)  -- retira 2 pontos de fome
        apply_poison_damage(user, 0.5, 1, 1.0)  -- 0.5 de dano a cada 1 segundo = 4 ticks para completar 2 pontos
        itemstack:take_item()
        return itemstack
    end,
})

---------------------------
-- NODE DO COGUMELO AMANITA (VERMELHO)
---------------------------
core.register_node("nh_nodes:flyamanitafungus", {
    description = "Cogumelo Agário-das-Moscas",
    drawtype = "mesh",
    mesh = "flyagaricfungus.obj",
    tiles = {"flyagaricfungus.png"},
    
    --waving = 1,
    
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, oddly_breakable_by_hand = 1, flammable = 2},
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
    },
    
    
    -- Tornar não comestível
    on_use = function(itemstack, user, pointed_thing)
        restore_hunger(user, -4)  -- retira 4 pontos de fome
        apply_poison_damage(user, 1, 2, 1.0)  -- 1 ponto de dano a cada 1 segundo = 4 ticks para completar 4 pontos
        itemstack:take_item()
        return itemstack
    end,
})

------------------------------------------------------------
-- EXEMPLO: REGISTRAR ITENS DE VESTUÁRIO (tá como tool por enquanto)
------------------------------------------------------------

-- Cinto
core.register_node("nh_nodes:belt", {
    description = "Cinto Básico",
    inventory_image = "belt_icon.png",
    --wield_image = "belt_icon2.png",
    drawtype = "mesh",
    mesh = "belt.obj",
    tiles = {"belt_overlay.png"},
    groups = {oddly_breakable_by_hand = 1, armor_waist = 1},
    stack_max = 1,  -- limita a 1 por slot

    paramtype = "light",
    paramtype2 = "facedir",

    node_box = {
        type = "fixed",
        fixed = {
            {-0.28, -0.5, -0.18, 0.28, -0.32, 0.18},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-0.28, -0.5, -0.18, 0.28, -0.32, 0.18},
    },
   
   
       -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.65}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})

-- Mochila
core.register_node("nh_nodes:backchest", {
    description = "Mochila Baú",
    drawtype = "mesh",
    mesh = "backchest.obj",
    tiles = {"BackChest.png"},
    --inventory_image = "bag_basic.png",
    groups = {snappy = 3, oddly_breakable_by_hand = 1, armor_back = 1},
    stack_max = 1,  -- limita a 1 por slot
    visual = "wielditem",
    visual_size = {x=0.5, y=0.5, z=0.5},
    paramtype = "light",
    paramtype2 = "facedir",
    
    -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.7}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
})


-- Exemplo de luvas gestuais
core.register_node("nh_nodes:likeglove", {
    description = "Luva legal",
    drawtype = "mesh",
    mesh = "likeglove.obj",
    tiles = {"likeglove.png"},
    stack_max = 1,  -- limita a 1 por slot
    
    paramtype = "light",
    paramtype2 = "facedir",
       
    groups = {
        armor_hands = 1,
        oddly_breakable_by_hand = 3,
        snappy = 3,
        fleshy = 5,
    },
        
    walkable = false,
    
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    
        -- Define posição customizada quando equipado
    armor_bone_position = {
        pos = {x = 0.9, y = 0, z = 0},  -- Ajuste Y para descer
        rot = {x = 0, y = -90, z = -90}     -- Ajuste Y para girar (90° = direita)
    },
})

-- Exemplo de luvas gestuais
core.register_node("nh_nodes:pointglove", {
    description = "Luva legal",
    drawtype = "mesh",
    mesh = "pointglove.obj",
    tiles = {"pointglove.png"},
    stack_max = 1,  -- limita a 1 por slot
    
    paramtype = "light",
    paramtype2 = "facedir",
       
    groups = {
        armor_hands = 1,
        oddly_breakable_by_hand = 3,
        snappy = 3,
        fleshy = 5,
    },
        
    walkable = false,
    
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    
        -- Define posição customizada quando equipado
    armor_bone_position = {
        pos = {x = 0.9, y = 0, z = 0},  -- Ajuste Y para descer
        rot = {x = 0, y = -90, z = -90}     -- Ajuste Y para girar (90° = direita)
    },
})

-- Exemplo de capacete
core.register_node("nh_nodes:copperhelmet", {
    description = "Capacete de Cobre",
    drawtype = "mesh",
    mesh = "helmet.obj",
    tiles = {"copperhelmet.png"},
    stack_max = 1,  -- limita a 1 por slot
    
    groups = {
        armor_head = 1,
        oddly_breakable_by_hand = 3,
        snappy = 3,
        fleshy = 5,
    },
    
    paramtype = "light",
    paramtype2 = "facedir",
    
        
    walkable = false,
    
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    
    -- Define posição customizada quando equipado
    armor_bone_position = {
        pos = {x = 0, y = 2.7, z = 0},  -- Ajuste Y para descer
        rot = {x = 0, y = -90, z = 0}     -- Ajuste Y para girar (90° = direita)
    },
    
    --armor_texture = "copperhelmet.png",
    --armor_groups = {fleshy = 5},  -- Proteção
})


-- Exemplo de armadura de tronco
core.register_node("nh_nodes:copperchestplate", {
    description = "Peitoral de Cobre",
    drawtype = "mesh",
    mesh = "chestplate.obj",
    tiles = {"copperchest.png"},
    stack_max = 1,  -- limita a 1 por slot
    
    paramtype = "light",
    paramtype2 = "facedir",
       
    groups = {
        armor_torso = 1,
        oddly_breakable_by_hand = 3,
        snappy = 3,
        fleshy = 5,
    },
        
    walkable = false,
    
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    
        -- Define posição customizada quando equipado
    armor_bone_position = {
        pos = {x = 0.6, y = 4.1, z = 0},  -- Ajuste Y para descer
        rot = {x = 0, y = -90, z = 0}     -- Ajuste Y para girar (90° = direita)
    },
})

-- Armadura de cintura
core.register_node("nh_nodes:fauld", {
    description = "Escarcelas de Cobre",
    drawtype = "mesh",
    mesh = "leggings.obj",
    tiles = {"copperlegging.png"},
    stack_max = 1,  -- limita a 1 por slot
    
    paramtype = "light",
    paramtype2 = "facedir",
       
    groups = {
        armor_waist = 1,
        oddly_breakable_by_hand = 3,
        snappy = 3,
        fleshy = 5,
    },
        
    walkable = false,
    
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    
        -- Define posição customizada quando equipado
    armor_bone_position = {
        pos = {x = 0.6, y = 2.1, z = 0},  -- Ajuste Y para descer
        rot = {x = 0, y = -90, z = 0}     -- Ajuste Y para girar (90° = direita)
    },
})

-- Exemplo de calças
core.register_node("nh_nodes:leggings", {
    description = "Calça de Cobre",
    drawtype = "mesh",
    mesh = "leggings.obj",
    tiles = {"copperlegging.png"},
    stack_max = 1,  -- limita a 1 por slot
    
    paramtype = "light",
    paramtype2 = "facedir",
       
    groups = {
        armor_legs = 1,
        oddly_breakable_by_hand = 3,
        snappy = 3,
        fleshy = 5,
    },
        
    walkable = false,
    
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3}
    },
    
        -- Define posição customizada quando equipado
    armor_bone_position = {
        pos = {x = 0.6, y = 2.1, z = 0},  -- Ajuste Y para descer
        rot = {x = 0, y = -90, z = 0}     -- Ajuste Y para girar (90° = direita)
    },
})


-- Exemplo de botas
--core.register_node("nh_nodes:boots", {
--    description = "Botas Básicas",
--    inventory_image = "boots_basic.png",
--    groups = {armor_feet = 1},
--    stack_max = 1,  -- limita a 1 por slot
    
--    paramtype = "light",
--    paramtype2 = "facedir",
--})



-- ========================================
-- PORTA DE CARVALHO 3x1
-- ========================================

-- Porta fechada
core.register_node("nh_nodes:oakdoor_closed", {
    description = "Porta de Carvalho",
    drawtype = "mesh",
    mesh = "oakdoor_closed.obj",  -- Um único mesh 3x1
    tiles = {"oakwood3x1.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3, door = 1},
    --sounds = default.node_sound_wood_defaults(),
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.3}  -- 3 blocos de altura, fina
    },
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.3}
    },
    
            -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = 0.5, y = 0.5, z = 1.7}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
            -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -2, y = -0.9, z = 1.35}
        --rot = {x = 0, y = 0, z = -110}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 3, y = -1, z = 0.7},
        rot = {x = 0, y = 0, z = 90}
    },
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Abre a porta
        core.set_node(pos, {name="nh_nodes:oakdoor_open", param2=node.param2})
        core.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
    end,
})

-- Porta aberta
core.register_node("nh_nodes:oakdoor_open", {
    description = "Porta de Carvalho (Aberta)",
    drawtype = "mesh",
    mesh = "oakdoor_open.obj",  -- Mesmo mesh mas rotacionado/aberto
    tiles = {"oakwood3x1.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3, door = 1, not_in_creative_inventory = 1},
    drop = "nh_nodes:oakdoor_closed",
    --sounds = default.node_sound_wood_defaults(),
    
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.38, -0.375, 2.5, 0.63}  -- Porta na lateral quando aberta
    },
    
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.38, -0.375, 2.5, 0.63}  -- Colisão fina na lateral
    },
    
            -- Configuração mão direita
    wielded_bone_position = {
        pos = {x = -2, y = -1, z = 1.35},
        rot = {x = 0, y = -90, z = -90}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    -- Configuração mão esquerda
    offhand_bone_position = {
        pos = {x = 3, y = -1, z = -1.4},
        rot = {x = 0, y = 90, z = 90}
    },
    -- wielded_visual_size = {x = 0.25, y = 0.25, z = 0.25},
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Fecha a porta
        core.set_node(pos, {name="nh_nodes:oakdoor_closed", param2=node.param2})
        core.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
    end,
})






-----------------------------
-- GRIMÓRIO DE MATERIALIZAÇÃO
-----------------------------

local ITEMS_PER_PAGE = 40
local GRID_W = 8
local GRID_H = 5

local item_cache = {}

local function build_item_cache()
    if next(item_cache) then return end
    for name, def in pairs(core.registered_items) do
        if name ~= "" then
            table.insert(item_cache, name)
        end
    end
    table.sort(item_cache)
end

local function filter_items(search)
    build_item_cache()

    if search == "" or not search then
        return item_cache
    end

    local result = {}
    search = search:lower()

    for _, name in ipairs(item_cache) do
        if name:lower():find(search, 1, true) then
            table.insert(result, name)
        end
    end

    return result
end


function show_grimoire(player, page, search)
    page = page or 1
    search = search or ""

    local name = player:get_player_name()
    local items = filter_items(search)

    local max_page = math.max(1, math.ceil(#items / ITEMS_PER_PAGE))
    page = math.min(page, max_page)

    local start = (page - 1) * ITEMS_PER_PAGE + 1
    local fs = {
        "formspec_version[4]",
        "size[14,13]",
        "label[0.3,0.3;Grimório Completo de Materialização]",

        "field[0.3,0.9;6,0.8;search;;" .. core.formspec_escape(search) .. "]",
        "button[6.4,0.9;1.2,0.8;do_search;Buscar]",

        "button[8,0.9;1,0.8;prev;<]",
        "label[9.2,1.05;" .. page .. "/" .. max_page .. "]",
        "button[10.3,0.9;1,0.8;next;>]",
    }

    local x0, y0 = 0.3, 1.8
    local i = start

    for y = 0, GRID_H - 1 do
        for x = 0, GRID_W - 1 do
            if not items[i] then break end
            table.insert(fs,
                "item_image_button[" ..
                (x0 + x * 1.1) .. "," ..
                (y0 + y * 1.1) .. ";1,1;" ..
                items[i] .. ";item_" .. i .. ";]"
            )
            i = i + 1
        end
    end

    -- Inventário do jogador
    table.insert(fs, "list[current_player;main;1,8.6;8,2;8]")
    table.insert(fs, "list[current_player;main;1,11.3;8,1;]")
    table.insert(fs, "listring[current_player;main]")

    core.show_formspec(name, "nh_nodes:materialization", table.concat(fs))
end


core.register_node("nh_nodes:archion", {
    description = "Archion\nGrimório de Materialização\n(completo)\n[só ativa no criativo]",
    drawtype = "mesh",
    mesh = "grimorie.obj",
    tiles = {"grimorie.png"},
    
    -- Propriedades essenciais
    walkable = false,
    max_stake = 1,
    paramtype = "light",  -- Necessário para iluminação correta
    paramtype2 = "facedir",  -- IMPORTANTE: paramtype2, não paramtype
    
    -- Grupos para quebra manual
    groups = {
        snappy = 3,
        oddly_breakable_by_hand = 3,
        falling_node = 1,
    },
    
    -- Caixas de colisão e seleção
    collision_box = {
        type = "fixed",  -- Deve ser "fixed", não "facedir"
        fixed = {-0.1, -0.5, -0.1, 0.1, -0.45, 0.1}
    },
    selection_box = {
        type = "fixed",  -- Deve ser "fixed", não "facedir"
        fixed = {-0.375, -0.5, -0.5, 0.375, -0.25, 0.5}
    },

on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    local controls = player:get_player_control()
    
    if controls.aux1 then
        if not core.is_creative_enabled(player:get_player_name()) then
            core.chat_send_player(player:get_player_name(), "[O Archion só funciona no modo criativo]")
            return itemstack
        end
        show_grimoire(player, 1, "")
        return itemstack
    end
    
    if itemstack and not itemstack:is_empty() then
        local item_def = core.registered_items[itemstack:get_name()]
        
        if item_def and item_def.type == "node" then
            return core.item_place_node(itemstack, player, pointed_thing)
        end
        
        if item_def and item_def.on_place then
            local safe_pointed = {
                type = pointed_thing.type,
                under = pointed_thing.above,
                above = pointed_thing.above,
            }
            return item_def.on_place(itemstack, player, safe_pointed)
        end
    end
    
    if itemstack:is_empty() then
        core.chat_send_player(
            player:get_player_name(),
            "Preciso observar (segurar 'E' ou 'Aux1') e acessar ele (clicar 'colocar' de mãos vazias) para abrir o Grimório..."
        )
    end
    
    return itemstack
end,
})


local player_state = {}

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "nh_nodes:materialization" then return end

    local name = player:get_player_name()
    player_state[name] = player_state[name] or {page = 1, search = ""}

    local state = player_state[name]

    if fields.do_search then
        state.search = fields.search or ""
        state.page = 1
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
        if field:sub(1,5) == "item_" then
            local index = tonumber(field:sub(6))
            local items = filter_items(state.search)
            local item = items[index]
            if item then
                player:get_inventory():add_item("main", item)
            end
            return
        end
    end
end)

core.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    
    -- Cria a página escrita com o texto do tutorial
    local page = ItemStack("nh_items:writedpage")
    local meta = page:get_meta()
    meta:set_string("text", 
        "=== O NOVO HORIZONTE ===\n\n" ..
        "Guia geral:\n\n" ..
        "- Colete seixos no chão para produzir uma ferramenta\n" ..
        "- Alguns seixos criam faíscas ao bater um no outro\n" ..
        "- Tente produzir fogo espalhando faísca em algum material próximo\n" ..
        "- Acenda tochas usando elas em algum fogo\n" ..
        "- Ative a sua mente (Aux1 / E) e toque em blocos do chão para idealizar produções\n" ..
        "- As produções não dependem da disposição dos materiais, só quantidades\n" .. 
        "- Confira as outras páginas em caso de dúvida\n" .. 
        "- Há baús escondidos pelo mundo, mas não espere grandes recompensas\n" ..
        "- Dizem haver de um livro perdido chamado Archion que pode dar tudo o que esse mundo tem a oferecer\n" ..
        "- Alguém teria invocado o livro usando o seu poder criativo ilimitado entoando: '/grantme all' e '/giveme nh_nodes:archion'\n" ..
        "- Segundo a lenda, há também criaturas que só surgem em localidades específicas\n" ..
        "- Alguns tentaram fugir, mas não conseguiram, esse mundo não parece ter limites.\n\n" ..
        "Boa sorte...\n\n\n\n\n\n\n\n" ..
        "                                                                                     9"
    )
    
    -- Adiciona ao slot 1 da hotbar (slots 1-8 são a hotbar)
    inv:set_stack("main", 2, page)
end)
