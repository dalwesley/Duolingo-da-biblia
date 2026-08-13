# Protocolo D7 — fase “Agora” (Sermão do Monte)

**Objetivo:** provar o loop com 10–20 pessoas reais. Critério da fase = conclusão de missão + retorno D7 **no Sermão** (trilha-vitrine).  
**Norte:** [`ROADMAP.md`](../ROADMAP.md) · pitch: [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md)

---

## 1. Setup do build de teste

```bash
cd trilha_app
# Catálogo aberto só em teste (default da loja é fechado):
flutter run --dart-define=OPEN_ALL_TRAILS=true
```

- Pedir login Google **ou** Apple (iOS).
- Orientar: começar / continuar no **Sermão do Monte** (ou onboarding → Gênesis e depois pular para Sermão se o catálogo estiver aberto).
- Não explicar o app além de: *“é um treino curto pra aprender a ler a Bíblia.”*

---

## 2. Roteiro por tester (dia 0)

| Passo | O que observar | Anotar |
|-------|----------------|--------|
| 1. Abrir → login → home | Travou? Demorou? | time-to-home |
| 2. 1ª missão concluída | &lt; 2 min desde login? | TTV (min) |
| 3. Gestos / Strong | Tocaram a ref do palco? | “uau” Strong? S/N |
| 4. Frase espontânea | *“O que é este app?”* sem induzir | 1 frase |
| 5. Abandono | Em qual tela / gesto saiu? | tela + motivo |

**Frases alinhadas ao norte:** “treino pra ler a Bíblia”, “academia”, “estudo curto”.  
**Frases de alerta:** “quiz”, “jogo de Bíblia”, “Duolingo de versículos” *sem* menção a aprender a ler.

---

## 3. Seguimento D1 / D7

| Dia | Ação | Sucesso |
|-----|------|---------|
| D1 | Mensagem leve: “conseguiu treinar de novo?” | Abriu o app + ≥1 missão |
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

| id | canal | D0 TTV | frase | Strong | D1 voltou | D7 voltou | notas |
|----|-------|--------|-------|--------|-----------|-----------|-------|
| T01 | … | … | … | … | … | … | … |

Meta qualitativa: ≥50% das frases espontâneas alinhadas ao norte; D7 ≥ retorno útil no Sermão (não só abrir e fechar).

---

## 5. Pipeline semanal (Relatos)

1. Testers usam Relato na lição quando a pergunta falha.
2. Admin → Relatos → corrigir banco / seed sem release.
3. Priorizar **Profundezas** que ainda “cheiram” a Semente (ver enrich + revisão editorial).

---

## 6. Critério para sair da fase “Agora”

- [ ] 10–20 testers com D0 completo
- [ ] TTV mediano &lt; 2 min (ou buracos de onboarding listados)
- [ ] D7 medido (GA4 + planilha) no Sermão
- [ ] Frase espontânea majoritariamente alinhada ao norte

Só então: lifeChallenge, áudio, Pro ([`ROADMAP.md`](../ROADMAP.md) “Depois”).
