-- Arquivo: items/init.lua
-----------------------------
-- ITEMS
-----------------------------
core.log("action", "[items] init.lua carregado")

local S = minetest.get_translator("nh_items")

-- Criar tabela namespace para o mod (no início do arquivo init.lua)
items = {}


--[[
core.register_tool("nh_items:rustironsword", {
    description = "Espada de Ferro Enferrujado",
    --inventory_image = "blank.png",
    --wield_image = "blank.png",
    --inventory_image = "rustsword.png",
    --mesh = "models/rustsword.obj",
    --tiles = {"rustsword.png"},

    --wield_scale = {x=0.3, y=0.3, z=0.3},
    --wield_scale = {x = 0.325, y = 0.325, z = 0.325},

    --wield_image = "blank.png", -- opcional, evita sprite aparecer
    --wield_overlay = "rustsword.png",

    tool_capabilities = {
        full_punch_interval = 1.2,
        max_drop_level = 0,

        groupcaps = {
            fleshy = {times = {[1]=1.20, [2]=0.80, [3]=0.40}, uses = 30, maxlevel = 1},
            snappy = {times = {[1]=1.30, [2]=0.90, [3]=0.50}, uses = 30, maxlevel = 1},
        },

        damage_groups = {fleshy = 3},
    },
    
    on_place = function(itemstack, placer, pointed_thing)

        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local pos = pointed_thing.above

        core.set_node(pos, {name = "nh_nodes:rustironsword"})

        itemstack:take_item()
        return itemstack
    end,
})

core.register_entity("nh_items:wield_sword", {
    initial_properties = {
        visual = "mesh",
        mesh = "rustsword.obj",
        textures = {"rustsword.png"},
        visual_size = {x=5, y=5},
        physical = false,
        collide_with_objects = false,
        pointable = false,
        static_save = false,
    }
})

local wield_entities = {}

core.register_globalstep(function()

    for _, player in ipairs(core.get_connected_players()) do

        local name = player:get_player_name()
        local item = player:get_wielded_item():get_name()

        if item == "nh_items:rustironsword" then

            if not wield_entities[name] then
                local obj = core.add_entity(player:get_pos(), "nh_items:wield_sword")
                obj:set_attach(player, "bone_RHand", {x=1.5,y=0,z=0}, {x=0,y=-90,z=270})
                wield_entities[name] = obj
            end

        else

            if wield_entities[name] then
                wield_entities[name]:remove()
                wield_entities[name] = nil
            end

        end

    end

end)
]]--

--[[
core.register_craftitem("nh_items:stick", {
    description = "Graveto",
    inventory_image = "graveto.png",
    wield_image = "graveto.png",
    wield_scale = {x = 0.7, y = 0.7, z = 0.7},

    range = 5, -- AUMENTA O ALCANCE

    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times = {[3] = 1.00}, uses = 0},
            cracky  = {times = {[3] = 2.00}, uses = 0},
            snappy  = {times = {[3] = 0.80}, uses = 0},
            choppy  = {times = {[3] = 1.50}, uses = 0},
        },
        damage_groups = {fleshy = 1},
    },
})
]]--

-- Itens necessários para escrever
core.register_craftitem("nh_items:feather", {
    description = S("Feather"),
    inventory_image = "feather.png",
    wield_image = "feather.png",
    wield_scale = {x = 0.2, y = 0.2, z = 0.01},
})

--core.register_craftitem("nh_items:bottle", {
--    description = "Frasco",
--    inventory_image = "bottle.png",
--    wield_image = "bottle.png",
--    wield_scale = {x = 0.3, y = 0.3, z = 0.5},
--})

--core.register_craftitem("nh_items:inkbottle", {
--    description = "Frasco com tinta",
--    inventory_image = "inkbottle.png",
--    wield_image = "inkbottle.png",
--    wield_scale = {x = 0.3, y = 0.3, z = 0.5},
--})

--[[
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
    
    if inv:contains_item("main", "nh_items:inkbottle") then
        has_ink = true
    end
    
    return has_feather, has_ink
end

function writing_utils.consume_ink(player)
    local inv = player:get_inventory()
    inv:remove_item("main", "nh_items:inkbottle")
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
    if inv:contains_item("main", "nh_items:inkbottle") then
        has_ink = true
    end
    
    return has_feather, has_ink
end

function consume_ink(player)
    local inv = player:get_inventory()
    -- Remover um frasco de tinta
    inv:remove_item("main", "nh_items:inkbottle")
end
]]--

