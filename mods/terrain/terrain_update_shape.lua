--[[
    terrain_update_shape.lua
    Antecipa a geração de slopes (ramp, corner, insidecorner) do terrain
    diretamente no mapgen, replicando a lógica dos LBMs/ABMs de init.lua mas
    operando sobre os arrays do VoxelManip (area/data/param2_data).

    Cobre todos os materiais definidos em init.lua:
      • top_grass  → top_grass_ramp / top_grass_corner / top_grass_insidecorner
      • top_grass2 → top_grass_insidecorner  (equivale ao ABM grass_conversion2)
      • dirt       → dirt_ramp / dirt_corner / dirt_insidecorner
      • sand       → sand_ramp / sand_corner / sand_insidecorner
      • basalt     → basaltramp / basaltcorner / basaltinsidecorner
      • snow       → snow_ramp / snow_corner / snow_insidecorner

    Como integrar no init.lua:
        Ver secção "INTEGRAÇÃO" no fim deste arquivo.

    API pública:
        terrain_slopes.init(C, DECORATION_CIDS)   -- chame UMA VEZ antes do on_generated
        terrain_slopes.apply(area, data, param2_data, minp, maxp, C, DECORATION_CIDS)
            → retorna número de nós convertidos (útil para debug/log)
--]]

local terrain_slopes = {}

-- ────────────────────────────────────────────────────────────────────────────
-- TABELAS DE CONFIGURAÇÃO
-- Cada entrada define um material que pode virar rampa/quina.
-- Devem espelhar os `make_slope_lbm` registrados em init.lua.
-- ────────────────────────────────────────────────────────────────────────────

--[[
    cfg = {
        -- content ids do nó-fonte (o que pode virar rampa)
        source_ids   = { C.topgrass },

        -- content ids que são considerados "sólidos" para fins de quina interna
        -- (mesma família: o próprio bloco + suas variantes de slope)
        solid_ids    = { C.topgrass, C.top_grass_ramp, C.top_grass_corner, C.grassinsidecorner },

        -- content ids que são considerados "edge" (borda abaixo = rampa possível)
        -- Tipicamente: air + qualquer nó que não seja da família sólida
        edge_ids     = { C.air, C.grassleaves, C.grassleavesmedium, ... },

        -- content ids dos nós de destino
        ramp         = C.top_grass_ramp,
        corner       = C.top_grass_corner,
        insidecorner = C.grassinsidecorner,

        -- Se true, remove decorações acima do slope gerado
        clear_above  = true,

        -- (opcional) id do nó abaixo que deve ser substituído quando forma corner
        -- corner_below_src  = C.dirt,
        -- corner_below_dest = C.top_grass2,
    }
--]]

-- A tabela real é montada em `terrain_slopes.init(C, ...)` para que os
-- content ids sejam resolvidos em tempo de execução.
local CONFIGS      = nil   -- lista de configs de materiais
local AIR_ID_CACHE = nil   -- cache do content id do ar

