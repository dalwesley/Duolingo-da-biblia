# STWAY — Documentação de produto

**Atualizado:** 20 set/2026  
**Versão do app:** 1.0.24+24  
**Norte completo:** [`ROADMAP.md`](../ROADMAP.md)  
**Pitch 1 página (nós vs. eles):** [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md)  
**Motor de formação (diretriz):** [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md)  
**Contrato de sessão (implementado):** [`SESSAO_TREINO.md`](SESSAO_TREINO.md) · técnico: [`TECNICA.md`](TECNICA.md) · D7: [`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md)

---

## Estado do produto (honestidade)

| Camada | Situação |
|--------|----------|
| **Shell de sessão** | Pronto — entrada → **6 atos** (boss **8**) nos 6 gestos → micro-verso opcional → insight → saída |
| **Conteúdo no Firebase** | Seed CLI **24 ago** — **8.370** perguntas, validador **verde**, palco TB, 6 gestos. `catalog.version` `1787584947461`. |
| **UI / UX** | Tema escuro cinemático, 5 tabs; Toque responde no versículo (`buildTapSpans`); medalhas v3.2 no perfil |
| **Distribuição no app** | Cache por trilha no boot; limpa banco antigo quando `catalog.version` muda; atos baixados ao abrir missão |
| **Escola no conteúdo** | 6 gestos ~equilibrados; palco TB; Gn 1–11 editorial; Êxodo/Sermão pack; resto gerado — próximo salto = handcraft vitrine |
| **Strong / TTS** | Strong offline na aba Bíblia **e** na missão (ref do palco → Estudar). TTS na Bíblia **e** na entrada da missão (passagem + “Hoje:” ~90 s) |
| **Caminhada** | Advento/Quaresma **só na janela** (29 nov–24 dez 2026). Calendário + cofre + banner aparecem sozinhos. |
| **Trilhas por dor** | Ansiedade → Sermão do Monte; Recomeço → Gênesis 1–11 (Vida Cristã, 5 missões, banco do cânon) |
| **Selos** | 6 personagens (fato + verso) no perfil/mapa/celebração — sem skin shop |
| **Hábito extra** | Widget home, FCM de aceno na companhia, lembrete após 1ª missão, Remote Config, gelo que cobre ontem ao virar o dia |
| **Social 1.0.24** | Esquina (desafio de uma cena até domingo, +10), retrato (foto/letra/avatar), online na liga |
| **Prática IRL** | `dailyChallenge` existe em **1** study (`sm-08`); o modelo `MissionStudy` **não parseia** — sem check-in |
| **Prova com usuário** | Protocolo D7 pronto ([`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md)); planilha vazia — falta 10–20 testers |
| **Monetização** | Casca RevenueCat (`Peregrino+`) **sem chaves** — IAP inativo. Perk previsto: 3→6 companheiros. Pro de verdade = [`MONETIZATION.md`](../MONETIZATION.md) (depois do D7) |

---

## Em uma frase

STWAY são **missões diárias em português** para criar **hábito de ler e estudar a Bíblia** — em poucos minutos por dia, com currículo, exercícios e Strong quando o versículo pede.

**Frase competitiva:** *“Enquanto outros te fazem jogar a Bíblia, o STWAY te põe em missão nela.”*

Não somos YouVersion (só ler), Hallow (orar), Ascend/Bible Way (jogo com pet/heróis sem estudo), Bibliando (missão sem os 6 gestos), Bíblia Fácil (oração+quiz), nem trivia vazia.  
**Sensação:** Duolingo no loop · **ler e estudar a Palavra de verdade**.

---

## Para quem

Cristãos de língua portuguesa que querem:

- Formar **hábito** de estudo bíblico (streak, missões curtas ~2–4 min)
- **Aprender de verdade** (exercícios com feedback, competências, Strong/morfologia)
- Caminhar um **currículo** coerente (Criação → NT), em rede — não só versículos soltos
- Ter **accountability** leve (Companhia, Salas, Caravana semanal, Esquina)

---

## Proposta de valor

