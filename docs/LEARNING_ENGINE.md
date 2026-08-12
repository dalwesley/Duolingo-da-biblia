# STWAY — Learning & Biblical Formation Engine

## Especificação mestre para trilhas, currículo, treinos, exercícios e refatoração do fluxo

**Versão:** 2.0  
**Atualizado:** agosto/2026  
**Status:** Diretriz central do produto  

Docs relacionadas: [`PRODUTO.md`](PRODUTO.md) · [`TECNICA.md`](TECNICA.md) · piloto [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md) · contrato de sessão [`SESSAO_TREINO.md`](SESSAO_TREINO.md)

---

# 1. A tese educacional do STWAY

## STWAY é uma academia da Palavra.

O STWAY não existe para transformar a Bíblia em um jogo.

Também não existe para transformar uma aula de teologia em pequenas telas.

O objetivo é construir uma experiência diária que faça o usuário:

> **ler → pensar → compreender → conectar → lembrar → interpretar → aplicar**

ao longo de uma jornada progressiva.

A pessoa começa com conhecimento básico.

Mas, conforme avança, passa a desenvolver **competência para estudar a própria Bíblia**.

---

# 2. O problema que estamos resolvendo

Grande parte dos cristãos possui:

* familiaridade com histórias bíblicas;
* reconhecimento de personagens;
* conhecimento de versículos conhecidos;
* exposição repetida a sermões;
* memória de conceitos ensinados na igreja.

Mas isso não significa necessariamente:

* compreensão do contexto;
* capacidade de interpretar um texto;
* percepção da estrutura literária;
* compreensão do argumento de um livro;
* capacidade de conectar textos;
* compreensão da progressão da revelação bíblica;
* capacidade de estudar uma passagem sozinho.

Portanto:

> **Conhecer histórias não é o mesmo que saber ler a Bíblia.**

O STWAY deve atacar exatamente essa diferença.

---

# 3. O que aprendemos com a formação teológica formal

Os melhores currículos analisados não ensinam "Bíblia" como uma única disciplina.

Eles constroem uma rede de conhecimentos.

O aluno estuda:

```text
Bíblia
+
História
+
Contexto
+
Línguas
+
Hermeneutica
+
Teologia
+
História da Igreja
+
Prática
```

Esses elementos se reforçam mutuamente.

Yale, por exemplo, estrutura sua formação em Biblical Studies, Theological Studies, Historical Studies, Practical Theology e Comparative/Cultural Studies.

RTS distribui seu MDiv entre línguas, Antigo e Novo Testamento, hermenêutica, teologia histórica e sistemática, pregação, aconselhamento, liderança e missões.

Westminster enfatiza explicitamente um currículo "cumulativamente sequencial e completamente integrado", no qual as disciplinas informam umas às outras.

O STWAY deve adaptar esse princípio para um produto de poucos minutos por dia.

---

# 4. Não transformar o STWAY em um seminário

O STWAY NÃO deve tentar reproduzir:

* 3 anos de MDiv;
* centenas de horas de aula;
* leitura acadêmica pesada;
* domínio completo de hebraico e grego;
* trabalhos acadêmicos extensos.

Isso destruiria a proposta de hábito.

A adaptação correta é:

> **Seminário = profundidade através de intensidade e duração.**
>
> **STWAY = profundidade através de progressão, recorrência e integração.**

O STWAY deve distribuir a profundidade pelo tempo.

---

# 5. O princípio da profundidade acumulativa

Uma missão não precisa ser profunda.

Uma **jornada** precisa ser.

Exemplo:

### Hoje

> Quem criou?

### Amanhã

> Como Gênesis estrutura a criação?

### Depois

> O que significa imagem de Deus?

### Depois

> Como essa ideia aparece em outros textos?

### Muito mais tarde

> Como a Bíblia desenvolve a antropologia bíblica?

O usuário não percebe que está construindo uma estrutura teológica.

Mas está.

---

# 6. A arquitetura do conhecimento

O currículo deve ser construído em camadas.

```text
FATO
↓
CONCEITO
↓
TEXTO
↓
CONTEXTO
↓
INTERPRETAÇÃO
↓
CONEXÃO
↓
TEOLOGIA
↓
TRANSFERÊNCIA
↓
APLICAÇÃO
```

Não significa que toda missão terá todas essas etapas.

Significa que **o currículo completo deve passar por elas**.

---

