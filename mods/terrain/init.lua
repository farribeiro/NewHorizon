-----------------------------
-- CONFIGURAÇÕES DO MUNDO
-----------------------------
local MIN_XZ = config.MIN_XZ
local MAX_XZ = config.MAX_XZ
local VOID_Y = config.VOID_Y

local SIZE = MAX_XZ - MIN_XZ + 1

-----------------------------
-- DESATIVAR MAPGEN NATIVO
-----------------------------
core.set_mapgen_setting("mg_name", "singlenode", true)

-----------------------------
-- REGISTRO DOS IDS
-----------------------------
local c_ignore = core.CONTENT_IGNORE

local c_grass   = core.get_content_id("nh_nodes:grass")
local c_topgrass = core.get_content_id("nh_nodes:top_grass")
local c_grassleaves = core.get_content_id("nh_nodes:grassleaves")
local c_grassleavesmedium = core.get_content_id("nh_nodes:grassleavesmedium")
local c_rush = core.get_content_id("nh_nodes:rush")
local c_dandelion = core.get_content_id("nh_nodes:dandelion")
local c_micaceusfungus = core.get_content_id("nh_nodes:micaceusfungus")
local c_flyamanitafungus = core.get_content_id("nh_nodes:flyamanitafungus")
local c_dirt    = core.get_content_id("nh_nodes:dirt")
local c_pebble  = core.get_content_id("nh_nodes:pebble")
local c_whitepebble  = core.get_content_id("nh_nodes:white_pebble")
local c_sand    = core.get_content_id("nh_nodes:sand")
local c_wetsand = core.get_content_id("nh_nodes:wet_sand")
local c_saprolite = core.get_content_id("nh_nodes:saprolite")
local c_gneiss  = core.get_content_id("nh_nodes:gneiss")
local c_basalt = core.get_content_id("nh_nodes:basalt")
local c_magma = core.get_content_id("nh_nodes:magma")
local c_peridotite = core.get_content_id("nh_nodes:peridotite")
local c_bedrock = core.get_content_id("nh_nodes:bedrock")
local c_redrock = core.get_content_id("nh_nodes:redrock")
local c_oaktimber = core.get_content_id("nh_nodes:oaktimber")
local c_fallenstick = core.get_content_id("nh_nodes:fallenstick")
local c_appletimber = core.get_content_id("nh_nodes:appletimber")
local c_pinetimber = core.get_content_id("nh_nodes:pinetimber")
local c_pineleaves = core.get_content_id("nh_nodes:pineleaves")
local c_oakwood = core.get_content_id("nh_nodes:oakwood")
local c_oakplank = core.get_content_id("nh_nodes:oakplank")
local c_oakdowel = core.get_content_id("nh_nodes:oakdowel")
local c_oakchest = core.get_content_id("nh_nodes:oak_chest")
--local c_oakdoor = core.get_content_id("nh_nodes:oak_door")
local c_leaves  = core.get_content_id("nh_nodes:leaves")
local c_appleleaves  = core.get_content_id("nh_nodes:appleleaves")
local c_blueberryleaves = core.get_content_id("nh_nodes:blueberryleaves")
local c_leavesblueberry4  = core.get_content_id("nh_nodes:leaves_blueberry4")
local c_leaves_nut  = core.get_content_id("nh_nodes:leaves_nut")
local c_leaves_nut2 = core.get_content_id("nh_nodes:leaves_nut2")
local c_leaves_nut3 = core.get_content_id("nh_nodes:leaves_nut3")
local c_leavesapple  = core.get_content_id("nh_nodes:leaves_apple")
local c_leavesapple2 = core.get_content_id("nh_nodes:leaves_apple2")
local c_leavesapple3 = core.get_content_id("nh_nodes:leaves_apple3")
local c_palmtimber = core.get_content_id("nh_nodes:palmtimber")
local c_palmleafstalks = core.get_content_id("nh_nodes:palmleafstalks")
local c_palmleaf = core.get_content_id("nh_nodes:palmleaf")
local c_palmstraw = core.get_content_id("nh_nodes:palmstraw")
local c_coconut = core.get_content_id("nh_nodes:coconut")
local c_water   = core.get_content_id("nh_nodes:water")
local c_water2  = core.get_content_id("nh_nodes:water2")
local c_lava    = core.get_content_id("nh_nodes:lava")
local c_obsidian = core.get_content_id("nh_nodes:obsidian")
local c_snow    = core.get_content_id("nh_nodes:snow")
local c_ice    = core.get_content_id("nh_nodes:ice")

local c_coal      = core.get_content_id("nh_nodes:coal")
local c_copper    = core.get_content_id("nh_nodes:copper")
local c_tin       = core.get_content_id("nh_nodes:tin")
local c_iron      = core.get_content_id("nh_nodes:iron")
local c_nickel    = core.get_content_id("nh_nodes:nickel")
local c_manganese = core.get_content_id("nh_nodes:manganese")
local c_chromium  = core.get_content_id("nh_nodes:chromium")

local c_air     = core.CONTENT_AIR
print("[terrain] content_ids obtidos")

local entity_positions = {}
local tent_generated = false
local TENT_SEARCH_RADIUS = 256

local ship_generated = false
local SHIP_SEARCH_RADIUS = 256


-----------------------------
-- NOISES (mantidos para compatibilidade com funções antigas)
-----------------------------

local perlin_continent
local perlin_biome
local perlin_mountain
local perlin_hills
local perlin_plains
local perlin_roughness
local perlin_caves
local perlin_caves_lava
local perlin_caves_water
local perlin_cave_size
local perlin_grassleaves
local perlin_trees
local perlin_bushes
--local perlin_palms
local perlin_saprolite


-----------------------------
-- NOISES PARA MINÉRIOS (adicionar após os noises existentes)
-----------------------------
local perlin_ore_master
local perlin_coal
local perlin_copper
local perlin_tin
local perlin_iron
local perlin_nickel
local perlin_manganese
local perlin_chromium

-----------------------------
-- PERLIN MAPS (OTIMIZAÇÃO)
-----------------------------
local perlin_continent_map
local perlin_biome_map
local perlin_mountain_map
local perlin_hills_map
local perlin_plains_map
local perlin_roughness_map
local perlin_caves_map
local perlin_caves_lava_map
local perlin_caves_water_map
local perlin_cave_size_map
local perlin_grassleaves_map
local perlin_trees_map
local perlin_bushes_map
local perlin_saprolite_map
local perlin_ore_master_map

-----------------------------
-- CONFIGURAÇÃO DOS NOISES
-----------------------------
local noise_continent = {
    offset = 0,
    scale = 0.5,
    spread = {x = 300, y = 300, z = 300}, -- MUITO grande
    seed = 24680,
    octaves = 2,
    persist = 0.5,
}

local noise_mountain = {
    offset = 0,
    scale = 1,  
    spread = {x = 80, y = 80, z = 80},
    seed = 12345,
    octaves = 5,
    persist = 0.6,
}

local noise_hills = {
    offset = 0,
    scale = 0.5,
    spread = {x = 150, y = 150, z = 150},
    seed = 67890,
    octaves = 3,
    persist = 0.5,
}

local noise_plains = {
    offset = 0,
    scale = 0.5,
    spread = {x = 180, y = 180, z = 180},
    seed = 99999,
    octaves = 2,
    persist = 0.4,
}


local noise_caves = {
    offset = 0,
    scale = 1,
    spread = {x = 50, y = 20, z = 50},
    seed = 121212,
    octaves = 3,
    persist = 0.5,
}

-- Para cavernas de lava
local noise_caves_lava = {
    offset = 0,
    scale = 1,
    spread = {x = 40, y = 80, z = 40},   -- spread maior em Y = cavernas mais verticais
    seed = 424242,  -- seed diferente
    octaves = 3,
    persist = 0.5,
}

-- Para cavernas de água (seed diferente!)
local noise_caves_water = {
    offset = 0,
    scale = 1,
    spread = {x = 60, y = 30, z = 60},   -- spread menor em Y = cavernas mais horizontais
    seed = 777888,  -- outra seed DIFERENTE
    octaves = 3,
    persist = 0.5,
}

local noise_cave_size = {
    offset = 0,
    scale = 1,
    spread = {x = 50, y = 50, z = 50},  -- Varia o tamanho das cavernas por região
    seed = 131313,
    octaves = 2,
    persist = 0.4,
}


local noise_roughness = {
    offset = 0,
    scale = 0.5,
    spread = {x = 25, y = 25, z = 25},
    seed = 11111,
    octaves = 2,
    persist = 0.6,
}

local noise_biome = {
    offset = 0,
    scale = 0.5,
    spread = {x = 150, y = 150, z = 150},
    seed = 77777,
    octaves = 3,
    persist = 0.6,
}


local noise_saprolite = {
    offset = 0,
    scale = 1,
    spread = {x = 40, y = 40, z = 40},
    seed = 9876,
    octaves = 2,
    persist = 0.5,
    lacunarity = 2.0
}

local noise_grassleaves = {
    offset = 0,
    scale = 10,
    spread = {x = 20, y = 20, z = 20},  -- Spread maior = mais espaçadas (era 10)
    seed = 12312,
    octaves = 3,
    persist = 0.5,
}

local noise_trees = {
    offset = 0,
    scale = 0.6,
    spread = {x = 10, y = 10, z = 10},  -- Spread maior = mais espaçadas (era 10)
    seed = 54321,
    octaves = 3,
    persist = 0.5,
}

local noise_bushes = {
    offset = 0,
    scale = 0.6,
    spread = {x = 8, y = 8, z = 8},
    seed = 98765,
    octaves = 2,
    persist = 0.4,
}

--local noise_palms = {
--    offset = 0,
--    scale = 0.6,
--    spread = {x = 15, y = 15, z = 15},
--    seed = 33333,
--    octaves = 2,
--    persist = 0.4,
--}


-----------------------------
-- CONFIGURAÇÃO DOS NOISES DE MINÉRIOS
-----------------------------
local noise_ore_master = {
    offset = 0,
    scale = 1,
    spread = {x = 30, y = 30, z = 30},
    seed = 9130,
    octaves = 3,
    persist = 0.6,
    lacunarity = 2.0,
}


local noise_coal = {
    offset = 0,
    scale = 0.5,
    spread = {x = 30, y = 30, z = 30},
    seed = 19283,
    octaves = 3,
    persist = 0.6,
}

