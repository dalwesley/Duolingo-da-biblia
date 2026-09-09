# STWAY — Documentação de produto

**Atualizado:** 9 set/2026  
**Versão do app:** 1.0.23  
**Norte completo:** [`ROADMAP.md`](../ROADMAP.md)  
**Pitch 1 página (nós vs. eles):** [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md)  
**Motor de formação (diretriz):** [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md)  
**Contrato de sessão (implementado):** [`SESSAO_TREINO.md`](SESSAO_TREINO.md) · técnico: [`TECNICA.md`](TECNICA.md) · D7: [`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md)

---

## Estado do produto (honestidade)

| Camada | Situação |
|--------|----------|
| **Shell de sessão** | Pronto — entrada → 6 gestos (V/F · toque no verso · escolher · ordenar · completar · conectar) → insight → saída |
| **Conteúdo no Firebase** | Seed CLI **24 ago** — **8.370** perguntas, validador **verde**, palco TB, 6 gestos. `catalog.version` `1787584947461`. |
| **UI / UX** | Tema escuro cinemático, 5 tabs; Toque responde no versículo (`buildTapSpans`) |
| **Distribuição no app** | Cache por trilha no boot; limpa banco antigo quando `catalog.version` muda; atos baixados ao abrir missão |
| **Escola no conteúdo** | 6 gestos ~equilibrados; palco TB; Gn 1–11 editorial; Êxodo/Sermão pack; resto gerado — próximo salto = handcraft vitrine |
| **Strong** | Offline na aba Bíblia **e** na missão (toque na referência do ato → Estudar) |
| **Prova com usuário** | Protocolo D7 pronto ([`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md)); falta execução com 10–20 testers |
| **Monetização** | Sem IAP |

---

## Em uma frase

STWAY são **missões diárias em português** para criar **hábito de ler e estudar a Bíblia** — em poucos minutos por dia, com currículo, exercícios e Strong quando o versículo pede.

**Frase competitiva:** *“Enquanto outros te fazem jogar a Bíblia, o STWAY te põe em missão nela.”*

Não somos YouVersion (só ler), Hallow (orar), Ascend/Bible Way (jogo com pet/heróis sem estudo), nem trivia vazia.  
**Sensação:** Duolingo no loop · **ler e estudar a Palavra de verdade**.

---

## Para quem

Cristãos de língua portuguesa que querem:

- Formar **hábito** de estudo bíblico (streak, missões curtas ~2–4 min)
- **Aprender de verdade** (exercícios com feedback, competências, Strong/morfologia)
- Caminhar um **currículo** coerente (Criação → NT), em rede — não só versículos soltos
- Ter **accountability** leve (Companhia, Salas, Caravana semanal)

---

## Proposta de valor

| O que entrega | Como |
|---------------|------|
| Formação progressiva | Jornada → trilhas → cenas → **missões** → exercícios tipados |
| Hábito diário | Missão do dia, quests, streak, lembretes locais |
| Profundidade | 3 níveis cognitivos (Semente / Rota / Profundezas) + Strong offline |
| Social leve | Caravana (liga semanal), Companhia 1:1, Salas de estudo |
| Conteúdo vivo | CMS admin no Firebase (studio com preview do ato) — atualiza sem release na loja |

Regra de feature ([§46](LEARNING_ENGINE.md)): *isso torna o usuário melhor em ler, compreender, conectar, interpretar, lembrar ou viver a Palavra?*

---

## Experiência do usuário

### Abas principais

1. **Hoje** — Próxima missão dominante, quests, streak, entrada para prática/memória  
2. **Trilhas** — Catálogo por reino (AT / NT / Vida Cristã / Teologia)  
3. **Bíblia** — Leitor offline + estudo Strong ao tocar no versículo  
4. **Juntos** — Caravana, Companhia, Salas  
5. **Config** — Som, notificações, export/import, logout  

### Fluxo principal

```
Splash → Login (Google / Apple no iOS) → Onboarding (1ª vez)
  → Hoje: continuar missão
  → Mapa da trilha → Dificuldade → Missão → Celebração
  → (opcional) Bíblia / Prática / Memória / Juntos
```

Onboarding em 5 beats: origem → hábito → caminhada → ritmo → primeira trilha (Gênesis 1–11).

### Loop da missão