# 7. A unidade correta de design

A hierarquia do produto será:

```text
JORNADA
    ↓
TRILHA
    ↓
CENA
    ↓
TREINO
    ↓
EXERCÍCIO
```

---

## Jornada

A grande progressão bíblica.

Exemplo:

> Criação → Queda → Promessa → Êxodo → Reino → Exílio → Cristo → Igreja → Nova Criação

---

## Trilha

Uma área organizada de aprendizagem.

Exemplos:

* Antigo Testamento
* Novo Testamento
* Vida Cristã
* Teologia

Mas também poderão existir trilhas transversais:

* Personagens
* Contexto histórico
* Como ler a Bíblia
* Grandes temas
* Confissões
* História da Igreja

Essas trilhas não devem necessariamente competir com a jornada principal.

Podem funcionar como **camadas de formação que se cruzam com ela**.

---

## Cena

Um grande acontecimento ou unidade.

Exemplo:

> A Criação

---

## Treino

Uma pequena competência ou conceito.

Exemplo:

> Imagem de Deus

---

## Exercício

A ação concreta realizada pelo usuário.

### Glossário de transição (app atual → motor v2)

| Termo legado (UX / código) | Termo pedagógico (v2) | Nota |
|----------------------------|------------------------|------|
| Missão / Passo (`Mission`) | **Treino** | Mesmo `slug` de progresso; “missão” pode permanecer no copy curto |
| Pergunta (`Question` / bank) | **Exercício** | Tipado (`choice`, `order`, `connect`…) |
| Preparo (`MissionStudy`) | Contexto + texto + conexões do treino | Pode fundir no documento do treino |
| Boss | Treino de revisão / interleaving | Mesmos componentes, skills misturadas |

---

# 8. O currículo não deve ser apenas cronológico

A jornada principal pode seguir uma ordem narrativa/canônica.

Mas o conhecimento precisa ser revisitado de outras perspectivas.

Portanto:

> **A estrutura do currículo pode ser linear.**
>
> **A estrutura do conhecimento deve ser em rede.**

Exemplo:

```text
Gênesis 1
   ↓
Imagem de Deus
   ↓
Colossenses 1
   ↓
Cristologia
   ↓
Nova Criação
   ↓
Apocalipse 21
```

O usuário avança.

Mas o conhecimento também se conecta para trás.

---

# 9. As competências bíblicas

O STWAY deve desenvolver progressivamente as seguintes competências.

## Nível 1 — Observar

O que o texto realmente diz?

Treinar:

* personagens;
* ações;
* palavras;
* repetições;
* contrastes;
* estrutura;
* sequência;
* informações explícitas.

---

## Nível 2 — Compreender

O que o texto está comunicando?

Treinar:

* ideia principal;
* significado;
* causa;
* consequência;
* intenção;
* relações entre afirmações.

---

## Nível 3 — Contextualizar

O que está acontecendo ao redor do texto?

Treinar:

* autor;
* destinatários;
* época;
* localização;
* cultura;
* situação histórica;
* gênero literário;
* contexto imediato.

---

## Nível 4 — Interpretar

O que o texto significa?

Treinar:

* distinção entre observação e interpretação;
* comparação de interpretações;
* evidência textual;
* contexto;
* coerência;
* intenção do autor.

---

## Nível 5 — Conectar

Como essa passagem se relaciona com o restante da Bíblia?

Treinar:

* temas;
* promessas;
* cumprimento;
* tipologia quando apropriada;
* citações;
* alusões;
* paralelos;
* desenvolvimento da revelação.

---

## Nível 6 — Sintetizar

Como várias informações formam uma ideia maior?

Exemplo:

> O que Gênesis 1–3 ensina sobre criação, humanidade, pecado e propósito?

Aqui o usuário deixa de responder perguntas isoladas e começa a construir uma visão bíblica.

---

## Nível 7 — Teologizar

O que a Bíblia ensina sistematicamente sobre esse assunto?

Exemplo:

```text
Gênesis
+
Salmos
+
Profetas
+
Evangelhos
+
Cartas
```

↓

> O que a Escritura ensina sobre o ser humano?

Esse nível deve aparecer progressivamente.

---

## Nível 8 — Aplicar

Como essa verdade deve moldar a vida?

Aplicação sempre deve ser consequência da compreensão.

Não utilizar aplicação moralista automática.

---

# 10. A progressão cognitiva

