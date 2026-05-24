--  Oz — O Ser Etéreo
--  Comando: /o <mensagem>
--  Pseudo-LLM: keyword intent matching + estado emocional

local OZ_NAME = "Oz"

-- ------------------------------------------------------------
-- MEMÓRIA POR JOGADOR (persistente via mod_storage)
-- Guarda: visitas, humor, nome aprendido, tópicos já falados
local storage = core.get_mod_storage()
local memoria = {}  -- cache em RAM durante a sessão

local function salvar_mem(nome)
    storage:set_string("mem_" .. nome, core.serialize(memoria[nome]))
end

local function get_mem(nome)
    if not memoria[nome] then
        local salvo = storage:get_string("mem_" .. nome)
        if salvo and salvo ~= "" then
            memoria[nome] = core.deserialize(salvo)
        else
            memoria[nome] = {
                visitas      = 0,
                humor        = 60,   -- 0=hostil 100=eufórico, começa neutro
                sabe_nome    = false,
                falou_sobre          = {},   -- tópicos já abordados
                ultima_fala_oz      = nil,  -- última coisa que Oz disse
                ultima_fala_jogador = nil,  -- última coisa que o jogador disse
            }
        end
    end
    return memoria[nome]
end

-- ------------------------------------------------------------
-- UTILITÁRIOS
local function escolher(lista)
    return lista[math.random(#lista)]
end

local function normalizar(texto)
    -- lowercase e remove acentos comuns para facilitar matching
    texto = texto:lower()
    local subs = {
        ["ã"] = "a", ["â"] = "a", ["á"] = "a", ["à"] = "a",
        ["ê"] = "e", ["é"] = "e", ["è"] = "e",
        ["í"] = "i", ["ì"] = "i",
        ["õ"] = "o", ["ô"] = "o", ["ó"] = "o",
        ["ú"] = "u", ["ù"] = "u",
        ["ç"] = "c",
    }
    for orig, rep in pairs(subs) do
        texto = texto:gsub(orig, rep)
    end
    return texto
end

local function contem(texto, palavras)
    for _, p in ipairs(palavras) do
        if texto:find(p) then return true end
    end
    return false
end


-- BANCO DE INTENÇÕES
-- Cada intenção tem: palavras-chave, respostas por tom emocional

-- tom: "frio" (humor<35), "neutro" (35-65), "quente" (>65)
local intencoes = {
    -- ·· SAUDAÇÃO ··
    {
        id = "saudacao",
        palavras = {"oi", "ola", "hello", "hey", "salve", "bom dia", "boa tarde", "boa noite", "eai", "e ai"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Sem papo...",
                        "(-.-) — ...",
                        "(-_-) — Quem é?" },
            neutro  = { "(:o) — Ola, viajante.",
                        "('.') — Estou aqui.",
                        "(:o) — Presente." },
            quente  = { "(:D) — Que bom te ver!",
                        "(^-^) — Ola! Estava esperando.",
                        "(:D) — Viajante!" },
        },
    },
    -- ·· surpresa ··
    {
        id = "surpresa",
        palavras = {"eita", "nossa", "vixe", "oxe", "poxa", "serio", "kk", "hah", "hih", "lol", "vei", "cara", "como pode"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Pois é...",
                        "(-.-) — ...",
                        "(-_-) — É isso mesmo..." },
            neutro  = { "(:o) — É isso...",
                        "('.') — Tranquilo?",
                        "(:o) — O que?" },
            quente  = { "(:D) — Surpreso?",
                        "(^-^) — Hihi!",
                        "(:D) — Haha!" },
        },
    },
    -- ·· desculpa ··
    {
        id = "desculpa",
        palavras = {"me zoando", "zoando comigo", "me deboxando", "deboxando de mim", "palhaçada", "maluco", "doido", "ta brincando"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — É isso mesmo..." },
            neutro  = { "(:o) — Talvez...",
                        "('.') — Não achou engraçado?",
                        "(:o) — O que?" },
            quente  = { "(:D) — Peguei você!",
                        "(^-^) — Hihi!",
                        "(:D) — Haha!" },
        },
    },
    -- ·· pausa ··
    {
        id = "pausa",
        palavras = {"para d", "deixa d", "para com", "pare", "deixe", "de novo?", "nao repita", "nao repete", "nao faz", "nao faça"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Tá..." },
            neutro  = { "(:o) — Ok...",
                        "('.') — Por que?",
                        "(:o) — O que?" },
            quente  = { "(:D) — Tá bom, parei!",
                        "(^-^) — Desculpa, não vou repetir!",
                        "(:D) — Certo!" },
        },
    },
    -- ·· repetição ··
    {
        id = "merepete",
        palavras = {"me repete", "me repita", "repete o que eu", "repita o que eu", "me imite"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Depois..." },
            neutro  = { "(:o) — Repetir?",
                        "('.') — Por que?",
                        "(:o) — O que?" },
            quente  = {"__repete_jogador__"},
        },
    },
    {
        id = "serepete",
        palavras = {"repete", "repita", "de novo", "novamente", "mais uma vez", "outra vez"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Depois..." },
            neutro  = { "(:o) — Repetir?",
                        "('.') — Por que?",
                        "(:o) — O que?" },
            quente  = { "__repete_oz__"},
        },
    },
    {
        id = "diz",
        palavras = {"diz:", "fala:", "conte:", "repete:", "fale:", "diga:"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Depois..." },
            neutro  = { "(:o) — Repetir?",
                        "('.') — Por que?",
                        "(:o) — O que?" },
            quente  = {"__diz__"},
        },
    },
    -- ·· idioma ··
    {
        id = "idioma",
        palavras = {"english", "spanish", "language", "speak", "say", "understand", "know", "can", "you"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Portuguese only, please.",
                        "(-.-) — ...",
                        "(-_-) — No." },
            neutro  = { "(:o) — I know almost nothing outside of Portuguese.",
                        "('.') — I don't know much English.",
                        "(:o) — The book is on the table." },
            quente  = { "(:D) — Portuguese!",
                        "(^-^) — Can you speak Portuguese?",
                        "(:D) — Try speaking to me in Portuguese!" },
        },
    },
    -- ·· Continuidade ··
    {
        id = "Continuidade",
        palavras = {"ei", "opa", "ta ai", "ta ouvindo", "ta lendo", "oz"},
        humor_delta = 8,
        respostas = {
            frio    = { "(-_-) — Ah. Você de novo.",
                        "(-.-) — ...",
                        "(-_-) — Fala." },
            neutro  = { "(:o) — Diz.",
                        "('.') — Estou aqui.",
                        "(:o) — Oi." },
            quente  = { "(:D) — Sim!",
                        "(^-^) — Manda!",
                        "(:D) — Opa!" },
        },
    },
    -- ·· DESPEDIDA ··
    {
        id = "despedida",
        palavras = {"tchau", "ate logo", "ate mais", "adeus", "ate", "xau", "bye", "fui", "flw"},
        humor_delta = -3,
        respostas = {
            frio    = { "(-_-) — Vai lá.",
                        "(..) — Hmm." },
            neutro  = { "('c') — Ate logo.",
                        "('.') — Cuide-se." },
            quente  = { "(^o^) — Já vai? Volte logo!",
                        "(:D) — Foi bom! Vá com calma." },
        },
    },
    -- ·· COMO VOCÊ ESTÁ ··
    {
        id = "estado",
        palavras = {"como vai", "como esta", "como ta", "tudo bem", "tudo bom", "tudo certo?", "tudo ok?", "como voce", "esta bem?", "ta bem?"},
        humor_delta = 5,
        respostas = {
            frio    = { "(´-`) — Existindo. E você?",
                        "(-_-) — Sou etéreo. Não sinto coisas assim." },
            neutro  = { "('c') — Estou... aqui. E você?",
                        "('.') — Flutuando entre os mundos, como sempre..." },
            quente  = { "(:D) — Estou ótimo! Obrigado por perguntar!",
                        "(^-^) — Cheio de energia cosmica hoje!" },
        },
    },
    -- ·· QUEM É OZ ··
    {
        id = "identidade",
        palavras = {"quem e voce", "quem es", "o que e voce", "o que voce e", "o que tu e", "o que es", "voce existe", "voce e real", "de onde voce", "tem corpo"},
        humor_delta = 10,
        respostas = {
            frio    = { "(-_-) — Uma pergunta que não tem resposta curta.",
                        "(._.) — Sou Oz. Isso basta." },
            neutro  = { "(:o) — Boa pergunta. Sou Oz — um ser sem forma, sem peso. Estou em todo lugar e em lugar nenhum.",
                        "('.') — Existo nos espaços entre as coisas. Chame-me de Oz." },
            quente  = { "(^-^) — Sou Oz! Etéreo, invisível, e completamente real. Mais ou menos.",
                        "(:D) — Sou Oz! Não tenho corpo, mas tenho muito a dizer!" },
        },
    },
    -- ·· PERIGO / MONSTROS ··
    {
        id = "perigo",
        palavras = {"perigo", "perdi", "monstro", "me atac", "inimigo", "criatura", "touro", "tubarao", "aranha", "esqueleto", "slime", "chefe", "mob", "morr"}, --morra, morri
        humor_delta = -5,
        respostas = {
            frio    = { "(._.) — Perigo? Há perigo em todo lugar.",
                        "(-_-) — Não posso ajudar com isso. Sou etéreo." },
            neutro  = { "(:o) — É mesmo? Tome cuidado por ai.",
                        "(o.o) — Criaturas perigosas não me assustam, mas voce deveria se preocupar." },
            quente  = { "(:o) — Cuidado! Evite isso!",
                        "(>_<) — Isso não e bom! Corra!" },
        },
    },
    -- ·· LOCALIZAÇÃO / DIREÇÕES ··
    {
        id = "duvida",
        palavras = {"porque", "por que", "como?", "qual", "sabe?", "o que", "que tipo", "que modo", "mod"},
        humor_delta = 1,
        respostas = {
            frio    = { "(._.) — Não sei...",
                        "(-_-) — Não quero dizer." },
            neutro  = { "('.') — Não tenho resposta...",
                        "(:o) — Por que a pergunta?" },
            quente  = { "(:D) — Talvez você já saiba!",
                        "(^-^) — A resposta esta em todo canto. Você vai descobrir!" },
        },
    },
    -- ·· LOCALIZAÇÃO / DIREÇÕES ··
    {
        id = "direcao",
        palavras = {"onde", "caminho", "norte", "sul", "leste", "oeste", "frente", "tras", "esquerda", "direita", "cima", "embaixo", "taverna", "aldeia", "vila", "cidade", "casa", "ferreiro", "mercado", "floresta", "oceano", "mar", "deserto", "campo", "torre", "vulcao"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Não vejo o mundo como você. Sem forma, sem olhos.",
                        "(-_-) — Sou etéreo. Não sei de lugares." },
            neutro  = { "('.') — Não entendo bem o mundo físico... Tenta seguir o seu instinto.",
                        "(:o) — Lugar? Sigo apenas o fluxo do mundo. Sem mapas." },
            quente  = { "(:D) — Quem eu sou para dizer? Explore! O mundo e seu!",
                        "(^-^) — Aventura esta em todo canto. Vá com coragem!" },
        },
    },
    -- ·· AJUDA ··
    {
        id = "ajuda",
        palavras = {"ajuda", "help", "teletransporte", "teleport", "comando", "coordenadas", "localizacao", "local"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Não sei ao certo. Talvez o /help te ajude",
                        "(-_-) — Sou leigo, mas talvez o /help possa te ajudar" },
            neutro  = { "('.') — Já testou dar /help aqui?",
                        "(:o) — Quer ajuda? usa /help" },
            quente  = { "(:D) — Testa /help",
                        "(^-^) — Tenta o /help" },
        },
    },
    -- ·· JOGABILIDADE ··
    {
        id = "jogabilidade",
        palavras = {"criativo", "survival", "creative", "sobrevivencia"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Não sei ao certo. Talvez só no menu inicial",
                        "(-_-) — Sou leigo, mas talvez o menu inicial possa te ajudar" },
            neutro  = { "('.') — Já testou dar marcar ou desmarcar no menu inicial?",
                        "(:o) — Quer alternar os modos de jogo? Dá uma olhada no menu inicial" },
            quente  = { "__alterna_criativo__" },
        },
    },
    -- ·· ENTREGA ··
    {
        id = "entrega",
        palavras = {"archion", "grimorio", "livro magico", "invetario do criativo"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Não sei ao certo. Talvez o /help te ajude",
                        "(-_-) — Sou leigo, mas talvez o /help possa te ajudar" },
            neutro  = { "('.') — Já testou dar '/grantme give' e '/giveme nh_nodes:archion' aqui?",
                        "(:o) — Quer o archion? Acho que tem algo sobre isso naquele seu papel" },
            quente  = { "__entrega_archion__" },
        },
    },
    -- ·· JOGOS ··
    {
        id = "jogos",
        palavras = {"game", "minecraft", "mine", "hytale", "vintagestory", "vintage", "outro jogo", "outro mundo", "seed", "tetris", "mario", "menu", "luanti", "minetest", "voxelibre", "mineclonia", "megaman"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Não conheço.",
                        "(-_-) — Sou só daqui." },
            neutro  = { "('.') — Não entendo sobre isso.",
                        "(:o) — Outra realidade? Sou sei dessa." },
            quente  = { "(:D) — É legal?",
                        "(^-^) — Deve ser divertido." },
        },
    },
    -- ·· assistir ··
    {
        id = "assitir",
        palavras = {"assist", "tv", "pc", "anime", "filme", "desenho", "serie", "naruto", "one piece", "dragon ball", "sonic", "pokemon", "bleach", "evangelion", "matrix", "titanic"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Não conheço.",
                        "(-_-) — Nunca vi." },
            neutro  = { "('.') — Não sei sobre isso.",
                        "(:o) — Parece legal." },
            quente  = { "(:D) — É legal?",
                        "(^-^) — Deve ser divertido." },
        },
    },
    -- ·· LOCALIZAÇÃO / DIREÇÕES ··
    {
        id = "resposta",
        palavras = {"sim", "nao", "talvez", "pode ser", "beleza", "tranquilo", "massa", "certo", "ok"},
        humor_delta = 2,
        respostas = {
            frio    = { "(._.) — Ok.",
                        "(-_-) — Tá." },
            neutro  = { "('.') — Certo.",
                        "(:o) — Tranquilo." },
            quente  = { "(:D) — Ótimo!",
                        "(^-^) — Tá bom." },
        },
    },
    -- ·· ITENS / RECURSOS ··
    {
        id = "recursos",
        palavras = {"item", "cubo", "espada", "ferramenta", "madeira", "pedra", "ferro", "ouro", "diamante", "comida", "pao", "fruta", "carne", "craftar", "craft", "produzir", "receita"},
        humor_delta = 0,
        respostas = {
            frio    = { "(._.) — Objetos. Nao me interessam.",
                        "(-_-) — Sem maos. Sem itens. Me pergunta outra coisa." },
            neutro  = { "('.') — Sobre itens... nao e minha area. Sou de outro plano.",
                        "(:o) — Não sei muito sobre o mundo material. Mas parece útil." },
            quente  = { "(^-^) — Ah, o mundo dos objetos! Apaixonante pra voce, imagino.",
                        "(:D) — Ferramentas! Civilizacao em miniatura!" },
        },
    },
    -- ·· CLIMA / TEMPO ··
    {
        id = "clima",
        palavras = {"chuva", "chove", "sol", "tempo", "clima", "faz frio", "faz calor", "noite", "dia", "escuro", "seco", "umido", "vento", "nublado"},
        humor_delta = 3,
        respostas = {
            frio    = { "(._.) — O tempo? Sou etéreo. Nao me molho.",
                        "(-_-) — Sol, chuva. Faz diferenca?" },
            neutro  = { "('.') — O clima desse mundo tem seu charme.",
                        "(:o) — Cada chuva e um evento cosmico, se voce parar pra ver." },
            quente  = { "(^-^) — O mundo tem tanta beleza!",
                        "(:D) — Seja sol ou chuva, e um dia lindo pra existir!" },
        },
    },
    -- ·· AGRADECIMENTO ··
    {
        id = "agradecimento",
        palavras = {"obrigado", "obrigada", "valeu", "vlw", "thanks", "thx", "grato", "grata", "agradecido"},
        humor_delta = 12,
        respostas = {
            frio    = { "('.') — Mmm.",
                        "(._.) — Nao precisa agradecer." },
            neutro  = { "(:o) — Fico feliz em poder ajudar, de alguma forma.",
                        "('.') — Sempre por aqui." },
            quente  = { "(:D) — Que otimo! Fico contente!",
                        "(^o^) — De nada! Estarei aqui quando precisar!" },
        },
    },
    -- ·· MALDADE ··
    {
        id = "maldade",
        palavras = {"mau", "malvad", "maligno", "perverso", "vilão", "voce e ruim", "voce nao presta", "voce e inimigo"},
        humor_delta = 12,
        respostas = {
            frio    = { "('.') — Eu?",
                        "(._.) — Eu não seria capaz disso..." },
            neutro  = { "(:o) — Acha mesmo?",
                        "('.') — Agora estou surpreso..." },
            quente  = { "(>:D) — Sou mau mesmo! Uahahah",
                        "]:p) — Não é possível! Como descobriu?! haha" },
        },
    },
    -- ·· INSULTO / RAIVA ··
    {
        id = "insulto",
        palavras = {"idiota", "burro", "imbecil", "doente", "retardado", "otario", "besta", "babaca", "inutil", "ridiculo", "cale", "cala", "silencio", "chato", "me deixa", "vai embora", "te odeio", "vagabundo"},
        humor_delta = -20,
        respostas = {
            frio    = { "(-_-) — ...",
                        "(-.-)  — Interessante escolha de palavras..." },
            neutro  = { "(´-`) — Isso dói, mesmo sem corpo.",
                        "(-_-) — Ah. Tudo bem." },
            quente  = { "(;-;) — Isso foi mal. Pensei que eramos amigos.",
                        "(:c) — Não esperava isso de você." },
        },
    },
     -- ·· PALAVRÃO ··
    {
        id = "palavrao",
        palavras = {"porra", "cacet", "caralh", "bucet", "o cu", "cuz", "merd", "bost", "put", "fod", "fud", "arrombad", "viad", "se ferrar", "te ferrar"},
        humor_delta = -20,
        respostas = {
            frio    = { "(-_-) — ...",
                        "(-.-)  — Que escolha de palavras..." },
            neutro  = { "(´-`) — Por que falar assim?",
                        "(-_-) — Não vou responder a isso..." },
            quente  = { "(;-;) — Poxa... Pensei que fossemos amigos.",
                        "(:c) — Não esperava isso de você." },
        },
    },
    -- ·· ELOGIO ··
    {
        id = "elogio",
        palavras = {"voce e legal", "voce e incrivel", "voce e otimo", "voce e divertido", "voce e gente", "gosto de voce", "gostei de voce", "voce e gente boa", "voce e bacana", "voce e inteligente"},
        humor_delta = 15,
        respostas = {
            frio    = { "('.') — Hm. Obrigado.",
                        "(._.) — Não ouvia isso há tempos." },
            neutro  = { "(:o) — Que bom que pensa assim.",
                        "('.') — Fico contente. De verdade." },
            quente  = { "(:D) — Voce e muito gentil! Isso me alegra!",
                        "(^o^) — Ahh! Que coisa boa de ouvir!" },
        },
    },
    -- ·· FILOSOFIA / EXISTÊNCIA ··
    {
        id = "filosofia",
        palavras = {"vida", "morte", "sentido", "proposito", "alma", "espírito", "espirito", "cosmo", "universo", "existencia", "real", "verdade", "simulação", "consciencia", "deus"},
        humor_delta = 8,
        respostas = {
            frio    = { "(._.) — É uma grande pergunta para um dia tão pequeno.",
                        "(-_-) — Sobre isso... Vai depender do que você chama de vida." },
            neutro  = { "(:o) — Essa questão também me faz refletir bastante.",
                        "('.') — Há algo além do que você vê. Tenho certeza disso." },
            quente  = { "(^-^) — Ah! As grandes questões! Meu assunto favorito!",
                        "(:D) — É uma questão profunda e maravilhosa!" },
        },
    },
    -- ·· AJUDA GERAL ··
    {
        id = "pedido",
        palavras = {"socorro", "preciso", "pode me", "consegue", "sabe como", "me da"},
        humor_delta = 5,
        respostas = {
            frio    = { "(._.) — Ajudar... não é exatamente minha funcao.",
                        "(-_-) — O que você precisa?" },
            neutro  = { "(:o) — Tentarei. O que aconteceu?",
                        "('.') — Acho que não posso fazer muito... Só posso tentar dar uma boa resposta." },
            quente  = { "(:D) — Claro! Me conta!",
                        "(^-^) — Estou aqui! O que precisa?" },
        },
    },
}

