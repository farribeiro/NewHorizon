-----------------------------
-- TELEPORTE TOROIDAL + NUVENS
-----------------------------
local MIN_XZ = config.MIN_XZ
local MAX_XZ = config.MAX_XZ
local VOID_Y = config.VOID_Y

-- Configuração normal das nuvens (para resetar depois do teleporte)
local cloud_normal = {
    density = 0.4,
    color = "#fff0f0e5",
    ambient = "#000000",
    height = 120,
    thickness = 16,
    speed = {x = 2, z = 0},
    offset = {x = 0, y = 0, z = 0}
}

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local p = player:get_pos()
        local old_p = {x = p.x, y = p.y, z = p.z}
        local moved = false
        -- ====== TELEPORTE TOROIDAL EM X/Z ======
        if p.x > MAX_XZ + 3 then p.x = MIN_XZ + 2; moved = true end
        if p.x < MIN_XZ - 3 then p.x = MAX_XZ - 2; moved = true end
        if p.z > MAX_XZ + 3 then p.z = MIN_XZ + 2; moved = true end
        if p.z < MIN_XZ - 3 then p.z = MAX_XZ - 2; moved = true end
        -- ====== QUEDA NO VOID ======
        if p.y < VOID_Y + 1 then
            local x_valid = p.x >= MIN_XZ and p.x <= MAX_XZ
            local z_valid = p.z >= MIN_XZ and p.z <= MAX_XZ
            local function sign(n)
                if n > 0 then return 1
                elseif n < 0 then return -1
                else return 0 end
            end
            if x_valid and z_valid then
                local new_x = -(-(p.x) + sign(p.x) * MAX_XZ)
                local new_z = -(-(p.z) + sign(p.z) * MAX_XZ)
                p.x = new_x
                p.z = new_z
                if p.x < MIN_XZ or p.x > MAX_XZ or p.z < MIN_XZ or p.z > MAX_XZ then
                    p.x = 0; p.z = 0
                end
            else
                p.x = 0; p.z = 0
            end
            p.y = p.y + 7
            moved = true
            player:set_velocity({x = 0, y = 0, z = 0})
        end
        -- ====== APLICAR TELEPORTE ======
	if moved then
	    local attach = player:get_attach()
	    if attach then
		-- Teleporta a entidade diretamente, o jogador vai junto por estar anexado
		attach:set_pos(p)
		attach:set_velocity({x = 0, y = 0, z = 0})
		
		local ent = attach:get_luaentity()
		if ent then
		    ent.driver = player
		end
	    else
		player:set_pos(p)
	    end
	    -- Ajuste das nuvens
	    local dx = p.x - old_p.x
	    local dz = p.z - old_p.z
	    local clouds = player:get_clouds()
	    if clouds then
		clouds.offset = clouds.offset or {x = 0, y = 0, z = 0}
		clouds.offset.x = clouds.offset.x + dx
		clouds.offset.z = clouds.offset.z + dz
		player:set_clouds(clouds)
		minetest.after(0.1, function()
		    if player and player:is_player() then
		        player:set_clouds(cloud_normal)
		    end
		end)
	    end
	end
    end
end)
print("[teleport] Sistema toroidal + void carregado")
