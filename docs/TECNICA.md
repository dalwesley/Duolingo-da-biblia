# STWAY — Documentação técnica

**Atualizado:** ago/2026  
**Monorepo:** `trilha_app/` (Flutter) + `admin/` (Vite)  
**Firebase project:** `trilha-biblia`

---

## Visão geral da arquitetura

```
┌─────────────────────┐         ┌──────────────────────┐
│  trilha_app (Flutter)│         │  admin (Vite + JS)   │
│  Google Sign-In      │         │  Email/Password      │
│  ContentCatalog      │◄───────►│  CMS + seed scripts  │
│  Progress / Social   │         │  Relatos / Release   │
└──────────┬──────────┘         └──────────┬───────────┘
           │                               │
           └───────────┬───────────────────┘
                       ▼
              Cloud Firestore
         content_*  ·  users  ·  leagues
         rooms  ·  companies  ·  admin_users
```

Currículo é **fonte de verdade no Firestore**. O app sincroniza por versão (`content_meta/catalog.version`) e cacheia em disco. Mudanças de conteúdo **não exigem** release na loja.

---

## Projetos

| Pasta | Stack | Papel |
|-------|-------|--------|
| `trilha_app/` | Flutter, Dart ^3.12, Provider, Firebase | App iOS/Android |
| `admin/` | Vite 6, JS vanilla, Firebase SDK 11 | CMS + tooling de conteúdo |
| raiz | `firebase.json`, `firestore.rules` | Hosting admin + regras |

Não há app Next.js na raiz (ver `AGENTS.md`).

---

## App Flutter (`trilha_app`)

### Stack

| Camada | Escolha |
|--------|---------|
| UI | Material 3, tema escuro (`AppTheme.dark`), `google_fonts` |
| Estado | Provider + `ChangeNotifier` |
| Auth | Firebase Auth + **Google Sign-In** (obrigatório) |
| Backend | Cloud Firestore |
| Analytics | Firebase Analytics + Crashlytics (off em debug) |
| Local | SharedPreferences, JSON em disco (catálogo), sqflite (Strong) |
| Notificações | `flutter_local_notifications` (sem FCM) |
| Outros | audioplayers, share_plus, qr_flutter, mobile_scanner, home_widget, app_links |

### Estrutura `lib/`

```
lib/
  main.dart                 # MultiProvider + MaterialApp
  firebase_options.dart     # opções Firebase (Android configurado)
  screens/                  # telas
  widgets/                  # UI reutilizável
  services/                 # domínio + Firebase
  models/                   # Trail, difficulty, quests, rooms…
  data/                     # TrailRepository, bancos auxiliares
  theme/                    # AppTheme, cores
  utils/                    # helpers
  cinematic/                # ícones cinemáticos
```

### Serviços principais

| Serviço | Responsabilidade |
|---------|------------------|
| `BackendService` | Init Firebase, auth Google, backup user, ligas/salas/companias |
| `ProgressService` | Passos, streak, missões, settings; mapa local + nuvem |
| `ContentCatalogService` | Currículo Firestore + cache em disco |
| `LeagueService` | Tiers semanais promote/demote |
| `RoomService` / `CompanionService` | Salas e companhia 1:1 |
| `NotificationService` | Lembretes de hábito |
| `SyncService` | Device ID + export/import JSON |
| `BibleService` / `BibleStudyService` | Bíblia + Strong offline |
| `AppUpdateService` | Soft/force update via `content_meta/app_release` |
| `AnalyticsService` | Funil de eventos |
| `QuestionReportService` | Relatos de pergunta |
| `InviteDeepLinkService` | `stway://companhia/…` |
| `HomeWidgetService` | Widget da home |

### Fluxo de bootstrap

1. Splash aguarda init do backend (até ~8s)  
2. Sem Google → `LoginScreen`  
3. Hidrata `users/{uid}` → onboarding ou `MainShell`  
4. Catálogo: cache disco → compara versão → fetch se stale  

### Navegação

- Shell com 5 tabs (`MainShell` / `main_bottom_nav.dart`)  
- Rota nomeada: `/lesson` (`missionSlug`)  
- Demais: `MaterialPageRoute`  
- Deep link: `stway://companhia/CODIGO`