1. Entrada curta (título · verso · contexto/conexão · Começar)  
2. Atos tipados no mesmo shell (V/F, toque, escolher, ordenar, completar, conectar) — **8** padrão · boss **10**  
3. Erro com correção em 1 linha + nova chance; acerto gera **passos**  
4. Se errou: micro-review (outro gesto) opcional  
5. Insight (“Hoje: …”) → saída (passos / streak; micro bônus de verso opcional)  
6. Bosses = revisão / interleaving do módulo  

Composer monta a sessão **só do banco** Firestore. Detalhe: [`SESSAO_TREINO.md`](SESSAO_TREINO.md) · [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md).

### Moeda / retenção

- **Passos** — unidade de progresso (legado interno ainda usa `xp` em alguns campos)  
- **Lâmpadas** — vidas na missão  
- **Streak** — sequência diária (com freeze/repair)  
- **Quests** diárias e semanais (+ sazonais litúrgicas)  
- **Caravana** — liga semanal por tier (Semente → Videira → Oliveira → Cedro → Estrela)  

Gamificação reforça aprendizagem — não recompensa clique vazio.

---

## Conteúdo

### Hierarquia (v2)

```text
JORNADA → TRILHA → CENA → MISSÃO → EXERCÍCIO
```

| Camada | Exemplo |
|--------|---------|
| Jornada | Criação → Queda → … → Nova Criação |
| Trilha | Gênesis 1–11 (ou transversais: Como ler a Bíblia) |
| Cena | A Criação |
| Missão | Imagem de Deus |
| Exercício | escolha, ordene, conexão, evidência… |

No produto, a unidade curta chama-se **missão**. Ver glossário abaixo.

### Caminho canônico (unlock)

`genesis-1-11` → `genesis-12-50` → `exodo` → `evangelhos` → `atos` → `cartas-paulo` → `apocalipse`

### Dificuldades (operações cognitivas)

| Nível | Nome no produto | Intenção |
|-------|-----------------|----------|
| Semente | Semente | Reconhecer / recordar / identificar |
| Rota | Rota (caminhada) | Compreender / comparar |
| Profundezas | Profundezas | Interpretar, conectar, sintetizar, transferir |

Não são “fácil / médio / difícil” em obscuridade — são **operações diferentes** sobre o mesmo conhecimento.

### Bíblia e Strong

- Traduções offline (TB, Almeida JFA)  
- Aba Bíblia: toque no versículo → **Estudar** (Strong, morfologia, concordância)  
- **Na missão:** toque na referência do palco (`Gn 1:27 · ESTUDAR`) → mesmo sheet, sem sair da sessão  
- Fonte: STEPBible / openbible.info (CC BY)  
- Strong serve interpretação contextual — não “significado secreto”

### Conteúdo e “pilotos”

Não há mais missão especial embutida. `gen-03-imagem` e o restante usam o mesmo pipeline (`content_bank_questions` + composer).

| Item | Status |
|------|--------|
| Banco tipado + skills | **8.370** atos V2 no Firestore (seed 24 ago); 6 gestos; palco TB; validador verde |
| Objective / insight / hooks nas missões | Presentes no catálogo |
| Spec histórica Imagem de Deus | [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md) |
| Sermão do Monte e Êxodo | Packs congelados (`_sermao_v2_data` / `_exodo_v2_data`) + gerador verso-primeiro |

### UI / UX (resumo)

- **Visual:** tema escuro noturno, accent azul + CTA amarelo, painéis elevados, fundo imersivo / cinemático em Gênesis  
- **Padrão:** 5 tabs (Hoje · Trilhas · Bíblia · Juntos · Config); mapa de trilha; picker de dificuldade  
- **Força:** sessão curta com gestos variados no mesmo shell  
- **Fraqueza vs. mercado:** polish/escala de marca; densidade visual de “game HUD” pode obscurecer a sensação de “escola”  

---

## Social

| Feature | O quê |
|---------|--------|
| **Caravana** | Ranking semanal em tiers; promove/rebaixa |
| **Companhia** | Dupla de accountability; convite QR / deep link `stway://companhia/CODIGO` |
| **Salas** | Grupo privado de estudo |

---

## Monetização

Hoje: **sem IAP, ads ou assinatura** no app.  
Direção (28 ago): Pro anual **R$ 119,90** · Família · Igreja na web. Não gatear Profundezas do canônico. [`MONETIZATION.md`](../MONETIZATION.md).

