minetest.log("action", "[base] Mod iniciado!")

minetest.register_node("nh_base:bloco_teste",
    { description = "Bloco de Teste", tiles = { "base_bloco_teste.png" }, groups = { cracky = 3 }, })

minetest.register_chatcommand("saudar",
    { description = "Saúda o jogador", func = function(name) return true, "Olá, " .. name .. "!" end, })
