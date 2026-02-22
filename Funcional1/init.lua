minetest.register_item(":", {
	type = "none", 
	wield_image = "base_bloco_teste.png", 
	wield_scale = {x = 1, y = 1, z = 1}, 
	tool_capabilities = { 
	full_punch_interval = 1.0, 
	max_drop_level = 0, 
	groupcaps = { 
		crumbly = {times = {[3] = 1.00}, uses = 0}, 
		cracky = {times = {[3] = 2.00}, uses = 0}, 
		snappy = {times = {[3] = 0.80}, uses = 0},
		choppy = {times = {[3] = 1.50}, uses = 0}, 
		}, 
		damage_groups = {fleshy = 1}, 
	  } 
	})

-----------------------------
-- CONFIGURAÇÕES DO MUNDO
-----------------------------
local MIN = -100
local MAX =  100
local SIZE = MAX - MIN + 1
local VOID_Y = -20  -- Altura mínima antes do teleporte de segurança

-----------------------------
-- NODES
-----------------------------
minetest.register_node("funcional1:grass", {
    description = "Grama",
    tiles = {"grama.png"},
    groups = {crumbly = 3},
})

minetest.register_node("funcional1:dirt", {
    description = "Terra",
    tiles = {"terra.png"},
    groups = {crumbly = 3},
})

minetest.register_node("funcional1:stone", {
    description = "Pedra",
    tiles = {"pedra.png"},
    groups = {cracky = 3},
})

minetest.register_node("funcional1:bedrock", {
    description = "Rocha Matriz",
    tiles = {"matriz.png"},
    groups = {cracky = 3}, --{unbreakable = 1, not_in_creative_inventory = 1},
    --drop = "",
})

minetest.register_node("funcional1:wood", {
    description = "Tronco",
    tiles = {"tronco.png"},
    groups = {choppy = 3},
})

minetest.register_node("funcional1:leaves", {
    description = "Folhas",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"folhas.png"},
    groups = {snappy = 3, leafdecay = 1},
})

minetest.register_node("funcional1:water", {
    description = "Água",
    drawtype = "liquid",
    tiles = {"agua.png"},
    special_tiles = {
        { name = "agua_animated.png", animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0} },
    },
    alpha = 160,
    paramtype = "light",
    walkable = false,
    liquidtype = "source",
    liquid_alternative_flowing = "funcional1:water_flowing",
    liquid_alternative_source = "funcional1:water",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=0, g=0, b=255},
    groups = {water=1, liquid=1},
})

minetest.register_node("funcional1:water_flowing", {
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
    alpha = 160,
    paramtype = "light",
    walkable = false,
    liquidtype = "flowing",
    liquid_alternative_flowing = "funcional1:water_flowing",
    liquid_alternative_source = "funcional1:water",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=0, g=0, b=255},
    groups = {water=1, liquid=1, not_in_creative_inventory=1},
})


local c_water = minetest.get_content_id("funcional1:water")

-----------------------------
-- DESATIVAR MAPGEN NATIVO
-----------------------------
minetest.set_mapgen_setting("mg_name", "singlenode", true)

-----------------------------
-- NOISES
-----------------------------
local noise_mountain = {
    offset = 0,
    scale = 9,
    spread = {x = 60, y = 60, z = 60},
    seed = 12345,
    octaves = 3,
    persist = 0.6,
}

local noise_trees = {
    offset = 0,
    scale = 0.6,
    spread = {x = 10, y = 10, z = 10},
    seed = 54321,
    octaves = 9,
    persist = 0.4,
}

----------------------------
-- ÁRVORE SIMPLES (Copa mais alta e mais volumosa)
-----------------------------
local function spawn_tree(area, data, pos, c_wood, c_leaves, wx, wz)


    -- RNG determinístico por posição
    local seed = wx * 73856093 + wz * 19349663
    local rng = PseudoRandom(seed)

    local height = rng:next(4, 7)
    local radius = rng:next(1, 2)
    local crown_radius = radius + rng:next(2, 3)

    -- =============== TRONCO ===============
    for y = 0, height do
        for dx = -radius, radius do
            for dz = -radius, radius do
                if dx * dx + dz * dz <= radius * radius + 0.2 then
                    data[area:index(pos.x + dx, pos.y + y, pos.z + dz)] = c_wood
                end
            end
        end
    end

    -- =============== COPA ===============
    local top = pos.y + height
    for dy = -2, 2 do
        for dx = -crown_radius, crown_radius do
            for dz = -crown_radius, crown_radius do
                if dx * dx + dz * dz + dy * dy <= (crown_radius + 1) ^ 2 then
                    data[area:index(pos.x + dx, top + dy, pos.z + dz)] = c_leaves
                end
            end
        end
    end

    -- Folha no topo
    data[area:index(pos.x, top + 3, pos.z)] = c_leaves
