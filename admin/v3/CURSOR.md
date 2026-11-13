# Gerar cenas V3 com o agente do Cursor

Roteiro para um agente de IA (Cursor) escrever as cenas das trilhas "capítulo a capítulo" (`admin/v3/<livro>-cap/`). O agente escreve o conteúdo; os scripts conferem.

## Para cada trilha (ex.: `mateus-cap`)

1. Liste `admin/v3/<trilha>/manual/pedidos/`. Cada arquivo `<nn>-<cena>.txt` é um pedido completo: instruções, especificação, exemplo e, no fim, a cena em `<cena>…</cena>` com os versículos da JFAAL.
2. Para cada pedido **sem resposta ainda**, leia o arquivo inteiro e siga-o à risca. Grave a resposta em:
   `admin/v3/<trilha>/manual/respostas/<cena>.json`
   - O nome do arquivo é o slug da cena, **sem** o número da frente (`01-mtc-01-a-familia-do-rei.txt` → `mtc-01-a-familia-do-rei.json`).
   - O conteúdo é **só** o objeto JSON `{"study": {...}, "questions": [...]}`, sem markdown e sem texto antes ou depois.
   - Faça as cenas (`lesson`) antes das Travessias (`boss`) da mesma etapa.
3. A cada 3 ou 4 cenas, rode a partir de `admin/`:
   ```
   node scripts/v3_manual.mjs conferir --trail <trilha>
   ```
   - Cena aprovada vai para `cenas/`; não mexa nela.
   - Cena com erro gera `manual/correcoes/<cena>.txt` com a lista. Corrija **todos** os erros editando `manual/respostas/<cena>.json` e rode o `conferir` de novo, até zerar.
4. Com todas aprovadas (`0 para corrigir · 0 sem resposta`), rode:
   ```
   npm run v3:shuffle -- --trail <trilha>
   npm run v3:validate -- --trail <trilha> --final
   npm run v3:merge -- --trail <trilha>
   npm run validate:bank -- v3/<trilha>/questions_v3.json
   ```
   Se o `--final` acusar V/F fora do alvo (45–55% verdadeiras), troque afirmações verdadeiras por falsas plausíveis (ou o contrário) e repita os passos 3 e 4.

## Regras que mais falham (confira antes de gravar)

- Texto bíblico: só os versos que vêm no pedido, copiados letra por letra. Nunca cite a Bíblia de memória.
- `verseRef` de cada pergunta: um capítulo, até 2 versos.
- Toque: 3 opções de 1 a 3 palavras, todas presentes no versículo do palco.
- Ordenar da Observação (semente): peças copiadas do versículo, na ordem do texto.
- Completar: opções de 1 palavra (2 só em nome composto); a resposta é a palavra exata do versículo.
- Conectar: opções com até 6 palavras; `crossRefs[].bridge` até 6 palavras.
- Escolha: opções até 85 caracteres. `feedbackCorrect` até 110; `feedbackWrong` até 120; `hint` até 90 sem entregar a resposta.
- Respostas de Toque e Completar não se repetem na cena; peças de Ordenar não se repetem entre modos.
- V/F: afirmação completa, sem "?" e sem começar com "Como"; a falsa precisa ser plausível e de fato falsa pelo texto.
- `keyTerms[].term` aparece literalmente nos trechos de `study.passages`.

## Não fazer

- Na hora de gerar as cenas, não editar `trail.json`, `plano.json`, `inputs/`, `pedidos/` nem os scripts. (Mudou o plano? Rode de novo o `v3_plan_trail.mjs`, que refaz pedidos e pacotes.)
- Não escrever em `cenas/`, `questions_v3.json` ou `studies_v3.json` à mão (os scripts geram).
- Não publicar (`v3:publish`) nem rodar nada com `--apply`.


---

# Montar o plano de um livro (antes dos pedidos)

Cada livro vira uma trilha nova `<livro>-cap` na coleção AT/NT. A trilha antiga do livro (os pontos altos) vai depois para o Panorama; as cenas novas **não repetem** os trechos dela.

Modelo: `admin/v3/_modelo/plano.json`. Exemplos prontos: `admin/v3/mateus-cap/plano.json`, `lucas-cap`, `joao-cap`, `atos-cap` (e `marcos-cap/trail.json`).

## Passos