local noise_copper = {
    offset = 0,
    scale = 0.5,
    spread = {x = 35, y = 35, z = 35},
    seed = 28374,
    octaves = 3,
    persist = 0.6,
}

local noise_tin = {
    offset = 0,
    scale = 0.5,
    spread = {x = 32, y = 32, z = 32},
    seed = 37465,
    octaves = 3,
    persist = 0.6,
}

local noise_iron = {
    offset = 0,
    scale = 0.5,
    spread = {x = 28, y = 28, z = 28},
    seed = 46556,
    octaves = 3,
    persist = 0.6,
}

local noise_nickel = {
    offset = 0,
    scale = 0.5,
    spread = {x = 25, y = 25, z = 25},
    seed = 55647,
    octaves = 3,
    persist = 0.6,
}

local noise_manganese = {
    offset = 0,
    scale = 0.5,
    spread = {x = 22, y = 22, z = 22},
    seed = 64738,
    octaves = 3,
    persist = 0.6,
}

local noise_chromium = {
    offset = 0,
    scale = 0.5,
    spread = {x = 20, y = 20, z = 20},
    seed = 73829,
    octaves = 3,
    persist = 0.6,
}

-----------------------------
-- FUNÇÃO PARA VERIFICAR SE DEVE GERAR MINÉRIO
-----------------------------
local function check_ore(x, y, z, perlin_ore, threshold, min_y, max_y)
    -- Verifica se está na faixa de altura correta
    if y < min_y or y > max_y then
        return false
    end
    
    -- Noise 3D para criar veios
    local ore_noise = perlin_ore:get_3d({x = x, y = y, z = z})
    
    -- Normaliza para 0-1
    local ore_value = (ore_noise + 1) / 2
    
    -- Se o valor for maior que o threshold, gera o minério
    return ore_value > threshold
end





-----------------------------
-- FUNÇÃO PARA VERIFICAR SE HÁ ESPAÇO PARA A ÁRVORE
-----------------------------
local function can_place_tree(area, data, pos, radius)
    -- Verifica se há espaço ao redor da base da árvore
    for dx = -radius, radius do
        for dz = -radius, radius do
            local check_x = pos.x + dx
            local check_z = pos.z + dz
            
            -- Verifica se a posição está dentro do chunk
            if area:contains(check_x, pos.y, check_z) then
                local vi = area:index(check_x, pos.y, check_z)
                
                -- Se já tem madeira ou folhas, não pode colocar
                if data[vi] == c_oaktimber or data[vi] == c_leaves or data[vi] == c_palmtimber or data[vi] == c_palmleaf then
                    return false
                end
            end
        end
    end
    return true
end

-----------------------------
-- FUNÇÃO DE SPAWN DE COQUEIRO
-----------------------------
local function spawn_palm_tree(area, data, pos, wx, wz)
    -- Verifica se há espaço
    if not can_place_tree(area, data, pos, 3) then
        return
    end
    
    -- Verifica se há areia abaixo do ponto de spawn
    local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    if area:contains(below_pos.x, below_pos.y, below_pos.z) then
        local vi_below = area:index(below_pos.x, below_pos.y, below_pos.z)
        if data[vi_below] ~= c_sand then
            return  -- Cancela se não tiver areia embaixo
        end
    else
        return  -- Cancela se a posição abaixo não está no chunk
    end
    
    -- RNG determinístico por posição
    local seed = wx * 55555 + wz * 88888
    local rng = PseudoRandom(seed)
    
    -- Altura do tronco: 6 a 9 blocos
    local height = rng:next(6, 9)
    
    -- =============== TRONCO ===============
    for y = 0, height do
        local check_pos = {x = pos.x, y = pos.y + y, z = pos.z}
        
        if area:contains(check_pos.x, check_pos.y, check_pos.z) then
            local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
            if data[vi] == c_air then
                data[vi] = c_palmtimber
            end
        end
    end
    
    -- =============== PALMLEAFSTALKS NO TOPO DO TRONCO ===============
    local stalk_pos = {x = pos.x, y = pos.y + height + 1, z = pos.z}
    if area:contains(stalk_pos.x, stalk_pos.y, stalk_pos.z) then
        local vi = area:index(stalk_pos.x, stalk_pos.y, stalk_pos.z)
        if data[vi] == c_air then
            data[vi] = c_palmleafstalks
        end
    end
    
    -- Camadas das folhas
	local bottom_layer = pos.y + height + 1
	local top_layer    = pos.y + height + 2

	-- Direções em cruz
	local directions = {
	    {x = 0,  z = -1, rotation = 0}, -- Norte
	    {x = 1,  z =  0, rotation = 1}, -- Leste
	    {x = 0,  z =  1, rotation = 2}, -- Sul
	    {x = -1, z =  0, rotation = 3}, -- Oeste
	}

	-- Registro opcional de folhas (se você realmente usa isso depois)
	local leaf_nodes = {}

    
    -- =============== FOLHAS EM CRUZ - CAMADA INFERIOR ===============
	for _, dir in ipairs(directions) do
	    for i = 1, 3 do
		local leaf_pos = {
		    x = pos.x + dir.x * i,
		    y = bottom_layer,
		    z = pos.z + dir.z * i
		}

		if not area:contains(leaf_pos.x, leaf_pos.y, leaf_pos.z) then
		    break
		end

		local vi = area:index(leaf_pos.x, leaf_pos.y, leaf_pos.z)

		-- SE NÃO FOR AR → PARA ESSA DIREÇÃO
		if data[vi] ~= c_air then
		    break
		end

		-- Caso contrário, coloca a folha
		data[vi] = c_palmleaf
		table.insert(leaf_nodes, {
		    pos = {x = leaf_pos.x, y = leaf_pos.y, z = leaf_pos.z},
		    rotation = dir.rotation
		})
	    end
	end

    -- =============== FOLHAS EM CRUZ - CAMADA SUPERIOR ===============
	for _, dir in ipairs(directions) do
	    for i = 1, 2 do
		local leaf_pos = {
		    x = pos.x + dir.x * i,
		    y = top_layer,
		    z = pos.z + dir.z * i
		}

		if not area:contains(leaf_pos.x, leaf_pos.y, leaf_pos.z) then
		    break
		end

		local vi = area:index(leaf_pos.x, leaf_pos.y, leaf_pos.z)

		if data[vi] ~= c_air then
		    break
		end

		data[vi] = c_palmleaf
		table.insert(leaf_nodes, {
		    pos = {x = leaf_pos.x, y = leaf_pos.y, z = leaf_pos.z},
		    rotation = dir.rotation
		})
	    end
	end
    
    -- =============== COCOS (0 a 4 aleatórios) ===============
    local num_coconuts = rng:next(0, 4)
    
    -- Posições possíveis para cocos (embaixo das folhas da camada inferior)
    local possible_positions = {
        {x = pos.x + 1, y = bottom_layer - 1, z = pos.z},
        {x = pos.x - 1, y = bottom_layer - 1, z = pos.z},
        {x = pos.x, y = bottom_layer - 1, z = pos.z + 1},
        {x = pos.x, y = bottom_layer - 1, z = pos.z - 1},
    }
    
    -- Embaralha as posições
    for i = #possible_positions, 2, -1 do
        local j = rng:next(1, i)
        possible_positions[i], possible_positions[j] = possible_positions[j], possible_positions[i]
    end
    
    -- Coloca os cocos
    for i = 1, math.min(num_coconuts, #possible_positions) do
        local coco_pos = possible_positions[i]
        
        if area:contains(coco_pos.x, coco_pos.y, coco_pos.z) then
            local vi = area:index(coco_pos.x, coco_pos.y, coco_pos.z)
            if data[vi] == c_air then
                data[vi] = c_coconut
            end
        end
    end
    
    -- Retorna lista de folhas para rotacionar depois (via core.set_node)
    return leaf_nodes
end

-----------------------------
-- FUNÇÃO DE SPAWN DE ARBUSTO (só folhas)
-----------------------------
local function spawn_bush(area, data, pos, wx, wz)
    -- Verifica se há espaço (raio menor que árvores)
    if not can_place_tree(area, data, pos, 2) then
        return  -- Cancela se estiver muito perto
    end
    
    -- RNG determinístico por posição (seed diferente das árvores)
    local seed = wx * 91823 + wz * 45678
    local rng = PseudoRandom(seed)
    
    -- Altura do arbusto: 1 ou 2 blocos
    local height = rng:next(1, 2)
    
    -- Raio do arbusto: 1 a 3 blocos
    local radius = rng:next(1, 3)
    
    -- Contador para limitar substituições especiais
    local max_swaps = 2
    local swaps = 0
    
    -- =============== GERA ARBUSTO ESFÉRICO ===============
    for y = 0, height do
        for dx = -radius, radius do
            for dz = -radius, radius do
                -- Calcula distância do centro (formato mais orgânico)
                local dist = (dx * dx + (y * 0.8) * (y * 0.8) + dz * dz) --local dist = math.sqrt(dx * dx + (y * 0.8) * (y * 0.8) + dz * dz)
                
                -- Adiciona aleatoriedade nas bordas
                local randomness = rng:next(-10, 10) / 20.0  -- -0.5 a +0.5
                
                -- Se estiver dentro do raio (com variação)
                if dist <= (radius + randomness)*(radius + randomness) then
                    local check_pos = {
                        x = pos.x + dx,
                        y = pos.y + y,
                        z = pos.z + dz
                    }
                    
                    if area:contains(check_pos.x, check_pos.y, check_pos.z) then
                        local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
                        -- Só substitui ar
                        if data[vi] == c_air then
                            data[vi] = c_blueberryleaves
                            
                            -- Chance de substituir por folhas com blueberry
                            if swaps < max_swaps then
                                local r = rng:next(1, 100)  -- 1 a 100
                                -- Distribuição enviesada:
                                if r < 0.10 then  -- 10% de chance
                                    data[vi] = c_leavesblueberry4
                                    swaps = swaps + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-----------------------------
-- FUNÇÃO DE SPAWN DE CARVALHO (com variação de tronco)
-----------------------------
local function spawn_tree(area, data, pos, wx, wz)
    -- Verifica se há espaço (raio de 5 blocos)
    if not can_place_tree(area, data, pos, 5) then
        return  -- Cancela a geração se estiver muito perto de outra árvore
    end
    
    -- VERIFICAÇÃO: Verifica se há grama abaixo do ponto de spawn ***
    local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    if area:contains(below_pos.x, below_pos.y, below_pos.z) then
        local vi_below = area:index(below_pos.x, below_pos.y, below_pos.z)
        if data[vi_below] ~= c_topgrass and data[vi_below] ~= c_grass then
            return  -- Cancela se não tiver grama embaixo
        end
    else
        return  -- Cancela se a posição abaixo não está no chunk
    end
    
    -- RNG determinístico por posição
    local seed = wx * 73856093 + wz * 19349663
    local rng = PseudoRandom(seed)
    local height = rng:next(6, 9)
    local crown_radius = rng:next(3, 4)
    
    -- =============== DETERMINA TAMANHO DO TRONCO ===============
    local trunk_type = rng:next(2, 4)  -- Sorteava entre 1 e 4
    local trunk_dx, trunk_dz
    
    if trunk_type == 1 then
        -- 1x1 (tronco único)
        trunk_dx = 0
        trunk_dz = 0
    elseif trunk_type == 2 then
        -- 2x1 (retangular horizontal)
        trunk_dx = 1
        trunk_dz = 0
    elseif trunk_type == 3 then
        -- 1x2 (retangular vertical)
        trunk_dx = 0
        trunk_dz = 1
    else
        -- 2x2 (quadrado)
        trunk_dx = 1
        trunk_dz = 1
    end
    
    -- =============== TRONCO (tamanho variável) ===============
    for y = 0, height do
        for dx = 0, trunk_dx do
            for dz = 0, trunk_dz do
                local check_pos = {x = pos.x + dx, y = pos.y + y, z = pos.z + dz}
                
                if area:contains(check_pos.x, check_pos.y, check_pos.z) then
                    local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
                    -- Só substitui ar ou folhas
                    if data[vi] == c_air or data[vi] == c_leaves then
                        data[vi] = c_oaktimber
                    end
                end
            end
        end
    end
    
    -- =============== COPA (esférica) ===============
    local max_swaps = 3
    local swaps = 0
    
    local top = pos.y + height
    -- Ajusta centro da copa para troncos maiores
    local copa_center_x = pos.x + (trunk_dx / 2)
    local copa_center_z = pos.z + (trunk_dz / 2)
    
    for dy = -2, 3 do
        for dx = -crown_radius, crown_radius do
            for dz = -crown_radius, crown_radius do
                local dist = (dx * dx + dy * dy + dz * dz) -- local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                if dist <= (crown_radius + 0.5)*(crown_radius + 0.5) then
                    local check_pos = {
                        x = math.floor(copa_center_x + dx), 
                        y = top + dy, 
                        z = math.floor(copa_center_z + dz)
                    }
                    if area:contains(check_pos.x, check_pos.y, check_pos.z) then  
                        local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
			if data[vi] == c_air then
			    data[vi] = c_leaves
			    -- Chance de substituir por folhas especiais
			    -- (mais pressão para NÃO trocar → distribuição enviesada)
			    if swaps < max_swaps then
				local r = rng:next(1, 1000) / 1000.0  -- Gera 0.0 a 1.0
				-- Distribuição enviesada:
				-- 70% = não troca
				-- 20% = troca muito rara
				-- 10% = troca rara
				if r < 0.05 then
				    data[vi] = c_leaves_nut
				    swaps = swaps + 1
				elseif r < 0.1 then
				    data[vi] = c_leaves_nut2
				    swaps = swaps + 1
				elseif r < 0.15 then
				    data[vi] = c_leaves_nut3
				    swaps = swaps + 1
				end
			    end
			end
                    end
                end
            end
        end
    end
    
    -- Folha no topo (centralizada)
    local top_x = math.floor(copa_center_x)
    local top_z = math.floor(copa_center_z)
    if area:contains(top_x, top + 3, top_z) then  
        local vi_top = area:index(top_x, top + 3, top_z)
        if data[vi_top] == c_air then
            data[vi_top] = c_leaves
        end
    end


    -- =============== FALLEN STICK (50% de chance) ===============
    --if math.random() < 0.40 then
    
    local rng_stick = PseudoRandom(wx * 12345 + wz * 67890)
    if rng_stick:next(1, 1000) <= 400 then -- 40% = 400/1000
        local attempts = 0
        local max_attempts = 10  -- Mais tentativas para encontrar chão válido (era 50 por arvore)
        
        while attempts < max_attempts do
            -- Gera posição aleatória em um raio maior (incluindo área além da copa)
            local stick_dx = rng_stick:next(-crown_radius - 2, crown_radius + 2)
            local stick_dz = rng_stick:next(-crown_radius - 2, crown_radius + 2)
            
            local stick_x = math.floor(copa_center_x + stick_dx)
            local stick_z = math.floor(copa_center_z + stick_dz)
            
            -- Busca o chão real descendo a partir da altura da árvore
            local found_ground = false
            local ground_y = nil
            
            -- Desce a partir do topo da árvore até alguns blocos abaixo da base
            for y = pos.y + height, pos.y - 5, -1 do
                if area:contains(stick_x, y, stick_z) and 
                   area:contains(stick_x, y + 1, stick_z) then
                    
                    local vi_ground = area:index(stick_x, y, stick_z)
                    local vi_above = area:index(stick_x, y + 1, stick_z)
                    
                    -- Verifica se encontrou um bloco sólido válido com ar acima
                    if (data[vi_ground] == c_topgrass or 
                        data[vi_ground] == c_grass or 
                        data[vi_ground] == c_dirt) and 
                       (data[vi_above] == c_air or data[vi_above] == c_grassleaves) then
                        
                        ground_y = y + 1  -- Posição do graveto (1 bloco acima do chão)
                        found_ground = true
                        break
                    end
                end
            end
            
            -- Se encontrou um chão válido, coloca o graveto
            if found_ground and ground_y then
                local vi_stick = area:index(stick_x, ground_y, stick_z)
                data[vi_stick] = c_fallenstick
                break  -- Graveto colocado com sucesso!
            end
            
            attempts = attempts + 1
        end
    end
    --]]--
