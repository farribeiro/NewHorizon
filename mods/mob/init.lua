--[[
  Mod: Mob, baseado no mod Happy Mob
  Versão com múltiplos mobs: Ouriço, Coelho, Galinha, galo, tubarão...
--]]

-------------------------------
-- CONFIGURAÇÕES GLOBAIS
-------------------------------

local DEBUG = true

local function log(msg)
    if DEBUG then
        core.log("action", "[Mob] "..msg)
    end
end

--mobs:set_spawn_setting("spawn", true)
--mobs:set_spawn_setting("remove_far", false)

-------------------------------
-- MOB 1: OURIÇO (Defensivo)
-------------------------------

mobs:register_mob("nh_mob:ourico", {
    type = "animal",
    passive = true,          -- Pode se defender quando atacado
    damage = 2,
    reach = 1,
    
    hp_min = 10,
    hp_max = 15,
    armor = 100,
    
    collisionbox = {-0.3, 0, -0.25, 0.25, 0.4, 0.25},
    physical = true,
    stepheight = 1.1,
    fall_speed = -8,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "ourico.obj",
    textures = {"ouricoskin.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 1.5,
    run_velocity = 4.5,
    
    view_range = 10,
    water_damage = 1,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
        run_start = 41,
        run_end = 60,
        jump_start = 61,
        jump_end = 80
    },

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), "O ouriço é amigável, mas cuidado ao atacá-lo!")
        end
    end,
})

-- Spawn do Ouriço (grama)
mobs:spawn({
    name = "nh_mob:ourico",
    nodes = {"air"},
    neighbors = {"nh_nodes:grass"},
    max_light = 15,
    interval = 120,
    chance = 3000,
    active_object_count = 3,
    min_height = -10,
    max_height = 25
})

mobs:register_egg("nh_mob:ourico", "Orbe com Ouriço", "orbspawner.png", 0)

-------------------------------
-- MOB 1: OURIÇO SHADOW (Defensivo)
-------------------------------

mobs:register_mob("nh_mob:ouricoshadow", {
    type = "animal",
    passive = true,          -- Pode se defender quando atacado
    damage = 2,
    reach = 1,
    
    hp_min = 10,
    hp_max = 15,
    armor = 100,
    
    collisionbox = {-0.3, 0, -0.25, 0.25, 0.4, 0.25},
    physical = true,
    stepheight = 1.1,
    fall_speed = -6,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "ourico.obj",
    textures = {"ouricoshadow.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 3.5,
    run_velocity = 5.5,
    
    view_range = 10,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    floats = 1,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
        run_start = 41,
        run_end = 60,
        jump_start = 61,
        jump_end = 80
    },

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), "O ouriço é amigável, mas cuidado ao atacá-lo!")
        end
    end,
})

-- Spawn do Ouriço (grama)
mobs:spawn({
    name = "nh_mob:ouricoshadow",
    nodes = {"air"},
    neighbors = {"nh_nodes:grass"},
    max_light = 15,
    interval = 120,
    chance = 300,
    active_object_count = 1,
    min_height = -10,
    max_height = 25
})

mobs:register_egg("nh_mob:ouricoshadow", "Orbe com Ouriço Raro", "orbspawner.png", 0)

-------------------------------
-- MOB 2: COELHO (Passivo/Tímido)
-------------------------------

mobs:register_mob("nh_mob:coelho", {
    type = "animal",
    passive = true,           -- Totalmente passivo
    damage = 0,               -- Não causa dano
    
    hp_min = 5,
    hp_max = 8,
    armor = 80,
    
    collisionbox = {-0.2, 0, -0.3, 0.2, 0.4, 0.3},
    physical = true,
    stepheight = 1.1,
    fall_speed = -8,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "rabbit.obj",      -- Você precisa criar este modelo
    textures = {"rabbit.png"}, -- Você precisa criar esta textura
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 2,
    run_velocity = 6,         -- Coelhos são rápidos quando assustados
    
    view_range = 8,
    water_damage = 1,
    lava_damage = 5,
    light_damage = 0,
    
    -- Coelhos fogem de jogadores
    runaway = true,
    runaway_from = {"player"},
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
        run_start = 41,
        run_end = 60,
    },
    
    -- Coelhos pulam ocasionalmente
    jump = true,
    jump_height = 4,

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), "O coelho fugiu assustado!")
            -- Faz o coelho pular e fugir
            self.object:set_velocity({x = 0, y = 6, z = 0})
        end
    end,
    
    -- Sons (se você tiver arquivos de som)
    sounds = {
        random = "coelho_sound",
        damage = "coelho_hurt",
    },
})