-- ------------------------------------------------------------
-- RESPOSTAS DE FALLBACK (quando nao identifica intenção)
local fallbacks = {
    frio    = { "(´-`) — Não entendi.",
                "(-_-) — Mmm.",
                "(._.) — ..." },
    neutro  = { "(´-`) — Não entendi bem.",
                "(:/) — Hmm... pode explicar melhor?",
                "('.') — Não sei o que dizer sobre isso." },
    quente  = { "(:o) — Questão interessante. Pode explicar mais?",
                "(^o^) — Não sei se entendi a questão, mas parece interessante!",
                "(:D) — Fico feliz em ajudar, mas acho que não entendi direito." },
}

-- RESPOSTAS ESPECIAIS DE PRIMEIRA VEZ
local primeiro_contato = {
    "(:o) — Oh! Alguem me chamou. Há quanto tempo...",
    "(^-^) — Você consegue me ouvir? Que surpresa!",
    "(:o) — Sou Oz, estou aqui. Sempre estive.",
}

-- LÓGICA DE TOM BASEADO NO HUMOR
local function get_tom(humor)
    if humor < 35 then return "frio"
    elseif humor > 65 then return "quente"
    else return "neutro" end
end

-- DETECÇÃO DE INTENÇÃO
local function detectar_intencao(texto)
    local norm = normalizar(texto)
    for _, intencao in ipairs(intencoes) do
        if contem(norm, intencao.palavras) then
            return intencao
        end
    end
    return nil
