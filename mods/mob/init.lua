--[[
  Mod: Mob, baseado no mod Happy Mob
  Versão com múltiplos mobs: Ouriço, Coelho, Galinha, galo, tubarão...
--]]

-------------------------------
-- CONFIGURAÇÕES GLOBAIS
-------------------------------

local DEBUG = true
local function log(msg) if DEBUG then core.log("action", "[Mob] " .. msg) end end
local S = core.get_translator("nh_mob")
--mobs:set_spawn_setting("spawn", true)
--mobs:set_spawn_setting("remove_far", false)
-- BOSS BAR
-- BOSS BAR SYSTEM
local SLOT_HEIGHT = 60   -- espaço entre cada barra (pixels)
local BASE_Y = -968      -- posição Y da primeira barra
local BASE_TEXT_Y = -990 -- posição Y do texto da primeira barra

-- Rastreia slots por jogador: _boss_slots[pname] = {[self_id] = slot_index}
local _boss_slots = {}
local function get_self_id(self) return tostring(self.object) end
local function assign_slot(pname, self_id)
	_boss_slots[pname] = _boss_slots[pname] or {}
	if _boss_slots[pname][self_id] then return _boss_slots[pname][self_id] end
	-- Acha o menor slot livre
	local used = {}
	for _, slot in pairs(_boss_slots[pname]) do used[slot] = true end
	local slot = 0
	while used[slot] do slot = slot + 1 end
	_boss_slots[pname][self_id] = slot
	return slot
end
local function free_slot(pname, self_id) if _boss_slots[pname] then _boss_slots[pname][self_id] = nil end end
local function update_boss_hud(self, boss_name)
	if not self.object or not self.object:is_valid() then return end
	local pos = self.object:get_pos()
	if not pos then return end
	self._hud_ids = self._hud_ids or {}
	local hp = self.health or 0
	local hp_max = self.hp_max or 50
	local percent = math.max(0, math.min(1, hp / hp_max))
	local bar_val = math.floor(percent * 50)
	local display_name = boss_name or "Boss"
	local self_id = get_self_id(self)
	for _, player in ipairs(core.get_connected_players()) do
		local pname = player:get_player_name()
		local dist = vector.distance(pos, player:get_pos())
		if dist > 40 then
			if self._hud_ids[pname] then -- Remove HUD e libera slot
				player:hud_remove(self._hud_ids[pname].bar)
				player:hud_remove(self._hud_ids[pname].text)
				self._hud_ids[pname] = nil
				free_slot(pname, self_id)
			end
		else
			if not self._hud_ids[pname] then -- Pega slot e calcula offset Y
				local slot           = assign_slot(pname, self_id)
				local offset_y_bar   = BASE_Y + (slot * SLOT_HEIGHT)
				local offset_y_text  = BASE_TEXT_Y + (slot * SLOT_HEIGHT)
				local bar_id         = player:hud_add({
					type = "statbar",
					position = { x = 0.5, y = 1 },
					offset = { x = -300, y = offset_y_bar },
					text =
					"blood.png^[colorize:#76008d:50",
					text2 = "blood.png^[colorize:#000000:180",
					number = bar_val,
					item = 50,
					direction = 0,
					size = { x = 24, y = 24 },
				})
				local text_id        = player:hud_add({
					type = "text",
					position = { x = 0.5, y = 1 },
					offset = { x = 0, y = offset_y_text },
					text = display_name .. "  " .. hp .. " / " .. hp_max,
					number = 0xFF3300,
					scale = { x = 200, y = 80 },
					alignment = { x = 0, y = 0 },
				})
				self._hud_ids[pname] = { bar = bar_id, text = text_id }
			else
				-- Só atualiza valores
				player:hud_change(self._hud_ids[pname].bar, "number", bar_val)
				player:hud_change(self._hud_ids[pname].text, "text", display_name .. "  " .. hp .. " / " .. hp_max)
			end
		end
	end
end
local function remove_all_boss_hud(self)
	if not self._hud_ids then return end
	local self_id = get_self_id(self)
	for _, player in ipairs(core.get_connected_players()) do
		local pname = player:get_player_name()
		if self._hud_ids[pname] then
			player:hud_remove(self._hud_ids[pname].bar)
			player:hud_remove(self._hud_ids[pname].text)
			self._hud_ids[pname] = nil
			free_slot(pname, self_id)
		end
	end
end
-- MOB 4: RAT/RATAZANA (Agressivo)
mobs:register_mob("nh_mob:rat",
	{
		type = "animal",
		passive = false,
		reach = 1,
		damage = 2,
		attack_type = "dogfight",
		description = S("Rat"),
		-- lista de mobs que ele vai atacar ativamente
		attack_animals = true, -- permite atacar outros mobs
		specific_attack = { "nh_mob:cricket", "nh_mob:cicada" },
		follow = { "nh_nodes:chicken_egg", "nh_nodes:friedchickenegg", "nh_nodes:raw_chicken", "nh_nodes:blueberry" },
		hp_min = 8,
		hp_max = 10,
		armor = 100,
		collisionbox = { -0.25, 0, -0.2, 0.3, 0.4, 0.2 },
		selectionbox = { -0.5, 0, -0.2, 0.5, 0.4, 0.2 },
		physical = true,
		stepheight = 3,
		fall_speed = -8,
		fall_damage = 0,
		floats = 1,
		visual = "mesh",
		mesh = "rat.glb",
		textures = { "rat.png" },
		-- rotate = 180,
		visual_size = { x = 15, y = 15 },
		-- PERMITIRIA "VOAR" DENTRO DAS FOLHAS se não retirasse a capacidade de andar...
		-- fly = true,
		-- fly_in = {"nh_nodes:leaves"},  -- Pode ser uma lista!
		walk_velocity = 3,
		run_velocity = 6,
		view_range = 8,
		water_damage = 0,
		lava_damage = 5,
		light_damage = 0,
		animation = { speed_normal = 1, stand_start = 0.25, stand_end = 1.25, walk_start = 1.5, walk_end = 2.5, },
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
		sounds = { random = "rat_quick", damage = "rat_hurt", },
	})
-- Spawn da ratazana (grama perto de árvores)
mobs:spawn({
	name = "nh_mob:rat",
	nodes = { "air" },
	neighbors = { "nh_nodes:grass", "nh_nodes:wood", "default:tree" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 3,
	min_height = -20,
	max_height = 30
})
--mobs:register_egg("nh_mob:rat", "Orbe com Ratazana", "orbspawner.png", 0)
register_orb_egg("nh_mob:rat", S("Orb with Rat"))
-- MOB 5: Joaninha
mobs:register_mob("nh_mob:ladybug", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Ladybug"),
	blood_texture = "mob_yellowblood.png", -- sua textura customizada
	blood_amount = 5,                   -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 3,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "ladybug.obj",
	textures = { "ladybug.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 },
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	-- fly = true,
	-- fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	follow = { "nh_nodes:grassleaves" },
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
	sounds = { random = "LadybugSound", damage = "LadybugSound", },
})
-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
	name = "nh_mob:ladybug",
	nodes = { "air" },
	neighbors = { "nh_nodes:grassleaves" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = 0,
	max_height = 30
})
--mobs:register_egg("nh_mob:ladybug", "Orbe com Joaninha", "orbspawner.png", 0)
register_orb_egg("nh_mob:ladybug", S("Orb with Ladybug"))
-- MOB 5: Grilo
mobs:register_mob("nh_mob:cricket", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Cricket"),
	blood_texture = "mob_yellowblood.png", -- sua textura customizada
	blood_amount = 5,                   -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	-- Grilos fogem de jogadores
	runaway = true,
	runaway_from = { "player" },
	collisionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 3,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "cricket.glb",
	textures = { "cricket.png" },
	-- rotate = 180,
	visual_size = { x = 15, y = 15 },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ backface_culling = false, }) end,
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	-- fly = true,
	-- fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0, walk_start = 0, walk_end = 0.5, },
	follow = { "nh_nodes:grassleaves" },
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
	sounds = { random = "CricketsSound", damage = "CricketsSound", },
})
-- Spawn da grilo (grama)
mobs:spawn({
	name = "nh_mob:cricket",
	nodes = { "air" },
	neighbors = { "nh_nodes:grassleaves" },
	max_light = 10,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = 0,
	max_height = 30
})
--mobs:register_egg("nh_mob:cricket", "Orbe com Grilo", "orbspawner.png", 0)
register_orb_egg("nh_mob:cricket", S("Orb with Cricket"))
-- MOB 5: Cigarra
mobs:register_mob("nh_mob:cicada", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Cicada"),
	blood_texture = "mob_yellowblood.png", -- sua textura customizada
	blood_amount = 5,                   -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 3,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "cicada.obj",
	textures = { "cicada.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ backface_culling = false, }) end,
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	-- fly = true,
	-- fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	follow = { "nh_nodes:grassleaves" },
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
	sounds = { random = "CicadaSound", damage = "CicadaSound", },
})
-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
	name = "nh_mob:cicada",
	nodes = { "air" },
	neighbors = { "nh_nodes:leaves" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 2,
	min_height = 0,
	max_height = 30
})
--mobs:register_egg("nh_mob:cicada", "Orbe com Cigarra", "orbspawner.png", 0)
register_orb_egg("nh_mob:cicada", S("Orb with Cicada"))
-- MOB 5: Vagalume
mobs:register_mob("nh_mob:firefly", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Firefly"),
	-- Vagalumes fogem de jogadores
	runaway = true,
	runaway_from = { "player" },
	blood_texture = "mob_yellowblood.png", -- sua textura customizada
	blood_amount = 5,                   -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 3,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "firefly.glb",
	textures = { "firefly.png" },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ backface_culling = false, use_texture_alpha = true, }) end,
	--rotate = 180,
	visual_size = { x = 15, y = 15 },
	-- BRILHO
	glow = 14, -- Intensidade de 0 a 14 (14 = mais brilhante)
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	fly = true,
	fly_in = { "air" }, -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 15, stand_start = 0, stand_end = 0.5, walk_start = 0, walk_end = 0.5, },
	follow = { "nh_nodes:fireflybottle" }, --"nh_nodes:apple",
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
	-- sounds = { random = "rat_quick", damage = "rat_hurt", },
})