-- Spawn do Coelho (neve)
mobs:spawn({
    name = "nh_mob:coelho",
    nodes = {"air"},
    neighbors = {"nh_nodes:snow"},
    max_light = 15,
    interval = 120,
    chance = 2500,            -- Spawn mais frequente
    active_object_count = 8,  -- Mais coelhos podem spawnar
    min_height = 0,
    max_height = 100
})

mobs:register_egg("nh_mob:coelho", "Orbe com Coelho", "orbspawner.png", 0)

-------------------------------
-- MOB 3: GALO (Agressivo)
-------------------------------

mobs:register_mob("nh_mob:galo", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    -- drop com a sintaxe correta
    drops = {
        {name = "items:feather", chance = 1, min = 1, max = 5},  -- 1-5 penas
        {name = "nh_nodes:raw_chicken", chance = 1, min = 1, max = 1},  -- 1 galinha crua (sempre)
    },
    
    hp_min = 4,
    hp_max = 8,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    selectionbox = {-0.5, 0, -0.2, 0.5, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    physical = true,
    stepheight = 1.1,
    fall_speed = -3,          -- Galinhas caem devagar (batem asas)
    fall_damage = 0,
    floats = 1,               -- Não nadam bem
    
    visual = "mesh",
    mesh = "rooster.obj",     -- Você precisa criar este modelo
    textures = {"rooster.png"}, -- Você precisa criar esta textura
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    -- Galinhas podem ser alimentadas e seguir o jogador com sementes
    follow = {"farming:seed_wheat", "nh_nodes:grassleaves"},


    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            -- Se o jogador está segurando sementes, a galinha segue
            if name == "farming:seed_wheat" or name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), "O galo está interessada na comida!")
            else
                core.chat_send_player(clicker:get_player_name(), "Cocoricó! 🐔")
            end
        end
    end,
    
    -- Sons da galinha
    sounds = {
        random = "galinha_cacarejo",
        damage = "galinha_hurt",
    },
})

-- Spawn da Galinha (terra/dirt)
mobs:spawn({
    name = "nh_mob:galo",
    nodes = {"air"},
    neighbors = {"nh_nodes:dirt", "nh_nodes:grass"},  -- Spawna em dirt e grama
    max_light = 15,
    interval = 120,
    chance = 2000,            -- Spawn frequente
    active_object_count = 2, -- 2 galos
    min_height = -10,
    max_height = 50
})

mobs:register_egg("nh_mob:galo", "Orbe com Galo", "orbspawner.png", 0)

-------------------------------
-- MOB 3: GALINHA (Passiva/Põe Ovos)
-------------------------------

