-- Arquivo: items/init.lua
-----------------------------
-- ITEMS
-----------------------------
core.log("action", "[items] init.lua carregado")

-- Criar tabela namespace para o mod (no início do arquivo init.lua)
items = {}


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

-- Itens necessários para escrever
core.register_craftitem("nh_items:feather", {
    description = "Pena",
    inventory_image = "feather.png",
    wield_image = "feather.png",
    wield_scale = {x = 0.2, y = 0.2, z = 0.01},
})

core.register_craftitem("nh_items:bottle", {
    description = "Frasco",
    inventory_image = "bottle.png",
    wield_image = "bottle.png",
    wield_scale = {x = 0.3, y = 0.3, z = 0.5},
})

core.register_craftitem("nh_items:inkbottle", {
    description = "Frasco com tinta",
    inventory_image = "inkbottle.png",
    wield_image = "inkbottle.png",
    wield_scale = {x = 0.3, y = 0.3, z = 0.5},
})

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
    description = "Página",
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
            local msg = "Você precisa de "
            if not has_feather and not has_ink then
                msg = msg .. "uma pena na hotbar e um frasco de tinta no inventário para escrever."
            elseif not has_feather then
                msg = msg .. "uma pena na hotbar para escrever."
            else
                msg = msg .. "um frasco de tinta no inventário para escrever."
            end
            core.chat_send_player(player_name, msg)
            return itemstack
        end
        
        -- Mostrar formspec para escrever
        core.show_formspec(player_name, "nh_items:page_writer",
            "size[8,6]" ..
            "label[0.3,0;Escrever na Página:]" ..
            "textarea[0.3,0.5;8,4.5;page_text;;]" ..
            "button[2,5;2,1;save;Salvar]" ..
            "button[4,5;2,1;cancel;Cancelar]"
        )
        
        return itemstack
    end,
})


-- Registro do item Página escrita
core.register_craftitem("nh_items:writedpage", {
    description = "Página escrita",
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
            text = "Página em branco"
        end
        
        core.show_formspec(player_name, "nh_items:page_reader",
            "size[8,6]" ..
            "textarea[0.3,0.3;8,5;page_text;;" .. core.formspec_escape(text) .. "]" ..
            "button_exit[3,5.3;2,1;close;Fechar]"
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
            core.chat_send_player(player_name, "Você não escreveu nada!")
            return
        end
        
        -- Verificar novamente se tem os itens (para evitar exploits)
        local has_feather, has_ink = player_has_writing_tools(player)
        if not has_feather or not has_ink then
            core.chat_send_player(player_name, "Você não tem mais os itens necessários!")
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
                
                core.chat_send_player(player_name, "Página escrita com sucesso!")
                return
            end
        end
        
        core.chat_send_player(player_name, "Você não tem uma página em branco!")
    end
end)

-- Função auxiliar para criar páginas com texto pré-definido
function items.create_page_with_text(text)
    local itemstack = ItemStack("nh_items:writedpage")
    local meta = itemstack:get_meta()
    meta:set_string("text", text)
    meta:set_string("description", "Página: " .. text:sub(1, 30) .. "...")
    return itemstack
end

-- Exemplo de diferentes tipos de páginas que podem ser geradas
page_texts = {
    diary = {
        "Querido diário, hoje foi um dia interessante nas minas...",
        "Encontrei uma caverna profunda hoje. Não sei se devo explorar...",
        "Os cristais brilham de forma estranha à noite.",
    },
    recipe = {
        "Receita secreta: Misture 3 nozes com mel selvagem.",
        "Para criar uma poção forte, combine ervas da montanha com água pura.",
        "O segredo está na temperatura: nunca deixe ferver!",
    },
    message = {
        "Se você está lendo isso, significa que eu não consegui voltar.",
        "Criar coisas úteis é uma Especialidade, Use o chão para isso", 
        "Encontre a tenda de palha e pegue o que quiser.",
        "Cuidado com as profundezas. Há algo lá embaixo.",
        "O tesouro está escondido onde o sol nunca alcança.",
    },
}
