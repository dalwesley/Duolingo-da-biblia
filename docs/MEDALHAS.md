# STWAY — Sistema de medalhas (v2)

**Status:** implementado (Fases A, B e D parcial — jornada, trilhas, 3 descobertas)  
**Atualizado:** set/2026  
**Substitui:** cofre único de 19 medalhas globais (`pilgrim_medals.dart` v1)

---

## Norte

Medalhas existem para **reforçar formação bíblica**, não clique vazio.

Toda medalha deve passar no teste do produto ([`PRODUTO.md`](PRODUTO.md)):

> *Isso torna o usuário melhor em ler, compreender, conectar, interpretar, lembrar ou viver a Palavra?*

Se a resposta for só “parece legal no perfil”, não entra.

---

## Problemas do v1 (19 globais)

| Problema | Exemplo |
|----------|---------|
| **Cofre único não escala** | 80+ trilhas no catálogo; 19 medalhas não cobrem o currículo |
| **Duplicação sem contexto** | `Trilha percorrida` e `Profundezas` são globais, mas o marco é por trilha |
| **Mistura de escalas** | “25 cenas” global vs progresso em Gênesis 1–11 |
| **Fim prematuro** | Completar 19/19 parece “game over” |
| **Sem gancho sazonal** | Caminhada (Advento/Quaresma) não tem cofre próprio |
| **Sem surpresa** | Tudo listado em “A conquistar” — zero descoberta |

---

## Arquitetura: cofres + medalhas

### Conceitos

```
COFRE (vault)          → container visível no perfil
  └── MEDALHA (medal)  → conquista individual com critério fixo
```

| Conceito | Descrição |
|----------|-----------|
| **Cofre** | Grupo temático com barra de progresso própria e celebração de “cofre completo” |
| **Medalha** | Uma conquista; tier fixo (bronze / prata / ouro); nunca “evolui” de bronze para ouro |
| **Descoberta** | Medalha fora do checklist; só aparece ao desbloquear |

### Tipos de cofre

| Tipo | `vaultId` | Quando aparece | Expira? |
|------|-----------|----------------|---------|
| **Jornada** | `journey` | Sempre | Não |
| **Trilha** | `trail:{slug}` | Ao iniciar a trilha (≥1 missão) | Não |
| **Sazonal** | `season:{id}` | Janela da temporada (ex. Advento 2026) | Medalhas ficam; cofre some da home |
| **Descobertas** | `discovery` | Só medalhas já desbloqueadas | Não |

**Não haverá cofre por livro bíblico** — leitura na Bíblia continua no cofre **Jornada** (família Palavra).

---

## Famílias (eixo pedagógico)

Mantém o vocabulário atual, com um acréscimo:

| Família | O que mede | Onde vive |
|---------|------------|-----------|
| `word` | Leitura bíblica no app | Jornada |
| `formation` | Domínio nas missões (acertos, perfeição) | Jornada + Trilha |
| `path` | Ritmo e constância (streak, ranking) | Jornada |
| `witness` | Compartilhar a Palavra | Jornada |
| `memory` | Versículos firmados | Jornada |
| `season` | Participação em Caminhada / evento | Sazonal |
| `discovery` | Comportamentos raros ou gentis | Descobertas |

---

## Cofre da Jornada (global)

**14 medalhas** — hábitos que atravessam trilhas.

### Palavra (5)

| ID | Título | Tier | Critério |
|----|--------|------|----------|
| `journey:word:first_chapter` | Primeira Palavra | Bronze | 1 capítulo lido na Bíblia |
| `journey:word:chapters_25` | Leitor atento | Prata | 25 capítulos lidos |
| `journey:word:book` | Livro completo | Ouro | 1 livro inteiro (TB) |
| `journey:word:gospel` | Evangelho percorrido | Ouro | 1 evangelho inteiro (Mt/Mc/Lc/Jo) |
| `journey:word:nt_book` | Novo Testamento | Prata | 1 livro do NT completo |

### Formação (4)

