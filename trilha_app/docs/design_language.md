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
| Ação principal | `AppRoles.action` (ouro `#F4A80C`) | `CopperCta`. Um ouro por tela, o do botão |
| Recompensa | `AppRoles.reward` (ouro) | **só** o número de passos |
| Chrome | `AppRoles.chrome` (aço frio `#9EB0C4`) | TopBar, ícone idle e abas inativas da nav — **igual em todas as abas** |
| Aba ativa da nav | `AppRoles.navToday/navTrails/navBible/navTogether` (Ajustes = chrome) | só a aba ativa acende no seu tom (pílula com gradiente e brilho) |
| Seleção (cena) | fill branco (`selected`) | **só** opção tocada na cena (gesto); nunca aba do shell |
| Aba ativa (shell) | fill escuro + rim do `accent` | `AppSegmentedTabs(accent:)` — presença do bloco |
| Idle (cena) | `nightElevated` + texto claro | placas de resposta no céu escuro |
| Acerto na cena | `AppRoles.action` (ouro) | placa da resposta certa |
| Presença / vida | `AppRoles.presence` (`#51AEF0`, azul da nuvem) | acertos, "estudou hoje", borda da próxima cena, lâmpada acesa |
| Lâmpadas (vidas) | `AppRoles.presence` | acesas = a luz da nuvem |
| Sequência | `AppRoles.streak` (o mesmo ouro) | a chama, o mesmo metal do botão |
| Risco / erro | `AppRoles.error` | flash da resposta errada na cena; ação destrutiva (sair, apagar) |

**Família da marca** (logo + nuvem): navy, caminho branco, azul `#51AEF0`,
um ouro `#F4A80C`. O ouro avança (o botão) e conta os passos. O azul é a
vida. Reinos só no mapa e no seletor; o modo também acende a cena. Medalhas só no cofre.

Regras (gesto na cena):
- Idle = poço escuro · Seleção = branco · Acerto = ouro · Erro = vermelho.
- Sem azul/glow nos gestos da partida (glow = lobby social, não placa de resposta).
- Cor do modo = luz do palco na cena (2026-10-21): borda e luz do palco,
  rótulo do gesto, lacuna e segmento atual do progresso. Nunca na placa de
  resposta (acerto continua ouro, erro vermelho). No Claro, tom escuro do modo.
- Um CTA: `CopperCta` ouro. O Verificar fica sempre ouro (antes da escolha
  só não responde) e dá um pulinho ao armar; a Dica é tinta de legenda.
- O enunciado é fala do Anan: Anan pequeno (feliz) à esquerda e a pergunta
  no balão claro (`AnanSpeechBubble`, `tail: AnanTail.left`), só o texto.
- Lâmpadas: lanterna no azul de presença; chama e brilho da acesa em âmbar
  (`AppRoles.lamp`); apagadas ficam no contorno fraco.
- Abertura da cena = mesmo cabeçalho (`AnanSideSpeech`: título + nota no balão)
  e mesmo palco dos gestos (luz do modo, versículo centrado, ref neutra).
- Barra da cena: título = tipo do gesto (Palavra, Afirmação…), sem "x/6"
  nem modo; os passos finos ficam dentro da barra (`TopBar.bottom`). Pulinho a cada escolha; a cara do veredito fica no diálogo.
- A cena é o único lugar com placas claras (respostas em marfim — o "palco").
- Cenário de marca (`BrandTrail` / splash): splash, onboarding, celebração;
  **lobby** (Hoje / Juntos) pode levar trilha velada. Bíblia / Ajustes /
  cena = gradiente da fase do dia; cenário pintado só dentro de card herói.
- Um botão principal: `CopperCta` (`large` no herói; `decorative` quando o card
  inteiro é o toque). Não desenhe CTA à mão.
- Um card: `GlassCard` (`tint` para um papel, `glow` para palco). Não monte
  card com `Container` + `BoxDecoration`.
- Juntos por bloco: Companhia/Grupos → `presence` no card; Desafio/Caravana →
  ouro só em placar/passos/podium (não na pílula do submenu).

- Um segmentado: `AppSegmentedTabs(accent: AppRoles.presence)`. Aba ativa ≠ branco de cena. Chips soltos: `AppSelectChip`.
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

