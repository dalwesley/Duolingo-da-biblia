# Protocolo D7 — fase “Agora” (Sermão do Monte)

**Objetivo:** provar o loop com 10–20 pessoas reais. Critério da fase = conclusão de missão + retorno D7 **no Sermão** (trilha-vitrine).  
**Norte:** [`ROADMAP.md`](../ROADMAP.md) · pitch: [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md)  
**Planilha:** [`D7_TESTERS.csv`](D7_TESTERS.csv)

**Frase para o tester (só isto):** *“é uma missão curta pra aprender a ler a Bíblia.”*

---

## 1. Setup do build de teste

```bash
cd trilha_app
# Catálogo aberto só em teste (default da loja é fechado):
flutter run --dart-define=OPEN_ALL_TRAILS=true
```

- Pedir login Google **ou** Apple (iOS).
- Orientar: ir em **Trilhas → Sermão do Monte → cena 1** (Bem-aventuranças). Se o onboarding abrir Gênesis, pular e abrir o Sermão.
- Não explicar o app além da frase acima.
- Vitrine de profundidade: se o tester escolher **Profundezas**, a cena 1 (sm-01…05) já passou por edição humana (ago/2026).

---

## 2. Roteiro por tester (dia 0)

| Passo | O que observar | Anotar |
|-------|----------------|--------|
| 1. Abrir → login → home | Travou? Demorou? | time-to-home |
| 2. 1ª missão concluída | &lt; 2 min desde login? | TTV (min) |
| 3. Gestos / Strong | Tocaram a ref do palco? | “uau” Strong? S/N |
| 4. Frase espontânea | *“O que é este app?”* sem induzir | 1 frase |
| 5. Abandono | Em qual tela / gesto saiu? | tela + motivo |

**Frases alinhadas ao norte:** “missão pra ler a Bíblia”, “academia”, “estudo curto”.  
**Frases de alerta:** “quiz”, “jogo de Bíblia”, “Duolingo de versículos” *sem* menção a aprender a ler.

---

## 3. Seguimento D1 / D7

| Dia | Ação | Sucesso |
|-----|------|---------|
| D1 | Mensagem leve: “conseguiu fazer a missão de novo?” | Abriu o app + ≥1 missão |
| D7 | “Voltou esta semana?” | `app_open` / missão ≥1 no dia 7±1 |

**Analytics no app (automático):**

| Evento | Quando |
|--------|--------|
| `app_open` | Splash (já existia) |
| `retention_pulse` | Cada abertura autenticada — `days_since_first_open`, `days_since_first_lesson`, `cohort_trail` |
| `first_lesson_complete` | 1ª missão da conta — `trail_slug`, `mission_slug`, `ttv_seconds` |
| `lesson_complete` | Toda missão — filtrar `trail_slug = sermao-do-monte` no GA4 |

No GA4: funil `first_lesson_complete` (Sermão) → usuários com `retention_pulse` onde `days_since_first_lesson >= 7`.

---

## 4. Planilha mínima (10–20 linhas)

Ver [`D7_TESTERS.csv`](D7_TESTERS.csv). Uma linha por tester (T01–T20).

Meta qualitativa: ≥50% das frases espontâneas alinhadas ao norte; D7 ≥ retorno útil no Sermão (não só abrir e fechar).

---

## 5. Pipeline semanal (Relatos)

1. Testers usam Relato na lição quando a pergunta falha.
2. Admin → Relatos → corrigir banco / seed sem release.
3. Priorizar **Profundezas** fora da cena 1 (sm-06+) que ainda “cheiram” a Semente.

---

## 6. Critério para sair da fase “Agora”

- [ ] 10–20 testers com D0 completo
- [ ] TTV mediano &lt; 2 min (ou buracos de onboarding listados)
- [ ] D7 medido (GA4 + planilha) no Sermão
- [ ] Frase espontânea majoritariamente alinhada ao norte

Só então, nesta ordem: `lifeChallenge` → trilhas por dor → áudio de commute ([`ROADMAP.md`](../ROADMAP.md) “Depois”).
