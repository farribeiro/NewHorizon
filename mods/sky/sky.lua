-- Define a velocidade do tempo (dia) ao carregar o mod
minetest.settings:set("time_speed", "24")  -- Ciclo do dia em 1 hora, ao invés de 20 min

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
