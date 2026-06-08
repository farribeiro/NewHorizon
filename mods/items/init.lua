-- ITEMS
local c = core
c.log("action", "[items] init.lua loaded")
local S = c.get_translator("nh_items")
 -- table_xyz and table x=y=z
local function xyz(x, y, z) if y == nil and z == nil then y, z = x, x end return {x = x, y = y, z = z} end
-- Criar tabela namespace para o mod (no início do arquivo init.lua)
items = {}
-- Sessões de edição de página: player_name → { text = "" }
local editing_pages = {}
-- Limpa sessão ao deslogar
c.register_on_leaveplayer(function(player) editing_pages[player:get_player_name()] = nil end)
-- Itens necessários para escrever
c.register_craftitem("nh_items:feather", {
    description = S"Feather",
    inventory_image = "feather.png",
    wield_image = "feather.png",
    wield_scale = xyz(0.4, 0.4, 0.01),
    wielded_bone_position = {pos = xyz(0.9, 0, 0.1), rot = xyz(-90, 0, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(0.9, 0, -0.1), rot = xyz(90, 0, 0)},
})
-- Registro do item Página (em branco)
c.register_craftitem("nh_items:page", {
    description = S("Paper"),
    inventory_image = "page.png",
    wield_image = "page.png",
    wield_scale = xyz(0.5, 0.5, 0.01),
    wielded_bone_position = {pos = xyz(1, 0, 0.6), rot = xyz(90, 90, 0)}, -- Configuração mão direita
    offhand_bone_position = {pos = xyz(1, -0.5, -0.2)},
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end
        local player_name = user:get_player_name()
        local has_feather, has_ink = player_has_writing_tools(user)
        if not has_feather or not has_ink then
            local msg = S("I think I need ")
            if not has_feather and not has_ink then msg = msg .. S("a feather in the hotbar and an ink bottle in the inventory to write.")
            elseif not has_feather then msg = msg .. S("a feather in the hotbar to write.")
            else msg = msg .. S("an ink bottle in the inventory to write.")
            end
            c.chat_send_player(player_name, msg)
            return
        end
        -- Recupera rascunho da sessão, se existir
        local session = editing_pages[player_name]
        local draft = session and session.text or ""
        -- Mostrar formspec para escrever
        c.show_formspec(player_name, "nh_items:page_writer",
            "size[10,14.5]" ..
            "label[0.3,0;" .. S"Write on the Paper:" .. "]" ..
            "button_exit[8,0.1;2,0.8;close;" .. S"Close" .. "]" ..
            "textarea[0.3,1;10,14;page_text;;" .. c.formspec_escape(draft) .. "]" ..
            "button[3,13;2,1;save;" .. S"Save" .. "]" ..
            "button_exit[5,13;2,1;finish;" .. S"Finish" .. "]" ..
            "label[3.3,13.9;"  .. S"Save to avoid losing the draft" .. "]"
        )
        return itemstack
    end,
})
-- Registro do item Página escrita
c.register_craftitem("nh_items:writedpage", {
    description = S("Writed Paper"),
    inventory_image = "writedpage.png",
    wield_image = "writedpage.png",
    wield_scale = xyz(0.5, 0.5, 0.01),
    wielded_bone_position = {pos = xyz(1.1, 0, 0.9), rot = xyz(90, 90, 0)}, -- Configuração mão direita
    wielded_visual_size = xyz(0.25),
    offhand_bone_position = {pos = xyz(1.1, -0.5, -0.1)},
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end
        local player_name = user:get_player_name()
        local meta = itemstack:get_meta()
        local text = meta:get_string("text")
        if text == "" then text = S("Blank Paper") end
        c.show_formspec(player_name, "nh_items:page_reader",
            "size[10,13.5]" ..
            "textarea[0.3,0.3;10,14;page_text;;" ..
            c.formspec_escape(text) .. "]" ..
            "button_exit[4,12.5;2,1;close;" .. S"Close" .. "]")
        return itemstack
    end,
})
-- Callback do formspec para escrever na página
c.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "nh_items:page_writer" then return end
    local player_name = player:get_player_name()
    -- Persiste o texto na sessão sempre que ele chegar (inclusive no quit)
    if fields.page_text ~= nil then
        editing_pages[player_name] = editing_pages[player_name] or {}
        editing_pages[player_name].text = fields.page_text
    end
    -- Fechar sem ação: preserva rascunho na sessão para a próxima abertura
    if fields.quit or fields.close then return end
    -- SAVE: salva o rascunho e reabre o formspec com o texto preservado (sem consumir nada)
    if fields.save then
        local text = (editing_pages[player_name] and editing_pages[player_name].text) or ""
        if text == "" then c.chat_send_player(player_name, S("I didn't write anything!")) return end
        -- Reabre o formspec mantendo o texto
        c.show_formspec(player_name, "nh_items:page_writer",
            "size[10,14.5]" ..
            "label[0.3,0;" .. S"Write on the Paper:" .. "]" ..
            "button_exit[8,0.1;2,0.8;close;" .. S"Close" .. "]" ..
            "textarea[0.3,1;10,14;page_text;;" .. c.formspec_escape(text) .. "]" ..
            "button[3,13;2,1;save;" .. S"Save" .. "]" ..
            "button[5,13;2,1;finish;" .. S"Finish" .. "]" ..
            "label[3.3,13.9;" .. S"Save to avoid losing the draft" .. "]"
        )
        c.chat_send_player(player_name, S("Draft saved!"))
        return
    end
    -- FINISH: consome a página em branco e a tinta, cria a writedpage
    if fields.finish then
        local text = (editing_pages[player_name] and editing_pages[player_name].text) or ""
        if text == "" then c.chat_send_player(player_name, S"I didn't write anything!") return end
        -- Verificar novamente se tem os itens (para evitar exploits)
        local has_feather, has_ink = player_has_writing_tools(player)
        if not has_feather or not has_ink then c.chat_send_player(player_name, S"I no longer have the necessary items!") return end
        local inv = player:get_inventory()
        -- Procurar e remover uma página em branco do inventário
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if stack:get_name() == "nh_items:page" then
                stack:take_item(1)
                inv:set_stack("main", i, stack)
                consume_ink(player) -- Consumir tinta
                -- Criar página escrita
                local written_page = items.create_page_with_text(text)
                inv:add_item("main", written_page)
                editing_pages[player_name] = nil -- Limpa o rascunho
                c.chat_send_player(player_name, S"Paper written successfully!")
                return
            end
        end
        c.chat_send_player(player_name, S"I don't have a blank sheet of paper...")
        return
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
        S("The crystals shine in a strange way at night."),},
    recipe = {
        S("Oak gum was essential to keep the fire going. I used it, coconut leaf, grass and a stick to make torches."),
        S("To create a Crafting Table, I combined two ingots and two oak planks in the crafting grid."),
        S("I survived thanks to eggs I found, but I couldn't stand eating them raw anymore. I made a campfire with a fire starter made of coconut straw and oak gum, then placed oak logs in it and fried the eggs!"),},
    message = {
        S("If you're reading this, it means I didn't make it back."),
        S("Crafting useful things is a Specialty. Use the ground for that."),
        S("Find the straw tent and take whatever you want."),
        S("Beware of the depths. There is something down there."),
        S("The treasure is hidden where the sun never reaches."),
    },
}