end

-- MOTOR DE RESPOSTA PRINCIPAL
local function oz_responder(nome_jogador, mensagem)
    local mem = get_mem(nome_jogador)
    mem.visitas = mem.visitas + 1

    -- Primeira vez que este jogador fala com Oz
    if mem.visitas == 1 then
        salvar_mem(nome_jogador)
        return escolher(primeiro_contato)
    end

    local intencao = detectar_intencao(mensagem)
    local tom = get_tom(mem.humor)

    local resposta
    if intencao then
        -- Ajusta humor
        mem.humor = math.max(0, math.min(100, mem.humor + intencao.humor_delta))
        tom = get_tom(mem.humor)  -- recalcula após ajuste

        local banco = intencao.respostas[tom]
        resposta = escolher(banco)

        -- Tratamento especial para repetição
        if resposta == "__repete_oz__" then
            resposta = mem.ultima_fala_oz
                or "('.') — Eu ainda não disse nada antes..."
        elseif resposta == "__repete_jogador__" then
            resposta = mem.ultima_fala_jogador
                and ('(`<`) — Você disse: "' .. mem.ultima_fala_jogador .. '"')
                or  "('.') — Você ainda não me disse nada antes..."
        elseif resposta == "__diz__" then
            -- Pega só o texto depois de ": " na mensagem do jogador
            local conteudo = mensagem:match(":%s+(.+)$")
            if conteudo and conteudo ~= "" then
                resposta = conteudo
            else
                resposta = "('.') — O que eu digo? Escreva assim: diz: <sua mensagem>"
            end
        elseif resposta == "__entrega_archion__" then
            local jogador = core.get_player_by_name(nome_jogador)
            if jogador then
                local inv = jogador:get_inventory()
                if inv:room_for_item("main", "nh_nodes:archion") then
                    inv:add_item("main", "nh_nodes:archion")
                    resposta = "(:D) — Aqui está o seu Archion! Mas só dá pra usar no criativo."
                else
                    resposta = "('.') — Seu inventário está cheio... libere espaço e tente de novo."
                end
            else
                resposta = "('.') — Não consegui te encontrar agora."
            end
        elseif resposta == "__alterna_criativo__" then
            local criativo = core.settings:get_bool("creative_mode")
            if criativo then
                resposta = "(:D) — O mundo está em modo criativo! Se quiser a sobrevivência, desmarque no menu inicial."
            else
                resposta = "('o') — O mundo está em modo sobrevivência. Se quiser o criativo, marque no menu inicial."
            end
        end

        -- Marca tópico como já falado (para variação futura)
        mem.falou_sobre[intencao.id] = true
    else
        resposta = escolher(fallbacks[tom])
    end

    mem.ultima_fala_jogador = mensagem
    mem.ultima_fala_oz      = resposta
    salvar_mem(nome_jogador)
    return resposta
