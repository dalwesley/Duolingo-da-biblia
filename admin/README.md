# STWAY Admin

Painel web (estilo Ipsat/Satélite) para gerenciar **trilhas**, **cenas**, **passos**, **perguntas** e **estudos (preparo)** no Firebase — sem precisar publicar nova versão do app.

Hierarquia no app e no painel: **Trilha → Cena → Passo → Preparo → Perguntas**.

## Stack

- Vite + JS vanilla + Firebase (mesmo padrão de `/dev/satelite/admin`)
- Firestore collections:
  - `content_trails/{slug}`
  - `content_bank_questions/{id}`
  - `content_difficulties/{id}`
  - `content_mission_studies/{slug}`
  - `content_question_reports/{id}`
  - `content_meta/catalog` (versão)
  - `admin_users/{uid}`

## Setup

```bash
cd admin
cp .env.example .env   # ajuste VITE_FIREBASE_APP_ID (app Web no Console)
npm install
npm run dev            # http://localhost:5174
```

### 1. Firebase Console

1. Crie um **app Web** no projeto `trilha-biblia` e cole o `appId` em `.env`.
2. Habilite **Authentication → Email/Password** (e Anonymous só se for usar skip auth em dev).
3. Publique as regras:

```bash
cd ..
firebase deploy --only firestore:rules
```

### 2. Primeiro admin

1. Crie um usuário em Authentication.
2. Em Firestore, crie `admin_users/{UID}`:

```json
{
  "email": "voce@email.com",
  "role": "admin",
  "permissions": { "trails": true, "bank": true, "studies": true }
}
```

3. Entre no painel com esse e-mail/senha.
4. Publique conteúdo pelo pipeline V3 (`npm run v3:publish`) — ver [`v3/README.md`](v3/README.md).

## Conteúdo (Firestore)

O app lê o currículo da nuvem (`content_trails`, `content_bank_questions`, `content_mission_studies`). A fonte é o banco V3 em `admin/v3/<trilha>/` (e `admin/pilot/genesis-1-11/`), publicado com `npm run v3:publish`. As trilhas de motivo Conhecer e Entender usam `perguntas-v2/` via `scripts/seed_entry_motive_banks.mjs`.

As traduções EN/ES **não** moram no Firestore: vão no app (`trilha_app/assets/l10n/content/`, gerado por `npm run v3:translate`). O Firestore é a fonte **PT**.

- **Não** cole EN/ES por cima dos campos PT no Firestore — usuário em PT passa a ver outro idioma.
- **Não** renomeie `id` / `slug` de pergunta ou missão por causa de tradução — o overlay casa por id.
- **Não** apague `passageText` / `verseRef` / tokens do versículo — ficam em PT de propósito.

### Auth

As contas donas do projeto (`stway.app@gmail.com`, `contato.wocto@gmail.com`, `dalwesley@gmail.com`) entram com **Google** e não têm senha de E-mail/senha. Os scripts usam o OAuth do `firebase login` (CLI) para escrever no Firestore. Bootstrap está **locked** (`content_meta/bootstrap_locked`) — novos admins só via Console / admin existente.

### Auditoria de rankings (Caravana)

As regras do Firestore validam que o placar em qualquer coleção de ranking (`leagues/`, `overallPlayers/`, `monthlyLeagues/`, `rooms/*/members/`) seja exatamente o mesmo valor gravado em `users/{uid}`. Isso impede que um cliente infle o próprio placar diretamente.

Antes do D7 e sempre que mexer em regras de pontuação:

```bash
# Da raiz do monorepo:
make audit_rankings       # lista inconsistências (dry-run)
make audit_rankings_fix   # corrige xp no ranking para espelhar users/{uid}
make deploy_rules         # publica firestore.rules no projeto
```

Testes da lógica de espelhamento:
```bash
make test_rankings
```

## Deploy do painel

```bash
npm run build
cd ..
firebase deploy --only hosting:panel
```

(`../firebase.json` aponta o alvo `panel` para `admin/dist`. O site público é o alvo `app`, em `site/`.)

## App Flutter

`ContentCatalogService` lê o Firestore, cacheia JSON em disco (`content_catalog/`) e compara `content_meta/catalog.version`. Currículo **não** vem empacotado no APK (só Bíblia + Strong). Question Studio: `admin/src/question-studio.js`.
