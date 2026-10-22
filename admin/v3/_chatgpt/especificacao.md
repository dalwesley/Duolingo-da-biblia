# Banco V3 — especificação (piloto `genesis-1-11`)

Objetivo: perguntas que usam o texto bíblico de verdade, com uma tarefa mental diferente por modo, para que os seis gestos deixem de repetir a mesma coisa.

Princípio: **o estudo vem primeiro; as perguntas derivam dele.** O estudo guarda a matéria-prima de cada modo (fatos, estrutura, relações, textos cruzados, leituras erradas). A pergunta nunca inventa conteúdo que o estudo não tenha.

Tradução: **JFAAL**, a mesma que o palco do app mostra (`PalcoVerse`). Todo texto bíblico copiado no banco precisa ser idêntico à JFAAL. Consulta: `node admin/scripts/_jfaal.mjs "Gênesis 1:1–2"`.

Validação: `node admin/scripts/validate_pilot_v3.mjs` (regras V3) e `node admin/scripts/validate_bank.mjs admin/pilot/genesis-1-11/questions_v3.json` (regras V2 atuais).

---

## 1. Arquivo por cena

`admin/pilot/genesis-1-11/cenas/<slug>.json`:

```json
{ "study": { ... }, "questions": [ ... ] }
```

`node admin/scripts/merge_pilot_v3.mjs` junta tudo em `studies_v3.json` e `questions_v3.json`.

---

## 2. Estudo V3

Campos compatíveis com o app atual (`mission_studies.json`) e campos novos.

| Campo | Regra |
|---|---|
| `slug` | slug da cena |
| `passageRef` | trecho principal. **Um capítulo, faixa contínua** (sem `;`). Até 6 versos |
| `passageText` | JFAAL exata de `passageRef` |
| `passages` | lista `{ref, text}` com todos os trechos da cena (o principal primeiro). Cena com duas faixas (ex.: dilúvio) usa duas entradas |
| `context` | até 300 caracteres. O que o leitor precisa saber antes, sem spoiler do insight |
| `keyword` / `keywordGloss` | palavra da cena (até 3 palavras) e explicação em 1 frase |
| `focusQuestion` | pergunta de reflexão pessoal (tom você) |
| `reflectionPrompts` | 3 rótulos curtos |
| `relatedVerses` | `{reference, reason}` — espelho de `crossRefs` para o app atual |
| `facts` | 4 a 6 `{text, evidenceRef, evidenceSpan}`: fato literal, referência de um capítulo, trecho exato da JFAAL que prova |
| `keyTerms` | 2 a 3 `{term, gloss}`: `term` aparece literalmente num trecho da cena |
| `structure` | 3 ou 4 `{label, evidenceRef}`: movimentos do trecho, em ordem, com rótulo próprio (não é cópia do versículo) |
| `relations` | 2 ou 3 `{kind, text, marker, evidenceRef}`: `kind` = causa, contraste, propósito, sequência ou resultado; `marker` = palavra do texto que marca a relação (ex.: "porém"), ou `null` se implícita |
| `crossRefs` | 2 ou 3 `{ref, text, bridge}`: texto real de outro lugar da Bíblia; `text` é trecho exato da JFAAL de `ref`; `bridge` = o que liga, em até 6 palavras |
| `misreadings` | 3 `{text, why}`: leituras erradas reais que um leitor faz deste trecho, e por que o texto não sustenta |
| `centralInsight` | copiar da cena (`trails.json`) |
| `anchorQuestion` | pergunta para testar em D+2, respondível sem ver o treino |

---

## 3. Matriz gesto × modo

O gesto é o movimento da mão. O modo muda **a tarefa mental**. Nenhum modo repete o que outro já pediu na mesma cena.

| nn | Gesto (`type`) | Observação (`semente`, `observe`) | Compreensão (`caminhada`, `understand`) | Interpretação (`profundezas`, `interpret`) |
|---|---|---|---|---|
| 01 | V/F (`true_false`) | fato literal (`facts`) | relação de causa, contraste ou propósito (`relations`) | leitura sustentável ou leitura errada (`misreadings`) |
| 02 | Toque (`find_in_text`) | tocar **quem** ou **o quê** no versículo | tocar a palavra que marca a relação ("porém", "então", "porque") ou a ação que muda a cena | tocar o trecho que sustenta uma leitura |
| 03 | Escolha (`choice`) | fato explícito | relação entre partes do texto | melhor interpretação; distratores tirados de `misreadings` |
| 04 | Ordenar (`order`) | frases do versículo na ordem do texto | movimentos do trecho (`structure`), com rótulos próprios | encadeamento bíblico (ex.: promessa → cumprimento) ou lógica do argumento |
| 05 | Completar (`complete`) | lembrar a palavra-chave concreta | lembrar a palavra que carrega a relação ou a ação | lembrar o termo que carrega o sentido teológico (`keyTerms`) |
| 06 | Conectar (`connect`) | versículo ↔ fato da cena (`passageB.ref` = "Contexto") | versículo ↔ texto cruzado real (`crossRefs`) | versículo ↔ texto cruzado que mostra tema ou cumprimento |

Desafios (`gen-boss-*`) têm 8 perguntas por modo: 01–06 como acima, **07 = Toque**, **08 = Ordenar**. Misturam versículos das cenas anteriores do bloco.