| ID | Título | Tier | Critério |
|----|--------|------|----------|
| `journey:form:first_perfect` | Passo firme | Bronze | 1 missão com 100% de acertos |
| `journey:form:perfect_5` | Passos firmes | Prata | 5 missões perfeitas (distintas) |
| `journey:form:perfect_25` | Clareza total | Ouro | 25 missões perfeitas |
| `journey:form:accuracy` | Andando na luz | Prata | ≥80% acertos com ≥30 questões respondidas |

> **Removido do global:** `form_missions_25` — vira marco **por trilha** (ver abaixo).  
> **Removido do global:** `form_trail`, `form_depths` — exclusivos do cofre de trilha.

### Caminho (3)

| ID | Título | Tier | Critério |
|----|--------|------|----------|
| `journey:path:streak_7` | Semana firme | Bronze | 7 dias de sequência |
| `journey:path:streak_30` | Mês constante | Ouro | 30 dias de sequência |
| `journey:path:leader` | Líder da caravana | Ouro | 1 dia em 1º no ranking geral |

### Testemunho (2)

| ID | Título | Tier | Critério |
|----|--------|------|----------|
| `journey:witness:share_1` | Palavra levada | Bronze | 1 versículo compartilhado |
| `journey:witness:share_10` | Semeador | Prata | 10 versículos compartilhados |

### Memória (2)

| ID | Título | Tier | Critério |
|----|--------|------|----------|
| `journey:memory:5` | No coração | Bronze | 5 versículos firmados |
| `journey:memory:20` | Palavra guardada | Ouro | 20 versículos firmados |

**Cofre completo:** 14/14 → sheet “Cofre da Jornada completo”.

---

## Cofre por trilha (template)

Gerado a partir do catálogo (`trails.json`). **4 medalhas fixas por trilha** publicada (`comingSoon: false`).

| ID | Título | Tier | Critério |
|----|--------|------|----------|
| `trail:{slug}:first_step` | Primeiro passo | Bronze | 1 missão concluída nesta trilha |
| `trail:{slug}:semente` | Semente | Bronze | Modo **Semente** liberado/clear nesta trilha |
| `trail:{slug}:caminhada` | Caminhada | Prata | Modo **Caminhada** clear nesta trilha |
| `trail:{slug}:peregrino` | Peregrino | Ouro | Todas as missões + modo **Profundezas** clear |

**Fonte de verdade:** `clearedTrailModes[slug]` + `completedMissions` ∩ `trail.missionSlugs`.

### Regras de exibição

- Cofre **oculto** até `first_step` desbloqueado (ou ≥1 missão na trilha).
- No perfil: ordenar por **progresso** (mais avançado primeiro), depois por `trail.order`.
- Trilhas `comingSoon` **não geram** cofre.
- Título do cofre = `trail.title` (ex. “Gênesis 1–11”).

### Escala (~70 trilhas ativas hoje)

~70 × 4 ≈ **280 medalhas de trilha** — ok porque só aparecem cofres com progresso.

No ranking: mostrar **total de medalhas** ou **cofres de trilha completos** (ex. “3 trilhas percorridas”).

---

## Cofre sazonal (Caminhada)

Vinculado a temporada com data (`season:advento-2026`, `season:quaresma-2027`).

**3–5 medalhas por temporada:**

| ID | Título | Tier | Critério (exemplo Advento) |
|----|--------|------|----------------------------|
| `season:{id}:day_1` | Porta aberta | Bronze | Concluir dia 1 da Caminhada |
| `season:{id}:week_1` | Primeira semana | Bronze | 7 dias da temporada |
| `season:{id}:half` | Meio do caminho | Prata | 50% dos dias |
| `season:{id}:complete` | Temporada vivida | Ouro | 40/40 dias |
| `season:{id}:perfect_week` | Semana firme | Prata | 7 dias seguidos dentro da temporada |

**Comportamento:**

- Cofre visível só entre `activeFrom` e `activeUntil + 7 dias` (grace para fechar).
- Medalhas **permanecem** no histórico após a temporada.
- Subtítulo no perfil: *“Advento 2026 · 4/5”*.
- Pro: Caminhada inteira; grátis: 3 primeiros dias (medalhas dos dias grátis contam).

