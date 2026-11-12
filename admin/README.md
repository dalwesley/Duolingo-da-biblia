# STWAY Admin

Painel web para revisar e corrigir o conteúdo no Firebase (banco V3), acompanhar relatos e o lançamento — sem publicar nova versão do app.

Hierarquia: **Trilha → Cena → Estudo + Perguntas** (5 gestos por modo: Observação, Compreensão, Interpretação).

## Telas

| Tela | Para quê |
|---|---|
| **Hoje** | Relatos abertos, edições do painel que faltam voltar para os arquivos (`v3:pull`), Pioneiro, versão do app e do catálogo, status do conteúdo por trilha |
| **Explorar** | O catálogo como a aba Explorar do app mostra (`src/catalog-tree.js`, espelho de `trail_catalog.dart`). Migalha = o endereço do peregrino: **Novo Testamento › Mateus › Cena 3**. A cena abre em três abas: **Perguntas** (por modo, com a checagem V3 contra a JFAAL), **Estudo** e **Entrada** (título, verso âncora, Hoje). Link: `#explorar/<trilha>/<cena>/<aba>` |
| **Relatos** | Erros, denúncias e sugestões; “Abrir pergunta” leva ao editor |
| **Suporte** (só admin) | Conta por e-mail/uid (Plus, Pioneiro, relatos) e passe de trilha pelo código. Só leitura |
| **Flags** (só admin) | Valores do Remote Config que o app lê. Mudar é no Console |

As trilhas de Temas (Ansiedade, Conhecer a Deus, Entender a Bíblia) são definidas no app (`trilha_app/lib/data/entry_trails.dart`), não em `content_trails`; por isso a prateleira Temas aparece vazia no painel. Vocabulário: Explorar › trilha › cena › entrada · estudo · perguntas; o recurso de linha do tempo, lugares e personagens (em breve) se chama **Atlas**.

## Corrigir uma pergunta pelo painel

1. **Explorar** → trilha → cena → aba Perguntas → toque na pergunta. O editor mostra todos os campos V3 (dica, feedback por opção errada, `evidenceSpan`), o preview Na hora / Acerto / Erro e a checagem V3 ao vivo.
2. Salvar vale no app na hora. A pergunta fica marcada (`panelEditedAt`).
3. **Antes do próximo publish da trilha**, traga a edição para os arquivos locais:

```bash
npm run v3:pull -- --trail <slug>          # mostra o que mudou
npm run v3:pull -- --trail <slug> --apply  # grava em <trilha>/cenas/*.json
npm run v3:pull                            # lista pendências de todas as trilhas
```

O `v3:publish` **para** se houver edição do painel fora dos arquivos (senão ela sumiria).

**Excluir = lixeira.** Pergunta excluída sai do app na hora e vai para `content_meta/panel_trash` (cópia inteira) por 30 dias. Restaure pelo cartão **Lixeira** no Hoje ou pela lixeira da cena em Explorar; o que passa de 30 dias some ao abrir o Hoje. Restaurar antes do `v3:pull` desfaz a exclusão; depois do pull, o próximo pull põe a pergunta de volta no arquivo. EN/ES vêm do app: depois do pull, rode `v3:translate`.

Teste do editor: `npm run test:panel`.

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

As contas donas do projeto (`stway.app@gmail.com`, `contato.wocto@gmail.com`, `dalwesley@gmail.com`) entram com **Google** (botão “Entrar com Google” no login; o domínio do painel precisa estar em Authentication → Settings → Authorized domains) e não têm senha de E-mail/senha. Os scripts usam o OAuth do `firebase login` (CLI) para escrever no Firestore. Bootstrap está **locked** (`content_meta/bootstrap_locked`) — novos admins só via Console / admin existente.

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
