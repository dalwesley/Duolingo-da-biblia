# Steway — formação bíblica com hábito

App Flutter para aprender a Bíblia em missões diárias + painel admin no Firebase.

Norte e checklist: [`ROADMAP.md`](ROADMAP.md).

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
