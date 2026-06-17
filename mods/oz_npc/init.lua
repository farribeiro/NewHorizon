--  Oz — O Ser Etéreo
--  Comando: /o <mensagem>
--  Pseudo-LLM: keyword intent matching + estado emocional
local OZ_NAME = "Oz"
local c = core
local S = c.get_translator "nh_oz_npc"
-- ------------------------------------------------------------
-- MEMÓRIA POR JOGADOR (persistente via mod_storage)
-- Guarda: visitas, humor, nome aprendido, tópicos já falados
local storage = c.get_mod_storage()
local memoria = {}  -- cache em RAM durante a sessão

local function salvar_mem(nome)
    storage:set_string("mem_" .. nome, c.serialize(memoria[nome]))
end

local function get_mem(nome)
    if not memoria[nome] then
        local salvo = storage:get_string("mem_" .. nome)
        if salvo and salvo ~= "" then memoria[nome] = c.deserialize(salvo)
        else
            memoria[nome] = {
                visitas      = 0,
                humor        = 60,   -- 0=hostil 100=eufórico, começa neutral
                sabe_nome    = false,
                falou_sobre          = {},   -- tópicos já abordados
                ultima_fala_oz      = nil,  -- última coisa que Oz disse
                ultima_fala_jogador = nil,  -- última coisa que o jogador disse
                ultimo_login        = os.time(),  -- timestamp do último login (para decaimento por tempo)
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
    for orig, rep in pairs(subs) do texto = texto:gsub(orig, rep) end
    return texto
end

local function contem(texto, words)
    for _, p in ipairs(words) do if texto:find(p) then return true end end
    return false
end


-- ------------------------------------------------------------
-- DECAIMENTO DE HUMOR
-- A cada hora ausente, o humor caminha 1 ponto em direção ao neutro (60).
-- Aplicado ao reentrar no mundo e a cada interação com o Oz.
local NEUTRO          = 60
local DECAIMENTO_POR_HORA = 1   -- pontos por hora de ausência (ajuste conforme o tom desejado)

local function aplicar_decaimento(mem)
    if mem.humor == NEUTRO then return end
    local agora    = os.time()
    local ausencia = agora - (mem.ultimo_login or agora)   -- segundos ausente
    local horas    = math.floor(ausencia / 3600)
    if horas <= 0 then return end
    local delta = horas * DECAIMENTO_POR_HORA
    if mem.humor > NEUTRO then mem.humor = math.max(NEUTRO, mem.humor - delta)
    else mem.humor = math.min(NEUTRO, mem.humor + delta)
    end
end

-- BANCO DE INTENÇÕES
-- Cada intenção tem: words-chave, responses por tom emocional

-- tom: "cold" (humor<35), "neutral" (35-65), "hot" (>65)
local intencoes = {
    -- ·· APRENDER NOME DO JOGADOR ··
    {id = "name",
        words = {"my name is ", "call me "},
        humor_delta = 10,
        responses = {
            cold    = {"(-_-) — " .. "__seu_nome__" .. "... " .. "I understand."},
            neutral  = {"( '.') — " .. "__seu_nome__" .. "... " .. "Now I know who you are."},
            hot     = {"(:D) — " .. "__seu_nome__" .. "! " .. "What a beautiful name!"},
    }},
    {id = "nome",
        words = {"meu nome e ", "me chamo ", "me chame de ", "me chama de ", "me chamar de", "me chamam de "},
        humor_delta = 10,
        responses = {
            cold    = {"(-_-) — " .. "__seu_nome__" .. "... " .. "Entendi."},
            neutral  = {"( '.') — " .. "__seu_nome__" .. "... " .. "Agora sei quem você é."},
            hot     = {"(:D) — " .. "__seu_nome__" .. "! " .. "Que nome bonito!"},
    }},
    -- ·· desculpa ··
    {id = "desculpa",
        words = {"me zoando", "zoando comigo", "me deboxando", "deboxando de mim", "palhacada", "maluco", "doido", "ta brincando"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — É isso mesmo..."},
            neutral  = {"(:o) — Talvez...",
                        "( '.') — Não achou engraçado?",
                        "(:o) — O que?"},
            hot  = {"(:D) — Peguei você!",
                        "(^-^) — Hihi!",
                        "(:D) — Haha!"},
    }},
    -- ·· pausa ··
    {id = "pause",
        words = {"stop", "dont do", "don't do", "not again", "no repeat", "without repeat"},
        humor_delta = 0,
        responses = {
            cold    = {"(-_-) — No...",
                        "(-.-) — ...",
                        "(-_-) — Okay..."},
            neutral  = {"(:o) — Ok...",
                        "( '.') — Why?",
                        "(:o) — What?"},
            hot  = {"(:D) — Okay, I'll stop!",
                        "(^-^) — Sorry, I won't repeat!",
                        "(:D) — Okay!"},
    }},
    {id = "pausa",
        words = {"para d", "deixa d", "para com", "pare", "deixe", "de novo nao", "nao repita", "nao repete", "nao faz", "nao faça"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Tá..."},
            neutral  = {"(:o) — Ok...",
                        "( '.') — Por que?",
                        "(:o) — O que?"},
            hot  = {"(:D) — Tá bom, parei!",
                        "(^-^) — Desculpa, não vou repetir!",
                        "(:D) — Certo!"},
    }},
    -- ·· repetição ··
    {id = "repeatme",
        words = {"repeat me", "repeat what", "imitate me"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — No...",
                        "(-.-) — ...",
                        "(-_-) — Later..."},
            neutral  = {"(:o) — Repeat?",
                        "( '.') — Why?",
                        "(:o) — What?"},
            hot  = {"__repete_jogador__"},
    }},
    {id = "merepete",
        words = {"me repete", "me repita", "repete o que eu", "repita o que eu", "me imite"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Depois..."},
            neutral  = {"(:o) — Repetir?",
                        "( '.') — Por que?",
                        "(:o) — O que?"},
            hot  = {"__repete_jogador__"},
    }},
    {id = "selfrepeat",
        words = {"repeat", "again", "one more time", "anew"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — No...",
                        "(-.-) — ...",
                        "(-_-) — Later..."},
            neutral  = {"(:o) — Repeat?",
                        "( '.') — Why?",
                        "(:o) — What?"},
            hot  = {"__repete_oz__"},
    }},
    {id = "serepete",
        words = {"repete", "repita", "de novo", "novamente", "mais uma vez", "outra vez"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Depois..."},
            neutral  = {"(:o) — Repetir?",
                        "( '.') — Por que?",
                        "(:o) — O que?"},
            hot  = {"__repete_oz__"},
    }},
    {id = "say",
        words = {"say:", "speak:", "tell:", "tell me:", "repeat:"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — No...",
                        "(-.-) — ...",
                        "(-_-) — Later..."},
            neutral  = {"(:o) — Repeat?",
                        "( '.') — Why?",
                        "(:o) — What?"},
            hot  = {"__diz__"},
    }},
    {id = "diz",
        words = {"diz:", "fala:", "conte:", "repete:", "fale:", "diga:"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Não...",
                        "(-.-) — ...",
                        "(-_-) — Depois..."},
            neutral  = {"(:o) — Repetir?",
                        "( '.') — Por que?",
                        "(:o) — O que?"},
            hot  = {"__diz__"},
    }},
    -- ·· idioma ··
    {id = "language",
        words = {"english", "spanish", "french", "language", "understand me"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Portuguese only, please.",
                        "(-.-) — ...",
                        "(-_-) — No."},
            neutral  = {"(:o) — I'm better at speaking Portuguese.",
                        "( '.') — I don't know much English.",
                        "(:o) — 'The book is on the table'."},
            hot  = {"(:D) — Portuguese!",
                     "(^-^) — Can you speak Portuguese?",
                     "(:D) — Try speaking to me in Portuguese!"},
    }},
    {id = "linguagem",
        words = {"inglés", "español", "espanol", "francés", "lengua", "habla", "dice", "entiende", "sabes", "puede", "tú", "usted"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Solo portugués, por favor..",
                        "(-.-) — ...",
                        "(-_-) — No."},
            neutral  = {"(:o) — Soy mejor hablando portugués.",
                        "( '.') — No sé mucho español.",
                        "(:o) — The book is on the table."},
            hot  = {"(:D) — ¡Portugués!",
                     "(^-^) — ¿Hablas portugués o inglés?",
                     "(:D) — ¡Intenta hablarme en portugués!"},
    }},
    {id = "idioma",
        words = {"ingles", "espanhol", "frances", "lingua", "idioma", "me entende?"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Apenas português.",
                        "(-.-) — ...",
                        "(-_-) — Não."},
            neutral  = {"(:o) — Eu sei bem pouco fora do português.",
                        "( '.') — Eu não sei muito de outros idiomas.",
                        "(:o) — No inglês sei: The book is on the table."},
            hot  = {"(:D) — Falo português!",
                     "(^-^) — Consegue falar algo em inglês?",
                     "(:D) — Tenta me falar algo em inglês."},
    }},
    -- ·· INSULTO / RAIVA ··
    {id = "insulto",
        words = {"idiota", "burro", "imbecil", "doente", "retardado", "otario", "besta", "babaca", "inutil", "ridiculo", "cale", "cala", "silencio", "chato", "me deixa", "vai embora", "te odeio", "vagabundo", "corno"},
        humor_delta = -20,
        responses = {
            cold    = {"(-_-) — ...",
                        "(-.-)  — Interessante escolha de words..."},
            neutral  = {"(´-`) — Isso dói, mesmo sem corpo.",
                        "(-_-) — Ah. Tudo bem."},
            hot  = {"(;-;) — Isso foi mal. Pensei que eramos amigos.",
                     "(:c) — Não esperava isso de você."},
    }},
    {id = "insult",
    words = {"idiot", "stupid", "imbecile", "sick", "retarded", "fool", "beast", "jerk", "useless", "ridiculous", "shut up", "silence", "annoying", "leave me alone", "go away", "i hate you", "bum"},
    humor_delta = -20,
    responses = {
            cold = {"(-_-) — ...",
                     "(-.-) — Interesting choice of words..."},
            neutral = {"(´-`) — That hurts, even without a body.",
                        "(-_-) — Oh. It's okay."},
            hot = {"(;-;) — That was bad. I thought we were friends.",
                    "(:c) — I didn't expect that from you."},
    }},
     -- ·· PALAVRÃO ··
    {id = "swore",
        words = {" cum ", "dick", "cock", "pussy", " ass ", "asshole", "your hole", "butthole", "shit", "bitch", "fuck", "bastard", "fag ", "nigga", "cunt"}, --seu, teu, meu
        humor_delta = -20,
        responses = {
            cold    = {"(-_-) — ...",
                        "(-.-)  — What a choice of words..."},
            neutral  = {"(´-`) — Why speak like that?",
                        "(-_-) — I'm not going to answer that..."},
            hot  = {"(;-;) — Oh man... I thought we were friends.",
                     "(:c) — I didn't expect that from you."},
    }},
    {id = "palavrao",
        words = {"porra", "goz", "cacet", "caralh", "a rola", "pica ", "bucet", "o cu", "eu cu", "cuz", "merd", "bost", "put", "fod", "fud", "arrombad", "viad", "se ferrar", "te ferrar"}, --seu, teu, meu
        humor_delta = -20,
        responses = {
            cold    = {"(-_-) — ...",
                        "(-.-)  — Que escolha de palavras..."},
            neutral  = {"(´-`) — Por que falar assim?",
                        "(-_-) — Não vou responder a isso..."},
            hot  = {"(;-;) — Poxa... Pensei que fossemos amigos.",
                     "(:c) — Não esperava isso de você."},
    }},
    -- ·· ELOGIO ··
    {id = "praise",
        words = {"u're cool", "ure cool", "ur cool", "u're amazing", "ure amazing", "ur amazing", "u're great", "ure great", "ur great", "u're fun", "ure fun", "ur fun", "u're a good", "ure a good", "ur a good", "u're smart", "ure smart", "ur smart", "u're cool", "ure cool", "ur cool", "I like you", "I like u", "I love you", "I love u"},
        humor_delta = 15,
        responses = {
            cold = {"( '.') — Hm. Thank you.",
                     "(._.) — I haven't heard that in ages."},
            neutral = {"(:o) — That's good that you think so.",
                        "( '.') — I'm glad. Really."},
            hot = {"(:D) — You're very kind! That makes me happy!",
                    "(^o^) — Ahh! That's so good to hear!"},
    }},
    {id = "elogio",
        words = {"voce e legal", "voce e incrivel", "voce e otimo", "voce e divertido", "voce e gente", "gosto de voce", "gostei de voce", "voce e gente boa", "voce e bacana", "voce e inteligente"},
        humor_delta = 15,
        responses = {
            cold    = {"( '.') — Hm. Obrigado.",
                        "(._.) — Não ouvia isso há tempos."},
            neutral  = {"(:o) — Que bom que pensa assim.",
                        "( '.') — Fico contente. De verdade."},
            hot  = {"(:D) — Voce e muito gentil! Isso me alegra!",
                     "(^o^) — Ahh! Que coisa boa de ouvir!"},
    }},
    -- ·· DESPEDIDA ··
    {id = "farewell",
        words = {"bye", "sleepy", "see you", "m leaving", "c u", " cu"},
        humor_delta = -3,
        responses = {
            cold    = {"(-_-) — Bye.",
                        "(..) — Hmm."},
            neutral  = {"('c') — See you later.",
                        "( '.') — Take care."},
            hot  = {"(^o^) — Leaving already? Come back soon!",
                     "(:D) — That was good! Take care."},
    }},
    {id = "despedida",
        words = {"tchau", "sono", "ate logo", "ate mais", "ou indo", "o indo", "adeus", "ate", "xau", "fui", "flw", "falou"}, -- estou, tou, to, vou, vo
        humor_delta = -3,
        responses = {
            cold    = {"(-_-) — Vai lá.",
                        "(..) — Hmm."},
            neutral  = {"('c') — Ate logo.",
                        "( '.') — Cuide-se."},
            hot  = {"(^o^) — Já vai? Volte logo!",
                        "(:D) — Foi bom! Fica bem."},
    }},
    -- ·· COMO VOCÊ ESTÁ ··
    {id = "state",
        words = {"how are you", "s it going", "how are things", "how are you doing", "what are you up to", "everything alright%?", "everything good%?", "alright%?", "everything okay%?", "are you well", "u okay%?", "u ok%?"},
        humor_delta = 5,
        responses = {
            cold = {"(´-`) — Existing. And you?",
                     "(-_-) — I'm ethereal. I don't feel things like that."},
            neutral = {"('c') — I'm... here. And you?",
                       "( '.') — Floating between worlds, as always..."},
            hot = {"(:D) — I'm great! Thanks for asking!",
                    "(^-^) — Full of cosmic energy today!"},
    }},
    {id = "estado",
        words = {"como va", "como esta", "como ta", "tudo bem%?", "tudo bom", "tudo certo%?", "tudo ok%?", "como voce", "ta bem%?", "anda fazendo%?", "ta fazendo%?"}, -- vai, vao, esta, estao, ta, tao
        humor_delta = 5,
        responses = {
            cold    = {"(´-`) — Existindo. E você?",
                        "(-_-) — Sou etéreo. Não sinto coisas assim."},
            neutral  = {"('c') — Estou... aqui. E você?",
                        "( '.') — Flutuando entre os mundos, como sempre..."},
            hot  = {"(:D) — Estou ótimo! Obrigado por perguntar!",
                        "(^-^) — Cheio de energia cosmica hoje!"},
    }},
    -- ·· QUEM É OZ ··
    {id = "identity",
        words = {"who are you", "who are u", "what are you", "what are u", "what r u", "what you are", "you exist", "are you real", "where are you from", "you have a body"},
        humor_delta = 10,
        responses = {
            cold = {"(-_-) — A question that doesn't have a short answer.",
                     "(._.) — I am Oz. That's enough."},
            neutral = {"(:o) — Good question. I am Oz — a being without form, without weight. I am everywhere and nowhere.",
                        "( '.') — I exist in the spaces between things. Call me Oz."},
            hot = {"(^-^) — I am Oz! Ethereal, invisible, and completely real. More or less.",
                    "(:D) — I am Oz! I have no body, but I have a lot to say!"},
    }},
    {id = "identidade",
        words = {"quem e voce", "quem es", "o que e voce", "o que voce e", "o que tu e", "o que es", "voce existe", "voce e real", "de onde voce", "tem corpo"},
        humor_delta = 10,
        responses = {
            cold    = {"(-_-) — Uma pergunta que não tem resposta curta.",
                        "(._.) — Sou Oz. Isso basta."},
            neutral  = {"(:o) — Boa pergunta. Sou Oz — um ser sem forma, sem peso. Estou em todo lugar e em lugar nenhum.",
                        "( '.') — Existo nos espaços entre as coisas. Chame-me de Oz."},
            hot  = {"(^-^) — Sou Oz! Etéreo, invisível, e completamente real. Mais ou menos.",
                     "(:D) — Sou Oz! Não tenho corpo, mas tenho muito a dizer!"},
    }},
    -- ·· PERIGO / MONSTROS ··
    {id = "globaldanger",
        words = {"mob", "slime", "limu", "sirenia", "animal", "dopel"}, 
        humor_delta = -5,
        responses = {
            cold = {"(._.) — " .. S"Danger? There's danger everywhere.",
                     "(-_-) — " .. S"I can't help with that. I'm ethereal."},
            neutral = {"(:o) — " .. S"Really? Be careful out there.",
                        "(o.o) — " .. S"Dangerous creatures don't scare me, but you should be worried."},
            hot = {"(:o) — " .. S"Watch out! Avoid that!",
                    "(>_<) — " .. S"That's not good! Run!"},
    }},
    {id = "danger",
        words = {"danger", "illegal", "lost", "monster", "attacked me", "enemy", "creature", "bull", "shark", "spider", "skeleton", "boss", "giant crab", "visage", "sentinel", "die", "kill me"}, --die, died
        humor_delta = -5,
        responses = {
            cold = {"(._.) — Danger? There's danger everywhere.",
                     "(-_-) — I can't help with that. I'm ethereal."},
            neutral = {"(:o) — Really? Be careful out there.",
                        "(o.o) — Dangerous creatures don't scare me, but you should be worried."},
            hot = {"(:o) — Watch out! Avoid that!",
                    "(>_<) — That's not good! Run!"},
    },},
    {id = "perigo",
        words = {"perigo", "ilegal", "perdi", "monstro", "me atac", "inimigo", "criatura", "touro", "tubarao", "aranha", "esqueleto", "chefe", "caranguejo gigante", "vulto", "sentinel", "morr", "me matar"}, --morra, morri, atacar, matar, tem, spawnam, 
        humor_delta = -5,
        responses = {
            cold    = {"(._.) — Perigo? Há perigo em todo lugar.",
                        "(-_-) — Não posso ajudar com isso. Sou etéreo."},
            neutral  = {"(:o) — É mesmo? Tome cuidado por ai.",
                        "(o.o) — Criaturas perigosas não me assustam, mas você deveria se preocupar."},
            hot  = {"(:o) — Cuidado! Evite isso!",
                        "(>_<) — Isso não e bom! Corra!"},
    },},
    -- ·· LOCALIZAÇÃO / DIREÇÕES ··
    {id = "direction",
        words = {"where", "way", "north", "south", "east", "west", "front", "back", "left", "right", "up", "down", "tavern", "village", "town", "city", "house", "blacksmith", "market", "forest", "ocean", "sea", "desert", "field", "tower", "volcano"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — I don't see the world as you do. Formless, eyeless.",
                        "(-_-) — I am ethereal. I don't know places."},
            neutral  = {"( '.') — I don't quite understand the physical world... Try to follow your instinct.",
                        "(:o) — Place? I just follow the flow of the world. Without maps."},
            hot  = {"(:D) — Who am I to say? Explore! The world is yours!",
                     "(^-^) — Adventure is everywhere. Go with courage!"},
    },},
    {id = "direcao",
        words = {"onde", "caminho", "norte", "sul", "leste", "oeste", "frente", "tras", "esquerda", "direita", "cima", "embaixo", "taverna", "aldeia", "vila", "cidade", "casa", "ferreiro", "mercado", "floresta", "oceano", "mar", "deserto", "campo", "torre", "vulcao"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Não vejo o mundo como você. Sem forma, sem olhos.",
                        "(-_-) — Sou etéreo. Não sei de lugares."},
            neutral  = {"( '.') — Não entendo bem o mundo físico... Tenta seguir o seu instinto.",
                        "(:o) — Lugar? Sigo apenas o fluxo do mundo. Sem mapas."},
            hot  = {"(:D) — Quem eu sou para dizer? Explore! O mundo e seu!",
                     "(^-^) — Aventura esta em todo canto. Vá com coragem!"},
    },},
    -- ·· AJUDA ··
    {id = "help",
        words = {"help me", "need help", "to teleport", "teleport me", "command", "coordinates", "location", "place"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — I'm not sure. Maybe /help will help you.",
                        "(-_-) — I'm a layman, but maybe /help can help you."},
            neutral  = {"( '.') — Have you tried typing /help here?",
                        "(:o) — Need help? Use /help"},
            hot  = {"(:D) — Try: /help",
                     "(^-^) — Try /help"},
    },},
    {id = "ajuda",
        words = {"ajuda", "teletransporte", "teleport", "comando", "coordenadas", "localizacao", "local"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Não sei ao certo. Talvez o /help te ajude",
                        "(-_-) — Sou leigo, mas talvez o /help possa te ajudar"},
            neutral  = {"( '.') — Já testou dar /help aqui?",
                        "(:o) — Quer ajuda? usa /help"},
            hot  = {"(:D) — Testa /help",
                        "(^-^) — Tenta o /help"},
    },},
    -- ·· JOGABILIDADE ··
    {id = "gameplay",
        words = {"survival", "creative", "mode"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — I'm not sure. Maybe only on the main menu.",
                        "(-_-) — I'm a layman, but perhaps the initial menu can help you."},
            neutral  = {"( '.') — Have you tried checking or unchecking the option in the main menu?",
                        "(:o) — Want to switch game modes? Check out the main menu."},
            hot  = {"__alterna_criativo__"},
        },
    },
    {id = "jogabilidade",
        words = {"criativo", "o survival", "a survival", "o creative", "a cretive", "sobrevivencia", "modo"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Não sei ao certo. Talvez só no menu inicial",
                        "(-_-) — Sou leigo, mas talvez o menu inicial possa te ajudar"},
            neutral  = {"( '.') — Já testou dar marcar ou desmarcar no menu inicial?",
                        "(:o) — Quer alternar os modos de jogo? Dá uma olhada no menu inicial"},
            hot  = {"__alterna_criativo__"},
    },},
    -- ·· GIVE ··
    {id = "give",
        words = {" me archion", " a archion", "the archion", "grimoire", "magic book", "creative mode inventory"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — I'm not sure. Maybe /help will help you...",
                        "(-_-) — I'm a layman, but maybe /help can help you."},
            neutral  = {"( '.') — Have you tried using '/grantme give' and '/giveme nh_nodes:archion' here?",
                        "(:o) — Do you want the archion? I think there's something about it in your paper."},
            hot  = {"__entrega_archion__"},
    },},
    -- ·· ENTREGA ··
    {id = "entrega",
        words = {"o archion", " um archion", "grimorio", "livro magico", "inventario do criativo", "inventario do modo criativo"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Não sei ao certo. Talvez o /help te ajude...",
                        "(-_-) — Sou leigo, mas talvez o /help possa te ajudar"},
            neutral  = {"( '.') — Já testou dar '/grantme give' e '/giveme nh_nodes:archion' aqui?",
                        "(:o) — Quer o archion? Acho que tem algo sobre isso naquele seu papel"},
            hot  = {"__entrega_archion__"},
    },},
    -- ·· JOGOS ··
    {id = "jogos",
        words = {"outro jogo", "outro mundo", "jogos", "mito", "lenda", "de plataforma", "de luta", "de tiro", "de guerra", "de estrategia", "de voxel", "de mineração"}, --mito, mitologia
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Eu não sei.",
                        "(-_-) — Só sei daqui."},
            neutral  = {"( '.') — Nunca soube disso.",
                        "(:o) — Outra realidade? Só sei dessa."},
            hot  = {"(:D) — É legal?",
                     "(^-^) — Parece divertido."},
    },},
    {id = "globalgames",
        words = {"game", "virtual", "procedural", "voxel", "pixel", "3d", "minecraft", "mine", "terraria", "hytale", "vintagestory", "vintage story", "fortnite", "roblox", "among us", "amongus", "other world", "seed", "tetris", "pong", "pacman", "pitfall", "mario", "doom", "counterstrike", "menu", "luanti", "minetest", "voxelibre", "mineclonia", "megaman", "bomberman", "final fantasy", "the sims", "shadow of the colossus", "god of war", "gta", "genshin", " mu%?", "mu online", "dota", "league of legends", "valorant", "arcade", "puzzle", "enigma", "retro", "escape", "shooter", "open source", "fliperama"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — " .. S("I don't know."),
                        "(-_-) — " .. S("I'm only know about here.") },
            neutral  = {"( '.') — " .. S("I never knew that."),
                        "(:o) — " .. S("Another reality? That's all I know.") },
            hot  = {"(:D) — " .. S("Is it cool?"),
                     "(^-^) — " .. S("It should be fun.") },
    },},
    -- ·· assistir ··
    {id = "assitir",
        words = {"assist", "a show", "tv", "pc", "anime", "manga", "movie", "filme", "cartoon", "animation", "animação", "desenho", "serie", "naruto", "one piece", "dragon ball", "sonic", "pokemon", "digimon", "bleach", "evangelion", "beyblade", "yugioh", "avatar", "matrix", "titanic", "senhor dos aneis", "lord of the rings"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — " .. S("I don't know."),
                        "(-_-) — " .. S("I've never seen it.") },
            neutral  = {"( '.') — " .. S("I don't know about that."),
                        "(:o) — " .. S("That sounds good.") },
            hot  = {"(:D) — " .. S("Is it cool?"),
                     "(^-^) — " .. S("It should be fun.") },
    },},
    -- ·· RESPOSTA ··
    {id = "globalanswer",
        words = {"ok", "Hm", "hum", "top ", "yep", "nop"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Ok.",
                        "(-_-) — " .. S("Good.") },
            neutral  = {"( '.') — " .. S("Right."),
                        "(:o) — " .. S("No problem.") },
            hot  = {"(:D) — " .. S("Excellent!"),
                     "(^-^) — " .. S("Okay.") },
    },},   
    -- Manual
    {id = "guide",
        words = {"production manual", "crafting manual", "craft manual", "production guide", "craft guide", "crafting guide", "crafting book", "recipe book", "recipe guide"},
        humor_delta = 0,
        responses = {
        cold = {"(._.) — Book? I'm not interested.",
                "(-_-) — I never produced anything. Ask me something else."},
        neutral = {"( '.') — About craft... it's not my area. I'm from another plane.",
                   "(:o) — I don't know much about it. But it seems useful."},
        hot = {"__entrega_guia__"},
    },},
    {id = "guia",
        words = {"manual de produção", "manual de craft", "manual de receita", "guia de produção", "guia de craft", "guia de receita", "livro de craft", "livro de receita"},
        humor_delta = 0,
        responses = {
            cold    = {"(._.) — Livro? Não me interessa.",
                        "(-_-) — Nunca produzi nada. Me pergunta outra coisa."},
            neutral  = {"( '.') — Sobre produção... não é minha área. Sou de outro plano.",
                        "(:o) — Não sei muito sobre isso. Mas parece útil."},
            hot  = {"__entrega_guia__"},
    },},
    -- RECURSOS
    {id = "resources",
        words = {"items", "cube", "sword", "pickaxe", "axe", "pebble", "tool", "wood", "stone", "iron", "gold", "diamond", "food", "bread", "fruit", "meat", "beef", "craft", "craft", "how to do", "produce", "recipe", "apple", "blueberry", "mushiroom", "paper", "armor", "chest", "bucket", "bed", "wing", "coconut"},
        humor_delta = 0,
        responses = {
        cold = {"(._.) — Objects. I'm not interested.",
                "(-_-) — No hands. No items. Ask me something else."},
        neutral = {"( '.') — About items... it's not my area. I'm from another plane.",
                   "(:o) — I don't know much about the material world. But it seems useful."},
        hot = {"(^-^) — Ah, the world of objects! Fascinating for you, I imagine.",
               "(:D) — Items?! They look like miniature toys to me!"},
    },},
    {id = "recursos",
        words = {"itens", "cubo", "espada", "picareta", "machado", "seixo", "ferramenta", "madeira", "pedra", "ferro", "ouro", "diamante", "comida", "pao", "fruta", "carne", "bife", "craftar", "como faço", "como faz", "produzir", "receita", "maca", "mirtilo", "cogumelo", "papel", "armadura", "bau", "balde", "cama", "asa", "coco"},
        humor_delta = 0,
        responses = {
            cold    = {"(._.) — Objetos. Não me interessam.",
                        "(-_-) — Sem mãos. Sem itens. Me pergunta outra coisa."},
            neutral  = {"( '.') — Sobre itens... não é minha área. Sou de outro plano.",
                        "(:o) — Não sei muito sobre o mundo material. Mas parece útil."},
            hot  = {"(^-^) — Ah, o mundo dos objetos! Fascinante pra você, imagino.",
                     "(:D) — Itens?! Para mim, parecem brinquedos em miniatura!"},
    },},
    -- ·· ITENS / RECURSOS ··
    {id = "globalresources",
        words = {"item", "metal", "mineral", "material", "banana"},
        humor_delta = 0,
        responses = {
        cold = {"(._.) — " .. S("Objects. I'm not interested."),
                "(-_-) — " .. S("No hands. No items. Ask me something else.") },
        neutral = {"( '.') — " .. S("About items... it's not my area. I'm from another plane."),
                   "(:o) — " .. S("I don't know much about the material world. But it seems useful.") },
        hot = {"(^-^) — " .. S("Ah, the world of objects! Fascinating for you, I imagine."),
               "(:D) — " .. S("Items?! They look like miniature toys to me!") },
    },},
    -- ·· TEMPO··
    {id = "time",
        words = {"hour", "what time", " the time", "day%?", "night%?", "afternoon%?", "dawn%?", "morning%?"},
        humor_delta = 3,
        responses = {
        cold = {"(._.) — The moment? I'm ethereal. I don't quite know the difference.",
                 "(-_-) — Time changes all the time. Does it make a difference?"},
        neutral = {"( '.') — Time in this world passes more slowly.",
                    "(:o) — Every day is a cosmic event, if you stop to think about it."},
        hot = {"__horario__"},
    },},
    {id = "tempo",
        words = {"hora", "dia%?", "noite%?", "de tarde%?", "madruga%?", "de manha%?"},
        humor_delta = 3,
        responses = {
            cold    = {"(._.) — O momento? Sou etéreo. Não sei bem a diferença.",
                        "(-_-) — O tempo muda o tempo todo. Faz diferença?"},
            neutral  = {"( '.') — O tempo nesse mundo passa mais devagar.",
                        "(:o) — Cada dia é um evento cósmico, se você parar pra ver."},
            hot  = {"__horario__"},
    },},
    -- ·· CLIMA··
    {id = "climate",
        words = {"rain", "raining", "sun", "weather", "climate", "cold", "hot", "dark", "dry", "humid", "wind", "cloudy"},
        humor_delta = 3,
        responses = {
            cold = {"(._.) — The weather? I'm ethereal. I don't get wet.",
                    "(-_-) — The sky changes all the time. Does it make a difference?"},
            neutral = {"( '.') — The climate of this world has its charm.",
                       "(:o) — Every rain is a cosmic event, if you stop to see."},
            hot = {"(^-^) — It's possible. The world has so much beauty!",
                    "(:D) — Whether it's sun or rain, it's a beautiful day to exist!"},
    },},
    {id = "clima",
        words = {"chuva", "chove", "sol", "tempo", "clima", "frio", "calor", "escuro", "seco", "umido", "vento", "nublado"},
        humor_delta = 3,
        responses = {
            cold    = {"(._.) — O tempo? Sou etéreo. Não me molho.",
                        "(-_-) — O céu muda o tempo todo. Faz diferença?"},
            neutral  = {"( '.') — O clima desse mundo tem seu charme.",
                        "(:o) — Cada chuva é um evento cósmico, se você parar pra ver."},
            hot  = {"(^-^) — É possível. O mundo tem tanta beleza!",
                     "(:D) — Seja sol ou chuva, e um dia lindo pra existir!"},
    },},
    -- ·· AGRADECIMENTO ··
    {id = "gratitude",
        words = {"thank you", "thanks", "thx", "grateful", "thankful", "grated"},
        humor_delta = 12,
        responses = {
            cold = {"( '.') — Mmm.",
                     "(._.) — No need to thank me."},
            neutral = {"(:o) — I'm happy to be able to help, in some way.",
                        "( '.') — Always around."},
            hot = {"(:D) — That's great! I'm glad!",
                    "(^o^) — You're welcome! I'll be here when you need me!"},
    },},
    {id = "agradecimento",
        words = {"obrigado", "obrigada", "valeu", "vlw", "grato", "grata", "agradecido"},
        humor_delta = 12,
        responses = {
            cold    = {"( '.') — Mmm.",
                        "(._.) — Nao precisa agradecer."},
            neutral  = {"(:o) — Fico feliz em poder ajudar, de alguma forma.",
                        "( '.') — Sempre por aqui."},
            hot  = {"(:D) — Que ótimo! Fico contente!",
                     "(^o^) — De nada! Estarei aqui quando precisar!"},
    },},
    -- ·· MALDADE ··
    {id = "evil",
        words = {"bad", "evil", "malicious", "perverse", "villain", "you are bad", "you are worthless", "you are an enemy"},
        humor_delta = 12,
        responses = {
            cold = {"( '.') — Me?",
                     "(._.) — I wouldn't be capable of that..."},
            neutral = {"(:o) — You really think so?",
                        "( '.') — Now I'm surprised..."},
            hot = {"(>:D) — I am evil indeed! Muahahaha",
                    "]:p) — No way! How did you find out?! haha"},
    },},
    {id = "maldade",
        words = {"mau", "malvad", "maligno", "perverso", "vilão", "voce e ruim", "voce nao presta", "voce e inimigo"},
        humor_delta = 12,
        responses = {
            cold    = {"( '.') — Eu?",
                        "(._.) — Eu não seria capaz disso..."},
            neutral  = {"(:o) — Acha mesmo?",
                        "( '.') — Agora estou surpreso..."},
            hot  = {"(>:D) — Sou mau mesmo! Uahahaha",
                     "]:p) — Não é possível! Como descobriu?! haha"},
    },},
    -- ·· FILOSOFIA / EXISTÊNCIA ··
    {id = "philosophy",
        words = {"life", "death", "meaning", "purpose", "soul", "spirit", "spiritual", "cosmos", "universe", "existence", "is real", "truth", "simulation", "consciousness", "god"},
        humor_delta = 8,
        responses = {
            cold = {"(._.) — That's a big question for such a short day.",
                     "(-_-) — About that... It will depend on what you call life."},
            neutral = {"(:o) — This question also makes me think a lot.",
                        "( '.') — There is something beyond what you see. I'm sure of it."},
            hot = {"(^-^) — Ah! The big questions! My favorite subject!",
                    "(:D) — It's a profound and wonderful question!"},
    },},
    {id = "filosofia",
        words = {"vida", "morte", "sentido", "proposito", "alma", "espírito", "espiritual", "cosmo", "universo", "existencia", "e real", "verdade", "simulação", "consciencia", "deus"},
        humor_delta = 8,
        responses = {
            cold    = {"(._.) — É uma grande pergunta para um dia tão pequeno.",
                        "(-_-) — Sobre isso... Vai depender do que você chama de vida."},
            neutral  = {"(:o) — Essa questão também me faz refletir bastante.",
                        "( '.') — Há algo além do que você vê. Tenho certeza disso."},
            hot  = {"(^-^) — Ah! As grandes questões! Meu assunto favorito!",
                     "(:D) — É uma questão profunda e maravilhosa!"},
    },},
    -- ·· Capacidade ··
    {id = "capacity",
        words = {"what you can achieve", "what can you achieve", "what you know", "what you can do", "what can you do", "what you are aware of", "what you are capable of", "what can you achieve"},
        humor_delta = 1,
        responses = {
            cold = {"(._.) — I don't know...",
                     "(-_-) — I don't want to say."},
            neutral = {"( '.') — I don't know how to explain...",
                        "(:o) — Why the question?"},
            hot = {"(:D) — I know how to answer you, give you the time, repeat myself, imitate you, tell you the game mode and give you the Crafting Guide and the Archion!",
                    "(^-^) — I can answer you, give you the time, repeat myself, imitate you, tell you the game mode, and give you the Crafting Guide and the Archion. Just ask."},
    },},
    {id = "capacidade",
        words = {"o que voce consegue", "o que voce sabe", "o que voce pode", "o que voce conhece", "o que voce e capaz", "o que vc consegue", "o que vc sabe", "o que vc pode", "o que vc conhece", "o que vc e capaz", "o que tu consegue", "o que tu sabe", "o que tu pode", "o que tu conhece", "o que tu e capaz"},
        humor_delta = 1,
        responses = {
            cold    = {"(._.) — Eu não sei...",
                        "(-_-) — Eu não quero dizer."},
            neutral  = {"( '.') — Eu não sei como explicar...",
                        "(:o) — Por que a pergunta?"},
            hot  = {"(:D) — Sei te responder, te dar a hora, me repetir, te repetir, dizer o modo de jogo e te dar o Guia de Produção e o Archion!",
                     "(^-^) — Posso te responder, te dar a hora, me repetir, te repetir, dizer o modo de jogo e te dar o Guia de Produção e o Archion. É só pedir."},
    },}, 
    -- ·· Duvida ··
    {id = "doubt",
        words = {"why", "how", "which", "know", "what", " a mod", "the mod", "at mod"},
        humor_delta = 1,
        responses = {
            cold    = {"(._.) — I don't know...",
                        "(-_-) — I don't want to say."},
            neutral  = {"( '.') — I don't have an answer...",
                        "(:o) — Why the question?"},
            hot  = {"(:D) — Maybe you already know!",
                     "(^-^) — The answer is everywhere. You'll find out!"},
    },},
    {id = "duvida",
        words = {"porque", "por que", "como%?", "qual", "sabe%?", "o que", "que tipo", "que modo", "o mod", "um mod"},
        humor_delta = 1,
        responses = {
            cold    = {"(._.) — Não sei...",
                        "(-_-) — Não quero dizer."},
            neutral  = {"( '.') — Não tenho resposta...",
                        "(:o) — Por que a pergunta?"},
            hot  = {"(:D) — Talvez você já saiba!",
                     "(^-^) — A resposta esta em todo canto. Você vai descobrir!"},
    },},
    -- ·· AJUDA GERAL ··
    {id = "order",
        words = {"rescue", "I need", "can you", "you know how", "give me"},
        humor_delta = 5,
        responses = {
        cold = {"(._.) — Helping... isn't exactly my job.",
                 "(-_-) — What do you need?"},
        neutral = {"(:o) — I'll try. What happened?",
                    "( '.') — I don't think I can do much... I can only try to give a good answer."},
        hot = {"(:D) — Sure! Tell me!",
                "(^-^) — I'm here! What do you need?"},
    },},
    {id = "pedido",
        words = {"socorro", "preciso", "pode me", "consegue", "sabe como", "me da"},
        humor_delta = 5,
        responses = {
            cold    = {"(._.) — Ajudar... não é exatamente minha função.",
                        "(-_-) — O que você precisa?"},
            neutral  = {"(:o) — Tentarei. O que aconteceu?",
                        "( '.') — Acho que não posso fazer muito... Só posso tentar dar uma boa resposta."},
            hot  = {"(:D) — Claro! Me conta!",
                     "(^-^) — Estou aqui! O que precisa?"},
    }},
    -- ·· surpresa ··
    {id = "surprise",
        words = {"wow", "woah", "oh my", "seriously", "dude", "guy", "bro"},
        humor_delta = 8,
        responses = {
            cold = {"(-_-) — Right...",
                     "(-.-) — ...",
                     "(-_-) — That's right..."},
            neutral = {"(:o) — That's it...",
                        "( '.') — Cool?",
                        "(:o) — What?"},
            hot = {"(:D) — Surprised?",
                    "(^-^) — Hihi!",
                    "(:D) — Haha!"},
    }},
    {id = "surpresa",
        words = {"eita", "nossa", "uau", "vixe", "oxe", "poxa", "serio", "kk", "vei", "caramba", "como pode", "mano"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Pois é...",
                        "(-.-) — ...",
                        "(-_-) — É isso mesmo..."},
            neutral  = {"(:o) — É isso...",
                        "( '.') — Tranquilo?",
                        "(:o) — O que?"},
            hot  = {"(:D) — Surpreso?",
                        "(^-^) — Hihi!",
                        "(:D) — Haha!"},
    }},
    {id = "globalsurprise",
        words = {"lol", "hah", "hih", "man"},
        humor_delta = 8,
        responses = {
            cold = {"(-_-) —" .. S("Right..."),
                     "(-.-) — ...",
                     "(-_-) —" .. S("That's right...") },
            neutral = {"(:o) —" .. S("That's it..."),
                        "( '.') —" .. S("Cool?"),
                        "(:o) —" .. S("What?") },
            hot = {"(:D) —" .. S("Surprised?"),
                    "(^-^) — Hihi!",
                    "(:D) — Haha!"},
    }},
    -- ·· Continuidade ··
    {id = "call",
        words = {"oz"},
        humor_delta = 8,
        responses = {
            cold = {"(-_-) — " .. S("Ah. You again."),
                    "(-.-) — ...",
                    "(-_-) — Hmm."},
            neutral = {"(:o) — " .. S("Say."),
                    "( '.') — " .. S("I'm here."),
                    "(:o) — " .. S("Hi.")},
            hot = {"(:D) — " .. S("Yes?!"),
                    "(^-^) — " .. S("Go ahead!"),
                    "(:D) — " .. S("Whats up!")},
    }},
    {id = "Continuity",
        words = {"hey", "you there", "you listening", "you reading"},
        humor_delta = 8,
        responses = {
            cold = {"(-_-) — Ah. You again.",
                    "(-.-) — ...",
                    "(-_-) — Hmm."},
            neutral = {"(:o) — Say.",
                    "( '.') — I'm here.",
                    "(:o) — Hi."},
            hot = {"(:D) — Yes?!",
                    "(^-^) — Go ahead!",
                    "(:D) — Whats up!"},
    }},
    {id = "Continuidade",
        words = {"ei", "opa", "ta ai", "ta ouvindo", "ta lendo"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Ah. Você de novo.",
                        "(-.-) — ...",
                        "(-_-) — Fala."},
            neutral  = {"(:o) — Diz.",
                        "( '.') — Estou aqui.",
                        "(:o) — Oi."},
            hot  = {"(:D) — Sim?!",
                     "(^-^) — Manda!",
                     "(:D) — Opa!"},
    }},
    -- ·· SAUDAÇÃO ··
    {id = "greeting",
        words = {"hello", "hey", "hi", "good morning", "gm", "good afternoon", "good evening", "good night", "gn", "whats up", "wazzup", "wazup"}, -- hi sobrepoe palavras com hi
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — No talking...",
                        "(-.-) — ...",
                        "(-_-) — Who is it?"},
            neutral  = {"(:o) — Hello, traveler.",
                        "( '.') — I'm here.",
                        "(:o) — Presente."},
            hot  = {"(:D) — It's good to see you!",
                     "(^-^) — Hello! I was expecting you.",
                     "(:D) — Traveler!",
                     "(^-^) — " .. "__nome_salvo__" .. "!"},
    },},
    {id = "saudacao",
        words = {"oi", "ola", "salve", "bom dia", "boa tarde", "boa noite", "eai", "e ai"},
        humor_delta = 8,
        responses = {
            cold    = {"(-_-) — Sem papo...",
                        "(-.-) — ...",
                        "(-_-) — Quem é?"},
            neutral  = {"(:o) — Olá, viajante.",
                        "( '.') — Estou aqui.",
                        "(:o) — Presente."},
            hot  = {"(:D) — Que bom te ver!",
                     "(^-^) — Olá! Estava te esperando.",
                     "(:D) — Viajante!",
                     "(^-^) — " .. "__nome_salvo__" .. "!"},
    },},
    {id = "answer",
        words = {"yes", "fine", "not ", "no%!", "noo", "no%,", "so so", "soso", "more or less", "maybe", "perhaps", "right", "nice", "cool", "yeah"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Ok.",
                        "(-_-) — Good."},
            neutral  = {"( '.') — Right.",
                        "(:o) — No problem."},
            hot  = {"(:D) — Excellent!",
                     "(^-^) — Okay."},
    },},
    {id = "resposta",
        words = {"sim", "nao", "talvez", "mais ou menos", "pode ser", "beleza", "tranquilo", "massa", "certo", "legal"},
        humor_delta = 2,
        responses = {
            cold    = {"(._.) — Ok.",
                        "(-_-) — Tá."},
            neutral  = {"( '.') — Certo.",
                        "(:o) — Tranquilo."},
            hot  = {"(:D) — Ótimo!",
                     "(^-^) — Tá bom."},
    },},
}