end

-----------------------------
-- FUNÇÃO DE SPAWN DE PINHEIRO
-----------------------------
local function spawn_pine_tree(area, data, pos, wx, wz)
    -- Verifica se há espaço (raio de 4 blocos)
    if not can_place_tree(area, data, pos, 4) then
        return
    end
    
    -- RNG determinístico por posição
    local seed = wx * 73856093 + wz * 19349663
    local rng = PseudoRandom(seed)
    local height = rng:next(8, 12)  -- Pinheiros mais altos
    
    -- =============== TRONCO (sempre 1x1) ===============
    for y = 0, height do
        local check_pos = {x = pos.x, y = pos.y + y, z = pos.z}
        
        if area:contains(check_pos.x, check_pos.y, check_pos.z) then
            local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
            if data[vi] == c_air or data[vi] == c_pineleaves then
                data[vi] = c_pinetimber
            end
        end
    end
    
-- =============== COPA CÔNICA (base mais baixa) ===============
local top = pos.y + height

local canopy_start = pos.y + math.floor(height * 0.25) -- começa mais baixo
local canopy_end   = top + 3                           -- estende acima do topo
local canopy_height = canopy_end - canopy_start

local max_radius = 4

	for y = canopy_end, canopy_start, -1 do
	    local layer = canopy_end - y
	    local t = layer / canopy_height  -- 0 no topo, 1 na base

	    -- Raio cresce suavemente para baixo
	    local radius = math.floor(t * max_radius)
	    if radius < 1 then radius = 1 end

	    for dx = -radius, radius do
		for dz = -radius, radius do
		    local dist = (dx * dx + dz * dz) --local dist = math.sqrt(dx * dx + dz * dz)

		    -- Cone mais fechado no topo
		    local limit = radius - (1 - t) * 0.25

		    -- Irregularidade leve
		    local noise = rng:next(0, 100) / 350

		    if dist <= (limit + noise)*(limit + noise) then
		        local check_pos = {
		            x = pos.x + dx,
		            y = y,
		            z = pos.z + dz
		        }

		        if area:contains(check_pos.x, check_pos.y, check_pos.z) then
		            local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
		            if data[vi] == c_air then
		                data[vi] = c_pineleaves
		            end
		        end
		    end
		end
	    end
	end
end



-----------------------------
-- FUNÇÃO DE SPAWN DE MACIEIRA
-----------------------------
local function spawn_apple_tree(area, data, pos, wx, wz)
    -- Verifica se há espaço (raio de 4 blocos)
    if not can_place_tree(area, data, pos, 4) then
        return
    end
    
    -- VERIFICAÇÃO: Verifica se há dirt abaixo do ponto de spawn ***
    local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    if area:contains(below_pos.x, below_pos.y, below_pos.z) then
        local vi_below = area:index(below_pos.x, below_pos.y, below_pos.z)
        if data[vi_below] ~= c_dirt then
            return  -- Cancela se não tiver grama embaixo
        end
    else
        return  -- Cancela se a posição abaixo não está no chunk
    end
    
    -- RNG determinístico por posição
    local seed = wx * 73856093 + wz * 19349663
    local rng = PseudoRandom(seed)
    local height = rng:next(3, 6)  -- macieiras mais altos
    
    -- =============== TRONCO (sempre 1x1) ===============
    for y = 0, height do
        local check_pos = {x = pos.x, y = pos.y + y, z = pos.z}
        
        if area:contains(check_pos.x, check_pos.y, check_pos.z) then
            local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
            if data[vi] == c_air or data[vi] == c_appleleaves then
                data[vi] = c_appletimber
            end
        end
    end
    
    -- =============== COPA (esférica) ===============
    local max_swaps = 3
    local swaps = 0

    
    local top = pos.y + height
    -- Ajusta centro da copa para troncos maiores
    local copa_center_x = pos.x
    local copa_center_z = pos.z
    local crown_radius = rng:next(1, 2)

    
    for dy = -2, 3 do
        for dx = -crown_radius, crown_radius do
            for dz = -crown_radius, crown_radius do
                local dist = (dx * dx + dy * dy + dz * dz) --local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                if dist <= (crown_radius + 0.5)*(crown_radius + 0.5) then
                    local check_pos = {
                        x = math.floor(copa_center_x + dx), 
                        y = top + dy, 
                        z = math.floor(copa_center_z + dz)
                    }
                    if area:contains(check_pos.x, check_pos.y, check_pos.z) then
                        local vi = area:index(check_pos.x, check_pos.y, check_pos.z)
			if data[vi] == c_air then
			    data[vi] = c_appleleaves

			    -- Chance de substituir por folhas especiais
			    -- (mais pressão para NÃO trocar → distribuição enviesada)
			    if swaps < max_swaps then
				local r = rng:next(1, 100)  -- 1 a 100
				-- Distribuição enviesada:
				if r < 5 then  -- 5%
				    data[vi] = c_leavesapple3
				    swaps = swaps + 1
				elseif r < 10 then  -- 10%
				    data[vi] = c_leavesapple2
				    swaps = swaps + 1
				elseif r < 15 then  -- 15%
				    data[vi] = c_leavesapple
				    swaps = swaps + 1
				end
			    end
			end
                    end
                end
            end
        end
    end
    
    -- Folha no topo (centralizada)
    local top_x = math.floor(copa_center_x)
    local top_z = math.floor(copa_center_z)
    if area:contains(top_x, top + 2, top_z) then
        local vi_top = area:index(top_x, top + 2, top_z)
        if data[vi_top] == c_air then
            data[vi_top] = c_leavesapple
        end
    end
