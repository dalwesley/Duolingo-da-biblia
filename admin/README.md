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
4. Publique conteúdo (ver secção **Seed** abaixo).

Ou no painel **Importar**, envie:
   - `trails.json`
   - `genesis_questions.json`, `exodo_questions.json`, `ot_questions.json`, `nt_questions.json`
   - `mission_studies.json`

## Seed (publicar JSON → Firestore)

O app lê o currículo da nuvem. Seed = copiar `trilha_app/assets/data/*.json` para Firestore (`trilha-biblia`).

### Comandos (como fizemos)

Caminho real com conta Google-only (`stway.app@gmail.com`): **Firebase CLI**, não Email/Password.

```bash
# Da raiz do monorepo — trilhas + banco + estudos + catalog.version
make seed_full
# equivalente:
cd admin && npm run seed:cli

# Só o banco (SEED_ONLY=bank por default no Makefile)
make seed
make seed SEED_ONLY=ot
```

`npm run seed:cli` = `node scripts/seed_content_cli.mjs` (OAuth do `firebase login`).  
`npm run seed` = client SDK Email/Password (`seed_content.mjs`) — falha em contas Google-only.  
Pipeline de conteúdo: `npm run pipeline:v2` (purge → author handcraft Êxodo/Sermão → build → repair → validate). Seed recusa banco inválido.

Disco local + Firestore **24 ago 2026:** 8.370 atos, validador verde, palco TB · `catalog.version` 1787584947461.

### Auth — o que NÃO fazer

As contas donas do projeto (`stway.app@gmail.com`, `contato.wocto@gmail.com`, `dalwesley@gmail.com`) entram com **Google**. No Authentication elas **não têm** senha de E-mail/senha (`passwordHash` ausente).

Por isso:

- **Não** use “Reset password” no Console como fluxo padrão do seed — isso não é como publicamos conteúdo.
- `SEED_EMAIL` / `SEED_PASSWORD` no `.env` **só** funcionam se existir um user **Email/Password** cujo `uid` está em `admin_users` com role `admin`/`editor`.
- Conta Google no `.env` → `INVALID_LOGIN_CREDENTIALS` / “conta existe, senha não é E-mail/senha”.

`admin_users` conhecidos (ago/2026): `contato.wocto@gmail.com`, `dalwesley@email.com` (Apple). Bootstrap está **locked** (`content_meta/bootstrap_locked`) — novos admins só via Console / admin existente.

### Quando o `.env` email/senha falhar (caminho real)

1. Confirme CLI logado no projeto: `firebase login` / `firebase projects:list` (conta `stway.app@gmail.com`).
2. Esse login OAuth do Firebase CLI **pode escrever** no Firestore via API REST (mesmo owner do projeto) — foi assim que o Sermão (470 Qs) subiu em 14/ago/2026 quando o client SDK recusou e-mail/senha.
3. Alternativa estável: no Console, **Add user** com e-mail/senha **só para seed**, documente em `admin_users/{uid}`, e use esse par no `.env`.
4. Ou: `npm run dev` no painel, entre autenticado, use **Importar**.

Não inventar senha para conta Google-only e colar no `.env` — não vai autenticar o `seed_content.mjs`. Use `make seed_full`.

### Checklist — seed seguro com i18n (pt/en/es)

As traduções EN/ES **não** moram no Firestore. Elas vão no **app** (`trilha_app/assets/l10n/content/`). O Firebase continua sendo a fonte **PT**.

#### ✅ Pode / deve

1. Confirmar login CLI no projeto certo:
   ```bash
   firebase login
   firebase use  # deve ser trilha-biblia (ou o alias do monorepo)
   firebase projects:list
   ```
2. Seed PT a partir dos JSON de sempre (`trilha_app/assets/data/`):
   ```bash
   # Da raiz do monorepo
   make seed_full          # trilhas + banco + estudos + catalog.version
   # ou só um pack do banco:
   make seed SEED_ONLY=ot
   ```
3. Publicar o **app** (APK/AAB/TestFlight) com os overlays em `assets/l10n/content/` — é isso que ativa EN/ES.
4. Conferir no app: Ajustes → idioma **Português** ainda mostra PT; English/Español trocam UI + overlays.

#### ❌ Não faça

1. **Não** cole EN/ES por cima dos campos PT no Firestore (`title`, `question`, `prompt`, etc.) — usuário em PT passa a ver outro idioma.
2. **Não** renomeie `id` / `slug` de pergunta ou missão só por causa de tradução — o overlay casa por id; muda o id e some a tradução.
3. **Não** apague `passageText` / `verseRef` / tokens do versículo — ficam em PT de propósito.
4. **Não** rode purge/rebuild do pipeline (`npm run pipeline:v2`) “só para traduzir” — isso reescreve o banco pedagógico.
5. **Não** suba `questions_en.json` / `trails_en.json` como se fossem `*_questions.json` no Importar do painel.
6. **Não** use `seed_content.mjs` (email/senha) com conta Google-only — use `make seed_full` / `seed:cli`.

#### Ordem recomendada (release com idioma)

1. Seed PT estável (`make seed_full`) se o currículo mudou.
2. Build do app com overlays (`flutter build …`).
3. Testar: pt → en → es → pt de novo (trilhas, uma cena, uma pergunta V/F e uma choice).
4. Só então publicar na loja.

#### Se algo der errado

- PT sumiu / virou inglês no Firestore: restaurar seed PT (`make seed_full`) — overlays no app **não** alteram a nuvem.
- EN/ES sem tradução mas UI traduzida: conferir se o binário inclui `assets/l10n/content/` e se o locale não é `pt`.
- Overlay “não pega”: ids no Firestore diferentes dos do JSON local — alinhar seed com `assets/data/`.

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
