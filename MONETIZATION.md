# Monetização STWAY

Modelo freemium com assinatura **STWAY Pro** e, depois, plano **Igreja**.

O loop diário continua gratis. O Pro remove fricção e aprofunda o estudo. Não cobramos para começar a caminhada.

---

## Princípios

1. **Nunca cobrar para começar** — Gênesis / primeiras missões e o hábito diário ficam livres.
2. **Não vender “fé”** — vender tempo, profundidade e continuidade (gelo, lâmpadas, Strong, dificuldade).
3. **Fricção justa, estilo Duolingo** — vidas e streak já existem; Pro alivia, não inventa paywall na primeira aula.
4. **B2C primeiro** — salas/células já existem; B2B igreja vem depois com tooling real.

---

## Free vs Pro

| Área | Free | Pro |
|------|------|-----|
| Trilhas base (AT/NT intro) | Todas as trilhas de entrada + mapa | — |
| Trilhas densas / Teologia / Profundezas | Semente + Rota | **Profundezas** desbloqueada de forma estável |
| Lâmpadas | 5 / missão | Continuar sem perder (ou refill diário) |
| Gelo de streak | 1 / semana | **3 / semana** + prioridade |
| Reparar streak | 1 / mês | **3 / mês** |
| Strong / morfologia / concordância | Preview limitado (ex.: 5 consultas/dia) | Ilimitado |
| Prática (erros, memória) | Básica | Revisões ilimitadas + packs |
| Liga / companheiros / salas | Tudo liberado (crescimento) | Cosmético leve depois (opcional) |
| Ads | Sem ads no início | Sem ads se um dia houver |
| Offline conteúdo denso | Leitor Bíblia ok | Cache de preparos/trilhas Pro |

**Regra de conteúdo:** ~70% do catálogo jogável free; ~30% “escola” (Teologia, profundidade, trilhas longas) = Pro ou free com teto de dificuldade.

---

## Preços (Brasil — ponto de partida)

| Plano | Preço | Nota |
|-------|-------|------|
| **Pro mensal** | R$ 19,90 | Entrada baixa |
| **Pro anual** | R$ 119,90 (~R$ 10/mês) | Empurrar no paywall (“2 meses grátis”) |
| **Trial** | 7 dias Pro | Depois da **3ª missão** ou no **1º gelo usado** |
| **Igreja** (fase 2) | R$ 49–99/mês até N membros | Salas + progresso do grupo |

Comparáveis de mercado: Duolingo Super ~R$ 30–50/mês; Hallow/Pray ~US$ 70–100/ano. STWAY posiciona no meio-baixo para converter cedo no BR.

---

## Onde encaixar no fluxo

```
Splash → Login → Onboarding (sem paywall)
  → Hoje (missão) → Lesson → Celebration
       │
       ├─ Soft: badge “Pro” sutil no perfil / settings
       ├─ Soft: após missar lâmpada → “Continuar com Pro”
       ├─ Soft: streak em risco → “Gelo extra com Pro”
       ├─ Soft: Strong na Bíblia → gate suave após N consultas
       └─ Hard (1×): pós 7º dia de streak OU 10ª missão → sheet Pro com trial
```

| Momento | Tela | Trigger | CTA |
|---------|------|---------|-----|
| A | `celebration_screen` | 10ª missão OU 7 dias de streak | “7 dias de Pro grátis” |
| B | `lesson_screen` / `lamps_bar` | 0 lâmpadas | “Recuperar e continuar” (Pro) |
| C | streak widgets | Risco / repair esgotado | “Proteger caminhada” |
| D | `bible_screen` Strong | Limite diário | “Estudo ilimitado” |
| E | `difficulty_picker` | Escolher Profundezas | “Modo escola — Pro” |
| F | `settings` / `me_screen` | Sempre | Gerenciar Pro |

**Não mostrar paywall:** onboarding, login, primeira trilha, splash.

---

## Packs avulsos (opcional — fase 1.5)

Só se a assinatura não converter o bastante:

| Pack | Preço |
|------|-------|
| 3 gelos | R$ 6,90 |
| Reparar agora | R$ 4,90 |
| Refill de lâmpadas | R$ 3,90 |

A assinatura deve ser claramente melhor que somar packs.

---

## Fase 2 — Igreja / célula

Base existente: `room_service` + superfícies novas no admin.

| Feature igreja | Valor |
|----------------|-------|
| Painel do líder (progresso da sala) | Por que paga |
| Trilhas “da igreja” (conteúdo custom via admin) | Diferencial |
| Assentos / convites ilimitados na sala | Limite free: 1 sala, N membros |
| Relatório semanal do grupo | Retenção B2B |

Free continua com salas pequenas; líder que quer acompanhar discipulado → plano Igreja.

---

## Implementação (ordem)

1. Flag `isPro` no user (Firestore) + RevenueCat ou `in_app_purchase`
2. Paywall sheet reutilizável (momentos A–F)
3. Gates: gelo, repair, lâmpadas continue, Strong limit, Profundezas
4. Settings: status da assinatura / restaurar compra
5. Depois: packs IAP e SKU Igreja

---

## Métricas de sucesso (90 dias)

- Trial start ≥ 8–12% dos usuários ativos D7
- Trial → pago ≥ 35–45%
- Free → Pro (sem trial) ≥ 2–4%
- Churn mensal Pro < 8%
- D7 retention não cair > 10% vs baseline (paywall não pode matar o hábito)

---

## Resumo

**Free = academia do hábito.**  
**Pro = nunca perder a caminhada + estudar de verdade (Strong + Profundezas).**  
**Igreja = salas com acompanhamento.**