---

## Descobertas (secretas / especiais)

**Não listadas** em “A conquistar”. Grid separado: **“Descobertas”** (só desbloqueadas + silhueta numerada “?”).

| ID | Título | Tier | Critério | Visibilidade |
|----|--------|------|----------|--------------|
| `discovery:comeback` | Voltou à trilha | Bronze | Retornar após ≥14 dias sem jogar | Secreta |
| `discovery:night_owl` | Vigília | Bronze | Missão concluída entre 22h–5h | Secreta |
| `discovery:perfect_boss` | Chefe vencido | Prata | Boss com 100% | Secreta |
| `discovery:companion` | Dois caminhando | Bronze | 7 dias com companhia ativa | Secreta |
| `discovery:room_host` | Sala acesa | Bronze | Criar sala e ≥3 membros caminharem na semana | Secreta |
| `discovery:bible_before_mission` | Palavra antes | Bronze | Ler capítulo do dia antes da missão | Secreta |
| `discovery:reflection` | Escrito no coração | Bronze | 10 reflexões no diário | Secreta |
| `discovery:founder` | Pioneiro | Ouro | Conta criada no 1º ano do app | Especial (one-shot) |

**Regras:**

- Não entram no % de nenhum cofre listado.
- Contam no **total público** se `caravanProfilePrefs.medals` estiver visível.
- Sheet de desbloqueio com copy: *“Descoberta!”* (tom de surpresa, não checklist).

---

## Tiers (bronze · prata · ouro)

| Tier | Significado | Frequência alvo |
|------|-------------|-----------------|
| **Bronze** | Primeiro contato / entrada | ~40% das medalhas |
| **Prata** | Consistência intermediária | ~35% |
| **Ouro** | Domínio ou marco raro | ~25% |

Tier é **fixo por medalha** — não há progressão bronze→prata na mesma conquista.

---

## Engajamento (loops)

### No momento

1. **Sheet** ao desbloquear (individual).
2. **Sheet** ao completar um cofre inteiro.
3. **Banner** de proximidade no cofre ativo: *“Faltam 2 capítulos…”*.
4. **SnackBar** quando falta 1 passo.
5. **Badge** na caravana: `N medalhas` ou `Cofre completo` (por cofre em destaque).

### Prioridade de proximidade

Mostrar dica só do cofre **mais relevante**:

1. Trilha com missão em andamento hoje (mapa aberto recentemente).
2. Cofre da Jornada.
3. Sazonal ativo.
4. Nunca para Descobertas.

### Social

- Perfil na caravana: cofres colapsáveis; visitante vê o que `caravanProfilePrefs` permitir.
- Ranking: total de medalhas + ícone de cofre completo da Jornada.
- **Não** exibir feed “Fulano desbloqueou X” no v1 (ruído).

---

## UI no perfil (wireframe)

```
┌─ COFRE DA JORNADA ──────────── 9/14 ─┐
│ [banner proximidade se houver]        │
│ CONQUISTADAS · grid 3 colunas         │
│ A CONQUISTAR · grid                   │
└───────────────────────────────────────┘

┌─ GÊNESIS 1–11 ───────────────── 3/4 ──┐
│ ...                                   │
└───────────────────────────────────────┘

┌─ SERMÃO DO MONTE ────────────── 1/4 ──┐
│ ...                                   │
└───────────────────────────────────────┘

┌─ ADVENTO 2026 (até 24/dez) ──── 2/5 ──┐  ← só se temporada ativa
│ ...                                   │
└───────────────────────────────────────┘

┌─ DESCOBERTAS ─────────────────── 2 ──┐
│ [medalhas] [?] [?]                    │  ← sem lista de hints
└───────────────────────────────────────┘
```

Mapa da trilha: chip opcional *“+1 medalha perto”* na próxima missão.

---

## Modelo de dados

Implementado em `trilha_app/lib/models/pilgrim_medal_models.dart`, `pilgrim_medal_catalog.dart` e `pilgrim_medals.dart`.