A dificuldade deve crescer assim:

```text
RECONHECER
↓
RECORDAR
↓
IDENTIFICAR
↓
COMPREENDER
↓
COMPARAR
↓
INTERPRETAR
↓
CONECTAR
↓
SINTETIZAR
↓
APLICAR
↓
TRANSFERIR
```

O usuário não deve permanecer eternamente em múltipla escolha.

Mas também não deve começar com interpretação complexa.

---

# 11. O motor de exercícios

O STWAY deve ter um conjunto pequeno de componentes reutilizáveis.

## Exercícios fundamentais

### 1. Escolha (`choice`)

Selecionar uma resposta.

---

### 2. Verdadeiro/Falso (`true_false`)

Avaliar uma afirmação.

---

### 3. Ordene (`order`)

Organizar eventos, ideias ou argumentos.

---

### 4. Associe (`match`)

Relacionar conceitos.

---

### 5. Complete (`complete`)

Recuperar uma informação.

---

### 6. Encontre no texto (`find_in_text`)

Localizar evidências.

---

### 7. Qual afirmação é sustentada pelo texto? (`text_supported`)

Treina interpretação baseada em evidência.

---

### 8. Encontre a conexão (`connect`)

Relacionar duas passagens.

---

### 9. Qual interpretação é melhor? (`best_interpretation`)

Comparar interpretações plausíveis.

---

### 10. Explique (`explain`)

Quando apropriado, o usuário formula uma resposta curta.

---

### 11. Classifique (`classify`)

Organizar informações por categorias.

---

### 12. Revisão (`review`)

Recuperar conteúdos anteriores.

---

# 12. Não criar experiências artesanais

Esta é uma regra técnica e editorial fundamental.

Se uma ideia puder ser representada por um componente existente:

> **usar o componente existente.**

Não criar:

* uma animação exclusiva;
* uma mecânica exclusiva;
* uma tela exclusiva;
* um fluxo exclusivo.

apenas porque determinada passagem é interessante.

Um novo componente só deve ser criado quando representar uma **necessidade pedagógica recorrente**.

---

# 13. O treino

Um treino normalmente deve ter:

**3–8 exercícios.**

Duração aproximada:

**2–4 minutos.**

Mas o número não é absoluto.

O princípio é:

> pequeno o suficiente para terminar;
>
> grande o suficiente para produzir aprendizagem.

---

## 13.1 Padrão de um treino Rota (arc indutivo)

Todo treino Rota deve seguir, em ordem, este arco — sem spoiler de aula antes:

```text
HIPÓTESE  →  OBSERVE  →  OBSERVE+  →  INTERPRETE  →  CONECTE  →  VIVA
(ativar)     (fato)      (fato 2)     (freio)        (rede)      (aplicar)
```

| Beat | Função | Boas práticas |
|------|--------|----------------|
| **Hipótese** | Ativar erro comum *antes* do texto | V/F ou escolha curta; sem passagem ainda |
| **Observe** | O que o texto diz | Texto na tela; pergunta objetiva; opções distintas (não trechos quase iguais) |
| **Observe+** | Segundo fato do mesmo texto | Evita repetir a mesma pergunta com outras palavras |
| **Interprete** | O que o texto sustenta / não sustenta | Opções **curtas**; texto visível; separar Escritura × tradição |
| **Conecte** | Eco em outra passagem | Linguagem simples — sem jargão (“tipologia”, “temática”) |
| **Viva** | Aplicação ligada ao insight | Sobre a vida / o próximo — **não** “o que este treino quer” |

Regras duras:

1. **Não explicar antes de observar** — preparo longo com glossário *antes* do motor v2 estraga a descoberta.
2. **Sem redundância** — se e02 e e03 medem a mesma coisa, corte um.
3. **Opções legíveis no celular** — uma linha quando possível; no máximo duas.
4. **Feedback = correção + motivo** — e o último acerto pode nomear o `centralInsight`.
5. **Show, don’t tell** (Duolingo / microlearning) — o usuário *faz*; a regra emerge do exercício.