A nuvem se chama **Anan** ("nuvem" em hebraico), a que acompanhou o povo no deserto. É a companheira dos avisos.
O cartão da próxima cena fica com o clima de antes: teia quando empoeirado,
brilho quando em dia, gelo quando congelado. O botão do herói ("Próxima cena" / "Continuar") leva o Anan à esquerda do texto, no clima do card: feliz em dia, triste com poeira, carregando (parado, esperando) no gelo.

- **Sucesso** na fala do fim da cena, também quando a cena fecha limpa ou com bônus. Sem coroa, sem "Cena limpa" e sem a linha da medalha: a cara já diz. Cena que não fechou usa a cara de erro.
- **Sucesso** também na folha de subida de nível da liga, no lugar da coroa.
- **Sucesso** no último ato do onboarding ("A jornada"), acima do título —
  fora do cartão, que é a prévia do cartão da Home.
- **Erro** quando a tela inteira não abre (catálogo, trilhas, Bíblia, Juntos
  sem conexão, peregrino da caravana) e há "Tentar de novo". Enquanto tenta
  de novo, a cara vira carregando. A cena que não carrega as perguntas abre
  um diálogo com essa cara.
- **Triste** no cartão "Você desceu" da liga e na confirmação de zerar
  progresso ou excluir a conta. Pesa a decisão sem ameaçar.
- **Feliz** no onboarding, logo depois do prólogo: o Anan se apresenta em
  duas falas (o nome; o Stway) e pergunta o que a pessoa quer fazer.
  "Começar jornada" (ouro) e "Pular" levam ao último ato, com os padrões;
  "Ajustar jornada" segue pelos atos.
- **Triste** no fio apagado da Companhia sem companheiro, entre você e o
  "Quem?". Com o convite aberto, **carregando**: o Anan espera junto.
- **Triste** no vazio do Desafio ("Nenhum desafio ainda"): ainda ninguém
  com quem disputar.
