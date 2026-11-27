# Monetização STWAY

Não cobramos para começar. Não cobramos para ler a Palavra.

Refeito em 20 out 2026, depois de cinco rodadas de auditoria do código e da
análise de mercado (Glorify, Hallow, Duolingo, Bibliando, YouVersion).
Preços e planos revistos em 25 nov 2026. Estado conferido contra o código
em 26 nov 2026 (ver [Estado no app](#estado-no-app-26-nov-2026)).

> A regra antiga "não preencher as chaves RevenueCat antes do D7" foi
> superada: a chave Android está no app desde a 1.0.39. A do iOS segue
> vazia até a conta da Apple mudar. O D7 com testadores ainda não tem dado.

---

## Posicionamento

# Vá além da missão diária.

**Aprenda com profundidade. Viva novas jornadas. Cresça junto com outras pessoas.**

Peregrino+ — mais profundidade em cada passo.

O STWAY não vende uma Bíblia melhor. Vende uma forma melhor de estudar,
compreender e reter o que a Bíblia ensina. A Bíblia, o cânon e as cenas são
grátis para sempre; o Plus vende **profundidade, jornada e síntese** —
o que o usuário não consegue montar sozinho a partir das peças gratuitas.

### Os três pilares (arquitetura, não lista de benefícios)

Os pilares são uma experiência só, não três aplicativos dentro do produto.
Toda peça nova do Plus precisa servir a pelo menos um pilar — e as melhores
servem aos três ao mesmo tempo.

1. **Aprendizagem avançada** — o motivo de assinar. Revisão adaptativa,
   planos por objetivo, estudos aprofundados, conexões entre passagens e
   acompanhamento da evolução do conhecimento.
2. **Experiências especiais** — o motivo de desejar. Caminhadas temáticas,
   temporadas (Advento, Páscoa), jornadas narrativas, desafios especiais.
3. **Comunidade** — o motivo de ficar e convidar. Jornadas compartilhadas,
   desafios cooperativos, grupos de estudo, família e ferramentas de líder.

**Regra de copy:** no lançamento, o paywall vende os pilares 1 e 2 — é o que
funciona. Comunidade entra como o que já é grátis e como horizonte, nunca
como benefício pago de uma fase futura. Não se vende o que ainda não existe.

### Livro é território, tema é rota

> Toda a Bíblia, livro por livro, é grátis.
> Os caminhos por tema, as jornadas e as revisões são o Peregrino+.

- **Território (grátis):** as áreas Antigo Testamento e Novo Testamento
  (livro a livro). **Uma trilha por vez** no grátis.
- **Portas de entrada (grátis inteiras):** Ansiedade, Conhecer a Deus,
  Entender a Bíblia — depois desembocam no cânon ou no Plus.
- **Rota (Plus):** Temas (ex.: A Promessa), Vida Cristã (Sermão do Monte,
  Oração, Família, História da Igreja…) e Teologia. Mateus 5–7 segue
  grátis pela trilha de Mateus no NT. **Sem amostra:** trilha Plus pede
  o Plus desde a 1ª cena (`PlusAccess.missionNeedsPlus` — mapa, Home e
  deep link). O trial da loja faz o papel de teste.
- A regra é pela área/card (`TrailJourney.requiresPlus`), não só pelo
  `realm`: área nova fora de AT/NT já nasce Plus (exceto as portas de
  entrada). Trilha Plus não espera pré-requisito de outra área; a ordem
  dentro do próprio caminho continua. A Caminhada de temporada usa cenas
  dessas trilhas e segue a regra própria dela (só o 1º dia grátis), não
  a da trilha.
- Cena dentro de rota paga continua alcançável grátis pela trilha do seu
  livro. O Plus vende seleção, ordem, estudo e destino — nunca a cena.

De onde vêm temas novos e o que faz quem já zerou o grátis:
[`docs/FUTURO_TEMAS.md`](docs/FUTURO_TEMAS.md).

### A experiência-modelo

A prova do posicionamento é uma **Caminhada Premium evergreen** (fora do
calendário de temporadas), montada de cenas que já existem nas trilhas:

> **A Promessa — de Abraão a Cristo.** Gênesis → profetas → Evangelhos →
> cartas. O usuário percorre cenas já gratuitas, mas na ordem da promessa,
> com textos de costura entre os blocos, perguntas de conexão e, no fim,
> um diagnóstico: quais conceitos desta jornada foram compreendidos e
> quais pedem revisão.

- As cenas continuam grátis nas trilhas. O Plus vende a **costura**: seleção,
  ordem narrativa, conexões escritas e diagnóstico.
- Na Fase 1 o diagnóstico é **local à jornada** (desempenho nestas cenas,
  com as explicações que as perguntas já têm). Mapa histórico por tema é
  Fase 2 e será alimentado pelos dados que jornadas assim gerarem.
- Critério editorial de toda Caminhada Premium: ≥70% de cenas reaproveitadas
  dos bancos atuais, costuras novas curtas e revisadas, nenhum texto bíblico
  atrás de paywall.
- Ela é a demonstração do trial: quem faz a amostra entende em minutos o
  "estou conectando o que antes eu não conectava".

---

## Princípios que não mudam

- Bíblia, cânon nos 3 modos (inclusive Profundezas), Strong, áudio da cena:
  **grátis para sempre**.
- O Plus é sempre **aditivo**: camada nova sobre o que é grátis. Nunca
  fatiar um recurso gratuito existente para criar o pago (memorização,
  fila de erros e planos básicos não encolhem).
- Nada de vender o futuro: benefício só entra no paywall quando funciona.
- Sem energia, sem loja de gelo/reparo, sem anúncio, sem battle pass.
  Proteção de sequência e reparo **não** são alavanca de assinatura.

## O que continua grátis

- Cena do dia, sequência, missões, gelo, lâmpadas, reparo, Strong
- Cânon nos 3 modos (Observação / Compreensão / Interpretação), **uma
  trilha por vez**
- Bíblia offline, busca, versículos salvos, áudio da cena (passagem + “Hoje:”)
- Memorização de versículos (flashcards com SRS leve) e fila de erros
- O plano de leitura da Bíblia inteira (canônico ou cronológico) + lembrete
- O 1º dia de cada Caminhada de temporada
- Portas de entrada inteiras (Ansiedade, Conhecer a Deus, Entender a Bíblia)
- 1 companhia, Caravana, grupo básico, Desafio

## Divisão grátis × Plus

| Funcionalidade | Grátis | Peregrino+ |
|---|---|---|
| Missão diária e trilhas bíblicas | Completo, **1 trilha por vez** | Quantas quiser ao mesmo tempo |
| Portas de entrada | Inteiras | Inteiras |
| Leitura e explicação das respostas | Completo | Completo |
| Memorização de versículos | Básica (deck atual) | Revisões adaptativas e agendadas |
| Revisão de erros | Básica (fila de erros) | Plano de revisão personalizado |
| Planos de formação | Bíblia inteira + amostra dos guiados | Guiados completos e planos por objetivo |
| Conexões bíblicas | Dentro das missões (gesto connect) | Estudos e explorações aprofundadas |
| Caminhadas | 1º dia de cada temporada | Temporadas completas + Caminhadas Premium |
| Temas / Vida Cristã / Teologia (Sermão, A Promessa, Oração…) | Fechadas (sem amostra) | Trilhas inteiras desde a 1ª cena (passagens sempre grátis pelo AT/NT) |
| Desafios e conquistas | Regulares | Experiências especiais |
| Comunidade | Grupos e interação básica | Jornadas cooperativas especiais (Fase 3) |
| Progresso | XP, sequência e trilhas | Análise de aprendizagem por tema (Fase 2) |

Todos os livros da Bíblia são grátis, os poéticos (Jó, Salmos, Provérbios,
Eclesiastes, Cantares) inclusive: ficam no card do Antigo Testamento. As
portas de entrada (Ansiedade, Conhecer a Deus, Entender a Bíblia) são
grátis inteiras.

**Cena Plus liberada por quem paga.** A trava do Peregrino+ vale em todo
caminho (mapa, Home, deep link, grupo, Travessia). Duas exceções, uma cena
por vez: no grupo, a cena que o líder marcou como estudo da semana abre
para todos se o líder tem o Plus; na Travessia, a cena abre se o par tem
o Plus. A cena seguinte da trilha volta a pedir o Plus. Cena já concluída
sempre se pode repetir. O Plus de quem libera vem do doc público
(`plusActive` + `plusExpiresAt`, gravados só pelo webhook).

---

## Preços (decididos em 25 nov 2026; substituem a tabela de 20 out)

Referências de mercado, out/2026: Glorify R$ 14,90/mês e R$ 149,90/ano
(promo recorrente de R$ 69,90); Hallow ~R$ 39,90/mês; Duolingo Super
R$ 34,90/mês e R$ 179,90/ano (Família R$ 269,90); Bibliando US$ 2,99/22,99;
YouVersion tudo grátis. Salário mínimo 2026: R$ 1.621.

| Plano | Mensal | Anual | Acessos | Onde vende |
|---|---|---|---|---|
| Grátis | — | — | 1 conta | — |
| Peregrino+ | **R$ 9,90** | **R$ 89,90** (trial 14 dias) | 1 conta | loja (web: ainda não ligado) |
| Pioneiro (vitalício, 200 vagas) | — | **R$ 149,90 uma vez** | 1 conta | só no app (loja) |
| Casal | — | **R$ 139,90** | 2 contas | loja |
| Família 3 | — | **R$ 179,90** | 3 contas | loja |
| Família 4 | — | **R$ 209,90** | 4 contas | loja |
| Pastor / Missionário | grátis | grátis | 1 conta + ferramentas de líder | contato |
| Igreja Pequena / Igreja / Rede | contato | contato | sob medida | contato |
| Apoio avulso | R$ 5 / 15 / 30 / 50, pagamento único | — | só o selo de apoiador | loja |

### Peregrino+ (individual)

- Mensal R$ 9,90: o mais barato do nicho; porta de entrada.
- Anual R$ 89,90 (R$ 7,49/mês): 24% abaixo de 12 × mensal (R$ 118,80).
  Trial de 14 dias só no anual. É o herói do paywall.
- Sem plano semestral.
- Ajuste fino depois de 60–90 dias com D7 medido, via RevenueCat
  Experiments, com dado de conversão.

### Pioneiro (vitalício, só no lançamento)

- **Pagamento único de R$ 149,90, acesso vitalício.** Só as primeiras
  200 vagas; não reabre. Cerca de 1,7× o anual.
- Na loja é produto **não consumível** (não é assinatura): sem trial,
  sem renovação. Mesmo entitlement `peregrino_plus`.
- Copy: "vitalício" ou "para sempre" é correto aqui (antes era "preço
  travado enquanto renovar"; essa versão saiu).
- A vaga conta na compra (`stats/pioneer`), uma por conta.
- No código (25 nov 2026): `PlusAccess.pioneerProductId =
  'plus_pioneer_lifetime'`; o paywall mostra anual, Pioneiro e mensal
  enquanto houver vaga (`packagesForSale`). O webhook trata
  `NON_RENEWING_PURCHASE` do vitalício (Plus sem data de fim), conta a
  vaga na compra e desliga no reembolso (CANCELLATION sem data de fim).
  `plus_founder_annual` segue reconhecido para o selo dos testadores.
- Venda controlada no app: `pioneerOnSale` exige o pacote na oferta, vaga
  (`stats/pioneer` + `pioneer_reserved` no Remote Config) e prazo
  (`pioneer_until`, opcional). O servidor **não barra** a compra 201: a
  compra acontece na loja, e o webhook só conta. Ao chegar perto de 200,
  tirar o vitalício da oferta no RevenueCat. Quem comprar nesse intervalo
  fica com o Pioneiro.
- **Builds antigos:** a 1.0.49 só conhece `plus_founder_annual` como
  Pioneiro e mostra qualquer pacote vitalício da oferta `current` como
  "Vitalício" comum, sem contador. Antes de pôr o vitalício na oferta:
  targeting por versão do app no RevenueCat (1.0.49 fica na oferta antiga)
  ou `minBuild` 51 no card de versão.
- Mensal + Pioneiro na mesma conta (26 nov 2026): o fim ou o cancelamento
  do mensal não desliga mais o Plus no servidor. Antes de gravar um estado
  desligado ou com data de fim, o webhook consulta o entitlement da conta
  no RevenueCat (`withAccountLookup`, precisa de `REVENUECAT_SECRET_KEY`).
  A consulta só mantém ou liga, nunca desliga. O paywall ainda não avisa
  quem tem o mensal que ele continua cobrando depois do vitalício.
- O site mostra o Pioneiro com `PIONEER_ON_SALE` fixo em
  `site/planos/planos.js`: desligar à mão quando esgotar (ou ler
  `stats/pioneer`, que tem leitura pública).

### Casal e Família (só anual)

O mesmo Peregrino+ em 2, 3 ou 4 contas, pelo entitlement no servidor
(`users/{uid}.plusActive`), com convite e não Family Sharing da loja
(funciona entre Android e iOS). Quanto mais gente, menor o preço por
pessoa. Regra: anual individual + R$ 50 pela 2ª pessoa, + R$ 40 pela
3ª, + R$ 30 pela 4ª.

| Plano | Anual | Por pessoa | Desconto sobre N × R$ 89,90 |
|---|---|---|---|
| Casal | R$ 139,90 | R$ 69,95 | 22% |
| Família 3 | R$ 179,90 | R$ 59,97 | 33% |
| Família 4 | R$ 209,90 | R$ 52,48 | 42% |

Sem mensal nesses planos (menos produtos na loja; família assina para
o ano). Nada de recurso exclusivo além do compartilhamento.

Como funciona (functions/family.js, 25 nov 2026):
- Produtos `plus_casal_annual`, `plus_familia3_annual`,
  `plus_familia4_annual` na oferta RevenueCat `familia`, mesmo grupo de
  assinatura e entitlement `peregrino_plus`.
- O webhook cria `families/{titular}` (vagas, fim, código de 6 letras).
  Convite: `stway://familia/CODIGO` ou `stway-app.web.app/abrir/familia?c=`.
- Entrar é a callable `familyAction` (join): reserva a vaga e dá Plus
  promocional no RevenueCat até o fim do titular + 3 dias. Renovação
  estende; fim, reembolso ou troca para individual pausa o plano e tira
  o promocional (membros ficam na lista e voltam se o titular reassinar).
- Quem já paga o próprio Plus (assinatura que renova ou vitalício) não
  entra: pagaria duas vezes.
- Perfil › Minha família: titular convida, tira pessoas e gera link novo;
  membro vê quem paga e pode sair.
- Depende do segredo `REVENUECAT_SECRET_KEY` (sk_) nas functions.

### Pastor, missionário e igrejas (por contato)

- **Pastor / Missionário: grátis**, pedido pelo formulário de contato.
  Ganha Plus + ferramentas de líder (grupos), para levar a igreja.
  Concessão por entitlement promocional do RevenueCat (1 ano,
  renovável), liberado pelo painel admin (Usuários › Suporte › Dar bolsa
  pastoral; grava `pastorGrants/{uid}`). Contra abuso: nome da igreja,
  cidade e um link (Instagram, site ou CNPJ); 1 concessão por igreja;
  renova por ano. O painel exige os três campos e barra a 2ª concessão
  da mesma igreja (`churchKey` em `functions/moderation.js`).
- O formulário de contato do site ainda é genérico (nome, e-mail,
  assunto, mensagem): o pedido chega em texto livre e o admin copia
  igreja, cidade e link à mão. Campos próprios: a fazer.
- **Igreja Pequena, Igreja e Rede: preço sob consulta** no lançamento.
  Venda conversada pela web (Pix, boleto) para aprender o que a igreja
  quer antes de fixar tabela. Regra de partida: líderes recebem Plus
  completo; membros têm acesso ao que o grupo estuda, não ao Plus
  inteiro (Plus inteiro para 250 membros mataria o individual).
- Sem plano Líder avulso no lançamento.

Igreja não é sistema de gestão (esses custam R$ 50–350/mês no Brasil);
é formação: painel do líder, grupos estudando juntos, trilhas da igreja.

### Apoio avulso

Oferta RevenueCat `apoio`: **R$ 5 / 15 / 30 / 50**. Pagamento único, não
libera recurso, dá o selo de apoiador. Some das telas enquanto a oferta
não existir na loja.

---

## Fases

### Fase 0 — Ativação (antes de cobrar qualquer real)

A infraestrutura está pronta e testada (paywall, gates em profundidade,
cache com dono e graça de 7 dias, funil completo, elegibilidade de trial,
webhook, rules, Família, bolsa pastoral). Falta o que não é código.

Decisões fechadas: preços da tabela acima (25 nov 2026); Pioneiro é
vitalício, produto separado; `plus_launch_free_until` fica **vazio
durante a review da Apple** e só é preenchido depois da aprovação;
A Promessa não atrasa a loja.

Checklist (estado em 26 nov 2026):

1. [ ] Cravar os preços desta tabela nas lojas, em BRL direto
2. [ ] Produtos na loja: `plus_annual` (R$ 89,90, trial 14 dias),
   `plus_monthly` (R$ 9,90), `plus_pioneer_lifetime` (não consumível,
   R$ 149,90, sem trial), `plus_casal_annual` / `plus_familia3_annual` /
   `plus_familia4_annual` (mesmo grupo de assinatura), `apoio_5/15/30/50`
3. [ ] RevenueCat: entitlement `peregrino_plus`, oferta padrão, ofertas
   `familia` e `apoio`; vitalício protegido dos builds antigos (ver
   Pioneiro)
4. [x] Chave Android no app (desde a 1.0.39). [ ] Chave iOS: espera a
   mudança da conta da Apple
5. [x] Functions com `REVENUECAT_WEBHOOK_AUTH` e `REVENUECAT_SECRET_KEY`
   (sk_) e rules no ar. Webhook com a correção do mensal + Pioneiro
   publicado em 26 nov 2026
6. [ ] Sandbox: comprar, trial, restaurar, gerenciar, cancelar, um apoio,
   Família (convite e saída), mensal + Pioneiro na mesma conta —
   **e conferir com uma conta que já usou o trial** se nenhuma tela
   promete teste grátis (no Android a elegibilidade vem como
   desconhecida e o app mostra o trial; quem decide é a loja na compra)
7. [ ] D7 com testadores antes de escalar divulgação do paywall (sem
   dado ainda)

Ordem de deploy (já seguida): functions + segredo do webhook →
firestore.rules → build com chaves. Checklist das lojas em
`app-review-notes-iap.md` (material das lojas, guardado fora do
repositório).

Acesso sem loja: no iOS (sem chave) o build abre tudo, fail-open
intencional, e `plus_launch_free_until` mostra o aviso. No Android (com
chave) o gate fecha sem Plus mesmo se a oferta falhar; o cache do último
entitlement segura o assinante até vencer + 7 dias.

### Fase 1 — Lançamento enxuto

O Plus de hoje, organizado pelos pilares 1 e 2:

- Caminhadas de temporada completas (1º dia grátis) + revisão da temporada
- Revisão inteligente **semanal** (fecha a semana de estudo; na
  temporada, o fechamento da semana da Caminhada a substitui — a
  Revisão do Dia foi aposentada: um fluxo de revisão por semana basta),
  reforço do ponto fraco, erros explicados no perfil
- Planos guiados completos (3 dias grátis de amostra por plano; recomeçar
  não renova a amostra)
- Constância e acerto por modo/gesto no perfil
- Selo de apoiador
- **A Caminhada Premium de referência** (A Promessa) como demonstração —
  entra no lançamento se a montagem editorial (≥70% reaproveitada) couber
  sem atrasar o D7; senão, é o primeiro grande lançamento seguinte

### Fase 2 — Evolução pedagógica

- **Sessão única de revisão** (degrau 2): a Revisão inteligente semanal
  e o fechamento da temporada viram uma sessão só com escopo variável
  (dia/semana/temporada) — uma entrada na Home, título e capa por edição.
  O degrau 1 já está no ar: no máximo 1 fluxo de revisão por dia, com
  hierarquia temporada > semana > dia (`reviewSlotDays` no progresso;
  ofertas somem até o dia seguinte)
- Repetição espaçada de verdade: agenda única do que revisar hoje
  (perguntas + versículos), sobre a fila de erros e a memorização atuais
- ~~“Explique meu erro”~~ — **construído em out/2026** como página do
  perfil (“Seus erros explicados”): os erros guardados com a resposta
  certa e o porquê (`feedbackCorrect` do banco), a um toque do cartão
  de acerto; já é benefício listado no paywall
- ~~Instrumentação de domínio~~ — **coletando desde out/2026**: acerto
  por trilha (`trailAnswerCorrect/Total`) gravado junto do `modo.gesto`,
  no payload e na restauração. O mapa de domínio nasce meses depois,
  com dado acumulado — não prometer antes
- Planos personalizados por objetivo (conhecer o AT, Evangelhos, doutrina…)
- ~~**STWAY Família**~~ — **construído em 25 nov 2026** (Casal, Família 3
  e 4; ver acima). Sai na 1.0.50

### Fase 3 — Expansão

- Conexões bíblicas aprofundadas como **programa editorial** contínuo
  (ritmo de editor, não data de feature)
- Jornadas cooperativas e desafios em grupo (ligar `groups_enabled`,
  `companion_enabled`, `challenge_enabled` com moderação pronta)
- **STWAY Igreja**: painel de líderes e grupos, web com Stripe + Pix.
  Hoje: piloto por contrato e Pix (`docs/ACORDO_IGREJA_PILOTO.md`), sem
  checkout na web
- ~~Bolsa pastoral no admin~~ — **construída em 25 nov 2026**
- Checkout pela web (Web Purchase Links do RevenueCat): o site já tem o
  lugar (`CHECKOUT` em `site/planos/planos.js`), vazio. A meta description
  de `site/planos/` ainda diz "Assine pelo site": corrigir até ligar

---

## Como aparece (e como não aparece)

Nunca: splash, login, onboarding, primeira trilha, no meio da cena.

**Automático, no máximo 1×/semana** (Home, sem outra folha aberta; cada
oferta uma vez na vida):

- Promoção de lançamento acabando (≤7 dias) ou acabada
- 7 cenas concluídas (conta com 2+ dias — maratona de dia 1 não dispara)
- Winback: 2 semanas depois que o Plus acabou; de novo perto de 1 ano

**No ponto do recurso:** dia 4+ da Caminhada, revisões sem Plus, perfil sem
Plus (teaser no lugar da constância/acerto), banner de cobrança na Home
(falhou → graça → 1ª semana pós-vencimento) e Ajustes (plano, restaurar,
gerenciar).

Todo o funil é medido: `paywall_view/dismiss/plan_select/purchase/restore`,
`plus_offer_sheet` (view/cta/dismiss por tipo), `plus_feature_open`.

## Metas (90 dias depois de ligar)

Hipótese a validar com D7 real, não medida ainda:

| | Base | Esticar |
|---|---|---|
| Trial entre quem chegou em D7 | 8–12% | 15% |
| Trial vira pago | 28–38% | 42% |
| Free vira Plus sem trial | 1,5–3% | 4% |
| Pagantes / D7 | **4–6%** | 8% |
| Receita nova em anual | ≥ 60% | ≥ 75% |
| D7 vs antes do paywall | não cair > **5%** | 0% |

---

## Estado no app (26 nov 2026)

Versão na loja: 1.0.49. A 1.0.50 (build 51) leva Pioneiro vitalício,
Casal/Família e bolsa pastoral; ainda não está nas lojas.

Chaves: `_apiKeyAndroid` preenchida (desde a 1.0.39), `_apiKeyIos`
vazia. No Android vale o entitlement ou o cache (até vencer + 7 dias de
graça); oferta vazia ou falha de rede **não** abre. No iOS o SDK não
inicia e tudo fica aberto.

| Peça | Estado |
|---|---|
| Paywall (Ajustes, perfil, revisões, ofertas, banner de cobrança) | Pronto, com Restaurar/Termos/Privacidade/EULA em todos os estados |
| Gates | Em profundidade: telas, `_start` e `LessonScreen(requiresPlus)` |
| Cache de entitlement | Com dono (uid), graça de 7 dias, aposentado quando a loja responde |
| Amostra de plano guiado | 3 dias por plano, registrada (`guidedSampleDays`); recomeçar retoma, não renova |
| Trial | 14 dias só no anual; só prometido com elegibilidade confirmada (`trialDaysFor`; no Android, desconhecida conta como elegível) |
| Pioneiro | Vitalício `plus_pioneer_lifetime`, contador e prazo no card (`_PioneerCounter`), some quando esgota (`packagesForSale`) |
| Casal / Família | `FamilyService` + `functions/family.js`, oferta `familia`, convite por código e link |
| Bolsa pastoral | Admin › Usuários › Suporte, `pastorGrants/{uid}`, 1 por igreja |
| Funil | View/dismiss/plano/compra/restore + folha de oferta + abertura de recurso. Admin › Funil conta Pioneiro pelos dois ids (vitalício e anual antigo) |
| Winback | Semana 2 e ~1 ano, com histórico semeado do cache e amarrado à conta |
| Webhook RevenueCat → Firestore | No ar, com o segredo. Trata TRANSFER nos dois sentidos, vitalício, Família e, desde 26 nov, consulta a conta antes de desligar (mensal + Pioneiro) |
| Selo de apoiador | Só o webhook grava; rules barram o cliente |
| Checkout web / Igreja com Stripe | Não existem. Site leva para a Play Store |

Pioneiro no código: `PlusAccess.pioneerProductId = 'plus_pioneer_lifetime'`
(`plus_founder_annual` reconhecido como Pioneiro antigo). Enquanto
`pioneerOnSale`, o paywall mostra anual, Pioneiro e mensal; selecionado,
o card do Pioneiro mostra vagas e prazo. O laboratório (`plus_lab_screen`)
simula a loja com mensal, anual, vitalício, Casal/Família e apoio, e
simula "Pioneiro esgotado".
Revisões não empilham: 1 fluxo/dia com hierarquia (temporada > semana >
dia), registro compartilhado `reviewSlotDays` e ofertas suprimidas.

Selo de Peregrino (só assinante) e selo de Apoiador (só apoio avulso)
são selos distintos, no perfil e na Caravana (`plusActive` do webhook).
Quem tem o Pioneiro vê o selo **Pioneiro** no lugar do de Peregrino (um
selo só; `plusActive` + `plusProductId` do webhook, e `hasPioneerBadge`
no próprio perfil). No vitalício o selo não vence. A 1.0.49 só reconhece
`plus_founder_annual`: nela, quem comprou o vitalício aparece com o selo
de Peregrino. Para "Pioneiro" ter um sentido só, a medalha dos
testadores se chama **Desbravador**: vem da marca
`users/{uid}.desbravador`, gravada só por
`admin/scripts/mark_desbravadores.mjs` (rules barram o cliente), não
mais da data da primeira abertura. Rodar com `--all-current --apply`
antes do lançamento; se os dados forem zerados, rodar de novo com
`--file exports/desbravadores.json` depois do reset.

Testes: functions 101 passando (29 no webhook) em 26 nov 2026.