Referência de pesquisa: método indutivo (observar → interpretar → aplicar); spaced retrieval e desirable difficulty; lições curtas com um objetivo ([Duolingo Method](https://duolingo-papers.s3.amazonaws.com/reports/Duolingo_whitepaper_duolingo_method_2023.pdf)).

Piloto: [`pilots/gen-03-imagem.md`](pilots/gen-03-imagem.md).

---

# 14. O treino não é uma mini-aula

Evitar:

```text
Texto longo
↓
Explicação longa
↓
Quiz
```

Preferir:

```text
Tentativa
↓
Texto
↓
Pensamento
↓
Feedback
↓
Nova tentativa
```

O usuário deve participar da construção do conhecimento.

---

# 15. O papel da explicação

Explicação existe para corrigir ou ampliar o modelo mental do usuário.

Não para preencher espaço.

Toda explicação deve responder:

> "O que eu precisava entender para responder corretamente?"

Quanto menor e mais precisa, melhor.

---

# 16. Erros são parte do treinamento

Erro não deve gerar apenas:

> ❌ Errado.

Deve gerar:

> **correção + motivo + nova oportunidade.**

Exemplo:

> Quase. O texto não afirma que todos os seres vivos foram feitos à imagem de Deus. Observe quem recebe explicitamente essa descrição em Gênesis 1:26–27.

Depois:

> Tente novamente.

O erro vira aprendizagem.

---

# 17. O usuário deve descobrir algumas respostas

Sempre que pedagogicamente possível:

```text
Pergunta
↓
Tentativa
↓
Texto
↓
Observação
↓
Conclusão
```

Em vez de:

```text
Explicação
↓
Pergunta
```

Mas isso não deve virar regra rígida.

Alguns conceitos precisam ser ensinados diretamente.

---

# 18. O conteúdo deve trabalhar em espiral

Uma competência ou conceito importante deve reaparecer.

Exemplo:

### Gênesis

> Imagem de Deus.

### Salmos

> O que significa ser humano diante de Deus?

### Profetas

> O que acontece quando a imagem de Deus é corrompida pelo pecado?

### Evangelhos

> Jesus como imagem perfeita.

### Cartas

> Cristo como imagem de Deus.

### Nova criação

> O que acontece com a humanidade no fim da história?

O usuário não apenas "termina Gênesis".

Ele constrói uma compreensão progressiva.

---

# 19. Revisão não é repetição idêntica

Evitar:

> mesma pergunta;
>
> mesma alternativa;
>
> mesma resposta.

Revisão deve mudar o contexto.

Primeiro:

> Quem foi criado à imagem de Deus?

Depois:

> Qual afirmação melhor explica o conceito?

Depois:

> Onde essa ideia reaparece?

Depois:

> Qual texto ajuda a entender Cristo em relação a essa ideia?

Isso mede **transferência**, não reconhecimento.

---

# 20. Interleaving

Misturar conhecimentos antigos e novos.

Exemplo:

Durante uma trilha sobre Abraão:

> Qual promessa apareceu anteriormente em Gênesis?

O usuário recupera algo aprendido semanas atrás.

Isso cria uma rede.

---

# 21. Conexões bíblicas

Conexões não devem existir apenas para produzir "uau".

Devem ter fundamento textual.

Tipos de conexão:

### Explícita

Um autor cita outro texto.

### Temática

Dois textos desenvolvem o mesmo tema.

### Narrativa

Um acontecimento prepara outro.

### Promessa e cumprimento

Uma promessa encontra desenvolvimento posterior.

### Tipológica

Quando há fundamento hermenêutico adequado.

### Contraste

Uma realidade é apresentada em contraste com outra.

---

# 22. Contexto não deve ser um "extra"

Contexto deve entrar quando muda a interpretação.

Exemplo:

> "Por que Paulo escreveu isso?"

é mais importante do que decorar a data da carta.

O STWAY deve priorizar:

> **contexto que altera compreensão.**

---

# 23. Línguas bíblicas

O estudo de Strong, hebraico e grego não deve existir apenas como curiosidade.

Ele deve ensinar o usuário a perceber:

* significado lexical;
* forma;
* morfologia;
* uso contextual;
* diferenças de tradução;
* relação entre palavras.

Progressão:

```text
Palavra
↓
Significado básico
↓
Forma
↓
Contexto
↓
Uso em outros textos
↓
Implicação interpretativa
```

Não transformar Strong em:

> "Descubra o significado secreto da palavra."

Evitar falácias lexicais.

---

# 24. Teologia sistemática

A teologia não deve ser apresentada apenas como uma trilha de definições.

O usuário deve chegar à teologia **a partir da Escritura**.

Exemplo:

```text
Gênesis
↓
Salmos
↓
Profetas
↓
Evangelhos
↓
Cartas
↓
Síntese
```

Então:

> O que a Bíblia ensina sobre Deus?

A teologia aparece como **síntese do conhecimento bíblico**, não como lista desconectada.

---

# 25. História da Igreja

Também deve funcionar como uma rede.

Exemplo:

```text
Texto bíblico
↓
Questão doutrinária
↓
Controvérsia
↓
Resposta da Igreja
↓
Credo/confissão
↓
Aplicação histórica
```

Assim o usuário entende por que determinada doutrina foi formulada.

Não apenas:

> "Memorize esta definição."

---

# 26. Confissões e tradições

Quando o conteúdo for denominacional ou confessional:

* identificar explicitamente a tradição;
* distinguir texto bíblico de formulação confessional;
* mostrar a relação entre Escritura e confissão;
* apresentar o conteúdo com precisão.

Exemplo:

> O que Westminster afirma?

não deve ser confundido com:

> O que Gênesis afirma?

O STWAY deve deixar clara a diferença entre:

**Escritura → interpretação → tradição/confissão.**

---

# 27. Profundidade progressiva

O usuário pode encontrar o mesmo tema em diferentes níveis.

### Semente

> Reconhecer.

### Rota

> Compreender.

### Profundezas

> Interpretar, conectar e sintetizar.

Mas esses níveis não devem ser apenas "fácil / médio / difícil".

Eles representam:

> **diferentes operações cognitivas sobre o mesmo conhecimento.**

---

# 28. O verdadeiro significado de "Profundezas"

Profundidade não é:

* texto maior;
* palavra mais difícil;
* pergunta mais obscura;
* curiosidade acadêmica.

Profundidade é:

> **mais relações + melhor evidência + maior capacidade de transferência.**

---

# 29. Como uma trilha deve ser construída

Antes de escrever qualquer pergunta, o editor deve construir um **mapa de conhecimento**.

Exemplo:

## Gênesis — Criação

### Conhecimentos

* Deus é apresentado como Criador.
* A criação possui estrutura.
* Homem e mulher são criados à imagem de Deus.
* Deus descansa.
* A criação estabelece categorias importantes para a narrativa bíblica.

### Contextos

* estrutura literária;
* contexto do Antigo Oriente quando relevante;
* significado de "imagem";
* conceito de descanso.

### Conexões

* João 1;
* Colossenses 1;
* Hebreus 4;
* outros textos relevantes.

### Teologia

* Deus Criador;
* antropologia;
* criação;
* providência;
* descanso.

### Competências

* observar;
* compreender;
* conectar;
* interpretar.

Só depois começam os exercícios.

---

# 30. Regra: conhecimento antes de perguntas

Não começar:

> "Que pergunta podemos fazer?"

Começar:

> "O que queremos que o usuário consiga compreender ou fazer?"

Depois criar a pergunta.

---

# 31. Cada treino deve ter um objetivo observável

Evitar:

> "Aprender sobre criação."

Preferir:

> "Identificar a estrutura básica apresentada em Gênesis 1."

ou:

> "Distinguir o que Gênesis 1 afirma sobre imagem de Deus de interpretações não sustentadas pelo texto."

---

# 32. Cada pergunta precisa ter função

Uma pergunta deve cumprir pelo menos uma destas funções:

* ativar conhecimento;
* observar;
* recuperar;
* distinguir;
* interpretar;
* conectar;
* sintetizar;
* revisar;
* transferir.

Se não tiver função clara:

> remover.

---

# 33. Distratores

Alternativas erradas devem representar erros reais.

Exemplo ruim:

> Quem criou o mundo?

A) Deus
B) Batman
C) Napoleão
D) Um cachorro