- **Triste** no centro da roda de lugares de Grupos vazio ("Quem estuda com
  você?"), no lugar da lâmpada.

Regra dos vazios de Juntos: sem ninguém ainda, o Anan fica triste.
- **Carregando** na splash e na primeira carga do catálogo.

Vazio comum (busca sem resultado, nada guardado, caravana pequena) fica no
glifo: a nuvem marca o que aconteceu com a pessoa, não a falta de dados.

Onde mais o Anan entra por padrão: `EmptyState` (triste; `face` muda), `AppSpinner` de tela ou seção (carregando, flutuando; o `inline` de botão continua anel), `AnanBeside` ao lado de medalha, selo e baú (sucesso; trancada ou abrindo = carregando), cada ato de ajuste do onboarding (`_AnanGuide`), paywall, escolha de modo e "preparando" do login, e o **Anan falando** (`AnanSpeech`): um padrão só, o do onboarding. O Anan fica em cima, ao centro, e o recado vai num balão de papel claro (`AnanSpeechBubble`, branco como o corpo do Anan e com o acabamento dele — contorno e brilho no azul da borda da nuvem —, tinta escura, rótulo em dourado escurecido) com a ponta voltada para ele. O balão é claro em qualquer visual. Hoje: as falas do onboarding, o card "Antes de começar" de cada porta de Trilhas (feliz; carregando quando a porta toda é "Em breve"), a abertura do Peregrino+, Em breve, aviso da promo Plus, Apoie, Revisão da semana e o recado da celebração (`MascotBubble`, nuvem menor). Sheets e diálogos seguem com a nuvem centralizada em cima (`AppSheetHeader`, `AppDialog`).

A nuvem é viva: o corpo é imagem (`cloud_body_*.png`, uma borda por cara) e
o rosto é desenhado em `CloudMascot`. Ao aparecer, parte do rosto neutro e
reage — a barra do olho abre em X e a cabeça balança no erro; no sucesso os
olhos viram arco, a boca abre e ela pula; na tristeza os olhos caem e ela
afunda. Ele entra com um pop (cresce e aparece). Barra pisca de tempos em tempos (feliz, carregando, triste), às vezes duas vezes; de vez em quando faz um gesto parado (pulinho no feliz e no sucesso, suspiro no triste). Cutucar o Anan faz ele reagir sem roubar o toque do botão ou card por baixo. Trocar
`face` no meio anima de onde está. `react: false` mostra a cara final direto;
com "reduzir movimento" do sistema, nada se mexe.

**O Anan aparece em toda interação com a pessoa:** diálogo, aviso, sheet e travessia. `AppSheetHeader` já traz a nuvem (centralizada acima do título; alinhada à esquerda, pequena ao lado), com `face` feliz por padrão e `cloud: false` só onde a nuvem já está na sheet. Na travessia (`showCrossingBurst`) ele espera em carregando, comemora (sucesso) na chegada e fica triste quando alguém sai. `AppDialog` já traz a nuvem no topo (`face`, feliz por padrão); `showAppConfirm` com `danger` fica triste; falha usa erro, espera usa carregando. Avisos abrem um diálogo com a nuvem (`showAppToastFor`): erro quando o caminho não abre, triste na lâmpada ou no que foi guardado, feliz no gesto de companhia, sucesso no resto. No veredito da cena a nuvem fica no centro, grande, e o cartão não muda de cor: acerto é a cara de sucesso, erro é a cara de erro e lâmpadas acabadas são triste. Na celebração, a contagem e a próxima cena ficam em placa clara, para acompanhar a nuvem; o céu da tela continua escuro. Spinner de botão e o flash de erro dentro da cena continuam no glifo.

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
| Carregando | `AppSpinner` em botão/linha; `CloudMascot` na splash e na 1ª carga do catálogo |
| Vazio | `EmptyState` |
| Nuvem | `CloudMascot` — lugares listados abaixo |

## Peregrino+

Tudo que lista o que o Plus dá usa `PlusPerkCard`
(`lib/widgets/plus_perks.dart`). Nenhuma tela monta lista própria.

- Os benefícios vêm de `PlusPerk`: caminhadas sazonais (`calendar`),
  revisão semanal (`scroll`), planos de leitura (`book`), sua
  constância (`path`), reforço do ponto
  fraco (`target`) e selo de apoiador (`gift`). Mesmo ícone, título e frase
  em todo lugar.
- Identidade: fundo `accentFill(0.10)`, borda `accentBorder(0.6)`, rótulo
  dourado (`AppRoles.reward`) em caixa alta e ícone emoldurado em dourado.
- Variações: `detailed` (com a frase, no paywall), compacto (só títulos,
  na oferta e no Perfil), `locked` (cadeado, no aviso de fim da
  promoção), `boxed: false` (dentro de outro cartão). Fora do paywall, a
  lista é curta: `PlusPerk.highlights` (Caminhadas, planos, revisão) e
  "E mais N benefícios".
- Para dizer o que continua grátis, use o mesmo formato em neutro (texto
  secundário), nunca em dourado.

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

Na cena (partida): HUD = progresso das perguntas + lâmpadas. Sequência
(`×N`) só no veredito da base — sem medidor no topo. Combo não cura
lâmpada nem soma passos extras. Erro = flash vermelho + lâmpada que apaga.

Na celebração: contagem de passos sobe e, ao fechar, háptico + pop no cartão
de passos. O multiplicador de cena limpa já está em `computeLessonSteps`.

No mapa da área: estação atual é nível jogável (glow, barra, "Jogar", aviso
de Travessia). Estações quietas com progresso mostram filete; beacon atual
pulsa. Toque com `ActPress`.

No Hoje (lobby): `HomePlayerHeader` é cartão de jogador — sequência, meta
com barra, gelo, passos, semana em orbs. Lâmpadas não aparecem fora da cena.

Fora do mundo (não usar em UI): céu como tema visual, poeira/perseguição,
teatro (atos), escada, moeda, emblema, galeria.

"Caminho" só em frase solta de narrador ("revelam-se no caminho"). Nunca
como nome de coisa: não é área, não é progresso salvo, não é assinatura.

## Glossário

| Conceito | Termo | Não usar |
|---|---|---|
| Unidade de estudo | **cena** | missão, lição, passo |
| Parte de uma cena (cada exercício) | **pergunta** ("Pergunta 2 de 5", "5 perguntas") | ato |
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
| Ranking | **caravana** — um ranking só, o do mês (cenas novas); seta verde = subiu hoje; subtítulo = presença (`Hoje` / data). Sem placar semanal por enquanto | liga, divisão, sala; caravana como nível ou sequência; "destaque da semana" / "+N na semana" no placar |
| Nível da caravana | **nível**; nome da árvore sozinho ("Você subiu para Oliveira"). Sobe com 3 **semanas firmes** (5 cenas novas cada), nunca desce | "Caravana da Oliveira", divisão, rebaixar |
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
| Pintura da cena guardada ao concluir | **postal** ("Revelar o postal", "Seus postais"); o verso é a nota da pessoa | selo, figurinha, card, carta |
| Trilha do Plus que quem assina libera para alguém (1 por mês) | **passe de trilha**; ação "Libere esta trilha para alguém", botão **Compartilhar o passe**; slogan "Sua assinatura libera alguém" | presente, cupom, vale, convite |
| Modos (UI) | **Observação / Compreensão / Interpretação** | semente, caminhada, profundezas (ids internos); "mudar a trilha" para trocar de modo |
| Texto bíblico | **Bíblia** (produto, leitura); **Palavra** em frase devocional; **Escrituras** (plural) em estudo | — |
| Vidas | **lâmpada** | — |
| A nuvem companheira | **Anan** ("o Anan") | mascote, nuvenzinha |

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

Feedback: sempre `showAppToastFor` — diálogo com a nuvem (nunca `SnackBar`).
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
| postal | postcard | postal |
| peregrino | pilgrim | peregrino |
| Observação / Compreensão / Interpretação | Observation / Understanding / Interpretation | Observación / Comprensión / Interpretación |
| Ajustes | Settings | Ajustes |
| Hoje · Trilhas · Bíblia | Today · Trails · Bible | Hoy · Rutas · Biblia |

Tom em en: "you", frases curtas, sentence case. Em es: **tú** (não usted),
imperativo de tú ("Continúa", "Invita").

## Cinema (F0) e juice (híbrido)

Direção: **filme no mundo, juice na recompensa.**

- **Tempo** — `AppMotion`: `instant` 90 · `quick` 160 · `standard` 240 ·
  `gentle` 360 · `slow` 520 · `scene` 820 ms; curvas `enter` (chega e pousa),
  `exit`, `move`, `settle`. Todo `duration:` de UI usa um degrau.
  `AppMotion.pop` / `spring` (quique) **só** quando algo é ganho: passos,
  medalha, baú, veredito, travessia, lâmpada. Nunca em chrome ou leitura.
- **Transição** — telas empurradas entram como aproximação de câmera
  (`CinematicPageTransitionsBuilder`, no tema). iOS mantém a do sistema
  (gesto de voltar). Abas trocam por dissolve.
- **Voz** — títulos, palco e números grandes em Cormorant (`display`);
  interface em Nunito (`title`, `label`, `body`, `cta`). Exo2 saiu.
- **Luz** — `AppLight`: luz principal de cima-esquerda (`keyFrom`), véu nos
  cards, gradação da estação litúrgica no céu, vinheta de lente.
- **Sombra** — `AppLight.shadow` (macia). Lábio duro (`AppLight.lip`) **só**
  nas placas de resposta da cena, onde o toque tem peso.

## Grandes momentos (F3)

`showSetPiece` + `SetPiece`: tela cheia, véu noite, luz do momento vinda de
cima, emblema com quique, título serifado, uma linha e um botão. Som e
háptica no mesmo frame do emblema. Toque adianta; "reduzir movimento" mostra
o quadro final. Cada momento acontece **uma vez** (`SetPieceMemory`).

| Momento | Quando | Luz | Som |
|---|---|---|---|
| Travessia | primeira entrada em cada cena-chefe | recompensa | — |
| Marco de sequência | compromisso escolhido ou 7/30/50/100/200/365 dias | sequência | chama |
| Nova estação | primeira abertura depois da virada litúrgica | cor da estação | conclusão |
| Trilha concluída | fim da trilha (por modo) | recompensa | travessia |

Momento novo usa o mesmo palco — não desenhe outro overlay.
