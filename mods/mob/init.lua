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

local S = minetest.get_translator("nh_mob")

--mobs:set_spawn_setting("spawn", true)
--mobs:set_spawn_setting("remove_far", false)

-------------------------------
-- MOB 4: RAT/RATAZANA (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:rat", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 2,
    attack_type = "dogfight",
    
    description = S("Rat"),
    
    -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:cricket", "nh_mob:cicada"},
    
    follow = {"nh_nodes:chicken_egg", "nh_nodes:friedchickenegg", "nh_nodes:raw_chicken", "nh_nodes:blueberry"},
    
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
    mesh = "rat.glb",
    textures = {"rat.png"},
    --rotate = 180,
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
        speed_normal = 1,
        stand_start = 0.25,
        stand_end = 1.25,
        walk_start = 1.5,
        walk_end = 2.5,
    },

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:blueberry" then
                core.chat_send_player(clicker:get_player_name(), S("The rat wants food!"))
            else
                core.chat_send_player(clicker:get_player_name(), S("Quick, quick..."))
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

--mobs:register_egg("nh_mob:rat", "Orbe com Ratazana", "orbspawner.png", 0)
register_orb_egg("nh_mob:rat", S("Orb with Rat"))


-------------------------------
-- MOB 5: Joaninha 
-------------------------------
mobs:register_mob("nh_mob:ladybug", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Ladybug"),
    
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
                core.chat_send_player(clicker:get_player_name(), S("The ladybug wants leaves!"))
            else
                core.chat_send_player(clicker:get_player_name(), S("bzz, bzz..."))
            end
        end
    end,
    
    sounds = {
        random = "LadybugSound",
        damage = "LadybugSound",
    },
})



-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
    name = "nh_mob:ladybug",
    nodes = {"air"},
    neighbors = {"nh_nodes:grassleaves"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = 0,
    max_height = 30                  
})

--mobs:register_egg("nh_mob:ladybug", "Orbe com Joaninha", "orbspawner.png", 0)
register_orb_egg("nh_mob:ladybug",  S("Orb with Ladybug"))

-------------------------------
-- MOB 5: Grilo 
-------------------------------
mobs:register_mob("nh_mob:cricket", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description =  S("Cricket"),
    
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
    mesh = "cricket.glb",
    textures = {"cricket.png"},
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    after_activate = function(self, staticdata, def, dtime)
        self.object:set_properties({
            backface_culling = false,
        })
    end,
    
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
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0,
        walk_start = 0,
        walk_end = 0.5,
    },
    
    follow = {"nh_nodes:grassleaves"},

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), S("The cricket ate the leaves!"))
            else
                core.chat_send_player(clicker:get_player_name(), "cri-cri, cri-cri...")
            end
        end
    end,
    
    sounds = {
        random = "CricketsSound",
        damage = "CricketsSound",
    },
})



-- Spawn da grilo (grama)
mobs:spawn({
    name = "nh_mob:cricket",
    nodes = {"air"},
    neighbors = {"nh_nodes:grassleaves"},
    max_light = 10,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = 0,
    max_height = 30                  
})

--mobs:register_egg("nh_mob:cricket", "Orbe com Grilo", "orbspawner.png", 0)
register_orb_egg("nh_mob:cricket",  S("Orb with Cricket"))

-------------------------------
-- MOB 5: Cigarra 
-------------------------------
mobs:register_mob("nh_mob:cicada", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Cicada"),
    
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
    mesh = "cicada.obj",
    textures = {"cicada.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    after_activate = function(self, staticdata, def, dtime)
        self.object:set_properties({
            backface_culling = false,
        })
    end,
    
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
    
    sounds = {
        random = "CicadaSound",
        damage = "CicadaSound",
    },
})



-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
    name = "nh_mob:cicada",
    nodes = {"air"},
    neighbors = {"nh_nodes:leaves"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 2,
    min_height = 0,
    max_height = 30                  
})

--mobs:register_egg("nh_mob:cicada", "Orbe com Cigarra", "orbspawner.png", 0)
register_orb_egg("nh_mob:cicada",  S("Orb with Cicada"))

-------------------------------
-- MOB 5: Vagalume 
-------------------------------
mobs:register_mob("nh_mob:firefly", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Firefly"),
    
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
    mesh = "firefly.glb",
    textures = {"firefly.png"},

    after_activate = function(self, staticdata, def, dtime)
        self.object:set_properties({
            backface_culling = false,
            use_texture_alpha = true,
        })
    end,

    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- BRILHO 
    glow = 14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
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
        stand_end = 0.5,
        walk_start = 0,
        walk_end = 0.5,
    },
    
    follow = {"nh_nodes:fireflybottle"}, --"nh_nodes:apple", 

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:bottle" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona fireflybottle ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:fireflybottle"))
            
                -- Remove o vagalume
                self.object:remove()
            
            elseif name == "nh_nodes:apple" then
                core.chat_send_player(clicker:get_player_name(), "bzz, bzz...")
            else
                core.chat_send_player(clicker:get_player_name(), S("The firefly wants to eat an apple!"))
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
    neighbors = {"nh_nodes:water2", "nh_nodes:grassleaves"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 3,
    min_height = -10,
    max_height = 30                  
})

--mobs:register_egg("nh_mob:firefly", "Orbe com Vaga-lume", "orbspawner.png", 0)
register_orb_egg("nh_mob:firefly", S("Orb with Firefly"))


-------------------------------
-- MOB 5: Cigarra 
-------------------------------
mobs:register_mob("nh_mob:worm", {
    type = "animal",
    passive = true,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Worm"),
    
    hp_min = 1,
    hp_max = 3,
    armor = 100,
    
    collisionbox = {-0.1, 0, -0.1, 0.1, 0.1, 0.1},
    selectionbox = {-0.1, 0, -0.1, 0.1, 0.1, 0.1},
    physical = true,
    stepheight = 1,
    fall_speed = -10,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "worm.glb",
    textures = {"worm.png"},
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 1,
    run_velocity = 2,
    
    view_range = 5,
    water_damage = 1,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 0.75,
        stand_start = 0,
        stand_end = 0,
        walk_start = 0,
        walk_end = 0.75,
    },
    
    follow = {"nh_nodes:dirt"},

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                item:take_item()
                clicker:set_wielded_item(item)

                -- Define inv ANTES de usar
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:worm"))

                self.object:remove()
                
            elseif name == "nh_nodes:dirt" then
                core.chat_send_player(clicker:get_player_name(), S("The worm wants dirt!"))
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    --sounds = {
    --    random = "CicadaSound",
    --    damage = "CicadaSound",
    --},
})



-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
    name = "nh_mob:worm",
    nodes = {"air"},
    neighbors = {"nh_nodes:dirt"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 2,
    min_height = 0,
    max_height = 30                  
})

--mobs:register_egg("nh_mob:worm", "Orbe com Minhoca", "orbspawner.png", 0)
register_orb_egg("nh_mob:worm", S("Orb with Worm"))

