# Trilha — Duolingo da Bíblia

App Flutter de aprendizado bíblico gamificado + painel admin no Firebase.

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