end

-----------------------------
-- FUNÇÃO DE CÁLCULO DE ALTURA (OTIMIZADA COM ARRAYS)
-----------------------------
local MAX_TERRAIN_Y = 80
local function calculate_height_batch(minp, maxp, SEA_LEVEL, CENTER_X, CENTER_Z, MAX_RADIUS,
                                      continent_2d, biome_2d, mountain_2d, hills_2d, plains_2d, rough_2d)
    local heights = {}
    local biome_factors = {}
    local sidelen = maxp.x - minp.x + 1
    
    local index = 1
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            -- Coordenadas toroidais
            local wx = ((x - MIN_XZ) % SIZE) + MIN_XZ
            local wz = ((z - MIN_XZ) % SIZE) + MIN_XZ
            
            -- Distância do centro
            local dx = wx - CENTER_X
            local dz = wz - CENTER_Z
            local dist_from_center_sq = dx * dx + dz * dz -- quadrado
            local MAX_RADIUS_SQ = MAX_RADIUS * MAX_RADIUS

            -- Fator continental (normalizado de 0 a 1)
            local continent_factor = math.max(0, 1.0 - (dist_from_center_sq / MAX_RADIUS_SQ))
            
            -- FORÇAR bordas a serem oceano
            -- Quando dist > 0.85 * MAX_RADIUS, começar a afundar drasticamente
            local edge_threshold = MAX_RADIUS * 0.5 -- fator de terra firme: até 30% do raio
            local edge_threshold_sq = edge_threshold * edge_threshold

	    if dist_from_center_sq > edge_threshold_sq then
    	        local edge_factor = (dist_from_center_sq - edge_threshold_sq) / (MAX_RADIUS_SQ - edge_threshold_sq)
    	        continent_factor = continent_factor * (1.0 - edge_factor * 0.8)
            end
            
            -- Fator continental dos noise maps (já normalizados)
            local cont_noise = (continent_2d[index] + 1) / 2
            local continent_lands = math.pow(cont_noise, 1.8)
            
            -- Bioma
            local biome_noise = biome_2d[index]
            local biome_factor = (biome_noise + 1) / 2
            
            -- Noises já normalizados
            local mountain_noise = mountain_2d[index]
            local hills_noise = hills_2d[index]
            local plains_noise = plains_2d[index]
            local rough_noise = rough_2d[index]
            
            local mn = (mountain_noise + 1) / 2
            local hn = (hills_noise + 1) / 2
            local pn = (plains_noise + 1) / 2
            local rn = (rough_noise + 1) / 2
            local cl = continent_lands
            
            -- Mistura baseada no bioma
            local terrain_height
            if biome_factor > 0.7 then
                local mountain_weight = (biome_factor - 0.6) / 0.4
                terrain_height = (mn * 0.5 + hn * 0.3 + rn * 0.2 + cl * 0.3) * (1.0 + mountain_weight)
            elseif biome_factor < 0.3 then
                local plains_weight = (0.4 - biome_factor) / 0.4
                terrain_height = (pn * 0.7 + rn * 0.3 + cl * 0.2) * (0.3 + plains_weight * 0.25)
            else
                terrain_height = hn * 0.6 + pn * 0.2 + rn * 0.2 + cl * 0.1
            end
            
            -- Aplica fator continental
            local final_height = terrain_height * continent_factor 
            local height = math.floor(final_height * 65 + SEA_LEVEL - 19)
            
            -- Limites
            if height > MAX_TERRAIN_Y then height = MAX_TERRAIN_Y end
            if height < -20 then height = -20 end
            
            heights[index] = height
            biome_factors[index] = biome_factor
            
            index = index + 1
        end
    end
    
    return heights, biome_factors
end

-----------------------------
-- FUNÇÃO PARA VERIFICAR SE É CAVERNA (OTIMIZADA COM ARRAYS 3D)
-----------------------------
local function is_cave_lava_batch(x, y, z, cave_lava_3d, cave_size_3d, area, minp)
    -- Apenas gera cavernas na camada de gneiss (ajustado conforme a minha lógica)
    if y > 23 or y < -37 then
        return false
    end
    
    -- Calcula índice no array 3D
    local vi = area:index(x, y, z)
    
    -- Noise 3D principal para cavernas
    local cave_noise = cave_lava_3d[vi]
    
    -- Noise para variar o tamanho das cavernas
    local size_noise = cave_size_3d[vi]
    local size_factor = (size_noise + 1) / 2  -- Normaliza para 0-1
    
    -- Threshold dinâmico: ajusta a "abertura" das cavernas
    -- Valores menores = cavernas maiores
    -- Valores maiores = cavernas menores/raras
    local threshold = 0.6 + (size_factor * 0.7)  -- Varia entre 0.6 e 0.8
    
    -- Se o noise absoluto for maior que o threshold, é caverna
    return math.abs(cave_noise) > threshold
end

local function is_cave_water_batch(x, y, z, cave_water_3d, cave_size_3d, area, minp)
    -- Apenas gera cavernas na camada de gneiss (ajustado conforme a minha lógica)
    if y > 23 or y < -37 then
        return false
    end
    
    -- Calcula índice no array 3D
    local vi = area:index(x, y, z)
    
    -- Noise 3D principal para cavernas
    local cave_noise = cave_water_3d[vi]
    
    -- Noise para variar o tamanho das cavernas
    local size_noise = cave_size_3d[vi]
    local size_factor = (size_noise + 1) / 2  -- Normaliza para 0-1
    
    -- Threshold dinâmico: ajusta a "abertura" das cavernas
    -- Valores menores = cavernas maiores
    -- Valores maiores = cavernas menores/raras
    local threshold = 0.6 + (size_factor * 0.5)  -- Varia entre 0.6 e 0.8
    
    -- Se o noise absoluto for maior que o threshold, é caverna
    return math.abs(cave_noise) > threshold
end

local function is_cave_batch(x, y, z, cave_3d, cave_size_3d, area, minp)
    -- Apenas gera cavernas na camada de gneiss (ajustado conforme a minha lógica)
    if y > 23 or y < -37 then
        return false
    end
    
    -- Calcula índice no array 3D
    local vi = area:index(x, y, z)
    
    -- Noise 3D principal para cavernas
    local cave_noise = cave_3d[vi]
    
    -- Noise para variar o tamanho das cavernas
    local size_noise = cave_size_3d[vi]
    local size_factor = (size_noise + 1) / 2  -- Normaliza para 0-1
    
    -- Threshold dinâmico: ajusta a "abertura" das cavernas
    -- Valores menores = cavernas maiores
    -- Valores maiores = cavernas menores/raras
    local threshold = 0.6 + (size_factor * 0.2)  -- Varia entre 0.6 e 0.8
    
    -- Se o noise absoluto for maior que o threshold, é caverna
    return math.abs(cave_noise) > threshold
end

-- Modelo da tenda de coqueiro
local function can_spawn_tent(area, data, base_pos)
    local width = 4
    local depth = 5
    local height = 4 -- 3 troncos + teto

    -- chão: areia molhada
    for dx = 0, width - 1 do
        for dz = 0, depth - 1 do
            local vi = area:index(base_pos.x + dx, base_pos.y - 1, base_pos.z + dz)
            if data[vi] ~= c_wetsand then
                return false
            end
        end
    end

    -- volume livre
    for dx = 0, width - 1 do
        for dz = 0, depth - 1 do
            for dy = 0, height do
                local vi = area:index(base_pos.x + dx, base_pos.y + dy, base_pos.z + dz)
                if data[vi] ~= c_air then
                    return false
                end
            end
        end
    end

    return true
end

local function spawn_tent(area, data, base_pos)
    local width = 4
    local depth = 5
    local trunk_height = 3
    local roof_y = base_pos.y + trunk_height

    local corners = {
        {0, 0},
        {3, 0},
        {0, 4},
        {3, 4},
    }

    -- troncos
    for _, c in ipairs(corners) do
        for y = 0, trunk_height - 1 do
            data[area:index(
                base_pos.x + c[1],
                base_pos.y + y,
                base_pos.z + c[2]
            )] = c_palmtimber
        end
    end

    -- teto
    for dx = 0, width - 1 do
        for dz = 0, depth - 1 do
            data[area:index(
                base_pos.x + dx,
                roof_y,
                base_pos.z + dz
            )] = c_palmstraw
        end
    end
end


-- Modelo do navio afundado
local function can_spawn_ship(area, data, base_pos)
    local width = 4
    local depth = 8
    local height = 4 -- 3 blocs paredes + teto

    -- chão: areia molhada
    for dx = 0, width - 1 do
        for dz = 0, depth - 1 do
            local vi = area:index(base_pos.x + dx, base_pos.y - 1, base_pos.z + dz)
            if data[vi] ~= c_wetsand then
                return false
            end
        end
    end

    -- volume livre
    for dx = 0, width - 1 do
        for dz = 0, depth - 1 do
            for dy = 0, height do
                local vi = area:index(base_pos.x + dx, base_pos.y + dy, base_pos.z + dz)
                if data[vi] ~= c_water then
                    return false
                end
            end
        end
    end

    return true
end

