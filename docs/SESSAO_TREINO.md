# STWAY — Contrato de sessão (modo único)

**Versão:** 1.2 · ago/2026  
**Status:** padrão oficial do produto · **implementado no app**  
**Relaciona:** [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md) · [`PRODUTO.md`](PRODUTO.md) · [`TECNICA.md`](TECNICA.md)

---

## 0. Modo único

Não existem dois players (legado vs v2).

```text
TODO TREINO = UMA SESSÃO
  entrada → atos (vários gestos) → insight → saída
```

O banco MCQ **não** é um modo — é o gesto **Escolher** (`choice`), montado pelo composer a partir de `content_bank_questions`.

**Estado (ago/2026):** `LessonScreen` + `SessionComposer` + `ExercisePanel` seguem este contrato. Conteúdo canônico no Firestore; JSON local só para seed/edição.

---

## 1. Duas retenções (não misturar)

| Métrica | Significa | Como a sessão serve |
|---------|-----------|---------------------|
| **Hábito** | Volta em 24h | Sessão ≤ 3 min, ~80% acerto, streak |
| **Conhecimento** | Lembra em D+2 / outra passagem | Retrieval + **gesto diferente** + review espaçado |

Streak sem review = hábito oco.  
Insight sem ato curto = sermão.

---

## 2. O que é uma sessão

```text
SESSÃO = 1 objetivo observável + 5–12 atos + 1 insight (no fim) + saída
Duração alvo: 2–3 min (teto 4)
Padrão: 7–9 atos · simples 5–6 · denso 10–12
```

- **Não é** mini-aula → quiz.  
- **Não é** 6 telas longas do mesmo tipo.  
- **É** sequência de micro-atos (5–15 s cada), quase sem prosa.

**Unidade emocional:** o usuário *faz* algo com o texto; o padrão aparece.  
O “uau” (= insight) só **depois** de ter evidência — nunca no preparo.

---

## 3. Anatomia da sessão

### 3.0 Entrada (1×, ≤ 5 s)

```text
Título do treino
Verso âncora (ref + texto curto)
Contexto OU conexão (1 bloco, ≤2 linhas)
[ Começar ]
```

- Sem quiz. Sem spoiler do insight.  
- Contexto **ou** conexão — não os dois longos.  
- Foco: o que a Bíblia diz — não meta (“veja o que o treino ensina”).

### 3.1 Atos (N×)

```text
gesto → resposta → feedback curto (1 linha) → próximo
~80% vencíveis na 1ª tentativa
```

Abrir com **V/F ou Toque**, não com quiz A/B/C/D.  
`Escolher` no meio · ≤ ~40% dos atos.

### 3.2 Insight (1×, ≤ 8 s)

```text
Hoje:
[ frase ≤140 caracteres ]
[ Seguir ]
```

Obrigatório · sem opções · não conta no N/N.

### 3.3 Saída

```text
Passos · streak · (opcional) 1 micro bônus
```

### Proibido

- Preparo longo / glossário **antes** dos atos  
- Opções com 2+ linhas densas  
- Mesmo gesto 4× seguidas  
- Pergunta meta (“o que este treino quer”)  
- Jargão na UI (tipologia, imago Dei…)  
- Inventar layout por passagem

---

## 4. Gestos permitidos

Mínimo **3 gestos distintos** por sessão (quando houver conteúdo autorado). Máximo **5**.

| Gesto | Verbo UI | O usuário… | Bom para |
|-------|----------|------------|----------|
| **V/F** | Decida | um toque | hipótese rápida (máx. 1–2×) |
| **Tocar** | Observe | toca palavra/frase no versículo | observar |
| **Escolher** | Escolha | 2–4 opções de **uma linha** | distinguir (+ banco legado) |
| **Ordenar** | Ordene | ordena 3–4 peças | estrutura / sequência |
| **Completar** | Complete | preenche 1 lacuna | recuperar |
| **Conectar / Emparelhar** | Conecte | liga A↔B ou ponte entre textos | conectar leve |

