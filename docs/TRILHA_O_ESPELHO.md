# Trilha "O Espelho" (Gênesis ↔ Apocalipse) — engatilhada, pós-lançamento

Status: **planejada, não construir antes do lançamento do app** (decisão 2026-11-06).

Origem: reel "A Bíblia termina onde começou" (arcos de referências cruzadas, 63.779 ligações — Harrison & Römhild 2007). O vídeo mostra só as pontas (Gn ↔ Ap); o valor pedagógico está no **elo do meio** (Lv, Is, Ez, Zc) e na leitura de que o fim **supera** o Éden (jardim → cidade, árvore guardada → aberta às nações, Deus que visita → Deus que habita).

## Formato

- 1 trilha, slug `o-espelho`, prateleira Temas (ao lado de A Promessa).
- 4 blocos × 3 cenas + 1 Travessia = 13 cenas.
- Cenas **novas** (não emprestadas): o banco do Apocalipse só tem Ap 21:1–7 (`apo-03-novo`), nada de Ap 22.
- Palco: 2 trechos por cena (Gn + Ap), texto JFAAL. Verificar se cena normal renderiza 2 `ranges` (Travessia já usa).
- Elo do meio entra em Compreensão/Interpretação (connect/choice).

## Pares

| # | Cena | Gênesis | Apocalipse | Elo do meio |
|---|---|---|---|---|
| | **Bloco 1 — A criação refeita** | | | |
| 1 | Céus e terra | 1:1 | 21:1 | Is 65:17 |
| 2 | A luz | 1:3 | 21:23 | Is 60:19 |
| 3 | Reinar | 1:28 | 22:5 | Dn 7:27 |
| | **Bloco 2 — O jardim vira cidade** | | | |
| 4 | O rio | 2:10 | 22:1 | Ez 47:1 |
| 5 | Ouro e pedras | 2:12 | 21:18 | Is 54:11–12 |
| 6 | A noiva | 2:22 | 21:2 | Ef 5:31–32 |
| | **Bloco 3 — O que a queda tirou** | | | |
| 7 | A serpente | 3:15 | 20:2 | Rm 16:20 |
| 8 | A maldição | 3:17 | 22:3 | Zc 14:11 |
| 9 | Morte e dor | 3:19 | 21:4 | Is 25:8 |
| | **Bloco 4 — Deus volta a morar** | | | |
| 10 | A árvore da vida | 2:9 | 22:2 | Ez 47:12 |
| 11 | As portas | 3:24 | 21:25 | Is 60:11 |
| 12 | Deus com o homem | 3:8 | 21:3 | Lv 26:12 (mesmo verbo "andar" de Gn 3:8) |
| 13 | Travessia — O Espelho inteiro | mistura | + 22:4 "verão a sua face" | |

Notas:
- Cena 10 usa Ap 22:2, não 22:14: a JFAAL traz em 22:14 "lavam suas vestiduras **no sangue do Cordeiro**" (leitura mista); ACF/ARC leem "guardam os seus mandamentos".
- Pares de reserva: servir (Gn 2:15 'abad ↔ Ap 22:3b), mar/abismo (Gn 1:2 ↔ Ap 21:1b), cidade como Santo dos Santos (Ap 21:16 ↔ 1Rs 6:20).

## Volume

- 12 cenas × 18 (6 gestos × 3 modos, formato V3) = 216
- Travessia 8 × 3 modos = 24
- **Total 240 perguntas pt-BR** + 13 estudos (frase Hoje, intro, facts). EN/ES depois da revisão.
- Pipeline: `admin/v3/o-espelho/` (inputs → cenas → shuffle → validate → merge → publish).

## Exemplos (cena 12)

**Observação — find_in_text:** "Em Gênesis 3:8, toque o que Adão e sua mulher fizeram diante de Deus." Opções: ouviram · andava · **esconderam**.

**Compreensão — choice:** "O que muda de Gênesis 3:8 para Apocalipse 21:3?"
a) **O homem fugia da presença; agora Deus habita com ele** · b) O homem volta a morar no jardim do Éden · c) Deus passa a visitar o homem só à tarde · d) Só alguns escolhidos verão Deus.

**Interpretação — connect:** A = Lv 26:12 "Andarei entre vocês, serei o vosso Deus, e vocês serão o meu povo." B = Contexto: Gn 3:8 Deus andava no jardim; Ap 21:3 Ele habita com os homens. Opções: **A presença perdida volta no meio do povo** · Regras de pureza do acampamento · Promessa de boa colheita.

## Decisões pendentes (perguntar antes de construir)

1. Gesto Ponte: usar como está ou redesenhar antes (trilha depende dele; usuário achou fraco em 2026-10-21).
2. Aprovar/trocar os 12 pares.
3. Plus (1ª cena amostra) ou grátis.
4. Nome final.
