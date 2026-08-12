# STWAY — Contrato de sessão (estilo Duo)

**Versão:** 1.0 · ago/2026  
**Status:** aprovado e implementado no piloto `gen-03-imagem`  
**Relaciona:** [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md) · [`PRODUTO.md`](PRODUTO.md) · [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md)

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
SESSÃO = 1 objetivo observável + 8–12 atos + 1 insight (no fim) + saída
Duração alvo: 2–3 min (teto 4)
```

- **Não é** mini-aula → quiz.  
- **Não é** 6 telas longas do mesmo tipo.  
- **É** sequência de micro-atos (5–15 s cada), quase sem prosa.

**Unidade emocional:** o usuário *faz* algo com o texto; o padrão aparece.  
O “uau” (= insight) só **depois** de ter evidência — nunca no preparo.

---

## 3. Anatomia da sessão

```text
[0] Entrada (≤ 5 s)
    título · modo (Semente/Rota/…) · verso âncora · 1 nota (contexto/curiosidade) · opcional 1 fio de conexão · CTA
    Foco: o que a Bíblia diz — não meta (“veja o que o treino ensina”).

[1…N] Atos (8–12)
    gesto → resposta → feedback curto (1–2 linhas) → próximo
    ~80% devem ser vencíveis na 1ª tentativa

[I] Insight (≤ 8 s)          ← obrigatório, 1× no fim
    1 frase “Hoje descobri que…”
    sem opções · só “Seguir”

[S] Saída
    passos + streak · (opcional) 1 micro bônus