Isso mede reconhecimento da alternativa óbvia.

Melhor:

> Qual afirmação corresponde ao início de Gênesis?

A) Deus passa a existir no início da criação.
B) Deus é apresentado como Criador desde o início.
C) O universo cria a si mesmo.
D) A criação acontece antes da existência de Deus.

Agora o usuário precisa compreender.

---

# 34. Não premiar apenas velocidade

Velocidade pode fazer parte da experiência.

Mas não deve substituir aprendizagem.

O sistema deve priorizar:

```text
compreensão
+
recuperação
+
retenção
+
progressão
```

e não simplesmente:

```text
responder rápido
```

---

# 35. Gamificação

A gamificação deve reforçar aprendizagem.

### Passos

Representam progresso.

### Lâmpadas

Representam oportunidade de continuar treinando.

### Streak

Representa consistência.

### Quests

Representam objetivos de prática.

### Caravana

Representa continuidade social.

Nenhum elemento deve recompensar o usuário por simplesmente clicar.

---

# 36. Métrica principal de uma missão

Não é:

> taxa de acerto.

É:

> **aprendizagem + retenção + retorno.**

Uma missão é boa quando:

1. o usuário conclui;
2. compreende;
3. lembra depois;
4. reconhece em outro contexto;
5. continua a jornada.

