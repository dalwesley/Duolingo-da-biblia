# Changelog

Todas as mudanças notáveis do STWAY (app Flutter + admin).

Formato inspirado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento do app: `trilha_app/pubspec.yaml` (`1.0.x+build`).

---

## [Unreleased]

## [1.0.23] — 2026-09-09

### Added
- Push de aceno na companhia (FCM + Cloud Function), mesmo com o app fechado
- Pedido de lembrete depois da 1ª missão — não no primeiro boot
- Convite de um par no pico da 1ª celebração
- Desafio da temporada na Home (depois da meta do dia)
- Paywall / RevenueCat ligado no app
- TTS para leitura em voz alta
- Remote Config no boot

### Changed
- Ranking da caravana: posição à esquerda, pódio ouro/prata/bronze, distância para quem está na frente — sem a barra que ia enchendo
- Semana da caravana só promove/desce com campo real (você + 2 pares)
- Home: desafio, risco da liga e missões do dia só depois da meta diária
- Permissão de notificação só após o prompt (ou o toggle em Ajustes)
- Save de ranking isolado: um documento recusado não derruba os outros

### Fixed
- Firestore aceita o mesmo placar como int ou float — o ranking inteiro deixava de gravar com `PERMISSION_DENIED`
- Celebração não mostra “momento da caravana” quando o ranking ainda é vazio

## [1.0.22] — 2026-08-26

### Added
- **Motor curricular V2:** validador pedagógico (`validate:bank`), purge de clones, pipeline (`pipeline:v2`)
- **Gênesis 1–11 / 12–50 V2:** editorial handcrafted + fill para 6/8 atos por modo
- **Catálogo completo V2:** **8.370** perguntas · 84 trilhas · 432 missões — 6 gestos equilibrados · validador verde · palco TB
- Piloto documentado: [`docs/pilots/genesis-v2.md`](docs/pilots/genesis-v2.md)
- Question Studio no admin (cadastro com preview do verso e copilot)
- Gloss contextual no estudo: chip mostra a palavra da TB, não o homônimo do dicionário

### Changed
- Seed CLI **24 ago**: catálogo local + Firestore alinhados (`catalog.version` 1787584947461)
- **App:** `ContentCatalogService` — limpa cache ao mudar versão; baixa atos por trilha (`ensureTrailBank`); sem pull de 8k no boot (fix crash Firestore OOM)
- Lookup TB: livros de 1 cap (`Obadias 21`), refs compostas, 0 palcos com reticências
- Import admin bloqueia banco com erros pedagógicos; clones `-xch`/`-xfill` ignorados
- Seed CLI: limpeza paginada de órfãos (`SEED_ORPHANS_ONLY`, throttle)
- Toque no palco do Complete: palavra com lacuna + A/B/C, igual Complete
- Chips e choice tiles unificados (`AppSelectChip` / `AppChoiceTile`)
- Estudo Strong: alinha token ↔ versículo (sinônimos TB, sentidos ranqueados, `inVerse`); overlays H8193 / H1961

### Removed
- Código morto do app: `StudyPanel`, `CinematicLessonPanel`, `SequenciaCard`, `StreakRiskBanner`, stack de relato (re-ligado depois), `question_feedback`
- Assets não usados: `brand_logo.png`, `brand_sheet.png`
- Scripts legado (sermao one-shot, python buracos/epístolas, expand/rebuild genesis pré-V2, `seed:refresh` / `prepare` / `migrate` / `enrich`)
- Pasta vazia `public/` e root `scripts/` pré-V2
- API morta `CinematicResolver.forQuestion` + beats explícitos; `ScenePanel`
- `marketing/` movido para `~/dev/stway-marketing` (fora do monorepo)

### Fixed
- **Relato de pergunta** religado no feedback da lição → `content_question_reports`
- Homônimos TBESH e partículas STEP deixam de poluir o chip de estudo

### Content (Firestore)
- Seed V2 **24 ago 2026:** **8.370** atos · 84 trilhas · 432 missões · `catalog.version` **1787584947461**
- (Histórico) Seed V2 **20 ago 2026:** `catalog.version` **1787231875201** · **5.997** órfãos legados removidos
- (Histórico) Seed P0–P6 **18 ago 2026:** 10.368 atos · version `1787096847621`

