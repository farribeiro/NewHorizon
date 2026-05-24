--terrain_update_shape.lua
--[[Antecipa a geração de slopes (ramp, corner, insidecorner) do terrain
    diretamente no mapgen, replicando a lógica dos LBMs/ABMs de init.lua mas
    operando sobre os arrays do VoxelManip (area/data/param2_data).
]]--

local terrain_slopes = {}

-- A tabela real é montada em `terrain_slopes.init(C, ...)` para que os
-- content ids sejam resolvidos em tempo de execução.
local CONFIGS      = nil   -- lista de configs de materiais
local AIR_ID_CACHE = nil   -- cache do content id do ar

-- INICIALIZAÇÃO  (chame UMA VEZ antes do primeiro on_generated)
-- Recebe a tabela C (content ids) e a tabela DECORATION_CIDS do init.lua.
function terrain_slopes.init(C, DECORATION_CIDS)
    AIR_ID_CACHE = C.air
    --Estrutura de cada cfg
    CONFIGS = {
        -- TOP_GRASS
        {
            source_ids   = {C.topgrass},
            solid_ids    = {C.topgrass, C.top_grass_ramp, C.top_grass_corner, C.grassinsidecorner},
            edge_ids     = nil,   -- nil → modo solid_below
            ramp         = C.top_grass_ramp,
            corner       = C.top_grass_corner,
            insidecorner = C.grassinsidecorner,
            clear_above  = true,
            corner_below_src  = C.dirt,
            corner_below_dest = C.topgrass2,
            passable_ids = { [C.air] = true },   -- decorações adicionadas no init()
            use_passthrough_for_ic = true,
        },
        -- TOP_GRASS2
        {
            source_ids   = { C.topgrass2 },
            solid_ids    = {C.snow, C.snow_ramp, C.snow_corner, C.snow_insidecorner, C.topgrass,
                C.top_grass_ramp, C.top_grass_corner, C.grassinsidecorner, C.topgrass2},
            edge_ids     = nil,   -- modo solid_below
            ramp         = nil,   -- top_grass2 não vira ramp
            corner       = nil,   -- top_grass2 não vira corner externo
            insidecorner = C.grassinsidecorner,
            clear_above  = true,
            passable_ids = { [C.air] = true },
            use_passthrough_for_ic = true,
            ic_only      = true,  -- pula ramp e corner, só tenta inside corner
        },
        -- DIRT  
        {
            source_ids   = {C.dirt},
            solid_ids    = {C.dirt, C.dirt_ramp, C.dirt_corner, C.dirt_insidecorner},
            edge_ids     = { C.sand, C.air },
            ramp         = C.dirt_ramp,
            corner       = C.dirt_corner,
            insidecorner = C.dirt_insidecorner,
            clear_above  = true,
            corner_below_src  = C.dirt,
            corner_below_dest = C.sand,
        },
        -- SAND  
        {
            source_ids   = {C.sand},
            solid_ids    = {C.sand, C.sand_ramp, C.sand_corner, C.sand_insidecorner},
            edge_ids     = {C.wetsand, C.air},
            ramp         = C.sand_ramp,
            corner       = C.sand_corner,
            insidecorner = C.sand_insidecorner,
            clear_above  = true,
            -- sem corner_below (convert_wetsand estava comentado no LBM original)
        },
        -- BASALT
        {
            source_ids   = { C.basalt },
            solid_ids    = {
                C.basalt, C.basaltramp, C.basaltcorner, C.basaltinsidecorner,
            },
            edge_ids     = { C.wetsand, C.air },
            ramp         = C.basaltramp,
            corner       = C.basaltcorner,
            insidecorner = C.basaltinsidecorner,
            clear_above  = true,
        },
        -- SNOW
        {
            source_ids   = { C.snow },
            solid_ids    = {C.snow, C.snow_ramp, C.snow_corner, C.snow_insidecorner,
                C.topgrass, C.top_grass_ramp, C.top_grass_corner, C.grassinsidecorner},
            edge_ids     = { C.air },
            ramp         = C.snow_ramp,
            corner       = C.snow_corner,
            insidecorner = C.snow_insidecorner,
            clear_above  = true,
            corner_below_src  = C.dirt,
            corner_below_dest = C.snow,
        },   
    }
    -- Pré-converte listas de ids para lookup tables O(1)
    for _, cfg in ipairs(CONFIGS) do
        -- source
        local src = {}
        for _, id in ipairs(cfg.source_ids) do src[id] = true end
        cfg._src = src
        -- solid
        local sol = {}
        for _, id in ipairs(cfg.solid_ids) do sol[id] = true end
        cfg._sol = sol
        -- edge (nil se modo solid_below)
        if cfg.edge_ids then
            local edg = {}
            for _, id in ipairs(cfg.edge_ids) do edg[id] = true end
            cfg._edg = edg
        end
        -- passable + decoration ids (grass / top_grass2)
        if cfg.passable_ids then
            local pass = {}
            for id, v in pairs(cfg.passable_ids) do pass[id] = v end
            if DECORATION_CIDS then
                for id in pairs(DECORATION_CIDS) do pass[id] = true end
            end
            cfg._pass = pass
        end
    end