| O que entrega | Como |
|---------------|------|
| Formação progressiva | Jornada → trilhas → cenas → **missões** → exercícios tipados |
| Hábito diário | Missão do dia, quests, streak, lembretes locais + FCM de aceno, widget |
| Profundidade | 3 níveis cognitivos (Semente / Rota / Profundezas) + Strong offline |
| Social leve | Caravana (liga semanal), Companhia 1:1, Salas, Esquina (mesma cena até domingo) |
| Conteúdo vivo | CMS admin no Firebase (studio com preview do ato) — atualiza sem release na loja |

Regra de feature ([§46](LEARNING_ENGINE.md)): *isso torna o usuário melhor em ler, compreender, conectar, interpretar, lembrar ou viver a Palavra?*

---

## Experiência do usuário

### Abas principais

1. **Hoje** — Uma missão dominante. Caminhada só na janela de Advento/Quaresma (ou prévia em Ajustes).  
2. **Trilhas** — Catálogo por reino (AT / NT / Vida Cristã / Teologia) — inclui Ansiedade e Recomeço  
3. **Bíblia** — Leitor offline + Strong + TTS + plano de leitura leve  
4. **Juntos** — Caravana, Companhia, Salas, Esquina  
5. **Config** — Som, notificações, Peregrino+ (casca), export/import, logout  

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
2. Atos tipados no mesmo shell (V/F, toque, escolher, ordenar, completar, conectar) — **6** padrão · boss **8** (`ProgressService`)  
3. Erro com correção em 1 linha + nova chance; acerto gera **passos**  
4. Se errou: micro-review (outro gesto) opcional  
5. Micro-verso opcional → insight (“Hoje: …”) → saída (passos / streak)  
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
- **Fraqueza vs. mercado:** polish/escala de marca; slogan “missão” já ocupado no BR (Bibliando); HUD de jogo pode obscurecer a sensação de “escola”  

---

## Social

| Feature | O quê |
|---------|--------|
| **Caravana** | Ranking semanal em tiers; promove/rebaixa; quem está online hoje |
| **Companhia** | Dupla de accountability; convite QR / deep link `stway://companhia/CODIGO` |
| **Salas** | Grupo privado de estudo |
| **Esquina** | Um desafio de cena por semana, até domingo, +10 ao fechar — não é PvP trivia |
| **Retrato** | Foto, letra ou avatar ilustrado (sem skin shop) |

---

## Monetização

Hoje: **IAP inativo**. Há tela Peregrino+ e SDK RevenueCat, mas as chaves estão vazias — ninguém compra. Caminhada, áudio da missão e revisão da semana **já estão no app**; dia 4+ da Caminhada só trava se as chaves existirem. Perk extra quando ligar: **mais companheiros**. Direção: [`MONETIZATION.md`](../MONETIZATION.md). Não gatear Profundezas do canônico. Não preencher as chaves RevenueCat antes do D7.

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

Pitch 1 página: [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md) · canvas `stway-concorrencia-direta-indireta.canvas.tsx`

**Veredito 20 set/2026 (noite):** o nicho “missões em PT-BR” tem **três** vozes (**Bibliando**, **Bíblia Fácil**, nós). Bible Way localiza de verdade (1.4.5, 10 idiomas). YouVersion ocupa o slot com *Plans with Friends*; Hallow, com oração + games na Home. O fosso STWAY continua sendo **treinar a leitura** (6 gestos · 3 modos · Strong · validador) + **par** (Companhia / Esquina) — não idioma, não slogan, não pet.

### Mapa em duas dimensões

| | **Consumo passivo** (ler · orar · ouvir) | **Prática ativa** (exercícios · competência) |
|---|------------------------------------------|-----------------------------------------------|
| **Escala / marca** | YouVersion · Hallow · Glorify · Manna | Bible Way · Ascend |
| **PT-BR / formação** | Guia de Fé (planos + igreja + IA) | **STWAY** · Bibliando · Verbo · Bíblia Fácil · trivia |

STWAY ocupa **formação ativa com pedagogia explícita**. Gigantes não priorizam isso; Bibliando prioriza o *formato* (missão/trilha/XP) sem os 6 gestos nem Strong; Bíblia Fácil mistura oração + quiz.

### Diretos (mesmo job: “Bíblia no bolso” + treino)

Por ameaça: Bibliando → Bible Way → Bíblia Fácil → Verbo → Show do Biblião → Ascend.

