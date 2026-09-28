# Plano de implementação — Simplificar STWAY sem perder valor

**Atualizado:** 28 set/2026  
**App:** `trilha_app` · shell 5 tabs  
**Norte:** [`PRODUTO.md`](PRODUTO.md) · [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md) · [`../ROADMAP.md`](../ROADMAP.md)  
**Glossário UI:** [`../trilha_app/docs/design_language.md`](../trilha_app/docs/design_language.md)

---

## 1. Objetivo

Reduzir carga cognitiva para o usuário novo **sem apagar** Caravana, Companhia, Grupos, Desafio, medalhas, selos ou jarros.

**Sensação-alvo:**  
> Primeiro a **cena**, depois o **par**, depois a **caravana**, depois a **célula** — uma linguagem por job.

**Critério de sucesso**

| Métrica | Como medir |
|---------|------------|
| Frase espontânea alinhada | D7: ≥50% “missão / hábito de ler a Bíblia” |
| Juntos compreensível | Tester explica Companhia em 1 frase sem induzir |
| Perfil / sequência | Sem “o que é isso?” nos jarros no D0–D3 |
| Loop intacto | TTV 1ª cena &lt;2 min (já no ROADMAP) |
| Zero regressão de feature | Todas as mecânicas acessíveis em ≤2 toques a partir de Juntos ou Perfil |

---

## 2. Não-objetivos

- Não reduzir abas (5 tabs ficam).
- Não fundir modelos de dados Companhia / Desafio / Grupo / Caravana.
- Não ligar IAP / mais companheiros antes do D7.
- Não virar YouVersion (planos em massa) nem Bible Way (clube/pet).
- Não reescrever `league_screen.dart` inteiro num único PR (fatiar).

---

## 3. Princípios de implementação

1. **Hierarquia pelo fosso** — Companhia + Desafio &gt; Caravana &gt; Grupos (igreja, depois).
2. **Esconder ≠ apagar** — progressive disclosure por readiness (streak / tem companhia / tem gente na caravana).
3. **Um glossário** — `design_language.md` manda; docs e UI convergem.
4. **Home continua com um job** — próxima cena; resto em “Mais para hoje” ou sheet.
5. **PRs pequenos** — cada fase shipável e reverível.

---

## 4. Glossário congelado (Fase 0 — pré-requisito)

Decisão única (atualizar `PRODUTO.md` para bater com a UI):

| Conceito | Termo canônico na UI | Evitar |
|----------|----------------------|--------|
| Unidade de estudo | **cena** | missão (ok em marketing/tester; UI = cena) |
| Dias seguidos | **sequência** | constância (só título de card se mantiver) |
| Liga | **caravana** | liga, divisão |
| Par 1:1 | **companhia** | dupla, parceria |
| Grupo de estudo | **grupo** | sala (código pode ficar `Room`) |
| Peer challenge | **desafio** (travado 28 set) | esquina, misturar com boss |
| Boss da trilha | **travessia** (Fase 3) | desafio |
| Desafio litúrgico | **desafio da estação** | só “desafio” |
| Vidas na cena | **lâmpada** | — |
| Histórico semanal | **lamparina** / jarro (só no perfil avançado) | chamar de lâmpada |
| Pontos | **passos** | XP |

**Decisões travadas (28 set/2026):**
- Juntos = **Variante A** (3 tabs; Companhia primeiro; Desafio fora de Geral/Semana).
- Peer challenge na UI = **Desafio** (docs deixam de preferir “Esquina”; código `Corner*` pode ficar).

---

## 5. Fases

```
Fase 0  Glossário + observabilidade          ✅ 28 set
Fase 1  Juntos: IA pelo fosso (Variante A)   ✅ 28 set
Fase 2  Hábito: uma metáfora na superfície   ✅ 28 set
Fase 3  Copy colisões (boss / estação)       ✅ 28 set
Fase 4  Perfil: coleções + progressive       ✅ 28 set
Fase 5  Convite unificado (opcional)         ⏸ adiadasob demanda D7
```