**Regra:** se a ideia cabe num gesto existente, usar. Novo gesto só se for recorrente em muitas trilhas.

MCQ clássico (`Escolher`) ≤ **40%** dos atos quando a sessão tem gestos mistos.  
O banco (`*_questions.json`) carrega `type` por pergunta. O composer monta 1 de cada gesto e preenche até 7–9 atos (2º Escolher no meio, ≤ 40%).

---

## 5. Texto na sessão

| Momento | Texto |
|---------|--------|
| Entrada | Verso curto + 1 nota (contexto **ou** conexão) |
| Durante atos | Trecho **curto** no palco (≤ ~40 palavras ou 2 versos) |
| Insight | Opcional: 1 meio-verso âncora |

Leitura passiva de parágrafo inteiro **não** conta como ato.

---

## 5.1 UI do ato — esqueleto único

Mesmo esqueleto em **todo** gesto. Só **Palco + Ação** mudam.

```text
[ 3/8 ]

VERBO                         ← Observe · Escolha · Decida · Ordene · Complete · Conecte
PERGUNTA                      ← 1 linha (omitir se o palco já é a pergunta)

nota?                         ← opcional · ≤2 linhas · some em review

┌──────────────────────────┐
│         PALCO            │  ← afirmação | verso | lacuna | 2 trechos | — 
└──────────────────────────┘

AÇÃO                          ← botões / toque / drag

💡💡💡    Dica?    Confirmar? ← Confirmar só se o gesto exige (ordenar)
```

**Pós-resposta (mesmo fluxo):**

```text
Feedback · 1 linha
[ Continuar ]
```

### Campos (vocabulário fechado)

| Campo | Sempre? | Limite | Não é |
|-------|---------|--------|--------|
| **Verbo** | Sim | 1 palavra da lista | Beat pedagógico (“Hipótese”) |
| **Pergunta** | Quase | ≤80 chars · 1 linha | Mini-aula |
| **Nota** | Não | ≤120 chars · ≤2 linhas | Resposta disfarçada |
| **Palco** | Quase | ≤~40 palavras / 2 versos | Parágrafo de estudo |
| **Ação** | Sim | — | Segunda UI inventada |
| **Feedback** | Sim pós-resposta | ≤100 chars | Novo conteúdo longo |

### Mapa gesto → preenchimento

| Gesto | Verbo | Pergunta | Palco | Ação |
|-------|-------|----------|-------|------|
| V/F | Decida | opcional | afirmação | V / F |
| Toque | Observe | “Quem/o quê…?” | versículo | toque no trecho |
| Escolher | Escolha | 1 linha | verso curto? | A/B/C/D (1 linha) |
| Completar | Complete | opcional | verso com `___` | opções A/B/C |
| Ordenar | Ordene | “Monte a sequência” | — | 3–4 peças |
| Conectar | Conecte | “O que une…?” | 2 trechos | toque / ligar |
| Insight | — | — | frase “Hoje:” | Seguir |

### Tokens de UI

| Peça | Token | Obrigatório |
|------|--------|-------------|
| Manuscrito / palco | `_Manuscript` · verso 22 | se há texto bíblico, afirmação ou lacuna |
| Marca no texto | wash + sublinhado (`_VerseMark`) | Toque, Completar, Conectar |
| Botão | `_OptionTile` (A/B/C/D ou nº) · raio 16 · gap 8 | Escolher, Completar, V/F, Ordenar |
| Completar | lacuna **no** versículo + botões A/B/C | não usar chip/pill |
| Toque | só no verso; distrator no texto | sem “não está no trecho” |
| Insight | depois dos atos · não conta no N/N | 1× no fim |

Beat (`Hipótese`, `Freio`…) fica no CMS — **não** na UI.

### Tradução mental (copy antigo → novo)

| Antes | Agora |
|-------|--------|
| title | **Verbo** (ou some) |
| subtitle | **Pergunta** |
| explicação | **Nota** (antes) + **Feedback** (depois) — curtos |
| ação | **Palco + Ação** |

---

## 6. Quando aparece o insight

