# Calibração de medalhas v3.3

**Vigente no app** (3 nov/2026). Arquitetura: [`MEDALHAS.md`](MEDALHAS.md).

Faísca acende o emblema **sem sheet**. Conquista (prata+) é moeda que **não some** e abre celebração. Palavra no cofre mede hábito de capítulos, não catálogo de livros.

Primeiro gesto real em ~1 semana (faísca). Próximo passo visível (~20% restantes). Uma linha na celebração se o ato moveu a escada.

## Escadas da jornada

Base comum: **Bronze → Prata → Ouro**. Platina e diamante ficam para marcos futuros.

### Palavra (`track:word`)
Medalha mede hábito de leitura (capítulos). Livro concluído não vira medalha.

| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 3 capítulos |
| Conquista | Prata | 25 capítulos |
| Conquista | Ouro | 100 capítulos |

### Formação (`track:formation`)
| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 3 cenas perfeitas |
| Conquista | Prata | 10 cenas perfeitas |
| Conquista | Ouro | 25 cenas perfeitas |

### Caminho (`track:path`)
| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 7 dias |
| Conquista | Prata | 14 dias |
| Conquista | Ouro | 30 dias |

### Testemunho (`track:witness`)
| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 3 compartilhamentos |
| Conquista | Prata | 10 |
| Conquista | Ouro | 50 |

### Memória (`track:memory`)
| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 3 versículos |
| Conquista | Prata | 15 |
| Conquista | Ouro | 50 |

## Trilha (por slug)
| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 1 missão |
| Conquista | Prata | Modo Observação |
| Conquista | Ouro | Modo Compreensão |
| Conquista | Diamante | Trilha + Interpretação |

## Advento 2026 (`season:advento-2026`)
Visível de 29 nov a 24 dez 2026 (+ 7 dias de graça). Depois só se houver progresso.

| Papel | Material | Marco |
|-------|----------|-------|
| Faísca | Bronze | 1 dia na janela |
| Conquista | Prata | 7 dias |
| Conquista | Ouro | metade dos dias (~13) |
| Conquista | Diamante | 22 dias |

Rara: 7 dias seguidos no Advento.

## Raras (Mirra / Aurora)
| ID | Título | Marco |
|----|--------|-------|
| `discovery:founder` | **Desbravador** | `users/{uid}.desbravador` (testou antes do lançamento) — **sem sheet** |
| `discovery:comeback` | Volta firme | Retorno após 21+ dias |
| `discovery:bible_before` | Palavra antes | Capítulo no mesmo dia, antes da missão |
| `discovery:andando_na_luz` | Andando na luz | 85%+ em 50+ questões |
| `discovery:perfect_boss` | Prova impecável | Boss 100% |
| `discovery:leader` | Líder da caravana | 1 dia em 1º |
| `discovery:accuracy_elite` | Mira certeira | 95%+ em 150+ |
| `discovery:trail_flawless` | Trilha impecável | Trilha inteira 100% |
| `discovery:reflection_deep` | Diário profundo | 40 reflexões |

AT/NT e “livro completo” **não** são medalhas.

**Pioneiro** no perfil = selo do plano Plus de lançamento (`plus_founder_annual`), não esta medalha.

## Princípios
1. Prefixo consecutivo — nunca pintar ouro sem a faísca.
2. Um emblema por família (e um por trilha). O emblema **evolui**; não há álbum de moedas do mesmo eixo.
3. Sheet ao tocar: um emblema + escada Bronze/Prata/Ouro. Celebração: só degrau de conquista (prata+) — faísca da jornada é silenciosa. Trilha e temporada (porta do Advento) ainda abrem a folha no 1º degrau.
4. Near-miss no ponto da ação: uma linha no Hoje e no mapa se faltam ≤3. Celebração: uma linha, não card.
5. Desbravador silencioso (marca de servidor). Surpresa no fluxo real: Palavra antes da missão.
6. Medalha não coleciona título bíblico. Palavra mede capítulos.
