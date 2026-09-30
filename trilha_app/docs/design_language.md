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

## Cores por papel (`AppRoles`)

Tela pede o **papel**, nunca o tom. `AppColors.clay`, `.cedar`, `.sand`…
são matéria-prima do tema, não se usam direto em tela nova.

| Papel | Token | Onde |
|---|---|---|
| Ação principal | `AppRoles.action` (ouro `#F7BB01`) | `CopperCta`, o que avança |
| Recompensa | `AppRoles.reward` (ouro) | passos, medalha, baú, meta cumprida |
| Chrome | `AppRoles.chrome` (neutro) | nav, TopBar, ícone de aba — **igual em todas as abas** |
| Seleção (cena) | fill branco + rim ouro | opção tocada, ainda não confirmada |
| Idle (cena) | `nightElevated` + texto claro | placas de resposta no céu escuro |
| Acerto na cena | `AppRoles.action` (ouro) | placa, veredito, barra, flash |
| Sucesso / presença (home) | `AppRoles.presence` (glow) | orbs da semana, "estudou hoje" |
| Lâmpadas (vidas) | `AppRoles.reward` (ouro) | acesas = luz |
| Sequência | `AppRoles.streak` (âmbar) | **só** a chama |
| Risco / erro | `AppRoles.error` | único vermelho |

Regras (gesto):
- Idle = poço escuro · Seleção = branco · Acerto = ouro · Erro = vermelho.
- Sem azul/glow nos gestos (glow fica na home).
- Cor do modo só no mapa / seletor.
- Um CTA: `CopperCta` ouro.
- A cena é o único lugar com placas claras (respostas em marfim — o "palco").
- Cenário de tela cheia (céu pintado, Gênesis, trilha da marca, confete) só em
  splash, onboarding e celebração. No resto, o gradiente da fase do dia; cenário
  só dentro de card herói.
- Um botão principal: `CopperCta` (`large` no herói; `decorative` quando o card
  inteiro é o toque). Não desenhe CTA à mão.
- Um card: `GlassCard` (`tint` para um papel, `glow` para palco). Não monte
  card com `Container` + `BoxDecoration`.

- Um segmentado: `AppSegmentedTabs` (glifo opcional). Chips soltos: `AppSelectChip`.
- Um avatar: `UserAvatar` com raio `AppMetrics.avatarSm` (16) · `avatarMd` (20)
  · `avatarLg` (30); retrato de identidade só `avatarXl` (40, cartão do
  peregrino) e `avatarHero` (52, herói do perfil). "Você" na lista: fundo `AppRoles.selected` a 0.08 + borda 0.4.
- Ícone solto: `AppMetrics.iconSm` 16 · `iconMd` 20 · `iconLg` 24 · `iconHero` 56;
  com poço: `leadingIcon` 40; chip: `chipIcon` 14.
- Erro inline: `InlineNotice` (card próprio; `standalone: false` dentro de
  outro card; `onRetry` mostra "Tentar de novo"). Nunca texto vermelho solto.
- Seleção sobre placa clara (respostas da cena): fill `AppRoles.action`
  (ouro do Verificar). Contorno `selectedOnLight` é legado.
- Título de seção/card: `RelicChapter` (ou `SectionLabel` para eyebrow). Sem
  marcas próprias por tela.
- Barra de progresso: `AppProgressBar` (6 compacto / 16 padrão). `RelicProgress`
  só como filete decorativo, nunca para o mesmo dado que outra tela mostra em barra.

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

## Mundo central: o caminho

O app tem **uma** imagem de fundo: a pessoa caminha uma trilha, cena a cena,
e cada acerto são passos. Companhia, caravana e grupo caminham junto.
Tudo o mais é subordinado a isso:

- **cena** é o palco onde se estuda (não é teatro: sem "ato", "Em cena", "elenco");
- **lâmpada** é a vida dentro da cena; **lamparina** é a semana no perfil;
- **medalha** é a recompensa; o conjunto delas é o **cofre**.

Fora do mundo (não usar em UI): céu como tema visual, poeira/perseguição,
teatro (atos), escada, moeda, emblema, galeria.

"Caminho" só em frase solta de narrador ("revelam-se no caminho"). Nunca
como nome de coisa: não é área, não é progresso salvo, não é assinatura.

## Glossário