local function spawn_ship(area, data, base_pos)
    local width = 5
    local depth = 8
    local pillar_height = 3
    local roof_y = base_pos.y + pillar_height

    local corners = {
        {0,         0},
        {width - 1, 0},
        {0,         depth - 1},
        {width - 1, depth - 1},
    }

    -- conves
    for dx = -2, width + 1 do
        for dz = -3, depth + 3 do
            data[area:index(
                base_pos.x + dx,
                base_pos.y,
                base_pos.z + dz
            )] = c_oakwood
        end
    end

    -- teto
    for dx = 0, width - 1 do
        for dz = 0, depth - 3 do
            data[area:index(
                base_pos.x + dx,
                roof_y + 1,
                base_pos.z + dz
            )] = c_oakwood
        end
    end
        -- parede frontal janela (dz = 0)
    for dx = 0, width - 1 do
        for y = 0, pillar_height - 2 do
            data[area:index(base_pos.x + dx, base_pos.y + y, base_pos.z)] = c_oakwood
        end
    end
    
    -- parede traseira porta
    for dx = 0, width - 3 do
        for y = 0, pillar_height do
            data[area:index(base_pos.x + dx, base_pos.y + y, base_pos.z + depth - 3)] = c_oakwood
        end
    end
    
    -- parede lateral esquerda fechada (dx = 0)
    for dz = 0, depth - 3 do
        for y = 0, pillar_height do
            data[area:index(base_pos.x, base_pos.y + y, base_pos.z + dz)] = c_oakwood
        end
    end
    
    -- parede lateral direita fechada (dx = width-1)
    for dz = 0, depth - 3 do
        for y = 0, pillar_height do
            data[area:index(base_pos.x + width - 1, base_pos.y + y, base_pos.z + dz)] = c_oakwood
        end
    end

    -- parede do fundo (dz = depth-1) fica ABERTA — entrada da cabine 
end