Dependência sugerida: **0 → 1 → 2 → 3**; Fase 4 pode ir em paralelo com 3; Fase 5 depois de feedback D7.

---

## Fase 0 — Glossário e baseline

### Trabalho

| # | Tarefa | Arquivos |
|---|--------|----------|
| 0.1 | Congelar tabela §4 neste doc + `design_language.md` | `trilha_app/docs/design_language.md` |
| 0.2 | Alinhar `PRODUTO.md` glossário (Salas→Grupos, Esquina↔Desafio) | `docs/PRODUTO.md` |
| 0.3 | Checklist de strings a renomear (grep) | script mental / issue |
| 0.4 | Eventos analytics (se faltarem): `juntos_tab_open`, `juntos_pane`, `companion_invite_tap`, `corner_empty_open` | `AnalyticsService` + call sites |

### Critério de aceite

- [ ] Um único termo para peer challenge documentado.
- [x] `PRODUTO.md` e `design_language.md` sem Salas/Esquina conflitantes (ou nota “legado código”).
- [ ] Issue/checklist de copy pronta para Fase 3.

### Fora de escopo

Mudança visual de tabs.

---

## Fase 1 — Juntos: hierarquia pelo fosso

**Problema:** 3 tabs (Caravana · Companhia · Grupos) + 3 panes (Geral · Semana · Desafio) = 6 pílulas; Desafio parece modo de ranking; empty states pedem “chame pra caravana” antes do convite de companhia.

### Arquitetura alvo

```
Juntos
├── [0] Com alguém     (default se !temCompanhia && !temGrupo)
│     ├── Hero: Companhia (vazia ou ativa)
│     ├── Card: Desafio (só se face != null OU já teve histórico)
│     └── Link: “Grupo · célula / EBD” → abre superfície de grupos
├── [1] Caravana
│     └── Geral | Semana   ← sem Desafio
└── (Grupos) embutido em “Com alguém” OU 3ª tab rebaixada
```

**Variante A (recomendada — menos churn):** manter 3 tabs, mas:
1. Ordem: **Companhia | Caravana | Grupos** (Companhia primeiro).
2. Remover pane **Desafio** de Geral/Semana; `CornerBoard` vira seção dentro de Companhia (ou card no topo se ativo).
3. Empty Companhia = hero; empty Caravana = ranking vazio **sem** competir com CTA de companhia.

**Variante B (mais agressiva):** 2 tabs — `Com alguém` | `Caravana`. Grupos dentro de Com alguém. Mais refator.

**Implementar Variante A primeiro.** Avaliar B após D7.

### Tarefas (Variante A)

| # | Tarefa | Arquivos principais |
|---|--------|---------------------|
| 1.1 | Reordenar `_SegmentTabs`: Companhia=0, Caravana=1, Grupos=2; default `_tab` = 0 se sem companhia | `league_screen.dart` |
| 1.2 | Remover Desafio de `_caravanPane` (só Geral=0, Semana=1) | `league_screen.dart` ~80, 1401–1411, switch panes |
| 1.3 | Embutir `CornerBoard` / `DesafioEntry` na aba Companhia (abaixo do bond ou empty) | `league_screen.dart`, `corner_board.dart` |
| 1.4 | Deep links: `wantCompanhia` → tab 0; caravana → 1; grupos → 2; desafio → companhia+scroll | `invite_deep_link_service.dart`, `main_shell.dart`, `league_screen.dart` |
| 1.5 | Empty Caravana: CTA secundário “Ou chame um companheiro” → tab Companhia; primário continua share loja | `league_screen.dart` EmptyState ~4472 |
| 1.6 | Empty Grupos: manter; não promover no empty de Companhia | `_RoomsEmptyState` |
| 1.7 | Top-bar subtitle: `Companhia · Caravana · Grupos` (não listar Desafio) | `main_shell.dart` ~428 |
| 1.8 | Inbox: alertas de desafio no badge Companhia (não só Caravana) | `juntos_inbox.dart`, `_SegmentTabs` |
| 1.9 | Testes manuais: convite QR companhia, sala, propor desafio pelo sheet da caravana, Home `DesafioEntry` | — |