| Conceito | Termo | Não usar |
|---|---|---|
| Unidade de estudo | **cena** | missão, lição, passo |
| Parte de uma cena (cada exercício) | **pergunta** ("Pergunta 2 de 6", "6 perguntas") | ato |
| Grupo de cenas dentro da trilha (módulo) | **etapa** ("Etapa II") | cena (colide com a unidade) |
| Área de trilhas (AT, NT, Vida cristã, Teologia) | **área** | caminho, reino |
| Pontos | **passos** ("+40 passos") | pontos, XP; "passo" como sinônimo de cena; "primeiros passos" como marco |
| Curso | **trilha** | trilha como "online" ("Na trilha agora") |
| Progresso geral | **jornada** | caminhada, caminho |
| Dias seguidos | **sequência** | constância, dias seguidos |
| Proteção da sequência | **gelo** | — |
| Meta diária (cenas por dia) | **meta** / "Seu ritmo" como título | passos por dia |
| Meta de sequência | **compromisso** | — |
| Acerto em % | **acertos** ("92% de acertos") | clareza, precisão |
| Tarefas diárias | **Tarefas do dia** | gestos (colide com os 6 gestos) |
| Revisar | **revisar / revisão** | revisitar |
| Aba social | **Juntos** (Companhia · Caravana · Grupos) | — |
| Liga semanal | **caravana** — só o grupo da semana | liga, divisão; caravana como nível ou sequência |
| Nível da caravana | **nível**; nome da árvore sozinho ("Você subiu para Oliveira") | "Caravana da Oliveira", divisão |
| Par 1:1 | **companhia**; a pessoa é **companheiro(a)** | dupla, parceria, par, amizade, amigo |
| Grupo de estudo | **grupo** | sala |
| Peer challenge (mesma cena até domingo) | **desafio** — é disputa: ganhar, perder, empate | esquina, PvP; "não é duelo" |
| Boss / revisão de módulo | **travessia** (shipped na UI; títulos de conteúdo ainda podem dizer “Desafio: …”) | reusar “desafio” sozinho |
| Desafio litúrgico | **desafio da estação** | só “desafio” |
| Estação litúrgica (Advento/Quaresma) | **estação** / nome da campanha | temporada; caminhada (colide com id do modo) |
| Usuário (identidade) | **peregrino** | aprendiz; "Peregrino+" é nome de plano, não mexer |
| Marca em texto corrido | **Stway** | STWAY (caixa alta) |
| Histórico semanal no perfil | **lamparina** / jarro | lâmpada (vidas) |
| Gesto social | **reconhecer** | curtir |
| Lembrar quem já está (companhia, grupo) | **acenar / aceno** ("Acenar para Ana") | chamar, animar |
| Trazer alguém novo (convite) | **chamar** ("Chamar pessoas", "Chamar um companheiro") | — |
| Lembrete do app no horário | **lembrar** ("Lembrar às 20h") | chamar |
| Slogan | **A Bíblia, cena a cena** | — |
| Recompensa | **medalha**; **selo** só para selos de personagem | conquista, conquistar, emblema, moeda |
| Modos (UI) | **Observação / Compreensão / Interpretação** | semente, caminhada, profundezas (ids internos); "mudar a trilha" para trocar de modo |
| Texto bíblico | **Bíblia** (produto, leitura); **Palavra** em frase devocional; **Escrituras** (plural) em estudo | — |
| Vidas | **lâmpada** | — |

## Uma ação, um rótulo

| Ação | Rótulo | Não usar |
|---|---|---|
| Primeira vez | **Começar** | Descobrir, Entrar na trilha |
| Seguir de onde parou | **Continuar** | Continuar a jornada / no cânon / a trilha, Retomar, Abrir agora |
| Depois de concluir a cena | **Próxima cena** | — |
| Voltar | **Voltar** (destino só se ambíguo: "Voltar ao mapa") | Até amanhã como botão |
| Trazer alguém novo | **Chamar** ("Chamar um companheiro", "Chamar pessoas", "Chamar para o desafio") | Convidar, Convidar amigo, Enviar convite |
| Responder a convite recebido | **Aceitar** (sheet "Aceitar convite") | Entrar |
| Digitar código | **Tenho um código** → botão **Entrar** | Entrar com código |
| Lembrar quem já está | **Acenar** ("Acenar para Ana") | Enviar aceno, chamar |
| Fora do app | **Mandar no WhatsApp** / **Compartilhar** | Também no WhatsApp |
| Sair (membro) / acabar (dono) | **Sair do …** / **Encerrar …** | — |
| Manter, na confirmação de saída | **Cancelar** | Continuar |
| Receber recompensa | **Coletar** | — |
| Fechar leitura / confirmar aviso | **Fechar** / **Entendi** | Glória a Deus, OK |
| Guardar versículo (Bíblia) | **Guardar** | Salvar |
| Salvar dado (Ajustes) | **Salvar** | Guardar |