mobs:register_mob("nh_mob:galinha", {
    type = "animal",
    passive = true,
    damage = 0,
    -- drop com a sintaxe correta
    drops = {
        {name = "items:feather", chance = 1, min = 1, max = 5},  -- 1-5 penas
        {name = "nh_nodes:raw_chicken", chance = 1, min = 1, max = 1},  -- 1 galinha crua (sempre)
    },
    
    hp_min = 4,
    hp_max = 8,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    selectionbox = {-0.5, 0, -0.2, 0.5, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    physical = true,
    stepheight = 1.1,
    fall_speed = -3,          -- Galinhas caem devagar (batem asas)
    fall_damage = 0,
    floats = 1,               -- Não nadam bem
    
    visual = "mesh",
    mesh = "chicken.obj",     -- Você precisa criar este modelo
    textures = {"chicken.png"}, -- Você precisa criar esta textura
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 1,
    run_velocity = 3,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    -- Galinhas podem ser alimentadas e seguir o jogador com sementes
    follow = {"farming:seed_wheat", "nh_nodes:grassleaves"},


    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            -- Se o jogador está segurando sementes, a galinha segue
            if name == "farming:seed_wheat" or name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), "A galinha está interessada na comida!")
            else
                core.chat_send_player(clicker:get_player_name(), "Pó pó! 🐔")
            end
        end
    end,
    
    -- Sons da galinha
    sounds = {
        random = "galinha_cacarejo",
        damage = "galinha_hurt",
    },
    
        -- Sistema de ovos
do_custom = function(self, dtime)

    -- Timer geral (limita execução)
    self.step_timer = (self.step_timer or 0) + dtime
    if self.step_timer < 1 then return end
    self.step_timer = 0

    -- Inicializa tempo aleatório UMA VEZ
    if not self.next_egg_time then
        self.next_egg_time = math.random(60, 120)
        self.egg_timer = 0
    end

    -- Contador de ovos
    self.egg_timer = self.egg_timer + 1

    -- Hora de botar ovo
    if self.egg_timer >= self.next_egg_time then

        local pos = self.object:get_pos()
        local yaw = self.object:get_yaw()

        -- Direção para trás da galinha
        local back_dir = {
            x = -math.sin(yaw),
            y = 0,
            z =  math.cos(yaw)
        }

        local egg_pos = vector.add(pos, vector.multiply(back_dir, 0.8))
        egg_pos.y = egg_pos.y + 0.1

        core.add_item(egg_pos, "nh_nodes:chicken_egg")


        log("Galinha botou um ovo em " .. core.pos_to_string(egg_pos))

        -- Avisar jogadores próximos
        for _, player in ipairs(core.get_connected_players()) do
            if vector.distance(player:get_pos(), pos) < 10 then
                core.chat_send_player(
                    player:get_player_name(),
                    "🥚 Uma galinha botou um ovo!"
                )
            end
        end

        -- Reset
        self.egg_timer = 0
        self.next_egg_time = math.random(60, 120)
    end
end,
})

-- Spawn da Galinha (terra/dirt)
mobs:spawn({
    name = "nh_mob:galinha",
    nodes = {"air"},
    neighbors = {"nh_nodes:dirt", "nh_nodes:grass"},  -- Spawna em dirt e grama
    max_light = 15,
    interval = 120,
    chance = 2000,            -- Spawn frequente
    active_object_count = 6, -- 6 galinhas
    min_height = -10,
    max_height = 50
})

mobs:register_egg("nh_mob:galinha", "Orbe com Galinha", "orbspawner.png", 0)

-------------------------------
-- ITEM: OVO
-------------------------------
-- Você pode criar um item de ovo que as galinhas dropam
core.register_craftitem("nh_mob:chicken_egg", { -- Você precisa criar este item nh_nodes:egg
    description = "Ovo de galinha",
    inventory_image = "chicken_egg.png",  -- Textura
    on_use = core.item_eat(2), -- Come o ovo cru (restaura 2 de fome)
})

-------------------------------
-- MOB 4: TUBARÃO (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:shark", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 5,
    attack_type = "dogfight",
    
    hp_min = 20,
    hp_max = 30,
    armor = 100,
    
    collisionbox = {-1.25, 0, -0.2, 1.3, 0.4, 0.2},
    selectionbox = {-1.5, 0, -0.2, 1.5, 0.4, 0.2},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "shark.obj",
    textures = {"shark.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- IMPORTANTE: Propriedades para manter na água
    fly = true,               -- Permite "voar" na água
    fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 2,           -- CRÍTICO: Recebe dano fora da água!
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:raw_chicken"},
    
    -- ADICIONE: Função para forçar o tubarão a voltar para água
    do_custom = function(self, dtime)
        local pos = self.object:get_pos()
        local node = core.get_node(pos)
        
        -- Se não está na água, tenta voltar
        if node.name ~= "nh_nodes:water" then
            -- Procura por água próxima
            local water_pos = core.find_node_near(pos, 5, {"nh_nodes:water"})
            
            if water_pos then
                -- Move em direção à água
                local dir = vector.direction(pos, water_pos)
                self.object:set_velocity(vector.multiply(dir, 2))
            end
        end
    end,
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:raw_chicken" then
                core.chat_send_player(clicker:get_player_name(), "O tubarão está com fome!")
            else
                core.chat_send_player(clicker:get_player_name(), "Glub, glub...")
            end
        end
    end,
    
    sounds = {
        random = "tubarao_som",
        damage = "tubarao_hurt",
    },
})

