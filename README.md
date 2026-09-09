# STWAY — hábito de ler e estudar a Bíblia

App Flutter para missões diárias + painel admin no Firebase.

**Norte:** criar hábito de ler e estudar a Bíblia — Duolingo no loop · Palavra no conteúdo.  
**Frase:** *Enquanto outros te fazem jogar a Bíblia, o STWAY te põe em missão nela.*

| Doc | Conteúdo |
|-----|----------|
| [`docs/PRODUTO.md`](docs/PRODUTO.md) | Visão, usuários, posicionamento vs mercado |
| [`docs/PITCH_NOS_VS_ELES.md`](docs/PITCH_NOS_VS_ELES.md) | Pitch 1 página · concorrência |
| [`docs/TECNICA.md`](docs/TECNICA.md) | Arquitetura, stack, Firestore, sync |
| [`ROADMAP.md`](ROADMAP.md) | Norte, checklist e prioridades |
| [`MONETIZATION.md`](MONETIZATION.md) | Hipóteses de receita (sem IAP ainda) |

**Estado (9 set/2026):** 8.370 atos V2 na nuvem · validador verde · app 1.0.23 · D7 aberto.

Canvas mestre de posicionamento: `~/.cursor/projects/.../canvases/stway-posicionamento-mercado-24ago2026.canvas.tsx`

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

Pipeline conteúdo: `npm run pipeline:v2` · publicar: `npm run seed:cli`  
Detalhes em [`admin/README.md`](admin/README.md).