end

-----------------------------
-- REGISTRO DOS IDS
-----------------------------
local c_grass   = minetest.get_content_id("funcional1:grass")
local c_dirt    = minetest.get_content_id("funcional1:dirt")
local c_stone   = minetest.get_content_id("funcional1:stone")
local c_bedrock = minetest.get_content_id("funcional1:bedrock")
local c_wood    = minetest.get_content_id("funcional1:wood")
local c_leaves  = minetest.get_content_id("funcional1:leaves")

-----------------------------
-- GERAÇÃO DO MUNDO
-----------------------------
minetest.register_on_generated(function(minp, maxp)

    if maxp.y < -11 or minp.y > 30 then return end

    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(minp, maxp)
    local area = VoxelArea:new {MinEdge = emin, MaxEdge = emax}
    local data = vm:get_data()

    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do

            -- Coordenadas toroidais
            local wx = ((x - MIN) % SIZE) + MIN
            local wz = ((z - MIN) % SIZE) + MIN

            -- Altura do terreno
            local h = math.floor(minetest.get_perlin(noise_mountain):get2d({x = wx, y = wz}))

            -- Camadas básicas
            for y = -12, h do
                if y <= -10 then
                    data[area:index(x, y, z)] = c_bedrock
                elseif y <= h - 6 then
                    data[area:index(x, y, z)] = c_stone
                elseif y <= h - 1 then
                    data[area:index(x, y, z)] = c_dirt
                else
                    data[area:index(x, y, z)] = c_grass
                end
            end

            -- Árvores
            local noise_val = minetest.get_perlin(noise_trees):get2d({x = wx, y = wz})
            if noise_val > 0.65 then
                spawn_tree(area, data, {x = x, y = h + 1, z = z}, c_wood, c_leaves, wx, wz)

            end

        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-----------------------------
-- TELEPORTE TOROIDAL + NUVENS
-----------------------------
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        
        local p = player:get_pos()
        local old_p = {x=p.x, y=p.y, z=p.z} -- Para calcular deslocamento
        local moved = false

        -- Teleporte toroidal em X/Z
        if p.x > MAX + 3 then p.x = MIN + 2; moved = true end
        if p.x < MIN - 3 then p.x = MAX - 2; moved = true end
        if p.z > MAX + 3 then p.z = MIN + 2; moved = true end
        if p.z < MIN - 3 then p.z = MAX - 2; moved = true end

        -- Queda no void
        if p.y < VOID_Y then
            p.x = p.x - 10
            p.z = p.z - 10
            p.y = 10
            moved = true
        end

        -- Aplicar teleporte
        if moved then
            player:set_pos(p)

            -- Movimento relativo
            local dx = p.x - old_p.x
            local dz = p.z - old_p.z

            -- Ajuste das nuvens
            local clouds = player:get_clouds()
            if clouds then
                clouds.offset = clouds.offset or {x=0,y=0,z=0}
                clouds.offset.x = clouds.offset.x + dx - 2
                clouds.offset.z = clouds.offset.z + dz - 2
                player:set_clouds(clouds)
                
                        -- Voltar ao normal depois de 0.05s
                minetest.after(0.05, function()
                    if player and player:is_player() then
                        player:set_clouds(cloud_normal)
                    end
                end)
            end
        end
    end
end)

minetest.register_on_newplayer(function(player)
    -- Coloca o bloco de spawn primeiro
    minetest.set_node({x=0, y=9, z=0}, {name="funcional1:grass"})
    -- Coloca o jogador sobre o bloco
    player:set_pos({x=0, y=9, z=0})
    -- Zera a velocidade vertical para não cair
    local vel = player:get_velocity()
    player:set_velocity({x=vel.x, y=0, z=vel.z})
end)


minetest.after(1, function()
    minetest.set_node({x=0,y=9,z=0}, {name="funcional1:grass"})
end)

minetest.register_on_joinplayer(function(player)

    -- Aumenta o modelo do player (50% maior)
    player:set_properties({
        visual_size = {x = 1.5, y = 1.5}
    })

    -- Ajuste da hitbox para combinar com a nova altura
    player:set_properties({
        collisionbox = {
            -0.45, 0.0, -0.45,   -- 0.3 × 1.5
            0.45, 2.7, 0.45      -- 1.8 × 1.5 = 2.7
        }
    })

    -- Ajuste da selectionbox (onde o jogador é selecionado ao mirar)
    player:set_properties({
        selectionbox = {
            -0.45, 0.0, -0.45,
            0.45, 2.7, 0.45
        }
    })
end)

minetest.register_on_joinplayer(function(player)
    -- Hotbar com 1 slot
    player:hud_set_hotbar_itemcount(2)
end)