1. Copie o modelo para `admin/v3/<livro>-cap/plano.json` e preencha com a linha do livro na tabela abaixo (`slug`, `chapters`, `avoidTrails`, `realm`, `category`). `order`: o mesmo da trilha antiga do livro em `trilha_app/assets/data/trails.json`.
2. `prefix`: 2 ou 3 letras + `c`, único (já usados: `mcc`, `mtc`, `lcc`, `joc`, `atc`).
3. Escreva as cenas e confira, a partir de `admin/`:
   ```
   node scripts/v3_plan_trail.mjs --plan v3/<livro>-cap/plano.json --check
   ```
   Ele confere cada trecho na JFAAL e avisa capítulo sem cena e trecho que repete a trilha antiga. Corrija até não sobrar `✗` (avisos `!` só quando fizer sentido).
4. Gere a trilha e os pedidos (mesmo comando, sem `--check`). Revise o `PLANO.md` gerado. Depois siga a parte de cima deste roteiro.

## Regras do plano

- **Uma cena por capítulo**, em ordem. Capítulo fraco para cena (genealogia, censo, lista de nomes, leis rituais em série, medidas do templo, partilha da terra) entra junto do vizinho numa cena só, com `"chapters": "a–b"` para a conta de cobertura.
- **Trecho (`ref`)**: um capítulo, faixa contínua, **6 a 12 versos**, a passagem mais forte do capítulo que **não** esteja na trilha antiga. Verifique o texto (`node scripts/_jfaal.mjs "Romanos 3:21–26"`).
- **Etapas**: 4 a 6 cenas cada, por bloco natural do livro; uma Travessia por etapa. Nome da etapa: `"<tema> · cap. a–b"`.
- **Livros longos**: Salmos em etapas de ~10 salmos seguindo os 5 livros (1–41, 42–72, 73–89, 90–106, 107–150); Isaías, Jeremias, Ezequiel e afins em etapas de ~6 capítulos.
- **Textos**: `title` curto (até ~5 palavras); `intro` 1 ou 2 frases que situam sem entregar a ideia; `insight` uma ideia clara, até 140 caracteres; `objective` 2 a 5 palavras. Português simples, sem jargão ("tipologia", "escatológico"…). Nome de Deus como na JFAAL ("Senhor").
- **Trechos de manuscrito disputado** (Marcos 16:9–20, João 7:53–8:11, 1 João 5:7b): evite como trecho principal, ou use só se for a única opção do capítulo.
- Não toque nas trilhas antigas nem nos planos já feitos.

## Tabela dos livros