-- Registro do item Página (em branco)
core.register_craftitem("nh_items:page", {
    description = S("Paper"),
    inventory_image = "page.png",
    wield_image = "page.png",
    wield_scale = {x = 0.5, y = 0.5, z = 0.01},
    
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then
            return
        end
        
        local player_name = user:get_player_name()
        local has_feather, has_ink = player_has_writing_tools(user)
        
        if not has_feather or not has_ink then
	    local msg = S("I think I need ")
	    if not has_feather and not has_ink then
		msg = msg .. S("a feather in the hotbar and an ink bottle in the inventory to write.")
	    elseif not has_feather then
		msg = msg .. S("a feather in the hotbar to write.")
	    else
		msg = msg .. S("an ink bottle in the inventory to write.")
	    end
	    core.chat_send_player(player_name, msg)
	    return
	end
        
        -- Mostrar formspec para escrever
        core.show_formspec(player_name, "nh_items:page_writer",
            "size[8,6]" ..
            "label[0.3,0;" .. S("Write on the Paper:") .. "]" ..
            "textarea[0.3,0.5;8,4.5;page_text;;]" ..
            "button[2,5;2,1;save;" .. S("Save") .. "]" ..
            "button[4,5;2,1;cancel;" .. S("Cancel") .. "]"
        )
        
        return itemstack
    end,
})


-- Registro do item Página escrita
core.register_craftitem("nh_items:writedpage", {
    description = S("Writed Paper"),
    inventory_image = "writedpage.png",
    wield_image = "writedpage.png",
    wield_scale = {x = 0.5, y = 0.5, z = 0.01},
    stack_max = 1,
    
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then
            return
        end
        
        local player_name = user:get_player_name()
        local meta = itemstack:get_meta()
        local text = meta:get_string("text")
        
        if text == "" then
            text = S("Blank Paper")
        end
        
        core.show_formspec(player_name, "nh_items:page_reader",
            "size[8,6]" ..
            "textarea[0.3,0.3;8,5;page_text;;" .. core.formspec_escape(text) .. "]" ..
            "button_exit[3,5.3;2,1;close;" .. S("Close") .. "]"
        )
        
        return itemstack
    end,
})

-- Callback do formspec para escrever na página
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "nh_items:page_writer" then
        return
    end
    
    local player_name = player:get_player_name()
    
    if fields.cancel or fields.quit then
        return
    end
    
    if fields.save and fields.page_text then
        local text = fields.page_text
        
        if text == "" then
            core.chat_send_player(player_name, S("I didn't write anything!"))
            return
        end
        
        -- Verificar novamente se tem os itens (para evitar exploits)
        local has_feather, has_ink = player_has_writing_tools(player)
        if not has_feather or not has_ink then
            core.chat_send_player(player_name, S("I no longer have the necessary items!"))
            return
        end
        
        local inv = player:get_inventory()
        
        -- Procurar e remover uma página em branco do inventário
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if stack:get_name() == "nh_items:page" then
                -- Remover a página em branco
                stack:take_item(1)
                inv:set_stack("main", i, stack)
                
                -- Consumir tinta
                consume_ink(player)
                
                -- Criar página escrita
                local written_page = items.create_page_with_text(text)
                inv:add_item("main", written_page)
                
                core.chat_send_player(player_name, S("Paper written successfully!"))
                return
            end
        end
        
        core.chat_send_player(player_name, S("I don't have a blank sheet of paper..."))
    end
end)

-- Função auxiliar para criar páginas com texto pré-definido
function items.create_page_with_text(text)
    local itemstack = ItemStack("nh_items:writedpage")
    local meta = itemstack:get_meta()
    meta:set_string("text", text)
    meta:set_string("description", S("Paper: ") .. text:sub(1, 30) .. "...")
    return itemstack
end

-- Exemplo de diferentes tipos de páginas que podem ser geradas
page_texts = {
    diary = {
        S("Dear diary, today was an interesting day in the mines..."),
        S("I found a deep cave today. I'm not sure if I should explore it..."),
        S("The crystals shine in a strange way at night."),
    },
    recipe = {
        S("Oak gum was essential to keep the fire going. I used it, coconut leaf, grass and a stick to make torches."),
        S("To create a Crafting Table, I combined two ingots and two oak planks in the crafting grid."),
        S("I survived thanks to eggs I found, but I couldn't stand eating them raw anymore. I made a campfire with a fire starter made of coconut straw and oak gum, then placed oak logs in it and fried the eggs!"),
    },
    message = {
        S("If you're reading this, it means I didn't make it back."),
        S("Crafting useful things is a Specialty. Use the ground for that."),
        S("Find the straw tent and take whatever you want."),
        S("Beware of the depths. There is something down there."),
        S("The treasure is hidden where the sun never reaches."),
    },
}