---

## Critérios de sucesso (produto)

Antes de “crescer” de verdade (ver Roadmap):

1. Retenção D7 ok no loop de missão  
2. Um caminho Criação → NT terminável, validado com tester  
3. Usuário explica o app numa frase alinhada ao norte (*“app de missões pra criar hábito de ler a Bíblia”*)  
4. Após uma missão: lembra, explica e reconhece o conceito em outro texto (transferência)

Regra de feature: *aumenta conclusão de missão, retenção ou retorno em 7 dias — sem sacrificar aprendizagem?*

---

## Papéis no ecossistema

| Superfície | Quem | Função |
|------------|------|--------|
| App Flutter (`trilha_app`) | Aprendiz | Treino diário |
| Admin (`admin`) | Editor / admin | Publicar currículo, banco, estudos, Question Studio + preview, moderar relatos, release remoto |

Pipeline editorial: [`LEARNING_ENGINE.md` §42–43](LEARNING_ENGINE.md).

---

## Posicionamento vs. concorrentes

**Canvas mestre (24 ago):** `canvases/stway-posicionamento-mercado-24ago2026.canvas.tsx`

### Mapa em duas dimensões

| | **Consumo passivo** (ler · orar · ouvir) | **Prática ativa** (exercícios · competência) |
|---|------------------------------------------|-----------------------------------------------|
| **Escala / marca** | YouVersion · Hallow · Glorify | — |
| **Formação / currículo** | Planos YouVersion | **STWAY** · (parcial) Bible Way |

STWAY ocupa **formação ativa em PT-BR** — nicho que gigantes não priorizam.

### Diretos (mesmo job: “Bíblia no bolso”)

| Player | O que faz | STWAY vs |
|--------|-----------|----------|
| **YouVersion** | Ler + planos + áudio + social igreja | Não competimos em catálogo. Competimos em *hábito de ler e estudar*. |
| **Bible Way / Ascend / Manna** | Game + streak + pet/herói | Gamificam *tema*. STWAY gamifica *competência* (6 gestos, 3 modos). |
| **Show do Biblião / trivia** | Quiz de memória | Sem currículo nem Strong. STWAY = trilha + profundidade. |

### Indiretos (mesmo bolso: tempo / hábito espiritual)

| Player | O que faz | STWAY vs |
|--------|-----------|----------|
| **Hallow** | Oração guiada + áudio | Complementar. **Não** virar app de oração. |
| **Glorify** | Adoração + devocional + polish | **Não** competir em biblioteca sonora. |
| **Duolingo** | Loop de hábito | Copiamos o *loop*; rejeitamos tom punitivo e conteúdo genérico. |
| **Apps de igreja** | CMS pastoral | STWAY = produto do *aprendiz*; igreja = canal futuro (Salas). |

### O que só STWAY junta (hoje)

- Sessão 2–4 min com **6 gestos** + insight (não só MCQ)
- **3 profundidades** cognitivas (Observação / Compreensão / Interpretação)
- **Currículo** Criação → NT no Firebase
- **Strong offline** na missão (ref do palco) e na aba Bíblia
- **CMS + validador pedagógico** — conteúdo vivo sem release
- **Social leve** — Caravana, Companhia, Salas (accountability, não feed de XP)

### Onde não competimos

- MAU / downloads / marca global
- Maior catálogo de áudio ou oração ambient
- Game MMO / pet / skin shop

**Competimos em:** *depois de 3 minutos, a pessoa leu e estudou um trecho — e quer voltar amanhã.*

---

## Glossário rápido

| Termo | Significado |
|-------|-------------|
| Missão | Unidade pedagógica (~2–4 min, 3–8 exercícios); no código: `Mission` |
| Exercício | Ação tipada (`choice`, `order`, `connect`…) |
| Cena | Módulo dentro da trilha |
| Preparo / estudo | Texto + contexto + conexões da missão (legado: `MissionStudy`) |
| Passos (moeda) | Progresso ganho nas missões |
| Lâmpadas | Vidas na missão |
| Caravana | Liga semanal |
| Companhia | Par 1:1 |
| Relato | Report de exercício pelo usuário → fila no admin |
| Competência | Observar → … → Aplicar ([§9](LEARNING_ENGINE.md)) |
