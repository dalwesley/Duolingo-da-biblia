# Steway Admin

Painel web (estilo Ipsat/Satélite) para gerenciar **trilhas**, **cenas**, **passos**, **perguntas** e **estudos (preparo)** no Firebase — sem precisar publicar nova versão do app.

Hierarquia no app e no painel: **Trilha → Cena → Passo → Preparo → Perguntas**.

## Stack

- Vite + JS vanilla + Firebase (mesmo padrão de `/dev/satelite/admin`)
- Firestore collections:
  - `content_trails/{slug}`
  - `content_bank_questions/{id}`
  - `content_difficulties/{id}`
  - `content_mission_studies/{slug}`
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
4. Normaliza banks/estudos e publica tudo:

```bash
npm run prepare:content   # opcional (já roda dentro do seed)
npm run seed              # sobe trails + genesis/exodo/ot/nt + studies
```

Ou no painel **Importar**, envie:
   - `trails.json`
   - `genesis_questions.json`, `exodo_questions.json`, `ot_questions.json`, `nt_questions.json`
   - `mission_studies.json`

## Deploy do painel

```bash
npm run build
cd ..
firebase deploy --only hosting
```

(`../firebase.json` aponta para `admin/dist`.)

## App Flutter

`ContentCatalogService` lê o Firestore, cacheia em `SharedPreferences` e cai nos assets locais se offline / vazio.