-- Spawn do tubarão (somente na água)
mobs:spawn({
    name = "nh_mob:shark",
    nodes = {"nh_nodes:water"},           -- Spawna DENTRO da água
    neighbors = {"nh_nodes:wet_sand"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 2,
    min_height = -20,
    max_height = -12                     -- Não spawna acima do nível do mar
})

mobs:register_egg("nh_mob:shark", "Orbe com Tubarão", "orbspawner.png", 0)

-------------------------------
-- MOB 4: RAT/RATAZANA (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:rat", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 2,
    attack_type = "dogfight",
    
    hp_min = 8,
    hp_max = 10,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 0.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 0.4, 0.2},
    physical = true,
    stepheight = 3,
    fall_speed = -8,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "rat.obj",
    textures = {"rat.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- PERMITIRIA "VOAR" DENTRO DAS FOLHAS se não retirasse a capacidade de andar...
    --fly = true,
    --fly_in = {"nh_nodes:leaves"},  -- Pode ser uma lista!
    
    walk_velocity = 3,
    run_velocity = 6,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:blueberry"},

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:blueberry" then
                core.chat_send_player(clicker:get_player_name(), "A ratazana quer comida!")
            else
                core.chat_send_player(clicker:get_player_name(), "Quick, quick...")
            end
        end
    end,
    
    sounds = {
        random = "rat_quick",
        damage = "rat_hurt",
    },
})

-- Spawn da ratazana (grama perto de árvores)
mobs:spawn({
    name = "nh_mob:rat",
    nodes = {"air"},
    neighbors = {"nh_nodes:grass", "nh_nodes:wood", "default:tree"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 3,
    min_height = -20,
    max_height = 30                  
})

mobs:register_egg("nh_mob:rat", "Orbe com Ratazana", "orbspawner.png", 0)



-------------------------------
-- MOB 5: Joaninha 
-------------------------------
mobs:register_mob("nh_mob:ladybug", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    hp_min = 1,
    hp_max = 3,
    armor = 100,
    
    collisionbox = {-0.1, 0, -0.1, 0.1, 0.1, 0.1},
    selectionbox = {-0.1, 0, -0.1, 0.1, 0.1, 0.1},
    physical = true,
    stepheight = 3,
    fall_speed = -8,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "ladybug.obj",
    textures = {"ladybug.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
    --fly = true,
    --fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
    
    walk_velocity = 1,
    run_velocity = 3,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:grassleaves"},

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), "A joaninha quer folhas!")
            else
                core.chat_send_player(clicker:get_player_name(), "bzz, bzz...")
            end
        end
    end,
    
    --sounds = {
   --     random = "rat_quick",
    --    damage = "rat_hurt",
    --},
})



-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
    name = "nh_mob:ladybug",
    nodes = {"air"},
    neighbors = {"nh_nodes:grassleaves"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 3,
    min_height = -20,
    max_height = 30                  
})

mobs:register_egg("nh_mob:ladybug", "Orbe com Joaninha", "orbspawner.png", 0)



-------------------------------
-- MOB 5: Vagalume 
-------------------------------
mobs:register_mob("nh_mob:firefly", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    hp_min = 1,
    hp_max = 3,
    armor = 100,
    
    collisionbox = {-0.1, 0, -0.1, 0.1, 0.1, 0.1},
    selectionbox = {-0.1, 0, -0.1, 0.1, 0.1, 0.1},
    physical = true,
    stepheight = 3,
    fall_speed = -8,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "firefly.obj",
    textures = {"firefly.png"},
        --textures = {"firefly.png^[opacity:200"},
        --    textures = {
        --{"firefly.png^[opacity:200"}  -- Note as chaves duplas!
    --},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- BRILHO 
    glow = 14,  -- Intensidade de 0 a 14 (14 = mais brilhante)

use_texture_alpha = "blend",
    
    -- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
    fly = true,
    fly_in = {"air"},  -- Pode ser uma lista!
    
    walk_velocity = 1,
    run_velocity = 3,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:grassleaves"},

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), "A joaninha quer folhas!")
            else
                core.chat_send_player(clicker:get_player_name(), "bzz, bzz...")
            end
        end
    end,
    
    --sounds = {
   --     random = "rat_quick",
    --    damage = "rat_hurt",
    --},
})