-- ------------------------------------------------------------
-- responses DE FALLBACK (quando nao identifica intenção)
local fallbacks = {
    cold    = {"(´-`) — " .. S("I didn't understand."),
                "(-_-) — " .. S("Mmm."),
                "(._.) — " .. S("...") },
    neutral  = {"(´-`) — " .. S("I didn't quite understand."),
                "(:/) — " .. S("Hmm... can you explain better?"),
                "( '.') — " .. S("I don't know what to say about that.") },
    hot  = {"(:o) — " .. S("Interesting question. Can you explain more?"),
                "(^o^) — " .. S("Not sure I understood, but it sounds interesting!"),
                "(:D) — " .. S("Happy to help, but I think I didn't quite get it.") },
}

-- responses ESPECIAIS DE PRIMEIRA VEZ
local primeiro_contato = {
    "(:o) — " .. S("Oh! Someone called me. It has been a while..."),
    "(^-^) — " .. S("You can hear me? What a surprise!"),
    "(:o) — " .. S("I am Oz, I am here. I always was."),
}

-- LÓGICA DE TOM BASEADO NO HUMOR
local function get_tom(humor)
    if humor < 35 then return "cold"
    elseif humor > 65 then return "hot"
    else return "neutral" end
end

-- DETECÇÃO DE INTENÇÃO
local function detectar_intencao(texto)
    local norm = normalizar(texto)
    for _, intencao in ipairs(intencoes) do
        if contem(norm, intencao.words) then
            return intencao
        end
    end
    return nil