| Player | O que faz (2026) | STWAY vs |
|--------|------------------|----------|
| **Bibliando** | Missões + trilhas PT-BR; leitura + contexto + descoberta; 1ª trilha grátis, resto IAP | Clone de *copy*. Sem 6 gestos, 3 modos, Strong, Caravana/Esquina. Diferenciar na sessão. |
| **Bible Way** | Lição 5 min, heróis, clubes, ranking, IA, áudio/sleep; **PT de verdade** (1.4.5); Premium ~US$ 4,99/sem | Gamifica *tema* + coleção. STWAY gamifica *competência*. Não copiar IA solta. |
| **Bíblia Fácil** | Devocional 5 min + oração + quiz + “missões bíblicas”; 10 mil+ downloads BR | Terceiro dono da palavra *missão*. Híbrido raso. `lifeChallenge` (ainda fora do player) é a resposta à “missão prática”. |
| **Verbo / Show do Biblião** | Quiz + leitura / trivia multiplayer | Sem currículo progressivo nem evidência no palco. Não copiar PvP. |
| **Ascend** | Lição &lt;10 min, fênix, relics, battle pass, energia, Showdown PvP | Loop de jogo (energia/ads). STWAY recusa battle pass e PvP. |

### Indiretos (mesmo bolso: tempo / hábito espiritual)

| Player | O que faz (2026) | STWAY vs |
|--------|------------------|----------|
| **YouVersion** | 2.500+ versões; planos; áudio; *Plans with Friends* até 300; Guided Scripture/Prayer; QR | Não competimos em catálogo nem igreja-em-escala. Competimos em *hábito de ler e estudar*. Já está instalado — é o slot, não o quiz. |
| **Hallow** | Oração + áudio + Family (6 pessoas); Home com games e desafios de comunidade | Complementar. **Não** virar app de oração nem copiar o game na Home. |
| **Glorify** | Devocional ~10 min + adoração + polish (~20 M) | **Não** competir em biblioteca sonora. |
| **Manna** | Um trecho/dia, amanhã trava, widget — iPhone | Duolingo de *leitura*. STWAY é estudo ativo. |
| **Guia de Fé** | Bíblia offline + planos + grupo de igreja + conselheiro IA (BR) | Igreja-CMS + leitura. STWAY = treino do aprendiz. |
| **Duolingo** | Loop de hábito | Copiamos o *loop* (missão, streak, gelo ao virar o dia); rejeitamos tom punitivo. |

### O que só STWAY junta (hoje, 1.0.24)

- Sessão 2–4 min com **6 gestos** + insight (não só MCQ)
- **3 profundidades** cognitivas (Observação / Compreensão / Interpretação)
- **Currículo** Criação → NT no Firebase + pedido de trilha no mapa
- **Strong offline** na missão (ref do palco) e na aba Bíblia; intro histórica do livro
- **CMS + validador pedagógico** — conteúdo vivo sem release
- **Social leve** — Caravana (online hoje), Companhia, Salas, Esquina (accountability, não feed de XP)

### Onde não competimos

- MAU / downloads / marca global
- Maior catálogo de áudio ou oração ambient
- Game MMO / pet / skin shop / battle pass
- Planos infinitos e igreja de 300 amigos
- Prova de retenção (D7 ainda vazio)

**Competimos em:** *depois de 3 minutos, a pessoa leu e estudou um trecho — e quer voltar amanhã.*

---

## Glossário rápido

| Termo | Significado |
|-------|-------------|
| Missão | Unidade pedagógica (~2–4 min, **6** atos · boss **8**); no código: `Mission` |
| Exercício | Ação tipada (`choice`, `order`, `connect`…) |
| Cena | Módulo dentro da trilha |
| Preparo / estudo | Texto + contexto + conexões da missão (`MissionStudy`) |
| `dailyChallenge` | Desafio IRL no study — **ainda não no player** |
| Passos (moeda) | Progresso ganho nas missões |
| Lâmpadas | Vidas na missão |
| Caravana | Liga semanal |
| Companhia | Par 1:1 (FCM de aceno) |
| Esquina | Desafio de uma cena até domingo (+10 na Caravana) |
| Peregrino+ | Casca de assinatura — IAP inativo |
| Relato | Report de exercício pelo usuário → fila no admin |
| Competência | Observar → … → Aplicar ([§9](LEARNING_ENGINE.md)) |