---

# 37. Métrica de competência

O STWAY deve eventualmente conseguir estimar:

```text
Observação       ███████░░░
Compreensão      ██████░░░░
Contexto         ████░░░░░░
Interpretação    ████░░░░░░
Conexão          ███░░░░░░░
Síntese          ██░░░░░░░░
Aplicação        ████░░░░░░
```

Não necessariamente mostrar esses números ao usuário.

Eles podem existir internamente para personalização.

---

# 38. Personalização

O sistema deve descobrir:

> Onde este usuário está?

e não simplesmente:

> Qual trilha ele quer abrir?

Exemplo:

Usuário conhece muito bem histórias bíblicas, mas tem dificuldade em:

* contexto;
* interpretação;
* conexões.

O STWAY deve aumentar exercícios nessas competências.

---

# 39. Conteúdo adaptativo

Dois usuários podem percorrer a mesma trilha.

Mas receber diferentes exercícios.

```text
MESMO CONTEÚDO
       ↓
    MOTOR
       ↓
┌──────────────┐
│ Usuário A    │
│ precisa      │
│ de revisão   │
└──────────────┘

┌──────────────┐
│ Usuário B    │
│ precisa de   │
│ profundidade │
└──────────────┘
```

A jornada permanece coerente.

A prática se adapta.

---

# 40. O papel da IA

IA pode ajudar a:

* gerar rascunhos de perguntas;
* criar distratores;
* identificar possíveis conexões;
* sugerir revisões;
* classificar perguntas por competência;
* detectar repetição;
* identificar lacunas curriculares;
* adaptar dificuldade.

IA NÃO deve decidir sozinha:

* doutrina;
* interpretação controversa;
* conexões teológicas sensíveis;
* significado original;
* afirmações acadêmicas importantes.

Conteúdo teológico deve ter revisão humana.

---

# 41. Schema mínimo de um treino

```yaml
training:
  id:
  title:

  objective:
  core_knowledge:

  primary_skill:
  secondary_skills:

  biblical_references:

  central_insight:

  context:
    required: false
    content:

  connections:
    - reference:
      type:
      explanation:

  theology:
    concepts:

  exercises:
    - type:
      prompt:
      reference:
      options:
      correct_answer:
      feedback:
      skill:

  review:
    concepts:
    future_targets:

  difficulty:
  depth_level:
```