end

-- MOTOR DE RESPOSTA PRINCIPAL
local function oz_responder(nome_jogador, mensagem)
    local mem = get_mem(nome_jogador)
    mem.visitas = mem.visitas + 1

    -- Decaimento passivo: aproxima o humor do neutro conforme o tempo passado
    aplicar_decaimento(mem)
    mem.ultimo_login = os.time()  -- atualiza referência de tempo

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

        local banco = intencao.responses[tom]
        resposta = escolher(banco)

        -- Tratamento especial de tokens nas respostas
        if resposta == "__repete_oz__" then resposta = mem.ultima_fala_oz or "( '.') — " .. S("I haven't said anything yet...")
        elseif resposta == "__repete_jogador__" then
            if mem.ultima_fala_jogador and mem.ultima_fala_jogador ~= "" then resposta = '(`<`) — ' .. S("You said:") .. ' "' .. mem.ultima_fala_jogador .. '"'
            else resposta = "( '.') — " .. S("You still haven't told me anything yet...")
            end
        elseif resposta == "__diz__" then
            -- Pega só o texto depois de ": " na mensagem do jogador
            local conteudo = mensagem:match(":%s+(.+)$")
            if conteudo and conteudo ~= "" then resposta = conteudo
            else resposta = "( '.') — " .. S("What do I say? Write it like this: 'say: <your message>'")
            end
        elseif resposta == "__entrega_archion__" then
            local jogador = c.get_player_by_name(nome_jogador)
            if jogador then
                local inv = jogador:get_inventory()
                if inv:room_for_item("main", "nh_nodes:archion") then
                    inv:add_item("main", "nh_nodes:archion")
                    resposta = "(:D) — " .. S"Here's your Archion! But it can only be used in Creative mode."
                else resposta = "( '.') — " .. S"I can't give you Archion. Your inventory is full... free up some space and try again."
                end
            else resposta = "( '.') — " .. S"I couldn't find you right now."
            end
        elseif resposta == "__entrega_guia__" then
            local jogador = c.get_player_by_name(nome_jogador)
            if jogador then
                local inv = jogador:get_inventory()
                if inv:room_for_item("main", "nh_nodes:craftguide") then
                    inv:add_item("main", "nh_nodes:craftguide")
                    resposta = "(:D) — " .. S"Here's your Crafting Guide!"
                else resposta = "( '.') — " .. S"I can't give you the Crafting Guide. Your inventory is full... free up some space and try again."
                end
            else resposta = "( '.') — " .. S"I couldn't find you right now."
            end
        elseif resposta == "__alterna_criativo__" then
            local criativo = c.settings:get_bool("creative_mode")
            if criativo then resposta = "(:D) — " .. S("The world is in creative mode! If you want the survival mod, uncheck it in the main menu.")
            else resposta = "('o') — " .. S("The world is in survival mode. If you want creative mode, select it from the main menu.")
            end
        elseif resposta == "__horario__" then
            -- get_timeofday() retorna 0.0 (meia-noite) a 1.0 (proxima meia-noite)
            local t = c.get_timeofday()
            local minutos_totais = math.floor(t * 24 * 60)
            local h = math.floor(minutos_totais / 60)
            local m = minutos_totais % 60
            local periodo
            if h >= 5 and h < 12 then periodo = S("in the world. It's morning")
            elseif h >= 12 and h < 18 then periodo = S("in the world. It's afternoon")
            elseif h >= 18 and h < 24 then periodo = S("in the world. It's night")
            else periodo = S("in the world. It's dawn")
            end
            resposta = "(:D) — " .. S("It's") .. string.format(" %02d:%02d " .. periodo .. ".", h, m)
        elseif resposta:find("__seu_nome__") then
            -- Extrai o nome dito pelo jogador após "meu nome e " ou "me chamo "
            local norm = normalizar(mensagem)
            local nome_extraido = norm:match("meu nome e%s+([%a]+)") or norm:match("me chamo%s+([%a]+)") or norm:match("me chame de%s+([%a]+)") or norm:match("me chama de%s+([%a]+)") or norm:match("me chamar de%s+([%a]+)") or norm:match("me chamam de%s+([%a]+)") or norm:match("my name is%s+([%a]+)") or norm:match("call me%s+([%a]+)")
            if nome_extraido and nome_extraido ~= "" then
                local nome_formatado = nome_extraido:sub(1,1):upper() .. nome_extraido:sub(2)
                mem.nome_aprendido = nome_formatado
                mem.sabe_nome = true
                resposta = resposta:gsub("__seu_nome__", nome_formatado)
            else resposta = "( '.') — Não entendi seu nome... pode repetir?"
            end
        elseif resposta:find("__nome_salvo__") then
            if mem.sabe_nome and mem.nome_aprendido then resposta = resposta:gsub("__nome_salvo__", mem.nome_aprendido)
            else resposta = "( '.') — Não entendi seu nome... pode repetir?"
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
c.register_chatcommand("o", {
    params      = "<mensagem>",
    description = "Fala com Oz, o ser etéreo.",
    func = function(nome, mensagem)
        mensagem = mensagem:match("^%s*(.-)%s*$")  -- trim
        if mensagem == "" then return true, "(o.o) — " .. S"Estou aqui. Pode falar." end
        local resposta = oz_responder(nome, mensagem)
        -- Exibe a fala do jogador antes da resposta do Oz
        -- Usa o nome aprendido se Oz ja souber como o jogador se chama
        local mem_display = get_mem(nome)
        local nome_display = (mem_display.sabe_nome and mem_display.nome_aprendido) or nome
        c.chat_send_all(c.colorize("#ffddaa", "[" .. nome_display .. "] ") .. mensagem)
        -- Envia a resposta no chat para todos verem (atmosfera)
        -- Troca para false, resposta se quiser só o jogador ver
        c.chat_send_all(c.colorize("#aaddff", "[Oz] ") .. resposta)
        return true  -- sem mensagem extra; já enviamos acima
    end,
})


