# STWAY — formação bíblica com hábito

App Flutter para aprender a Bíblia em missões diárias + painel admin no Firebase.

**Academia da Palavra:** Duolingo no loop · escola no conteúdo.

| Doc | Conteúdo |
|-----|----------|
| [`docs/PRODUTO.md`](docs/PRODUTO.md) | Visão, usuários, features, glossário |
| [`docs/TECNICA.md`](docs/TECNICA.md) | Arquitetura, stack, Firestore, sync |
| [`ROADMAP.md`](ROADMAP.md) | Norte, checklist e prioridades |

## Projetos

| Pasta | O quê |
|-------|--------|
| `trilha_app/` | App nativo (iOS / Android) |
| `admin/` | Painel admin (Vite + Firebase) |

## App Flutter

```bash
cd trilha_app
flutter pub get
flutter run
```

Detalhes em [`trilha_app/README.md`](trilha_app/README.md).

## Painel admin

```bash
cd admin
cp .env.example .env   # se ainda não tiver
npm install
npm run dev            # http://localhost:5174
```

Detalhes em [`admin/README.md`](admin/README.md).