### Modelo de conteúdo (app)

```
TrailRealm
  └── TrailCategory
        └── Trail (slug, unlockAfter, comingSoon, modules[])
              └── TrailModule (cenas)
                    └── Mission (lesson | boss)
```

Dificuldades: `semente` | `caminhada` (Rota) | `profundezas` — ver `models/difficulty.dart`.

### Assets offline (empacotados)

- `assets/data/bible_tb.json`, `bible_jfaal.json`  
- `assets/data/bible_study.sqlite.gz`  
- `assets/sounds/`  

Currículo **não** é o primary package do app (JSONs em `assets/data/` servem seed/admin).

### Plataformas

| | Status |
|--|--------|
| Android | Caminho de release documentado (`com.trilha.trilha_app`) |
| iOS | Display name STWAY; Firebase/`firebase_options` ainda pendente para iOS |

Detalhes de store/keystore: `trilha_app/RELEASE.md`.

---

## Painel admin (`admin`)

### Stack

- Vite 6 (dev em `:5174`)  
- **Vanilla JS** (não React)  
- Firebase Auth (email/senha) + Firestore  
- Hosting: `firebase deploy --only hosting` → `admin/dist`

### Rotas SPA (`src/main.js`)

| Rota | Função |
|------|--------|
| `dashboard` | Contagens, versão do catálogo, `app_release` |
| `trails` / `trail:{slug}` | CRUD de trilhas e editor aninhado |
| `bank` | Banco reutilizável de perguntas |
| `studies` | Preparos por slug de passo |
| `reports` | Moderação de relatos |
| `import` | Upload JSON em lote |

### Auth e papéis

- Produção: Email/Password + doc em `admin_users/{uid}`  
- Dev: `VITE_ADMIN_SKIP_AUTH=true` (bloqueado em build de produção)  
- Roles: `admin` (tudo) · `editor` (via `permissions.trails|bank|studies`)  

### Módulos chave

`firebase.js`, `auth.js`, `roles.js`, `db.js` (mapa `COL` + `bumpCatalogVersion`), páginas `*-page.js`, scripts em `admin/scripts/` (`seed`, `prepare:content`).

---

## Firestore

### Conteúdo (leitura pública; escrita só editors)

| Path | Uso |
|------|-----|
| `content_trails/{slug}` | Árvore completa da trilha |
| `content_bank_questions/{id}` | Banco de perguntas |
| `content_difficulties/{id}` | Metadados de dificuldade |
| `content_mission_studies/{slug}` | Preparo do passo |
| `content_meta/catalog` | `{ version }` — sinal de sync |
| `content_meta/verses` | Mapa de textos de refs (opcional) |
| `content_meta/app_release` | Soft/force update |
| `content_question_reports/{id}` | Relatos (user cria; editor modera) |

Todo `saveDoc` / `removeDoc` / `batchSet` no admin chama `bumpCatalogVersion()`.

### Usuário e social

| Path | Uso |
|------|-----|
| `users/{uid}` | Progresso + campos de liga |
| `leagues/{week}/…` | Liga semanal e tiers |
| `monthlyLeagues/{month}/…` | Ranking mensal |
| `overallPlayers/{uid}` | Mirror global |
| `rooms/{code}` + `members` | Salas |
| `companies/{code}` | Companhias |
| `admin_users/{uid}` | Perfis do CMS |

Regras: `firestore.rules` (`isAdmin`, `isContentEditor`).

### Sync no app (`ContentCatalogService`)

1. Lê cache em `content_catalog/` (app support)  
2. Compara `content_meta/catalog.version`  
3. Se desatualizado/ausente → baixa collections e persiste JSON  
4. Primeira abertura sem rede e sem cache: currículo indisponível até sync  

---

## Learning Engine v2 — schema e migração

Diretriz: [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md).  
Piloto: [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md).

### Hierarquia de dados (alvo)

```text
JORNADA (progressão narrativa — doc / roadmap)
  └── content_trails/{trailSlug}
        └── modules[]          # CENA
              └── missions[]   # TREINO (slug estável = progresso)
                    └── exercises[] | questions[]  # EXERCÍCIO
```

`missions[].slug` permanece a chave de progresso (`ProgressService`). “Missão” no código = **treino** no produto.

