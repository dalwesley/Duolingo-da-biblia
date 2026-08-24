# Protocolo D7 — fase “Agora”

**Atualizado:** 20 ago/2026  
**Objetivo:** provar o loop com 10–20 pessoas reais. Critério = conclusão de missão + retorno D7.  
**Vitrines:** **Sermão do Monte** (cena 1) e/ou **Gênesis 1–11 V2** (banco 8.370 na nuvem).  
**Norte:** [`ROADMAP.md`](../ROADMAP.md) · pitch: [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md)  
**Planilha:** [`D7_TESTERS.csv`](D7_TESTERS.csv) · convite: [`D7_CONVITE.md`](D7_CONVITE.md)

**Frase para o tester (só isto):** *“é um app de missões curtas pra criar hábito de ler a Bíblia.”*

---

## 1. Setup do build de teste

```bash
# Da raiz do monorepo:
make d7_run
# equivalente:
cd trilha_app && flutter run --dart-define=OPEN_ALL_TRAILS=true
```

- Pedir login Google **ou** Apple (iOS).
- Orientar uma das vitrines:
  - **Sermão:** Trilhas → Sermão do Monte → cena 1 (Bem-aventuranças)
  - **Gênesis:** onboarding já aponta; ou Trilhas → Gênesis 1–11
- Não explicar o app além da frase acima.
- Sessão esperada: **~6 atos** (boss 8), com choice + V/F.
- Se a pergunta falhar: **Relatar problema nesta pergunta** (vai para admin → Relatos).

---

## 2. Roteiro por tester (dia 0)

| Passo | O que observar | Anotar |
|-------|----------------|--------|
| 1. Abrir → login → home | Travou? Demorou? | time-to-home |
| 2. 1ª missão concluída | &lt; 2 min desde login? | TTV (min) |
| 3. Gestos / Strong | Tocaram a ref do palco? | “uau” Strong? S/N |
| 4. Frase espontânea | *“O que é este app?”* sem induzir | 1 frase |
| 5. Relato (se errar) | Achou o botão Relatar? | S/N |
| 6. Abandono | Em qual tela / gesto saiu? | tela + motivo |

**Frases alinhadas ao norte:** “missão pra ler a Bíblia”, “academia”, “estudo curto”.  
**Frases de alerta:** “quiz”, “jogo de Bíblia”, “Duolingo de versículos” *sem* menção a hábito de ler e estudar.

---

## 3. Seguimento D1 / D7

| Dia | Ação | Sucesso |
|-----|------|---------|
| D1 | [`D7_CONVITE.md`](D7_CONVITE.md) mensagem D1 | Abriu o app + ≥1 missão |
| D7 | mensagem D7 | `app_open` / missão ≥1 no dia 7±1 |

**Analytics no app (automático):**

| Evento | Quando |
|--------|--------|
| `app_open` | Splash |
| `retention_pulse` | Cada abertura autenticada — `days_since_first_open`, `days_since_first_lesson`, `cohort_trail` |
| `first_lesson_complete` | 1ª missão da conta — `trail_slug`, `mission_slug`, `ttv_seconds` |
| `lesson_complete` | Toda missão — filtrar `sermao-do-monte` ou `genesis-1-11` no GA4 |

No GA4: funil `first_lesson_complete` → usuários com `retention_pulse` onde `days_since_first_lesson >= 7`.

---

## 4. Planilha mínima (10–20 linhas)

Ver [`D7_TESTERS.csv`](D7_TESTERS.csv). Uma linha por tester (T01–T20).

Colunas: `id,canal,contato,trilha,d0_data,d0_ttv_min,frase_espontanea,strong_uau,relatou,abandonou_em,d1_voltou,d7_voltou,notas`

Meta qualitativa: ≥50% das frases espontâneas alinhadas ao norte; D7 ≥ retorno útil (não só abrir e fechar).

---

## 5. Pipeline semanal (Relatos)

1. Testers usam **Relatar problema** na lição quando a pergunta falha.
2. Admin → Relatos → corrigir banco / `pipeline:v2` + `seed:cli` sem release.
3. Priorizar qualidade editorial em Êxodo / Sermão (além do gerador V2).

---

## 6. Critério para sair da fase “Agora”

- [ ] 10–20 testers com D0 completo
- [ ] TTV mediano &lt; 2 min (ou buracos de onboarding listados)
- [ ] D7 medido (GA4 + planilha) na vitrine escolhida
- [ ] Frase espontânea majoritariamente alinhada ao norte

Só então, nesta ordem: `lifeChallenge` → trilhas por dor → áudio de commute ([`ROADMAP.md`](../ROADMAP.md) “Depois”).
