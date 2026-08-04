# Roadmap STWAY — formação bíblica com hábito

**Atualizado:** ago/2026 (caminho Criação→NT densificado + studies Sermão 25/25).

**Norte:** treino diário em português para aprender a Bíblia de verdade — missões curtas + estudo original offline.
Não somos YouVersion (ler), nem Hallow (orar), nem Ascend/Bible Way (jogo com pet/heróis sem escola), nem trivia vazia.
**Sensação:** academia da Palavra (Duolingo no loop · escola no conteúdo).
**Frase competitiva:** *“Enquanto outros te fazem jogar a Bíblia, o STWAY te treina nela.”*

## Critério de pronto para crescer

- [ ] Retenção D7 ok no loop de missão
- [ ] **1 caminho Criação → NT terminável** — estrutura e qualidade mínima prontas (ver abaixo); falta **prova com tester**
- [ ] Usuário explica o app numa frase alinhada ao norte (*"app pra treinar e aprender a Bíblia"*)

**Caminho canônico (unlock):**
`genesis-1-11` → `genesis-12-50` → `exodo` → `evangelhos` → `atos` → `cartas-paulo` → `apocalipse`

| Elo | Estado |
|-----|--------|
| Gênesis 1–11 / 12–50 / Êxodo / Evangelhos | denso + studies |
| Atos | **10 missões** (2 módulos) + studies + banco 3 níveis |
| Cartas de Paulo (entrada) | panorama 3 passos + studies enriquecidos |
| Apocalipse | **8 missões** (2 módulos) + studies + banco 3 níveis |

Regra: nenhuma feature nova sem responder *"aumenta conclusão de missão ou retorno em 7 dias?"*

Histórico de releases: [`CHANGELOG.md`](CHANGELOG.md).

---

## Feito (base)

- [x] Congelar frase-mãe / filtro de features (este doc)
- [x] **Publicar conteúdo no Firebase** (trails + studies + bank) — app já lê da nuvem
- [x] Instrumentar loop: abertura → missão iniciada → concluída → D1/D7 (+ analytics de pergunta)
- [x] Currículo amplo no catálogo (AT panorâmico + Evangelhos + Epístolas + Atos/Apocalipse densos)
- [x] **Gênesis 12–50** jogável (Abraão → José)
- [x] **Atos** arco jogável (Jerusalém → confins) · **Apocalipse** arco jogável (cartas/trono → nova criação)
- [x] Unlock narrativo Êxodo ← Gênesis 12–50; Apocalipse ← Cartas de Paulo
- [x] Strong / estudo no caminho da missão (`StudyPanel` na lição, não só aba Bíblia)
- [x] Onboarding → Gênesis 1–11 (deep-link pós-login)
- [x] Home: um trabalho dominante = próxima missão (+ card da Palavra)
- [x] Identidade **Academia da Palavra** (copy + tipografia + loop estudo→quiz→reflexão opcional)
- [x] Social base: Caravana · Companhia · Salas (+ convite deep link `stway://companhia`)
- [x] Calendário litúrgico (quests sazonais)
- [x] Feedback pedagógico no erro + modo boss real
- [x] Sync por conta endurecido (sem misturar progresso entre usuários)
- [x] **Relato de pergunta** (sheet na lição → `content_question_reports` → admin Relatos)
- [x] Análise competitiva profunda (ago/2026) → prioridades abaixo

### Piloto Sermão do Monte — estrutura

- [x] **6 cenas / 31 missões** (25 passos + 6 bosses) cobrindo Mateus 5–7 — não o mapa antigo de 12 cenas
- [x] Banco 3 níveis (Semente / Rota / Profundezas) nos passos
- [x] `MissionStudy` em **sm-01…sm-25** (25/25 passos de conteúdo; bosses = revisão)

Mapa real (fonte: `trails.json` / Firebase):

| Cena | Foco | Passos |
|------|------|--------|
| 1 | As Bem-aventuranças | sm-01…05 + boss |
| 2 | O Caráter do Reino | sm-06…09 + boss |
| 3 | Identidade e Missão | sm-10…13 + boss |
| 4 | Relações do Reino | sm-14…17 + boss |
| 5 | Vida diante do Pai | sm-18…21 + boss |
| 6 | Decisões do discípulo | sm-22…25 + boss final |

---

## Agora — provar o loop (1–4 semanas)