### Documento de treino (campos novos em `missions[]` ou `content_trainings/{slug}`)

Campos pedagógicos (todos opcionais na fase 1; obrigatórios no checklist editorial v2):

| Campo | Tipo | Uso |
|-------|------|-----|
| `objective` | string | Objetivo observável |
| `coreKnowledge` | string[] | O que deve ficar |
| `primarySkill` | enum skill | Competência principal |
| `secondarySkills` | skill[] | Secundárias |
| `centralInsight` | string | “Hoje descobri que…” |
| `biblicalReferences` | string[] | Refs canônicas |
| `context` | `{ required, content }` | Só se altera interpretação |
| `connections` | `{ reference, type, explanation }[]` | Tipos: explícita, temática, narrativa, promessa, tipológica, contraste |
| `theology` | `{ concepts: string[] }` | Síntese — não lista solta |
| `review` | `{ concepts, futureTargets }` | Espiral / transferência |
| `depthLevel` | `semente` \| `caminhada` \| `profundezas` | Operação cognitiva |
| `exercises` | Exercise[] | Motor v2 |
| `questions` | Question[] | **Legado** — fallback se `exercises` vazio |

**Skills (enum):** `observe` · `understand` · `contextualize` · `interpret` · `connect` · `synthesize` · `theologize` · `apply`

### Exercise (schema mínimo)

```json
{
  "id": "gen-03-imagem-e01",
  "type": "choice",
  "skill": "observe",
  "prompt": "…",
  "cue": "Toque no texto: …",
  "reference": "Gênesis 1:26–27",
  "passageText": "…",
  "options": [{ "id": "a", "text": "…" }],
  "correctAnswer": "a",
  "feedback": {
    "correct": "…",
    "wrong": { "b": "…", "c": "…", "d": "…" },
    "retryHint": "Observe quem recebe explicitamente a descrição…"
  },
  "revealTextAfterAttempt": false,
  "function": "observe"
}
```

`cue` (opcional): instrução curta de tarefa. Na UI texto-tarefa, o **campo** (`passageText` / `template` / afirmação V/F) é o herói; `cue` fica secundário. `beat`/`function` não aparecem no player.
| `type` | Payload extra |
|--------|----------------|
| `choice` / `true_false` / `text_supported` / `best_interpretation` | `options`, `correctAnswer` |
| `order` | `items[]`, `correctOrder[]` |
| `match` / `classify` | `left[]`, `right[]` ou `categories` + `items`, `correctPairs` |
| `complete` | `template`, `blanks` / alinhado a `VerseFillPanel` |
| `find_in_text` | `passageText`, `targets[]` (spans / frases) |
| `connect` | `passageA`, `passageB`, `options` ou `correctLink` |
| `explain` | `rubricHints[]` (avaliação leve / peer / self) |
| `review` | `sourceTrainingIds[]` + qualquer tipo acima |

### Coleções Firestore

| Path | Fase | Uso |
|------|------|-----|
| `content_trails/{slug}` | agora | Continua árvore; `missions[]` ganha campos v2 |
| `content_bank_questions/{id}` | agora → evolui | Legado MCQ; novos docs podem usar `type` + `skill` |
| `content_exercises/{id}` | fase 2 | Banco tipado reutilizável (revisão / adaptação) |
| `content_trainings/{slug}` | fase 2 (opcional) | Extrair treino do embed se CMS ficar pesado |
| `content_mission_studies/{slug}` | agora | Mantém até campos de contexto/conexões migrarem para o treino |
| `users/{uid}.skillEstimates` | fase 3 | Mapa skill → score interno (não exibir no MVP) |

Bump de catálogo: qualquer save continua via `bumpCatalogVersion()`.

### Compatibilidade no app

```text
LessonScreen / motor
  ├── se mission.exercises?.isNotEmpty → ExercisePlayer (tipos)
  └── senão → fluxo legado (study → quiz MCQ → micro → reflection)
```

| Camada | Mudança |
|--------|---------|
| `models/trail.dart` | `Mission` + campos v2; classe `Exercise`; `Question` permanece |
| `models/difficulty.dart` / bank | `BankQuestion.type`, `skill`; parser ignora tipos desconhecidos |
| `lesson_screen.dart` | Branch exercises vs legado |
| Novos widgets | Um widget por `type` (reuso; sem UI artesanal por passagem) |
| `study_panel.dart` | Pode ler `centralInsight` / `connections` do treino |
| Analytics | `exercise_start/complete` + `skill` + `type` |