---

## 4. Regras por gesto

Comum a todas as perguntas:

- `id` = `genesis-1-11-{sem|cam|pro}-{section}-{nn}`
- `question` = `prompt` = `cue` (mesmo texto)
- `verseRef`: **um capítulo, faixa contínua, até 2 versos** (é o palco, que o app busca na JFAAL)
- `passageText`: JFAAL exata de `verseRef`
- `evidence`: lista de referências. `evidenceSpan`: trecho exato de `passageText` que prova a resposta (o app vai acender esse trecho)
- `hint`: até 90 caracteres. Aponta **onde olhar**, nunca diz a resposta
- `feedbackCorrect`: até 100 caracteres, explica **por quê**, sem prefixo "Certo:"/"Correto:"
- `feedbackWrong`: uma chave por opção errada (em V/F, a chave é a resposta errada: `"true"` ou `"false"`), até 110 caracteres, específica para aquele erro
- `learningObjective`: 1 frase
- português do Brasil, tom respeitoso, sem jargão na UI ("imago Dei", "tipologia", "protoevangelho", "escatológico")

### 01 V/F (`true_false`)
- `question` é **afirmação completa**, sem `?`, sem dois-pontos
- `options`: `[{"id":"true","text":"Verdadeiro"},{"id":"false","text":"Falso"}]`; `correctOptionId` = `correctAnswer` = `"true"` ou `"false"`
- A falsa precisa ser **plausível** para quem leu rápido (troca de agente, de ordem, de alcance), nunca absurda
- Equilíbrio: na trilha, entre 45% e 55% de verdadeiras

### 02 Toque (`find_in_text`)
- Não é lacuna: o aluno toca no versículo inteiro
- `options`: 3 `{id: a|b|c, text}`, cada texto com 1 a 3 palavras e **presente literalmente** em `passageText` (mesma grafia, maiúscula inclusive)
- As 3 opções são trechos diferentes e plausíveis; a errada nunca pode também responder à pergunta
- `question`: "Em Gênesis 1:2, toque …". Não citar a resposta no enunciado

### 03 Escolha (`choice`)
- 4 opções `a`–`d`, até 80 caracteres, 1 linha
- Observação: fatos do texto (paráfrase curta, não cópia do versículo)
- Compreensão e Interpretação: **nenhuma opção é cópia de trecho do versículo**; distratores são leituras plausíveis e erradas

### 04 Ordenar (`order`)
- 3 opções `a`,`b`,`c` (4 só em Interpretação e só se o texto tiver 4 passos claros), `correctOrder` = ordem certa dos ids
- Observação: peças são **trechos literais** de `passageText`, na ordem do texto
- Compreensão: peças são rótulos de `structure` (paráfrase)
- Interpretação: peças são passos de um encadeamento bíblico
- Frase inteira em cada peça, até 70 caracteres, sem terminar em "e", vírgula ou reticências

### 05 Completar (`complete`)
- `template` = `passageText` com **uma** palavra trocada por `___`
- `options`: 3 palavras únicas (1 palavra cada, ou 2 se for nome composto); a certa é a palavra retirada
- A palavra do completar **não pode** ser resposta do Toque em nenhum modo da mesma cena
- A palavra retirada não pode ser óbvia pela gramática (as 3 opções precisam caber na frase)

### 06 Conectar (`connect`)
- `passageA` = `{ref, text}`: `text` é trecho exato da JFAAL de `ref` (pode ser só uma parte do versículo)
- `passageB`: Observação usa `{"ref":"Contexto","text":"<fato da cena>"}`; Compreensão e Interpretação usam **texto real** `{ref, text}` com trecho exato da JFAAL de `ref`
- 3 opções, a certa **nomeia a ponte** em 1 a 6 palavras
- `question`: "O que liga Gênesis 1:1 a Hebreus 11:3?" (ou "O que Gênesis 1:1 comunica que se liga a este contexto?" na Observação)

---

## 5. Unicidade na cena

- Nenhum enunciado repetido na cena
- As respostas de Toque e Completar de toda a cena (3 modos) são todas diferentes entre si
- As peças de Ordenar não se repetem entre modos
- `passageB` de Conectar não se repete entre Compreensão e Interpretação
- O mesmo `verseRef` não aparece em mais de 3 das 6 perguntas de um modo (use a cena inteira)

---

## 6. Cautela teológica

- Ficar no que o texto sustenta. Onde tradições cristãs divergem (duração dos dias, idade da terra, extensão do dilúvio, forma literária), **não** tomar lado: perguntar o que o texto afirma
- Textos cruzados do Novo Testamento só onde o próprio NT faz a ligação (ex.: Hebreus 11:3, Romanos 5:12, Gálatas 3:8) ou onde o tema é o mesmo sem forçar
- Leituras erradas (`misreadings`) são erros reais de leitura (ex.: "o caos existia antes de Deus"), nunca caricaturas
- Linguagem inclusiva do texto: homem e mulher juntos quando o texto diz

---

## 7. Proibido

- Distratores genéricos ou absurdos ("curiosidade histórica", "o texto não diz nada", "só a reis")
- Prefixos "O trecho afirma:", "Certo:", "Correto:"
- Opção cortada no meio da frase
- Texto bíblico de outra tradução
- Pergunta sobre a própria missão ("o que este treino quer")