-- Spawn do vagalume (grama perto de árvores)
mobs:spawn({
	name = "nh_mob:firefly",
	nodes = { "air" },
	neighbors = { "nh_nodes:water2", "nh_nodes:grassleaves" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 3,
	min_height = -10,
	max_height = 30
})
--mobs:register_egg("nh_mob:firefly", "Orbe com Vaga-lume", "orbspawner.png", 0)
register_orb_egg("nh_mob:firefly", S("Orb with Firefly"))
-- MOB 5: Cigarra
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
	collisionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 1,
	fall_speed = -10,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "worm.glb",
	textures = { "worm.png" },
	-- rotate = 180,
	visual_size = { x = 15, y = 15 },
	walk_velocity = 1,
	run_velocity = 2,
	view_range = 5,
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 0.75, stand_start = 0, stand_end = 0, walk_start = 0, walk_end = 0.75, },
	follow = { "nh_nodes:dirt" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then
				item:take_item()
				clicker:set_wielded_item(item)
				local inv = clicker:get_inventory() -- Define inv ANTES de usar
				inv:add_item("main", ItemStack("nh_nodes:worm"))
				self.object:remove()
			elseif name == "nh_nodes:dirt" then
				core.chat_send_player(clicker:get_player_name(), S("The worm wants dirt!"))
			else
				core.chat_send_player(clicker:get_player_name(), "...")
			end
		end
	end,
	-- sounds = { random = "CicadaSound", damage = "CicadaSound", },
})
-- Spawn da joaninha (grama perto de árvores)
mobs:spawn({
	name = "nh_mob:worm",
	nodes = { "air" },
	neighbors = { "nh_nodes:dirt" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 2,
	min_height = 0,
	max_height = 30
})
--mobs:register_egg("nh_mob:worm", "Orbe com Minhoca", "orbspawner.png", 0)
register_orb_egg("nh_mob:worm", S("Orb with Worm"))
-- MOB 5: Touro
mobs:register_mob("nh_mob:bull", {
	type = "animal",
	passive = false,
	reach = 3,
	damage = 7,
	attack_type = "dogfight",
	attack_chance = 1,
	drops = {
		{ name = "nh_nodes:cowleather", chance = 1, min = 1, max = 4 }, -- 1-4 couros
		{ name = "nh_nodes:cowmeat",    chance = 1, min = 2, max = 5 }, -- 2-7 carnes (sempre)
		{ name = "nh_nodes:bone",       chance = 1, min = 2, max = 5 }, -- 2-7 ossos (sempre)
	},
	description = S("Bull"),
	hp_min = 25,
	hp_max = 35,
	armor = 100,
	collisionbox = { -2.3, 0, -2.3, 2.3, 2.6, 2.3 },
	selectionbox = { -2.5, 0, -0.7, 0.9, 2.6, 0.7 },
	physical = true,
	stepheight = 2,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "bull.glb",
	textures = { "bull2.png" },
	-- rotate = 180,
	visual_size = { x = 7.5, y = 7.5 },
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	-- fly = true,
	-- fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 6,
	view_range = 10,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	follow = { "nh_nodes:grassleaves" },
	sounds = { random = "BullSound", damage = "BullAngrySound", },
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
	saddle = "mobs:saddle", -- item de sela necessário
	ride_speed = 8,       -- velocidade montado
	ride_acceleration = 1.0, -- aceleração montado
	ride_friction = 0.8,  -- fricção ao parar
	-- Offset do jogador sobre o mob (ajuste conforme o visual do touro)
	driver_attach_at = { x = 0, y = 30, z = -5 },
	driver_eye_offset = { x = 0, y = 3, z = 0 },
	driver_scale_factor = 1,
	on_rightclick = function(self, clicker)
		if not clicker:is_player() then return end
		if mobs:protect(self, clicker) then return end
		local item = clicker:get_wielded_item()
		local name = item:get_name()
		-- ALIMENTAÇÃO PARA REPRODUÇÃO
		if name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
			if not self.bred then
				self.bred = true
				item:take_item()
				clicker:set_wielded_item(item)
				local mob_type = self.name == "nh_mob:bull" and "bull" or "cow"
				core.chat_send_player(clicker:get_player_name(), S("The bull is ready to breed!")) -- Efeito de coração sobre o mob
				local pos = self.object:get_pos()
				core.add_particlespawner({
					amount = 5,
					time = 1,
					minpos = { x = pos.x - 0.5, y = pos.y + 2, z = pos.z - 0.5 },
					maxpos = { x = pos.x + 0.5, y = pos.y + 3, z = pos.z + 0.5 },
					minvel = { x = 0, y = 0.5, z = 0 },
					maxvel = { x = 0, y = 1, z = 0 },
					minexptime = 1,
					maxexptime = 1.5,
					minsize = 1,
					maxsize = 1.5,
					texture = "heart.png",
				})
				return
			else
				core.chat_send_player(clicker:get_player_name(), S("Already ready to breed!"))
				return
			end
		end
		if mobs:feed_tame(self, clicker, 1, false, false) then return end
		if self.driver then -- Se já tem alguém montado, desmonta
			mobs:detach(self.driver, { x = 1, y = 0, z = 0 })
			self.driver = nil
			return
		end
		local item = clicker:get_wielded_item()
		local name = item:get_name()
		if name == "mobs:saddle" then -- Coloca a sela E já monta
			self.saddled = true -- flag interna
			item:take_item()
			clicker:set_wielded_item(item)
			core.chat_send_player(clicker:get_player_name(), S("Saddle placed!"))
			mobs:attach(self, clicker) -- já monta na hora
			return
		end
		if self.saddled then -- Clicou sem sela na mão: monta se já estiver selado
			mobs:attach(self, clicker)
			return
		end
		if name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
			core.chat_send_player(clicker:get_player_name(), S("You fed the bull! Mooo!"))
		elseif name == "" then -- mão vazia
			core.chat_send_player(clicker:get_player_name(), S("You petted the bull. hff, hff..."))
		else             -- item errado
			core.chat_send_player(clicker:get_player_name(), S("The bull is not interested in that..."))
		end
	end,
})
-- Spawn do touro (folhas de grama)
mobs:spawn({
	name = "nh_mob:bull",
	nodes = { "air" },
	neighbors = { "nh_nodes:grassleaves" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = -20,
	max_height = 30
})
--mobs:register_egg("nh_mob:bull", "Orbe com Touro", "orbspawner.png", 0)
register_orb_egg("nh_mob:bull", S("Orb with Bull"))
mobs:register_mob("nh_mob:cow", {
	type = "animal",
	passive = true,
	reach = 3,
	damage = 5,
	attack_type = "dogfight",
	drops = {
		{ name = "nh_nodes:cowleather", chance = 1, min = 1, max = 4 }, -- 1-4 couros
		{ name = "nh_nodes:cowmeat",    chance = 1, min = 2, max = 5 }, -- 2-7 carnes (sempre)
		{ name = "nh_nodes:bone",       chance = 1, min = 2, max = 5 }, -- 2-7 ossos (sempre)
	},
	description = S("Cow"),
	hp_min = 25,
	hp_max = 35,
	armor = 100,
	collisionbox = { -2.3, 0, -2.3, 2.3, 2.6, 2.3 },
	selectionbox = { -2.5, 0, -0.7, 0.9, 2.6, 0.7 },
	physical = true,
	stepheight = 2,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "cow.glb",
	textures = { "cow.png" },
	-- rotate = 180,
	visual_size = { x = 7.5, y = 7.5 },
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	-- fly = true,
	-- fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 6,
	view_range = 10,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	follow = { "nh_nodes:grassleaves" },
	sounds = { random = "BullSound", damage = "BullAngrySound", },
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
	saddle = "mobs:saddle", -- item de sela necessário
	ride_speed = 8,       -- velocidade montado
	ride_acceleration = 1.0, -- aceleração montado
	ride_friction = 0.8,  -- fricção ao parar
	-- Offset do jogador sobre o mob (ajuste conforme o visual do touro)
	driver_attach_at = { x = 0, y = 30, z = -5 },
	driver_eye_offset = { x = 0, y = 3, z = 0 },
	driver_scale_factor = 1,
	do_custom = function(self, dtime)
		if not self.hp_anterior then self.hp_anterior = self.health end -- detecta que levou dano comparando HP atual com o anterior
		if self.health < self.hp_anterior then                    -- levou dano de verdade
			self.hp_anterior = self.health
			self.passive = false
			self.state = ""
			-- tenta pegar o player mais próximo como alvo
			local pos = self.object:get_pos()
			local jogadores = core.get_connected_players()
			local alvo = nil
			local menor_dist = self.view_range or 10
			for _, p in ipairs(jogadores) do
				local dist = vector.distance(pos, p:get_pos())
				if dist < menor_dist then
					menor_dist = dist
					alvo = p
				end
			end
			if alvo then self:do_attack(alvo) end
		end
		self.hp_anterior = self.health
		-- REPRODUÇÃO
		-- Só verifica se a vaca está pronta
		if not self.bred then return end
		-- Timer para não checar todo tick
		self.breed_timer = (self.breed_timer or 0) + dtime
		if self.breed_timer < 2 then return end -- checa a cada 2 segundos
		self.breed_timer = 0
		-- Cooldown pós-reprodução
		if self.breed_cooldown and self.breed_cooldown > 0 then
			self.breed_cooldown = self.breed_cooldown - 2
			return
		end
		-- Procura touro próximo que também esteja pronto
		local pos = self.object:get_pos()
		local touro_ent = nil
		for _, obj in ipairs(core.get_objects_inside_radius(pos, 6)) do
			local ent = obj:get_luaentity()
			if ent and ent.name == "nh_mob:bull" and ent.bred then
				touro_ent = ent
				break
			end
		end
		if not touro_ent then return end
		-- Ambos prontos: reseta flags e aplica cooldown
		self.bred = false
		touro_ent.bred = false
		self.breed_cooldown = 300   -- 5 minutos
		-- Spawna filhote: 33% boi, 33% vaca, 33% touro
		local sorteio = math.random(1, 3) --local sorteio = math.random(1, 4)
		local filhote
		if sorteio == 1 then
			filhote = "nh_mob:ox"
		elseif sorteio == 2 then
			filhote = "nh_mob:bull"
		else
			filhote = "nh_mob:cow" -- sorteio 3 = 33%
		end
		local spawn_pos = { x = pos.x + math.random(-2, 2), y = pos.y, z = pos.z + math.random(-2, 2) }
		core.add_entity(spawn_pos, filhote)
		-- Partículas de coração no spawn
		core.add_particlespawner({
			amount = 15,
			time = 1,
			minpos = { x = spawn_pos.x - 0.5, y = spawn_pos.y, z = spawn_pos.z - 0.5 },
			maxpos = { x = spawn_pos.x + 0.5, y = spawn_pos.y + 1, z = spawn_pos.z + 0.5 },
			minvel = { x = -0.5, y = 1, z = -0.5 },
			maxvel = { x = 0.5, y = 2, z = 0.5 },
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 1,
			maxsize = 2,
			texture = "heart.png",
		})
		core.log("action", "[nh_mob] Reprodução: " .. filhote .. " gerado!")
		core.chat_send_all(S("A bovine calf was born!"))
	end,
	on_rightclick = function(self, clicker)
		if not clicker:is_player() then return end
		if mobs:protect(self, clicker) then return end
		local item = clicker:get_wielded_item()
		local name = item:get_name()
		-- ALIMENTAÇÃO PARA REPRODUÇÃO
		if name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
			if not self.bred then
				self.bred = true
				item:take_item()
				clicker:set_wielded_item(item)
				local mob_type = self.name == "nh_mob:bull" and "bull" or "cow"
				core.chat_send_player(clicker:get_player_name(), S("The cow is ready to breed!"))
				-- Efeito de coração sobre o mob
				local pos = self.object:get_pos()
				core.add_particlespawner({
					amount = 5,
					time = 1,
					minpos = { x = pos.x - 0.5, y = pos.y + 2, z = pos.z - 0.5 },
					maxpos = { x = pos.x + 0.5, y = pos.y + 3, z = pos.z + 0.5 },
					minvel = { x = 0, y = 0.5, z = 0 },
					maxvel = { x = 0, y = 1, z = 0 },
					minexptime = 1,
					maxexptime = 1.5,
					minsize = 1,
					maxsize = 1.5,
					texture = "heart.png",
				})
				return
			else
				core.chat_send_player(clicker:get_player_name(), S("Already ready to breed!"))
				return
			end
		end
		if mobs:feed_tame(self, clicker, 1, false, false) then return end
		if self.driver then -- Se já tem alguém montado, desmonta
			mobs:detach(self.driver, { x = 1, y = 0, z = 0 })
			self.driver = nil
			return
		end
		local item = clicker:get_wielded_item()
		local name = item:get_name()
		-- Coloca a sela E já monta
		if name == "mobs:saddle" then
			self.saddled = true -- flag interna
			item:take_item()
			clicker:set_wielded_item(item)
			core.chat_send_player(clicker:get_player_name(), S("Saddle placed!"))
			mobs:attach(self, clicker) -- já monta na hora
			return
		end
		-- Clicou sem sela na mão: monta se já estiver selado
		if self.saddled then
			mobs:attach(self, clicker)
			return
		end

		if name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
			core.chat_send_player(clicker:get_player_name(), S("You fed the cow! Mooo!"))
		elseif name == "" then -- mão vazia
			core.chat_send_player(clicker:get_player_name(), S("You petted the cow. hff, hff..."))
		else             -- item errado
			core.chat_send_player(clicker:get_player_name(), S("The cow is not interested in that..."))
		end
	end,
})
-- Spawn do touro (folhas de grama)
mobs:spawn({
	name = "nh_mob:cow",
	nodes = { "air" },
	neighbors = { "nh_nodes:grassleaves" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 2,
	min_height = -20,
	max_height = 30
})
--mobs:register_egg("nh_mob:bull", "Orbe com Touro", "orbspawner.png", 0)
register_orb_egg("nh_mob:cow", S("Orb with Cow"))
mobs:register_mob("nh_mob:ox", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 4,
	attack_type = "dogfight",
	drops = {
		{ name = "nh_nodes:cowleather", chance = 1, min = 1, max = 4 }, -- 1-4 couros
		{ name = "nh_nodes:cowmeat",    chance = 1, min = 2, max = 5 }, -- 2-7 carnes (sempre)
		{ name = "nh_nodes:bone",       chance = 1, min = 2, max = 5 }, -- 2-7 ossos (sempre)
	},
	description = S("Ox"),
	hp_min = 25,
	hp_max = 35,
	armor = 100,
	collisionbox = { -2.5, 0, -0.7, 0.9, 2.6, 0.7 },
	selectionbox = { -2.5, 0, -0.7, 0.9, 2.6, 0.7 },
	physical = true,
	stepheight = 2,
	fall_speed = -8,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "ox.glb",
	textures = { "bull.png" },
	-- rotate = 180,
	visual_size = { x = 7.5, y = 7.5 },
	-- PERMITIRIA "VOAR" se não retirasse a capacidade de andar...
	-- fly = true,
	-- fly_in = {"nh_nodes:air"},  -- Pode ser uma lista!
	walk_velocity = 1,
	run_velocity = 6,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	follow = { "nh_nodes:grassleaves" },
	sounds = { random = "BullSound", damage = "BullAngrySound", },
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
	saddle = "mobs:saddle", -- item de sela necessário
	ride_speed = 8,       -- velocidade montado
	ride_acceleration = 1.0, -- aceleração montado
	ride_friction = 0.8,  -- fricção ao parar
	-- Offset do jogador sobre o mob (ajuste conforme o visual do touro)
	driver_attach_at = { x = 0, y = 30, z = -5 },
	driver_eye_offset = { x = 0, y = 3, z = 0 },
	driver_scale_factor = 1,
	on_rightclick = function(self, clicker)
		if not clicker:is_player() then return end
		if mobs:protect(self, clicker) then return end
		if mobs:feed_tame(self, clicker, 1, false, false) then return end
		-- Se já tem alguém montado, desmonta
		if self.driver then
			mobs:detach(self.driver, { x = 1, y = 0, z = 0 })
			self.driver = nil
			return
		end
		local item = clicker:get_wielded_item()
		local name = item:get_name()
		-- Coloca a sela E já monta
		if name == "mobs:saddle" then
			self.saddled = true -- flag interna
			item:take_item()
			clicker:set_wielded_item(item)
			core.chat_send_player(clicker:get_player_name(), S("Saddle placed!"))
			mobs:attach(self, clicker) -- já monta na hora
			return
		end
		-- Clicou sem sela na mão: monta se já estiver selado
		if self.saddled then
			mobs:attach(self, clicker)
			return
		end
		if name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
			core.chat_send_player(clicker:get_player_name(), S("You fed the ox! Mooo!"))
		elseif name == "" then -- mão vazia
			core.chat_send_player(clicker:get_player_name(), S("You petted the ox. hff, hff..."))
		else             -- item errado
			core.chat_send_player(clicker:get_player_name(), S("The ox is not interested in that..."))
		end
	end,
})
register_orb_egg("nh_mob:ox", S("Orb with Ox"))
-- MOB 4: Aguia (Agressivo)
mobs:register_mob("nh_mob:eagle", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	--attack_chance = 8, -- entre 1-10
	description = S("Eagle"),
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:rat", "nh_mob:rabbit" },
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = { -0.5, 0, -0.2, 0.3, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.5, 2.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "eagle.glb",
	textures = { "eagle.png" },
	--rotate = 180,
	visual_size = { x = 15, y = 15 }, -- visual_size = {x = 2.1, y = 2.1},
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,                    -- Permite "voar" na água
	fly_in = "air",                -- Voa no ar
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
		punch_start = 0.5, -- Frame inicial do ataque
		punch_end = 1, -- Frame final do ataque
		punch_speed = 1, -- vel 1-30
	},
	sounds = { random = "EagleSound", damage = "EagleSound", },
	follow = { "nh_nodes:torch2" },
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

		if vel.y > 0.5 then -- Subindo
			if self.state ~= "fly_up" then
				self.state = "fly_up"
				self:set_animation("fly_up")
			end
		elseif vel.y < -0.5 then -- Descendo
			if self.state ~= "fly_down" then
				self.state = "fly_down"
				self:set_animation("fly_down")
			end
		else -- Movimento normal
			if self.state ~= "walk" then
				self.state = "walk"
				self:set_animation("walk")
			end
		end
		-- controla timer para não rodar todo tick
		self.perch_timer = (self.perch_timer or 0) + dtime
		if self.perch_timer < 3 then return end
		self.perch_timer = 0
		local time = core.get_timeofday()
		-- Só tenta pousar de noite
		if time > 0.75 or time < 0.2 then
			if not self.is_perching then
				local pos = self.object:get_pos()
				local leaves = core.find_node_near(pos, 6, { "nh_nodes:oaktimber" })
				if leaves then
					leaves.y = leaves.y + 1
					self.object:set_pos(leaves)
					self.object:set_velocity({ x = 0, y = 0, z = 0 })
					self.object:set_acceleration({ x = 0, y = 0, z = 0 })
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
				self.object:set_acceleration({ x = 0, y = 0, z = 0 }) -- restaura aceleração padrão de voo
				self.object:set_velocity({ x = 5, y = 5, z = 5 }) -- impulso inicial
				self:set_animation("walk")
			end
		end
	end,
})
-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
	name = "nh_mob:eagle",
	nodes = { "air" },              -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:leaves" }, --neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = 10,
	max_height = 50
})
--mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)
register_orb_egg("nh_mob:eagle", S("Orb with Eagle"))
-- MOB 4: Milhafre (Agressivo)
mobs:register_mob("nh_mob:blackkite", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	--attack_chance = 8, -- entre 1-10
	description = S("Black Kite"),
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:rat", "nh_mob:rabbit" },
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = { -0.5, 0, -0.2, 0.3, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.5, 2.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "eagle.glb",
	textures = { "blackkite.png" },
	-- rotate = 180,
	visual_size = { x = 15, y = 15 }, -- visual_size = {x = 2.1, y = 2.1},
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,                    -- Permite "voar" na água
	fly_in = "air",                -- Voa no ar
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
		punch_start = 0.5, -- Frame inicial do ataque
		punch_end = 1, -- Frame final do ataque
		punch_speed = 1, -- vel 1-30
	},
	sounds = { random = "EagleSound", damage = "EagleSound", },
	follow = { "nh_nodes:torch2" },
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
		if vel.y > 0.5 then -- Subindo
			if self.state ~= "fly_up" then
				self.state = "fly_up"
				self:set_animation("fly_up")
			end
		elseif vel.y < -0.5 then -- Descendo
			if self.state ~= "fly_down" then
				self.state = "fly_down"
				self:set_animation("fly_down")
			end
		else -- Movimento normal
			if self.state ~= "walk" then
				self.state = "walk"
				self:set_animation("walk")
			end
		end
		self.perch_timer = (self.perch_timer or 0) + dtime -- controla timer para não rodar todo tick
		if self.perch_timer < 3 then return end
		self.perch_timer = 0
		local time = core.get_timeofday()
		if time > 0.75 or time < 0.2 then -- Só tenta pousar de noite
			if not self.is_perching then
				local pos = self.object:get_pos()
				local leaves = core.find_node_near(pos, 6, { "nh_nodes:oaktimber" })
				if leaves then
					leaves.y = leaves.y + 1
					self.object:set_pos(leaves)
					self.object:set_velocity({ x = 0, y = 0, z = 0 })
					self.object:set_acceleration({ x = 0, y = 0, z = 0 })
					self.fly = false
					self.walk_velocity = 0
					self.run_velocity = 0
					self.is_perching = true
					self.eagle_anim_state = "perch"
					self:set_animation("stand")
				end
			end
		else
			if self.is_perching then -- Se amanheceu, volta a voar
				self.is_perching = false
				self.fly = true
				self.walk_velocity = 1
				self.run_velocity = 4
				self.object:set_acceleration({ x = 0, y = 0, z = 0 }) -- restaura aceleração padrão de voo
				self.object:set_velocity({ x = 5, y = 5, z = 5 }) -- impulso inicial
				self:set_animation("walk")
			end
		end
	end,

})
mobs:spawn({                        -- Spawn da aguia (copas de carvalhos)
	name = "nh_mob:blackkite",
	nodes = { "air" },              -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:leaves" }, --neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = 10,
	max_height = 50
})
--mobs:register_egg("nh_mob:blackkite", "Orbe com Milhafre", "orbspawner.png", 0)
register_orb_egg("nh_mob:blackkite", S("Orb with Black Kite"))
-- MOB 4: Fenix (Agressivo)
mobs:register_mob("nh_mob:phoenix", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	-- attack_chance = 8, -- entre 1-10
	description = S("Phoenix") .. "\n" .. S("[Altered Animal]"),
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = { -0.5, 0, -0.2, 0.3, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.5, 2.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "eagle.glb",
	textures = { "phoenix.png" },
	-- rotate = 180,
	visual_size = { x = 30, y = 30 }, -- visual_size = {x = 2.1, y = 2.1},
	-- BRILHO
	glow = 14,                     -- Intensidade de 0 a 14 (14 = mais brilhante)
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,                    -- Permite "voar" na água
	fly_in = "air",                -- Voa no ar
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
		punch_start = 0.5, -- Frame inicial do ataque
		punch_end = 1, -- Frame final do ataque
		punch_speed = 1, -- vel 1-30
	},
	sounds = { random = "EagleSound", damage = "EagleSound", },
	follow = { "nh_nodes:torch2" },
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
		if vel.y > 0.5 then -- Subindo
			if self.state ~= "fly_up" then
				self.state = "fly_up"
				self:set_animation("fly_up")
			end
		elseif vel.y < -0.5 then -- Descendo
			if self.state ~= "fly_down" then
				self.state = "fly_down"
				self:set_animation("fly_down")
			end
		else -- Movimento normal
			if self.state ~= "walk" then
				self.state = "walk"
				self:set_animation("walk")
			end
		end
		-- controla timer para não rodar todo tick
		self.perch_timer = (self.perch_timer or 0) + dtime
		if self.perch_timer < 3 then return end
		self.perch_timer = 0
		local time = core.get_timeofday()
		-- Só tenta pousar de noite
		if time > 0.75 or time < 0.2 then
			if not self.is_perching then
				local pos = self.object:get_pos()
				local leaves = core.find_node_near(pos, 6, { "nh_nodes:magma" })
				if leaves then
					leaves.y = leaves.y + 1
					self.object:set_pos(leaves)
					self.object:set_velocity({ x = 0, y = 0, z = 0 })
					self.object:set_acceleration({ x = 0, y = 0, z = 0 })
					self.fly = false
					self.walk_velocity = 0
					self.run_velocity = 0
					self.is_perching = true
					self.eagle_anim_state = "perch"
					self:set_animation("stand")
				end
			end
		else
			if self.is_perching then -- Se amanheceu, volta a voar
				self.is_perching = false
				self.fly = true
				self.walk_velocity = 1
				self.run_velocity = 4
				self.object:set_acceleration({ x = 0, y = 0, z = 0 }) -- restaura aceleração padrão de voo
				self.object:set_velocity({ x = 5, y = 5, z = 5 }) -- impulso inicial
				self:set_animation("walk")
			end
		end
	end,
})
-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
	name = "nh_mob:phoenix",
	nodes = { "air" },              -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:basalt" }, --neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = 15,
	max_height = 50
})
--mobs:register_egg("nh_mob:phoenix", "Orbe com Fênix", "orbspawner.png", 0)
register_orb_egg("nh_mob:phoenix", S("Orb with Phoenix"))
-- MOB 1: OURIÇO (Defensivo)
mobs:register_mob("nh_mob:hedgehog", {
	type = "animal",
	passive = true, -- Pode se defender quando atacado
	damage = 5,
	reach = 1,
	description = S("Hedgehog"),
	hp_min = 10,
	hp_max = 15,
	armor = 100,
	collisionbox = { -0.3, 0, -0.25, 0.25, 0.4, 0.25 },
	physical = true,
	stepheight = 1.1,
	fall_speed = -8,
	fall_damage = 2,
	visual = "mesh",
	mesh = "ourico.glb",
	textures = { "ouricoskin.png" },
	-- rotate = 180,
	visual_size = { x = 15, y = 15 },
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:cricket", "nh_mob:cicada", "nh_mob:ladybug" },
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
			core.chat_send_player(clicker:get_player_name(),
				S("The hedgehog is friendly, but I need to be careful if I attack it..."))
		end
	end,
	do_punch = function(self, hitter, tflp, tool_caps, dir, damage)
		-- só age se for jogador de mão vazia
		if not hitter:is_player() then return end -- dano normal pra outros mobs

		local item = hitter:get_wielded_item()
		if item:get_name() == "" then -- machuca o jogador
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
				-- Dano em mobs próximos
				if ent and ent._cmi_is_mob and ent.name ~= "nh_mob:hedgehog" then
					obj:punch(obj, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 5 } }, nil)
				elseif obj:is_player() then -- Dano no jogador ao encostar
					self._player_timers = self._player_timers or {}
					local name = obj:get_player_name()
					self._player_timers[name] = (self._player_timers[name] or 0) + 1
					-- Só aplica dano a cada tick (já controlado pelo spike_timer de 1s)
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = { fleshy = 5 } -- mesmo dano do mob (damage = 5)
					}, nil)
					core.chat_send_player(name, S("The spines hurt me!"))
				end
			end
		end
	end,
})
-- Spawn do Ouriço (grama)
mobs:spawn({
	name = "nh_mob:hedgehog",
	nodes = { "air" },
	neighbors = { "nh_nodes:grass" },
	max_light = 15,
	interval = 120,
	chance = 3000,
	active_object_count = 3,
	min_height = -10,
	max_height = 25
})
--mobs:register_egg("nh_mob:ourico", "Orbe com Ouriço", "orbspawner.png", 0)
register_orb_egg("nh_mob:hedgehog", S("Orb with Hedgehog"))
-- MOB 1: OURIÇO SHADOW (Defensivo)
mobs:register_mob("nh_mob:hedgehogshadow", {
	type = "animal",
	passive = true, -- Pode se defender quando atacado
	damage = 2,
	reach = 1,
	description = S("Shadow Hedgehog") .. "\n" .. S("[Modified Animal]"),
	hp_min = 10,
	hp_max = 15,
	armor = 100,
	collisionbox = { -0.3, 0, -0.25, 0.25, 0.4, 0.25 },
	physical = true,
	stepheight = 1.1,
	fall_speed = -6,
	fall_damage = 2,
	visual = "mesh",
	mesh = "ourico.glb",
	textures = { "ouricoshadow.png" },
	--rotate = 180,
	visual_size = { x = 15, y = 15 },
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:cricket", "nh_mob:cicada", "nh_mob:ladybug" },
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
			core.chat_send_player(clicker:get_player_name(),
				S("The hedgehog is friendly, but I need to be careful if I attack it..."))
		end
	end,
	do_punch = function(self, hitter, tflp, tool_caps, dir, damage)
		-- só age se for jogador de mão vazia
		if not hitter:is_player() then return end -- dano normal pra outros mobs
		local item = hitter:get_wielded_item()
		if item:get_name() == "" then       -- machuca o jogador
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
				-- Dano em mobs próximos
				if ent and ent._cmi_is_mob and ent.name ~= "nh_mob:hedgehogshadow" then
					obj:punch(obj, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 5 } }, nil)
				elseif obj:is_player() then -- Dano no jogador ao encostar
					self._player_timers = self._player_timers or {}
					local name = obj:get_player_name()
					self._player_timers[name] = (self._player_timers[name] or 0) + 1
					-- Só aplica dano a cada tick (já controlado pelo spike_timer de 1s)
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = { fleshy = 5 } -- mesmo dano do mob (damage = 5)
					}, nil)
					core.chat_send_player(name, S("The spines hurt me!"))
				end
			end
		end
	end,
})
-- Spawn do Ouriço (grama)
mobs:spawn({
	name = "nh_mob:hedgehogshadow",
	nodes = { "air" },
	neighbors = { "nh_nodes:grass" },
	max_light = 15,
	interval = 120,
	chance = 300,
	active_object_count = 1,
	min_height = -10,
	max_height = 25
})
--mobs:register_egg("nh_mob:ouricoshadow", "Orbe com Ouriço Raro", "orbspawner.png", 0)
register_orb_egg("nh_mob:hedgehogshadow", S("Orb with Shadow Hedgehog"))
-- Ouriço do mar
mobs:register_mob("nh_mob:urchin", {
	type = "animal",
	passive = true,
	damage = 5,
	reach = 1,
	description = S("Sea Urchin"),
	hp_min = 10,
	hp_max = 15,
	armor = 100,
	collisionbox = { -0.5, 0, -0.5, 0.5, 1, 0.5 },
	selectionbox = { -0.5, 0, -0.5, 0.5, 1, 0.5 },
	physical = true,
	stepheight = 1.1,
	fall_speed = -8,
	fall_damage = 2,
	floats = 0,
	visual = "mesh",
	mesh = "urchin.glb",
	textures = { "urchin.png" },
	--rotate = 180,
	visual_size = { x = 10, y = 10 },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ backface_culling = false, }) end,
	walk_velocity = 0.05,
	run_velocity = 0.1,
	view_range = 10,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 1, stand_start = 0, stand_end = 1, walk_start = 0, walk_end = 2, run_start = 0, run_end = 2, },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(), S("I need to be careful if I attack it..."))
		end
	end,
	do_punch = function(self, hitter, tflp, tool_caps, dir, damage)
		-- só age se for jogador de mão vazia
		if not hitter:is_player() then return end -- dano normal pra outros mobs
		local item = hitter:get_wielded_item()
		if item:get_name() == "" then       -- machuca o jogador
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
		local objetos = core.get_objects_inside_radius(pos, 1.2)
		for _, obj in ipairs(objetos) do
			if obj ~= self.object then
				local ent = obj:get_luaentity()
				if ent and ent._cmi_is_mob and ent.name ~= "nh_mob:urchin" then -- Dano em mobs próximos
					obj:punch(obj, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 5 } }, nil)
				elseif obj:is_player() then                         -- Dano no jogador ao encostar
					self._player_timers = self._player_timers or {}
					local name = obj:get_player_name()
					self._player_timers[name] = (self._player_timers[name] or 0) + 1
					obj:punch(self.object, 1.0,
						{             -- Só aplica dano a cada tick (já controlado pelo spike_timer de 1s)
							full_punch_interval = 1.0,
							damage_groups = { fleshy = 5 } -- mesmo dano do mob (damage = 5)
						}, nil)
					core.chat_send_player(name, S("The spines hurt me!"))
				end
			end
		end
	end,
})
-- Spawn do Ouriço do mar
mobs:spawn({
	name = "nh_mob:urchin",
	nodes = { "nh_nodes:water" },
	neighbors = { "nh_nodes:wet_sand" },
	max_light = 15,
	interval = 120,
	chance = 3000,
	active_object_count = 5,
	min_height = -17,
	max_height = -13
})
--mobs:register_egg("nh_mob:ourico", "Orbe com Ouriço", "orbspawner.png", 0)
register_orb_egg("nh_mob:urchin", S("Orb with Sea Urchin"))
-- MOB 4: Caravela (passivo/dano)
mobs:register_mob("nh_mob:manowar", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	-- attack_chance = 8, -- entre 1-10
	description = S("Man o' war"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	hp_min = 5,
	hp_max = 7,
	armor = 100,
	collisionbox = { -0.5, 0, -0.2, 0.3, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.3, 2.4, 0.2 },
	physical = true,
	--stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 0,
	visual = "mesh",
	mesh = "caravela.obj",
	textures = { "caravela.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 }, -- visual_size = {x = 2.1, y = 2.1},
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ backface_culling = false, use_texture_alpha = true, }) end,
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,  -- Permite "voar" na água
	fly_in = "air", -- Voa no ar
	walk_velocity = 1,
	run_velocity = 2,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	follow = { "nh_nodes:torch2" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(),
				S("I need to be careful if I attack it..."))
		end
	end,
	do_custom = function(self, dtime)
		self._spike_timer = (self._spike_timer or 0) + dtime
		if self._spike_timer < 1 then return end
		self._spike_timer = 0
		local pos = self.object:get_pos()
		-- Área restrita aos 2 blocos abaixo do mob
		local below_min = vector.new(pos.x - 1, pos.y - 5.5, pos.z - 0.6)
		local below_max = vector.new(pos.x + 1, pos.y + 2, pos.z + 0.6)
		local objetos = core.get_objects_in_area(below_min, below_max)
		for _, obj in ipairs(objetos) do
			if obj ~= self.object then
				local ent = obj:get_luaentity()
				if ent and ent._cmi_is_mob and ent.name ~= "nh_mob:manowar" then
					obj:punch(obj, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 5 } }, nil)
				elseif obj:is_player() then
					self._player_timers = self._player_timers or {}
					local name = obj:get_player_name()
					self._player_timers[name] = (self._player_timers[name] or 0) + 1
					obj:punch(self.object, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 5 } }, nil)
					core.chat_send_player(name, S("The tentacles hurt me!"))
				end
			end
		end
	end,
})
-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
	name = "nh_mob:manowar",
	nodes = { "air" },                 -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:top_grass" }, --neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 5,
	min_height = 500,
	max_height = 1010
})
--mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)
register_orb_egg("nh_mob:manowar", S("Orb with Man o' War"))
local DOME_RADIUS = 18 -- Raio da esfera
local function create_dome(center)
	local placed = {}
	local r = DOME_RADIUS
	for x = -r, r do
		for y = -r, r do
			for z = -r, r do
				local dist = math.sqrt(x * x + y * y + z * z)
				if dist >= r - 1 and dist <= r then -- Só a casca: entre r-1 e r (espessura de 1 node)
					local pos = { x = math.floor(center.x + x), y = math.floor(center.y + y), z = math.floor(center.z + z) }
					-- Só coloca se for ar, para não destruir terreno
					local node = core.get_node(pos)
					if node.name == "air" then
						core.set_node(pos, { name = "nh_nodes:barrier" })
						table.insert(placed, pos)
					end
				end
			end
		end
	end
	return placed -- salva as posições para remover depois
