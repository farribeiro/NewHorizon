# Oz — O Ser Etéreo

Um NPC invisível para Luanti que responde via chat usando detecção de intenção
por palavras-chave e estado emocional dinâmico. Sem LLM, sem HTTP, sem lag.
Inspirado na abordagem de Façade (2005).

---

## Instalação

1. Copie a pasta `oz_npc` para o diretório de mods do Luanti:
   - **Linux:** `~/.minetest/mods/`
   - **Windows:** `%appdata%\minetest\mods\`
   - **macOS:** `~/Library/Application Support/minetest/mods/`

2. Ative o mod no mundo desejado (menu "Selecionar mods" na tela do mundo).

3. Nenhuma dependência necessária. Funciona em qualquer jogo.

---

## Como usar

No chat do jogo, use o comando `/o` seguido da sua mensagem:

```
/o oi
/o como você está?
/o onde fica a taverna?
/o quem é você?
```

---

## Como Oz funciona

### Detecção de intenção
Oz reconhece as seguintes categorias de mensagem por palavras-chave:

| Intenção        | Exemplos de gatilho                              |
|-----------------|--------------------------------------------------|
| Saudação        | oi, olá, hey, salve, bom dia                    |
| Despedida       | tchau, até logo, adeus, bye                     |
| Estado          | como vai, tudo bem, como você está              |
| Identidade      | quem é você, o que você é, você existe          |
| Perigo          | monstro, ataque, inimigo, morri                 |
| Direção         | onde, caminho, taverna, aldeia, norte           |
| Recursos        | item, espada, madeira, craft, receita           |
| Clima           | chuva, sol, noite, faz frio                     |
| Agradecimento   | obrigado, valeu, grato                          |
| Insulto         | idiota, inútil, odeio, me deixa                 |
| Elogio          | legal, incrível, gosto de você                  |
| Filosofia       | vida, morte, alma, universo, existência         |
| Ajuda           | ajuda, socorro, preciso, pode me               |

### Estado emocional
Oz tem um **humor** de 0 a 100 (por jogador, por sessão):
- **< 35** → tom frio, respostas secas
- **35–65** → tom neutro, respostas equilibradas
- **> 65** → tom quente, respostas animadas

Elogios sobem o humor. Insultos baixam. Despedidas reduzem levemente.

### Falas espontâneas
A cada 4–8 minutos (aleatorio), Oz sussurra algo ao chat global,
desde que haja pelo menos um jogador online.

### Memória de sessão
Oz lembra quantas vezes cada jogador falou com ele (reseta ao reiniciar o servidor).
Na primeira interação, sempre reage com surpresa.

---

## Personalização

Tudo está em `init.lua`, bem comentado:

- **`intencoes`** — adicione novas intenções ou palavras-chave
- **`fallbacks`** — respostas quando nenhuma intenção é detectada
- **`falas_espontaneas`** — falas que Oz diz sozinho de tempos em tempos
- **`INTERVALO_MIN / MAX`** — frequência das falas espontâneas (em segundos)
- **`minetest.chat_send_all`** → **`minetest.chat_send_player`** — para respostas privadas

---

## Cor do nome no chat

Por padrão, `[Oz]` aparece em azul claro (`#aaddff`).
Altere o valor hex em `init.lua` para mudar a cor.

---

## Licença

MIT — faça o que quiser.