Foco: **publicar no Firebase + usuários reais**. Buracos estruturais do caminho e studies do Sermão fechados no asset local.

- [x] **Seed** trails + studies + banks no Firebase (`seed_content.mjs` — ago/2026)
- [ ] Medir time-to-value: onboarding → 1ª missão concluída em &lt;2 min
- [ ] Teste com 10–20 pessoas reais; anotar abandono e frase espontânea do app
- [ ] Pipeline semanal no admin: ajustes via Relatos sem release
- [ ] Strong como momento “uau” na 1ª semana do Sermão (provar com tester)
- [ ] Caminhar o arco Criação→NT com 1–2 testers (caçar buraco residual de copy/quiz)
- [ ] Não expandir plano de leitura / paridade YouVersion

Critério de sucesso desta fase = conclusão de missão e retorno D7 **no Sermão** (trilha-vitrine).

---

## Depois — fosso visível (4–8 semanas)

Só avançar o que melhora D7. Roubar do mercado **melhorado**, sem virar clone.

### Currículo e hábito
- [ ] Prova do caminho Criação → NT com testers (critério de pronto — conteúdo mínimo já no asset)
- [ ] Densificar Romanos / Tiago se abandono aparecer na entrada das Epístolas
- [ ] Trilhas de entrada por dor (3–5 missões: ansiedade, recomeço…) que desembocam no currículo canônico
- [ ] Sermão vitrine: testers terminam as 6 cenas (studies já 100% nos passos)

### Anatomia da missão (núcleo enxuto — não 9 telas)

Evitar funil tipo curso (Intro→Contexto→Estudo→Curiosidade→Conexões→Quiz→Desafio→Reflexão→XP). Sessão alvo: **3–5 min**.

Núcleo:
1. **Preparo** — passagem + 1 insight de contexto (`MissionStudy` curto)
2. **Fixação** — quiz (já existe)
3. **Conexão** — 1 verso relacionado *ou* 1 curiosidade (não os dois sempre)
4. **Prática** — desafio da vida real (abaixo)
5. **[Opcional]** — reflexão escrita (já existe)

- [x] Fechar studies do Sermão (sm-01…05) antes de inventar motor de steps
- [ ] Curiosidade / conexões = campos opcionais no conteúdo, não fases obrigatórias
- [ ] Desafio cognitivo extra (match, completar verso) só se provar retenção de memória

### Desafio da vida real (diferencial de transformação)

Tese: apps ensinam conhecimento; STWAY fecha com **obediência concreta** (Sermão do Monte *é* ética do Reino).

- [ ] Campo `lifeChallenge` / `dailyChallenge` no fim da missão (título + 1 frase acionável)
- [ ] Check-in leve: Fiz / Ainda não / Refleti — **sem punição**, sem prova/foto
- [ ] XP pequeno ou só via reflexão existente — não segundo sistema de reward paralelo
- [ ] Follow-up no dia seguinte: “Como foi o desafio de ontem?” (1 prompt)
- [ ] Pilotar nas bem-aventuranças (misericórdia, pureza, paz, ansiedade…) antes de generalizar

**Cuidado teológico:** não gamificar pecado/perdão com XP alto; convite pastoral > mecânica de clique.

### Diferenciais (roubar melhorado)
- [ ] **Áudio da missão** (MVP): passagem narrada + 1 insight do preparo — commute BR; não hub de oração
- [ ] **Selos de personagem da trilha** (Abrão, Moisés…): 1 fato teológico + versículo âncora — heróis Bible Way sem skin shop
- [x] **Living Seed elevado**: reações à streak / risco / missão perfeita — companion Ascend com metáfora bíblica (já existe base)
- [ ] **Campanha litúrgica piloto** (Advento ou Quaresma): quest + trilha curta em massa — #Pray40 do Hallow, no DNA STWAY
- [x] **Pulso semanal nas Salas**: quem caminhou + baú de grupo (+15 passos)
- [x] **Micro-modo cognitivo** na missão: completar verso (~20s) após o quiz
- [x] **Home/onboarding game-first**: HUD + missão pronta; estudo (Palavra) depois do loop
- [x] **Celebração placar**: combo / rank Caravana / quase promove

### Identidade
- [ ] Ícone/mascote com mais energia de jogo (iteração visual) — sem battle pass cosmético
- [x] Posicionamento nítido na superfície: *missão · lâmpadas · streak · Bíblia* (onboarding/home)

