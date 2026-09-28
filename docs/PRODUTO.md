# STWAY — Documentação de produto

**Atualizado:** 28 set/2026  
**Versão do app:** 1.0.29+29  
**Norte completo:** [`ROADMAP.md`](../ROADMAP.md)  
**Pitch 1 página (nós vs. eles):** [`PITCH_NOS_VS_ELES.md`](PITCH_NOS_VS_ELES.md)  
**Simplificação UX (Fases 0–4):** [`PLANO_SIMPLIFICACAO.md`](PLANO_SIMPLIFICACAO.md)  
**Motor de formação (diretriz):** [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md)  
**Contrato de sessão (implementado):** [`SESSAO_TREINO.md`](SESSAO_TREINO.md) · técnico: [`TECNICA.md`](TECNICA.md) · D7: [`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md)

---

## Estado do produto (honestidade)

| Camada | Situação |
|--------|----------|
| **Shell de sessão** | Pronto — entrada → **6 atos** (boss **8**) nos 6 gestos → micro-verso opcional → insight → saída |
| **Conteúdo no Firebase** | Seed CLI **24 ago** — **8.370** perguntas, validador **verde**, palco TB, 6 gestos. `catalog.version` `1787584947461`. |
| **UI / UX** | Tema escuro cinemático, 5 tabs; Toque no versículo; medalhas v3.2; Juntos = Companhia → Caravana → Grupos (Desafio sob Companhia); boss UI = Travessia |
| **Distribuição no app** | Cache por trilha no boot; limpa banco antigo quando `catalog.version` muda; atos baixados ao abrir a cena |
| **Escola no conteúdo** | 6 gestos ~equilibrados; palco TB; Gn 1–11 editorial; Êxodo/Sermão pack; resto gerado — próximo salto = handcraft vitrine |
| **Strong / TTS** | Strong offline na aba Bíblia **e** na cena (ref do palco → Estudar). TTS na Bíblia **e** na entrada da cena (passagem + “Hoje:” ~90 s) |
| **Caminhada (estação)** | Advento/Quaresma **só na janela** (29 nov–24 dez 2026). Calendário + cofre + banner aparecem sozinhos. Não confundir com o modo cognitivo `caminhada`. |
| **Trilhas por dor** | Ansiedade → Sermão do Monte; Recomeço → Gênesis 1–11 (Vida Cristã, 5 cenas, banco do cânon) |
| **Selos** | 6 personagens (fato + verso) no perfil/mapa/celebração — sem skin shop |
| **Hábito extra** | Widget home, FCM de aceno na companhia, lembrete após 1ª cena, Remote Config, gelo (cobre ontem + sheet 1×), toast de lâmpadas no 1º erro |
| **Social** | Companhia 1:1 · Caravana (Geral/Semana) · Grupos · Desafio (mesma cena até domingo, +10; código `Corner*`) · retrato · online |
| **Simplificação 28 set** | Fases 0–4 em [`PLANO_SIMPLIFICACAO.md`](PLANO_SIMPLIFICACAO.md). Fase 5 (convite unificado) adiável. |
| **Prática IRL** | `dailyChallenge` existe em **1** study (`sm-08`); o modelo `MissionStudy` **não parseia** — sem check-in |
| **Prova com usuário** | Protocolo D7 pronto ([`D7_TESTER_PROTOCOLO.md`](D7_TESTER_PROTOCOLO.md)); planilha vazia — falta 10–20 testers |
| **Monetização** | Casca RevenueCat (`Peregrino+`) **sem chaves** — IAP inativo. Perk previsto: 3→6 companheiros. Pro de verdade = [`MONETIZATION.md`](../MONETIZATION.md) (depois do D7) |

---

## Em uma frase

STWAY é **hábito bíblico gamificado**: missões curtas em português para **ler e estudar a Bíblia todo dia**, com o ritmo de um jogo.

**Frase competitiva:** *“Enquanto outros te fazem jogar a Bíblia, o STWAY te põe em missão nela.”*

Não somos YouVersion (só ler), Hallow (orar), Ascend/Bible Way (jogo com pet/heróis sem estudo), Bibliando (missão sem os 6 gestos), Bíblia Fácil (oração+quiz), nem trivia vazia.

**Hierarquia:** o verso é o centro; o jogo é o pulso (começar, sequência, voltar amanhã). Não é game bíblico — é o hábito de abrir a Bíblia, feito para viciar no bom sentido.

---

## Para quem

Cristãos de língua portuguesa que querem:

- Formar **hábito** de estudo bíblico (streak, missões curtas ~2–4 min)
- **Aprender de verdade** (exercícios com feedback, competências, Strong/morfologia)
- Caminhar um **currículo** coerente (Criação → NT), em rede — não só versículos soltos
- Ter **accountability** leve (Companhia, Grupos, Caravana semanal, Desafio)

---

## Proposta de valor

| O que entrega | Como |
|---------------|------|
| Formação progressiva | Jornada → trilhas → **cenas** → exercícios tipados (código: `Mission`) |
| Hábito diário | Cena do dia, quests, sequência, lembretes locais + FCM de aceno, widget |
| Profundidade | 3 modos: Observação / Compreensão / Interpretação (ids `semente` / `caminhada` / `profundezas`) + Strong offline |
| Social leve | Companhia → Caravana → Grupos; Desafio sob Companhia (mesma cena até domingo) |
| Conteúdo vivo | CMS admin no Firebase (studio com preview do ato) — atualiza sem release na loja |

Regra de feature ([§46](LEARNING_ENGINE.md)): *isso torna o usuário melhor em ler, compreender, conectar, interpretar, lembrar ou viver a Palavra?*

---

## Experiência do usuário

### Abas principais

1. **Hoje** — Uma cena dominante. Estação (Advento/Quaresma) só na janela.  
2. **Trilhas** — Catálogo por reino (AT / NT / Vida Cristã / Teologia) — inclui Ansiedade e Recomeço  
3. **Bíblia** — Leitor offline + Strong + TTS + plano de leitura leve  
4. **Juntos** — Companhia · Caravana · Grupos (Desafio sob Companhia)  
5. **Ajustes** — Ritmo, lembretes, aparência, Peregrino+ (casca), conta  

Perfil abre pelo avatar na Home (não é aba).

### Fluxo principal

```
Splash → Login (Google / Apple no iOS) → Onboarding (1ª vez)
  → Hoje: continuar cena
  → Mapa da trilha → Dificuldade → Cena → Celebração
  → (opcional) Bíblia / Prática / Memória / Juntos
```

Onboarding em **6 beats**: origem → hábito → intenção → céu → ritmo → limiar (1ª trilha / Gênesis 1–11).

### Loop da cena

1. Entrada curta (título · verso · contexto/conexão · Começar)  
2. Atos tipados no mesmo shell (V/F, toque, escolher, ordenar, completar, conectar) — **6** padrão · travessia/boss **8** (`ProgressService`)  
3. Erro com correção em 1 linha + nova chance; acerto gera **passos**  
4. Se errou: micro-review (outro gesto) opcional  
5. Micro-verso opcional → insight (“Hoje: …”) → saída (passos / sequência)  
6. Travessias (boss) = revisão / interleaving do módulo   

Composer monta a sessão **só do banco** Firestore. Detalhe: [`SESSAO_TREINO.md`](SESSAO_TREINO.md) · [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md).

### Moeda / retenção

- **Passos** — unidade de progresso (legado interno ainda usa `xp` em alguns campos)  
- **Lâmpadas** — vidas na cena  
- **Sequência** — dias seguidos (gelo 1×/semana + reparo mensal; sheet 1× quando o gelo salva)  
- **Quests** diárias e semanais (+ sazonais litúrgicas)  
- **Caravana** — liga semanal por tier (Semente → Videira → Oliveira → Cedro → Estrela)  
- **Lamparinas / jarros** — histórico de 12 semanas no perfil (atrás de “Histórico das semanas”)  

Gamificação reforça aprendizagem — não recompensa clique vazio.

---

## Conteúdo

### Hierarquia (v2)

```text
JORNADA → TRILHA → CENA → EXERCÍCIO
```

| Camada | Exemplo | Nota |
|--------|---------|------|
| Jornada | Criação → Queda → … → Nova Criação | Arco canônico |
| Trilha | Gênesis 1–11 | Curso |
| Cena | Imagem de Deus | Unidade curta na **UI**; código `Mission` / marketing pode dizer “missão” |
| Exercício | escolha, ordenar, conectar… | Gesto tipado |

Fonte de verdade de copy: [`../trilha_app/docs/design_language.md`](../trilha_app/docs/design_language.md).

### Caminho canônico (unlock)

`genesis-1-11` → `genesis-12-50` → `exodo` → `evangelhos` → `atos` → `cartas-paulo` → `apocalipse`

### Dificuldades (operações cognitivas)

| Id (código/banco) | Label na UI | Intenção |
|-------------------|-------------|----------|
| `semente` | Observação | Reconhecer / recordar / identificar |
| `caminhada` | Compreensão | Compreender / comparar |
| `profundezas` | Interpretação | Interpretar, conectar, sintetizar, transferir |

Não são “fácil / médio / difícil” em obscuridade — são **operações diferentes** sobre o mesmo conhecimento.  
Não confundir o id `caminhada` com a **Caminhada** litúrgica (Advento/Quaresma).

### Bíblia e Strong

- Traduções offline (TB, Almeida JFA)  
- Aba Bíblia: toque no versículo → **Estudar** (Strong, morfologia, concordância)  
- **Na cena:** toque na referência do palco (`Gn 1:27 · ESTUDAR`) → mesmo sheet, sem sair da sessão  
- Fonte: STEPBible / openbible.info (CC BY)  
- Strong serve interpretação contextual — não “significado secreto”

### Conteúdo e “pilotos”

Não há mais cena especial embutida. `gen-03-imagem` e o restante usam o mesmo pipeline (`content_bank_questions` + composer).

| Item | Status |
|------|--------|
| Banco tipado + skills | **8.370** atos V2 no Firestore (seed 24 ago); 6 gestos; palco TB; validador verde |
| Objective / insight / hooks nas cenas | Presentes no catálogo |
| Spec histórica Imagem de Deus | [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md) |
| Sermão do Monte e Êxodo | Packs congelados (`_sermao_v2_data` / `_exodo_v2_data`) + gerador verso-primeiro |

### UI / UX (resumo)

- **Visual:** tema escuro noturno, accent azul + CTA amarelo, painéis elevados, fundo imersivo / cinemático em Gênesis  
- **Padrão:** 5 tabs (Hoje · Trilhas · Bíblia · Juntos · Ajustes); mapa de trilha; picker de dificuldade  
- **Força:** sessão curta com gestos variados no mesmo shell  
- **Fraqueza vs. mercado:** polish/escala de marca; slogan “missão” já ocupado no BR (Bibliando); HUD de jogo ainda compete com o verso  

---

## Social

Ordem das abas em Juntos: **Companhia → Caravana → Grupos**. Desafio não é pane de ranking.

| Feature | O quê |
|---------|--------|
| **Companhia** | Par 1:1; convite QR / deep link `stway://companhia/CODIGO`; FCM de aceno |
| **Caravana** | Ranking Geral e Semana (tiers); promove/rebaixa; online hoje |
| **Grupos** | Grupo privado de estudo (código: `Room*`) |
| **Desafio** | Mesma cena com um par até domingo, +10 ao fechar — sob Companhia (código `Corner*`) |
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

**Veredito 20 set/2026 (noite):** o nicho “missões em PT-BR” tem **três** vozes (**Bibliando**, **Bíblia Fácil**, nós). Bible Way localiza de verdade (1.4.5, 10 idiomas). YouVersion ocupa o slot com *Plans with Friends*; Hallow, com oração + games na Home. O fosso STWAY continua sendo **treinar a leitura** (6 gestos · 3 modos · Strong · validador) + **par** (Companhia / Desafio) — não idioma, não slogan, não pet.

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
| **Bibliando** | Missões + trilhas PT-BR; leitura + contexto + descoberta; 1ª trilha grátis, resto IAP | Clone de *copy*. Sem 6 gestos, 3 modos, Strong, Caravana/Desafio. Diferenciar na sessão. |
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

### O que só STWAY junta (hoje, 1.0.29)

- Sessão 2–4 min com **6 gestos** + insight (não só MCQ)
- **3 profundidades** cognitivas (Observação / Compreensão / Interpretação)
- **Currículo** Criação → NT no Firebase + pedido de trilha no mapa
- **Strong offline** na cena (ref do palco) e na aba Bíblia; intro histórica do livro
- **CMS + validador pedagógico** — conteúdo vivo sem release
- **Social leve** — Companhia primeiro, Caravana, Grupos, Desafio (accountability, não feed de XP)

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
| **Cena** | Unidade curta na UI (~2–4 min, **6** atos · travessia **8**); código: `Mission` |
| Missão | Sinônimo de marketing/tester/código legado — preferir **cena** na UI |
| Exercício / ato | Ação tipada (`choice`, `order`, `connect`…) |
| Preparo / estudo | Texto + contexto + conexões (`MissionStudy`) |
| Passos | Moeda de progresso |
| Sequência | Dias seguidos (gelo + reparo) |
| Lâmpadas | Vidas na cena |
| Lamparina / jarro | Histórico semanal no perfil (não é vida) |
| Travessia | Boss / revisão de módulo na UI |
| Desafio | Peer: mesma cena até domingo (+10); código `Corner*` |
| Desafio da estação | Medalha/campanha litúrgica |
| Caravana | Liga (Geral / Semana) |
| Companhia | Par 1:1 |
| Grupo | Estudo em célula/EBD (código `Room*`) |
| Peregrino+ | Casca de assinatura — IAP inativo |
| Relato | Report de exercício → admin |
| Competência | Observar → … → Aplicar ([§9](LEARNING_ENGINE.md)) |