-------------------------------
-- MOB 5: Touro 
-------------------------------
mobs:register_mob("nh_mob:bull", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 7,
    attack_type = "dogfight",
    drops = {
        {name = "nh_nodes:cowleather", chance = 1, min = 1, max = 4},  -- 1-4 couros
        {name = "nh_nodes:cowmeat", chance = 1, min = 2, max = 5},  -- 2-7 carnes (sempre)
        {name = "nh_nodes:bone", chance = 1, min = 2, max = 5},  -- 2-7 ossos (sempre)
    },
    
    description = S("Bull"),
    
    hp_min = 25,
    hp_max = 35,
    armor = 100,
    
    collisionbox = {-2.5, 0, -0.7, 0.9, 2.6, 0.7},
    selectionbox = {-2.5, 0, -0.7, 0.9, 2.6, 0.7},
    physical = true,
    stepheight = 2,
    fall_speed = -8,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "bull.glb",
    textures = {"bull2.png"},
    --rotate = 180,
    visual_size = {x = 7.5, y = 7.5},
    
    -- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
    --fly = true,
    --fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
    
    walk_velocity = 1,
    run_velocity = 6,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    follow = {"nh_nodes:grassleaves"},

    
    sounds = {
        random = "BullSound",
        damage = "BullAngrySound",
    },
    
    animation = {
        speed_normal = 1,
        stand_start = 0.5,
        stand_end = 0.5,
        walk_start = 1,
        walk_end = 5,
        run_start = 5.25,
        run_end = 6.25,
        -- Animação usada ao montar (pode usar a mesma de corrida)
        ride_start = 5.25,
        ride_end = 6.25,
    },
    
    -- MONTARIA
    saddle = "mobs:saddle",           -- item de sela necessário
    ride_speed = 8,                   -- velocidade montado
    ride_acceleration = 1.0,          -- aceleração montado
    ride_friction = 0.8,              -- fricção ao parar
    
    -- Offset do jogador sobre o mob (ajuste conforme o visual do touro)
    driver_attach_at = {x = 0, y = 30, z = -5},
    driver_eye_offset = {x = 0, y = 3, z = 0},
    driver_scale_factor = 1,

on_rightclick = function(self, clicker)
    if not clicker:is_player() then return end

    if mobs:protect(self, clicker) then return end
    if mobs:feed_tame(self, clicker, 1, false, false) then return end

    -- Se já tem alguém montado, desmonta
    if self.driver then
        mobs:detach(self.driver, {x=1, y=0, z=0})
        self.driver = nil
        return
    end

    local item = clicker:get_wielded_item()
    local name = item:get_name()

    -- Coloca a sela E já monta
    if name == "mobs:saddle" then
        self.saddled = true  -- flag interna
        item:take_item()
        clicker:set_wielded_item(item)
        core.chat_send_player(clicker:get_player_name(), S("Saddle placed!"))
        mobs:attach(self, clicker)  -- já monta na hora
        return
    end

    -- Clicou sem sela na mão: monta se já estiver selado
    if self.saddled then
        mobs:attach(self, clicker)
        return
    end

	if name == "nh_nodes:grassleaves" or "nh_nodes:grassleavesmedium" then
	    core.chat_send_player(clicker:get_player_name(), S("You fed the bull! Mooo!"))
	elseif name == "" then
	    -- mão vazia
	    core.chat_send_player(clicker:get_player_name(), S("You petted the bull. hff, hff..."))
	else
	    -- item errado
	    core.chat_send_player(clicker:get_player_name(), S("The bull is not interested in that..."))
	end
end,
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

--mobs:register_egg("nh_mob:bull", "Orbe com Touro", "orbspawner.png", 0)
register_orb_egg("nh_mob:bull", S("Orb with Bull"))


mobs:register_mob("nh_mob:ox", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 7,
    attack_type = "dogfight",
    drops = {
        {name = "nh_nodes:cowleather", chance = 1, min = 1, max = 4},  -- 1-4 couros
        {name = "nh_nodes:cowmeat", chance = 1, min = 2, max = 5},  -- 2-7 carnes (sempre)
        {name = "nh_nodes:bone", chance = 1, min = 2, max = 5},  -- 2-7 ossos (sempre)
    },
    
    description = S("Ox"),
    
    hp_min = 25,
    hp_max = 35,
    armor = 100,
    
    collisionbox = {-2.5, 0, -0.7, 0.9, 2.6, 0.7},
    selectionbox = {-2.5, 0, -0.7, 0.9, 2.6, 0.7},
    physical = true,
    stepheight = 2,
    fall_speed = -8,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "bull.glb",
    textures = {"bull.png"},
    --rotate = 180,
    visual_size = {x = 7.5, y = 7.5},
    
    -- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
    --fly = true,
    --fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
    
    walk_velocity = 1,
    run_velocity = 6,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    follow = {"nh_nodes:grassleaves"},

    
    sounds = {
        random = "BullSound",
        damage = "BullAngrySound",
    },
    
    animation = {
        speed_normal = 1,
        stand_start = 0.5,
        stand_end = 0.5,
        walk_start = 1,
        walk_end = 5,
        run_start = 5.25,
        run_end = 6.25,
        -- Animação usada ao montar (pode usar a mesma de corrida)
        ride_start = 5.25,
        ride_end = 6.25,
    },
    
    -- MONTARIA
    saddle = "mobs:saddle",           -- item de sela necessário
    ride_speed = 8,                   -- velocidade montado
    ride_acceleration = 1.0,          -- aceleração montado
    ride_friction = 0.8,              -- fricção ao parar
    
    -- Offset do jogador sobre o mob (ajuste conforme o visual do touro)
    driver_attach_at = {x = 0, y = 30, z = -5},
    driver_eye_offset = {x = 0, y = 3, z = 0},
    driver_scale_factor = 1,

on_rightclick = function(self, clicker)
    if not clicker:is_player() then return end

    if mobs:protect(self, clicker) then return end
    if mobs:feed_tame(self, clicker, 1, false, false) then return end

    -- Se já tem alguém montado, desmonta
    if self.driver then
        mobs:detach(self.driver, {x=1, y=0, z=0})
        self.driver = nil
        return
    end

    local item = clicker:get_wielded_item()
    local name = item:get_name()

    -- Coloca a sela E já monta
    if name == "mobs:saddle" then
        self.saddled = true  -- flag interna
        item:take_item()
        clicker:set_wielded_item(item)
        core.chat_send_player(clicker:get_player_name(), S("Saddle placed!"))
        mobs:attach(self, clicker)  -- já monta na hora
        return
    end

    -- Clicou sem sela na mão: monta se já estiver selado
    if self.saddled then
        mobs:attach(self, clicker)
        return
    end

	if name == "nh_nodes:grassleaves" or "nh_nodes:grassleavesmedium" then
	    core.chat_send_player(clicker:get_player_name(), S("You fed the ox! Mooo!"))
	elseif name == "" then
	    -- mão vazia
	    core.chat_send_player(clicker:get_player_name(), S("You petted the ox. hff, hff..."))
	else
	    -- item errado
	    core.chat_send_player(clicker:get_player_name(), S("The ox is not interested in that..."))
	end
end,
})

register_orb_egg("nh_mob:ox", S("Orb with Ox"))

-------------------------------
-- MOB 4: Aguia (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:eagle", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 2,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    description = S("Eagle"),
    
    -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:rat", "nh_mob:rabbit"},
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.5, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "eagle.glb",
    textures = {"eagle.png"},
    --rotate = 180,
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
        speed_normal = 0.1,
        stand_start = 0,
        stand_end = 0.5,
        walk_start = 0.7,
        walk_end = 0.8,
        
    fly_up_start = 0.75,
    fly_up_end = 0.75,

    fly_down_start = 0.75,
    fly_down_end = 0.75,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 0.5,    -- Frame inicial do ataque
        punch_end = 1,      -- Frame final do ataque
        punch_speed = 1, -- vel 1-30
    },
    
    sounds = {
        random = "EagleSound",
        damage = "EagleSound",
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), S("The eagle doesn't want light!"))
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    
    
    do_custom = function(self, dtime)

    local vel = self.object:get_velocity()

    if not vel then return end

    -- Subindo
    if vel.y > 0.5 then
        if self.state ~= "fly_up" then
            self.state = "fly_up"
            self:set_animation("fly_up")
        end

    -- Descendo
    elseif vel.y < -0.5 then
        if self.state ~= "fly_down" then
            self.state = "fly_down"
            self:set_animation("fly_down")
        end

    -- Movimento normal
    else
        if self.state ~= "walk" then
            self.state = "walk"
            self:set_animation("walk")
        end
    end
    


    -- controla timer para não rodar todo tick
    self.perch_timer = (self.perch_timer or 0) + dtime

    if self.perch_timer < 3 then
        return
    end

    self.perch_timer = 0

    local time = minetest.get_timeofday()

    -- Só tenta pousar de noite
    if time > 0.75 or time < 0.2 then

        if not self.is_perching then

            local pos = self.object:get_pos()
            local leaves = minetest.find_node_near(pos, 6, {"nh_nodes:oaktimber"})

		if leaves then

		    leaves.y = leaves.y + 1

		    self.object:set_pos(leaves)
		    self.object:set_velocity({x=0,y=0,z=0})
		    self.object:set_acceleration({x=0,y=0,z=0})

		    self.fly = false
		    self.walk_velocity = 0
		    self.run_velocity = 0

		    self.is_perching = true
		    self.eagle_anim_state = "perch"
		    self:set_animation("stand")

		end
        end
    else
        -- Se amanheceu, volta a voar
	if self.is_perching then
	    self.is_perching = false

	    self.fly = true
	    self.walk_velocity = 1
	    self.run_velocity = 4
    -- restaura aceleração padrão de voo
    self.object:set_acceleration({x=0, y=0, z=0})

    -- impulso inicial
    self.object:set_velocity({x=5,y=5,z=5})

	    self:set_animation("walk")
	end
    end

    
end,

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

--mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)
register_orb_egg("nh_mob:eagle", S("Orb with Eagle"))


-------------------------------
-- MOB 4: Milhafre (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:blackkite", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 2,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    description = S("Black Kite"),
    
    -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:rat", "nh_mob:rabbit"},
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.5, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "eagle.glb",
    textures = {"blackkite.png"},
    --rotate = 180,
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
        speed_normal = 0.1,
        stand_start = 0,
        stand_end = 0.5,
        walk_start = 0.7,
        walk_end = 0.8,
        
    fly_up_start = 0.75,
    fly_up_end = 0.75,

    fly_down_start = 0.75,
    fly_down_end = 0.75,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 0.5,    -- Frame inicial do ataque
        punch_end = 1,      -- Frame final do ataque
        punch_speed = 1, -- vel 1-30
    },
    
    sounds = {
        random = "EagleSound",
        damage = "EagleSound",
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), S("The black kite wants the torch!"))
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    
    
    do_custom = function(self, dtime)

    local vel = self.object:get_velocity()

    if not vel then return end

    -- Subindo
    if vel.y > 0.5 then
        if self.state ~= "fly_up" then
            self.state = "fly_up"
            self:set_animation("fly_up")
        end

    -- Descendo
    elseif vel.y < -0.5 then
        if self.state ~= "fly_down" then
            self.state = "fly_down"
            self:set_animation("fly_down")
        end

    -- Movimento normal
    else
        if self.state ~= "walk" then
            self.state = "walk"
            self:set_animation("walk")
        end
    end
    


    -- controla timer para não rodar todo tick
    self.perch_timer = (self.perch_timer or 0) + dtime

    if self.perch_timer < 3 then
        return
    end

    self.perch_timer = 0

    local time = minetest.get_timeofday()

    -- Só tenta pousar de noite
    if time > 0.75 or time < 0.2 then

        if not self.is_perching then

            local pos = self.object:get_pos()
            local leaves = minetest.find_node_near(pos, 6, {"nh_nodes:oaktimber"})

		if leaves then

		    leaves.y = leaves.y + 1

		    self.object:set_pos(leaves)
		    self.object:set_velocity({x=0,y=0,z=0})
		    self.object:set_acceleration({x=0,y=0,z=0})

		    self.fly = false
		    self.walk_velocity = 0
		    self.run_velocity = 0

		    self.is_perching = true
		    self.eagle_anim_state = "perch"
		    self:set_animation("stand")

		end
        end
    else
        -- Se amanheceu, volta a voar
	if self.is_perching then
	    self.is_perching = false

	    self.fly = true
	    self.walk_velocity = 1
	    self.run_velocity = 4
    -- restaura aceleração padrão de voo
    self.object:set_acceleration({x=0, y=0, z=0})

    -- impulso inicial
    self.object:set_velocity({x=5,y=5,z=5})

	    self:set_animation("walk")
	end
    end

    