-- Spawn do vagalume (grama perto de árvores)
mobs:spawn({
    name = "nh_mob:firefly",
    nodes = {"air"},
    neighbors = {"nh_nodes:water2"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 3,
    min_height = -20,
    max_height = 30                  
})

mobs:register_egg("nh_mob:firefly", "Orbe com Vagalume", "orbspawner.png", 0)


-------------------------------
-- MOB 5: Touro 
-------------------------------
mobs:register_mob("nh_mob:bull", {
    type = "animal",
    passive = false,
    reach = 7,
    damage = 7,
    attack_type = "dogfight",
    drops = {
        {name = "nh_nodes:cowleather", chance = 1, min = 1, max = 5},  -- 1-5 couros
        {name = "nh_nodes:cowmeat", chance = 1, min = 1, max = 8},  -- 1-8 carnes (sempre)
    },
    
    hp_min = 25,
    hp_max = 35,
    armor = 100,
    
    collisionbox = {-1.8, 0, -0.7, 0.9, 2.6, 0.7},
    selectionbox = {-1.8, 0, -0.7, 0.9, 2.6, 0.7},
    physical = true,
    stepheight = 2,
    fall_speed = -8,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "bull.obj",
    textures = {"bull.png"},
    rotate = 180,
    visual_size = {x = 7.5, y = 7.5},
    
    -- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
    --fly = true,
    --fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
    
    walk_velocity = 3,
    run_velocity = 6,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:grassleaves"},

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), "Muuumm!")
            else
                core.chat_send_player(clicker:get_player_name(), "hff, hff...")
            end
        end
    end,
    
    --sounds = {
   --     random = "rat_quick",
    --    damage = "rat_hurt",
    --},
})

-- Spawn do touro (folhas de grama)
mobs:spawn({
    name = "nh_mob:bull",
    nodes = {"air"},
    neighbors = {"nh_nodes:grassleaves"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 3,
    min_height = -20,
    max_height = 30                  
})

mobs:register_egg("nh_mob:bull", "Orbe com Touro", "orbspawner.png", 0)



-------------------------------
-- MOB 4: PLANARIA SLIME (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:slime", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 0.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 0.4, 0.2},
    physical = true,
    stepheight = 3,           -- Consegue subir no player (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "planaria_slime_small2.obj",
    textures = {"planaria_slime2.png^[opacity:200"}, --{{"planaria_slime3.png","planaria_slime3.png"}}
    rotate = 180,
    visual_size = {x = 10, y = 10},
    
    -- BRILHO NOS OLHOS
    glow = 5,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    -- TRANSPARENCIA
    use_texture_alpha = "blend",  -- Tente "blend" em vez de true -> use_texture_alpha = true,  -- Habilita transparência
    --backface_culling = true,   -- Renderiza ambos os lados das faces
    
    walk_velocity = 1,
    run_velocity = 2,
    
    view_range = 7,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:raw_chicken"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:raw_chicken" then
                core.chat_send_player(clicker:get_player_name(), "O slime quer comida!")
            else
                core.chat_send_player(clicker:get_player_name(), "O.O")
            end
        end
    end,
    
    sounds = {
        random = "slime_som",
        damage = "slime_hurt",
    },
})


-------------------------------
-- MOB 4: Aguia (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:eagle", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 2,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "eagle.obj",
    textures = {"eagle.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15}, -- visual_size = {x = 2.1, y = 2.1},
    
    -- IMPORTANTE: Propriedades para manter na água
    fly = true,               -- Permite "voar" na água
    fly_in = "air",   -- Voa no ar
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 1,
        walk_start = 1,
        walk_end = 2,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 11.54,    -- Frame inicial do ataque
        punch_end = 16,      -- Frame final do ataque
        --punch_speed = 20, -- vel 1-30
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), "O vulto não quer luz!")
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    sounds = {
        random = "vulto_som",
        damage = "vulto_hurt",
    },
})

-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
    name = "nh_mob:eagle",
    nodes = {"air"}, -- nh_nodes = {"nh_nodes:water"},
    neighbors = {"nh_nodes:leaves"}, --neighbors = {"nh_nodes:wet_sand"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = 10,
    max_height = 50                  
})

mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)


