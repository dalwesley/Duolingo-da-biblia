# Trilha — Duolingo da Bíblia

App de aprendizado bíblico gamificado. MVP com trilha **Gênesis 1–11**.

## Começar

```bash
npm install
npm run db:migrate
npm run db:seed
npm run dev
```

Abra [http://localhost:3000](http://localhost:3000)

## Scripts

| Comando | Descrição |
|---------|-----------|
| `npm run dev` | Servidor de desenvolvimento |
| `npm run db:migrate` | Cria/atualiza banco SQLite |
| `npm run db:seed` | Popula trilha Gênesis com perguntas |
| `npm run db:reset` | Reseta banco e re-seed |

## Estrutura

```
prisma/
  schema.prisma      # Trail → Module → Mission → Question
  seed-data/genesis.ts  # Conteúdo Gênesis 1-11 (PT)
  seed.ts
src/
  app/               # Páginas e API
  components/        # UI gamificada
  lib/               # Prisma + Zustand (XP, streak)
```

## Roadmap

- [x] Trilha Gênesis 1-11
- [x] Missões, XP, streak, bosses
- [ ] Import dataset BIBLE (HuggingFace)
- [ ] Mais trilhas (Êxodo, Evangelhos)
- [ ] Auth + sync nuvem
- [ ] Outras matérias (matemática, ENEM)