-- ────────────────────────────────────────────────────────────────────────────
-- INICIALIZAÇÃO  (chame UMA VEZ antes do primeiro on_generated)
-- Recebe a tabela C (content ids) e a tabela DECORATION_CIDS do init.lua.
-- ────────────────────────────────────────────────────────────────────────────
function terrain_slopes.init(C, DECORATION_CIDS)
    AIR_ID_CACHE = C.air

    --[[
    Estrutura de cada cfg:
      source_ids            ids que este cfg pode converter
      solid_ids             ids considerados "sólidos" da mesma família
      edge_ids              ids de "borda" (nil = modo solid_below para grass)
      ramp / corner / insidecorner   ids de destino
      clear_above           bool: apaga decoração acima do slope gerado
      corner_below_src/dest converte o nó ABAIXO quando forma corner externo
      passable_ids          ids considerados passáveis para inside corner de grass
      use_passthrough_for_ic bool: usa lógica passthrough (grass) vs edge (demais)
      ic_only               bool: este cfg só produz inside corners (top_grass2)
    --]]

    CONFIGS = {

        -- ── TOP_GRASS  ───────────────────────────────────────────────────
        -- Espelha o LBM inline "nh_terrain:grass_conversion" de init.lua.
        -- Lógica especial: "drop" = o vizinho lateral TEM sólido-família
        --                  UMA CAMADA ABAIXO dele (mode solid_below).
        -- Inside corner: diagonal deve ser passável E ter sólido abaixo.
        {
            source_ids   = { C.topgrass },
            solid_ids    = {
                C.topgrass, C.top_grass_ramp,
                C.top_grass_corner, C.grassinsidecorner,
            },
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

        -- ── TOP_GRASS2  ──────────────────────────────────────────────────
        -- Espelha o ABM "nh_terrain:grass_conversion2".
        -- top_grass2 é gerado quando um corner converte o dirt abaixo;
        -- ele só pode virar inside corner (nunca ramp nem corner externo).
        -- Usa a mesma lógica solid_below e passthrough do top_grass.
        {
            source_ids   = { C.topgrass2 },
            solid_ids    = {C.snow, C.snow_ramp, C.snow_corner, C.snow_insidecorner,
                C.topgrass, C.top_grass_ramp, C.top_grass_corner, C.grassinsidecorner, C.topgrass2,
            },
            edge_ids     = nil,   -- modo solid_below
            ramp         = nil,   -- top_grass2 não vira ramp
            corner       = nil,   -- top_grass2 não vira corner externo
            insidecorner = C.grassinsidecorner,
            clear_above  = true,
            passable_ids = { [C.air] = true },
            use_passthrough_for_ic = true,
            ic_only      = true,  -- pula ramp e corner, só tenta inside corner
        },

        -- ── DIRT  ────────────────────────────────────────────────────────
        -- Espelha make_slope_lbm "nh_terrain:dirt_conversion".
        -- Edge = ar OU areia (transição dirt→sand na borda de praia).
        {
            source_ids   = { C.dirt },
            solid_ids    = {
                C.dirt, C.dirt_ramp, C.dirt_corner, C.dirt_insidecorner,
            },
            edge_ids     = { C.sand, C.air },
            ramp         = C.dirt_ramp,
            corner       = C.dirt_corner,
            insidecorner = C.dirt_insidecorner,
            clear_above  = true,
            corner_below_src  = C.dirt,
            corner_below_dest = C.sand,
        },

        -- ── SAND  ────────────────────────────────────────────────────────
        -- Espelha make_slope_lbm "nh_terrain:sand_conversion".
        -- Edge = ar OU areia molhada.
        {
            source_ids   = { C.sand },
            solid_ids    = {
                C.sand, C.sand_ramp, C.sand_corner, C.sand_insidecorner,
            },
            edge_ids     = { C.wetsand, C.air },
            ramp         = C.sand_ramp,
            corner       = C.sand_corner,
            insidecorner = C.sand_insidecorner,
            clear_above  = true,
            -- sem corner_below (convert_wetsand estava comentado no LBM original)
        },

        -- BASALT
        -- Espelha make_slope_lbm "nh_terrain:basalt_conversion".
        
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
        -- Espelha make_slope_lbm "nh_terrain:snow_conversion".
        {
            source_ids   = { C.snow },
            solid_ids    = {C.snow, C.snow_ramp, C.snow_corner, C.snow_insidecorner,
                C.topgrass, C.top_grass_ramp, C.top_grass_corner, C.grassinsidecorner,
            },
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

-- ────────────────────────────────────────────────────────────────────────────
-- HELPERS INTERNOS
-- ────────────────────────────────────────────────────────────────────────────

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

-- ────────────────────────────────────────────────────────────────────────────
-- LÓGICA DE SLOPE PARA UM NÓ
-- Espelha fielmente a `action` de `make_slope_lbm` e os LBMs/ABMs inline de
-- grass do init.lua, operando em cima do VoxelManip.
--
-- Nota sobre modos de detecção de "drop":
--   • Modo solid_below (grass/top_grass2):
--       b[dir] = cfg._sol[ nó_abaixo_do_vizinho_lateral ] == true
--       "O vizinho lateral está sobre um sólido da família" → há continuação
--       sólida. A AUSÊNCIA disso (vizinho em borda/queda) ativa o drop.
--       Mas na lógica original é invertido: b[dir]=true quando TEM sólido
--       abaixo do vizinho → isso sinaliza que esse vizinho É uma superfície
--       válida → nosso nó está na borda em relação a ele → rampa nessa direção.
--
--   • Modo edge (dirt, sand, basalt, snow):
--       b[dir] = cfg._edg[ nó_vizinho_lateral ] == true
--       "O vizinho lateral é ar ou borda" → drop nessa direção.
-- ────────────────────────────────────────────────────────────────────────────
local function apply_one(cfg, area, data, param2_data, DECORATION_CIDS, x, y, z)
    local vi     = area:index(x, y, z)
    local cur_id = data[vi]

    -- Só processa nós-fonte desta config
    if not cfg._src[cur_id] then return false end

    -- Requer ar acima (nó superficial exposto)
    local above_id = get_id(area, data, x, y + 1, z)
    if above_id ~= AIR_ID_CACHE then return false end

    -- ── Calcula vizinhos ─────────────────────────────────────────────────
    -- b[dir] = true → há "drop" / borda nessa direção → candidato a rampa
    -- s[dir] = true → vizinho é sólido da mesma família → candidato a quina

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

    -- ────────────────────────────────────────────────────────────────────
    -- PRIORIDADE 1: INSIDE CORNER
    -- Condição: sem nenhum drop lateral, dois vizinhos sólidos formando L,
    -- e o diagonal oposto ao canto interior é "passável".
    -- Também é a ÚNICA conversão para top_grass2 (ic_only = true).
    -- ────────────────────────────────────────────────────────────────────
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
                    -- Grass/top_grass2: passthrough = passable + sólido-família abaixo
                    if cfg._pass[diag_id] then
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

        -- ic_only: sem inside corner encontrado → não faz nada
        -- normal:  sem drops e sem inside corner → nó interior, sem mudança
        return false
    end

    -- ────────────────────────────────────────────────────────────────────
    -- PRIORIDADE 2: CORNER EXTERNO
    -- Condição: exatamente 2 drops em direções ADJACENTES (não opostas).
    -- Drops opostos (N+S ou E+W) significam que o nó está numa crista
    -- ou vale → mantém bloco plano, sem conversão.
    -- ────────────────────────────────────────────────────────────────────
    if n_drops == 2 then
        local d1, d2 = drops[1], drops[2]

        -- Drops opostos → sem corner
        if (d1 == "N" and d2 == "S") or (d1 == "S" and d2 == "N") then return false end
        if (d1 == "E" and d2 == "W") or (d1 == "W" and d2 == "E") then return false end

        -- Verifica que o cfg suporta corner (top_grass2 não suporta)
        if not cfg.corner then return false end

        -- Mapa de pares de drops adjacentes → param2 do corner
        -- (drops = direções que "caem", o corner aponta para o lado oposto)
        --
        --  drops S+W  → corner param2=0  (canto NE: lado norte e leste são "cheios")
        --  drops W+N  → corner param2=3  (canto SE)
        --  drops N+E  → corner param2=2  (canto SW)
        --  drops E+S  → corner param2=1  (canto NW)
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

    -- ────────────────────────────────────────────────────────────────────
    -- PRIORIDADE 3: RAMPA
    -- Condição: exatamente 1 drop (um único lado em borda/queda).
    -- ────────────────────────────────────────────────────────────────────
    if n_drops == 1 then
        -- Verifica que o cfg suporta ramp (top_grass2 não suporta)
        if not cfg.ramp then return false end

        --  drop ao N → rampa desce para o norte → param2=0
        --  drop ao S → param2=2
        --  drop ao E → param2=3
        --  drop ao W → param2=1
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

-- ────────────────────────────────────────────────────────────────────────────
-- FUNÇÃO PRINCIPAL — terrain_slopes.apply()
--
-- Varre todos os nós do chunk e aplica conversão de slopes em dois passes:
--
--   Passe 1 (top→bottom): materiais principais (top_grass, dirt, sand, …)
--     • top_grass  → ramp / corner / insidecorner
--     • Corner de top_grass gera top_grass2 no nó abaixo (dir. convert_below)
--     • dirt / sand → ramp / corner / insidecorner
--
--   Passe 2 (top→bottom): top_grass2 → insidecorner
--     • Espelha o ABM grass_conversion2 do init.lua
--     • Só roda após o passe 1 para garantir que os top_grass2 já existam
--
-- Bordas externas do chunk (±1 nó em cada eixo) são excluídas da varredura
-- porque seus vizinhos podem estar fora do area e retornar CONTENT_IGNORE,
-- causando falsos positivos. Os LBMs (run_at_every_load) do init.lua já
-- cobrem essas bordas quando o chunk é carregado.
--
-- Parâmetros:
--   area            VoxelArea do vm
--   data            array de content ids  (vm:get_data())
--   param2_data     array de param2       (vm:get_param2_data())
--   minp, maxp      limites do chunk (os do on_generated, não os do vm)
--   C               tabela de content ids do terrain (init.lua)
--   DECORATION_CIDS lookup table {[cid]=true} das decorações (init.lua)
--
-- Retorna: { pass1=n, pass2=n, total=n }  (útil para debug/log)
-- ────────────────────────────────────────────────────────────────────────────
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

    -- ── PASSE 1: materiais principais (de cima para baixo) ────────────────
    -- Percorrer Y de cima para baixo garante que um corner em Y=N possa
    -- gerar top_grass2 em Y=N-1, que o passe 2 converterá a seguir.
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

    -- ── PASSE 2: top_grass2 → insidecorner ───────────────────────────────
    -- Equivale ao ABM "nh_terrain:grass_conversion2" do init.lua.
    -- top_grass2 é produzido quando um corner de top_grass converte o dirt
    -- abaixo (convert_below); aqui verificamos se esse novo nó forma um
    -- inside corner com os vizinhos grass já convertidos no passe 1.
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

-- ────────────────────────────────────────────────────────────────────────────
-- INTEGRAÇÃO NO init.lua
-- ────────────────────────────────────────────────────────────────────────────
--[[

PASSO 1 — Carregue o módulo e inicialize-o UMA VEZ.
Coloque isto logo após a definição de C, DECORATION_CIDS e init_slope_tables():

    local terrain_slopes = dofile(
        minetest.get_modpath(minetest.get_current_modname())
        .. "/terrain_update_shape.lua"
    )
    terrain_slopes.init(C, DECORATION_CIDS)


PASSO 2 — Chame terrain_slopes.apply() dentro de core.register_on_generated,
APÓS gerar o terreno base (e ilhas / vulcão), mas ANTES de apply_decorations
e vm:set_data(). A ordem completa:

    -- terreno base
    local grass_positions = generate_terrain_base(
        minp, maxp, area, data, heights, biome_factors, noise_maps)

    -- ilhas flutuantes
    generate_floating_islands(area, data, minp, maxp)

    -- vulcão (se aplicável)
    if chunk_near_volcano then
        generate_volcano(area, data, minp, maxp, volcano_pos)
    end

    -- PRÉ-GERAÇÃO DE SLOPES ← NOVO
    local sr = terrain_slopes.apply(
        area, data, param2_data, minp, maxp, C, DECORATION_CIDS)
    -- debug opcional:
    -- core.log("action", ("[terrain] Slopes p1=%d p2=%d total=%d")
    --     :format(sr.pass1, sr.pass2, sr.total))

    -- decorações (geradas DEPOIS dos slopes para que clear_above já tenha
    -- limpado vegetação flutuante antes de replantá-la)
    local decorations = generate_decorations(
        minp, maxp, heights, biome_factors, noise_maps)
    local palm_leaf_rotations, pebble_positions =
        apply_decorations(area, data, param2_data, decorations)

    -- torres de obsidiana
    generate_obsidian_towers(area, data, minp, maxp)

    -- grava no mapa
    vm:set_data(data)
    vm:set_param2_data(param2_data)
    vm:write_to_map()
    vm:update_map()


Por que funciona sem conflito com os LBMs existentes:
  • Os LBMs (run_at_every_load) continuam ativos e corrigem a borda de 1 nó
    que este módulo exclui intencionalmente de cada chunk.
  • O ABM grass_conversion2 continua ativo, mas raramente precisará agir pois
    o passe 2 já converte os top_grass2 produzidos no passe 1.
  • Se um LBM encontrar um nó já no shape correto, a condição de troca não é
    satisfeita e ele simplesmente não faz nada (idempotente).
  • O ABM clear_decorations_on_slopes continua necessário para decorações
    que apareçam dinamicamente (jogadores plantando, etc.).

--]]

return terrain_slopes