---

## Em seguida — monetizar + célula (após D7 ok)

Ver `MONETIZATION.md`. Não shipar Pro antes do hábito provar valor.

- [ ] STWAY Pro (gates: gelo, lâmpadas, Strong, Profundezas) + trial pós 3ª missão / 1º gelo
- [ ] Soft paywalls nos pontos A–F do MONETIZATION.md
- [ ] Plano Igreja piloto (1–3 líderes): Salas + progresso do grupo + códigos presente Pro
- [ ] Opcional: 1 minuto de oração pós-celebração (não aba Hallow)

### Motor de etapas configuráveis (só se retenção pedir)

Não começar por aqui. Schema de steps (contexto, curiosidade, match…) + admin + `LessonScreen` data-driven **depois** de Sermão polido + `lifeChallenge` validados.

- [ ] Spec de steps versionados (cliente antigo ignora tipos desconhecidos)
- [ ] Editor admin por módulo/cena (hoje o UI simples colapsa em `modules[0]`)

---

## Segurar (até D7 ok — e depois, com filtro)

### Até D7 ok
- [ ] Novas mecânicas de liga/social além do pulso de Salas
- [ ] Paridade com YouVersion (traduções em massa, **planos infinitos**, feed) — plano de leitura leve ok; não virar produto de leitura
- [ ] Oração/meditação estilo Hallow (hub de sono/rosário)
- [ ] Polimento cinematográfico sem missão nova / sem study faltante
- [ ] **9 etapas obrigatórias por missão** (pipeline de curso, mata micro-sessão)
- [ ] Motor multi-step / “clone Duolingo” antes de Sermão 100% + prática IRL
- [ ] XP alto em atos de vida real não verificáveis
- [ ] Mais trilhas “em breve” / volume NT sem studies e sem testers no Sermão

### Nunca (ou só com prova forte)
- [ ] Battle pass / den / relics / ads de energia estilo Ascend
- [ ] PvP trivia tempo real estilo Desafio Bíblico
- [ ] IA solta “explica o versículo” sem ancoragem Strong/texto
- [ ] Expandir feature surface social antes do caminho Criação→NT estar sólido
- [ ] Exigir prova pública de desafio espiritual (foto, testemunho obrigatório)

---

## Inventário de conteúdo (alvo)

| Trilha | Hoje (aprox.) | Alvo próximo |
|--------|---------------|--------------|
| Gênesis 1–11 | 14 missões | manter qualidade |
| Gênesis 12–50 | 23 missões | manter / densificar se D7 pedir |
| Êxodo | 12 · unlock após Gen 12–50 | aprofundar onde abandono aparecer |
| Evangelhos | 12 densificados | manter |
| **Sermão do Monte** | **31 · studies 25/25** | prova D7 / testers nas 6 cenas |
| Cartas de Paulo (entrada) | 3 + studies | manter como ponte |
| Epístolas (livros) | scaffold ~3–6/livro | densificar se abandono |
| **Atos** | **10 (2 módulos)** | manter / polir via Relatos |
| **Apocalipse** | **8 (2 módulos)** | manter / polir via Relatos |

### Ordem de execução (resumo)

1. **Seed Firebase** — publicar assets (trails, studies, nt/sermao banks)
2. **Prova** — 10–20 testers + D7 no Sermão e 1 volta no caminho Criação→NT
3. **Prática** — `lifeChallenge` leve + check-in + follow-up
4. **Motor** — steps configuráveis só se D7 / conclusão pedirem

## Fosso vs mercado (lembrete)

| Nós | Eles |
|-----|------|
| Strong + Bíblia offline na missão | Ascend/Bible Way: quiz + pet/heróis |
| Dificuldade pedagógica (Semente→Profundezas) | Hearts/energy genéricos |
| Reflexão + preparo + **desafio de vida real** (próximo) | Trivia ou devocional raso |
| Granularidade tipo Duolingo no currículo (Sermão 31 passos) | Capítulos “resumidos” em poucas missões |
| Relatos de pergunta → correção rápida no admin | Conteúdo engessado em release |
| pt-BR first + liturgia | EN-first ou localização superficial |
| Célula/Salas → Igreja | Leaderboard global vazio |

Janela: Bible Way já localiza; Ascend pode localizar. Ser o padrão **academia bíblica pt-BR** agora — treino + compreensão + prática que sai do app.
