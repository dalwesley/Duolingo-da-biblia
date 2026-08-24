# Piloto editorial V2 — Catálogo STWAY

**Status:** catálogo completo V2 **seeded no Firebase**  
**Atualizado:** 24 ago/2026 (gerador verso-primeiro + Toque no palco; validador verde)

---

## Trilhas

| Trilha | Missões | Perguntas | Fonte |
|--------|---------|-----------|-------|
| `genesis-1-11` | 14 | 270 | Handcrafted + fill (`_genesis_111_v2_data.mjs`) |
| `genesis-12-50` | 23 | 432 | Handcrafted + fill (`_genesis_1250_v2_data.mjs`) |
| `exodo` | 12 | 228 | Pack congelado (`_exodo_v2_data.json`) — palco TB |
| `sermao-do-monte` | 31 | 594 | Pack congelado (`_sermao_v2_data.json`) — palco TB |
| **Demais 80 trilhas** | — | ~6.846 | Gerador `_v2_generator.mjs` + Bíblia TB |

**Total catálogo V2:** **8.370** perguntas · 432 missões · 84 trilhas · zero clones · 6 gestos (V/F · toque · escolher · ordenar · completar · conectar).

Build: `npm run pipeline:v2` · Seed: `npm run seed:cli` (só com validador verde) · Validate: `npm run validate:bank`

---

## Padrão por missão (lição)

| Nível | Qtd | Skills | Operação |
|-------|-----|--------|----------|
| Semente | **6** | `observe` / `recall` | O que o texto diz |
| Rota | **6** | `understand` / `connect` | Relações, padrão, contexto |
| Profundezas | **6** | `interpret` / `connect` / `synthesize` | Significado, teologia bíblica |

Boss: **8** perguntas por modo (revisão + templates).

Alinhado a `ProgressService` (6 normal / 8 boss) e [`SESSAO_TREINO.md`](../SESSAO_TREINO.md).

Gênesis editorial preenche slots 01–02 (boss 01–03); o gerador completa até 6/8.

---

## Schema V2 (por pergunta)

```json
{
  "id": "genesis-12-50-sem-gen12-01-chamado-01",
  "trail": "genesis-12-50",
  "section": "gen12-01-chamado",
  "difficulty": "semente",
  "skill": "observe",
  "type": "choice",
  "learningObjective": "...",
  "evidence": ["Gênesis 12:1"],
  "feedbackCorrect": "...",
  "feedbackWrong": { "b": "..." }
}
```

---

## Regras do validador

- Sem IDs `-xch` / `-xfill`
- Skill compatível com difficulty
- V/F = afirmação completa e verificável
- Rota/Profundezas: distratores interpretivos, não fragmentos de versículo
- Sem stem duplicado no mesmo passo + nível

Pipeline: `cd admin && npm run pipeline:v2`

---

## Firestore (20 ago/2026)

| Coleção | N |
|---------|---|
| `content_bank_questions` | 8.370 |
| `content_trails` | 84 |
| `content_mission_studies` | 431 |
| `content_meta/catalog.version` | `1787584947461` |

Órfãos do banco legado: **5.997** removidos no mesmo seed.

---

## Próximo piloto sugerido

1. `exodo` — handcraft no padrão Gênesis (hoje 228 geradas)
2. `sermao-do-monte` — vitrine D7 (hoje 594 geradas)

Contrato de sessão: [`SESSAO_TREINO.md`](../SESSAO_TREINO.md)  
Norte pedagógico: [`LEARNING_ENGINE.md`](../LEARNING_ENGINE.md)
