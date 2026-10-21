# Caminhada Premium — A Promessa (de Abraão a Cristo)

Especificação da experiência-modelo do Peregrino+ (ver
[`MONETIZATION.md`](../MONETIZATION.md)). É a demonstração do posicionamento:
as cenas são gratuitas; o Plus vende a **costura** — ordem narrativa,
conexões escritas e diagnóstico final.

Status: especificação editorial + de produto. Nenhuma linha de código ainda.

---

## A promessa da jornada (para o usuário)

> Você já leu sobre Abraão, o Êxodo, os profetas e Jesus — separados.
> Nesta caminhada, você percorre a promessa que atravessa todos eles,
> na ordem, e descobre o que ficou conectado na sua cabeça.

## Formato

- **12 estações** em 4 blocos de 3, uma estação por dia (ritmo de Caminhada),
  sem janela de calendário: evergreen, começa quando a pessoa quiser.
- Cada estação é uma **cena que já existe** numa trilha (reaproveitamento
  ≥70%; idealmente 100% na v1). Jogar a estação aqui **conta também na
  trilha de origem** — nada de progresso duplicado ou perdido.
- **4 textos de costura** (um por bloco, ~120–180 palavras, revisados):
  o que a promessa era até aqui, o que muda neste bloco, o que procurar.
- **Diagnóstico final** (ver abaixo) + selo de conclusão da jornada.
- Amostra: **bloco 1 inteiro grátis** (3 estações + costura). O cadeado
  aparece na porta do bloco 2 — é a amostra que demonstra o valor no trial.

## Roteiro (critério de seleção das cenas)

O editor escolhe as cenas existentes pelo `verseRef`/insight que cubram
os marcos abaixo. Se um marco não tiver cena boa hoje, usa-se a cena mais
próxima do mesmo livro — **não se cria cena nova na v1**.

| Bloco | Tema | Marcos (referências-âncora) |
|---|---|---|
| 1 · A Promessa feita | Abraão | Gn 12:1–3 (chamado e promessa) · Gn 15 (aliança) · Gn 22 (Moriá) ou Gn 17 (sinal da aliança) |
| 2 · A Promessa guardada | Êxodo e terra | Êx 3 (o Nome e a memória da promessa) · Êx 19–20 (aliança no Sinai) · Dt 26 ou Js 24 (recapitulação: “meu pai era um arameu”) |
| 3 · A Promessa anunciada | Profetas e Salmos | Is 9 ou Is 53 (o Servo) · Jr 31:31–34 (nova aliança) · Sl 89 ou Sl 132 (a promessa a Davi) |
| 4 · A Promessa cumprida | Evangelhos e cartas | Mt 1:1–17 (a genealogia como argumento) · Lc 1:46–55 ou 1:67–79 (cânticos) · Gl 3 (a promessa e a lei) ou Rm 4 (Abraão justificado) |

Costuras (1 por bloco, sempre nesta ordem lógica): *o que foi prometido →
o que parecia perdido → o que foi anunciado → como se cumpriu — e o que
ainda se espera* (a costura final pode abrir Ap 21–22 como horizonte,
sem estação jogável na v1).

## Diagnóstico final (Fase 1: local à jornada)

Ao concluir a estação 12:

1. **Três perguntas de síntese** no gesto `connect`: ligar marco →
   cumprimento (ex.: Gn 22 ↔ Rm 8 / Hb 11; Jr 31 ↔ Lc 22; Gn 12 ↔ Gl 3).
   Reaproveitar perguntas `connect` dos bancos das estações quando
   servirem; no máximo 3 perguntas novas, no padrão V2.
2. **Mapa da jornada**: os 4 blocos com acerto de primeira em cada um
   (“você firmou a Promessa anunciada; a Promessa guardada pede revisão”).
3. **Próximo passo concreto**: as 1–3 estações com erro entram na fila de
   revisão (erros) da pessoa. Nada de mapa histórico por tema — isso é a
   Fase 2, alimentada por dados como estes.
4. Selo de conclusão + convite para a próxima Caminhada Premium.

## Regras de acesso

- Bloco 1 grátis para todos (é a vitrine). Blocos 2–4: Peregrino+
  (`plusFeaturesOpen`, com o comportamento sem loja já existente).
- Nenhuma cena muda de lugar: quem não assina continua podendo fazer
  todas as 12 estações nas trilhas de origem, na ordem das trilhas.
  O que ele não tem é a ordem da promessa, as costuras e o diagnóstico.
- Progresso da jornada é próprio (não reusar `seasonWalkDays`, que é de
  calendário): um registro por jornada (`premiumWalkProgress`), com
  estações concluídas e acertos por bloco — é também a semente da
  instrumentação de domínio da Fase 2.

## Reuso de engenharia (o que já existe)

- Mecânica de Caminhada (`SeasonWalkScreen`, dias, crédito, revisão):
  a Premium é uma campanha **sem data** — generalizar `SeasonWalkCampaign`
  para aceitar `start == null` (evergreen) ou criar tipo irmão que
  compartilhe tiles e o player de cena (`LessonScreen` com
  `skipTrailLock`, como hoje).
- Acesso: mesmo padrão `SeasonWalkAccess` (amostra → Plus), trocando
  “dia do calendário” por “índice do bloco”.
- Celebração e selo: reusar o fluxo de fim de jornada/medalha existente.
- Telemetria desde o dia 1: `premium_walk_start`, `premium_walk_station`,
  `premium_walk_block_locked` (quem bate no cadeado do bloco 2),
  `premium_walk_complete`, bloco a bloco. Sem isso não há como saber se
  a experiência-modelo demonstra valor.

## O que NÃO é esta jornada

- Não é uma trilha nova nem substitui Gênesis/Evangelhos nas trilhas.
- Não é cooperativa na v1 (convidar amigos é Fase 3; a jornada nasce
  individual, como as temporadas).
- Não promete “mapa de conhecimento da Bíblia toda” — só o retrato
  desta jornada.

## Critérios de pronto (v1)

- [ ] 12 estações mapeadas para slugs reais do catálogo, todas jogáveis
- [ ] 4 costuras escritas e revisadas (padrão editorial da casa, TB nas citações)
- [ ] Até 3 perguntas de síntese, no padrão V2 (6 gestos não se aplicam aqui;
      só `connect`, com `feedbackWrong` por alternativa)
- [ ] Diagnóstico com mapa por bloco + envio dos erros à fila de revisão
- [ ] Amostra (bloco 1) aberta; cadeado no bloco 2 com paywall
      `source: 'premium_walk'`
- [ ] Eventos de telemetria no ar
- [ ] Teste com 5–10 pessoas do D7: a pessoa consegue dizer, com as
      próprias palavras, uma conexão que não tinha antes?

## Decisões em aberto

1. Tema confirmado? Alternativas ao mesmo desenho: *A Aliança*
   (mais teológica, menos narrativa), *De Gênesis a Jesus* (mais ampla,
   16+ estações). Recomendação: manter **A Promessa**.
2. 12 estações em dias consecutivos ou livres (sem ritmo diário)?
   Recomendação: livres — evergreen não deve punir quem atrasa;
   o lembrete diário já existe no plano de leitura.
3. A jornada aparece onde? Recomendação: cartão próprio na Home durante
   a Fase 1 (é a demonstração do Plus) + entrada permanente na tela do
   Peregrino+, sem disputar com a Caminhada de temporada quando houver
   uma ativa — temporada tem prioridade de vitrine.