## [1.0.21] — 2026-08-14

### Added
- Widget iOS ligado (App Group `group.ZS7LYV9Y7U.stway`) — streak e meta na tela inicial; toque abre `stway://hoje`
- Protocolo D7 com planilha `docs/D7_TESTERS.csv` (Sermão do Monte)
- Onboarding em 5 beats: origem → hábito → caminhada → ritmo → primeira trilha

### Changed
- Sermão do Monte e trilhas do Novo Testamento abertos sem exigir o caminho do AT (vitrine D7 / teste interno)
- Copy de produto: unidade curta é **missão** (não “treino”)
- Profundezas da vitrine do Sermão (cena 1, sm-01…05): operações de interpretar / conectar, não clone de Semente
- Settings: conta Apple ou Google (splash e sync não tratam só Google)
- Docs de seed: contas Google-only não usam `SEED_PASSWORD`; fluxo em `admin/README.md` (CLI / Email-Password admin / Importar)

### Fixed
- Extensão do widget voltou a ser embutida no Runner após troca de Development Team
- Deep link do widget (`stway://hoje`) não é tratado como convite de Companhia

---

## [1.0.20] — 2026-08-13

### Added
- Companhia: Animar parceiro com card empoeirado + mensagem por faixa de atraso (1–3 / 4–6 / 7+ dias)
- Link https `…/abrir/juntos/` (WhatsApp-clicável) que redireciona para `stway://juntos`
- Presença na companhia: dias fora, passos semanais à frente/atrás, sync de `lastSeen`
- Prompt de atualização forçado em debug (`FORCE_UPDATE_PROMPT` também em release de teste)
- Grupos canônicos da Bíblia + melhorias na tela da Bíblia / progresso de trilhas

### Changed
- Copy do Animar mais próxima (tom de amigo) e card de share em formato story
- Sheet de update e fluxo de deep link Juntos → Companhia
- Ajustes de UI em celebração, settings, mapa de trilha e journey path

### Fixed
- Share do Animar falhava em silêncio (capture/Opacity 0 + modal no Android)

---

## [1.0.17] — 2026-08-04

### Added
- Game juice: HUD na home (meta/sequência/lâmpadas/gelo), Living Seed reativo, micro-modo “completar verso”, pulso semanal + baú nas Salas
- Celebração com placar (combo, rank na Caravana, “quase sobe”)
- Card **Sequência** na home — dias seguidos, status (risco/gelo/em dia), próximo marco e compartilhar

### Changed
- Ícones: lâmpada do HUD unificada com a lanterna das perguntas; glifos (check, gelo, trilha, elos, voltar, config) no mesmo peso sólido
- Micro-modo “completar verso” cinematográfico: tipografia de verso, cena em glass, slots com pulso, flash de revelação e word bank staggered
- Resultado da caravana (subir/descer/ficar) coleta na Home; promoção abre celebração com confete ao tocar Coletar
- Card “continuar” da home com 3 faces cinematográficas animadas: em risco = empoeirado; congelado só após o gelo cobrir 1 dia; em dia = luz viva; CTAs “Continuar caminhada” / “Retomar caminhada”
- CTA da missão pronta: **Entrar** (em vez de “Começar run”); badges da trilha e das lâmpadas empilhados (sem misturar streak)
- Lembretes de atraso no tom “comendo poeira / ficando pra trás” (slots diários + D+1/D+2 + reforço noturno)
- Onboarding game-first: missão · lâmpadas · streak · Bíblia

### Fixed
- Caravana: lista de pessoas inconsistente entre logins — mescla `tiers/` + board legado; ranking geral prioriza `overallPlayers` com `orderBy`; reload ao abrir a aba e pull-to-refresh

### Removed
- `RunStatusStrip` (substituído pelo header unificado da home)

---

## [1.0.16] — 2026-08-03