end
function remove_dome(placed_list)
	if not placed_list then return end
	for _, pos in ipairs(placed_list) do
		local node = core.get_node(pos)
		if node.name == "nh_nodes:barrier" then core.set_node(pos, { name = "air" }) end
	end
end

-- SENTINEL (BOSS)
mobs:register_mob("nh_mob:sentinel", {
	type = "monster",
	-- passive = false,
	reach = 1,
	damage = 10,
	attack_type = "dogfight",
	-- attack_chance = 8, -- entre 1-10
	description = S("Sentinel"),
	blood_texture = "spark_particle.png^[colorize:#FF8800:150", -- textura customizada
	blood_amount = 3,                                        -- quantidade de partículas
	hp_min = 50,
	hp_max = 50,
	armor = 100,
	collisionbox = { -0.5, 0, -0.5, 0.5, 5, 0.5 },
	selectionbox = { -0.5, 0, -0.5, 0.5, 5, 0.5 },
	physical = true,
	-- stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "skydragon.obj",
	textures = { "skydragon.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 }, -- visual_size = {x = 2.1, y = 2.1},
	glow = 14,
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,  -- Permite "voar" na água
	fly_in = "air", -- Voa no ar
	walk_velocity = 2,
	run_velocity = 3,
	view_range = 30,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	follow = { "nh_nodes:torch2", "nh_nodes:redcrystal" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(), S("Is it a wasp?..."))
		end
	end,
	custom_attack = function(self, to_attack)
		self.attack_count = (self.attack_count or 0) + 1
		if self.attack_count < 3 then return end
		self.attack_count = 0
		self:set_animation("punch", false)
		return true -- PARA CONTINUAR.
	end,
	after_activate = function(self, staticdata, def, dtime)
		self.object:set_properties({ static_save = true })
		core.after(0.5, function() -- Restaura ataque ao jogador mais próximo sempre (novo spawn OU reload)
			if not self.object or not self.object:is_valid() then return end
			local pos = self.object:get_pos()
			local nearest_player = nil
			local nearest_dist = self.view_range or 30
			for _, player in ipairs(core.get_connected_players()) do
				local dist = vector.distance(pos, player:get_pos())
				if dist < nearest_dist then
					nearest_dist = dist
					nearest_player = player
				end
			end
			if nearest_player then self:do_attack(nearest_player) end
		end)
		if staticdata and staticdata ~= "" then return end -- Cúpula e punch simbólico só no PRIMEIRO spawn (staticdata vazio = novo)
		core.after(0.5,
			function() if self.object and self.object:is_valid() then self._dome_nodes = create_dome(self.object:get_pos()) end end)
		local pos = self.object:get_pos()
		local nearest_player = nil
		local nearest_dist = 20
		for _, player in ipairs(core.get_connected_players()) do
			local dist = vector.distance(pos, player:get_pos())
			if dist < nearest_dist then
				nearest_dist = dist
				nearest_player = player
			end
		end
		if nearest_player then
			core.after(0.2, function()
				if self.object:is_valid() then
					self.object:punch(nearest_player, 1.0,
						{ full_punch_interval = 1.0, damage_groups = { fleshy = 1 }, }, nil)
				end
			end)
		end
	end,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		-- Sobe na água se estiver submerso
		local node = core.get_node({ x = pos.x, y = pos.y, z = pos.z })
		local ndef = core.registered_nodes[node.name]
		if ndef and ndef.groups and ndef.groups.liquid then
			local v = self.object:get_velocity()
			if v and v.y < 0.5 then self.object:set_velocity({ x = v.x, y = 0.8, z = v.z }) end
		end
		self._spike_timer = (self._spike_timer or 0) + dtime
		if self._spike_timer < 1 then return end
		self._spike_timer = 0
		local pos = self.object:get_pos()
		local function get_objects_in_box(center, half_x, half_y, half_z)
			-- Pega num raio maior que a box para não perder ninguém, depois filtra
			local max_radius = math.max(half_x, half_y, half_z)
			local candidatos = core.get_objects_inside_radius(center, max_radius)
			local resultado = {}
			for _, obj in ipairs(candidatos) do
				local opos = obj:get_pos()
				if opos then
					if math.abs(opos.x - center.x) <= half_x and
						math.abs(opos.y - center.y) <= half_y and
						math.abs(opos.z - center.z) <= half_z then
						table.insert(resultado, obj)
					end
				end
			end
			return resultado
		end
		-- Uso (box de 2x4x2 centrada 2 blocos acima do mob):
		local centro = { x = pos.x, y = pos.y + 2, z = pos.z }
		local objetos = get_objects_in_box(centro, 2, 4, 2)
		for _, obj in ipairs(objetos) do
			if obj ~= self.object then
				local ent = obj:get_luaentity()
				if ent and ent._cmi_is_mob and ent.name ~= "nh_mob:sentinel" then -- Dano em mobs próximos
					obj:punch(obj, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 5 } }, nil)
					-- Dano no jogador ao encostar
				elseif obj:is_player() then
					self._player_timers = self._player_timers or {}
					local name = obj:get_player_name()
					self._player_timers[name] = (self._player_timers[name] or 0) + 1
					-- Só aplica dano a cada tick (já controlado pelo spike_timer de 1s)
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = { fleshy = 5 } -- mesmo dano do mob (damage = 5)
					}, nil)
					core.chat_send_player(name, S("This is hot, it burned me!"))
				end
			end
		end
		if self._last_hp == nil then
			self._last_hp = self.health -- AQUI também
			self._hud_timer = 0
		end
		self._hud_timer = self._hud_timer + dtime
		local current_hp = self.health -- E AQUI
		if current_hp ~= self._last_hp then
			self._last_hp = current_hp
			update_boss_hud(self, S("Sentinel"))
			self._hud_timer = 0
		elseif self._hud_timer >= 0.5 then
			self._hud_timer = 0
			update_boss_hud(self, S("Sentinel"))
		end
		return true
	end,
	on_die = function(self, pos, killer)
		remove_dome(self._dome_nodes)
		self._dome_nodes = nil
		remove_all_boss_hud(self)
	end,
})
core.register_on_dieplayer(function(player, reason)
	local pname = player:get_player_name()
	for _, obj in ipairs(core.get_objects_inside_radius(player:get_pos(), 150)) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "nh_mob:sentinel" then
			if ent._hud_ids and ent._hud_ids[pname] then
				player:hud_remove(ent._hud_ids[pname].bar)
				player:hud_remove(ent._hud_ids[pname].text)
				ent._hud_ids[pname] = nil
				free_slot(pname, get_self_id(ent))
			end
			remove_dome(ent._dome_nodes)
			ent._dome_nodes = nil
			-- Substitui por estátua e remove o mob
			local pos = obj:get_pos()
			if pos then core.set_node(pos, { name = "nh_nodes:sentinelstatue" }) end
			mobs:remove(ent, true)
		end
		if ent and ent.name == "nh_mob:giantcrab" then
			if ent._hud_ids and ent._hud_ids[pname] then
				player:hud_remove(ent._hud_ids[pname].bar)
				player:hud_remove(ent._hud_ids[pname].text)
				ent._hud_ids[pname] = nil
				free_slot(pname, get_self_id(ent))
			end
			-- Substitui por estátua e remove o mob
			local pos = obj:get_pos()
			if pos then core.set_node(pos, { name = "nh_nodes:giantcrabstatue" }) end
			mobs:remove(ent, true)
		end
	end
end)
--[[
-- Spawn da bolha (ceu)
mobs:spawn({
    name = "nh_mob:sentinel",
    nodes = { "air" },                  -- nh_nodes = {"nh_nodes:water"},
    neighbors = { "nh_nodes:top_grass" }, --neighbors = {"nh_nodes:wet_sand"},
    max_light = 15,
    interval = 120,
    chance = 2000,
    active_object_count = 1,
    min_height = 820,
    max_height = 1010
})
]] --
--mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)
register_orb_egg("nh_mob:sentinel", S("Orb with Sentinel"))
-- MOB 4: Bolha (passivo/plataforma)
mobs:register_mob("nh_mob:bubble", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	-- attack_chance = 8,                 -- entre 1-10
	description = S("Bubble"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	hp_min = 2,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.5, 0, -0.5, 0.5, 1, 0.5 },
	selectionbox = { -0.5, 0, -0.5, 0.5, 1, 0.5 },
	physical = true,
	-- stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "bubblefly.obj",
	textures = { "bubblefly.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 }, -- visual_size = {x = 2.1, y = 2.1},
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ use_texture_alpha = true, textures = { "bubblefly.png", "bubblefly.png", }, }) end,
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,  -- Permite "voar" na água
	fly_in = "air", -- Voa no ar
	walk_velocity = 1,
	run_velocity = 2,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	follow = { "nh_nodes:torch2" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(), S("Just a bubble..."))
		end
	end,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		-- Sobe na água se estiver submerso
		local node = core.get_node({ x = pos.x, y = pos.y, z = pos.z })
		local ndef = core.registered_nodes[node.name]
		if ndef and ndef.groups and ndef.groups.liquid then
			local v = self.object:get_velocity()
			if v and v.y < 0.5 then self.object:set_velocity({ x = v.x, y = 0.8, z = v.z }) end
		end
		self._last_pos = self._last_pos or vector.new(pos)
		local delta = vector.subtract(pos, self._last_pos)
		self._last_pos = vector.new(pos)
		-- Só processa se a bolha realmente se moveu
		local moved = math.abs(delta.x) > 0.001 or math.abs(delta.z) > 0.001
		local above_min = vector.new(pos.x - 0.5, pos.y + 1, pos.z - 0.5)
		local above_max = vector.new(pos.x + 0.5, pos.y + 2.8, pos.z + 0.5)
		self._player_timers = self._player_timers or {}
		local players_above = {}
		for _, obj in ipairs(core.get_objects_in_area(above_min, above_max)) do
			if obj:is_player() then
				local name = obj:get_player_name()
				players_above[name] = true
				-- Só aplica o delta se a BOLHA se moveu (não interfere com movimento do jogador)
				if moved then
					local ppos = obj:get_pos()
					obj:set_pos({ x = ppos.x + delta.x, y = ppos.y, z = ppos.z + delta.z })
				end
				self._player_timers[name] = (self._player_timers[name] or 0) + dtime
				if self._player_timers[name] >= 10 then
					self.object:punch(self.object, 1.0,
						{ full_punch_interval = 0, damage_groups = { fleshy = self.object:get_hp() } }, nil)
					return
				end
			end
		end
		for name, _ in pairs(self._player_timers) do if not players_above[name] then self._player_timers[name] = nil end end
	end,
})
-- Spawn da bolha (fundo do mar)
mobs:spawn({
	name = "nh_mob:bubble",
	nodes = { "nh_nodes:water" },    -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:fireice" }, -- neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 30,
	chance = 20,
	active_object_count = 10,
	min_height = -20,
	max_height = -15
})
-- Spawn da bolha (ceu)
mobs:spawn({
	name = "nh_mob:bubble",
	nodes = { "air" },                                  -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:top_grass", "nh_nodes:dirt" }, -- neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 10,
	min_height = 500,
	max_height = 1010
})
--mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)
register_orb_egg("nh_mob:bubble", S("Orb with Bubble"))
-- MOB 4: Bolha Grande (passivo/plataforma)
mobs:register_mob("nh_mob:bigbubble", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	-- attack_chance = 8, -- entre 1-10
	description = S("Big Bubble"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	hp_min = 1,
	hp_max = 2,
	armor = 100,
	collisionbox = { -1, 0, -1, 1, 2, 1 },
	selectionbox = { -1, 0, -1, 1, 2, 1 },
	physical = true,
	--stepheight = 2,           -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "bubblefly.obj",
	textures = { "bubblefly.png" },
	rotate = 180,
	visual_size = { x = 30, y = 30 }, -- visual_size = {x = 2.1, y = 2.1},
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ use_texture_alpha = true, textures = { "bubblefly.png", "bubblefly.png", }, }) end,
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,  -- Permite "voar" na água
	fly_in = "air", -- Voa no ar
	walk_velocity = 1,
	run_velocity = 2,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	follow = { "nh_nodes:torch2" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(), S("Just a bubble..."))
		end
	end,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		-- Sobe na água se estiver submerso
		local node = core.get_node({ x = pos.x, y = pos.y, z = pos.z })
		local ndef = core.registered_nodes[node.name]
		if ndef and ndef.groups and ndef.groups.liquid then
			local v = self.object:get_velocity()
			if v and v.y < 0.5 then self.object:set_velocity({ x = v.x, y = 0.8, z = v.z }) end
		end
		self._last_pos = self._last_pos or vector.new(pos)
		local delta = vector.subtract(pos, self._last_pos)
		self._last_pos = vector.new(pos)
		-- Só processa se a bolha realmente se moveu
		local moved = math.abs(delta.x) > 0.001 or math.abs(delta.z) > 0.001
		local above_min = vector.new(pos.x - 1, pos.y + 1.8, pos.z - 1)
		local above_max = vector.new(pos.x + 1, pos.y + 3.5, pos.z + 1)
		self._player_timers = self._player_timers or {}
		local players_above = {}
		for _, obj in ipairs(core.get_objects_in_area(above_min, above_max)) do
			if obj:is_player() then
				local name = obj:get_player_name()
				players_above[name] = true
				-- Só aplica o delta se a BOLHA se moveu (não interfere com movimento do jogador)
				if moved then
					local ppos = obj:get_pos()
					obj:set_pos({ x = ppos.x + delta.x, y = ppos.y, z = ppos.z + delta.z })
				end
				self._player_timers[name] = (self._player_timers[name] or 0) + dtime
				if self._player_timers[name] >= 10 then
					self.object:punch(self.object, 1.0, {
						full_punch_interval = 0,
						damage_groups = { fleshy = self.object:get_hp() }
					}, nil)
					return
				end
			end
		end
		for name, _ in pairs(self._player_timers) do if not players_above[name] then self._player_timers[name] = nil end end
	end,
})
-- Spawn da aguia (copas de carvalhos)
mobs:spawn({
	name = "nh_mob:bigbubble",
	nodes = { "air" },                                  -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:top_grass", "nh_nodes:dirt" }, --neighbors = {"nh_nodes:wet_sand"},
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 5,
	min_height = 500,
	max_height = 1010
})
--mobs:register_egg("nh_mob:eagle", "Orbe com Águia", "orbspawner.png", 0)
register_orb_egg("nh_mob:bigbubble", S("Orb with Big Bubble"))
-- MOB 2: COELHO (Passivo/Tímido)
mobs:register_mob("nh_mob:rabbit", {
	type = "animal",
	passive = true, -- Totalmente passivo
	damage = 0,  -- Não causa dano
	description = S("Dwarf Rabbit"),
	hp_min = 5,
	hp_max = 8,
	armor = 100,
	collisionbox = { -0.2, 0, -0.3, 0.2, 0.4, 0.3 },
	physical = true,
	stepheight = 1.1,
	fall_speed = -8,
	fall_damage = 2,
	visual = "mesh",
	mesh = "rabbit.glb",
	textures = { "rabbit.png" },
	--rotate = 180,
	visual_size = { x = 15, y = 15 },
	walk_velocity = 2,
	run_velocity = 5, -- Coelhos são rápidos quando assustados
	view_range = 8,
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	-- Coelhos fogem de jogadores
	runaway = true,
	runaway_from = { "player" },
	animation = { speed_normal = 3, stand_start = 0.5, stand_end = 2.5, walk_start = 3, walk_end = 4.5, run_start = 3, run_end = 4.5, },
	-- Coelhos pulam ocasionalmente
	jump = true,
	jump_height = 3,
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(), S("The rabbit ran away scared!"))
			self.object:set_velocity({ x = 0, y = 5, z = 0 }) -- Faz o coelho pular e fugir
		end
	end,
	sounds = { random = "RabbitSound1", damage = "rabbit_hurt", }, -- Sons (se você tiver arquivos de som)
})
-- Spawn do Coelho (neve)
mobs:spawn({
	name = "nh_mob:rabbit",
	nodes = { "air" },
	neighbors = { "nh_nodes:snow" },
	max_light = 15,
	interval = 120,
	chance = 2500,        -- Spawn mais frequente
	active_object_count = 8, -- Mais coelhos podem spawnar
	min_height = 0,
	max_height = 100
})
--mobs:register_egg("nh_mob:rabbit", "Orbe com Coelho", "orbspawner.png", 0)
register_orb_egg("nh_mob:rabbit", S("Orb with Dwarf Rabbit"))
-- Karibo (terror bird + Ostrich + shoebill)
mobs:register_mob("nh_mob:karibo", {
	type = "animal",
	passive = true, -- Pode se defender quando atacado
	damage = 3,
	reach = 1,
	description = S("Karibo") .. "\n" .. S("[Modified Animal]"),
	hp_min = 20,
	hp_max = 25,
	armor = 100,
	collisionbox = { -1, 0, -0.7, 0.4, 3.5, 0.7 },
	selectionbox = { -1, 0, -0.7, 0.4, 3.5, 0.7 },
	physical = true,
	stepheight = 1.1,
	fall_speed = -6,
	fall_damage = 2,
	visual = "mesh",
	mesh = "karibo.glb",
	textures = { "karibo.png" },
	-- rotate = 180,
	visual_size = { x = 7, y = 7 },
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:rabbit" },
	walk_velocity = 3,
	run_velocity = 7.5,
	view_range = 10,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	floats = 1,
	animation = {
		speed_normal = 1,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 1,
		run_start = 0,
		run_end = 1,
		--jump_start = 61,
		--jump_end = 80
	},
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			core.chat_send_player(clicker:get_player_name(),
				S("The Karibo looks a bit dangerous, but I think it can be tamed"))
		end
	end,
	do_custom = function(self, dtime)
		if not self.hp_anterior then self.hp_anterior = self.health end -- detecta que levou dano comparando HP atual com o anterior
		if self.health < self.hp_anterior then                    -- levou dano de verdade
			self.hp_anterior = self.health
			self.passive = false
			self.state = ""
			-- tenta pegar o player mais próximo como alvo
			local pos = self.object:get_pos()
			local jogadores = core.get_connected_players()
			local alvo = nil
			local menor_dist = self.view_range or 10
			for _, p in ipairs(jogadores) do
				local dist = vector.distance(pos, p:get_pos())
				if dist < menor_dist then
					menor_dist = dist
					alvo = p
				end
			end
			if alvo then self:do_attack(alvo) end
		end
		self.hp_anterior = self.health
	end,
})
-- Spawn do karibo
mobs:spawn({ name = "nh_mob:karibo", nodes = { "air" }, neighbors = { "nh_nodes:ice", "nh_nodes:snow" }, max_light = 15, interval = 120, chance = 300, active_object_count = 2, min_height = -10, max_height = 25 })
register_orb_egg("nh_mob:karibo", S("Orb with Karibo"))
-- MOB 3: GALO / rooster (Agressivo)
mobs:register_mob("nh_mob:rooster", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	description = S("Rooster"),
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:cricket", "nh_mob:cicada" },
	-- attack_chance = 100,   -- ataca sempre que detecta
	attack_players = true, -- ataca jogadores
	-- drop com a sintaxe correta
	drops = {
		{ name = "items:feather",        chance = 1, min = 1, max = 5 }, -- 1-5 penas
		{ name = "nh_nodes:raw_chicken", chance = 1, min = 1, max = 1 }, -- 1 galinha crua (sempre)
	},
	hp_min = 4,
	hp_max = 8,
	armor = 100,
	collisionbox = { -0.5, 0, -0.2, 0.3, 0.4, 0.2 }, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
	selectionbox = { -0.5, 0, -0.2, 0.3, 0.4, 0.2 }, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
	physical = true,
	stepheight = 1.1,
	fall_speed = -3,           -- Galinhas caem devagar (batem asas)
	fall_damage = 0,
	floats = 1,                -- Não nadam bem
	visual = "mesh",
	mesh = "rooster.glb",      -- Você precisa criar este modelo
	textures = { "rooster.png" }, -- Você precisa criar esta textura
	-- rotate = 180,
	visual_size = { x = 15, y = 15 },
	walk_velocity = 1,
	run_velocity = 4,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 1, stand_start = 0.25, stand_end = 0.25, walk_start = 0.5, walk_end = 1.5, fly_up_start = 1.65, fly_up_end = 1.85, fly_down_start = 1.75, fly_down_end = 1.75, },
	-- Galinhas podem ser alimentadas e seguir o jogador com sementes
	follow = { "farming:seed_wheat", "nh_nodes:grassleaves", "nh_nodes:grassleavesmedium" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			-- Se o jogador está segurando sementes, a galinha segue
			if name == "farming:seed_wheat" or name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
				core.chat_send_player(clicker:get_player_name(), S("The rooster is interested in the food!"))
			else
				core.chat_send_player(clicker:get_player_name(), S("Cock-a-doodle-doo!"))
			end
		end
	end,
	sounds = { random = "ChickenSound", damage = "ChickenHurt", }, -- Sons da galinha
	do_custom = function(self, dtime)                           -- Sistema de detecção pra voo
		if self.state ~= "attack" then                          -- Busca proativa por players no raio de view_range
			local pos = self.object:get_pos()
			for _, player in ipairs(core.get_connected_players()) do
				if vector.distance(pos, player:get_pos()) <= 8 then
					self.attack = player
					self.state = "attack"
					break
				end
			end
		end
		local vel = self.object:get_velocity()
		if not vel then return end
		if self.state == "attack" or self.state == "runaway" or self.state == "follow" then return end -- Nunca interferir se o mob está atacando ou em comportamento especial
		if vel.y > 0.5 then                                                                      -- Subindo
			if self.state ~= "fly_up" then
				self.state = "fly_up"
				self:set_animation("fly_up")
			end
		elseif vel.y < -0.5 then -- Descendo
			if self.state ~= "fly_down" then
				self.state = "fly_down"
				self:set_animation("fly_down")
			end
		else -- Movimento normal no chão
			if self.state == "fly_up" or self.state == "fly_down" then
				self.state = "walk"
				self:set_animation("walk")
			end
		end
	end,
})
-- Spawn do galo (terra/dirt)
mobs:spawn({
	name = "nh_mob:rooster",
	nodes = { "air" },
	neighbors = { "nh_nodes:dirt", "nh_nodes:grass" }, -- Spawna em dirt e grama
	max_light = 15,
	interval = 120,
	chance = 2000,        -- Spawn frequente
	active_object_count = 2, -- 2 galos
	min_height = -10,
	max_height = 50
})
--mobs:register_egg("nh_mob:galo", "Orbe com Galo", "orbspawner.png", 0)
register_orb_egg("nh_mob:rooster", S("Orb with Rooster"))
-- MOB 3: GALINHA (Passiva/Põe Ovos)
mobs:register_mob("nh_mob:chicken", {
	type = "animal",
	passive = true,
	damage = 0,
	description = S("Chicken"),
	-- Galinhas fogem de jogadores
	runaway = true,
	runaway_from = { "player" },
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:cricket", "nh_mob:cicada" },
	drops = {
		{ name = "items:feather",        chance = 1, min = 1, max = 5 }, -- 1-5 penas
		{ name = "nh_nodes:raw_chicken", chance = 1, min = 1, max = 1 }, -- 1 galinha crua (sempre)
	},
	hp_min = 4,
	hp_max = 8,
	armor = 100,
	collisionbox = { 0, 0, -0.2, 0.3, 0.4, 0.2 }, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
	selectionbox = { 0, 0, -0.2, 0.3, 0.4, 0.2 }, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
	physical = true,
	stepheight = 1.1,
	fall_speed = -3,           -- Galinhas caem devagar (batem asas)
	fall_damage = 0,
	floats = 1,                -- Não nadam bem
	visual = "mesh",
	mesh = "chicken.glb",      -- Você precisa criar este modelo
	textures = { "chicken.png" }, -- Você precisa criar esta textura
	-- rotate = 180,
	visual_size = { x = 15, y = 15 },
	walk_velocity = 1,
	run_velocity = 4,
	view_range = 8,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 1, stand_start = 0.25, stand_end = 0.25, walk_start = 0.5, walk_end = 1.5, fly_up_start = 1.65, fly_up_end = 1.85, fly_down_start = 1.75, fly_down_end = 1.75, },
	-- Galinhas podem ser alimentadas e seguir o jogador com sementes
	follow = { "farming:seed_wheat", "nh_nodes:grassleaves", "nh_nodes:grassleavesmedium" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "farming:seed_wheat" then
				core.chat_send_player(clicker:get_player_name(), S("The chicken is interested in the food!"))
			elseif name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then
				-- Consome 1 unidade do item
				item:take_item(1)
				clicker:set_wielded_item(item)
				local pos = self.object:get_pos()
				core.add_particlespawner({ -- Partículas de coração
					amount = 15,
					time = 1,
					minpos = { x = pos.x - 0.5, y = pos.y, z = pos.z - 0.5 },
					maxpos = { x = pos.x + 0.5, y = pos.y + 1, z = pos.z + 0.5 },
					minvel = { x = -0.5, y = 1, z = -0.5 },
					maxvel = { x = 0.5, y = 2, z = 0.5 },
					minexptime = 0.5,
					maxexptime = 1,
					minsize = 1,
					maxsize = 2,
					texture =
					"heart.png",
				})
				-- Ativa a busca por ovo
				self.seeking_egg = true
				self.seek_timer = 0
				core.chat_send_player(clicker:get_player_name(),
					S("The chicken looks excited and starts looking for an egg!"))
			else
				core.chat_send_player(clicker:get_player_name(), S("Cluck cluck!"))
			end
		end
	end,
	sounds = { random = "ChickenSound", damage = "ChickenHurt", }, -- Sons da galinha
	-- Sistema de ovos
	do_custom = function(self, dtime)
		self.step_timer = (self.step_timer or 0) + dtime
		if self.step_timer < 1 then return end
		self.step_timer = 0
		if self.seeking_egg then -- SISTEMA DE BUSCA POR OVO (ativado ao ser alimentada)
			self.seek_timer = (self.seek_timer or 0) + 1
			-- Timeout: desiste após 60 segundos
			if self.seek_timer > 60 then
				self.seeking_egg = false
				self.seek_timer = 0
			else
				local pos = self.object:get_pos()
				-- Procura o node nh_nodes:chicken_egg num raio de 10 blocos
				local egg_nodes = core.find_nodes_in_area({ x = pos.x - 10, y = pos.y - 2, z = pos.z - 10 },
					{ x = pos.x + 10, y = pos.y + 2, z = pos.z + 10 }, { "nh_nodes:chicken_egg" })
				if #egg_nodes > 0 then -- Pega o ovo mais próximo
					local closest_egg = nil
					local closest_dist = math.huge
					for _, epos in ipairs(egg_nodes) do
						local dist = vector.distance(pos, epos)
						if dist < closest_dist then
							closest_dist = dist
							closest_egg = epos
						end
					end
					if closest_egg then -- Ainda longe: caminha em direção ao ovo
						if closest_dist > 1.5 then
							self.object:set_velocity({
								x = (closest_egg.x - pos.x) / closest_dist * 2,
								y = self.object:get_velocity().y,
								z = (closest_egg.z - pos.z) / closest_dist * 2,
							})
						else
							-- Chegou perto do ovo!
							-- Remove o node de ovo
							core.remove_node(closest_egg)
							-- Spawna o galo no lugar do ovo
							local rooster_pos = { x = closest_egg.x, y = closest_egg.y, z = closest_egg.z, }
							core.add_entity(rooster_pos, "nh_mob:chick")

							core.add_particlespawner({ -- Partículas de coração no spawn do galo
								amount = 15,
								time = 1,
								minpos = { x = rooster_pos.x - 0.5, y = rooster_pos.y, z = rooster_pos.z - 0.5 },
								maxpos = { x = rooster_pos.x + 0.5, y = rooster_pos.y + 1, z = rooster_pos.z + 0.5 },
								minvel = { x = -0.5, y = 1, z = -0.5 },
								maxvel = { x = 0.5, y = 2, z = 0.5 },
								minexptime = 0.5,
								maxexptime = 1,
								minsize = 1,
								maxsize = 2,
								texture =
								"heart.png",
							})
							log("A chicken hatched a chick from an egg at " .. core.pos_to_string(rooster_pos))
							for _, player in ipairs(core.get_connected_players()) do -- Avisa jogadores próximos
								if vector.distance(player:get_pos(), pos) < 15 then
									core.chat_send_player(player:get_player_name(), S("A chick hatched from the egg!"))
								end
							end
							-- Desativa a busca
							self.seeking_egg = false
							self.seek_timer = 0
						end
					end
				end
			end
		end
		-- SISTEMA DE OVOS (código original)
		-- Inicializa tempo aleatório UMA VEZ
		if not self.next_egg_time then
			self.next_egg_time = math.random(120, 240) -- 2 a 4 min
			self.egg_timer = 0
		end
		self.egg_timer = self.egg_timer + 1    -- Contador de ovos
		if self.egg_timer >= self.next_egg_time then -- Hora de botar ovo
			local pos = self.object:get_pos()
			local yaw = self.object:get_yaw()
			local back_dir = { x = -math.sin(yaw), y = 0, z = math.cos(yaw) } -- Direção para trás da galinha
			local egg_pos = vector.add(pos, vector.multiply(back_dir, 0.8))
			egg_pos.y = egg_pos.y + 0.1
			core.add_item(egg_pos, "nh_nodes:chicken_egg")
			log("A chicken laid an egg in " .. core.pos_to_string(egg_pos))
			for _, player in ipairs(core.get_connected_players()) do -- Avisar jogadores próximos
				if vector.distance(player:get_pos(), pos) < 10 then
					core.chat_send_player(player:get_player_name(), S("A chicken laid an egg!"))
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
		elseif vel.y < -0.5 then -- Descendo
			if self.state ~= "fly_down" then
				self.state = "fly_down"
				self:set_animation("fly_down")
			end
		else -- Movimento normal
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
	nodes = { "air" },
	neighbors = { "nh_nodes:dirt", "nh_nodes:grass" }, -- Spawna em dirt e grama
	max_light = 15,
	interval = 120,
	chance = 2000,        -- Spawn frequente
	active_object_count = 5, -- 5 galinhas
	min_height = -10,
	max_height = 50
})
-- mobs:register_egg("nh_mob:galinha", "Orbe com Galinha", "orbspawner.png", 0)
register_orb_egg("nh_mob:chicken", S("Orb with Chicken"))