| Livro | Cap. | Trilha nova | avoidTrails | realm | category |
|---|---|---|---|---|---|
| Gênesis | 50 | `genesis-cap` | genesis-1-11, genesis-12-50 | antigo-testamento | pentateuco |
| Êxodo | 40 | `exodo-cap` | exodo | antigo-testamento | pentateuco |
| Levítico | 27 | `levitico-cap` | levitico | antigo-testamento | pentateuco |
| Números | 36 | `numeros-cap` | numeros | antigo-testamento | pentateuco |
| Deuteronômio | 34 | `deuteronomio-cap` | deuteronomio | antigo-testamento | pentateuco |
| Josué | 24 | `josue-cap` | josue | antigo-testamento | historicos-at |
| Juízes | 21 | `juizes-cap` | juizes | antigo-testamento | historicos-at |
| Rute | 4 | `rute-cap` | rute | antigo-testamento | historicos-at |
| 1 Samuel | 31 | `1samuel-cap` | samuel | antigo-testamento | historicos-at |
| 2 Samuel | 24 | `2samuel-cap` | samuel | antigo-testamento | historicos-at |
| 1 Reis | 22 | `1reis-cap` | reis | antigo-testamento | historicos-at |
| 2 Reis | 25 | `2reis-cap` | reis | antigo-testamento | historicos-at |
| 1 Crônicas | 29 | `1cronicas-cap` | cronicas | antigo-testamento | historicos-at |
| 2 Crônicas | 36 | `2cronicas-cap` | cronicas | antigo-testamento | historicos-at |
| Esdras | 10 | `esdras-cap` | esdras | antigo-testamento | historicos-at |
| Neemias | 13 | `neemias-cap` | neemias | antigo-testamento | historicos-at |
| Ester | 10 | `ester-cap` | ester | antigo-testamento | historicos-at |
| Jó | 42 | `jo-cap` | jo | antigo-testamento | poeticos |
| Salmos | 150 | `salmos-cap` | salmos | antigo-testamento | poeticos |
| Provérbios | 31 | `proverbios-cap` | proverbios | antigo-testamento | poeticos |
| Eclesiastes | 12 | `eclesiastes-cap` | eclesiastes | antigo-testamento | poeticos |
| Cânticos | 8 | `canticos-cap` | cantares | antigo-testamento | poeticos |
| Isaías | 66 | `isaias-cap` | isaias | antigo-testamento | profetas-maiores |
| Jeremias | 52 | `jeremias-cap` | jeremias | antigo-testamento | profetas-maiores |
| Lamentações | 5 | `lamentacoes-cap` | lamentacoes | antigo-testamento | profetas-maiores |
| Ezequiel | 48 | `ezequiel-cap` | ezequiel | antigo-testamento | profetas-maiores |
| Daniel | 12 | `daniel-cap` | daniel, periodo-intertestamentario | antigo-testamento | profetas-maiores |
| Oséias | 14 | `oseias-cap` | oseias | antigo-testamento | profetas-menores |
| Joel | 3 | `joel-cap` | joel | antigo-testamento | profetas-menores |
| Amós | 9 | `amos-cap` | amos | antigo-testamento | profetas-menores |
| Obadias | 1 | `obadias-cap` | obadias | antigo-testamento | profetas-menores |
| Jonas | 4 | `jonas-cap` | jonas | antigo-testamento | profetas-menores |
| Miquéias | 7 | `miqueias-cap` | miqueias | antigo-testamento | profetas-menores |
| Naum | 3 | `naum-cap` | naum | antigo-testamento | profetas-menores |
| Habacuque | 3 | `habacuque-cap` | habacuque | antigo-testamento | profetas-menores |
| Sofonias | 3 | `sofonias-cap` | sofonias | antigo-testamento | profetas-menores |
| Ageu | 2 | `ageu-cap` | ageu | antigo-testamento | profetas-menores |
| Zacarias | 14 | `zacarias-cap` | zacarias | antigo-testamento | profetas-menores |
| Malaquias | 4 | `malaquias-cap` | malaquias, periodo-intertestamentario | antigo-testamento | profetas-menores |
| Mateus (feito) | 28 | `mateus-cap` | evangelhos, mateus | novo-testamento | evangelhos |
| Marcos (feito) | 16 | `marcos-cap` | evangelhos, marcos | novo-testamento | evangelhos |
| Lucas (feito) | 24 | `lucas-cap` | evangelhos, lucas | novo-testamento | evangelhos |
| João (feito) | 21 | `joao-cap` | evangelhos, joao | novo-testamento | evangelhos |
| Atos (feito) | 28 | `atos-cap` | atos, cartas-paulo | novo-testamento | historicos-nt |
| Romanos | 16 | `romanos-cap` | romanos | novo-testamento | epistolas |
| 1 Coríntios | 16 | `1corintios-cap` | cartas-paulo, corintios | novo-testamento | epistolas |
| 2 Coríntios | 13 | `2corintios-cap` | corintios | novo-testamento | epistolas |
| Gálatas | 6 | `galatas-cap` | cartas-paulo, galatas | novo-testamento | epistolas |
| Efésios | 6 | `efesios-cap` | efesios | novo-testamento | epistolas |
| Filipenses | 4 | `filipenses-cap` | filipenses | novo-testamento | epistolas |
| Colossenses | 4 | `colossenses-cap` | colossenses | novo-testamento | epistolas |
| 1 Tessalonicenses | 5 | `1tessalonicenses-cap` | tessalonicenses | novo-testamento | epistolas |
| 2 Tessalonicenses | 3 | `2tessalonicenses-cap` | tessalonicenses | novo-testamento | epistolas |
| 1 Timóteo | 6 | `1timoteo-cap` | timoteo | novo-testamento | epistolas |
| 2 Timóteo | 4 | `2timoteo-cap` | timoteo | novo-testamento | epistolas |
| Tito | 3 | `tito-cap` | tito | novo-testamento | epistolas |
| Filemom | 1 | `filemom-cap` | filemom | novo-testamento | epistolas |
| Hebreus | 13 | `hebreus-cap` | hebreus | novo-testamento | epistolas |
| Tiago | 5 | `tiago-cap` | cartas-gerais, tiago | novo-testamento | epistolas |
| 1 Pedro | 5 | `1pedro-cap` | cartas-gerais, pedro | novo-testamento | epistolas |
| 2 Pedro | 3 | `2pedro-cap` | pedro | novo-testamento | epistolas |
| 1 João | 5 | `1joao-cap` | cartas-joao | novo-testamento | epistolas |
| 2 João | 1 | `2joao-cap` | cartas-joao | novo-testamento | epistolas |
| 3 João | 1 | `3joao-cap` | cartas-joao | novo-testamento | epistolas |
| Judas | 1 | `judas-cap` | judas | novo-testamento | epistolas |
| Apocalipse | 22 | `apocalipse-cap` | apocalipse | novo-testamento | apocalipse |