### Added
- Plano de leitura bíblica (tela + serviço + modelo)
- Relato de pergunta incorreta/dúvida (sheet no app + página Relatos no admin)
- Sermão do Monte completo: 6 cenas · 31 missões · banco 3 níveis · studies sm-01…25
- Expansão de currículo: Epístolas, Atos/Apocalipse densos, trilhas “buracos” (OT/NT/teologia/vida cristã)
- Caminho canônico Criação→NT jogável com unlock narrativo
- Cronologia bíblica (`bible_chronology.dart`)
- Regras Firestore para reports / conteúdo admin

### Changed
- Estudo na missão (`MissionStudy` / `study_panel`) mais presente no fluxo da lição
- Catálogo e progresso alinhados ao currículo Firebase-first (conteúdo publicado na nuvem)
- `prepare:content` preserva studies do Sermão/`cp-*` e não zera o banco NT sem embutidas
- Ranking da Caravana só com pessoas reais do Firebase (sem bots)
- Ranking geral montado a partir de `users/` (progresso sincronizado), com `overallPlayers` como complemento
- Rules Firestore: autenticados podem ler `users/` para a classificação geral

---

## [1.0.13] — 2026-08-02

### Added
- Feedback pedagógico em resposta errada (ensino, não só “errou”)
- Analytics de perguntas (instrumentação do loop de lição)
- Modo boss real nas missões

### Changed
- Painel cinemático da lição e banco de perguntas ajustados ao fluxo de ensino

---

## [1.0.12] — 2026-07-31

Inclui commits pós-1.0.7 até este bump (UI, sync, companhia).

### Added
- Deep links de convite da Companhia (`stway://companhia`)
- Card da Palavra na home (âncora do dia)
- Celebração cinemática pós-missão

### Changed
- Sync na nuvem por conta: evita misturar cache entre usuários e saves concorrentes apagando progresso
- Splash e branding de abertura mais claros
- Memorizar / flashcards e foco do roadmap na home
- Ajustes sóbrios de UI (home, liga, lição, chrome) sem perder hierarquia de acento
- Persistência de hashes de signing Play para Google Sign-In

### Fixed
- Estabilidade do sync de progresso e salvos em corrida

---

## [1.0.7] — 2026-07-29

### Fixed
- Perguntas da trilha ficam no escopo da missão (sem fallback que misturava capítulos/repetições)

### Changed
- Auto-seleção de Semente quando é o único modo disponível
- Remoção de `AD_ID` do manifest Android

---

## [1.0.6] — 2026-07-28

### Changed
- Arte de splash
- Copy de login mais clara

---

## [1.0.5] — 2026-07-25

Primeiro bump de release para testes Play / distribuição.

### Added
- Documentação do modelo freemium (STWAY Pro + Igreja) em `MONETIZATION.md`
- Preparação Android Play (branding STWAY + docs de signing)

### Changed
- Identidade visual Academia da Palavra (palette, HUD, ImmersiveScaffold)
- Chrome unificado no amarelo Continuar e tokens compartilhados
- Abas e leitura bíblica distintas do amarelo de jogo
- Memorizar: flashcards polidos; glyph de coração nas quests de memória
- Home/auth com aparência persistida entre boots
- Retenção estilo Duolingo: comeback, reparo de streak, lembretes recorrentes
- Widgets de home e cards unificados entre abas

### Fixed
- Overflow do seletor de dificuldade em Profundezas

---

## [1.0.0 – base] — 2026-07

Fundação do produto (pré-bumps de store).

### Added
- App Flutter de missões bíblicas + painel admin Firebase
- Conteúdo de trilhas no Firestore (`content_trails`), workflow Firebase-first
- Expansão curricular AT com modos Semente / Rota / Profundezas
- Liga semanal (ranking) e UI cinemática
- Estudo Strong / Bíblia offline no fluxo de estudo
- Social base: Caravana · Companhia · Salas
- Calendário litúrgico (quests sazonais)

### Changed
- Monorepo simplificado para `trilha_app/` + `admin/` (sem Next.js na raiz)

---

## Links

- Norte e próximos passos: [`ROADMAP.md`](ROADMAP.md)
- Monetização: [`MONETIZATION.md`](MONETIZATION.md)
- App: [`trilha_app/README.md`](trilha_app/README.md)