end,

})

-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
    name = "nh_mob:blackkite",
    nodes = {"air"}, -- nh_nodes = {"nh_nodes:water"},
    neighbors = {"nh_nodes:leaves"}, --neighbors = {"nh_nodes:wet_sand"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = 10,
    max_height = 50                  
})

--mobs:register_egg("nh_mob:blackkite", "Orbe com Milhafre", "orbspawner.png", 0)
register_orb_egg("nh_mob:blackkite", S("Orb with Black Kite"))

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
    
    description = S("Phoenix") .. "\n" .. S("[Altered Animal]"),
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.5, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "eagle.glb",
    textures = {"phoenix.png"},
    --rotate = 180,
    visual_size = {x = 30, y = 30}, -- visual_size = {x = 2.1, y = 2.1},
    
    -- BRILHO 
    glow = 14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
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
        speed_normal = 0.2,
        stand_start = 0,
        stand_end = 0.5,
        walk_start = 0.7,
        walk_end = 0.8,
        
    fly_up_start = 0.75,
    fly_up_end = 0.75,

    fly_down_start = 0.75,
    fly_down_end = 0.75,
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 0.5,    -- Frame inicial do ataque
        punch_end = 1,      -- Frame final do ataque
        punch_speed = 1, -- vel 1-30
    },
    
    sounds = {
        random = "EagleSound",
        damage = "EagleSound",
    },
    
    follow = {"nh_nodes:torch2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), S("The phoenix wants fire!"))
            else
                core.chat_send_player(clicker:get_player_name(), "...")
            end
        end
    end,
    
    
    
        do_custom = function(self, dtime)

    local vel = self.object:get_velocity()

    if not vel then return end

    -- Subindo
    if vel.y > 0.5 then
        if self.state ~= "fly_up" then
            self.state = "fly_up"
            self:set_animation("fly_up")
        end

    -- Descendo
    elseif vel.y < -0.5 then
        if self.state ~= "fly_down" then
            self.state = "fly_down"
            self:set_animation("fly_down")
        end

    -- Movimento normal
    else
        if self.state ~= "walk" then
            self.state = "walk"
            self:set_animation("walk")
        end
    end
    


    -- controla timer para não rodar todo tick
    self.perch_timer = (self.perch_timer or 0) + dtime

    if self.perch_timer < 3 then
        return
    end

    self.perch_timer = 0

    local time = minetest.get_timeofday()

    -- Só tenta pousar de noite
    if time > 0.75 or time < 0.2 then

        if not self.is_perching then

            local pos = self.object:get_pos()
            local leaves = minetest.find_node_near(pos, 6, {"nh_nodes:magma"})

		if leaves then

		    leaves.y = leaves.y + 1

		    self.object:set_pos(leaves)
		    self.object:set_velocity({x=0,y=0,z=0})
		    self.object:set_acceleration({x=0,y=0,z=0})

		    self.fly = false
		    self.walk_velocity = 0
		    self.run_velocity = 0

		    self.is_perching = true
		    self.eagle_anim_state = "perch"
		    self:set_animation("stand")

		end
        end
    else
        -- Se amanheceu, volta a voar
	if self.is_perching then
	    self.is_perching = false

	    self.fly = true
	    self.walk_velocity = 1
	    self.run_velocity = 4
    -- restaura aceleração padrão de voo
    self.object:set_acceleration({x=0, y=0, z=0})

    -- impulso inicial
    self.object:set_velocity({x=5,y=5,z=5})

	    self:set_animation("walk")
	end
    end
end,
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
    min_height = 15,
    max_height = 50                  
})

--mobs:register_egg("nh_mob:phoenix", "Orbe com Fênix", "orbspawner.png", 0)
register_orb_egg("nh_mob:phoenix", S("Orb with Phoenix"))

-------------------------------
-- MOB 1: OURIÇO (Defensivo)
-------------------------------

mobs:register_mob("nh_mob:hedgehog", {
    type = "animal",
    passive = true,          -- Pode se defender quando atacado
    damage = 5,
    reach = 1,
    
    description = S("Hedgehog"),
    
    hp_min = 10,
    hp_max = 15,
    armor = 100,
    
    collisionbox = {-0.3, 0, -0.25, 0.25, 0.4, 0.25},
    physical = true,
    stepheight = 1.1,
    fall_speed = -8,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "ourico.glb",
    textures = {"ouricoskin.png"},
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:cricket", "nh_mob:cicada",  "nh_mob:ladybug"},
    
    walk_velocity = 1.5,
    run_velocity = 4.5,
    
    view_range = 10,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 1,
        stand_start = 0.125,
        stand_end = 0.625,
        walk_start = 0.75,
        walk_end = 1.25,
        run_start = 0.75,
        run_end = 1.25,
        --jump_start = 61,
        --jump_end = 80
    },

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), S("The hedgehog is friendly, but be careful when attacking it!"))
        end
    end,
    
do_punch = function(self, hitter, tflp, tool_caps, dir, damage)
    -- só age se for jogador de mão vazia
    if not hitter:is_player() then return end -- dano normal pra outros mobs

    local item = hitter:get_wielded_item()
    if item:get_name() == "" then
        -- machuca o jogador
        hitter:set_hp(hitter:get_hp() - 2)
        core.chat_send_player(hitter:get_player_name(), S("The spines hurt me!"))
        return false -- CANCELA o dano no ouriço
    end
    -- com ferramenta: dano normal (não retorna false)
end,

do_custom = function(self, dtime)
    self._spike_timer = (self._spike_timer or 0) + dtime
    if self._spike_timer < 1 then return end
    self._spike_timer = 0

    local pos = self.object:get_pos()
    local objetos = core.get_objects_inside_radius(pos, 1)

    for _, obj in ipairs(objetos) do
        if obj ~= self.object then
            local ent = obj:get_luaentity()
            if ent and ent._cmi_is_mob and ent.name ~= "nh_mob:hedgehog" then
                -- aplica dano de espinho no mob próximo (mas ainda sofre dano)
                obj:punch(obj, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 5}
                }, nil)
            end
        end
    end
end,
})

-- Spawn do Ouriço (grama)
mobs:spawn({
    name = "nh_mob:hedgehog",
    nodes = {"air"},
    neighbors = {"nh_nodes:grass"},
    max_light = 15,
    interval = 120,
    chance = 3000,
    active_object_count = 3,
    min_height = -10,
    max_height = 25
})

--mobs:register_egg("nh_mob:ourico", "Orbe com Ouriço", "orbspawner.png", 0)
register_orb_egg("nh_mob:hedgehog", S("Orb with Hedgehog"))

-------------------------------
-- MOB 1: OURIÇO SHADOW (Defensivo)
-------------------------------

mobs:register_mob("nh_mob:hedgehogshadow", {
    type = "animal",
    passive = true,          -- Pode se defender quando atacado
    damage = 2,
    reach = 1,
    
    description = S("Shadow Hedgehog") .. "\n" .. S("[Modified Animal]"),
    
    hp_min = 10,
    hp_max = 15,
    armor = 100,
    
    collisionbox = {-0.3, 0, -0.25, 0.25, 0.4, 0.25},
    physical = true,
    stepheight = 1.1,
    fall_speed = -6,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "ourico.glb",
    textures = {"ouricoshadow.png"},
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
        -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:cricket", "nh_mob:cicada",  "nh_mob:ladybug"},
    
    walk_velocity = 3.5,
    run_velocity = 5.5,
    
    view_range = 10,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    floats = 1,
    
    animation = {
        speed_normal = 1,
        stand_start = 0.125,
        stand_end = 0.625,
        walk_start = 0.75,
        walk_end = 1.25,
        run_start = 0.75,
        run_end = 1.25,
        --jump_start = 61,
        --jump_end = 80
    },

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), S("The hedgehog is friendly, but be careful when attacking it!"))
        end
    end,
    

})

-- Spawn do Ouriço (grama)
mobs:spawn({
    name = "nh_mob:hedgehogshadow",
    nodes = {"air"},
    neighbors = {"nh_nodes:grass"},
    max_light = 15,
    interval = 120,
    chance = 300,
    active_object_count = 1,
    min_height = -10,
    max_height = 25
})