### Critério de aceite

- [ ] Em Caravana só existem Geral e Semana.
- [ ] Desafio ativo ou vazio aparece sob Companhia (ou card Home se já ativo).
- [ ] Usuário novo abre Juntos → vê primeiro o pitch de Companhia.
- [ ] Fluxos existentes (propor desafio no sheet do peregrino, aceitar, chegar +10) intactos.
- [ ] Deep links não quebram.

### Riscos

| Risco | Mitigação |
|-------|-----------|
| `league_screen.dart` ~4.5k linhas | Extrair só o necessário; não “split god file” neste PR |
| Usuários acostumados a Desafio sob Caravana | Card “Desafio” visível na Companhia; Home já tem `DesafioEntry` |
| Índices de tab quebram deep link | Checklist 1.4 + teste em aparelho |

### Estimativa

3–5 dias (1 a 2 PRs: “move Desafio” + “reorder tabs / empty states”).

---

## Fase 2 — Hábito: uma metáfora na superfície

**Problema:** sequência contada por chama + LivingSeed + 12 jarros; gelo não ensinado; “lâmpada” = vidas e jarros.

### Tarefas

| # | Tarefa | Arquivos |
|---|--------|----------|
| 2.1 | `ConstancyCard`: acima da dobra = anel + 7 dias + estágio SoftBadge; **12 jarros atrás de** “Histórico das semanas” (expand/collapse; default fechado se `playDates` &lt; 21 dias) | `profile_hero.dart` |
| 2.2 | Primeira expansão dos jarros: tooltip/body já existente (“Cada lamparina…”) + `SharedPreferences` `jars_hint_seen` | `profile_hero.dart`, `progress_service` ou prefs locais |
| 2.3 | Home: na 1ª aplicação de gelo, sheet/chip único “O gelo cobriu ontem — sua sequência segue” | `home_player_header.dart` / `comeback_sheet` pattern / `progress_service` flag |
| 2.4 | Lição: no 1º erro que apaga lâmpada, microcopy “Restam N lâmpadas” (se ainda não claro) | `lamps_bar.dart` / `lesson_screen.dart` |
| 2.5 | Não duplicar LivingSeed como painel grande no Me do dono (badge no ConstancyCard basta; card completo só visitante se já existir) | `me_screen.dart`, `pilgrim_profile_sections.dart` |

### Critério de aceite

- [ ] D0–D14: perfil não mostra 12 jarros abertos por padrão (sem 3 semanas de dados).
- [ ] Gelo explicado 1× quando salva.
- [ ] Home header continua: número + gelo — sem plantinha extra.

### Estimativa

2–3 dias.

---

## Fase 3 — Colisões de copy

### Tarefa

Grep + replace controlado:

| Onde | De | Para |
|------|----|------|
| Celebração boss chip | `Desafio` | `Travessia` (ou termo Fase 0) |
| Docs | Esquina/Salas inconsistentes | termo canônico |
| Caravana empty | `pra` | `para` (`design_language`) |
| Snackbars `+50 na caravana` | — | `+50 passos na caravana` |

Arquivos típicos: `celebration_screen.dart`, `league_screen.dart`, `corner_challenge.dart` (se renomear Desafio→Esquina), `mascot_messages.dart`, `PRODUTO.md`.

### Critério de aceite

- [ ] Nenhuma tela usa a mesma palavra para boss e peer challenge.
- [ ] Voice `para` nos empties de caravana.

### Estimativa

0.5–1 dia.

---

## Fase 4 — Perfil: coleções sem scroll infinito

### Tarefa

| # | Tarefa | Arquivos |
|---|--------|----------|
| 4.1 | Agrupar Selos · Medalhas · Escrituras em segmento único (ou SectionLabel + collapse) | `me_screen.dart`, `pilgrim_profile_sections.dart` |
| 4.2 | `WeeklyQuestsCard` só se houver quest claimável / progresso da semana | `me_screen.dart`, `milestone_chests.dart` |
| 4.3 | Recognition history no fim (já está) — manter | — |