```dart
enum PilgrimVaultKind { journey, trail, season, discovery }

enum PilgrimMedalTier { bronze, silver, gold }

class PilgrimVaultDef {
  final String id;           // journey | trail:genesis-1-11 | season:advento-2026
  final PilgrimVaultKind kind;
  final String title;
  final String? subtitle;
  final DateTime? activeFrom;
  final DateTime? activeUntil;
  final List<PilgrimMedalDef> medals;
}

class PilgrimMedalDef {
  final String id;             // único globalmente
  final String vaultId;
  final String title;
  final String hint;           // vazio se discovery secret
  final PilgrimMedalTier tier;
  final PilgrimMedalFamily family;
  final bool secret;           // discovery: não lista em "A conquistar"
  final CinematicGlyph glyph;
}
```

**Persistência (`users/{uid}`):**

```json
{
  "celebratedMedalIds": ["journey:word:first_chapter", "..."],
  "vaultCompleteCelebrated": ["journey", "trail:genesis-1-11"],
  "medalCelebrationSeeded": true
}
```

Critérios derivados do progresso existente — **sem** campo `unlockedMedals[]` duplicado.

---

## Migração v1 → v2

| ID v1 | ID v2 |
|-------|-------|
| `word_first_chapter` | `journey:word:first_chapter` |
| `word_chapters_25` | `journey:word:chapters_25` |
| … | … |
| `form_trail` | *derivar* → `trail:{slug}:peregrino` para cada trilha já completa |
| `form_depths` | *derivar* → trilhas com `profundezas` em `clearedTrailModes` |
| `form_missions_25` | *descartar* ou mapear para `trail:{slug}:peregrino` se ≥25 na mesma trilha |

Na 1ª abertura pós-update: `seedMedalCelebrations` marca medalhas já conquistadas; não re-celebra em massa.

---

## Privacidade

Mantém `CaravanProfileSection.medals` — visitante vê **todas** as medalhas/cofres permitidos (não por cofre).

Opcional v2.1: toggle por cofre (provavelmente overkill).

---

## O que não fazer

- Medalha por **login diário** sem estudo.
- Medalha por **abrir o app** N vezes.
- Cofre com **50+ medalhas** visíveis de uma vez (usar colapso).
- **Paywall** em medalha de formação core (sazonal Pro ok nos dias pagos).
- **Ranking** só por medalhas (passos/semana continuam principais).

---

## Fases de implementação

| Fase | Escopo | Entrega |
|------|--------|---------|
| **A** | Modelo `vaultId` + migração Jornada (14) | Cofre único renomeado; IDs novos |
| **B** | Template trilha + geração do catálogo | Cofres por trilha no perfil |
| **C** | Sazonal (1ª Caminhada piloto) | `season:advento-2026` |
| **D** | Descobertas (6 iniciais) | Grid separado + sheets |
| **E** | Mapa + proximidade por trilha ativa | Chip na missão |

---

## Métricas de sucesso

| Métrica | Hipótese |
|---------|----------|
| % usuários com ≥1 medalha de trilha em 14 dias | Trilha cofre puxa conclusão |
| Tempo até 1ª medalha | Bronze de entrada em <3 sessões |
| Retorno D7 em quem desbloqueou medalha na D1–D3 | Celebração funciona |
| Cofres de trilha completos / MAU | Currículo sendo percorrido |
| Desbloqueios sazonais / inscritos na Caminhada | Sazonal engaja Pro |

---

## Resumo

| Pergunta | Resposta |
|----------|----------|
| Cofre por trilha? | **Sim** — 4 medalhas template por trilha ativa |
| Especiais / sazonais / secretas? | **Sim** — cofres `season` e `discovery` separados |
| O que acontece quando “acaba”? | Acaba **um cofre**, não o jogo; surgem trilhas e temporadas novas |
| Quantas medalhas no total? | ~14 jornada + ~4×trilhas ativas + ~5/temporada + descobertas — escala com conteúdo |

**Próximo passo:** Fase C (sazonal) e chip de proximidade no mapa (Fase E).