--mobs:register_egg("nh_mob:ouricoshadow", "Orbe com Ouriço Raro", "orbspawner.png", 0)
register_orb_egg("nh_mob:hedgehogshadow", S("Orb with Shadow Hedgehog"))

-------------------------------
-- MOB 2: COELHO (Passivo/Tímido)
-------------------------------

mobs:register_mob("nh_mob:rabbit", {
    type = "animal",
    passive = true,           -- Totalmente passivo
    damage = 0,               -- Não causa dano
    
    description = S("Dwarf Rabbit"),
    
    hp_min = 5,
    hp_max = 8,
    armor = 80,
    
    collisionbox = {-0.2, 0, -0.3, 0.2, 0.4, 0.3},
    physical = true,
    stepheight = 1.1,
    fall_speed = -8,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "rabbit.glb",      
    textures = {"rabbit.png"}, 
    --rotate = 180,
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
        speed_normal = 3,
        stand_start = 0.5,
        stand_end = 2.5,
        walk_start = 3,
        walk_end = 4.5,
        run_start = 3,
        run_end = 4.5,
    },
    
    -- Coelhos pulam ocasionalmente
    jump = true,
    jump_height = 4,

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), S("The rabbit ran away scared!"))
            -- Faz o coelho pular e fugir
            self.object:set_velocity({x = 0, y = 6, z = 0})
        end
    end,
    
    -- Sons (se você tiver arquivos de som)
    sounds = {
        random = "RabbitSound1",
        damage = "RabbitSound2",
    },
})

-- Spawn do Coelho (neve)
mobs:spawn({
    name = "nh_mob:rabbit",
    nodes = {"air"},
    neighbors = {"nh_nodes:snow"},
    max_light = 15,
    interval = 120,
    chance = 2500,            -- Spawn mais frequente
    active_object_count = 8,  -- Mais coelhos podem spawnar
    min_height = 0,
    max_height = 100
})

--mobs:register_egg("nh_mob:rabbit", "Orbe com Coelho", "orbspawner.png", 0)
register_orb_egg("nh_mob:rabbit", S("Orb with Dwarf Rabbit"))

-------------------------------
-- MOB 3: GALO / rooster (Agressivo)
-------------------------------

mobs:register_mob("nh_mob:rooster", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    
    description = S("Rooster"),
    
        -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:cricket", "nh_mob:cicada"},
    
    -- drop com a sintaxe correta
    drops = {
        {name = "items:feather", chance = 1, min = 1, max = 5},  -- 1-5 penas
        {name = "nh_nodes:raw_chicken", chance = 1, min = 1, max = 1},  -- 1 galinha crua (sempre)
    },
    
    hp_min = 4,
    hp_max = 8,
    armor = 100,
    
    collisionbox = {-0.5, 0, -0.2, 0.3, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    selectionbox = {-0.5, 0, -0.2, 0.3, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    physical = true,
    stepheight = 1.1,
    fall_speed = -3,          -- Galinhas caem devagar (batem asas)
    fall_damage = 0,
    floats = 1,               -- Não nadam bem
    
    visual = "mesh",
    mesh = "rooster.glb",     -- Você precisa criar este modelo
    textures = {"rooster.png"}, -- Você precisa criar esta textura
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 1,
    run_velocity = 4,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 1,
        stand_start = 0.25,
        stand_end = 0.25,
        walk_start = 0.5,
        walk_end = 1.5,
        
    fly_up_start = 1.65,
    fly_up_end = 1.85,

    fly_down_start = 1.75,
    fly_down_end = 1.75,
    },
    
    -- Galinhas podem ser alimentadas e seguir o jogador com sementes
    follow = {"farming:seed_wheat", "nh_nodes:grassleaves"},


    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            -- Se o jogador está segurando sementes, a galinha segue
            if name == "farming:seed_wheat" or name == "nh_nodes:grassleaves" then
                core.chat_send_player(clicker:get_player_name(), S("The rooster is interested in the food!"))
            else
                core.chat_send_player(clicker:get_player_name(), S("Cocoricó! 🐔"))
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

    local vel = self.object:get_velocity()

    if not vel then return end

    -- Subindo
    if vel.y > 0.5 then
        if self.state ~= "fly_up" then
            self.state = "fly_up"
            self:set_animation("fly_up")
        end

    -- Descendo
    elseif vel.y < -0.5 then
        if self.state ~= "fly_down" then
            self.state = "fly_down"
            self:set_animation("fly_down")
        end

    -- Movimento normal
    else
        if self.state ~= "walk" then
            self.state = "walk"
            self:set_animation("walk")
        end
    end
end,
})

-- Spawn da Galinha (terra/dirt)
mobs:spawn({
    name = "nh_mob:rooster",
    nodes = {"air"},
    neighbors = {"nh_nodes:dirt", "nh_nodes:grass"},  -- Spawna em dirt e grama
    max_light = 15,
    interval = 120,
    chance = 2000,            -- Spawn frequente
    active_object_count = 2, -- 2 galos
    min_height = -10,
    max_height = 50
})

--mobs:register_egg("nh_mob:galo", "Orbe com Galo", "orbspawner.png", 0)
register_orb_egg("nh_mob:rooster", S("Orb with Rooster"))

-------------------------------
-- MOB 3: GALINHA (Passiva/Põe Ovos)
-------------------------------