1. Só **depois** dos atos (e review, se houver).  
2. Formato fixo: **Hoje:** \[frase ≤ 140 caracteres\]  
3. Essa frase = `centralInsight` do treino (única).  
4. Se o usuário não resume o treino nessa frase, o conteúdo está errado — não a UI.

---

## 7. Review (retenção de conhecimento)

| Tipo | Quando | O quê |
|------|--------|--------|
| **Micro-review in-session** | 1–2 atos no fim, se errou algo | mesmo conceito, **outro gesto**, sem Nota |
| **Boss / revisão de cena** | fim do módulo | mistura atos de treinos anteriores |
| **Spaced (produto)** | D+1…D+7 (prática / quest) | mesmo fato em outro contexto |

Regra de ouro: **mesmo conhecimento, formato novo**.  
Repetir a mesma MCQ ≠ review.

---

## 8. Dificuldade e vidas

Semente / Rota / Profundezas = **perfil de operações** sobre o mesmo shell — não players diferentes.

- Alvo: **~80%** de acertos na 1ª tentativa.  
- Lâmpadas = continuar treinando.  
- Erro → motivo em 1 linha + mesma ideia (gesto mais fácil ou dica).  
- Sem timer agressivo no MVP.

---

## 9. Composer (app)

Fonte canônica: **banco** (`content_bank_questions`), tipado. Sem prioridade de `mission.exercises` embutidos.

```text
1. bank questions (type + skill) → Exercise
2. senão mission.questions → Exercise(type: choice)   # fallback raro
3. insight de centralInsight
4. review condicional se errou (outro gesto)
```

Política da sessão (código: `ProgressService` + `SessionComposer`):

- Normal **8** atos · boss **10** · clamp 5–12
- 1 de cada gesto primeiro; **2º Escolher** se o pool tiver (≤ **40%**)
- V/F ≤ 2 · nunca o mesmo gesto 4× seguidas
- Entrada: verso ≤ ~40 palavras + contexto **ou** conexão (um bloco)
- `skill` do banco preservada; senão inferida do tipo

Sempre o mesmo player (`ExercisePanel`). Sem branch de quiz legado.

---

## 10. Métricas

Uma sessão passa se:

1. Conclusão ≥ meta de produto (habit)  
2. Tempo mediano 2–3 min  
3. Taxa de acerto 1ª tentativa ~70–85%  
4. Em D+2, amostra responde pergunta-âncora **sem** ver o treino  
5. Usuário **não** descreve o app como “perguntas e respostas”

Pergunta-âncora do piloto (Imagem de Deus):

> Quem Gênesis 1:27 diz ter sido criado à imagem de Deus?

---

## 11. Ordem típica (Rota)

```text
V/F ou Toque → misturar gestos → Escolher no meio
→ Completar / Ordenar → (review se errou) → Insight → Saída
```

---

## 12. Exemplo — `gen-03-imagem`

Treino **padrão** da trilha (não conteúdo especial). O composer monta ~8 atos a partir do banco da seção `gen-03-imagem`.

| Fase | O quê |
|------|--------|
| Entrada | verso curto + nota (contexto ou conexão) |
| Atos | mix V/F · toque · escolher · ordenar · completar · conectar |
| Review | se errou: 1 ato extra, outro gesto |
| Insight | `centralInsight` da missão |
| Saída | passos / streak |

Nota: [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md) (referência histórica).

---

## 13. Decisão

- [x] Contrato aprovado (v1.0 piloto)  
- [x] Anatomia de tela refinada (v1.1)  
- [x] Modo único + composer no app (v1.2)  
- [x] Catálogo Firestore alinhado ao contrato (seed ago/2026)

Player: `SessionComposer` → `ExercisePanel` · shell em `LessonScreen`.  
Gestos MVP: V/F · toque · escolha · ordenar · completar · conectar · insight (+ review).

**Ainda editorial (não código):** profundezas com operações reais (não clone de Semente); prova D7 com testers.

**Código (já feito):** Strong no fluxo do treino (toque na ref do palco → sheet Estudar) e na aba Bíblia.
