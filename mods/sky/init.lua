minetest.log("action", "=== NH MOD DE CÉU CARREGADO ===")

minetest.register_on_joinplayer(function(player)
    player:set_clouds({
        density = 0.4,
        color = "#FFFFFFAA",
        ambient = "#888888",
        height = 120,
        thickness = 20,
        speed = {x = 2, z = 1},
    })
end)