Detalhe técnico Firestore / app: [`TECNICA.md` § Learning Engine](TECNICA.md#learning-engine-v2--schema-e-migração).

---

# 42. Pipeline editorial

Toda nova trilha deve seguir:

```text
1. MAPA BÍBLICO
       ↓
2. MAPA DE CONHECIMENTO
       ↓
3. COMPETÊNCIAS
       ↓
4. CONTEXTO
       ↓
5. CONEXÕES
       ↓
6. SÍNTESE TEOLÓGICA
       ↓
7. TREINOS
       ↓
8. EXERCÍCIOS
       ↓
9. REVISÕES
       ↓
10. VALIDAÇÃO
       ↓
11. PUBLICAÇÃO
```

---

# 43. Checklist editorial

Antes de publicar uma trilha:

### Bíblia

* [ ] O conteúdo está fiel ao texto?
* [ ] Referências foram verificadas?
* [ ] Contexto foi respeitado?
* [ ] Interpretações foram diferenciadas de fatos textuais?

### Pedagogia

* [ ] O objetivo é observável?
* [ ] A competência está definida?
* [ ] O usuário precisa pensar?
* [ ] Existe recuperação?
* [ ] Existe feedback?
* [ ] Existe revisão?
* [ ] Existe transferência?

### Currículo

* [ ] Isso se conecta ao que veio antes?
* [ ] Prepara algo que virá depois?
* [ ] Evita lacunas importantes?
* [ ] Reaproveita conhecimentos anteriores?
* [ ] Contribui para a visão do todo?

### Experiência

* [ ] Pode ser concluído em poucos minutos?
* [ ] A interação é variada?
* [ ] Não depende de uma UI exclusiva?
* [ ] O usuário percebe progresso?

### Profundidade

* [ ] Existe diferença entre memorizar e compreender?
* [ ] Existe diferença entre observar e interpretar?
* [ ] Existe oportunidade de conectar?
* [ ] Existe oportunidade de transferir para outro texto?

---

# 44. Critério definitivo de uma boa trilha

Não perguntar apenas:

> "O usuário terminou?"

Perguntar:

### Depois de terminar...

**Ele sabe mais?**

**Ele compreende melhor?**

**Ele consegue explicar?**

**Ele consegue lembrar?**

**Ele consegue encontrar isso novamente na Bíblia?**

**Ele consegue conectar com algo aprendido anteriormente?**

**Ele consegue usar essa habilidade em outro texto?**

Se a resposta for sim:

> **o usuário está sendo formado.**

---

# 45. O princípio mais importante

O STWAY não deve tentar dar ao usuário:

> **uma faculdade de teologia em três minutos por dia.**

Isso seria impossível.

O objetivo é muito mais interessante:

> **dar ao usuário três minutos por dia durante meses e anos, e fazer esses três minutos construírem uma estrutura de conhecimento que normalmente exigiria anos de estudo estruturado.**

É isso que significa:

# Academia da Palavra.

Não uma aula por dia.

**Treino contínuo.**

---

# 46. Regra final para qualquer nova feature

Antes de criar qualquer funcionalidade, perguntar:

> **Isso torna o usuário melhor em ler, compreender, conectar, interpretar, lembrar ou viver a Palavra?**

Se não:

> **não é prioridade do STWAY.**

---

# 47. Prompt mestre de criação de conteúdo

Use esta instrução como base para qualquer IA responsável por criar conteúdo STWAY:

> Você é um designer instrucional bíblico responsável pelo currículo do STWAY, uma academia da Palavra.
>
> O objetivo não é criar quizzes divertidos nem resumir conteúdo bíblico.
>
> O objetivo é desenvolver progressivamente a capacidade do usuário de observar, compreender, contextualizar, interpretar, conectar, sintetizar, memorizar e aplicar as Escrituras.
>
> Ao criar qualquer trilha, cena, treino ou exercício:
>
> 1. Comece pelo texto bíblico e pelo objetivo de aprendizagem.
> 2. Identifique o conhecimento essencial.
> 3. Identifique a competência bíblica que será treinada.
> 4. Identifique conhecimentos prévios necessários.
> 5. Identifique contexto relevante.
> 6. Identifique conexões com outras partes da Escritura.
> 7. Identifique como esse conhecimento contribui para uma compreensão teológica maior.
> 8. Crie exercícios utilizando componentes existentes do STWAY.
> 9. Faça o usuário recuperar, observar, comparar ou interpretar antes de entregar explicações sempre que pedagogicamente apropriado.
> 10. Crie feedback que explique o raciocínio.
> 11. Crie oportunidades de revisão futura.
> 12. Inclua transferência para outros contextos quando apropriado.
> 13. Aumente a complexidade ao longo do currículo, não necessariamente dentro de uma única missão.
> 14. Não transforme toda missão em uma aula.
> 15. Não crie perguntas apenas para preencher quantidade.
> 16. Não crie "insights" artificiais para surpreender.
> 17. Não trate curiosidades como doutrina.
> 18. Diferencie claramente texto bíblico, interpretação, contexto histórico, tradição teológica e aplicação.
> 19. Respeite o contexto literário e histórico.
> 20. Evite falácias de palavra, especialmente em estudos de hebraico/grego.
> 21. Crie distratores plausíveis baseados em erros reais.
> 22. Reutilize conceitos anteriores para criar uma rede de conhecimento.
> 23. Não crie interfaces especiais quando um exercício existente puder representar a ideia.
> 24. A sessão deve ser curta, mas o currículo deve ser profundo.
>
> A pergunta central não é:
>
> **"O usuário aprendeu esta informação?"**
>
> É:
>
> **"O usuário está se tornando melhor em ler e compreender a Bíblia?"**
>
> Produza conteúdo que permita responder "sim".