```

**Proibido na sessão Rota**

- Preparo longo / glossário **antes** dos atos  
- Opções com 2+ linhas densas  
- Mesmo gesto 4× seguidas  
- Pergunta meta (“o que este treino quer”)  
- Jargão (tipologia, conexão temática, imago Dei)

---

## 4. Gestos permitidos (variar; não inventar UI por passagem)

Mínimo **3 gestos distintos** por sessão. Máximo **5**.

| Gesto | O usuário… | Bom para |
|-------|------------|----------|
| **Tocar** | toca palavra/frase no versículo | observar |
| **Escolher** | 2–4 opções de **uma linha** | distinguir |
| **Ordenar** | ordena 3–4 peças | estrutura / sequência |
| **Completar** | preenche 1 lacuna | recuperar |
| **Emparelhar** | liga A↔B (até 3 pares) | conectar leve |
| **V/F** | um toque | hipótese rápida (máx. 1–2×) |

**Regra:** se a ideia cabe num gesto existente, usar. Novo gesto só se for recorrente em muitas trilhas.

MCQ clássico (A/B/C/D) ≤ **40%** dos atos da sessão.

---

## 5. Quando entra o texto

| Momento | Texto |
|---------|--------|
| Antes dos atos | **Não** (exceto 1 linha na entrada) |
| Durante atos de observar/conectar | Trecho **curto** na mesma tela (≤ ~40 palavras ou 2 versos) |
| No insight | Opcional: 1 meio-verso âncora |

Leitura passiva de parágrafo inteiro **não** conta como ato.

### 5.1 UI do ato (padrão replicável)

Mesmo esqueleto em **todo** gesto — não inventar layout por passagem.

```text
VERBO          Observe · Escolha · Complete · Ordene · Conecte · Decida
pergunta       1 linha · display 24 · sempre à esquerda
nota?          fio + label + corpo 13 (some em revisão)
manuscrito?    versículo / afirmação / lacuna — um palco só
botões         badge + texto · raio 16 · gap 8  (nunca pill solto)
footer         lâmpadas · dica · Confirmar (só se o gesto precisa)
```

| Peça | Token | Obrigatório |
|------|--------|-------------|
| Manuscrito | `_Manuscript` · verso 22 | se há texto bíblico ou lacuna |
| Marca no texto | wash + sublinhado (`_VerseMark`) | Toque, Completar, Conectar |
| Botão | `_OptionTile` (A/B/C/D ou nº) | Escolher, Completar, V/F, Ordenar |
| Completar | lacuna **no** versículo + os **mesmos** botões A/B/C | não usar chip/pill |
| Toque | só no verso; sem “não está no trecho” | distrator tem de estar no texto |
| Insight | **depois** dos atos (e micro/anotar) · não conta no N/N | 1× no fim |

Beat (`Hipótese`, `Freio`…) fica no CMS — **não** na UI.

---

## 6. Quando aparece o insight

1. Só **depois** de ≥ 1 ato de observação com acerto.  
2. Preferência: **último beat** da sessão (card, sem quiz).  
3. Formato fixo:

> **Hoje:** \[frase de ≤ 140 caracteres\]

4. Essa frase = `centralInsight` do treino (única).  
5. Se o usuário não consegue resumir o treino nessa frase, o conteúdo está errado — não a UI.

---

## 7. Quando entra o review (retenção de conhecimento)

| Tipo | Quando | O quê |
|------|--------|--------|
| **Micro-review in-session** | 1–2 atos no fim, se errou algo | mesmo conceito, **outro gesto** |
| **Boss / revisão de cena** | fim do módulo | mistura atos de treinos anteriores |
| **Spaced (produto)** | D+1…D+7 (prática / quest) | reaparecer “imagem” em outro contexto (ex.: Cl 1) |

Regra de ouro do Duo: **mesmo conhecimento, formato novo**.  
Repetir a mesma MCQ ≠ review.

---

## 8. Dificuldade e vidas

- Alvo de sessão: **~80% de acertos** na 1ª tentativa (média populacional).  
- Lâmpadas = continuar treinando (já existe).  
- Erro → motivo em 1 linha + **mesma ideia**, gesto mais fácil ou dica — não parágrafo.  
- Não premiar velocidade pura; não punir pensamento com timer agressivo no MVP.

---

## 9. Métricas da sessão (o que “bom” significa)

Uma sessão passa se:

1. Conclusão ≥ meta de produto (habit)  
2. Tempo mediano 2–3 min  
3. Taxa de acerto 1ª tentativa ~70–85%  
4. Em D+2, amostra responde a pergunta-âncora **sem** ver o treino  
5. Usuário **não** descreve o app como “perguntas e respostas” em interview

Pergunta-âncora deste piloto (Imagem de Deus):

> Quem Gênesis 1:27 diz ter sido criado à imagem de Deus?

---

## 10. Exemplo seco — `gen-03-imagem` (só o esqueleto)

*Só para ilustrar o contrato — copy final depois da aprovação.*

| # | Gesto | Ato (ideia) |
|---|-------|-------------|
| 1 | V/F | Hipótese rápida sem texto |
| 2 | Tocar | No versículo, toque quem recebe a imagem |
| 3 | Escolher | 1 linha: o que mais o texto liga à imagem? |
| 4 | Ordenar | criado → imagem → cuidado (3 peças) |
| 5 | Escolher | O que o texto **não** diz (freio curto) |
| 6 | Emparelhar ou tocar | Gn ‖ Cl — a palavra que une |
| 7 | Completar | “à imagem de Deus… ___ e ___” |
| 8 | (se erro) | mesmo fato, gesto mais fácil |
| I | Insight | card 1 frase |
| S | Saída | passos / streak |

8 atos + insight ≠ 6 ensaios.

---

## 11. Decisão

- [x] **Aprovar** este contrato → piloto Imagem de Deus implementado  
- [ ] **Aprovar com cortes**  
- [ ] **Rejeitar**

Player: `ExercisePanel` + `PilotTrainings` + branch em `LessonScreen`.  
Gestos no MVP: V/F · toque · escolha · ordenar · completar · insight (+ review condicional).  
`match` existe no modelo; piloto usa toque para a ponte Gn‖Cl.
