# STWAY — linguagem única (UI + texto)

Regra geral: **use o componente; nunca refaça à mão.** Se o componente não
cobre o caso, estenda o componente (novo parâmetro), não copie o visual.

## Tipografia

`AppTypography` arredonda para a escala. Peça só tamanhos que existem:

| Estilo | Escala |
|---|---|
| display | 18 · 20 · 24 · 28 · 32 · 40 · 48 |
| title | 12 · 14 · 16 · 18 · 20 · 24 |
| body | 11 · 12 · 13 · 14 · 16 |
| label | 10 · 11 · 12 · 13 |

| Papel | Estilo |
|---|---|
| Título de tela | `TopBar` (display 20) |
| Herói de tela / celebração | display 28 (recompensa: 24) |
| Título de sheet | `AppSheetHeader` (title 20; celebração display 28) |
| Título de seção (grupo de cards no perfil) | `RelicChapter` (barra 3×18 + title 16) |
| Título de card | `RelicChapter(divided: false)` — traço na cor do card + title 16; sem ícone |
| Título de row de lista | title 14 · legenda body 12 |
| Eyebrow / rótulo pequeno em maiúsculas | `SectionLabel` (label 11) — string em caixa normal |
| Texto corrido | body 14 (denso: 13) |
| Botão | `CopperCta` / `GhostCta` / `TextCta` |

Pesos: title usa o padrão (w800) — não repita `weight: FontWeight.w800`.
w900 só em display e números de HUD.

## Cores de texto (`Appearance.of(context)`)

- `a.text` — principal
- `a.textSecondary` — legenda, apoio, subtítulo
- `a.textFaint` — dica, rodapé, futuro/desativado
- `a.sectionLabel` — eyebrows

Não use `Colors.white.withValues(...)` nem `a.textMuted(0.xx)` com alphas
soltos em código novo.

Superfícies: `a.cardFill`, `a.cardFillSoft`, `a.cardBorder`, `a.divider`,
`a.insetFill`, `a.insetBorder`.

## Containers

| Papel | Componente |
|---|---|
| Card | `GlassCard` (padding `AppMetrics.cardPadding`, raio `AppMetrics.cardRadius`) |
| Card de perfil / relíquia | `RelicPanel` |
| Poço dentro de card | `InsetPanel` |
| Sheet | `showAppSheet` + `AppSheetPanel` + `AppSheetHeader` |
| Divisória de row | `ListDivider` (`indent: ListDivider.iconIndent` com ícone) |
| Filete decorativo | `RelicHairline` |

Raios: card = `AppMetrics.cardRadius`; herói = `AppMetrics.heroRadius`;
chip/badge = `AppRadii.sm`; seleção = `AppRadii.pill`.

## Ícones

- Sempre `CinematicIcon` (glifos da marca). Material `Icons.*` só onde não
  existe glifo (logo Apple, drag handle, olho, rádio).
- Ícone à esquerda de row: `CinematicIcon(framed: true)` em
  `AppMetrics.leadingIcon` (40). `RelicDisc` só para relíquia/medalha/recorde.
- Seta de row: `ListChevron` no tamanho padrão (18). `CinematicGlyph.forward`
  só dentro de CTA. Nunca "→" / "←" no texto.
- Sem emoji na interface (só em texto de compartilhamento).

## Badges, chips, progresso, estados

| Papel | Componente |
|---|---|
| Status | `SoftBadge` |
| Número | `CountBadge` |
| Escolha | `AppSelectChip` |
| Barra de progresso | `AppProgressBar` (16 padrão, 6 compacto); filete: `RelicProgress` |
| Ponto de novidade | `AlertDot` |
| Carregando | `AppSpinner` (`inline: true` em botão/linha) |
| Vazio | `EmptyState` |

## Botões

- Principal: `CopperCta`. Secundário: `GhostCta`. Terciário: `TextCta`.
- Ação de risco (sair, desistir, encerrar): `TextCta(danger: true)` ou
  `GhostCta(danger: true)`.
- Os botões já vibram (`ActHaptics`) — não chame `HapticFeedback` junto.
  Em toque custom use `ActHaptics.tap/light/confirm`, não `HapticFeedback`.

## Glossário

| Conceito | Termo | Não usar |
|---|---|---|
| Unidade de estudo | **cena** | missão, lição |
| Pontos | **passos** ("+40 passos") | pontos, XP; "passo" como sinônimo de cena |
| Curso | **trilha** | — |
| Progresso geral | **jornada** | — |
| Dias seguidos | **sequência** | constância, dias seguidos |
| Liga semanal | **caravana** | liga, divisão |
| Par 1:1 | **companhia**; a pessoa é **companheiro(a)** | dupla, parceria, par |
| Grupo de estudo | **grupo** | sala |
| Peer challenge (mesma cena até domingo) | **desafio** | esquina, PvP, disputa |
| Boss / revisão de módulo | **travessia** (shipped na UI; títulos de conteúdo ainda podem dizer “Desafio: …”) | reusar “desafio” sozinho |
| Desafio litúrgico | **desafio da estação** | só “desafio” |
| Estação litúrgica (Advento/Quaresma) | **estação** / nome da campanha | caminhada (colide com id do modo) |
| Histórico semanal no perfil | **lamparina** / jarro | lâmpada (vidas) |
| Gesto social | **reconhecer** | curtir |
| Lembrar quem já está (companhia, grupo) | **acenar / aceno** ("Acenar para Ana") | chamar, animar |
| Trazer alguém novo (convite) | **chamar** ("Chamar pessoas", "Chamar um companheiro") | — |
| Lembrete do app no horário | **lembrar** ("Lembrar às 20h") | chamar |
| Slogan | **A Bíblia, cena a cena** | — |
| Recompensa | **medalha**; **selo** só para selos de personagem | conquista |
| Texto bíblico | **Bíblia** (produto, leitura); **Palavra** em frase devocional; **Escrituras** (plural) em estudo | — |
| Vidas | **lâmpada** | — |

## Tom

1. Fale com **você**. Imperativo na forma de você: "Faça", "Continue",
   "Chame", "Mande". "te" como objeto é ok. Nunca "Faz", "Segue", "Chama",
   "Manda" na voz do app.
2. **para**, não "pra". Gíria ("pra", "tô", "vem?") só em mensagem que um
   amigo manda para o outro.
3. Frase com inicial maiúscula só na primeira palavra ("Baú do dia",
   "Cofre da jornada"). Maiúsculas só em nome próprio.
4. Nunca escreva string em CAIXA ALTA — use `SectionLabel` (ou `FilmEyebrow`, que também caixa-alta sozinho).
5. No máximo um "!" por tela, só em celebração real.
6. Rótulos de botão:
   - fechar sheet de leitura: **Fechar**
   - confirmar aviso / celebração: **Entendi**
   - recusar convite: **Agora não**
   - cancelar em confirmação: **Cancelar**
   - avançar: **Continuar**
   - repetir: **Tentar de novo**
7. Reticências: "…" (um caractere).