mobs:register_mob("nh_mob:chicken", {
    type = "animal",
    passive = true,
    damage = 0,
    
    description = S("Chicken"),
    
    
    -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:cricket", "nh_mob:cicada"},
    
    drops = {
        {name = "items:feather", chance = 1, min = 1, max = 5},  -- 1-5 penas
        {name = "nh_nodes:raw_chicken", chance = 1, min = 1, max = 1},  -- 1 galinha crua (sempre)
    },
    
    hp_min = 4,
    hp_max = 8,
    armor = 100,
    
    collisionbox = {0, 0, -0.2, 0.3, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    selectionbox = {0, 0, -0.2, 0.3, 0.4, 0.2}, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
    physical = true,
    stepheight = 1.1,
    fall_speed = -3,          -- Galinhas caem devagar (batem asas)
    fall_damage = 0,
    floats = 1,               -- Não nadam bem
    
    visual = "mesh",
    mesh = "chicken.glb",     -- Você precisa criar este modelo
    textures = {"chicken.png"}, -- Você precisa criar esta textura
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    walk_velocity = 1,
    run_velocity = 3,
    
    view_range = 8,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 1,
        stand_start = 0.25,
        stand_end = 0.25,
        walk_start = 0.5,
        walk_end = 1.5,
        
    fly_up_start = 1.65,
    fly_up_end = 1.85,

    fly_down_start = 1.75,
    fly_down_end = 1.75,
    },
    
    -- Galinhas podem ser alimentadas e seguir o jogador com sementes
    follow = {"farming:seed_wheat", "nh_nodes:grassleaves"},


    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            -- Se o jogador está segurando sementes, a galinha segue
            if name == "farming:seed_wheat" or name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
                core.chat_send_player(clicker:get_player_name(), S("The chicken is interested in the food!"))
            else
                core.chat_send_player(clicker:get_player_name(), S("Pó pó! 🐔"))
            end
        end
    end,
    
    -- Sons da galinha
    sounds = {
        random = "ChickenSound",
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
        self.next_egg_time = math.random(120, 240)  -- 2 a 4 min
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


        log("A chicken laid an egg in " .. core.pos_to_string(egg_pos))

        -- Avisar jogadores próximos
        for _, player in ipairs(core.get_connected_players()) do
            if vector.distance(player:get_pos(), pos) < 10 then
                core.chat_send_player(
                    player:get_player_name(),
                    S("🥚 A chicken laid an egg!")
                )
            end
        end

        -- Reset
        self.egg_timer = 0
        self.next_egg_time = math.random(120, 240) -- 2 a 4 min
    end
    



    local vel = self.object:get_velocity()

    if not vel then return end

    -- Subindo
    if vel.y > 0.5 then
        if self.state ~= "fly_up" then
            self.state = "fly_up"
            self:set_animation("fly_up")
        end

    -- Descendo
    elseif vel.y < -0.5 then
        if self.state ~= "fly_down" then
            self.state = "fly_down"
            self:set_animation("fly_down")
        end

    -- Movimento normal
    else
        if self.state ~= "walk" then
            self.state = "walk"
            self:set_animation("walk")
        end
    end
end,
})

-- Spawn da Galinha (terra/dirt)
mobs:spawn({
    name = "nh_mob:chicken",
    nodes = {"air"},
    neighbors = {"nh_nodes:dirt", "nh_nodes:grass"},  -- Spawna em dirt e grama
    max_light = 15,
    interval = 120,
    chance = 2000,            -- Spawn frequente
    active_object_count = 5, -- 5 galinhas
    min_height = -10,
    max_height = 50
})

--mobs:register_egg("nh_mob:galinha", "Orbe com Galinha", "orbspawner.png", 0)
register_orb_egg("nh_mob:chicken", S("Orb with Chicken"))


-------------------------------
-- MOB 4: TUBARÃO (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:shark", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 5,
    attack_type = "dogfight",
    
    description = S("Shark"),
    
    -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:chicken", "nh_mob:rooster", "nh_mob:rabbit", "nh_mob:bull", "nh_mob:hedgehog"},
    
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
                core.chat_send_player(clicker:get_player_name(), S("The shark is hungry!"))
            else
                core.chat_send_player(clicker:get_player_name(), S("Glub, glub..."))
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

--mobs:register_egg("nh_mob:shark", "Orbe com Tubarão", "orbspawner.png", 0)
register_orb_egg("nh_mob:shark", S("Orb with Shark"))




-------------------------------
-- "MOB" item: Mensagem na garrafa
-------------------------------
mobs:register_mob("nh_mob:messagebottle", {
    type = "animal",
    passive = true,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Message Bottle") .. "\n" .. S("[Item]"),
    
    hp_min = 1,
    hp_max = 1,
    armor = 100,
    
    collisionbox = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18},
    selectionbox = {-0.18, -0.5, -0.18, 0.18, -0.05, 0.18},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 0,
    floats = 4,
    pushable = true,
    
    visual = "mesh",
    mesh = "bottlepage.obj",
    textures = {"bottlepagetexture.png"},
    rotate = 180,
    visual_size = {x = 15, y = 15},
    
    -- IMPORTANTE: Propriedades para manter na água
    fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 1,
    run_velocity = 1,
    
    view_range = 1,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,           -- CRÍTICO: Recebe dano fora da água!
    
    --animation = {
    --    speed_normal = 15,
    --    stand_start = 0,
    --    stand_end = 20,
    --    walk_start = 21,
    --    walk_end = 40,
    --},
    
    --follow = {"nh_nodes:raw_chicken"},
 
 
on_rightclick = function(self, clicker)
    if clicker:is_player() then
        local item = clicker:get_wielded_item()
        local name = item:get_name()
        
        if name == "" then
            item:take_item()
            clicker:set_wielded_item(item)

            -- Sorteio
            math.randomseed(os.time() + math.random(1000))
            local recipes = page_texts.recipe
            local random_text = recipes[math.random(#recipes)]
            local written_page = items.create_page_with_text(random_text)

            -- Define inv ANTES de usar
            local inv = clicker:get_inventory()
            inv:add_item("main", ItemStack("nh_nodes:bottle"))
            inv:add_item("main", written_page)

            self.object:remove()

        elseif name == "nh_nodes:bottle" then
            core.chat_send_player(clicker:get_player_name(), S("Plim! I need to empty my hand to pick it up."))
        else
            core.chat_send_player(clicker:get_player_name(), S("Message bottle. I need to empty my hand to pick it up."))
        end
    end
end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
    drops = {},  -- deixa vazio

on_die = function(self, pos)
    -- Sorteio igual ao on_rightclick
    math.randomseed(os.time() + math.random(1000))
    local recipes = page_texts.recipe
    local random_text = recipes[math.random(#recipes)]
    local written_page = items.create_page_with_text(random_text)
    
    -- Dropa o item no chão
    core.add_item(pos, written_page)
end,
})

-- Spawn da garrafa (somente na água)
mobs:spawn({
    name = "nh_mob:messagebottle",
    nodes = {"air", "nh_nodes:water"}, -- Spawna sobre a agua
    neighbors = {"nh_nodes:water"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = -1,
    max_height = 1                     -- spawna no nível do mar
})

--mobs:register_egg("nh_mob:messagebottle", "Garrafa com Mensagem", "bottle.png", 0)


-------------------------------
-- "MOB" item: coco
-------------------------------
mobs:register_mob("nh_mob:coconut", {
    type = "animal",
    passive = true,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Floating Coconut"),
    
    hp_min = 1,
    hp_max = 1,
    armor = 100,
    
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "coconut.obj",
    textures = {"CocoTexture.png"},
    rotate = 180,
    visual_size = {x = 10, y = 10},
    
   after_activate = function(self, staticdata, def, dtime)
        self.object:set_properties({
            use_texture_alpha = true,
        })
    end,
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 0.2,
    run_velocity = 0.2,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,           -- CRÍTICO: Recebe dano fora da água!
    
    --animation = {
    --    speed_normal = 15,
    --    stand_start = 0,
    --    stand_end = 20,
    --    walk_start = 21,
    --    walk_end = 40,
    --},
    
    --follow = {"nh_nodes:raw_chicken"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona o coco ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:coconut"))
            
                -- Remove a garrafa
                self.object:remove()
            
            elseif name == "nh_nodes:coconut" then
                core.chat_send_player(clicker:get_player_name(), "Ploc!")
            else
                core.chat_send_player(clicker:get_player_name(), S("A floating coconut! Great food to find at sea."))
            end
        end
    end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
    drops = {
        {name = "nh_nodes:coconut", chance = 1, min = 1, max = 1},  -- 1-1 gelo
    },
    
})

-- Spawn do iceberg (somente na água)
mobs:spawn({
    name = "nh_mob:coconut",
    nodes = {"air", "nh_nodes:water"},           -- Spawna DENTRO da água
    neighbors = {"nh_nodes:water"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 2,
    min_height = -1,
    max_height = 1                     -- spawna no nível do mar
})


-------------------------------
-- "MOB" item: iceberg
-------------------------------
mobs:register_mob("nh_mob:iceberg", {
    type = "animal",
    passive = true,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Floating Ice") .. "\n" .. S("[Platform]"),
    
    hp_min = 1,
    hp_max = 1,
    armor = 100,
    
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "iceberg.obj",
    textures = {"ice.png"},
    rotate = 180,
    visual_size = {x = 10, y = 10},
    
   after_activate = function(self, staticdata, def, dtime)
        self.object:set_properties({
            use_texture_alpha = true,
        })
    end,
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 1,
    run_velocity = 1,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,           -- CRÍTICO: Recebe dano fora da água!
    
    --animation = {
    --    speed_normal = 15,
    --    stand_start = 0,
    --    stand_end = 20,
    --    walk_start = 21,
    --    walk_end = 40,
    --},
    
    --follow = {"nh_nodes:raw_chicken"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona o gelo ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:ice2"))
            
                -- Remove a garrafa
                self.object:remove()
            
            elseif name == "nh_nodes:ice" then
                core.chat_send_player(clicker:get_player_name(), S("Plim! I need to empty my hand to pick it up."))
            else
                core.chat_send_player(clicker:get_player_name(), S("Floating ice"))
            end
        end
    end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
    drops = {
        {name = "nh_nodes:ice", chance = 1, min = 1, max = 1},  -- 1-1 gelo
    },
    
})

-- Spawn do iceberg (somente na água)
mobs:spawn({
    name = "nh_mob:iceberg",
    nodes = {"air", "nh_nodes:water"},           -- Spawna DENTRO da água
    neighbors = {"nh_nodes:ice"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 5,
    min_height = -1,
    max_height = 1                     -- spawna no nível do mar
})

--mobs:register_egg("nh_mob:iceberg", "Iceberg", "ice.png", 0)


-------------------------------
-- "MOB" item: iceberg
-------------------------------
mobs:register_mob("nh_mob:iceberg2", {
    type = "animal",
    passive = true,
    reach = 1,
    damage = 0,
    attack_type = "dogfight",
    
    description = S("Iceberg2") .. "\n" .. S("[Platform]"),
    
    hp_min = 8,
    hp_max = 10,
    armor = 100,
    
    collisionbox = {-1, -1, -1, 1, 0.5, 1},
    selectionbox = {-1.25, -2, -1.25, 1.25, 1, 1.25},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 0,
    floats = 1,
    
    visual = "mesh",
    mesh = "iceberg2.obj",
    textures = {"ice3.png"},
    rotate = 180,
    visual_size = {x = 10, y = 10},
    
   after_activate = function(self, staticdata, def, dtime)
        self.object:set_properties({
            use_texture_alpha = true,
        })
    end,
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 0.5,
    run_velocity = 0.5,
    
    view_range = 16,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,           -- CRÍTICO: Recebe dano fora da água!
    
    --animation = {
    --    speed_normal = 15,
    --    stand_start = 0,
    --    stand_end = 20,
    --    walk_start = 21,
    --    walk_end = 40,
    --},
    
    --follow = {"nh_nodes:raw_chicken"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona mob iceberg ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_mob:iceberg2"))
            
                -- Remove a garrafa
                self.object:remove()
            
            elseif name == "nh_nodes:ice" then
                core.chat_send_player(clicker:get_player_name(), "Plim!")
            else
                core.chat_send_player(clicker:get_player_name(), "Iceberg")
            end
        end
    end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
    drops = {
        {name = "nh_nodes:ice", chance = 1, min = 3, max = 5},  -- 1-1 gelo
        {name = "nh_nodes:snow", chance = 1, min = 3, max = 5},  -- 1-1 gelo
    },
    
})

-- Spawn do iceberg (somente na água)
mobs:spawn({
    name = "nh_mob:iceberg2",
    nodes = {"nh_nodes:water"},           -- Spawna DENTRO da água
    neighbors = {"nh_nodes:ice"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 5,
    min_height = -1,
    max_height = 1                     -- spawna no nível do mar
})

mobs:register_egg("nh_mob:iceberg2", "Iceberg2", "ice.png", 0)

-------------------------------
-- "MOB" item: piao
-------------------------------
mobs:register_mob("nh_mob:spinningtop", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    
    description = S("Oak Spinning Top") .. "\n" .. S("[Item]"),
    
    hp_min = 1,
    hp_max = 3,
    armor = 100,
    
    collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    selectionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 1,
    floats = 1,
    
    visual = "mesh",
    mesh = "piao.glb",
    textures = {"oakpiao.png"},
    --rotate = 180,
    visual_size = {x = 10, y = 10},
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 1,
    run_velocity = 1,
    
    view_range = 16,
    water_damage = 1, -- CRÍTICO: Recebe dano na água!
    lava_damage = 1,
    light_damage = 0,
    air_damage = 0,           
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0.25,
        walk_start = 0.25,
        walk_end = 1.5,
    },
    
    --follow = {"nh_nodes:raw_chicken"},
    
        -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:spinningtop2", "nh_mob:spinningtop3"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona fireflybottle ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:spinningtop"))
            
                -- Remove a garrafa
                self.object:remove()
            
            elseif name == "nh_nodes:spinningtop" then
                core.chat_send_player(clicker:get_player_name(), S("Teck! I need to empty my hand to pick it up."))
            else
                core.chat_send_player(clicker:get_player_name(), S("Spinning... I need to empty my hand to pick it up."))
            end
        end
    end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
do_custom = function(self, dtime)
    local allowed_nodes = {
        ["nh_nodes:oaktimber"] = true,
        ["nh_nodes:oakwood"] = true,
        ["nh_nodes:oakplank"] = true,
        ["nh_nodes:oakboard"] = true,
        ["nh_nodes:pinetimber"] = true,
        ["nh_nodes:gneiss"] = true,
        ["nh_nodes:ice"] = true,
        ["air"] = true,
    }
    
    self._damage_timer = (self._damage_timer or 0) + dtime
    
    if self._damage_timer >= 1.0 then
        self._damage_timer = 0
        
        local pos = self.object:get_pos()
        local below = {x = pos.x, y = math.floor(pos.y), z = pos.z}
        local node = minetest.get_node(below)
        
        if not allowed_nodes[node.name] then
            -- Só manda a mensagem na PRIMEIRA vez que entra no bloco errado
            if not self._on_bad_floor then
                self._on_bad_floor = true
                minetest.chat_send_all(S("Inappropriate surface. The palm spinning top is losing rotation due to friction..."))
            end
            
                        -- Rastreia HP manualmente sem depender do punch
            self._tracked_hp = (self._tracked_hp or self.object:get_hp()) - 1
            
            self.object:punch(self.object, 1.0, {
	    full_punch_interval = 1.0,
	    damage_groups = {fleshy = 1}
	     }, nil)
	     
	    --local hp = self.object:get_hp()
	     
            minetest.chat_send_all(S("Oak spinning top damage! HP: ") .. self._tracked_hp)
        else
            -- Resetar quando voltar para bloco permitido
            self._on_bad_floor = false
        end
    end
end,

--on_die = function(self, pos)
    -- Dropa o item na posição onde morreu
   -- minetest.add_item(pos, ItemStack("nh_nodes:spinningtop"))
--end,
    
    drops = {
        {name = "nh_nodes:spinningtop", chance = 1, min = 1, max = 1},  -- 1-1 gelo
    },
    
})

--mobs:register_egg("nh_mob:spinningtop", "Pião de Carvalho", "oakpiaoinv.png", 0)

-- "MOB" item: piao
-------------------------------
mobs:register_mob("nh_mob:spinningtop2", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    
    description = S("Palm Spinning Top") .. "\n" .. S("[Item]"),
    
    hp_min = 1,
    hp_max = 3,
    armor = 100,
    
    collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    selectionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 1,
    floats = 1,
    
    visual = "mesh",
    mesh = "piao.glb",
    textures = {"palmpiao.png"},
    --rotate = 180,
    visual_size = {x = 10, y = 10},
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 1,
    run_velocity = 1,
    
    view_range = 16,
    water_damage = 1, -- CRÍTICO: Recebe dano na água!
    lava_damage = 1,
    light_damage = 0,
    air_damage = 0,           
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0.25,
        walk_start = 0.25,
        walk_end = 1.5,
    },
    
    --follow = {"nh_nodes:raw_chicken"},
    
        -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:spinningtop", "nh_mob:spinningtop3"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona fireflybottle ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:spinningtop2"))
            
                -- Remove a garrafa
                self.object:remove()
            
            elseif name == "nh_nodes:spinningtop2" then
                core.chat_send_player(clicker:get_player_name(), S("Teck! I need to empty my hand to pick it up."))
            else
                core.chat_send_player(clicker:get_player_name(), S("Spinning... I need to empty my hand to pick it up."))
            end
        end
    end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
do_custom = function(self, dtime)
    local allowed_nodes = {
        ["nh_nodes:oaktimber"] = true,
        ["nh_nodes:oakwood"] = true,
        ["nh_nodes:oakplank"] = true,
        ["nh_nodes:oakboard"] = true,
        ["nh_nodes:pinetimber"] = true,
        ["nh_nodes:gneiss"] = true,
        ["nh_nodes:ice"] = true,
        ["air"] = true,
    }
    
    self._damage_timer = (self._damage_timer or 0) + dtime
    
    if self._damage_timer >= 1.0 then
        self._damage_timer = 0
        
        local pos = self.object:get_pos()
        local below = {x = pos.x, y = math.floor(pos.y), z = pos.z}
        local node = minetest.get_node(below)
        
        if not allowed_nodes[node.name] then
            -- Só manda a mensagem na PRIMEIRA vez que entra no bloco errado
            if not self._on_bad_floor then
                self._on_bad_floor = true
                minetest.chat_send_all(S("Inappropriate surface. The palm spinning top is losing rotation due to friction..."))
            end
            
                        -- Rastreia HP manualmente sem depender do punch
            self._tracked_hp = (self._tracked_hp or self.object:get_hp()) - 1
            
            self.object:punch(self.object, 1.0, {
	    full_punch_interval = 1.0,
	    damage_groups = {fleshy = 1}
	     }, nil)
	     
	    --local hp = self.object:get_hp()
	     
            minetest.chat_send_all(S("Palm spinning top damage! HP: ") .. self._tracked_hp)
        else
            -- Resetar quando voltar para bloco permitido
            self._on_bad_floor = false
        end
    end
end,
    
    drops = {
        {name = "nh_nodes:spinningtop2", chance = 1, min = 1, max = 1},  -- 1-1 gelo
    },
    
})

-- Spawn do piao 
--mobs:spawn({
--    name = "nh_mob:iceberg",
--    nodes = {"nh_nodes:water"},           -- Spawna DENTRO da água
--    neighbors = {"nh_nodes:ice"},
--    max_light = 15,
--    interval = 120,
--    chance = 2000,
--    active_object_count = 1,
--    min_height = 0,
--    max_height = -1                     -- spawna no nível do mar
--})

--mobs:register_egg("nh_mob:spinningtop2", "Pião de Coqueiro", "palmpiaoinv.png", 0)

-------------------------------
-- "MOB" item: piao
-------------------------------
mobs:register_mob("nh_mob:spinningtop3", {
    type = "animal",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    
    description = S("Pine Spinning Top") .. "\n" .. S("[Item]"),
    
    hp_min = 1,
    hp_max = 3,
    armor = 100,
    
    collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    selectionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    physical = true,
    stepheight = 0,           -- NÃO consegue subir degraus (importante!)
    fall_speed = -6,
    fall_damage = 1,
    floats = 1,
    
    visual = "mesh",
    mesh = "piao.glb",
    textures = {"pinepiao.png"},
    --rotate = 180,
    visual_size = {x = 10, y = 10},
    
    -- IMPORTANTE: Propriedades para manter na água
    --fly = false,               -- Permite "voar" na água
    --fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
    
    --walk_chance = 0,
    
    walk_velocity = 1,
    run_velocity = 1,
    
    view_range = 16,
    water_damage = 1, -- CRÍTICO: Recebe dano na água!
    lava_damage = 1,
    light_damage = 0,
    air_damage = 0,           
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0.25,
        walk_start = 0.25,
        walk_end = 1.5,
    },
    
    --follow = {"nh_nodes:raw_chicken"},
    
        -- lista de mobs que ele vai atacar ativamente
    attack_animals = true,        -- permite atacar outros mobs
    specific_attack = {"nh_mob:spinningtop", "nh_mob:spinningtop2"},
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "" then
                -- Remove uma garrafa do inventário
                item:take_item()
                clicker:set_wielded_item(item)
            
                -- Adiciona fireflybottle ao inventário
                local inv = clicker:get_inventory()
                inv:add_item("main", ItemStack("nh_nodes:spinningtop3"))
            
                -- Remove a garrafa
                self.object:remove()
            
            elseif name == "nh_nodes:spinningtop3" then
                core.chat_send_player(clicker:get_player_name(), S("Teck! I need to empty my hand to pick it up."))
            else
                core.chat_send_player(clicker:get_player_name(), S("Spinning... I need to empty my hand to pick it up."))
            end
        end
    end,
    
    --sounds = {
    --    random = "tubarao_som",
    --    damage = "tubarao_hurt",
    --},
    
do_custom = function(self, dtime)
    local allowed_nodes = {
        ["nh_nodes:oaktimber"] = true,
        ["nh_nodes:oakwood"] = true,
        ["nh_nodes:oakplank"] = true,
        ["nh_nodes:oakboard"] = true,
        ["nh_nodes:pinetimber"] = true,
        ["nh_nodes:gneiss"] = true,
        ["nh_nodes:ice"] = true,
        ["air"] = true,
    }
    
    self._damage_timer = (self._damage_timer or 0) + dtime
    
    if self._damage_timer >= 1.0 then
        self._damage_timer = 0
        
        local pos = self.object:get_pos()
        local below = {x = pos.x, y = math.floor(pos.y), z = pos.z}
        local node = minetest.get_node(below)
        
        if not allowed_nodes[node.name] then
            -- Só manda a mensagem na PRIMEIRA vez que entra no bloco errado
            if not self._on_bad_floor then
                self._on_bad_floor = true
                minetest.chat_send_all(S("Inappropriate surface. The pine spinning top is losing rotation due to friction..."))
            end
            
                        -- Rastreia HP manualmente sem depender do punch
            self._tracked_hp = (self._tracked_hp or self.object:get_hp()) - 1
            
            self.object:set_hp(hp - 1)
            
            --self.object:punch(self.object, 1.0, {
	    --full_punch_interval = 1.0,
	    --damage_groups = {fleshy = 1}
	     --}, nil)
	     
	    --local hp = self.object:get_hp()
	     
            minetest.chat_send_all(S("Pine spinning top damage! HP: ") .. self._tracked_hp)
        else
            -- Resetar quando voltar para bloco permitido
            self._on_bad_floor = false
        end
    end
end,
    
    drops = {
        {name = "nh_nodes:spinningtop3", chance = 1, min = 1, max = 1},  -- 1-1 gelo
    },
    
})

--mobs:register_egg("nh_mob:spinningtop3", "Pião de Pinheiro", "pinepiaoinv.png", 0)


-------------------------------
-- MOB 1: polvo (Defensivo)
-------------------------------

mobs:register_mob("nh_mob:octopus", {
    type = "animal",
    passive = true,          -- Pode se defender quando atacado
    damage = 3,
    reach = 1,
    
    description = S("Dark Octopus") .. "\n" .. S("[Altered Animal]"),
    
    hp_min = 5,
    hp_max = 10,
    armor = 100,
    
    collisionbox = {-0.3, 0, -0.25, 0.25, 0.4, 0.25},
    physical = true,
    stepheight = 3.1,
    fall_speed = -8,
    fall_damage = 2,
    
    visual = "mesh",
    mesh = "octopus.glb",
    textures = {"octopus.png"},
    --rotate = 180,
    visual_size = {x = 15, y = 15},
    
    drops = {
        {name = "nh_nodes:inksac", chance = 1, min = 1, max = 1},  -- bolsa de tinta
    },
    
        -- IMPORTANTE: Propriedades para manter na água
    fly = true,               -- Permite "voar" na água
    fly_in = "nh_nodes:water",   -- Voa na agua
    
    -- lista de mobs que ele vai atacar ativamente
    --attack_animals = true,        -- permite atacar outros mobs
    --specific_attack = {"nh_mob:cricket", "nh_mob:cicada",  "nh_mob:ladybug"},
    
    walk_velocity = 0.5,
    run_velocity = 2,
    
    view_range = 10,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
    animation = {
        speed_normal = 1,
        stand_start = 0.38,
        stand_end = 0.63,
        walk_start = 0,
        walk_end = 0.75,
        run_start = 0,
        run_end = 0.75,
        --jump_start = 61,
        --jump_end = 80
    },

    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), "O polvo é perigoso, cuidado ao atacar!")
        end
    end,
  
})


--mobs:register_egg("nh_mob:octopus", "Orbe com Polvo", "orbspawner.png", 0)
-- Substitua os register_egg pelos orbes com mesh:
register_orb_egg("nh_mob:octopus",  S("Orb with Dark Octopus"))



-------------------------------
-- MOB 4: Polvo esqueleto (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:exoskull", {
    type = "monster",
    passive = false,
    reach = 2,
    damage = 5,
    attack_type = "dogfight",
    --attack_chance = 8, -- entre 1-10
    
    description = S("Exhausted") .. "\n" .. S("[Altered Animal]"),
    
    hp_min = 20,
    hp_max = 30,
    armor = 100,
    
    collisionbox = {-0.25, 0, -0.2, 0.3, 2.4, 0.2},
    selectionbox = {-0.5, 0, -0.2, 0.5, 2.4, 0.2},
    physical = true,
    stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
    fall_speed = -10,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "octopusskull.glb",
    textures = {"octopusskull.png"},
    --rotate = 180,
    visual_size = {x = 2, y = 2}, -- visual_size = {x = 2.1, y = 2.1},
    
    drops = {
        {name = "nh_nodes:bone", chance = 1, min = 2, max = 6},  -- ossos
        {name = "nh_nodes:rustironsword", chance = 1, min = 0, max = 1},  -- espada
    },
    
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
                core.chat_send_player(clicker:get_player_name(), S("The exhausted doesn't want light!"))
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
	
    on_die = function(self, pos)
        minetest.after(0.1, function()
            minetest.add_entity(pos, "nh_mob:octopus") -- exemplo
        end)

    -- Opcional: deixa o novo mob já em modo de ataque
    -- if obj then
    --     obj:get_luaentity().state = "attack"
    -- end
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

--mobs:register_egg("nh_mob:octoskull", "Orbe com Exopolvo", "orbspawner.png", 0)
register_orb_egg("nh_mob:exoskull", S("Orb with Exhausted"))


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
    
    description = S("Sirenia") .. "\n" .. S("[Animal Phenomenon]"),
    
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
                core.chat_send_player(clicker:get_player_name(), S("The sirenia doesn't want light!"))
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
    nodes = {"air", "nh_nodes:water"}, -- nh_nodes = {"nh_nodes:water"},
    neighbors = {"nh_nodes:ice"}, --neighbors = {"nh_nodes:obsidian"},
    max_light = 10,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = -20,
    max_height = 1   -- -10               
})

