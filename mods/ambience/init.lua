-- ambience.lua
minetest.log("action", "=== NH MOD NH_AMBIENCE CARREGADO ===")
local SOUND_RANGE = 8
local CHECK_INTERVAL = 5.0
local gain_atual = {}       -- guarda o gain atual por jogador/som
local GAIN_THRESHOLD = 0.15 -- só recriar se mudou mais que isso
local timers = {}
local wind_handles = {}
local water_handles = {}
local GRASS_NODES = {
    --["nh_nodes:grass"]     = true,
    --["nh_nodes:top_grass"] = true,
    --["nh_nodes:dirt"] = true,
    ["nh_nodes:sand"] = true,
}
local WATER_NODES = {
    --["nh_nodes:wet_sand"] = true,
    ["nh_nodes:water"] = true,
    --["nh_nodes:water2"]   = true,
}
local function count_nearby(pos, node_table, radius)
    local count = 0
    for x = -radius, radius do
        for z = -radius, radius do
            for dy = -2, 0 do
                local n = core.get_node({
                    x = pos.x + x,
                    y = pos.y + dy,
                    z = pos.z + z
                }).name
                if node_table[n] then count = count + 1 end
            end
        end
    end
    return count
end
core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        timers[name] = (timers[name] or 0) + dtime
        if timers[name] < CHECK_INTERVAL then goto continue end
        timers[name]         = 0
        local pos            = player:get_pos()
        local head           = { x = pos.x, y = pos.y + 1.5, z = pos.z }
        local is_underground = head.y < -1
        local in_snow        = core.get_node({ x = pos.x, y = pos.y - 1, z = pos.z }).name == "nh_nodes:snow"
        local water_count    = count_nearby(pos, WATER_NODES, 5)
        local grass_count    = count_nearby(pos, GRASS_NODES, SOUND_RANGE)
        -- Calcula gains
        local max_grass      = (SOUND_RANGE * 2 + 1) * (SOUND_RANGE * 2 + 1) * 3
        local max_water      = (5 * 2 + 1) * (5 * 2 + 1) * 3
        local grass_ratio    = math.min(1.0, grass_count / max_grass)
        local water_ratio    = math.min(1.0, water_count / max_water)
        local gain_wind      = (not is_underground and not in_snow) and (grass_ratio * 0.9) or 0
        local gain_water     = (not is_underground) and (water_ratio * 0.9) or 0
        gain_wind            = gain_wind * (1.0 - water_ratio * 0.8)
        -- Som de vento (grama, terra, areia)
        if wind_handles[name] then
            local diff = math.abs((gain_atual[name .. "_wind"] or 0) - gain_wind)
            if gain_wind <= 0.05 or diff > GAIN_THRESHOLD then
                core.sound_stop(wind_handles[name])
                wind_handles[name] = nil
            end
        end
        if not wind_handles[name] and gain_wind > 0.05 then
            wind_handles[name] = core.sound_play("nh_mainwindgrass", {
                to_player = name,
                gain = gain_wind,
                loop = true,
            })
            gain_atual[name .. "_wind"] = gain_wind
        end
        -- Água (mesma lógica)
        if water_handles[name] then
            local diff = math.abs((gain_atual[name .. "_water"] or 0) - gain_water)
            if gain_water <= 0.05 or diff > GAIN_THRESHOLD then
                core.sound_stop(water_handles[name])
                water_handles[name] = nil
            end
        end
        if not water_handles[name] and gain_water > 0.05 then
            water_handles[name] = core.sound_play("nh_ambience_sea", {
                to_player = name,
                gain = gain_water,
                loop = true,
            })
            gain_atual[name .. "_water"] = gain_water
        end
        ::continue::
    end
end)
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if wind_handles[name] then
        core.sound_stop(wind_handles[name])
        wind_handles[name] = nil
    end
    if water_handles[name] then
        core.sound_stop(water_handles[name])
        water_handles[name] = nil
    end
    timers[name] = nil
end)
