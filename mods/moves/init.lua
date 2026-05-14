-- Arquivo: moves/init.lua
print("[moves] Mod carregado")

local double_tap_time = 0.3
local last_tap = {}
local was_pressing = {}
local running = {}
local last_shift_tap = {}
local was_shift = {}
local crawling = {}
local crouching = {}

-- WALL JUMP
local walljump_cooldown = {}
local walljump_delay = 0.02
local was_jump = {}
local air_jumps = {}

-- WALL CLIMB
local CLIMB_SPEED    = 20      -- velocidade de subida (aumentada)
local HORIZ_FRICTION = 0.1
local FRONT_DIST     = 0.6
local HEIGHT_OFFS    = {0.5, 1.1, 1.8}
local is_climbing    = {}      -- true enquanto o climb estiver ativo
moves_player_states  = {}

-- Janela de tempo após um wall jump em que o climb fica bloqueado
local CLIMB_BLOCK_AFTER_WALLJUMP = 0.4
local last_walljump = {}

-- Utilitário: verifica se um node é sólido/walkable
local function is_walkable(pos)
    local n = core.get_node_or_nil(pos)
    if not n then return false end
    local reg = core.registered_nodes[n.name]
    return reg and reg.walkable == true
end

-- Verifica se existe parede CONTÍNUA de `height` blocos a partir de base_y
local function wall_at(check_x, base_y, check_z, height)
    for i = 0, height - 1 do
        if not is_walkable({x = check_x, y = base_y + i, z = check_z}) then
            return false
        end
    end
    return true
end

core.register_globalstep(function(dtime)

    -- 1. CORRIDA (double-tap W)
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        local controls = player:get_player_control()

        local pressed_now = controls.up and not was_pressing[name]
        if pressed_now then
            local now = core.get_us_time() / 1e6
            if last_tap[name] and (now - last_tap[name] <= double_tap_time) then
                if not running[name] then
                    running[name] = true
                    player:set_physics_override({ speed = 2.0 })
                end
            end
            last_tap[name] = now
        end

        if running[name] and not controls.up then
            running[name] = false
            player:set_physics_override({ speed = 1.0 })
        end

        was_pressing[name] = controls.up
    end

    -- 2. AGACHAR / RASTEJAR (Shift)
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        local controls = player:get_player_control()
        local shift_now = controls.sneak and not was_shift[name]

        if shift_now then
            local now = core.get_us_time() / 1e6
            if last_shift_tap[name] and (now - last_shift_tap[name] <= double_tap_time) then
                crawling[name] = true
                crouching[name] = false
                player:set_physics_override({ speed = 1.1, jump = 0.5 })
                player:set_properties({
                    eye_height = 0.6,
                    collisionbox = {-0.3, 0, -0.3, 0.3, 0.5, 0.3},
                })
            end
            last_shift_tap[name] = now
        end

        if controls.sneak and not crawling[name] then
            if not crouching[name] then
                crouching[name] = true
                crawling[name] = false
                player:set_physics_override({ speed = 0.7, jump = 1.0 })
                player:set_properties({
                    eye_height = 1.0,
                    collisionbox = {-0.3, 0, -0.3, 0.3, 1.2, 0.3},
                })
            end
        end

        if not controls.sneak then
            if crouching[name] or crawling[name] then
                crouching[name] = false
                crawling[name] = false
                player:set_physics_override({ speed = 1.0, jump = 1.0 })
                player:set_properties({
                    eye_height = 2.4,
                    collisionbox = {-0.3, 0, -0.3, 0.3, 2.7, 0.3},
                })
            end
        end

        was_shift[name] = controls.sneak
    end


    -- 3. WALL JUMP + WALL CLIMB (loop único, prioridades explícitas)
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        local ctrl  = player:get_player_control()

        local pos = player:get_pos()
        local below = {
            x = pos.x,
            y = pos.y - 0.15,
            z = pos.z
        }
        local touching_ground = is_walkable(below)
        if touching_ground then
            air_jumps[name] = 0
            is_climbing[name] = false   -- toca o chão → cancela climb
        end
        if air_jumps[name] == nil then air_jumps[name] = 0 end

        if not walljump_cooldown[name] then walljump_cooldown[name] = 0 end
        if not last_walljump[name]     then last_walljump[name]     = 0 end

        local now  = core.get_us_time() / 1e6
        local dir  = player:get_look_dir()

        local check_x = pos.x + dir.x * FRONT_DIST
        local check_z = pos.z + dir.z * FRONT_DIST

        -- Parede detectada em qualquer offset de altura
        local base_wall_found = false
        for _, yoff in ipairs(HEIGHT_OFFS) do
            if is_walkable({x = check_x, y = pos.y + yoff, z = check_z}) then
                base_wall_found = true
                break
            end
        end

        -- Parede de ≥2 blocos contínuos (para wall jump)
        local walljump_wall = base_wall_found and wall_at(check_x, pos.y, check_z, 2)

        -- Checagem de início de climb: ≥4 blocos — só usada para INICIAR, não manter
        local climb_start_wall = base_wall_found and wall_at(check_x, pos.y, check_z, 4)

        local jump_just_pressed = ctrl.jump and not was_jump[name]
        if jump_just_pressed and touching_ground then air_jumps[name] = 1 end
        local walljump_ready = (now - walljump_cooldown[name]) >= walljump_delay
        local climb_blocked  = (now - last_walljump[name]) < CLIMB_BLOCK_AFTER_WALLJUMP

        -- Cancela climb se soltar o pulo ou sumir a parede completamente
        if is_climbing[name] and (not ctrl.jump or not base_wall_found) then
            is_climbing[name] = false
        end

        -- PRIORIDADE 1 — WALL JUMP
        if jump_just_pressed and walljump_wall and walljump_ready and air_jumps[name] >= 1 and air_jumps[name] < 2 then

            is_climbing[name] = false
            player:set_physics_override({ gravity = 1.0, jump = 1.0 })
            player:add_velocity({
                x = -dir.x * 6,
                y = 4.5,
                z = -dir.z * 6,
            })
            air_jumps[name] = air_jumps[name] + 1
            walljump_cooldown[name] = now
            last_walljump[name]     = now

        -- PRIORIDADE 2 — WALL CLIMB
        -- Inicia climb: precisa de ≥4 blocos + não acabou de wall-jumpar
        -- Mantém climb: já estava escalando, só precisa de parede presente e pulo segurado
        elseif ctrl.jump and not jump_just_pressed and not climb_blocked and
               (is_climbing[name] or climb_start_wall) then

            is_climbing[name] = true
            local vel = player:get_velocity() or {x = 0, y = 0, z = 0}
            player:set_velocity({
                x = vel.x * HORIZ_FRICTION,
                y = CLIMB_SPEED,
                z = vel.z * HORIZ_FRICTION,
            })
            moves_player_states[name] = "climb"
            player:set_physics_override({
                gravity = 0,
                jump    = 0,
            })

        -- PADRÃO — física normal
        else
            if not is_climbing[name] then
                player:set_physics_override({
                    gravity = 1.0,
                    jump    = 1.0,
                })
            end
        end

        was_jump[name] = ctrl.jump
    end

end)