mobs:register_mob("nh_mob:chick", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Chick"),
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:cricket", "nh_mob:cicada" },
	hp_min = 2,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 }, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
	selectionbox = { -0.1, 0, -0.1, 0.1, 0.1, 0.1 }, -- X (frente), y (em baixo), z (lateral) / x (traz), y (cima), z (lateral)
	physical = true,
	stepheight = 1.1,
	fall_speed = -3,         -- Galinhas caem devagar (batem asas)
	fall_damage = 0,
	floats = 1,              -- Não nadam bem
	visual = "mesh",
	mesh = "chick.glb",      -- Você precisa criar este modelo
	textures = { "chick.png" }, -- Você precisa criar esta textura
	-- rotate = 180,
	visual_size = { x = 7, y = 7 },
	walk_velocity = 0.5,
	run_velocity = 2,
	view_range = 5,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = { speed_normal = 1, stand_start = 0.0, stand_end = 0.5, walk_start = 0.5, walk_end = 1.5, fly_up_start = 1.65, fly_up_end = 1.85, fly_down_start = 1.75, fly_down_end = 1.75, },
	-- Galinhas podem ser alimentadas e seguir o jogador com sementes
	follow = { "farming:seed_wheat", "nh_nodes:grassleaves", "nh_nodes:grassleavesmedium" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "farming:seed_wheat" or name == "nh_nodes:grassleaves" or name == "nh_nodes:grassleavesmedium" then -- Se o jogador está segurando sementes, a galinha segue
				core.chat_send_player(clicker:get_player_name(), S("The chick is interested in the food!"))
			else
				core.chat_send_player(clicker:get_player_name(), S("Peep, peep!"))
			end
		end
	end,
	sounds = { random = "ChickSound", damage = "ChickHurt", }, -- Sons da galinha
	-- Sistema de ovos
	do_custom = function(self, dtime)
		local vel = self.object:get_velocity()
		if not vel then return end
		if vel.y > 0.5 then -- Subindo
			if self.state ~= "fly_up" then
				self.state = "fly_up"
				self:set_animation("fly_up")
			end
		elseif vel.y < -0.5 then -- Descendo
			if self.state ~= "fly_down" then
				self.state = "fly_down"
				self:set_animation("fly_down")
			end
		else -- Movimento normal
			if self.state ~= "walk" then
				self.state = "walk"
				self:set_animation("walk")
			end
		end
	end,
})
--mobs:register_egg("nh_mob:galo", "Orbe com Galo", "orbspawner.png", 0)
register_orb_egg("nh_mob:chick", S("Orb with Chick"))
-- MOB 4: TUBARÃO (Agressivo)
mobs:register_mob("nh_mob:shark", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 5,
	attack_type = "dogfight",
	description = S("Shark"),
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:chicken", "nh_mob:rooster", "nh_mob:rabbit", "nh_mob:bull", "nh_mob:hedgehog" },
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = { -1.25, 0, -0.2, 1.3, 0.4, 0.2 },
	selectionbox = { -1.5, 0, -0.2, 1.5, 0.4, 0.2 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "shark.obj",
	textures = { "shark.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 },
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,             -- Permite "voar" na água
	fly_in = "nh_nodes:water", -- Só "voa" dentro de nodes:water
	walk_velocity = 1,
	run_velocity = 4,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 2, -- CRÍTICO: Recebe dano fora da água!
	animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	follow = { "nh_nodes:raw_chicken" },
	-- ADICIONE: Função para forçar o tubarão a voltar para água
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		local node = core.get_node(pos)
		if node.name ~= "nh_nodes:water" then -- Se não está na água, tenta voltar
			-- Procura por água próxima
			local water_pos = core.find_node_near(pos, 5, { "nh_nodes:water" })
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
	sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
})
-- Spawn do tubarão (somente na água)
mobs:spawn({
	name = "nh_mob:shark",
	nodes = { "nh_nodes:water" }, -- Spawna DENTRO da água
	neighbors = { "nh_nodes:wet_sand" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 2,
	min_height = -20,
	max_height = -12 -- Não spawna acima do nível do mar
})
--mobs:register_egg("nh_mob:shark", "Orbe com Tubarão", "orbspawner.png", 0)
register_orb_egg("nh_mob:shark", S("Orb with Shark"))
-- "MOB" item: Mensagem na garrafa
mobs:register_mob("nh_mob:messagebottle", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Message Bottle") .. "\n" .. S("[Item]"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	hp_min = 1,
	hp_max = 1,
	armor = 100,
	collisionbox = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 },
	selectionbox = { -0.18, -0.5, -0.18, 0.18, -0.05, 0.18 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 0,
	floats = 4,
	pushable = true,
	visual = "mesh",
	mesh = "bottlepage.obj",
	textures = { "bottlepagetexture.png" },
	rotate = 180,
	visual_size = { x = 15, y = 15 },
	-- IMPORTANTE: Propriedades para manter na água
	fly = false, -- Permite "voar" na água
	-- fly_in = "nh_nodes:water", -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 1,
	run_velocity = 1,
	view_range = 1,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0, -- CRÍTICO: Recebe dano fora da água!
	-- animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	-- follow = {"nh_nodes:raw_chicken"},
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
				core.chat_send_player(clicker:get_player_name(),
					S("Message bottle. I need to empty my hand to pick it up."))
			end
		end
	end,
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
	drops = {}, -- deixa vazio
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
	nodes = { "air", "nh_nodes:water" }, -- Spawna sobre a agua
	neighbors = { "nh_nodes:water" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = -1,
	max_height = 1 -- spawna no nível do mar
})
--mobs:register_egg("nh_mob:messagebottle", "Garrafa com Mensagem", "bottle.png", 0)
-- "MOB" item: coco
mobs:register_mob("nh_mob:coconut", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Floating Coconut"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	hp_min = 1,
	hp_max = 1,
	armor = 100,
	collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "coconut.obj",
	textures = { "CocoTexture.png" },
	rotate = 180,
	visual_size = { x = 10, y = 10 },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ use_texture_alpha = true, }) end,
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = false,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 0.2,
	run_velocity = 0.2,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0, -- CRÍTICO: Recebe dano fora da água!
	-- animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	-- follow = {"nh_nodes:raw_chicken"},
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
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
	drops = { { name = "nh_nodes:coconut", chance = 1, min = 1, max = 1 }, -- 1-1 gelo
	},
})
-- Spawn do iceberg (somente na água)
mobs:spawn({
	name = "nh_mob:coconut",
	nodes = { "air", "nh_nodes:water" }, -- Spawna DENTRO da água
	neighbors = { "nh_nodes:water" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 2,
	min_height = -1,
	max_height = 1 -- spawna no nível do mar
})
-- "MOB" item: iceberg
mobs:register_mob("nh_mob:iceberg", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	description = S("Floating Ice") .. "\n" .. S("[Platform]"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	hp_min = 1,
	hp_max = 1,
	armor = 100,
	collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "iceberg.obj",
	textures = { "ice.png" },
	rotate = 180,
	visual_size = { x = 10, y = 10 },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ use_texture_alpha = true, }) end,
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = false,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 1,
	run_velocity = 1,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0, -- CRÍTICO: Recebe dano fora da água!
	-- animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	-- follow = {"nh_nodes:raw_chicken"},
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then -- Remove uma garrafa do inventário
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
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
	drops = { { name = "nh_nodes:ice", chance = 1, min = 1, max = 1 }, -- 1-1 gelo
	},
})
-- Spawn do iceberg (somente na água)
mobs:spawn({
	name = "nh_mob:iceberg",
	nodes = { "air", "nh_nodes:water" }, -- Spawna DENTRO da água
	neighbors = { "nh_nodes:ice" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 5,
	min_height = -1,
	max_height = 1 -- spawna no nível do mar
})
--mobs:register_egg("nh_mob:iceberg", "Iceberg", "ice.png", 0)
-- "MOB" item: iceberg
mobs:register_mob("nh_mob:iceberg2", {
	type = "animal",
	passive = true,
	reach = 1,
	damage = 0,
	attack_type = "dogfight",
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 8,               -- quantidade de partículas
	description = S("Iceberg") .. "\n" .. S("[Platform]"),
	hp_min = 8,
	hp_max = 10,
	armor = 100,
	collisionbox = { -1, -1, -1, 1, 0.5, 1 },
	selectionbox = { -1.25, -2, -1.25, 1.25, 1, 1.25 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 0,
	floats = 1,
	visual = "mesh",
	mesh = "iceberg2.obj",
	textures = { "ice3.png" },
	rotate = 180,
	visual_size = { x = 10, y = 10 },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ use_texture_alpha = true, }) end,
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = false,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water", -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 0.5,
	run_velocity = 0.5,
	view_range = 16,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0, -- CRÍTICO: Recebe dano fora da água!
	-- animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	--follow = {"nh_nodes:raw_chicken"},
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then -- Remove uma garrafa do inventário
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
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
	drops = { { name = "nh_nodes:ice", chance = 1, min = 3, max = 5 }, -- 1-1 gelo
		{ name = "nh_nodes:snow", chance = 1, min = 3, max = 5 },   -- 1-1 gelo
	},
})
-- Spawn do iceberg (somente na água)
mobs:spawn({
	name = "nh_mob:iceberg2",
	nodes = { "nh_nodes:water" }, -- Spawna DENTRO da água
	neighbors = { "nh_nodes:ice" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 5,
	min_height = -1,
	max_height = 1 -- spawna no nível do mar
})
mobs:register_egg("nh_mob:iceberg2", "Iceberg", "ice.png", 0)
-- "MOB" item: piao
mobs:register_mob("nh_mob:spinningtop", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	description = S("Oak Spinning Top") .. "\n" .. S("[Item]"),
	blood_texture = "spark_particle.png^[colorize:#000000:200", -- sua textura customizada
	blood_amount = 8,                                        -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 1,
	floats = 1,
	visual = "mesh",
	mesh = "piao.glb",
	textures = { "oakpiao.png" },
	-- rotate = 180,
	visual_size = { x = 10, y = 10 },
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = false,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 1,
	run_velocity = 1,
	view_range = 16,
	water_damage = 1, -- CRÍTICO: Recebe dano na água!
	lava_damage = 1,
	light_damage = 0,
	air_damage = 0,
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0.25, walk_start = 0.25, walk_end = 1.5, },
	-- follow = {"nh_nodes:raw_chicken"},
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:spinningtop2", "nh_mob:spinningtop3" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then -- Remove uma garrafa do inventário
				item:take_item()
				clicker:set_wielded_item(item)
				-- Adiciona fireflybottle ao inventário
				local inv = clicker:get_inventory()
				inv:add_item("main", ItemStack("nh_nodes:spinningtop"))
				self.object:remove() -- Remove a garrafa
			elseif name == "nh_nodes:spinningtop" then
				core.chat_send_player(clicker:get_player_name(), S("Teck! I need to empty my hand to pick it up."))
			else
				core.chat_send_player(clicker:get_player_name(), S("Spinning... I need to empty my hand to pick it up."))
			end
		end
	end,
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
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
			local below = { x = pos.x, y = math.floor(pos.y), z = pos.z }
			local node = core.get_node(below)
			if not allowed_nodes[node.name] then -- Só manda a mensagem na PRIMEIRA vez que entra no bloco errado
				if not self._on_bad_floor then
					self._on_bad_floor = true
					core.chat_send_all(
						S("Inappropriate surface. The palm spinning top is losing rotation due to friction..."))
				end
				-- Rastreia HP manualmente sem depender do punch
				self._tracked_hp = (self._tracked_hp or self.object:get_hp()) - 1
				self.object:punch(self.object, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 1 } }, nil)
				-- local hp = self.object:get_hp()
				core.chat_send_all(S("Oak spinning top damage! HP: ") .. self._tracked_hp)
			else -- Resetar quando voltar para bloco permitido
				self._on_bad_floor = false
			end
		end
	end,
	-- on_die = function(self, pos)
	--     -- Dropa o item na posição onde morreu
	--     core.add_item(pos, ItemStack("nh_nodes:spinningtop"))
	-- end,
	drops = { { name = "nh_nodes:spinningtop", chance = 1, min = 1, max = 1 }, -- 1-1 gelo
	},

})
--mobs:register_egg("nh_mob:spinningtop", "Pião de Carvalho", "oakpiaoinv.png", 0)
-- "MOB" item: piao
mobs:register_mob("nh_mob:spinningtop2", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	description = S("Palm Spinning Top") .. "\n" .. S("[Item]"),
	blood_texture = "spark_particle.png^[colorize:#000000:200", -- sua textura customizada
	blood_amount = 8,                                        -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 1,
	floats = 1,
	visual = "mesh",
	mesh = "piao.glb",
	textures = { "palmpiao.png" },
	-- rotate = 180,
	visual_size = { x = 10, y = 10 },
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = false,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 1,
	run_velocity = 1,
	view_range = 16,
	water_damage = 1, -- CRÍTICO: Recebe dano na água!
	lava_damage = 1,
	light_damage = 0,
	air_damage = 0,
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0.25, walk_start = 0.25, walk_end = 1.5, },
	--follow = {"nh_nodes:raw_chicken"},
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:spinningtop", "nh_mob:spinningtop3" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then -- Remove uma garrafa do inventário
				item:take_item()
				clicker:set_wielded_item(item)
				-- Adiciona fireflybottle ao inventário
				local inv = clicker:get_inventory()
				inv:add_item("main", ItemStack("nh_nodes:spinningtop2"))
				self.object:remove() -- Remove a garrafa
			elseif name == "nh_nodes:spinningtop2" then
				core.chat_send_player(clicker:get_player_name(), S("Teck! I need to empty my hand to pick it up."))
			else
				core.chat_send_player(clicker:get_player_name(), S("Spinning... I need to empty my hand to pick it up."))
			end
		end
	end,
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
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
			local below = { x = pos.x, y = math.floor(pos.y), z = pos.z }
			local node = core.get_node(below)
			if not allowed_nodes[node.name] then
				-- Só manda a mensagem na PRIMEIRA vez que entra no bloco errado
				if not self._on_bad_floor then
					self._on_bad_floor = true
					core.chat_send_all(
						S("Inappropriate surface. The palm spinning top is losing rotation due to friction..."))
				end
				-- Rastreia HP manualmente sem depender do punch
				self._tracked_hp = (self._tracked_hp or self.object:get_hp()) - 1
				self.object:punch(self.object, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 1 } }, nil)
				-- local hp = self.object:get_hp()
				core.chat_send_all(S("Palm spinning top damage! HP: ") .. self._tracked_hp)
			else -- Resetar quando voltar para bloco permitido
				self._on_bad_floor = false
			end
		end
	end,

	drops = { { name = "nh_nodes:spinningtop2", chance = 1, min = 1, max = 1 }, -- 1-1 gelo
	},

})
-- Spawn do piao
-- mobs:spawn({
--     name = "nh_mob:iceberg",
--     nodes = { "nh_nodes:water" }, -- Spawna DENTRO da água
--     neighbors = { "nh_nodes:ice" },
--     max_light = 15,
--     interval = 120,
--     chance = 2000,
--     active_object_count = 1,
--     min_height = 0,
--     max_height = -1 -- spawna no nível do mar
-- })
--mobs:register_egg("nh_mob:spinningtop2", "Pião de Coqueiro", "palmpiaoinv.png", 0)
-- "MOB" item: piao
mobs:register_mob("nh_mob:spinningtop3", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	description = S("Pine Spinning Top") .. "\n" .. S("[Item]"),
	blood_texture = "spark_particle.png^[colorize:#000000:200", -- sua textura customizada
	blood_amount = 8,                                        -- quantidade de partículas
	hp_min = 1,
	hp_max = 3,
	armor = 100,
	collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	selectionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	physical = true,
	stepheight = 0, -- NÃO consegue subir degraus (importante!)
	fall_speed = -6,
	fall_damage = 1,
	floats = 1,
	visual = "mesh",
	mesh = "piao.glb",
	textures = { "pinepiao.png" },
	-- rotate = 180,
	visual_size = { x = 10, y = 10 },
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = false,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Só "voa" dentro de nodes:water
	-- walk_chance = 0,
	walk_velocity = 1,
	run_velocity = 1,
	view_range = 16,
	water_damage = 1, -- CRÍTICO: Recebe dano na água!
	lava_damage = 1,
	light_damage = 0,
	air_damage = 0,
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0.25, walk_start = 0.25, walk_end = 1.5, },
	-- follow = {"nh_nodes:raw_chicken"},
	-- lista de mobs que ele vai atacar ativamente
	attack_animals = true, -- permite atacar outros mobs
	specific_attack = { "nh_mob:spinningtop", "nh_mob:spinningtop2" },
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then -- Remove uma garrafa do inventário
				item:take_item()
				clicker:set_wielded_item(item)
				-- Adiciona fireflybottle ao inventário
				local inv = clicker:get_inventory()
				inv:add_item("main", ItemStack("nh_nodes:spinningtop3"))
				self.object:remove() -- Remove a garrafa
			elseif name == "nh_nodes:spinningtop3" then
				core.chat_send_player(clicker:get_player_name(), S("Teck! I need to empty my hand to pick it up."))
			else
				core.chat_send_player(clicker:get_player_name(), S("Spinning... I need to empty my hand to pick it up."))
			end
		end
	end,
	-- sounds = { random = "tubarao_som", damage = "tubarao_hurt", },
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
			local below = { x = pos.x, y = math.floor(pos.y), z = pos.z }
			local node = core.get_node(below)
			if not allowed_nodes[node.name] then
				-- Só manda a mensagem na PRIMEIRA vez que entra no bloco errado
				if not self._on_bad_floor then
					self._on_bad_floor = true
					core.chat_send_all(
						S("Inappropriate surface. The pine spinning top is losing rotation due to friction..."))
				end
				-- Rastreia HP manualmente sem depender do punch
				self._tracked_hp = (self._tracked_hp or self.object:get_hp()) - 1
				self.object:set_hp(hp - 1)
				-- self.object:punch(self.object, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 1 } }, nil)
				--local hp = self.object:get_hp()
				core.chat_send_all(S("Pine spinning top damage! HP: ") .. self._tracked_hp)
			else -- Resetar quando voltar para bloco permitido
				self._on_bad_floor = false
			end
		end
	end,
	drops = { { name = "nh_nodes:spinningtop3", chance = 1, min = 1, max = 1 }, -- 1-1 gelo
	},
})
--mobs:register_egg("nh_mob:spinningtop3", "Pião de Pinheiro", "pinepiaoinv.png", 0)
-- MOB 1: polvo (Defensivo)
mobs:register_mob("nh_mob:octopus", {
	type = "animal",
	passive = true, -- Pode se defender quando atacado
	damage = 3,
	reach = 1,
	description = S("Dark Octopus") .. "\n" .. S("[Altered Animal]"),
	blood_texture = "mob_blueblood.png", -- sua textura customizada
	blood_amount = 5,                 -- quantidade de partículas
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = { -0.3, 0, -0.25, 0.25, 0.4, 0.25 },
	physical = true,
	stepheight = 3.1,
	fall_speed = -8,
	fall_damage = 2,
	visual = "mesh",
	mesh = "octopus.glb",
	textures = { "octopus.png" },
	-- rotate = 180,
	visual_size = { x = 15, y = 15 },
	drops = { { name = "nh_nodes:inksac", chance = 1, min = 1, max = 1 }, -- bolsa de tinta
	},
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,             -- Permite "voar" na água
	fly_in = "nh_nodes:water", -- Voa na agua
	-- lista de mobs que ele vai atacar ativamente
	-- attack_animals = true,        -- permite atacar outros mobs
	-- specific_attack = {"nh_mob:cricket", "nh_mob:cicada",  "nh_mob:ladybug"},
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
register_orb_egg("nh_mob:octopus", S("Orb with Dark Octopus"))
-- MOB 4: Polvo esqueleto (Agressivo)
mobs:register_mob("nh_mob:exoskull", {
	type = "monster",
	passive = false,
	reach = 2,
	damage = 5,
	attack_type = "dogfight",
	--attack_chance = 8, -- entre 1-10
	description = S("Exhausted") .. "\n" .. S("[Altered Animal]"),
	blood_texture = "mob_blueblood.png", -- sua textura customizada
	blood_amount = 5,                 -- quantidade de partículas
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = { -0.25, 0, -0.2, 0.3, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.5, 2.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -10,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "octopusskull.glb",
	textures = { "octopusskull.png" },
	-- rotate = 180,
	visual_size = { x = 2, y = 2 },                                  -- visual_size = {x = 2.1, y = 2.1},
	drops = {
		{ name = "nh_nodes:bone",          chance = 1, min = 2, max = 6 }, -- ossos
		{ name = "nh_nodes:rustironsword", chance = 1, min = 0, max = 1 }, -- espada
	},
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = true,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Voa no ar
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
		punch_start = 11.54, -- Frame inicial do ataque
		punch_end = 16, -- Frame final do ataque
		-- punch_speed = 20, -- vel 1-30
	},

	follow = { "nh_nodes:torch2" },
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
	sounds = { random = "vulto_som", damage = "vulto_hurt", },
	custom_attack = function(self, to_attack)
		self.attack_count = (self.attack_count or 0) + 1
		if self.attack_count < 3 then return end
		self.attack_count = 0
		self:set_animation("punch", false)
		return true -- PARA CONTINUAR.
	end,
	on_die = function(self, pos)
		core.after(0.1, function() core.add_entity(pos, "nh_mob:octopus") end)
		-- Opcional: deixa o novo mob já em modo de ataque
		-- if obj then obj:get_luaentity().state = "attack" end
	end,
})
-- Spawn do vulto (fundo de cavernas escuras)
mobs:spawn({
	name = "nh_mob:octoskull",
	nodes = { "nh_nodes:water" },    -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:oakwood" }, --neighbors = {"nh_nodes:wet_sand"},
	max_light = 10,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = -50,
	max_height = 3
})
--mobs:register_egg("nh_mob:octoskull", "Orbe com Exopolvo", "orbspawner.png", 0)
register_orb_egg("nh_mob:exoskull", S("Orb with Exhausted"))
-- MOB 4: Sereia / sirenia /mermaid (Agressivo)
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
	collisionbox = { -0.25, 0, -0.2, 0.3, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.5, 2.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "sirenia.glb",
	textures = { "sirenia.png" },
	-- rotate = 180,
	visual_size = { x = 2, y = 2 }, -- visual_size = {x = 2.1, y = 2.1},
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,                  -- Permite "voar" na água
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
		punch_start = 11.54, -- Frame inicial do ataque
		punch_end = 16, -- Frame final do ataque
		-- punch_speed = 20, -- vel 1-30
	},
	follow = { "nh_nodes:torch2" },
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
	sounds = { random = "vulto_som", damage = "vulto_hurt", },
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
	nodes = { "air", "nh_nodes:water" }, -- nh_nodes = {"nh_nodes:water"},
	neighbors = { "nh_nodes:ice" },   --neighbors = {"nh_nodes:obsidian"},
	max_light = 10,
	interval = 120,
	chance = 2000,
	active_object_count = 1,
	min_height = -20,
	max_height = 1 -- -10
})
--mobs:register_egg("nh_mob:sirenia", "Orbe com Sirenia", "orbspawner.png", 0)
register_orb_egg("nh_mob:sirenia", S("Orb with Sirenia"))
-- MOB 4: PLANARIA SLIME (Agressivo)
mobs:register_mob("nh_mob:slime", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	description = S("Limu") .. "\n" .. S("[Altered Animal]"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 5,               -- quantidade de partículas
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = { -0.2, 0, -0.2, 0.2, 0.4, 0.2 },
	selectionbox = { -0.2, 0, -0.2, 0.2, 0.4, 0.2 },
	physical = true,
	stepheight = 3, -- Consegue subir no player (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "planslime.glb",            --mesh = "planaria_slime_small2.obj",
	textures = { "planaria_slime2.png" }, --^[opacity:200 --{{"planaria_slime3.png","planaria_slime3.png"}}
	--rotate = 180,
	visual_size = { x = 10, y = 10 },
	-- BRILHO NOS OLHOS
	glow = 5, -- Intensidade de 0 a 14 (14 = mais brilhante)
	after_activate = function(self, staticdata, def, dtime)
		self.object:set_properties({ use_texture_alpha = true, textures = { "planaria_slime2.png", "planaria_slime2.png", }, })
		-- Procura jogador próximo e já começa a atacar
		local pos = self.object:get_pos()
		local nearest_player = nil
		local nearest_dist = self.view_range or 7
		for _, player in ipairs(core.get_connected_players()) do
			local dist = vector.distance(pos, player:get_pos())
			if dist < nearest_dist then
				nearest_dist = dist
				nearest_player = player
			end
		end
		if nearest_player then
			core.after(0.4, function()
				if self.object and self.object:is_valid() then
					self.object:punch(nearest_player, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 1 }, },
						nil)
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
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0, walk_start = 0, walk_end = 0.63, },
	follow = { "nh_nodes:raw_chicken" },
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
	sounds = { random = "slime_som", damage = "slime_hurt", },
})
-- Spawn da slime (cavernas)
mobs:spawn({
	name = "nh_mob:slime",
	nodes = { "air" },
	neighbors = { "nh_nodes:gneiss", "nh_nodes:water2" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 4,
	min_height = -15,
	max_height = -5
})
--mobs:register_egg("nh_mob:slime", "Orbe com Limu Pequeno", "orbspawner.png", 0)
register_orb_egg("nh_mob:slime", S("Orb with Small Limu"))
-- MOB 4: PLANARIA SLIME2 (Agressivo)
mobs:register_mob("nh_mob:slime2", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 3,
	attack_type = "dogfight",
	description = S("Medium Limu") .. "\n" .. S("[Altered Animal]"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 5,               -- quantidade de partículas
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	on_die = function(self, pos)
		core.after(0.1, function() -- Spawna 6 slime normal
			core.add_entity(pos, "nh_mob:slime")
			core.add_entity(pos, "nh_mob:slime")
			core.add_entity(pos, "nh_mob:slime")
			core.add_entity(pos, "nh_mob:slime")
			core.add_entity(pos, "nh_mob:slime")
			core.add_entity(pos, "nh_mob:slime")
		end)
	end,
	collisionbox = { -0.35, 0, -0.35, 0.35, 0.7, 0.35 },
	selectionbox = { -0.35, 0, -0.35, 0.35, 0.7, 0.35 },
	physical = true,
	stepheight = 4, -- Consegue subir no player (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "planslime.glb",            --mesh = "planaria_slime_small2.obj",
	textures = { "planaria_slime2.png" }, --^[opacity:200 --{{"planaria_slime3.png","planaria_slime3.png"}}
	--rotate = 180,
	visual_size = { x = 20, y = 20 },
	-- BRILHO NOS OLHOS
	glow = 5, -- Intensidade de 0 a 14 (14 = mais brilhante)
	-- TRANSPARENCIA
	-- use_texture_alpha = "blend",  -- Tente "blend" em vez de true -> use_texture_alpha = true,  -- Habilita transparência
	-- backface_culling = true,   -- Renderiza ambos os lados das faces
	after_activate = function(self, staticdata, def, dtime)
		self.object:set_properties({ use_texture_alpha = true, textures = { "planaria_slime2.png", "planaria_slime2.png", }, })
		-- Procura jogador próximo e já começa a atacar
		local pos = self.object:get_pos()
		local nearest_player = nil
		local nearest_dist = self.view_range or 7
		for _, player in ipairs(core.get_connected_players()) do
			local dist = vector.distance(pos, player:get_pos())
			if dist < nearest_dist then
				nearest_dist = dist
				nearest_player = player
			end
		end
		if nearest_player then
			core.after(0.4,
				function()
					if self.object and self.object:is_valid() then
						self.object:punch(nearest_player, 1.0,
							{ full_punch_interval = 1.0, damage_groups = { fleshy = 1 }, }, nil)
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
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0, walk_start = 0, walk_end = 0.63, },
	follow = { "nh_nodes:raw_chicken" },
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
	sounds = { random = "slime_som", damage = "slime_hurt", },
})
-- Spawn da slime (cavernas)
mobs:spawn({
	name = "nh_mob:slime2",
	nodes = { "air" },
	neighbors = { "nh_nodes:gneiss", "nh_nodes:water2" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 4,
	min_height = -15,
	max_height = -5
})
--mobs:register_egg("nh_mob:slime2", "Orbe com Limu Médio", "orbspawner.png", 0)
register_orb_egg("nh_mob:slime2", S("Orb with Medium Limu"))
-- MOB 4: PLANARIA SLIME3 (Agressivo)
mobs:register_mob("nh_mob:slime3", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 3,
	attack_type = "dogfight",
	description = S("Large Limu") .. "\n" .. S("[Altered Animal]"),
	blood_texture = "mob_droplet.png", -- sua textura customizada
	blood_amount = 5,               -- quantidade de partículas
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	on_die = function(self, pos)
		core.after(0.1, function()
			-- Spawna 4 slime2
			core.add_entity(pos, "nh_mob:slime2")
			core.add_entity(pos, "nh_mob:slime2")
			core.add_entity(pos, "nh_mob:slime2")
			core.add_entity(pos, "nh_mob:slime2")
			-- Spawna 2 slime normal
			core.add_entity(pos, "nh_mob:slime")
			core.add_entity(pos, "nh_mob:slime")
		end)
	end,
	collisionbox = { -0.625, 0, -0.625, 0.625, 1.25, 0.625 },
	selectionbox = { -0.625, 0, -0.625, 0.625, 1.25, 0.625 },
	physical = true,
	stepheight = 4, -- Consegue subir no player (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "planslime.glb",            --mesh = "planaria_slime_small2.obj",
	textures = { "planaria_slime2.png" }, --^[opacity:200 --{{"planaria_slime3.png","planaria_slime3.png"}}
	-- rotate = 180,
	visual_size = { x = 40, y = 40 },
	-- BRILHO NOS OLHOS
	glow = 5, -- Intensidade de 0 a 14 (14 = mais brilhante)
	-- TRANSPARENCIA
	-- use_texture_alpha = "blend",  -- Tente "blend" em vez de true -> use_texture_alpha = true,  -- Habilita transparência
	-- backface_culling = true,   -- Renderiza ambos os lados das faces
	after_activate = function(self, staticdata, def, dtime)
		self.object:set_properties({ use_texture_alpha = true, textures = { "planaria_slime2.png", "planaria_slime2.png", }, })
		-- Procura jogador próximo e já começa a atacar
		local pos = self.object:get_pos()
		local nearest_player = nil
		local nearest_dist = self.view_range or 7
		for _, player in ipairs(core.get_connected_players()) do
			local dist = vector.distance(pos, player:get_pos())
			if dist < nearest_dist then
				nearest_dist = dist
				nearest_player = player
			end
		end
		if nearest_player then
			core.after(0.2,
				function()
					if self.object and self.object:is_valid() then
						self.object:punch(nearest_player, 1.0,
							{ full_punch_interval = 1.0, damage_groups = { fleshy = 1 }, }, nil)
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
	animation = { speed_normal = 1, stand_start = 0, stand_end = 0, walk_start = 0, walk_end = 0.63, },
	follow = { "nh_nodes:raw_chicken" },
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
	sounds = { random = "slime_som", damage = "slime_hurt", },
})
-- Spawn da slime (cavernas)
mobs:spawn({
	name = "nh_mob:slime3",
	nodes = { "air" },
	neighbors = { "nh_nodes:gneiss", "nh_nodes:water2" },
	max_light = 15,
	interval = 120,
	chance = 2000,
	active_object_count = 4,
	min_height = -20,
	max_height = -10
})
-- mobs:register_egg("nh_mob:slime3", "Orbe com Limu Grande", "orbspawner.png", 0)
register_orb_egg("nh_mob:slime3", S("Orb with Large Limu"))
-- MOB 4: VULTO / VISAGE (Agressivo)
mobs:register_mob("nh_mob:visage", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 5,
	attack_type = "dogfight",
	description = S("Visage") .. "\n" .. S("[Phenomenon]"),
	blood_texture = "spark_particle.png^[colorize:#000000:250", -- sua textura customizada
	blood_amount = 5,                                        -- quantidade de partículas
	hp_min = 1,
	hp_max = 1,
	armor = 100,
	collisionbox = { -0.25, -2, -0.2, 0.3, 0.4, 0.2 },
	selectionbox = { -0.5, -2, -0.2, 0.5, 0.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "vulto.obj",
	textures = { "vulto3.png" }, --vulto.png^[opacity:200
	rotate = 180,
	visual_size = { x = 2, y = 2 },
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,  -- Permite "voar" na água
	fly_in = "air", -- Voa no ar
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
	follow = { "nh_nodes:torch2" },
	on_die = function(self, pos) core.after(0.1, function() local obj = core.add_entity(pos, "nh_mob:visage2") end) end,
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
	sounds = { random = "vulto_som", damage = "vulto_hurt", },
})
-- Spawn do vulto (fundo de cavernas escuras)
mobs:spawn({
	name = "nh_mob:visage",
	nodes = { "air" },
	neighbors = { "nh_nodes:gneiss", "nh_nodes:water" },
	max_light = 1,
	interval = 120,
	chance = 2000,
	active_object_count = 2,
	min_height = -50,
	max_height = -20
})
-- mobs:register_egg("nh_mob:visage", "Orbe com Vulto", "orbspawner.png", 0)
register_orb_egg("nh_mob:visage", S("Orb with Visage"))
-- MOB 4: VULTO / VISAGE (Agressivo)
mobs:register_mob("nh_mob:visage2", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 5,
	attack_type = "dogfight",
	description = S("Visage") .. "\n" .. S("[Phenomenon]"),
	blood_texture = "spark_particle.png^[colorize:#000000:250", -- sua textura customizada
	blood_amount = 5,                                        -- quantidade de partículas
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = { -0.25, -2, -0.2, 0.3, 0.4, 0.2 },
	selectionbox = { -0.5, -2, -0.2, 0.5, 0.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -4,
	fall_damage = 0,
	floats = 3,
	visual = "mesh",
	mesh = "vulto.obj",
	textures = { "vulto2.png" }, --vulto.png^[opacity:200
	rotate = 180,
	visual_size = { x = 2, y = 2 },
	-- BRILHO NOS OLHOS
	glow = 14, -- Intensidade de 0 a 14 (14 = mais brilhante)
	after_activate = function(self, staticdata, def, dtime)
		self.object:set_properties({ use_texture_alpha = true, textures = { "vulto2.png" }, })
		-- Procura o jogador mais próximo e simula um soco dele no mob
		local pos = self.object:get_pos()
		local nearest_player = nil
		local nearest_dist = 20 -- só considera jogadores em até 20 blocos
		for _, player in ipairs(core.get_connected_players()) do
			local dist = vector.distance(pos, player:get_pos())
			if dist < nearest_dist then
				nearest_dist = dist
				nearest_player = player
			end
		end
		if nearest_player then -- Pequeno delay para o mob terminar de spawnar antes do punch
			core.after(0.2,
				function()
					if self.object:is_valid() then
						self.object:punch(nearest_player, 1.0,
							{ full_punch_interval = 1.0, damage_groups = { fleshy = 1 }, -- 1 de dano simbólico
							}, nil)
					end
				end)
		end
	end,
	-- IMPORTANTE: Propriedades para manter na água
	fly = true,  -- Permite "voar" na água
	fly_in = "air", -- Voa no ar
	walk_velocity = 1,
	run_velocity = 4,
	view_range = 16,
	water_damage = 2,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	animation = { speed_normal = 15, stand_start = 0, stand_end = 20, walk_start = 21, walk_end = 40, },
	follow = { "nh_nodes:torch2" },
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
	sounds = { random = "vulto_som", damage = "vulto_hurt", },
})
-- MOB 4: Dopel (Agressivo)
mobs:register_mob("nh_mob:dopel", {
	type = "monster",
	passive = false,
	reach = 1.75,
	damage = 5,
	-- attack_players = true,
	attack_type = "dogfight",
	description = S("Dopel") .. "\n" .. S("[?]"),
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = { -0.2, 0, -0.2, 0.2, 2.4, 0.2 },
	selectionbox = { -0.5, 0, -0.2, 0.5, 2.4, 0.2 },
	physical = true,
	stepheight = 2, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -10,
	fall_damage = 0,
	floats = 3,
	--pathfinding = true, -- se move em zig-zag
	static_save = true,
	despawn_by_day = false,
	remove_far = false,
	visual = "mesh",
	mesh = "character5.glb",
	textures = { "skin.png" },
	-- rotate = 180,
	visual_size = { x = 1, y = 1 },
	-- BRILHO NOS OLHOS
	-- glow = -14,  -- Intensidade de 0 a 14 (14 = mais brilhante)
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = true,               -- Permite "voar" na água
	-- fly_in = "air",   -- Voa no ar
	walk_velocity = 1,
	run_velocity = 4,
	view_range = 16,
	water_damage = 2,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	animation = {
		speed_normal = 0.5,
		stand_start = 0,
		stand_end = 1.02,
		walk_start = 1,
		walk_end = 2,
		-- ANIMAÇÃO DE ATAQUE:
		punch_start = 11.75, -- Frame inicial do ataque
		punch_end = 12, -- Frame final do ataque
	},

	-- Mantém uma lista mínima (pode deixar vazia ou com qualquer item)
	-- O seguimento real será feito pelo do_custom abaixo
	-- follow = {"nh_nodes:torch2", "nh_nodes:dirt", "nh_items:writedpage", "nh_nodes:oakchest", "nh_nodes:cobblestone", "nh_nodes:oakwood"},

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
	sounds = { random = "vulto_som", damage = "vulto_hurt", },
	after_activate = function(self, staticdata, def, dtime) self.object:set_properties({ static_save = true }) end,
	-- do_custom = function(self, dtime)
	--     self.lifetimer = 20000
	--     return true
	-- end,
})
-- Spawn do dopel (casas, blocos de madeiras)
mobs:spawn({
	name = "nh_mob:dopel",
	nodes = { "air" },
	neighbors = { "nh_nodes:oakwood" },
	max_light = 14,
	interval = 30,
	chance = 20,
	active_object_count = 1,
	min_height = -50,
	max_height = 50
})
--mobs:register_egg("nh_mob:dopel", "Orbe com Dopel", "orbspawner.png", 0)
register_orb_egg("nh_mob:dopel", S("Orb with Dopel"))
-- MOB x: Giant Crab (Agressivo)
mobs:register_mob("nh_mob:giantcrab", {
	type = "monster",
	passive = false,
	reach = 6,
	damage = 8,
	attack_type = "dogfight",
	description = S("Giant Crab") .. "\n" .. S("[Ancient Animal]"),
	blood_texture = "mob_blueblood.png", -- sua textura customizada
	blood_amount = 5,                 -- quantidade de partículas
	hp_min = 50,
	hp_max = 50,
	-- armor = 100,
	armor = 100,
	drops = { { name = "nh_nodes:redcrystal", chance = 1, min = 1, max = 3 }, -- 1-3 cristais (sempre)
	},
	collisionbox = { -7, 0, -5, 5, 8.5, 5 },
	selectionbox = { -7, 5.5, -5, 5, 8.5, 5 },
	physical = true,
	stepheight = 10, -- Consegue subir degraus para conseguir sair da agua (importante!)
	fall_speed = -15,
	fall_damage = 0,
	floats = 0,
	-- pathfinding = true,
	-- tamed = true,
	static_save = true,
	despawn_by_day = false,
	remove_far = false,
	visual = "mesh",
	mesh = "giantcrab.glb",
	textures = { "giantcrab.png" },
	-- rotate = 180,
	visual_size = { x = 20, y = 20 },
	-- BRILHO NOS OLHOS
	glow = 14, -- Intensidade de 0 a 14 (14 = mais brilhante)
	-- IMPORTANTE: Propriedades para manter na água
	-- fly = true,               -- Permite "voar" na água
	-- fly_in = "nh_nodes:water",   -- Voa no ar
	walk_velocity = 5,
	run_velocity = 10,
	view_range = 50,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	air_damage = 0,
	animation = {
		speed_normal = 1,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 0.75,
		-- ANIMAÇÃO DE ATAQUE:
		punch_start = 0.75, -- Frame inicial do ataque
		punch_end = 1.25, -- Frame final do ataque
	},
	-- Mantém uma lista mínima (pode deixar vazia ou com qualquer item)
	-- O seguimento real será feito pelo do_custom abaixo
	-- follow = {"nh_nodes:sphere", "nh_nodes:kelp", "nh_nodes:obsidian", "nh_nodes:wet_sand", "nh_nodes:dirt", "nh_items:writedpage", "nh_nodes:oakchest", "nh_nodes:cobblestone", "nh_nodes:pineraft", "nh_nodes:rowing"},
	-- RESPOSTA NO PRIMEIRO CLIQUE COM QUALQUER ITEM (exceto mão vazia)
	on_rightclick = function(self, clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()
			local name = item:get_name()
			if name == "" then
				core.chat_send_player(clicker:get_player_name(), S("?!"))
			else
				core.chat_send_player(
					clicker:get_player_name(), S("Crrrr!"))
			end
		end
	end,
	sounds = { random = "vulto_som", damage = "vulto_hurt", },
	custom_attack = function(self, to_attack)
		self.attack_count = (self.attack_count or 0) + 1
		if self.attack_count < 3 then return end
		self.attack_count = 0
		self:set_animation("punch", false)
		return true -- PARA CONTINUAR.
	end,
	after_activate = function(self, staticdata, def, dtime)
		self.object:set_properties({ static_save = true })
		-- Restaura ataque ao jogador mais próximo sempre (novo spawn OU reload)
		core.after(0.5, function()
			if not self.object:is_valid() then return end
			local pos = self.object:get_pos()
			local nearest_player = nil
			local nearest_dist = self.view_range or 50
			for _, player in ipairs(core.get_connected_players()) do
				local dist = vector.distance(pos, player:get_pos())
				if dist < nearest_dist then
					nearest_dist = dist
					nearest_player = player
				end
			end
			if nearest_player then self:do_attack(nearest_player) end
		end)
		-- Punch simbólico só no primeiro spawn
		if staticdata and staticdata ~= "" then return end
		core.after(0.2, function()
			if not self.object:is_valid() then return end
			local pos = self.object:get_pos()
			local nearest_player = nil
			local nearest_dist = 20
			for _, player in ipairs(core.get_connected_players()) do
				local dist = vector.distance(pos, player:get_pos())
				if dist < nearest_dist then
					nearest_dist = dist
					nearest_player = player
				end
			end
			if nearest_player then
				self.object:punch(nearest_player, 1.0,
					{ full_punch_interval = 1.0, damage_groups = { fleshy = 1 }, }, nil)
			end
		end)
	end,
	do_custom = function(self, dtime)
		-- Impede remoção por distância e lifetimer
		--self.tamed = true
		self.lifetimer = 20000
		if self._last_hp == nil then
			self._last_hp = self.health -- AQUI também
			self._hud_timer = 0
		end
		self._hud_timer = self._hud_timer + dtime
		local current_hp = self.health -- E AQUI
		if current_hp ~= self._last_hp then
			self._last_hp = current_hp
			update_boss_hud(self, S("Giant Crab"))
			self._hud_timer = 0
		elseif self._hud_timer >= 0.5 then
			self._hud_timer = 0
			update_boss_hud(self, S("Giant Crab"))
		end
		return true
	end,
	on_die = function(self, pos, killer) remove_all_boss_hud(self) end,
})
-- Spawn do crab (casas, blocos de madeiras)
--[[
mobs:spawn({
	name = "nh_mob:giantcrab",
	nodes = { "nh_nodes:water" },
	neighbors = { "nh_nodes:kelp" },
	max_light = 15,
	interval = 30,
	chance = 20,
	active_object_count = 1,
	min_height = -19,
	max_height = -16
})
]] --
--mobs:register_egg("nh_mob:dopel", "Orbe com Dopel", "orbspawner.png", 0)
register_orb_egg("nh_mob:giantcrab", S("Orb with Giant Crab"))
-- LOGS FINAIS
core.register_on_mods_loaded(function() log("All mobs 'init.lua' initialized successfully!") end)