Feedback: sempre `showAppToastFor` (nunca `SnackBar` cru).
Erro: "Não foi possível [verbo]. Tente de novo." (com ponto; nunca "Não deu para").
Futuro: **Em breve** (detalhe opcional depois de " · ").

## Voz por contexto

| Contexto | Voz |
|---|---|
| Narrador (Hoje, cena, trilhas, perfil, Juntos) | você + para; frases curtas; calmo; mundo do caminho; sem urgência de perseguição |
| Acerto na cena | curto, sem "!": "Isso.", "Acertou.", "Muito bem." |
| Celebração | narrador; até um "!" |
| Mascote | só na celebração; uma linha |
| Técnica (Ajustes, erros, plano de leitura, ferramentas da Bíblia) | direta, sem metáfora: progresso, conta, backup, aparelho; "Apagar progresso", não "Resetar"; "Automático", não "Auto" |
| Aparência | **Claro / Médio / Escuro / Automático** (muda com o horário) | 
| Mensagem de amigo para amigo (aceno, texto de convite que a pessoa manda) | 1ª pessoa de quem manda; gíria, "pra" e emoji ok |

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

## Idiomas (pt-BR · en · es)

Textos de interface moram em `lib/l10n/parts/*.json`, um arquivo por área,
com as três línguas lado a lado:

```json
"homeDaysLeft": {
  "pt": "{count, plural, =1{Falta 1 dia} other{Faltam {count} dias}}",
  "en": "{count, plural, =1{1 day left} other{{count} days left}}",
  "es": "{count, plural, =1{Falta 1 día} other{Faltan {count} días}}",
  "placeholders": {"count": "int"}
}
```

`python3 tool/l10n_merge.py` valida (chave duplicada, idioma faltando,
placeholder não declarado), gera `lib/l10n/app_{pt,en,es}.arb` e roda
`flutter gen-l10n` (código em `lib/l10n/gen/`). Nunca edite os `.arb` à mão.
Fora de widget (model, util, serviço, notificação) use `L10n.current.chave`
(`l10n/l10n_global.dart`); em widget, sempre `context.l10n`.

- Use `context.l10n.chave` (import `l10n/app_language.dart`). Nunca string
  solta em tela nova.
- Chave com prefixo da tela (`settings…`, `lesson…`); genéricos em `common…`.
- Contagem sempre com plural ICU: `{count, plural, =1{1 cena} other{{count} cenas}}`.
  Nada de `n == 1 ? … : …` no código.
- Frase inteira numa chave com placeholder (`Você subiu para {tier}`); nunca
  concatene pedaços traduzidos.
- Datas com `DateFormat(..., locale)`; nunca `dd/mm` montado à mão.
- Nome do idioma no seletor é escrito nele mesmo (Português, English, Español).
- Conteúdo (trilhas, perguntas, Bíblia, léxico) ainda é só pt-BR — não entra
  no ARB.

Glossário por idioma (mesma regra "uma palavra, um sentido"):

| pt-BR | en | es |
|---|---|---|
| cena | scene | escena |
| pergunta | question | pregunta |
| etapa | stage | etapa |
| área | area | área |
| trilha | trail | ruta |
| jornada | journey | camino |
| passos | steps | pasos |
| sequência | streak | racha |
| gelo | freeze | hielo |
| meta | goal | meta |
| compromisso | commitment | compromiso |
| acertos | accuracy | aciertos |
| caravana | caravan | caravana |
| nível | level | nivel |
| companhia / companheiro(a) | companion | compañía / compañero(a) |
| grupo | group | grupo |
| desafio | challenge | desafío |
| travessia | crossing | travesía |
| estação | season | temporada litúrgica |
| Juntos | Together | Juntos |
| acenar / aceno | wave | saludar / saludo |
| chamar | invite | invitar |
| reconhecer | recognize | reconocer |
| lâmpada | lamp | lámpara |
| lamparina | oil lamp | candil |
| medalha / selo / cofre | medal / seal / vault | medalla / sello / cofre |
| peregrino | pilgrim | peregrino |
| Observação / Compreensão / Interpretação | Observation / Understanding / Interpretation | Observación / Comprensión / Interpretación |
| Ajustes | Settings | Ajustes |
| Hoje · Trilhas · Bíblia | Today · Trails · Bible | Hoy · Rutas · Biblia |

Tom em en: "you", frases curtas, sentence case. Em es: **tú** (não usted),
imperativo de tú ("Continúa", "Invita").