-- FALAS ESPONTÂNEAS PERIÓDICAS (Oz sussurra ao mundo)
local falas_espontaneas = {
    "(:o) — " .. S("The wind carries stories that no one else tells."),
    "(._.) — " .. S("You search so much... And then what?"),
    "( '.') — " .. S("Is anyone listening to me now?"),
    "(:o) — " .. S("Something has changed around here. I feel it..."),
    "(._.) — " .. S("Silence has weight. Did you know?"),
    "( '.') — " .. S("Each block placed is a choice. Interesting."),
    "(:o) — " .. S("There's more here than meets the eye."),
    "(._.) — " .. S("Just give me an /o to talk to me, did you know?"),
}

-- A cada 4-8 minutos (em tempo de jogo), Oz fala sozinho
-- Só dispara se houver pelo menos 1 jogador online
local INTERVALO_MIN = 240  -- segundos
local INTERVALO_MAX = 480

local function agendar_fala()
    local delay = math.random(INTERVALO_MIN, INTERVALO_MAX)
    c.after(delay, function()
        local jogadores = c.get_connected_players()
        if #jogadores > 0 then
            local fala = escolher(falas_espontaneas)
            c.chat_send_all(c.colorize("#aaddff", "[Oz] ") .. fala)
        end
        agendar_fala()  -- reagenda
    end)
end

-- DECAIMENTO AO ENTRAR NO MUNDO
-- Quando o jogador entra, aplica o decaimento acumulado desde o último login
-- e atualiza o timestamp — independente de ter falado com o Oz.
c.register_on_joinplayer(function(player)
    local nome = player:get_player_name()
    local mem  = get_mem(nome)
    if mem.humor ~= NEUTRO then aplicar_decaimento(mem) end
    mem.ultimo_login = os.time()
    salvar_mem(nome)
end)

agendar_fala()

-- ------------------------------------------------------------
c.log("action", "[oz_npc] Oz desperta.")