-------------------------------
-- MOB 4: Fenix (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:phoenix", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 2,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "eagle.obj",
    textures = {"phoenix.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15}, -- visual_size = {x = 2.1, y = 2.1},
    
    -- IMPORTANTE: Propriedades para manter na água
    fly = true,               -- Permite "voar" na água
    fly_in = "air",   -- Voa no ar
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 1,
        walk_start = 1,
        walk_end = 2,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 11.54,    -- Frame inicial do ataque
        punch_end = 16,      -- Frame final do ataque
        --punch_speed = 20, -- vel 1-30
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), "O vulto não quer luz!")
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    sounds = {
        random = "vulto_som",
        damage = "vulto_hurt",
    },
})

-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
    name = "nh_mob:phoenix",
    nodes = {"air"}, -- nh_nodes = {"nh_nodes:water"},
    neighbors = {"nh_nodes:basalt"}, --neighbors = {"nh_nodes:wet_sand"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = 20,
    max_height = 50                  
})

mobs:register_egg("nh_mob:phoenix", "Orbe com Fênix", "orbspawner.png", 0)


-- Spawn da slime (cavernas)
mobs:spawn({
    name = "nh_mob:slime",
    nodes = {"air"},
    neighbors = {"nh_nodes:gneiss", "nh_nodes:water"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 5,
    min_height = -25,
    max_height = -5                 
})

mobs:register_egg("nh_mob:slime", "Orbe com Slime", "orbspawner.png", 0)


-------------------------------
-- MOB 4: VULTO / VISAGE (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:visage", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 5,
    attack_type = "dogfight",
    
    hp_min = 20,
    hp_max = 30,
    armor = 100,
    
    collisionbox = {-0.25, -2, -0.2, 0.3, 0.4, 0.2},
    selectionbox = {-0.5, -2, -0.2, 0.5, 0.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "vulto.obj",
    textures = {"vulto.png^[opacity:200"},
    use_texture_alpha = "blend",
    rotate = 180,
    visual_size = {x = 2, y = 2},
    
    -- BRILHO NOS OLHOS
    glow = 14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
    -- IMPORTANTE: Propriedades para manter na água
    fly = true,               -- Permite "voar" na água
    fly_in = "air",   -- Voa no ar
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 2,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 15,
        stand_start = 0,
        stand_end = 20,
        walk_start = 21,
        walk_end = 40,
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), "O vulto não quer luz!")
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    sounds = {
        random = "vulto_som",
        damage = "vulto_hurt",
    },
})

-- Spawn do vulto (fundo de cavernas escuras)
mobs:spawn({
    name = "nh_mob:visage",
    nodes = {"air"},
    neighbors = {"nh_nodes:gneiss", "nh_nodes:water"},
    max_light = 1,
    interval = 120,
    chance = 2000,
    active_object_count = 2,
    min_height = -50,
    max_height = -20                  
})

mobs:register_egg("nh_mob:visage", "Orbe com Vulto", "orbspawner.png", 0)



-------------------------------
-- MOB 4: Dopel (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:dopel", {
    type = "monster",
    passive = false,
    reach = 2,
    damage = 5,
    attack_type = "dogfight",
    
    hp_min = 20,
    hp_max = 30,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "character2.glb",
    textures = {"skin.png"},
    --rotate = 180,
    visual_size = {x = 1, y = 1},
    
    -- BRILHO NOS OLHOS
    glow = -14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = true,               -- Permite "voar" na água
    --fly_in = "air",   -- Voa no ar
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 2,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 1,
        walk_start = 1,
        walk_end = 2,
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), "O vulto não quer luz!")
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    sounds = {
        random = "vulto_som",
        damage = "vulto_hurt",
    },
    
    custom_attack = function(self, to_attack)
	self.attack_count = (self.attack_count or 0) + 1
	if self.attack_count < 3 then return end
	self.attack_count = 0

	self:set_animation("punch", false)

	return true -- PARA CONTINUAR.
	end,	
})

