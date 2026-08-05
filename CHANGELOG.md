# Changelog

Todas as mudanças notáveis do STWAY (app Flutter + admin).

Formato inspirado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento do app: `trilha_app/pubspec.yaml` (`1.0.x+build`).

---

## [Unreleased]

Trabalho em curso (ainda não versionado em release).

### Changed
- Perguntas/memória mais game: badge DESAFIO/BÔNUS, sem narrativa itálica, Dica (não Sussurro), tiles 3D, VERIFICAR, feedback Acertou!/Errou!, vidas no HUD
- Card CTA da home: em risco = poeira + teias + aranha; gelo usado = geada/cristais; em dia = vidro limpo com reflexo e bisel
- Memória: pontuação do verso (reticências → frases), blank preserva vírgula/ponto, header sem título duplicado

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
