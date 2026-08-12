# STWAY — Documentação de produto

**Atualizado:** ago/2026  
**Versão do app:** 1.0.19  
**Norte completo:** [`ROADMAP.md`](../ROADMAP.md)  
**Motor de formação (diretriz):** [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md)

---

## Em uma frase

STWAY é a **academia da Palavra**: treino diário em português que desenvolve competência para ler, compreender, conectar e interpretar as Escrituras — em poucos minutos por dia, ao longo de uma jornada.

**Frase competitiva:** *“Enquanto outros te fazem jogar a Bíblia, o STWAY te treina nela.”*

Não somos YouVersion (só ler), Hallow (orar), Ascend/Bible Way (jogo com pet/heróis sem escola), nem trivia vazia.  
**Sensação:** Duolingo no loop · formação bíblica no conteúdo.

---

## Para quem

Cristãos de língua portuguesa que querem:

- Formar **hábito** de estudo bíblico (streak, treinos curtos ~2–4 min)
- **Aprender de verdade** (exercícios com feedback, competências, Strong/morfologia)
- Caminhar um **currículo** coerente (Criação → NT), em rede — não só versículos soltos
- Ter **accountability** leve (Companhia, Salas, Caravana semanal)

---

## Proposta de valor

| O que entrega | Como |
|---------------|------|
| Formação progressiva | Jornada → trilhas → cenas → **treinos** → exercícios tipados |
| Hábito diário | Treino do dia, quests, streak, lembretes locais |
| Profundidade | 3 níveis cognitivos (Semente / Rota / Profundezas) + Strong offline |
| Social leve | Caravana (liga semanal), Companhia 1:1, Salas de estudo |
| Conteúdo vivo | CMS admin no Firebase — atualiza sem release na loja |

Regra de feature ([§46](LEARNING_ENGINE.md)): *isso torna o usuário melhor em ler, compreender, conectar, interpretar, lembrar ou viver a Palavra?*

---

## Experiência do usuário

### Abas principais

1. **Hoje** — Próximo treino dominante, quests, streak, entrada para prática/memória  
2. **Trilhas** — Catálogo por reino (AT / NT / Vida Cristã / Teologia)  
3. **Bíblia** — Leitor offline + estudo Strong ao tocar no versículo  
4. **Juntos** — Caravana, Companhia, Salas  
5. **Config** — Som, notificações, export/import, logout  

### Fluxo principal

```
Splash → Login (Google) → Onboarding (1ª vez)
  → Hoje: continuar treino
  → Mapa da trilha → Dificuldade → Treino → Celebração
  → (opcional) Bíblia / Prática / Memória / Juntos
```

Onboarding em 4 beats: promessa → por quê → ritmo → primeira trilha (Gênesis 1–11).

### Loop de treino

1. Usuário entra no treino (legado UX ainda pode dizer “missão”)  
2. Tenta / observa o texto / recebe feedback — não “aula longa → quiz”  
3. 3–8 exercícios tipados (lâmpadas = vidas)  
4. Erro com correção + motivo + nova chance; acerto gera **passos**  
5. Celebração + progresso na nuvem  
6. Bosses = revisão / interleaving do módulo  

Detalhe pedagógico: [`LEARNING_ENGINE.md`](LEARNING_ENGINE.md).

### Moeda / retenção

- **Passos** — unidade de progresso (legado interno ainda usa `xp` em alguns campos)  
- **Lâmpadas** — vidas no treino  
- **Streak** — sequência diária (com freeze/repair)  
- **Quests** diárias e semanais (+ sazonais litúrgicas)  
- **Caravana** — liga semanal por tier (Semente → Videira → Oliveira → Cedro → Estrela)  

Gamificação reforça aprendizagem — não recompensa clique vazio.

---

## Conteúdo

### Hierarquia (v2)

```text
JORNADA → TRILHA → CENA → TREINO → EXERCÍCIO
```

| Camada | Exemplo |
|--------|---------|
| Jornada | Criação → Queda → … → Nova Criação |
| Trilha | Gênesis 1–11 (ou transversais: Como ler a Bíblia) |
| Cena | A Criação |
| Treino | Imagem de Deus |
| Exercício | escolha, ordene, conexão, evidência… |

Copy curto no app pode manter “missão” = container do treino. Ver glossário abaixo.

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
- Toque no versículo → **Estudar**: Strong, morfologia, concordância, referências cruzadas  
- Fonte: STEPBible / openbible.info (CC BY)  
- Strong serve interpretação contextual — não “significado secreto”

### Pilotos

| Piloto | Status |
|--------|--------|
| **Imagem de Deus** (`gen-03-imagem`) — motor v2 | Spec em [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md) |
| Sermão do Monte | 6 cenas / 31 missões (legado); migrar após validar piloto |

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
Direção e hipóteses: [`MONETIZATION.md`](../MONETIZATION.md).

---

## Critérios de sucesso (produto)

Antes de “crescer” de verdade (ver Roadmap):

1. Retenção D7 ok no loop de treino  
2. Um caminho Criação → NT terminável, validado com tester  
3. Usuário explica o app numa frase alinhada ao norte (*“app pra treinar a ler a Bíblia”*)  
4. Após um treino: lembra, explica e reconhece o conceito em outro texto (transferência)

Regra de feature: *aumenta conclusão de treino, retenção ou retorno em 7 dias — sem sacrificar aprendizagem?*

---

## Papéis no ecossistema

| Superfície | Quem | Função |
|------------|------|--------|
| App Flutter (`trilha_app`) | Aprendiz | Treino diário |
| Admin (`admin`) | Editor / admin | Publicar currículo, banco, estudos, moderar relatos, release remoto |

Pipeline editorial: [`LEARNING_ENGINE.md` §42–43](LEARNING_ENGINE.md).

---

## Posicionamento vs. concorrentes

| Tipo | Exemplos | STWAY |
|------|----------|--------|
| Leitura / plano | YouVersion | Treino + currículo + competências, não só ler |
| Oração / áudio | Hallow | Foco em formação cognitiva da Palavra |
| Game bíblico | Ascend / pets | Escola no conteúdo; social leve sem pet |
| Trivia | Quizzes soltos | Rede de conhecimento + 3 profundidades + Strong |

---

## Glossário rápido

| Termo | Significado |
|-------|-------------|
| Treino | Unidade pedagógica (~2–4 min, 3–8 exercícios); no código/legado: `Mission` / “missão” |
| Exercício | Ação tipada (`choice`, `order`, `connect`…) |
| Cena | Módulo dentro da trilha |
| Preparo / estudo | Texto + contexto + conexões do treino (legado: `MissionStudy`) |
| Passos (moeda) | Progresso ganho nos treinos |
| Lâmpadas | Vidas no treino |
| Caravana | Liga semanal |
| Companhia | Par 1:1 |
| Relato | Report de exercício pelo usuário → fila no admin |
| Competência | Observar → … → Aplicar ([§9](LEARNING_ENGINE.md)) |