--mobs:register_egg("nh_mob:sirenia", "Orbe com Sirenia", "orbspawner.png", 0)
register_orb_egg("nh_mob:sirenia",  S("Orb with Sirenia"))


-------------------------------
-- MOB 4: PLANARIA SLIME (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:slime", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 1,
    attack_type = "dogfight",
    
    description = S("Limu") .. "\n" .. S("[Altered Animal]"),
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    collisionbox = {-0.2, 0, -0.2, 0.2, 0.4, 0.2},
    selectionbox = {-0.2, 0, -0.2, 0.2, 0.4, 0.2},
    physical = true,
    stepheight = 3,           -- Consegue subir no player (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "planslime.glb", --mesh = "planaria_slime_small2.obj",
    textures = {"planaria_slime2.png"}, --^[opacity:200 --{{"planaria_slime3.png","planaria_slime3.png"}}
    --rotate = 180,
    visual_size = {x = 10, y = 10},
    
    -- BRILHO NOS OLHOS
    glow = 5,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
after_activate = function(self, staticdata, def, dtime)
    self.object:set_properties({
        use_texture_alpha = true,
        textures = {
            "planaria_slime2.png",
            "planaria_slime2.png",
        },
    })
    
    -- Procura jogador próximo e já começa a atacar
    local pos = self.object:get_pos()
    local nearest_player = nil
    local nearest_dist = self.view_range or 7
    
    for _, player in ipairs(minetest.get_connected_players()) do
        local dist = vector.distance(pos, player:get_pos())
        if dist < nearest_dist then
            nearest_dist = dist
            nearest_player = player
        end
    end
    
    if nearest_player then
        minetest.after(0.4, function()
            if self.object and self.object:is_valid() then
                self.object:punch(nearest_player, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 1},
                }, nil)
            end
        end)
    end
end,

    walk_velocity = 1,
    run_velocity = 2,
    
    view_range = 7,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0,
        walk_start = 0,
        walk_end = 0.63,
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

-- Spawn da slime (cavernas)
mobs:spawn({
    name = "nh_mob:slime",
    nodes = {"air"},
    neighbors = {"nh_nodes:gneiss", "nh_nodes:water2"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 4,
    min_height = -15,
    max_height = -5                 
})

--mobs:register_egg("nh_mob:slime", "Orbe com Limu Pequeno", "orbspawner.png", 0)
register_orb_egg("nh_mob:slime",   S("Orb with Small Limu"))

-- MOB 4: PLANARIA SLIME2 (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:slime2", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 3,
    attack_type = "dogfight",
    
    description = S("Medium Limu") .. "\n" .. S("[Altered Animal]"),
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
    on_die = function(self, pos)
        minetest.after(0.1, function()
            -- Spawna 6 slime normal
            minetest.add_entity(pos, "nh_mob:slime")
            minetest.add_entity(pos, "nh_mob:slime")
            minetest.add_entity(pos, "nh_mob:slime")
            minetest.add_entity(pos, "nh_mob:slime")
            minetest.add_entity(pos, "nh_mob:slime")
            minetest.add_entity(pos, "nh_mob:slime")
        end)
    end,
    
    collisionbox = {-0.35, 0, -0.35, 0.35, 0.7, 0.35},
    selectionbox = {-0.35, 0, -0.35, 0.35, 0.7, 0.35},
    physical = true,
    stepheight = 4,           -- Consegue subir no player (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "planslime.glb", --mesh = "planaria_slime_small2.obj",
    textures = {"planaria_slime2.png"}, --^[opacity:200 --{{"planaria_slime3.png","planaria_slime3.png"}}
    --rotate = 180,
    visual_size = {x = 20, y = 20},
    
    -- BRILHO NOS OLHOS
    glow = 5,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    -- TRANSPARENCIA
    --use_texture_alpha = "blend",  -- Tente "blend" em vez de true -> use_texture_alpha = true,  -- Habilita transparência
    --backface_culling = true,   -- Renderiza ambos os lados das faces
    
after_activate = function(self, staticdata, def, dtime)
    self.object:set_properties({
        use_texture_alpha = true,
        textures = {
            "planaria_slime2.png",
            "planaria_slime2.png",
        },
    })
    
    -- Procura jogador próximo e já começa a atacar
    local pos = self.object:get_pos()
    local nearest_player = nil
    local nearest_dist = self.view_range or 7
    
    for _, player in ipairs(minetest.get_connected_players()) do
        local dist = vector.distance(pos, player:get_pos())
        if dist < nearest_dist then
            nearest_dist = dist
            nearest_player = player
        end
    end
    
    if nearest_player then
        minetest.after(0.4, function()
            if self.object and self.object:is_valid() then
                self.object:punch(nearest_player, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 1},
                }, nil)
            end
        end)
    end
end,

    walk_velocity = 1,
    run_velocity = 2,
    
    view_range = 7,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0,
        walk_start = 0,
        walk_end = 0.63,
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

-- Spawn da slime (cavernas)
mobs:spawn({
    name = "nh_mob:slime2",
    nodes = {"air"},
    neighbors = {"nh_nodes:gneiss", "nh_nodes:water2"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 4,
    min_height = -15,
    max_height = -5                 
})

--mobs:register_egg("nh_mob:slime2", "Orbe com Limu Médio", "orbspawner.png", 0)
register_orb_egg("nh_mob:slime2",    S("Orb with Medium Limu"))

-- MOB 4: PLANARIA SLIME3 (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:slime3", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 3,
    attack_type = "dogfight",
    
    description = S("Large Limu") .. "\n" .. S("[Altered Animal]"),
    
    hp_min = 10,
    hp_max = 20,
    armor = 100,
    
on_die = function(self, pos)
    minetest.after(0.1, function()
        -- Spawna 4 slime2
        minetest.add_entity(pos, "nh_mob:slime2")
        minetest.add_entity(pos, "nh_mob:slime2")
        minetest.add_entity(pos, "nh_mob:slime2")
        minetest.add_entity(pos, "nh_mob:slime2")
        -- Spawna 2 slime normal
        minetest.add_entity(pos, "nh_mob:slime")
        minetest.add_entity(pos, "nh_mob:slime")
    end)
end,
    
    collisionbox = {-0.625, 0, -0.625, 0.625, 1.25, 0.625},
    selectionbox = {-0.625, 0, -0.625, 0.625, 1.25, 0.625},
    physical = true,
    stepheight = 4,           -- Consegue subir no player (importante!)
    fall_speed = -4,
    fall_damage = 0,
    floats = 3,
    
    visual = "mesh",
    mesh = "planslime.glb", --mesh = "planaria_slime_small2.obj",
    textures = {"planaria_slime2.png"}, --^[opacity:200 --{{"planaria_slime3.png","planaria_slime3.png"}}
    --rotate = 180,
    visual_size = {x = 40, y = 40},
    
    -- BRILHO NOS OLHOS
    glow = 5,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    -- TRANSPARENCIA
    --use_texture_alpha = "blend",  -- Tente "blend" em vez de true -> use_texture_alpha = true,  -- Habilita transparência
    --backface_culling = true,   -- Renderiza ambos os lados das faces
    
after_activate = function(self, staticdata, def, dtime)
    self.object:set_properties({
        use_texture_alpha = true,
        textures = {
            "planaria_slime2.png",
            "planaria_slime2.png",
        },
    })
    
    -- Procura jogador próximo e já começa a atacar
    local pos = self.object:get_pos()
    local nearest_player = nil
    local nearest_dist = self.view_range or 7
    
    for _, player in ipairs(minetest.get_connected_players()) do
        local dist = vector.distance(pos, player:get_pos())
        if dist < nearest_dist then
            nearest_dist = dist
            nearest_player = player
        end
    end
    
    if nearest_player then
        minetest.after(0.2, function()
            if self.object and self.object:is_valid() then
                self.object:punch(nearest_player, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 1},
                }, nil)
            end
        end)
    end
end,

    walk_velocity = 1,
    run_velocity = 2,
    
    view_range = 7,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    air_damage = 0,         
    
    animation = {
        speed_normal = 1,
        stand_start = 0,
        stand_end = 0,
        walk_start = 0,
        walk_end = 0.63,
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

-- Spawn da slime (cavernas)
mobs:spawn({
    name = "nh_mob:slime3",
    nodes = {"air"},
    neighbors = {"nh_nodes:gneiss", "nh_nodes:water2"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 4,
    min_height = -20,
    max_height = -10                 
})

--mobs:register_egg("nh_mob:slime3", "Orbe com Limu Grande", "orbspawner.png", 0)
register_orb_egg("nh_mob:slime3",  S("Orb with Large Limu"))


-------------------------------
-- MOB 4: VULTO / VISAGE (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:visage", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 5,
    attack_type = "dogfight",
    
    description = S("Visage") .. "\n" .. S("[Phenomenon]"),
    
    hp_min = 1,
    hp_max = 1,
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
    textures = {"vulto3.png"}, --vulto.png^[opacity:200
    rotate = 180,
    visual_size = {x = 2, y = 2},
    
    
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
    
    on_die = function(self, pos)
        minetest.after(0.1, function()
            local obj = minetest.add_entity(pos, "nh_mob:visage2")
        end)
    end,
    
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()
            
            if name == "nh_nodes:torch2" then
                core.chat_send_player(clicker:get_player_name(), S("The visage doesn't want light!"))
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

--mobs:register_egg("nh_mob:visage", "Orbe com Vulto", "orbspawner.png", 0)
register_orb_egg("nh_mob:visage",  S("Orb with Visage"))


-------------------------------
-- MOB 4: VULTO / VISAGE (Agressivo)
-------------------------------
mobs:register_mob("nh_mob:visage2", {
    type = "monster",
    passive = false,
    reach = 1,
    damage = 5,
    attack_type = "dogfight",
    
    description = S("Visage") .. "\n" .. S("[Phenomenon]"),
    
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
    textures = {"vulto2.png"}, --vulto.png^[opacity:200
    rotate = 180,
    visual_size = {x = 2, y = 2},
    
    -- BRILHO NOS OLHOS
    glow = 14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
after_activate = function(self, staticdata, def, dtime)
    self.object:set_properties({
        use_texture_alpha = true,
        textures = {"vulto2.png"},
    })
    
    -- Procura o jogador mais próximo e simula um soco dele no mob
    local pos = self.object:get_pos()
    local nearest_player = nil
    local nearest_dist = 20  -- só considera jogadores em até 20 blocos
    
    for _, player in ipairs(minetest.get_connected_players()) do
        local dist = vector.distance(pos, player:get_pos())
        if dist < nearest_dist then
            nearest_dist = dist
            nearest_player = player
        end
    end
    
    if nearest_player then
        -- Pequeno delay para o mob terminar de spawnar antes do punch
        minetest.after(0.2, function()
            if self.object:is_valid() then
                self.object:punch(nearest_player, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 1},  -- 1 de dano simbólico
                }, nil)
            end
        end)
    end
end,
    
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
                core.chat_send_player(clicker:get_player_name(), S("The visage doesn't want light!"))
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
    fall_speed = -10,
    fall_damage = 0,
    floats = 3,
    
    despawn_by_day = false,
    remove_far = false,
    
    visual = "mesh",
    mesh = "character3.glb",
    textures = {"skin.png"},
    --rotate = 180,
    visual_size = {x = 1, y = 1},
    
    -- BRILHO NOS OLHOS
    --glow = -14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
    
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
        -- ANIMAÇÃO DE ATAQUE:
        punch_start = 11.5,    -- Frame inicial do ataque
        punch_end = 12,      -- Frame final do ataque
    },
    
    -- Mantém uma lista mínima (pode deixar vazia ou com qualquer item)
    -- O seguimento real será feito pelo do_custom abaixo
    follow = {"nh_nodes:torch2", "nh_nodes:dirt", "nh_items:writedpage", "nh_nodes:oakchest", "nh_nodes:cobblestone", "nh_nodes:oakwood"},
    
    -- ✅ RESPOSTA NO PRIMEIRO CLIQUE COM QUALQUER ITEM (exceto mão vazia)
    on_rightclick = function(self, clicker)
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local name = item:get_name()

            if name == "" then
                core.chat_send_player(clicker:get_player_name(), S("Who are you? Why do you look like me?!"))
            else
                core.chat_send_player(clicker:get_player_name(), S("That thing you're holding is mine!"))  
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

-- Spawn do dopel (casas, blocos de madeiras)
mobs:spawn({
    name = "nh_mob:dopel",
    nodes = {"air"},
    neighbors = {"nh_nodes:oakwood"},
    max_light = 14,
    interval = 30,
    chance = 20,
    active_object_count = 1,
    min_height = -50,
    max_height = 50                  
})

--mobs:register_egg("nh_mob:dopel", "Orbe com Dopel", "orbspawner.png", 0)
register_orb_egg("nh_mob:dopel", S("Orb with Dopel"))

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