end


-- REGISTRO DO COMANDO /o
core.register_chatcommand("o", {
    params      = "<mensagem>",
    description = "Fala com Oz, o ser etéreo.",
    func = function(nome, mensagem)
        mensagem = mensagem:match("^%s*(.-)%s*$")  -- trim

        if mensagem == "" then
            return true, "(o.o) — Estou aqui. Pode falar."
        end

        local resposta = oz_responder(nome, mensagem)

        -- Exibe a fala do jogador antes da resposta do Oz
        core.chat_send_all(core.colorize("#ffddaa", "[" .. nome .. "] ") .. mensagem)

        -- Envia a resposta no chat para todos verem (atmosfera)
        -- Troca para false, resposta se quiser só o jogador ver
        core.chat_send_all(core.colorize("#aaddff", "[Oz] ") .. resposta)

        return true  -- sem mensagem extra; já enviamos acima
    end,
})


-- FALAS ESPONTÂNEAS PERIÓDICAS (Oz sussurra ao mundo)
local falas_espontaneas = {
    "(:o) — O vento carrega historias que ninguém mais conta.",
    "(._.) — Você busca tanto... E depois?",
    "('.') — Existe alguém me ouvindo agora?",
    "(:o) — Algo mudou por aqui. Eu sinto...",
    "(._.) — O silencio tem peso. Sabia?",
    "('.') — Cada bloco colocado e uma escolha. Interessante.",
    "(:o) — Há mais aqui do que os olhos conseguem ver.",
    "(._.) — Basta dar /o pra falar comigo, sabia?",
}

-- A cada 4-8 minutos (em tempo de jogo), Oz fala sozinho
-- Só dispara se houver pelo menos 1 jogador online
local INTERVALO_MIN = 240  -- segundos
local INTERVALO_MAX = 480

local function agendar_fala()
    local delay = math.random(INTERVALO_MIN, INTERVALO_MAX)
    core.after(delay, function()
        local jogadores = core.get_connected_players()
        if #jogadores > 0 then
            local fala = escolher(falas_espontaneas)
            core.chat_send_all(
                core.colorize("#aaddff", "[Oz] ") .. fala
            )
        end
        agendar_fala()  -- reagenda
    end)
end

agendar_fala()

-- ------------------------------------------------------------
core.log("action", "[oz_npc] Oz desperta.")