end

-- HELPERS INTERNOS
-- Retorna o content id de (x, y, z) ou CONTENT_IGNORE se fora do area
local function get_id(area, data, x, y, z)
    if area:contains(x, y, z) then
        return data[area:index(x, y, z)]
    end
    return minetest.CONTENT_IGNORE
end
-- Remove decoração acima (se existir) usando lookup de cids de decoração
local function clear_above_node(area, data, DECORATION_CIDS, x, y, z)
    if area:contains(x, y + 1, z) then
        local vi = area:index(x, y + 1, z)
        if DECORATION_CIDS[data[vi]] then
            data[vi] = AIR_ID_CACHE
        end
    end
end
-- Converte o nó abaixo se for `src_id` → `dest_id`
local function convert_below(area, data, x, y, z, src_id, dest_id)
    if area:contains(x, y - 1, z) then
        local vi = area:index(x, y - 1, z)
        if data[vi] == src_id then
            data[vi] = dest_id
        end
    end
end

-- LÓGICA DE SLOPE PARA UM NÓ
local function apply_one(cfg, area, data, param2_data, DECORATION_CIDS, x, y, z)
    local vi     = area:index(x, y, z)
    local cur_id = data[vi]

    -- Só processa nós-fonte desta config
    if not cfg._src[cur_id] then return false end

    -- Requer ar acima (nó superficial exposto)
    local above_id = get_id(area, data, x, y + 1, z)
    if above_id ~= AIR_ID_CACHE and not DECORATION_CIDS[above_id] then return false end

    -- Calcula vizinhos
    local bN, bS, bE, bW   -- drops
    local sN, sS, sE, sW   -- sólidos laterais

    local id_N = get_id(area, data, x,     y, z - 1)
    local id_S = get_id(area, data, x,     y, z + 1)
    local id_E = get_id(area, data, x + 1, y, z    )
    local id_W = get_id(area, data, x - 1, y, z    )

    if cfg._edg then
        -- Modo edge: o vizinho LATERAL é borda/ar
        bN = cfg._edg[id_N] == true
        bS = cfg._edg[id_S] == true
        bE = cfg._edg[id_E] == true
        bW = cfg._edg[id_W] == true
    else
        -- Modo solid_below (grass): verifica o nó abaixo de cada vizinho
        bN = cfg._sol[ get_id(area, data, x,     y - 1, z - 1) ] == true
        bS = cfg._sol[ get_id(area, data, x,     y - 1, z + 1) ] == true
        bE = cfg._sol[ get_id(area, data, x + 1, y - 1, z    ) ] == true
        bW = cfg._sol[ get_id(area, data, x - 1, y - 1, z    ) ] == true
    end

    sN = cfg._sol[id_N] == true
    sS = cfg._sol[id_S] == true
    sE = cfg._sol[id_E] == true
    sW = cfg._sol[id_W] == true

    -- Lista das direções de drop (para contar e identificar corners)
    -- Convenção: drop ao norte → a rampa "desce" para o lado norte → param2 = 0
    local drops = {}
    if bN then drops[#drops + 1] = "N" end
    if bS then drops[#drops + 1] = "S" end
    if bE then drops[#drops + 1] = "E" end
    if bW then drops[#drops + 1] = "W" end

    local n_drops  = #drops
    local any_drop = n_drops > 0

    -- PRIORIDADE 1: INSIDE CORNER
    if not any_drop or cfg.ic_only then
        -- {condição_L,          diagonal_x,  diagonal_z,  param2}
        local ic_cases = {
            { sS and sW,  x - 1,  z + 1,  2 },
            { sW and sN,  x - 1,  z - 1,  1 },
            { sN and sE,  x + 1,  z - 1,  0 },
            { sE and sS,  x + 1,  z + 1,  3 },
        }
        for _, ic in ipairs(ic_cases) do
            if ic[1] then
                local dx, dz = ic[2], ic[3]
                local diag_id = get_id(area, data, dx, y, dz)
                local ok = false
                if cfg.use_passthrough_for_ic and cfg._pass then
                    -- Grass/top_grass2: passthrough = passable + sólido-família abaixo.
                    -- Decorações na diagonal são tratadas igual ao ar: se o diag_id
                    -- for uma decoration (não é sólido), considera o espaço aberto e
                    -- verifica se o nó abaixo da diagonal é sólido da família.
                    local effective_diag_id = diag_id
                    if DECORATION_CIDS[diag_id] then
                        -- decoration no mesmo nível → trata como ar
                        effective_diag_id = AIR_ID_CACHE
                    end
                    if cfg._pass[effective_diag_id] then
                        local diag_below = get_id(area, data, dx, y - 1, dz)
                        ok = cfg._sol[diag_below] == true
                    end
                elseif cfg._edg then
                    -- Demais: diagonal é edge (ar ou borda)
                    ok = cfg._edg[diag_id] == true
                end
                if ok then
                    data[vi]       = cfg.insidecorner
                    param2_data[vi] = ic[4]
                    if cfg.clear_above then
                        clear_above_node(area, data, DECORATION_CIDS, x, y, z)
                    end
                    return true
                end
            end
        end
        return false
    end

    -- PRIORIDADE 2: CORNER EXTERNO
    if n_drops == 2 then
        local d1, d2 = drops[1], drops[2]

        -- Drops opostos → sem corner
        if (d1 == "N" and d2 == "S") or (d1 == "S" and d2 == "N") then return false end
        if (d1 == "E" and d2 == "W") or (d1 == "W" and d2 == "E") then return false end

        -- Verifica que o cfg suporta corner (top_grass2 não suporta)
        if not cfg.corner then return false end

        local function has(a, b)
            return (d1 == a and d2 == b) or (d1 == b and d2 == a)
        end
        local p2 = nil
        if     has("S", "W") then p2 = 2
        elseif has("W", "N") then p2 = 1
        elseif has("N", "E") then p2 = 0
        elseif has("E", "S") then p2 = 3
        end

        if p2 ~= nil then
            data[vi]        = cfg.corner
            param2_data[vi] = p2
            if cfg.clear_above then
                clear_above_node(area, data, DECORATION_CIDS, x, y, z)
            end
            if cfg.corner_below_src then
                convert_below(area, data, x, y, z,
                    cfg.corner_below_src, cfg.corner_below_dest)
            end
            return true
        end
        return false
    end

    -- PRIORIDADE 3: RAMPA
    if n_drops == 1 then
        -- Verifica que o cfg suporta ramp (top_grass2 não suporta)
        if not cfg.ramp then return false end

        local p2 = nil
        if     bN and not bS then p2 = 0
        elseif bS and not bN then p2 = 2
        elseif bE and not bW then p2 = 3
        elseif bW and not bE then p2 = 1
        end

        if p2 ~= nil then
            data[vi]        = cfg.ramp
            param2_data[vi] = p2
            if cfg.clear_above then
                clear_above_node(area, data, DECORATION_CIDS, x, y, z)
            end
            return true
        end
    end
    -- 3 ou 4 drops → pico ou platô isolado → mantém bloco plano
    return false
end

-- FUNÇÃO PRINCIPAL — terrain_slopes.apply()
-- Varre todos os nós do chunk e aplica conversão de slopes em dois passes
function terrain_slopes.apply(area, data, param2_data, minp, maxp, C, DECORATION_CIDS)
    assert(CONFIGS,
        "[terrain_slopes] Chame terrain_slopes.init(C, DECORATION_CIDS) antes do primeiro on_generated!")
    -- Lookup rápido: source_id → cfg
    local src_to_cfg = {}
    for _, cfg in ipairs(CONFIGS) do
        for id in pairs(cfg._src) do
            src_to_cfg[id] = cfg
        end
    end
    -- Encontra a config ic_only (top_grass2) para o passe 2
    local cfg_ic_only = nil
    for _, cfg in ipairs(CONFIGS) do
        if cfg.ic_only then cfg_ic_only = cfg; break end
    end
    local n1, n2 = 0, 0
    -- Limites internos (exclui borda de 1 nó em cada lado)
    local x0, x1 = minp.x + 1, maxp.x - 1
    local y0, y1 = minp.y + 1, maxp.y - 1
    local z0, z1 = minp.z + 1, maxp.z - 1
    -- PASSE 1: materiais principais (de cima para baixo)
    for z = z0, z1 do
        for y = y1, y0, -1 do
            for x = x0, x1 do
                if area:contains(x, y, z) then
                    local id  = data[area:index(x, y, z)]
                    local cfg = src_to_cfg[id]
                    -- Passe 1: ignora top_grass2 (ic_only), reservado ao passe 2
                    if cfg and not cfg.ic_only then
                        if apply_one(cfg, area, data, param2_data, DECORATION_CIDS, x, y, z) then
                            n1 = n1 + 1
                        end
                    end
                end
            end
        end
    end
    -- PASSE 2: top_grass2 → insidecorner
    -- Equivale ao ABM "nh_terrain:grass_conversion2" do init.lua
    if cfg_ic_only then
        for z = z0, z1 do
            for y = y1, y0, -1 do
                for x = x0, x1 do
                    if area:contains(x, y, z) then
                        local id = data[area:index(x, y, z)]
                        if cfg_ic_only._src[id] then
                            if apply_one(cfg_ic_only, area, data, param2_data, DECORATION_CIDS, x, y, z) then
                                n2 = n2 + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return { pass1 = n1, pass2 = n2, total = n1 + n2 }
end
return terrain_slopes