local function place_random_chest(area, data, base_pos)
    local candidates = {}

    -- espaço interno: x = 1..2, z = 1..3
    for dx = 1, 2 do
        for dz = 1, 3 do
            table.insert(candidates, {dx = dx, dz = dz})
        end
    end

    if #candidates == 0 then return end

    -- ✅ RNG determinístico baseado na posição do baú
    local rng_chest = PseudoRandom(base_pos.x * 11111 + base_pos.z * 22222)
    local idx = rng_chest:next(1, #candidates)
    local c = candidates[idx]

    local chest_pos = {
        x = base_pos.x + c.dx,
        y = base_pos.y,
        z = base_pos.z + c.dz
    }

    local vi = area:index(chest_pos.x, chest_pos.y, chest_pos.z)
    data[vi] = c_oakchest

    -- garantir inicialização correta
    core.after(0, function()
        local node = core.get_node(chest_pos)
        local def = core.registered_nodes[node.name]
        if def and def.on_construct then
            def.on_construct(chest_pos)
        end
    end)
end

local function safe_index(area, x, y, z, minp, maxp)
    if x < minp.x or x > maxp.x or
       y < minp.y or y > maxp.y or
       z < minp.z or z > maxp.z then
        return nil
    end
    return area:index(x, y, z)
end

-----------------------------
-- FUNÇÃO DE INICIALIZAÇÃO DOS PERLIN MAPS
-----------------------------
local function init_perlin_maps()
    if perlin_biome then
        return -- Já inicializados
    end
    
    -- Mantém os perlins antigos para compatibilidade com funções que ainda os usam
    perlin_continent = core.get_perlin(noise_continent)
    perlin_mountain     = core.get_perlin(noise_mountain)
    perlin_hills        = core.get_perlin(noise_hills)
    perlin_plains       = core.get_perlin(noise_plains)
    perlin_caves        = core.get_perlin(noise_caves)
    perlin_caves_lava   = core.get_perlin(noise_caves_lava)
    perlin_caves_water  = core.get_perlin(noise_caves_water)
    perlin_cave_size    = core.get_perlin(noise_cave_size)
    perlin_roughness    = core.get_perlin(noise_roughness)
    perlin_biome        = core.get_perlin(noise_biome)
    perlin_grassleaves  = core.get_perlin(noise_grassleaves)
    perlin_trees        = core.get_perlin(noise_trees)
    perlin_bushes       = core.get_perlin(noise_bushes)
    perlin_saprolite    = core.get_perlin(noise_saprolite)
    perlin_ore_master = core.get_perlin(noise_ore_master)
    

    
    -- NOVOS PERLIN MAPS OTIMIZADOS
    local chunksize = {x = 80, y = 80, z = 80}
    perlin_continent_map = core.get_perlin_map(noise_continent, chunksize)
    perlin_biome_map = core.get_perlin_map(noise_biome, chunksize)
    perlin_mountain_map = core.get_perlin_map(noise_mountain, chunksize)
    perlin_hills_map = core.get_perlin_map(noise_hills, chunksize)
    perlin_plains_map = core.get_perlin_map(noise_plains, chunksize)
    perlin_roughness_map = core.get_perlin_map(noise_roughness, chunksize)
    perlin_caves_map = core.get_perlin_map(noise_caves, chunksize)
    perlin_caves_lava_map = core.get_perlin_map(noise_caves_lava, chunksize)
    perlin_caves_water_map = core.get_perlin_map(noise_caves_water, chunksize)
    perlin_cave_size_map = core.get_perlin_map(noise_cave_size, chunksize)
    perlin_grassleaves_map = core.get_perlin_map(noise_grassleaves, chunksize)
    perlin_trees_map = core.get_perlin_map(noise_trees, chunksize)
    perlin_bushes_map = core.get_perlin_map(noise_bushes, chunksize)
    perlin_saprolite_map = core.get_perlin_map(noise_saprolite, chunksize)
    perlin_ore_master_map = core.get_perlin_map(noise_ore_master, chunksize)

    core.log("action", "[terrain] Perlins e Perlin Maps inicializados")
end

-----------------------------
-- FUNÇÃO DE GERAÇÃO DOS NOISE MAPS EM BATCH
-----------------------------
local function generate_noise_maps(minp, maxp)
    local minposxz = {x = minp.x, y = minp.z}
    
    -- Noise maps 2D (para altura do terreno)
    local continent_2d = perlin_continent_map:get_2d_map_flat(minposxz)
    local biome_2d = perlin_biome_map:get_2d_map_flat(minposxz)
    local mountain_2d = perlin_mountain_map:get_2d_map_flat(minposxz)
    local hills_2d = perlin_hills_map:get_2d_map_flat(minposxz)
    local plains_2d = perlin_plains_map:get_2d_map_flat(minposxz)
    local rough_2d = perlin_roughness_map:get_2d_map_flat(minposxz)
    local grassleaves_2d = perlin_grassleaves_map:get_2d_map_flat(minposxz)
    local trees_2d = perlin_trees_map:get_2d_map_flat(minposxz)
    local bushes_2d = perlin_bushes_map:get_2d_map_flat(minposxz)
    
    -- Noise maps 3D (para cavernas e minérios)
    local caves_3d = perlin_caves_map:get_3d_map_flat(minp)
    local caves_lava_3d = perlin_caves_lava_map:get_3d_map_flat(minp)
    local caves_water_3d = perlin_caves_water_map:get_3d_map_flat(minp)
    local cave_size_3d = perlin_cave_size_map:get_3d_map_flat(minp)
    local saprolite_3d = perlin_saprolite_map:get_3d_map_flat(minp)
    local ore_master_3d = perlin_ore_master_map:get_3d_map_flat(minp)
    
    return {
        -- 2D maps
        continent_2d = continent_2d,
        biome_2d = biome_2d,
        mountain_2d = mountain_2d,
        hills_2d = hills_2d,
        plains_2d = plains_2d,
        rough_2d = rough_2d,
        grassleaves_2d = grassleaves_2d,
        trees_2d = trees_2d,
        bushes_2d = bushes_2d,
        
        -- 3D maps
        caves_3d = caves_3d,
        caves_lava_3d = caves_lava_3d,
        caves_water_3d = caves_water_3d,
        cave_size_3d = cave_size_3d,
        saprolite_3d = saprolite_3d,
        ore_master_3d = ore_master_3d,
    }
end

-----------------------------
-- FUNÇÃO AUXILIAR: EPICENTROS DE NEVE
-----------------------------
local SNOW_RADIUS = 350
local EPICENTER_NE = {x = MAX_XZ * 0.5, z = MAX_XZ * 0.5}
local EPICENTER_SW = {x = MIN_XZ * 0.5, z = MIN_XZ * 0.5}

local function inside_snow_area(x, z)
    local dx1 = x - EPICENTER_NE.x
    local dz1 = z - EPICENTER_NE.z
    local d1 = dx1*dx1 + dz1*dz1
    
    local dx2 = x - EPICENTER_SW.x
    local dz2 = z - EPICENTER_SW.z
    local d2 = dx2*dx2 + dz2*dz2
    
    return (d1 <= SNOW_RADIUS*SNOW_RADIUS) or (d2 <= SNOW_RADIUS*SNOW_RADIUS)
end


-----------------------------
-- FUNÇÃO DE GERAÇÃO DO TERRENO BASE
-----------------------------
local function generate_terrain_base(minp, maxp, area, data, heights, biome_factors, noise_maps)
    local SEA_LEVEL = 0
    
    local index_2d = 1
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local wx = ((x - MIN_XZ) % SIZE) + MIN_XZ
            local wz = ((z - MIN_XZ) % SIZE) + MIN_XZ
            
        -- ✅ RNG determinístico por coluna
        local rng_terrain = PseudoRandom(wx * 99991 + wz * 77773)
            
            local height = heights[index_2d]
            local biome_factor = biome_factors[index_2d]
            
            for y = math.max(minp.y, -50), math.min(maxp.y, MAX_TERRAIN_Y) do
                local vi = area:index(x, y, z)
                local is_snow_area = inside_snow_area(x, z)
                
                -- Pular blocos obviamente vazios acima do terreno
                if y > height + 10 then
                    data[vi] = c_air
                    goto skip_block
                end
                
    -- ⭐ OTIMIZAÇÃO 2 - CACHE DE CAVERNAS ⭐
    local is_cave = false
    local is_cave_lava = false
    local is_cave_water = false
    
    -- Só calcula se estiver na faixa de altura relevante
    if y > -37 and y <= 23 then
        is_cave = is_cave_batch(x, y, z, noise_maps.caves_3d, noise_maps.cave_size_3d, area, minp)
        is_cave_lava = is_cave_lava_batch(x, y, z, noise_maps.caves_lava_3d, noise_maps.cave_size_3d, area, minp)
        is_cave_water = is_cave_water_batch(x, y, z, noise_maps.caves_water_3d, noise_maps.cave_size_3d, area, minp)
    end
                
                if y <= -50 then
                    data[vi] = c_redrock
                elseif y <= -48 then
                    data[vi] = c_peridotite
                elseif y <= -46 then
                    data[vi] = c_bedrock
                elseif y <= -43 then
                    data[vi] = c_peridotite
                elseif y <= -40 then
                    data[vi] = c_lava
                elseif y <= -35 then
                    data[vi] = c_basalt
                elseif y <= height - 7 then
                    -- Verifica caverna primeiro
                    if is_cave then
                        data[vi] = c_ignore
                        if y <= -34 and rng_terrain:next(1, 1000) <= 50 then  -- 5%
                            data[vi] = c_obsidian
                        end
                    elseif is_cave_lava then
                        data[vi] = c_ignore
                        if y < -30 then --and rng_terrain:next(1, 1000) <= 900 then  -- 90%
                            data[vi] = c_lava
                        end
                    elseif is_cave_water then
                        data[vi] = c_ignore
                        if y < -28 then --and rng_terrain:next(1, 1000) <= 900 then  -- 90%
                            data[vi] = c_water2
                        end
                    else
                        -- Gneiss e minérios
                        local node_type = c_gneiss
                        local ore_noise = noise_maps.ore_master_3d[vi]
                        
                        if y > -10  and y < 5 and ore_noise > 0.85 then  -- 15% de chance
                            node_type = c_coal
                        elseif y > -20 and y < -10 and ore_noise > 0.88 then  --  (12% chance)
                            node_type = c_copper
                        elseif y > -25 and y <= -20 and ore_noise > 0.90 then -- 10% chance
                            node_type = c_tin
                        elseif y > -30 and y <= -25 and ore_noise > 0.92 then -- 8% chance
                            node_type = c_iron
                        elseif y > -32 and y <= -30 and ore_noise > 0.94 then -- 6% chance
                            node_type = c_nickel
                        elseif y > -33 and y <= -32 and ore_noise > 0.96 then -- 4% chance
                            node_type = c_manganese
                        elseif y > -35 and y <= -33 and ore_noise > 0.98 then -- 2% chance
                            node_type = c_chromium
                        end
                        
                        data[vi] = node_type
                    end
                elseif y <= height - 4 then
                    -- Saprolite
                    local saprolite_2d_value = perlin_saprolite:get_2d({x=wx, y=wz})
                    local saprolite_thickness = math.floor((saprolite_2d_value + 1) * 1.5 + 0.5)
                    
                    if y > height - 4 - saprolite_thickness then
                        data[vi] = c_saprolite
                    else
                        data[vi] = c_gneiss
                    end
                elseif y <= height - 1 then
                    if height <= SEA_LEVEL + 5 then
                        data[vi] = c_sand
                    else
                        data[vi] = c_dirt
                    end
                elseif y == height then
                    local is_mountain = (height > SEA_LEVEL + 8)
                    
                    if is_mountain and is_snow_area then
                        data[vi] = c_snow
                    elseif height <= SEA_LEVEL then
                        data[vi] = c_wetsand
                        -- Propagar areia molhada para baixo
                        local by = y - 1
                        while by >= minp.y do
                            local bvi = area:index(x, by, z)
                            if data[bvi] == c_sand then
                                data[bvi] = c_wetsand
                                by = by - 1
                            else
                                break
                            end
                        end
                    elseif height <= SEA_LEVEL + 5 then
                        data[vi] = c_sand
                    elseif height <= SEA_LEVEL + 6 then
                        data[vi] = c_dirt
                    elseif height <= SEA_LEVEL + 7 then
                        data[vi] = c_topgrass
                    else
                        data[vi] = c_topgrass
                    end
                --elseif y <= SEA_LEVEL and data[vi] == c_air then
                    --data[vi] = c_water
                else
                    data[vi] = c_air
                end
                
                ::skip_block::  -- ⭐ LABEL NO FINAL DO LOOP Y
            end
            
            -- Preenche com água todos os blocos de ar abaixo do nível do mar
            local is_snow_col = inside_snow_area(x, z)
            for y = math.max(minp.y, -50), SEA_LEVEL do
                local vi = area:index(x, y, z)
                if data[vi] == c_air then
                    -- Na área de neve, a camada superficial (y == SEA_LEVEL) vira gelo
                    -- usando o mesmo ruído de grassleaves para variação natural nas bordas
                    if is_snow_col and y == SEA_LEVEL and noise_maps.grassleaves_2d[index_2d] > 0.0 then
                        data[vi] = c_ice
                    else
                        data[vi] = c_water
                    end
                end
            end
            for y = math.max(minp.y, -50), math.min(maxp.y, height) do
		local vi = area:index(x, y, z)
		if data[vi] == c_ignore then
	            data[vi] = c_air  -- restaura o ar das cavernas
		end
	    end
            
            index_2d = index_2d + 1
        end
    end
end


-----------------------------
-- CONFIGURAÇÃO DA ILHA VULCÂNICA
-----------------------------
local VOLCANO_RADIUS = 100  -- Raio da ilha
local VOLCANO_HEIGHT = 40  -- Altura do vulcão
local CRATER_RADIUS = 10   -- Raio da cratera
local CRATER_DEPTH = 70     -- Profundidade da cratera
local BEACH_WIDTH = 50      -- Largura da praia

-- Posição aleatória no oceano (será calculada uma vez)
local VOLCANO_POS = nil

-----------------------------
-- FUNÇÃO PARA ENCONTRAR POSIÇÃO VÁLIDA PARA O VULCÃO
-----------------------------
local function find_volcano_position()
    if VOLCANO_POS then
        return VOLCANO_POS
    end
    
    local CENTER_X = (MIN_XZ + MAX_XZ) / 2
    local CENTER_Z = (MIN_XZ + MAX_XZ) / 2
    local MAX_RADIUS = (SIZE / 2) * 0.85
    
    -- Define área onde o vulcão pode aparecer (no oceano, longe do centro e das bordas)
    local min_dist = MAX_RADIUS * 0.7  -- Mínimo 50% do raio (oceano profundo)
    local max_dist = MAX_RADIUS * 0.85 -- Máximo 75% do raio (antes das bordas)
    
    -- Gera posição aleatória
    local angle = math.random() * math.pi * 2
    local distance = min_dist + math.random() * (max_dist - min_dist)
    
    VOLCANO_POS = {
        x = CENTER_X + math.cos(angle) * distance,
        z = CENTER_Z + math.sin(angle) * distance
    }
    
    core.log("action", "[terrain] Vulcão gerado em: x=" .. VOLCANO_POS.x .. ", z=" .. VOLCANO_POS.z)
    
    return VOLCANO_POS
end

-----------------------------
-- FUNÇÃO DE GERAÇÃO DA ILHA VULCÂNICA
-----------------------------
local function generate_volcano(area, data, minp, maxp, volcano_pos)
    local SEA_LEVEL = 0
    
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            -- Calcula distância do centro do vulcão
            local dx = x - volcano_pos.x
            local dz = z - volcano_pos.z
            local dist_sq = dx * dx + dz * dz
            local dist = math.sqrt(dist_sq)  -- calcular UMA vez
            local VOLCANO_RADIUS_SQ = VOLCANO_RADIUS * VOLCANO_RADIUS
            local rng_volcano = PseudoRandom(x * 13579 + z * 24680)
            
            -- Se está dentro do raio da ilha (vulcão)
            if dist_sq <= VOLCANO_RADIUS_SQ then
                local height_factor = 1.0 - (dist_sq / VOLCANO_RADIUS_SQ)
                
                -- Usar potência maior para cone mais íngreme (convexo)
                local base_height = math.floor(height_factor ^ 3 * VOLCANO_HEIGHT)
                
                -- Adiciona rugosidade à superfície
                local noise_x = x * 0.1
                local noise_z = z * 0.1
                local roughness = (perlin_roughness:get_2d({x=noise_x, y=noise_z}) + 1) * 2
                local volcano_height = SEA_LEVEL + base_height + math.floor(roughness)
                
                -- Determina se está na zona de praia (parte baixa do vulcão)
                local is_beach_zone = dist >= VOLCANO_RADIUS - BEACH_WIDTH
                
                -- Encontra o terreno oceânico existente neste ponto
                local ocean_floor_here = SEA_LEVEL
                for y = SEA_LEVEL, minp.y, -1 do
                    if area:contains(x, y, z) then
                        local vi = area:index(x, y, z)
                        if data[vi] ~= c_water and data[vi] ~= c_air then
                            ocean_floor_here = y
                            break
                        end
                    end
                end
                
                -- Calcula a base do cone a partir do chão oceânico real
                local total_cone_height = volcano_height - ocean_floor_here
                
                -- ==== CRATERA (cálculo correto) ====
                local in_crater = dist <= CRATER_RADIUS
                local crater_factor = 1 - (dist / CRATER_RADIUS)
                if crater_factor < 0 then crater_factor = 0 end
                
                local crater_depth_here = (crater_factor ^ 3) * CRATER_DEPTH
                
                -- Fundo real da cratera neste ponto
                local crater_floor = volcano_height - crater_depth_here
                
                -- **COMEÇA DO CHÃO OCEÂNICO ATÉ O TOPO**
                for y = math.max(minp.y, ocean_floor_here), math.min(maxp.y, volcano_height + 10) do
                    if not area:contains(x, y, z) then
                        goto continue_y
                    end
                    
                    local vi = area:index(x, y, z)
                    
                    -- Calcula qual deveria ser o raio do cone nesta altura Y
                    local height_from_base = y - ocean_floor_here
                    local progress = height_from_base / total_cone_height  -- 0 na base, 1 no topo
                    
                    -- Cone mais íngreme: reduz raio mais rapidamente com a altura
                    local cone_radius_at_y = VOLCANO_RADIUS * (height_factor ^ 2) * (1.0 - progress ^ 1.5)
                    
                    -- Verifica se estamos dentro do cone nesta altura
                    local inside_cone = dist <= cone_radius_at_y
                    
                    -- CRATERA (tem prioridade máxima)
                    if in_crater and y >= crater_floor and y <= volcano_height then
                        -- Nível FIXO do lago de lava (horizontal)
                        local crater_center_floor = volcano_height - CRATER_DEPTH
                        local lava_level = crater_center_floor + 55
                        
                        if y <= lava_level then
                            data[vi] = c_lava
                        else
                            data[vi] = c_air
                        end
                    
                    -- INTERIOR DO CONE (sólido, mas só onde o cone existe)
                    elseif inside_cone and y < volcano_height - 3 then
                        -- Se está na zona de praia E submerso, usa areia
                        if is_beach_zone and y <= SEA_LEVEL then
                            data[vi] = c_sand
                        else
                            data[vi] = c_basalt
                        end
                    
                    -- SUPERFÍCIE DO CONE
                    elseif inside_cone and y <= volcano_height then
                        -- Se está na zona de praia E perto do nível do mar, usa areia
                        if is_beach_zone and y <= SEA_LEVEL + 3 then
                            data[vi] = c_sand
                        else
                            if rng_volcano:next(1, 1000) <= 700 then  -- 70%
                                data[vi] = c_basalt
                            else
                                data[vi] = c_magma
                            end
                        end
                    end
                    
                    ::continue_y::
                end
            end
        end
    end
end

-----------------------------
-- FUNÇÃO DE GERAÇÃO DE DECORAÇÕES (ÁRVORES, PEBBLES, ETC)
-----------------------------
local function generate_decorations(minp, maxp, heights, biome_factors, noise_maps)
    local SEA_LEVEL = 0
    local grassleaves_positions = {}
    local tree_positions = {}
    local pebble_positions = {}
    local pebble_positions2 = {}
    local palm_positions = {}
    
    local index_2d = 1
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local wx = ((x - MIN_XZ) % SIZE) + MIN_XZ
            local wz = ((z - MIN_XZ) % SIZE) + MIN_XZ
            local height = heights[index_2d]
            local biome_factor = biome_factors[index_2d]
            
            -- Folhas de grama (não gera em área de neve)
	    if not inside_snow_area(x, z) and height > SEA_LEVEL + 6 and height >= minp.y and height <= maxp.y then
	        local grassleaves_density = biome_factor < 0.4 and 0.85 or (biome_factor > 0.7 and 0.8 or 0.85)
	        if noise_maps.grassleaves_2d[index_2d] > grassleaves_density then
		    table.insert(grassleaves_positions, {x=x, y=height+1, z=z})
	        end
	    end
            
            -- Carvalhos e Macieiras
            if not inside_snow_area(x, z) and height > SEA_LEVEL + 4 and height >= minp.y and height <= maxp.y then
	        if noise_maps.trees_2d[index_2d] > 0.70 then
	    	    local tree_type = "tree"  -- default: carvalho
		
		-- Macieiras aparecem em alturas mais baixas (zona de transição)
		    if height <= SEA_LEVEL + 6 then
		        tree_type = "apple"
		    end
		
		    table.insert(tree_positions, {x=x, y=height+1, z=z, wx=wx, wz=wz, type=tree_type})
	        end
	    end

            
            -- Pinheiros
            if inside_snow_area(x, z) and height > SEA_LEVEL + 6 and height >= minp.y and height <= maxp.y then
                if noise_maps.trees_2d[index_2d] > 0.65 then
                    table.insert(tree_positions, {x=x, y=height+1, z=z, wx=wx, wz=wz, type="pine"})
                end
            end
            
            -- Arbustos
            if not inside_snow_area(x, z) and height > SEA_LEVEL + 6 and height >= minp.y and height <= maxp.y then
                local bush_density = biome_factor < 0.5 and 0.72 or (biome_factor > 0.7 and 0.80 or 0.75)
                if noise_maps.bushes_2d[index_2d] > bush_density then
                    table.insert(tree_positions, {x=x, y=height+1, z=z, wx=wx, wz=wz, type="bush"})
                end
            end
            
            -- Coqueiros
            if not inside_snow_area(x, z) and height >= SEA_LEVEL - 2 and height <= SEA_LEVEL + 3 and height >= minp.y and height <= maxp.y then
	        if noise_maps.trees_2d[index_2d] > 0.7 then
		    table.insert(palm_positions, {x=x, y=height+1, z=z, wx=wx, wz=wz})
	        end
	    end
            
            -- Pebbles
            if height > SEA_LEVEL + 5 and height <= SEA_LEVEL + 6 then
                local rng_pebble = PseudoRandom(x * 33333 + z * 44444)
                if rng_pebble:next(1, 2000) == 1 then  -- 0.05% = 1/2000
                    table.insert(pebble_positions2, {x=x, y=height+1, z=z})
                end
                if rng_pebble:next(1, 1000) == 1 then  -- 0.1% = 1/1000
                    table.insert(pebble_positions, {x=x, y=height+1, z=z})
                end
            end
            
            index_2d = index_2d + 1
        end
    end
    
    return {
        grassleaves = grassleaves_positions,
        trees = tree_positions,
        pebbles = pebble_positions,
        pebbles2 = pebble_positions2,
        palms = palm_positions,
    }
end

-----------------------------
-- FUNÇÃO DE APLICAÇÃO DAS DECORAÇÕES
-----------------------------
local function apply_decorations(area, data, decorations)
    local palm_leaf_rotations = {}
    
    -- Gera árvores
    for _, spawn_data in ipairs(decorations.trees) do
        if spawn_data.type == "tree" then
            spawn_tree(area, data, spawn_data, spawn_data.wx, spawn_data.wz)
            
            local rng_page = PseudoRandom(spawn_data.wx * 31337 + spawn_data.wz * 13337)
            if rng_page:next(1, 15) == 1 then
                local dirs = {
                    {x=1,  y=0, z=0},
                    {x=-1, y=0, z=0},
                    {x=0,  y=0, z=1},
                    {x=0,  y=0, z=-1},
                }
                local dir = dirs[rng_page:next(1, 4)]
                
                core.after(0.1, function()
                    local found_y = nil
                    for try_y = spawn_data.y + 2, spawn_data.y + 1, -1 do
                        local trunk_pos = {x = spawn_data.x,         y = try_y, z = spawn_data.z}
                        local side_pos  = {x = spawn_data.x + dir.x, y = try_y, z = spawn_data.z + dir.z}
                        
                        local trunk_node = core.get_node(trunk_pos).name
                        local side_node  = core.get_node(side_pos).name
                        
                        if trunk_node == "nh_nodes:oaktimber" and side_node == "air" then
                            found_y = try_y
                            break
                        end
                    end
                    
                    if found_y then
                        local page_pos = {
                            x = spawn_data.x + dir.x,
                            y = found_y,
                            z = spawn_data.z + dir.z,
                        }
                        
                        local dir_to_param2 = {
                            [1]  = {[0]  = 2},
                            [-1] = {[0]  = 3},
                            [0]  = {[1]  = 4, [-1] = 5},
                        }
                        local param2 = dir_to_param2[dir.x] and dir_to_param2[dir.x][dir.z]
                        
                        if param2 then
                            core.set_node(page_pos, {
                                name = "nh_nodes:writedpage_node",
                                param2 = param2
                            })
                            local meta = core.get_meta(page_pos)
                            local list = page_texts.message
                            local text = list[rng_page:next(1, #list)]
                            meta:set_string("text", text)
                        end
                    end
                end)
            end
            
        elseif spawn_data.type == "apple" then
            spawn_apple_tree(area, data, spawn_data, spawn_data.wx, spawn_data.wz)
        elseif spawn_data.type == "pine" then
            spawn_pine_tree(area, data, spawn_data, spawn_data.wx, spawn_data.wz)
        elseif spawn_data.type == "bush" then
            spawn_bush(area, data, spawn_data, spawn_data.wx, spawn_data.wz)
        end
    end
    
    
    -- Gera coqueiros
    for _, palm_data in ipairs(decorations.palms) do
        local leaf_nodes = spawn_palm_tree(area, data, palm_data, palm_data.wx, palm_data.wz)
        if leaf_nodes then
            for _, leaf_info in ipairs(leaf_nodes) do
                table.insert(palm_leaf_rotations, leaf_info)
            end
        end
    end
    
	-- Gera folhas de grama (com algumas pedras aleatórias)
	for _, grass_pos in ipairs(decorations.grassleaves) do
	    if area:contains(grass_pos.x, grass_pos.y, grass_pos.z) then
		local vi = area:index(grass_pos.x, grass_pos.y, grass_pos.z)
		if data[vi] == c_air then
		    local rng_grass = PseudoRandom(grass_pos.x * 54321 + grass_pos.z * 98765)
		    local r = rng_grass:next(1, 1000)
		    -- chance de gerar outras coisas invés de grama
		    if r <= 1 then  -- 0.001 = 10/10000
		        data[vi] = c_micaceusfungus
		    elseif r <= 1 then  -- 0.001 = 10/10000
		        data[vi] = c_flyamanitafungus
		    elseif r <= 2 then  -- 0.002 = 20/10000
		        data[vi] = c_rush
		    elseif r <= 3 then  -- 0.003 = 30/10000
		        data[vi] = c_dandelion
		    elseif r <= 250 then  -- 0.25 = 2500/10000
		        data[vi] = c_grassleavesmedium
		    else
		        data[vi] = c_grassleaves
		    end
		end
	    end
	end
    
    -- Gera pebbles
    for _, pebble_pos in ipairs(decorations.pebbles2) do
        if area:contains(pebble_pos.x, pebble_pos.y, pebble_pos.z) then
            local vi = area:index(pebble_pos.x, pebble_pos.y, pebble_pos.z)
            if data[vi] == c_air then
                data[vi] = c_whitepebble
            end
        end
    end
    
    for _, pebble_pos in ipairs(decorations.pebbles) do
        if area:contains(pebble_pos.x, pebble_pos.y, pebble_pos.z) then
            local vi = area:index(pebble_pos.x, pebble_pos.y, pebble_pos.z)
            if data[vi] == c_air then
                data[vi] = c_pebble
                local chest_y = pebble_pos.y - 2
                if area:index(pebble_pos.x, chest_y, pebble_pos.z) then
                    local chest_vi = area:index(pebble_pos.x, chest_y, pebble_pos.z)
                    data[chest_vi] = c_oakchest
                end
            end
        end
    end
    
    return palm_leaf_rotations, decorations.pebbles
end

-----------------------------
-- FUNÇÃO DE GERAÇÃO DE TORRES DE OBSIDIANA
-----------------------------
local function generate_obsidian_towers(area, data, minp, maxp)
    local TOWER_MIN_Y = -50
    local TOWER_MAX_Y = 80
    
    local tower_bases = {
        {x = MIN_XZ,     z = MIN_XZ},
        {x = MAX_XZ - 1, z = MIN_XZ},
        {x = MIN_XZ,     z = MAX_XZ - 1},
        {x = MAX_XZ - 1, z = MAX_XZ - 1},
    }
    
    for _, base in ipairs(tower_bases) do
        for y = TOWER_MIN_Y, TOWER_MAX_Y do
            for dx = 0, 4 do
                for dz = 0, 4 do
                    local vi = safe_index(area, base.x + dx, y, base.z + dz, minp, maxp)
                    if vi then
                        data[vi] = c_obsidian
                    end
                end
            end
        end
    end
end

-----------------------------
-- FUNÇÃO DE TENTATIVA DE SPAWN DA TENDA
-----------------------------
local function try_spawn_tent(area, data, minp, maxp)
    if tent_generated then
        return false
    end
    
    if math.abs(minp.x) > TENT_SEARCH_RADIUS or math.abs(minp.z) > TENT_SEARCH_RADIUS then
        return false
    end
    
    local SEA_LEVEL = 0
    
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            if (x * x + z * z) <= (TENT_SEARCH_RADIUS * TENT_SEARCH_RADIUS) then
                for y = SEA_LEVEL + 1, SEA_LEVEL + 6 do
                    local base_pos = {x = x, y = y, z = z}
                    
                    if area:contains(x, y, z) and can_spawn_tent(area, data, base_pos) then
                        spawn_tent(area, data, base_pos)
                        place_random_chest(area, data, base_pos)
                        tent_generated = true
                        return true
                    end
                end
            end
            if tent_generated then return true end
        end
        if tent_generated then return true end
    end
    
    return false
end

-----------------------------
-- FUNÇÃO DE TENTATIVA DE SPAWN DO BARCO AFUNDADO
-----------------------------
local function try_spawn_ship(area, data, minp, maxp)
    if ship_generated then
        return false
    end
    
    if math.abs(minp.x) > SHIP_SEARCH_RADIUS or math.abs(minp.z) > SHIP_SEARCH_RADIUS then
        return false
    end
    
    local SEA_LEVEL = 0
    
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            if (x * x + z * z) <= (SHIP_SEARCH_RADIUS * SHIP_SEARCH_RADIUS) then
                for y = SEA_LEVEL - 7, SEA_LEVEL - 2 do
                    local base_pos = {x = x, y = y, z = z}
                    
                    if area:contains(x, y, z) and can_spawn_ship(area, data, base_pos) then
                        spawn_ship(area, data, base_pos)
                        place_random_chest(area, data, {x = base_pos.x, y = base_pos.y + 1, z = base_pos.z})
                        ship_generated = true
                        return true
                    end
                end
            end
            if ship_generated then return true end
        end
        if ship_generated then return true end
    end
    
    return false
end


-----------------------------
-- GERAÇÃO DO MUNDO (OTIMIZADA E REFATORADA)
-----------------------------
core.register_on_generated(function(minp, maxp)
    -- Inicializa Perlin maps (apenas uma vez)
    init_perlin_maps()
    
    -- Otimização: ignora chunks muito altos ou muito baixos
    if maxp.y < -100 or minp.y > 200 then return end
    
    -- Setup do voxelmanip
    local vm = core.get_voxel_manip()
    local emin, emax = vm:read_from_map(minp, maxp)
    local area = VoxelArea:new {MinEdge = emin, MaxEdge = emax}
    local data = vm:get_data()
    
    -- Configurações
    local SEA_LEVEL = 0
    local CENTER_X = (MIN_XZ + MAX_XZ) / 2
    local CENTER_Z = (MIN_XZ + MAX_XZ) / 2
    local MAX_RADIUS = (SIZE / 2) * 0.85
    
	-- Gera todos os noise maps em batch
	local noise_maps = generate_noise_maps(minp, maxp)

	-- **ADICIONE ESTAS LINHAS AQUI:**
	-- Encontra/define posição do vulcão
	local volcano_pos = find_volcano_position()

	-- Verifica se este chunk está próximo do vulcão
	local chunk_near_volcano = false
	if volcano_pos then
	    local chunk_center_x = (minp.x + maxp.x) / 2
	    local chunk_center_z = (minp.z + maxp.z) / 2
	    local dist = math.sqrt((chunk_center_x - volcano_pos.x)^2 + (chunk_center_z - volcano_pos.z)^2)
	    chunk_near_volcano = dist < (VOLCANO_RADIUS + 80)  -- Margem de segurança
	end

	-- Calcula alturas em batch
    local heights, biome_factors = calculate_height_batch(
        minp, maxp, SEA_LEVEL, CENTER_X, CENTER_Z, MAX_RADIUS,
        noise_maps.continent_2d, noise_maps.biome_2d, noise_maps.mountain_2d,
        noise_maps.hills_2d, noise_maps.plains_2d, noise_maps.rough_2d
    )

    
    -- Gera terreno base
    generate_terrain_base(minp, maxp, area, data, heights, biome_factors, noise_maps)
    
    -- Gera ilha vulcânica se o chunk estiver próximo
    if chunk_near_volcano then
        generate_volcano(area, data, minp, maxp, volcano_pos)
        --add_eruption_effects(area, data, minp, maxp, volcano_pos)
    end
    
    -- Gera decorações (árvores, arbustos, etc)
    local decorations = generate_decorations(minp, maxp, heights, biome_factors, noise_maps)
    
    
    -- Aplica decorações no terreno
    local palm_leaf_rotations, pebble_positions = apply_decorations(area, data, decorations)
    
    
    -- Gera torres de obsidiana
    generate_obsidian_towers(area, data, minp, maxp)
    
    -- Grava dados no voxelmanip
    vm:set_data(data)
    vm:write_to_map()
    vm:update_map()
    
    -- Tentativa de spawnar tenda (APÓS gravar o terreno)
    local tent_spawned = try_spawn_tent(area, data, minp, maxp)
    
    if tent_spawned then
        -- Regrava apenas se modificou
        vm:set_data(data)
        vm:write_to_map()
        vm:update_map()
    end
    
        -- Tentativa de spawnar tenda (APÓS gravar o terreno)
    local ship_spawned = try_spawn_ship(area, data, minp, maxp)
    
    if ship_spawned then
        -- Regrava apenas se modificou
        vm:set_data(data)
        vm:write_to_map()
        vm:update_map()
    end

    
    -- Rotaciona folhas de coqueiro e inicializa baús
    core.after(0, function()
        -- Rotação das folhas de palmeira
        for _, leaf_info in ipairs(palm_leaf_rotations) do
            local node = core.get_node(leaf_info.pos)
            if node.name == "nh_nodes:palmleaf" then
                core.set_node(leaf_info.pos, {
                    name = "nh_nodes:palmleaf",
                    param2 = leaf_info.rotation
                })
            end
        end
        
        -- Inicializa inventários dos baús
        for _, pebble_pos in ipairs(pebble_positions) do
            local chest_pos = {x = pebble_pos.x, y = pebble_pos.y - 2, z = pebble_pos.z}
            local node = core.get_node(chest_pos)
            
            if node.name == "nh_nodes:oak_chest" then
                -- Força re-construção do baú para criar o inventário
                local node_def = core.registered_nodes["nh_nodes:oak_chest"]
                if node_def and node_def.on_construct then
                    node_def.on_construct(chest_pos)
                end
            end
        end
    end)
end) -- FIM do register_on_generated


if not core.registered_nodes["nh_nodes:grass"] then
    core.log("warning", "[terrain] nh_nodes:top_grass não está registrado.")
end

core.register_lbm({
    name = "nh_terrain:grass_conversion",
    nodenames = {"nh_nodes:top_grass"},
    run_at_every_load = true,
    action = function(pos)
        local x, y, z = pos.x, pos.y - 1, pos.z
        local n

        n = core.get_node({x = x + 1, y = y, z = z}).name
        if n == "nh_nodes:top_grass" or n == "nh_nodes:grass" then
            core.set_node(pos, {name = "nh_nodes:grass"})
            return
        end

        n = core.get_node({x = x - 1, y = y, z = z}).name
        if n == "nh_nodes:top_grass" or n == "nh_nodes:grass" then
            core.set_node(pos, {name = "nh_nodes:grass"})
            return
        end

        n = core.get_node({x = x, y = y, z = z + 1}).name
        if n == "nh_nodes:top_grass" or n == "nh_nodes:grass" then
            core.set_node(pos, {name = "nh_nodes:grass"})
            return
        end

        n = core.get_node({x = x, y = y, z = z - 1}).name
        if n == "nh_nodes:top_grass" or n == "nh_nodes:grass" then
            core.set_node(pos, {name = "nh_nodes:grass"})
            return
        end
    end
})


core.after(1, function()
    print("[terrain] Pré-gerando área de spawn...")
    core.emerge_area(
        {x = -48, y = -16, z = -48},
        {x = 48, y = 80, z = 48},
        function(blockpos, action, calls_remaining)
            if calls_remaining == 0 then
                print("[terrain] Área de spawn pré-gerada com sucesso!")
            end
    end)
end)

-----------------------------
-- COMANDO PARA ENCONTRAR O VULCÃO
-----------------------------
core.register_chatcommand("vulcao", {
    description = "Teleporta para a ilha vulcânica",
    privs = {teleport = true},  -- Requer privilégio de teleporte
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Jogador não encontrado"
        end
        
        local volcano_pos = find_volcano_position()
        
        if not volcano_pos then
            return false, "Vulcão ainda não foi gerado"
        end
        
        -- Teleporta para o topo do vulcão
        local tp_pos = {
            x = volcano_pos.x - 2,
            y = VOLCANO_HEIGHT + 5,  -- Um pouco acima da cratera
            z = volcano_pos.z - 2
        }
        
        player:set_pos(tp_pos)
        
        return true, "Teleportado para o vulcão em X:" .. math.floor(volcano_pos.x) .. " Z:" .. math.floor(volcano_pos.z)
    end,
})

-- Comando alternativo sem necessidade de privilégios (para testes)
core.register_chatcommand("onde_vulcao", {
    description = "Mostra as coordenadas da ilha vulcânica",
    func = function(name)
        local volcano_pos = find_volcano_position()
        
        if not volcano_pos then
            return false, "Vulcão ainda não foi gerado"
        end
        
        return true, "Ilha vulcânica em X:" .. math.floor(volcano_pos.x) .. " Z:" .. math.floor(volcano_pos.z)
    end,
})

print("[terrain] Geração continental com biomas, árvores e coqueiros carregada (OTIMIZADA COM PERLIN MAPS)")