### Admin

| Arquivo | Mudança |
|---------|---------|
| `trails-page.js` | `emptyStep` → campos de treino; editor de `exercises[]` |
| `bank-page.js` | Seletor `type` + `skill`; validação por tipo |
| `studies-page.js` | Até migração: manter; depois fundir no editor de treino |
| Checklist | Espelhar [`LEARNING_ENGINE.md` §43](LEARNING_ENGINE.md) antes de publicar |

### Fases de implementação

1. **Schema + CMS + piloto** — campos no treino; tipos `choice` / `true_false` / `connect` / `order` / `find_in_text` / `text_supported`  
2. **Player** — `ExercisePanel` + branch em `LessonScreen`; legado intacto; piloto `gen-03-imagem` via `PilotTrainings` (fallback) e `exercises` em `trails.json`  
3. **Banco `content_exercises`** + revisão/interleaving  
4. **`skillEstimates`** + seleção adaptativa leve  

Não criar componente novo sem necessidade pedagógica recorrente ([§12](LEARNING_ENGINE.md)).

---

## Analytics (funil)

Eventos principais (ver `RELEASE.md` / `AnalyticsService`):

`app_open` → `login` → `home_view` → `difficulty_pick` → `lesson_start` → `lesson_complete`  
(+ eventos de pergunta / relatos conforme instrumentação)

---

## Offline e resiliência

| Área | Comportamento |
|------|----------------|
| Bíblia / Strong | Totalmente offline (assets) |
| Currículo | Cache pós-sync; precisa rede na 1ª carga |
| Progresso | Cache local; hidrata da nuvem no login |
| Backend down | Modo offline parcial no `BackendService` |
| Notificações | Locais (manhã/tarde/noite, semanal, nudges D+1/D+2) |

---

## Comandos úteis

```bash
# App
cd trilha_app && flutter pub get && flutter run
flutter build apk --release

# Admin
cd admin && cp .env.example .env && npm install && npm run dev
npm run seed                  # sobe conteúdo para Firestore
npm run build && cd .. && firebase deploy --only hosting

# Regras
firebase deploy --only firestore:rules

# Regenerar DB Strong
cd trilha_app && python3 scripts/build_bible_study_db.py
```

---

## Segurança (resumo)

- Conteúdo: **read** público; **write** `admin`/`editor`  
- Relatos: authenticated create; editors read/update  
- `admin_users`: self-read; bootstrap controlado por `content_meta/bootstrap_locked`  
- App end-user e admin usam **identidades distintas** (Google vs email admin)  

Não versionar secrets (`.env`, keystores). Ver `trilha_app/RELEASE.md` para SHA Google Sign-In.

---

## Onde olhar no código

| Preocupação | Arquivo |
|-------------|---------|
| Bootstrap / providers | `trilha_app/lib/main.dart` |
| Auth + cloud | `trilha_app/lib/services/backend_service.dart` |
| Progresso | `trilha_app/lib/services/progress_service.dart` |
| Catálogo | `trilha_app/lib/services/content_catalog_service.dart` |
| Modelos de trilha | `trilha_app/lib/models/trail.dart` |
| Persistência admin | `admin/src/db.js` |
| Editor de trilhas | `admin/src/trails-page.js` |
| Regras | `firestore.rules` |

---

## Docs relacionadas

- Produto: [`docs/PRODUTO.md`](PRODUTO.md)  
- Learning Engine: [`docs/LEARNING_ENGINE.md`](LEARNING_ENGINE.md)  
- Piloto Imagem de Deus: [`docs/pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md)  
- Roadmap / norte: [`ROADMAP.md`](../ROADMAP.md)  
- Monetização (plano): [`MONETIZATION.md`](../MONETIZATION.md)  
- Changelog: [`CHANGELOG.md`](../CHANGELOG.md)  
- Setup app: [`trilha_app/README.md`](../trilha_app/README.md)  
- Setup admin: [`admin/README.md`](../admin/README.md)  