-- Spawn do vulto (fundo de cavernas escuras)
mobs:spawn({
    name = "nh_mob:dopel",
    nodes = {"air"},
    neighbors = {"nh_nodes:basalt", "nh_nodes:obsidian", "nh_nodes:snow"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = -50,
    max_height = 40                  
})

mobs:register_egg("nh_mob:dopel", "Orbe com Dopel", "orbspawner.png", 0)


-------------------------------
-- MOB 4: Polvo esqueleto (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:octoskull", {
    type = "monster",
    passive = false,
    reach = 2,
    damage = 5,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    hp_min = 20,
    hp_max = 30,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "octopusskull.glb",
    textures = {"octopusskull.png"},
    --rotate = 180,
    visual_size = {x = 2, y = 2}, -- visual_size = {x = 2.1, y = 2.1},
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = true,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Voa no ar
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 1,
        walk_start = 1,
        walk_end = 2,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 11.54,    -- Frame inicial do ataque
        punch_end = 16,      -- Frame final do ataque
        --punch_speed = 20, -- vel 1-30
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), "O vulto não quer luz!")
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    sounds = {
        random = "vulto_som",
        damage = "vulto_hurt",
    },
    
    custom_attack = function(self, to_attack)
	self.attack_count = (self.attack_count or 0) + 1
	if self.attack_count < 3 then return end
	self.attack_count = 0

	self:set_animation("punch", false)

	return true -- PARA CONTINUAR.
	end,	
})

-- Spawn do vulto (fundo de cavernas escuras)
mobs:spawn({
    name = "nh_mob:octoskull",
    nodes = {"nh_nodes:water"}, -- nh_nodes = {"nh_nodes:water"},
    neighbors = {"nh_nodes:oakwood"}, --neighbors = {"nh_nodes:wet_sand"},
    max_light = 10,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = -50,
    max_height = 3                  
})

mobs:register_egg("nh_mob:octoskull", "Orbe com Exopolvo", "orbspawner.png", 0)


-------------------------------
-- MOB 4: Sereia / sirenia /mermaid (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:sirenia", {
    type = "monster",
    passive = false,
    reach = 2,
    damage = 1,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    hp_min = 20,
    hp_max = 30,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "sirenia.glb",
    textures = {"sirenia.png"},
    --rotate = 180,
    visual_size = {x = 2, y = 2}, -- visual_size = {x = 2.1, y = 2.1},
    
    -- IMPORTANTE: Propriedades para manter na água
    fly = true,               -- Permite "voar" na água
    fly_in = "nh_nodes:water",   -- Nada na agua
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 1,
        walk_start = 1,
        walk_end = 2,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 11.54,    -- Frame inicial do ataque
        punch_end = 16,      -- Frame final do ataque
        --punch_speed = 20, -- vel 1-30
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), "O vulto não quer luz!")
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    sounds = {
        random = "vulto_som",
        damage = "vulto_hurt",
    },
    
    	custom_attack = function(self, to_attack)
  
	self.attack_count = (self.attack_count or 0) + 1
	if self.attack_count < 3 then return end
	self.attack_count = 0

	self:set_animation("punch", false)

	return true -- PARA CONTINUAR.
	end,	
})

-- Spawn do vulto (fundo de cavernas escuras)
mobs:spawn({
    name = "nh_mob:sirenia",
    nodes = {"nh_nodes:water"}, -- nh_nodes = {"nh_nodes:water"},
    neighbors = {"nh_nodes:ice"}, --neighbors = {"nh_nodes:obsidian"},
    max_light = 10,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = -20,
    max_height = 0   -- -10               
})

mobs:register_egg("nh_mob:sirenia", "Orbe com Sirenia", "orbspawner.png", 0)

-------------------------------
-- LOGS FINAIS
-------------------------------

core.register_on_mods_loaded(function()
    log("===========================================")
    log("Mod Mob inicializado com sucesso!")
    log("===========================================")
    log("")
    log("OURIÇO:")
    log("  - Spawn: nh_nodes:grass")
    log("  - Comportamento: Passivo, mas se defende quando atacado")
    log("  - Dano: 2 HP")
    log("")
    log("COELHO:")
    log("  - Spawn: nh_nodes:snow")
    log("  - Comportamento: Totalmente passivo e tímido")
    log("  - Foge de jogadores")
    log("")
    log("GALINHA:")
    log("  - Spawn: nh_nodes:dirt e nh_nodes:grass")
    log("  - Comportamento: Passiva, segue jogadores com sementes")
    log("  - Bota ovos periodicamente")
    log("")
    log("===========================================")
end)