### Critério de aceite

- [ ] Perfil do dono: identidade → constância → (quests se ativas) → coleções → palavra → reconhecimento.
- [ ] Menos de “um sistema de recompensa por viewport” acima da dobra.

### Estimativa

2–3 dias.

---

## Fase 5 — Convite unificado (opcional, pós-D7)

Só se D7 mostrar fricção em “como chamar alguém”.

- Um sheet `Convidar`: chips Companhia | Grupo | (Desafio só se veio de perfil).
- Reusar `invite_qr_sheet.dart` / deep links existentes.
- Otimizar **primeiro** `Convidar amigo` (Companhia), não power features.

Estimativa: 2–3 dias.

---

## 6. Ordem dos PRs (sugestão)

| PR | Título | Fase |
|----|--------|------|
| 1 | `docs: freeze glossary + align PRODUTO` | 0 |
| 2 | `juntos: move Desafio out of Caravana panes into Companhia` | 1 |
| 3 | `juntos: Companhia first tab + empty-state CTAs` | 1 |
| 4 | `profile: collapse week jars behind Histórico` | 2 |
| 5 | `habit: one-shot gelo teach + lamp life microcopy` | 2 |
| 6 | `copy: disambiguate Desafio boss vs peer; para not pra` | 3 |
| 7 | `profile: collapse collections sections` | 4 |
| 8 | (opcional) `juntos: unified invite sheet` | 5 |

---

## 7. Test plan (manual)

### Regressão Juntos

- [ ] Abrir Juntos sem companhia → Companhia empty com Convidar / Tenho código
- [ ] Criar companhia via QR → bond UI
- [ ] Caravana Geral / Semana ranking e sheet do peregrino
- [ ] Propor Desafio pelo sheet → aparece sob Companhia + Home `DesafioEntry`
- [ ] Aceitar / chegar / +10 / withdraw
- [ ] Criar grupo / código / baú do grupo
- [ ] Deep link `stway://companhia/…`, `stway://sala/…`, `stway://juntos`
- [ ] Badge inbox (outcome liga, aceno, desafio)

### Regressão hábito / perfil

- [ ] Completar cena → sequência +1
- [ ] Simular miss + gelo → chip/sheet 1×
- [ ] Perfil: anel; expandir histórico → jarros + copy
- [ ] Erro na cena → lâmpadas diminuem com feedback

### D7 (paralelo)

Seguir [`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md). Acrescentar observação:

| Pergunta extra (sem induzir) | Anotar |
|------------------------------|--------|
| Abriu Juntos? O que achou que era? | frase |
| Viu jarros no perfil? Entendeu? | S/N + frase |

---

## 8. Relação com o ROADMAP

Este plano **não substitui** a fase “Agora” (provar D7).  
Encaixa como **higiene de UX** que aumenta a chance do tester explicar o app numa frase — critério 3 do ROADMAP.

| ROADMAP “Agora” | Este plano |
|-----------------|------------|
| Rodar D7 | Paralelo; feedback alimenta Fases 4–5 |
| TTV &lt;2 min | Não mexer no caminho missão |
| Depois: fosso visível | Fase 1 **é** tornar o fosso (par) visível na UI |

Não avançar `lifeChallenge` / IAP neste plano.

---

## 9. Esforço total

| Fase | Dias úteis (1 dev) |
|------|--------------------|
| 0 | 0.5–1 |
| 1 | 3–5 |
| 2 | 2–3 |
| 3 | 0.5–1 |
| 4 | 2–3 |
| 5 | 2–3 (opcional) |
| **Total 0–4** | **≈ 8–13 dias** |
| **Com 5** | **≈ 10–16 dias** |

---

## 10. Status (28 set/2026)

**Shipado:** Variante A · termo **Desafio** · Fases 0–4.  
**Adiado:** Fase 5 (convite unificado) — só se D7 mostrar fricção.  
**Docs alinhados:** `PRODUTO`, `ROADMAP`, `PITCH`, `TECNICA`, `design_language`, glossários.

Próximo: rodar D7; observar itens 7–8 do protocolo.
