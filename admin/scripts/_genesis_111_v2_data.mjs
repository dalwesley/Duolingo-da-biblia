/**
 * Banco editorial V2 — Gênesis 1–11 (STWAY).
 * Semente = observar | Rota = compreender | Profundezas = interpretar/conectar
 *
 * Nota: o seed Firebase atual ainda usa IDs `genesis--sem-…` (typo histórico).
 * Novas gerações usam `genesis-1-11-sem-…`. Não renomear em massa sem reseeding.
 */

const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };

function q(section, diff, n, fields) {
  const {
    question,
    options,
    correct,
    ok,
    wrong,
    verseRef,
    skill,
    type = 'choice',
    learningObjective,
    evidence,
    passageText,
    template,
  } = fields;
  return {
    id: `genesis-1-11-${SHORT[diff]}-${section}-${String(n).padStart(2, '0')}`,
    trail: 'genesis-1-11',
    difficulty: diff,
    section,
    type,
    skill,
    question,
    prompt: question,
    cue: question,
    options: options.map(([id, text]) => ({ id, text })),
    correctOptionId: correct,
    correctAnswer: correct,
    feedbackCorrect: ok,
    feedbackWrong: wrong,
    verseRef,
    learningObjective,
    evidence: evidence || [verseRef],
    ...(passageText ? { passageText } : {}),
    ...(template ? { template } : {}),
  };
}

function pack(section, levels) {
  const skillMap = { semente: 'observe', caminhada: 'understand' };
  const out = [];
  for (const [diff, items] of Object.entries(levels)) {
    items.forEach((fields, i) => {
      const skill =
        fields.skill ||
        skillMap[diff] ||
        (i % 2 === 0 ? 'interpret' : 'connect');
      out.push(q(section, diff, i + 1, { ...fields, skill }));
    });
  }
  return out;
}

export function genesis111V2Packs() {
  return [
    ...pack('gen-01-criador', {
      semente: [
        {
          question: 'O que Deus criou no princípio, segundo Gênesis 1:1?',
          options: [
            ['a', 'Os céus e a terra'],
            ['b', 'O jardim do Éden'],
            ['c', 'O homem e a mulher'],
            ['d', 'A luz e as trevas'],
          ],
          correct: 'a',
          ok: 'Correto. O texto abre com a criação do cosmos inteiro.',
          wrong: {
            b: 'O Éden aparece no capítulo 2.',
            c: 'Humanos são criados depois.',
            d: 'Luz e trevas vêm no terceiro versículo.',
          },
          verseRef: 'Gênesis 1:1',
          learningObjective: 'Identificar o objeto da criação inicial.',
          passageText: 'No princípio, criou Deus os céus e a terra.',
        },
        {
          question: 'Como a terra é descrita em Gênesis 1:2, antes das ordens criadoras?',
          options: [
            ['a', 'Sem forma e vazia'],
            ['b', 'Cheia de vida e frutífera'],
            ['c', 'Dividida em mares e continentes'],
            ['d', 'Pronta para receber o homem'],
          ],
          correct: 'a',
          ok: 'Exato. A terra ainda aguarda a palavra ordenadora de Deus.',
          wrong: {
            b: 'Isso descreve a criação já ordenada, não o estado inicial.',
            c: 'Separações vêm nos dias seguintes.',
            d: 'O homem ainda não foi formado.',
          },
          verseRef: 'Gênesis 1:2',
          learningObjective: 'Reconhecer o estado caótico da terra antes da criação.',
          passageText:
            'A terra, porém, era sem forma e vazia; havia trevas sobre a face do abismo, mas o Espírito de Deus pairava por cima das águas.',
        },
      ],
      caminhada: [
        {
          question: 'O que o estado "sem forma e vazia" sugere no contexto do relato?',
          options: [
            ['a', 'Terra ainda desordenada, pronta para ser moldada por Deus'],
            ['b', 'Terra eternamente maldita e irreparável'],
            ['c', 'Prova de que Deus não criou a matéria primitiva'],
            ['d', 'Metáfora de que a terra sempre existiu sozinha'],
          ],
          correct: 'a',
          ok: 'Perfeito. O caos inicial prepara o leitor para a ação criadora.',
          wrong: {
            b: 'O texto não condena a terra, apenas a descreve como inacabada.',
            c: 'Gênesis 1:1 já afirma criação divina.',
            d: 'O relato enfatiza dependência da palavra de Deus.',
          },
          verseRef: 'Gênesis 1:2',
          learningObjective: 'Compreender o caos inicial como cenário da ação divina.',
          evidence: ['Gênesis 1:1', 'Gênesis 1:2'],
        },
        {
          question: 'Qual papel o Espírito de Deus desempenha sobre as águas em 1:2?',
          options: [
            ['a', 'Presença ativa de Deus sobre o caos, antecipando ordenação'],
            ['b', 'Ausência total de Deus do mundo material'],
            ['c', 'Punição imediata pela desordem da terra'],
            ['d', 'Substituição definitiva da criação por espiritualidade'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Deus já está presente antes de falar "Haja luz".',
          wrong: {
            b: 'O Espírito paira justamente sobre a criação.',
            c: 'Não há juízo aqui, apenas descrição.',
            d: 'Matéria e Espírito coexistem no relato.',
          },
          verseRef: 'Gênesis 1:2',
          learningObjective: 'Interpretar a presença do Espírito como preparação da criação.',
        },
      ],
      profundezas: [
        {
          question: 'Como Gênesis 1:1–2 prepara o leitor para o restante do capítulo?',
          options: [
            ['a', 'Apresenta Deus como Senhor do caos que traz ordem pela palavra'],
            ['b', 'Mostra que a criação é acidente sem propósito'],
            ['c', 'Prova que luz e trevas são iguais perante Deus'],
            ['d', 'Elimina qualquer distinção entre criador e criatura'],
          ],
          correct: 'a',
          ok: 'Excelente. O prólogo estabelece autoridade e intenção divinas.',
          wrong: {
            b: 'Toda a sequência contradiz acaso.',
            c: 'Deus separará luz e trevas com valor distinto.',
            d: 'O texto mantém clara distinção criador/criatura.',
          },
          verseRef: 'Gênesis 1:1–2',
          skill: 'interpret',
          learningObjective: 'Relacionar o prólogo com a teologia do capítulo 1.',
          evidence: ['Gênesis 1:1', 'Gênesis 1:2', 'Gênesis 1:3'],
        },
        {
          question: 'Que contraste teológico o texto estabelece entre caos e criação?',
          options: [
            ['a', 'Desordem cede lugar à bondade quando Deus fala e separa'],
            ['b', 'Caos e ordem são dois deuses rivais iguais'],
            ['c', 'Deus apenas aproveita matéria que nunca controlou'],
            ['d', 'A criação boa exclui qualquer sombra ou limite'],
          ],
          correct: 'a',
          ok: 'Correto. A palavra divina transforma caos em cosmos habitável.',
          wrong: {
            b: 'Monoteísmo permeia todo o relato.',
            c: 'Deus reina sobre o caos desde o início.',
            d: 'Trevas existem, mas são limitadas por Deus.',
          },
          verseRef: 'Gênesis 1:1–2',
          skill: 'connect',
          learningObjective: 'Conectar caos inicial com o tema da ordem boa.',
        },
      ],
    }),

    ...pack('gen-02-dias', {
      semente: [
        {
          question: 'Qual foi a primeira ordem criadora registrada em Gênesis 1?',
          options: [
            ['a', 'Haja luz'],
            ['b', 'Haja expansão no meio das águas'],
            ['c', 'Produza a terra vegetação'],
            ['d', 'Façamos o homem'],
          ],
          correct: 'a',
          ok: 'Correto. A luz inaugura a série de "Haja…".',
          wrong: {
            b: 'Isso ocorre no segundo dia.',
            c: 'Vegetação pertence ao terceiro dia.',
            d: 'Humanos são criados no sexto dia.',
          },
          verseRef: 'Gênesis 1:3',
          learningObjective: 'Identificar a primeira palavra criadora do relato.',
          passageText: 'Disse Deus: Haja luz; e houve luz.',
        },
        {
          question: 'O que Deus separou no segundo dia da criação?',
          options: [
            ['a', 'Águas de cima e águas de baixo'],
            ['b', 'Luz e trevas'],
            ['c', 'Terra seca e mares'],
            ['d', 'Homem e mulher'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Deus faz a expansão entre as águas.',
          wrong: {
            b: 'Luz e trevas foram separadas no primeiro dia.',
            c: 'Terra seca e mares aparecem no terceiro dia.',
            d: 'Humanos são formados no sexto dia.',
          },
          verseRef: 'Gênesis 1:6–8',
          learningObjective: 'Reconhecer a separação central do segundo dia.',
        },
      ],
      caminhada: [
        {
          question: 'Qual padrão se repete nos dias da criação em Gênesis 1:3–25?',
          options: [
            ['a', 'Deus fala, executa, vê que é bom e nomeia/separa'],
            ['b', 'Deus luta contra forças rivais até vencer por acaso'],
            ['c', 'Cada dia corrige erros do dia anterior'],
            ['d', 'Criação ocorre sem palavra, apenas por evolução lenta'],
          ],
          correct: 'a',
          ok: 'Perfeito. Ritmo de palavra, realização e avaliação marca o relato.',
          wrong: {
            b: 'Não há combate mitológico aqui.',
            c: 'Cada dia é bom, não reparo de falha.',
            d: 'A palavra divina é elemento central.',
          },
          verseRef: 'Gênesis 1:3–25',
          learningObjective: 'Compreender a estrutura literária dos dias creativos.',
          evidence: ['Gênesis 1:3', 'Gênesis 1:9–10', 'Gênesis 1:24–25'],
        },
        {
          question: 'Por que a "separação" é tema importante nos primeiros três dias?',
          options: [
            ['a', 'Porque ordenar o caos significa distinguir e dar lugar a cada coisa'],
            ['b', 'Porque Deus rejeita tudo o que é material'],
            ['c', 'Porque separar prova fraqueza divina'],
            ['d', 'Porque o texto nega valor à diversidade da criação'],
          ],
          correct: 'a',
          ok: 'Exato. Separar é tornar o mundo habitável e legível.',
          wrong: {
            b: 'Deus declara a matéria boa.',
            c: 'Separar expressa domínio sábio, não fraqueza.',
            d: 'Diversidade surge justamente das separações.',
          },
          verseRef: 'Gênesis 1:4–10',
          learningObjective: 'Entender separação como ato de ordenação, não rejeição.',
        },
      ],
      profundezas: [
        {
          question: 'O que o refrão "era bom" comunica sobre a criação?',
          options: [
            ['a', 'Cada etapa cumpre o propósito de Deus e reflete sua bondade'],
            ['b', 'Apenas o ser humano possui valor moral'],
            ['c', 'Bondade significa ausência total de limite ou perigo'],
            ['d', 'Deus ainda não viu defeitos que corrigirá depois'],
          ],
          correct: 'a',
          ok: 'Correto. Bondade aqui é conformidade com o desígnio criador.',
          wrong: {
            b: 'Vários elementos não humanos são "bons".',
            c: 'Bondade não elimina noite, mar ou limites.',
            d: 'O refrão afirma, não suspeita.',
          },
          verseRef: 'Gênesis 1:4–25',
          skill: 'interpret',
          learningObjective: 'Interpretar "era bom" como avaliação teológica da criação.',
          evidence: ['Gênesis 1:4', 'Gênesis 1:10', 'Gênesis 1:25'],
        },
        {
          question: 'Como os dias 1–3 se relacionam com os dias 4–6?',
          options: [
            ['a', 'Espaços preparados nos primeiros dias recebem habitantes nos seguintes'],
            ['b', 'Dias 4–6 desfazem o trabalho dos dias 1–3'],
            ['c', 'Não há correspondência intencional entre os blocos'],
            ['d', 'Apenas os dias pares têm importância simbólica'],
          ],
          correct: 'a',
          ok: 'Excelente. Há paralelismo entre reino preparado e reino povoado.',
          wrong: {
            b: 'O texto constrói continuidade, não ruptura.',
            c: 'A simetria 1–4, 2–5, 3–6 é reconhecida por exegetas.',
            d: 'Todos os seis dias participam da mesma teologia.',
          },
          verseRef: 'Gênesis 1:3–25',
          skill: 'connect',
          learningObjective: 'Conectar estrutura dos dias com teologia da criação.',
        },
      ],
    }),

    ...pack('gen-03-imagem', {
      semente: [
        {
          question: 'Em cuja imagem Deus criou o ser humano?',
          options: [
            ['true', 'Verdadeiro'],
            ['false', 'Falso'],
          ],
          correct: 'true',
          ok: 'Correto. "Façamos o homem à nossa imagem" (1:26).',
          wrong: {
            false: 'O texto afirma expressamente imagem divina.',
          },
          verseRef: 'Gênesis 1:26',
          type: 'true_false',
          learningObjective: 'Reconhecer a afirmação da imagem de Deus no humano.',
          passageText:
            'Então, disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança.',
        },
        {
          question: 'O que Deus concede ao humano sobre a criação em 1:28?',
          options: [
            ['a', 'Dominar peixes, aves e toda criatura vivente'],
            ['b', 'Adorar somente o sol e a lua'],
            ['c', 'Explorar a terra até esgotá-la'],
            ['d', 'Viver isolado da criação'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Domínio está ligado à bênção e responsabilidade.',
          wrong: {
            b: 'Luminares foram feitos para marcar tempos, não para culto.',
            c: 'Domínio no contexto bíblico implica stewardship, não destruição.',
            d: 'Humanos são colocados dentro da criação, não fora dela.',
          },
          verseRef: 'Gênesis 1:28',
          learningObjective: 'Identificar o mandato de domínio concedido ao humano.',
        },
      ],
      caminhada: [
        {
          question: 'O que implica criar o humano "à imagem de Deus"?',
          options: [
            ['a', 'Dignidade, vocação representativa e relação especial com o Criador'],
            ['b', 'Identidade física idêntica à aparência de Deus'],
            ['c', 'Autonomia para viver sem responsabilidade moral'],
            ['d', 'Superioridade que autoriza desprezo pelos outros seres'],
          ],
          correct: 'a',
          ok: 'Perfeito. Imagem aponta representação e valor, não mera aparência.',
          wrong: {
            b: 'Imagem no Antigo Oriente era funcional e relacional.',
            c: 'Imagem implica responsabilidade, não licença.',
            d: 'Domínio não legitima crueldade.',
          },
          verseRef: 'Gênesis 1:26–27',
          learningObjective: 'Compreender imagem como dignidade e representação.',
        },
        {
          question: 'Como "dominar" deve ser entendido à luz do contexto de Gênesis 1?',
          options: [
            ['a', 'Governar com cuidado, como vice-regente de um Deus bom'],
            ['b', 'Aniquilar qualquer forma de vida que atrapalhe o humano'],
            ['c', 'Usurpar o lugar de Deus como dono absoluto'],
            ['d', 'Negar qualquer envolvimento prático com a terra'],
          ],
          correct: 'a',
          ok: 'Exato. Domínio ecoa a governança ordenadora de Deus.',
          wrong: {
            b: 'Criação é declarada boa; destruição gratuita contradiz o texto.',
            c: 'Humanos representam Deus, não o substituem.',
            d: 'Cultivar e poblar implicam envolvimento.',
          },
          verseRef: 'Gênesis 1:26–28',
          learningObjective: 'Distinguir domínio bíblico de exploração arbitrária.',
        },
      ],
      profundezas: [
        {
          question: 'Como a imagem de Deus fundamenta a dignidade humana?',
          options: [
            ['a', 'Valor humano deriva do criador, não de utilidade ou força'],
            ['b', 'Dignidade depende de conquistas culturais ou tecnológicas'],
            ['c', 'Somente reis possuem imagem; o povo comum não'],
            ['d', 'Imagem se perde totalmente após qualquer erro moral'],
          ],
          correct: 'a',
          ok: 'Correto. Ser humano é valorado por origem divina, não por desempenho.',
          wrong: {
            b: 'O texto baseia dignidade na criação, não em mérito.',
            c: 'Imagem abrange "homem e mulher" (1:27).',
            d: 'Queda afeta imagem, mas não apaga o argumento de 1:26–27.',
          },
          verseRef: 'Gênesis 1:26–27',
          skill: 'interpret',
          learningObjective: 'Articular imago Dei como base de dignidade humana.',
        },
        {
          question: 'Que responsabilidade prática a bênção de 1:28 impõe hoje?',
          options: [
            ['a', 'Cuidar da criação como expressão de fidelidade ao Criador'],
            ['b', 'Ignorar limites ecológicos porque o mundo acabará'],
            ['c', 'Tratar animais e terras como sem valor moral algum'],
            ['d', 'Concentrar domínio apenas em acumular riqueza pessoal'],
          ],
          correct: 'a',
          ok: 'Excelente. Bênção e mandato caminham juntos.',
          wrong: {
            b: 'Escatologia não anula stewardship presente.',
            c: 'Criação é boa e confiada ao humano.',
            d: 'Domínio é vocação, não ganância privada.',
          },
          verseRef: 'Gênesis 1:28',
          skill: 'connect',
          learningObjective: 'Conectar mandato de domínio com responsabilidade atual.',
        },
      ],
    }),

    ...pack('gen-04-descanso', {
      semente: [
        {
          question: 'O que Deus fez no sétimo dia, segundo Gênesis 2:2?',
          options: [
            ['a', 'Descansou de toda a obra que fizera'],
            ['b', 'Criou novamente luz e trevas'],
            ['c', 'Expulsou Adão do jardim'],
            ['d', 'Confundiu as línguas da humanidade'],
          ],
          correct: 'a',
          ok: 'Correto. Deus cessa a obra creativa e descansa.',
          wrong: {
            b: 'A criação já estava concluída.',
            c: 'Expulsão pertence ao capítulo 3.',
            d: 'Babel está em Gênesis 11.',
          },
          verseRef: 'Gênesis 2:2',
          learningObjective: 'Identificar a ação divina no sétimo dia.',
          passageText:
            'E, havendo Deus acabado no sétimo dia a obra que fizera, descansou nesse dia de toda a obra que tinha feito.',
        },
        {
          question: 'O que Deus fez em relação ao sétimo dia?',
          options: [
            ['a', 'Abençoou e santificou'],
            ['b', 'Amaldiçoou por causa do homem'],
            ['c', 'O eliminou do calendário'],
            ['d', 'O entregou somente aos anjos'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. O dia recebe status único de santidade.',
          wrong: {
            b: 'Maldições aparecem após a queda.',
            c: 'O dia é destacado, não apagado.',
            d: 'É ordenança para a criação humana também.',
          },
          verseRef: 'Gênesis 2:3',
          learningObjective: 'Reconhecer bênção e santificação do Shabat.',
        },
      ],
      caminhada: [
        {
          question: 'Por que o descanso de Deus vem após "tudo estar concluído"?',
          options: [
            ['a', 'Porque repouso coroa uma obra perfeita, não uma interrupção por cansaço'],
            ['b', 'Porque Deus falhou em terminar no sexto dia'],
            ['c', 'Porque o sétimo dia cancela o valor dos seis anteriores'],
            ['d', 'Porque descanso significa abandono da criação'],
          ],
          correct: 'a',
          ok: 'Perfeito. Descanso celebra completude e satisfação.',
          wrong: {
            b: 'O sexto dia termina com "muito bom".',
            c: 'Os seis dias permanecem bons.',
            d: 'Deus continua envolvido com o mundo.',
          },
          verseRef: 'Gênesis 2:1–3',
          learningObjective: 'Compreender descanso divino como coroação, não fraqueza.',
        },
        {
          question: 'O que significa "santificar" o sétimo dia neste contexto?',
          options: [
            ['a', 'Separá-lo como tempo distinto dedicado a Deus e ao ritmo da vida'],
            ['b', 'Transformá-lo em dia de trabalho extra'],
            ['c', 'Reservá-lo apenas para punições públicas'],
            ['d', 'Torná-lo igual aos demais dias sem diferença'],
          ],
          correct: 'a',
          ok: 'Exato. Santificar implica consagrar e distinguir.',
          wrong: {
            b: 'Shabat contrasta com labuta ordinária.',
            c: 'Santificação aponta bênção, não castigo.',
            d: 'O texto enfatiza diferença do sétimo dia.',
          },
          verseRef: 'Gênesis 2:3',
          learningObjective: 'Entender santificação do Shabat como tempo consagrado.',
        },
      ],
      profundezas: [
        {
          question: 'Como o Shabat aponta para a ordem boa da criação?',
          options: [
            ['a', 'Convida a participar do ritmo em que trabalho e descanso coexistem sob Deus'],
            ['b', 'Ensina que criar é pecado e deve ser evitado'],
            ['c', 'Prova que matéria e tempo são ilusões'],
            ['d', 'Substitui completamente a necessidade de justiça social'],
          ],
          correct: 'a',
          ok: 'Correto. Shabat integra humanos ao padrão de vida de Deus.',
          wrong: {
            b: 'Trabalho dos seis dias é bom.',
            c: 'Tempo e matéria são reais no relato.',
            d: 'Shabat não elimina ética comunitária.',
          },
          verseRef: 'Gênesis 2:1–3',
          skill: 'interpret',
          learningObjective: 'Interpretar Shabat como participação na ordem criadora.',
        },
        {
          question: 'Que contraste o descanso divino oferece a ritmos de inquietação humana?',
          options: [
            ['a', 'Mostra que identidade não depende de produção incessante'],
            ['b', 'Incentiva preguiça total e abandono de responsabilidades'],
            ['c', 'Elimina a necessidade de limites semanais'],
            ['d', 'Afirma que descanso é privilégio só de quem não trabalha'],
          ],
          correct: 'a',
          ok: 'Excelente. Repouso afirma confiança no Deus que sustenta.',
          wrong: {
            b: 'Shabat pressupõe trabalho nos outros dias.',
            c: 'Limites rítmicos são justamente o ponto.',
            d: 'Descanso é mandato inclusivo.',
          },
          verseRef: 'Gênesis 2:2–3',
          skill: 'connect',
          learningObjective: 'Conectar Shabat com antídoto à cultura de exaustão.',
        },
      ],
    }),

    ...pack('gen-05-eden', {
      semente: [
        {
          question: 'Onde Deus plantou o jardim, segundo Gênesis 2:8?',
          options: [
            ['a', 'No Éden, ao oriente'],
            ['b', 'No monte Sinai'],
            ['c', 'Em Babilônia'],
            ['d', 'No deserto do Sinai'],
          ],
          correct: 'a',
          ok: 'Correto. O Éden é apresentado como jardim orientado.',
          wrong: {
            b: 'Sinai pertence à história de Israel, não à criação.',
            c: 'Babilônia aparece mais tarde em Gênesis.',
            d: 'Deserto não é o cenário do jardim.',
          },
          verseRef: 'Gênesis 2:8',
          learningObjective: 'Localizar o jardim do Éden no relato.',
          passageText: 'E plantou o SENHOR Deus um jardim no Éden, ao oriente.',
        },
        {
          question: 'Qual tarefa Deus confia ao homem no jardim?',
          options: [
            ['a', 'Cultivá-lo e guardá-lo'],
            ['b', 'Construir uma torre até o céu'],
            ['c', 'Nomear todos os animais em uma hora'],
            ['d', 'Proibir qualquer contato com a terra'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Trabalho e vigilância definem a vocação edénica.',
          wrong: {
            b: 'Torre de Babel é outra narrativa.',
            c: 'Nomear animais ocorre, mas não é a tarefa principal aqui.',
            d: 'O homem é colocado para cuidar, não se afastar.',
          },
          verseRef: 'Gênesis 2:15',
          learningObjective: 'Identificar a vocação de cultivar e guardar.',
        },
      ],
      caminhada: [
        {
          question: 'Por que o Éden é descrito como fonte de rios?',
          options: [
            ['a', 'Para mostrar vida, fertilidade e provisão vinda de Deus'],
            ['b', 'Para provar que o jardim era deserto seco'],
            ['c', 'Para indicar que humanos deviam viver sem água'],
            ['d', 'Para sugerir que Deus abandonou logo o jardim'],
          ],
          correct: 'a',
          ok: 'Perfeito. Água abundante sinaliza bênção e sustento.',
          wrong: {
            b: 'Rios contradizem aridez.',
            c: 'Água é signo positivo central.',
            d: 'Deus coloca o homem justamente no jardim.',
          },
          verseRef: 'Gênesis 2:10–14',
          learningObjective: 'Compreender rios como sinal de provisão divina.',
        },
        {
          question: 'O que "cultivar e guardar" revela sobre a vocação humana?',
          options: [
            ['a', 'Trabalho criativo e proteção responsável dentro da criação'],
            ['b', 'Exploração irrestrita sem limites éticos'],
            ['c', 'Isolamento completo de toda criatura'],
            ['d', 'Obediência apenas quando convém ao humano'],
          ],
          correct: 'a',
          ok: 'Exato. Vocação combina desenvolvimento e cuidado.',
          wrong: {
            b: 'Guardar implica limites e vigilância.',
            c: 'Humanos vivem em relação com o jardim.',
            d: 'Comunhão com Deus pressupõe confiança.',
          },
          verseRef: 'Gênesis 2:15',
          learningObjective: 'Entender vocação edénica como cuidado ativo.',
        },
      ],
      profundezas: [
        {
          question: 'Como o jardim do Éden antecipa comunhão e responsabilidade?',
          options: [
            ['a', 'Deus está próximo, provê e confia missão ao humano'],
            ['b', 'Humanos vivem autônomos sem orientação divina'],
            ['c', 'O jardim elimina qualquer escolha moral'],
            ['d', 'Responsabilidade humana contradiz a bondade de Deus'],
          ],
          correct: 'a',
          ok: 'Correto. Proximidade e mandato caminham juntos.',
          wrong: {
            b: 'Deus planta, coloca e instrui.',
            c: 'Há árvore proibida e comando.',
            d: 'Confiança expressa bondade, não contradição.',
          },
          verseRef: 'Gênesis 2:8–17',
          skill: 'interpret',
          learningObjective: 'Interpretar Éden como comunhão com responsabilidade.',
        },
        {
          question: 'Que relação há entre o Éden e o projeto de Gênesis 1?',
          options: [
            ['a', 'Capítulo 2 aprofunda vocação humana dentro da criação boa do capítulo 1'],
            ['b', 'Éden cancela o mandato de domínio de 1:28'],
            ['c', 'Os dois capítulos negam-se completamente'],
            ['d', 'Somente Gênesis 1 é teologicamente relevante'],
          ],
          correct: 'a',
          ok: 'Excelente. Leitura complementar enriquece a teologia da criação.',
          wrong: {
            b: 'Cultivar/guardar especifica domínio responsável.',
            c: 'Tradição judaica e cristã lê em continuidade.',
            d: 'Ambos são canonicalmente centrais.',
          },
          verseRef: 'Gênesis 1:28',
          skill: 'connect',
          learningObjective: 'Conectar mandatos de Gênesis 1 e 2.',
          evidence: ['Gênesis 1:28', 'Gênesis 2:15'],
        },
      ],
    }),

    ...pack('gen-06-queda', {
      semente: [
        {
          question: 'Quem abordou a mulher no jardim?',
          options: [
            ['a', 'A serpente'],
            ['b', 'Um anjo com espada'],
            ['c', 'Caim'],
            ['d', 'Noé'],
          ],
          correct: 'a',
          ok: 'Correto. A serpente inicia a tentação.',
          wrong: {
            b: 'Anjo com espada aparece após a queda.',
            c: 'Caim nasce depois da expulsão.',
            d: 'Noé pertence à narrativa do dilúvio.',
          },
          verseRef: 'Gênesis 3:1',
          learningObjective: 'Identificar o agente tentador no relato.',
          passageText: 'Ora, a serpente era mais astuta que todos os animais do campo.',
        },
        {
          question: 'O que a serpente questionou primeiro?',
          options: [
            ['a', 'Se Deus realmente proibira comer de toda árvore'],
            ['b', 'Se Adão havia nomeado os animais'],
            ['c', 'Se o dilúvio destruiria a terra'],
            ['d', 'Se Abrão sairia de Ur'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. A dúvida começa distorcendo a palavra de Deus.',
          wrong: {
            b: 'Nomear animais é cena anterior.',
            c: 'Dilúvio ainda não foi anunciado.',
            d: 'Abraão aparece em capítulo 12.',
          },
          verseRef: 'Gênesis 3:1',
          learningObjective: 'Reconhecer a estratégia inicial da tentação.',
        },
      ],
      caminhada: [
        {
          question: 'Como a serpente distorce a palavra de Deus?',
          options: [
            ['a', 'Exagera a proibição e insinua que Deus retém o bem'],
            ['b', 'Cita fielmente sem alterar sentido'],
            ['c', 'Afirma que Deus nunca deu comando algum'],
            ['d', 'Propõe obedecer imediatamente a Deus'],
          ],
          correct: 'a',
          ok: 'Perfeito. Tentação mistura verdade parcial com desconfiança.',
          wrong: {
            b: 'Há distorção deliberada.',
            c: 'Comando existe; a serpente o distorce.',
            d: 'Serpente empurra desobediência.',
          },
          verseRef: 'Gênesis 3:1–5',
          learningObjective: 'Compreender distorção da palavra como tática de tentação.',
        },
        {
          question: 'A afirmação "certamente não morrereis" ao comer do fruto é verdadeira?',
          options: [
            ['true', 'Verdadeiro'],
            ['false', 'Falso'],
          ],
          correct: 'false',
          ok: 'Correto. A serpente minimiza consequências reais da desobediência.',
          wrong: {
            true: 'O texto mostra ruptura imediata e morte espiritual/relacional.',
          },
          verseRef: 'Gênesis 3:4',
          type: 'true_false',
          learningObjective: 'Avaliar a promessa falsa da serpente.',
        },
      ],
      profundezas: [
        {
          question: 'O que a queda revela sobre desejo e desobediência?',
          options: [
            ['a', 'Desejo desordenado leva a desconfiar de Deus e quebrar comunhão'],
            ['b', 'Desobediência fortalece imediatamente a amizade com Deus'],
            ['c', 'Pecado não altera relações humanas ou divinas'],
            ['d', 'Tentação sempre falha sem consequência'],
          ],
          correct: 'a',
          ok: 'Exato. Queda é ruptura de confiança e ordem.',
          wrong: {
            b: 'Adão e Eva se escondem de Deus.',
            c: 'Relações com Deus, terra e um ao outro mudam.',
            d: 'Consequências surgem logo em seguida.',
          },
          verseRef: 'Gênesis 3:6–13',
          skill: 'interpret',
          learningObjective: 'Interpretar queda como ruptura de confiança.',
        },
        {
          question: 'Como este episódio altera a relação humano-Deus narrada antes?',
          options: [
            ['a', 'Comunhão íntima cede a vergonha, medo e ocultação'],
            ['b', 'Proximidade aumenta após desobedecer'],
            ['c', 'Deus deixa de se importar com humanos'],
            ['d', 'Nada muda na experiência de Adão e Eva'],
          ],
          correct: 'a',
          ok: 'Correto. Esconder-se diante de Deus marca a ruptura.',
          wrong: {
            b: 'Medo substitui confiança.',
            c: 'Deus ainda busca e fala com eles.',
            d: 'Mudança é explícita no texto.',
          },
          verseRef: 'Gênesis 3:8–10',
          skill: 'connect',
          learningObjective: 'Conectar queda com perda de comunhão.',
        },
      ],
    }),

    ...pack('gen-07-consequencias', {
      semente: [
        {
          question: 'Entre quem Deus profetiza enemizade em Gênesis 3:15?',
          options: [
            ['a', 'Serpente e mulher, e suas descendências'],
            ['b', 'Caim e Abel'],
            ['c', 'Noé e os filhos'],
            ['d', 'Abraão e Faraó'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Protoevangelium nasce no julgamento da serpente.',
          wrong: {
            b: 'Caim e Abel aparecem no capítulo 4.',
            c: 'Noé pertence ao dilúvio.',
            d: 'Abraão está no capítulo 12.',
          },
          verseRef: 'Gênesis 3:15',
          learningObjective: 'Identificar protagonistas de Gênesis 3:15.',
        },
        {
          question: 'O que mudou para o homem no trabalho da terra?',
          options: [
            ['a', 'Trabalho árduo com espinhos e suor'],
            ['b', 'Eliminação total do trabalho'],
            ['c', 'Domínio absoluto sem esforço'],
            ['d', 'Proibição de plantar qualquer coisa'],
          ],
          correct: 'a',
          ok: 'Correto. Terra resiste ao esforço humano.',
          wrong: {
            b: 'Trabalho continua, porém frustrado.',
            c: 'Frustração substitui facilidade.',
            d: 'Cultivo permanece, mas difícil.',
          },
          verseRef: 'Gênesis 3:17–19',
          learningObjective: 'Reconhecer consequências do trabalho pós-queda.',
        },
      ],
      caminhada: [
        {
          question: 'O que é a promessa de Gênesis 3:15 (protoevangelium)?',
          options: [
            ['a', 'Anúncio de conflito em que a descendência da mulher prevalecerá sobre a serpente'],
            ['b', 'Promessa de que pecado não terá mais efeito algum'],
            ['c', 'Garantia de que a serpente vencerá a humanidade'],
            ['d', 'Profecia sobre construção da torre de Babel'],
          ],
          correct: 'a',
          ok: 'Perfeito. Julgamento inclui semente de esperança.',
          wrong: {
            b: 'Consequências continuam, mas há promessa.',
            c: 'Texto aponta vitória futura contra serpente.',
            d: 'Babel é narrativa distinta.',
          },
          verseRef: 'Gênesis 3:15',
          learningObjective: 'Compreender 3:15 como promessa dentro do juízo.',
        },
        {
          question: 'Por que as consequências afetam serpente, mulher e homem de modos distintos?',
          options: [
            ['a', 'Cada agente participou da ruptura de formas específicas no relato'],
            ['b', 'Deus pune aleatoriamente sem relação com a história'],
            ['c', 'Apenas Eva pecou; Adão é absolvido'],
            ['d', 'Consequências são idênticas para todos os seres'],
          ],
          correct: 'a',
          ok: 'Exato. Juízo é personalizado conforme papéis na queda.',
          wrong: {
            b: 'Há lógica narrativa clara.',
            c: 'Adão também comeu e é abordado.',
            d: 'Serpente, mulher e homem recebem palavras distintas.',
          },
          verseRef: 'Gênesis 3:14–19',
          learningObjective: 'Entender juízo diferenciado conforme participação.',
        },
      ],
      profundezas: [
        {
          question: 'Como Gênesis 3:15 aponta esperança dentro do julgamento?',
          options: [
            ['a', 'Deus não abandona criação; promete vitória futura sobre o mal'],
            ['b', 'Esperança só aparece em Gênesis 12, sem antecedentes'],
            ['c', 'Promessa cancela necessidade de obediência'],
            ['d', 'Serpente é elogiada no final do capítulo'],
          ],
          correct: 'a',
          ok: 'Correto. Graça surde já no pronunciamento de juízo.',
          wrong: {
            b: '3:15 é frequentemente lida como primeiro evangelho.',
            c: 'Esperança não elimina responsabilidade.',
            d: 'Serpente é condenada, não elogiada.',
          },
          verseRef: 'Gênesis 3:15',
          skill: 'interpret',
          learningObjective: 'Interpretar protoevangelium como esperança escatológica.',
        },
        {
          question: 'Que padrão de graça e juízo aparece em Gênesis 3?',
          options: [
            ['a', 'Deus julga o mal, mas ainda busca, veste e preserva vida humana'],
            ['b', 'Juízo total elimina qualquer relação futura'],
            ['c', 'Graça aparece apenas sem qualquer custo ou ruptura'],
            ['d', 'Deus ignora pecado para evitar conflito'],
          ],
          correct: 'a',
          ok: 'Excelente. Juízo real coexiste com cuidado providencial.',
          wrong: {
            b: 'Deus ainda fala com Adão e Eva.',
            c: 'Ruptura é real; graça não a nega.',
            d: 'Pecado é confrontado diretamente.',
          },
          verseRef: 'Gênesis 3:8–21',
          skill: 'connect',
          learningObjective: 'Conectar juízo e graça na narrativa da queda.',
        },
      ],
    }),

    ...pack('gen-08-caim', {
      semente: [
        {
          question: 'O que Caim e Abel ofereceram a Deus?',
          options: [
            ['a', 'Caim ofereceu fruto da terra; Abel, primogênitos do rebanho'],
            ['b', 'Ambos ofereceram ouro e prata'],
            ['c', 'Nenhum dos dois trouxe oferta'],
            ['d', 'Caim sacrificou Abel como oferta'],
          ],
          correct: 'a',
          ok: 'Correto. Ofertas refletem vocações distintas.',
          wrong: {
            b: 'Metais não são mencionados.',
            c: 'Ambos trazem ofertas.',
            d: 'Morte de Abel ocorre depois da rejeição.',
          },
          verseRef: 'Gênesis 4:3–4',
          learningObjective: 'Distinguir ofertas de Caim e Abel.',
        },
        {
          question: 'A quem Deus se refere ao dizer "Onde está Abel, teu irmão?"?',
          options: [
            ['a', 'Caim'],
            ['b', 'Noé'],
            ['c', 'Sete'],
            ['d', 'Lameque'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Deus confronta Caim diretamente.',
          wrong: {
            b: 'Noé pertence a gerações posteriores.',
            c: 'Sete nasce depois.',
            d: 'Lameque aparece mais adiante no capítulo.',
          },
          verseRef: 'Gênesis 4:9',
          learningObjective: 'Identificar destinatário da pergunta divina.',
        },
      ],
      caminhada: [
        {
          question: 'Por que a oferta de Abel foi aceita e a de Caim, rejeitada?',
          options: [
            ['a', 'O texto liga aceitação à qualidade/atitude de Abel, não ao tipo de oferta em si'],
            ['b', 'Deus rejeita sempre produtos agrícolas'],
            ['c', 'Abel ofereceu mais ouro que Caim'],
            ['d', 'Deus escolheu ao acaso sem critério'],
          ],
          correct: 'a',
          ok: 'Perfeito. Gênesis 4:4–7 aponta disposição do coração.',
          wrong: {
            b: 'Ofertas agrícolas são válidas em outros textos.',
            c: 'Riqueza material não é critério aqui.',
            d: 'Deus adverte Caim antes do crime.',
          },
          verseRef: 'Gênesis 4:4–7',
          learningObjective: 'Compreender critério de aceitação além do material.',
        },
        {
          question: 'O que a pergunta "Onde está Abel?" exige de Caim?',
          options: [
            ['a', 'Responsabilidade fraterna e honestidade diante de Deus'],
            ['b', 'Nova oferta agrícola imediata'],
            ['c', 'Construção de um altar em Babel'],
            ['d', 'Abandono definitivo da terra'],
          ],
          correct: 'a',
          ok: 'Exato. Deus recusa a evasiva "Acaso sou guarda do meu irmão?".',
          wrong: {
            b: 'Questão central é fraternidade violada.',
            c: 'Babel é outra história.',
            d: 'Caim é marcado, mas permanece na terra.',
          },
          verseRef: 'Gênesis 4:9–10',
          learningObjective: 'Entender pergunta divina como chamado à responsabilidade.',
        },
      ],
      profundezas: [
        {
          question: 'O que Gênesis 4 revela sobre ira, pecado e fraternidade?',
          options: [
            ['a', 'Ira não dominada abre caminho à violência contra o irmão'],
            ['b', 'Ira é sempre neutra e sem perigo'],
            ['c', 'Fraternidade não importa diante de Deus'],
            ['d', 'Pecado afeta só quem comete, nunca parentes'],
          ],
          correct: 'a',
          ok: 'Correto. Deus alerta: "o pecado jaz à porta".',
          wrong: {
            b: 'Texto adverte explicitamente.',
            c: 'Irmão é tema central.',
            d: 'Sangue de Abel "clama da terra".',
          },
          verseRef: 'Gênesis 4:6–10',
          skill: 'interpret',
          learningObjective: 'Interpretar ira como porta para violência fraterna.',
        },
        {
          question: 'Como este episódio amplia consequências da queda?',
          options: [
            ['a', 'Pecado destrói relações familiares e community, não só comunhão com Deus'],
            ['b', 'Queda fica confinada ao casal original'],
            ['c', 'Violência prova progresso moral da humanidade'],
            ['d', 'Caim restaura imediatamente o Éden'],
          ],
          correct: 'a',
          ok: 'Excelente. Queda irradia para gerações e vínculos.',
          wrong: {
            b: 'Capítulo 4 mostra escalada.',
            c: 'Primeiro homicídio é regressão, não progresso.',
            d: 'Caim vaga como fugitivo.',
          },
          verseRef: 'Gênesis 4:1–16',
          skill: 'connect',
          learningObjective: 'Conectar queda com violência fraterna.',
        },
      ],
    }),

    ...pack('gen-09-diluvio', {
      semente: [
        {
          question: 'O que Deus viu sobre a terra antes do dilúvio?',
          options: [
            ['a', 'Maldade/corrupção generalizada da humanidade'],
            ['b', 'Obediência perfeita em toda parte'],
            ['c', 'Ausência total de violência'],
            ['d', 'Fidelidade ininterrupta de Noé aos ídolos'],
          ],
          correct: 'a',
          ok: 'Correto. Corrupção justifica juízo, mas Deus preserva Noé.',
          wrong: {
            b: 'Texto descreve maldade contínua.',
            c: 'Violência faz parte da corrupção.',
            d: 'Noé encontra graça justamente por fidelidade.',
          },
          verseRef: 'Gênesis 6:5–8',
          learningObjective: 'Identificar diagnóstico moral pré-diluviano.',
          passageText:
            'Viu, pois, o SENHOR que a maldade do homem se multiplicara sobre a terra e que toda imaginação dos pensamentos de seu coração era só má continuamente.',
        },
        {
          question: 'Com quem Deus estabeleceu aliança após o dilúvio?',
          options: [
            ['a', 'Noé, seus descendentes e toda criatura vivente'],
            ['b', 'Somente Faraó e o Egito'],
            ['c', 'Apenas a serpente do Éden'],
            ['d', 'Exclusivamente Caim e sua linhagem'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Aliança abrange criação inteira.',
          wrong: {
            b: 'Egito aparece muito depois.',
            c: 'Serpente não recebe aliança aqui.',
            d: 'Caim pertence a narrativa anterior.',
          },
          verseRef: 'Gênesis 9:9–13',
          learningObjective: 'Reconhecer escopo da aliança pós-diluviana.',
        },
      ],
      caminhada: [
        {
          question: 'Por que Noé encontrou graça enquanto a terra estava corrompida?',
          options: [
            ['a', 'Porque viveu com retidão/fidelidade em meio à geração caída'],
            ['b', 'Porque era o mais rico de todos'],
            ['c', 'Porque nunca precisou obedecer a Deus'],
            ['d', 'Porque construiu a torre de Babel'],
          ],
          correct: 'a',
          ok: 'Perfeito. Graça e caráter andam juntos no relato.',
          wrong: {
            b: 'Riqueza não é critério.',
            c: 'Obediência ao construir arca é central.',
            d: 'Babel é posterior.',
          },
          verseRef: 'Gênesis 6:8–9',
          learningObjective: 'Compreender graça de Noé no contexto de corrupção.',
        },
        {
          question: 'O que o arco-íris simboliza na aliança pós-dilúvio?',
          options: [
            ['a', 'Sinal memorial de que Deus não destruirá a terra com dilúvio'],
            ['b', 'Promessa de que humanos nunca mais pecarão'],
            ['c', 'Garantia de que não haverá mais chuva'],
            ['d', 'Marca de vergonha imposta a Noé'],
          ],
          correct: 'a',
          ok: 'Exato. Arco aponta para misericórdia promissória.',
          wrong: {
            b: 'Humanos continuam pecadores depois.',
            c: 'Chuva permanece; dilúvio universal não.',
            d: 'Arco é sinal de aliança, não humilhação.',
          },
          verseRef: 'Gênesis 9:12–17',
          learningObjective: 'Interpretar arco-íris como sinal de aliança.',
        },
      ],
      profundezas: [
        {
          question: 'Como o dilúvio funciona como juízo e novo começo?',
          options: [
            ['a', 'Julga corrupção, mas preserva vida e reinicia humanidade com Noé'],
            ['b', 'Elimina definitivamente plano de Deus com o mundo'],
            ['c', 'É castigo sem qualquer elemento de salvação'],
            ['d', 'Apaga memória da criação original sem continuidade'],
          ],
          correct: 'a',
          ok: 'Correto. Juízo e graça coexistem na narrativa.',
          wrong: {
            b: 'Aliança pós-diluviana continua plano.',
            c: 'Arca salva Noé e família.',
            d: 'Bênção de 9:1 ecoa 1:28.',
          },
          verseRef: 'Gênesis 6–9',
          skill: 'interpret',
          learningObjective: 'Interpretar dilúvio como descontinuidade e continuidade.',
          evidence: ['Gênesis 6:5–8', 'Gênesis 9:1', 'Gênesis 9:12–13'],
        },
        {
          question: 'Que continuidade e ruptura há entre criação, queda e dilúvio?',
          options: [
            ['a', 'Bondade criadora persiste, mas pecado provoca juízo renovador'],
            ['b', 'Dilúvio prova que criação original foi erro'],
            ['c', 'Queda não tem relação com corrupção posterior'],
            ['d', 'Noé inaugura humanidade sem aliança alguma'],
          ],
          correct: 'a',
          ok: 'Excelente. Padrão queda–escalada–juízo–promessa continua.',
          wrong: {
            b: 'Deus reafirma criação após dilúvio.',
            c: 'Capítulos 3–6 mostram escalada.',
            d: 'Aliança com arco é explícita.',
          },
          verseRef: 'Gênesis 1–9',
          skill: 'connect',
          learningObjective: 'Conectar arco narrativo Gênesis 1–9.',
        },
      ],
    }),

    ...pack('gen-10-babel', {
      semente: [
        {
          question: 'O que o povo queria construir em Babel?',
          options: [
            ['a', 'Uma cidade e uma torre com topo nos céus'],
            ['b', 'Uma arca para escapar do dilúvio'],
            ['c', 'Um altar no monte Moriá'],
            ['d', 'Um jardim sem rios'],
          ],
          correct: 'a',
          ok: 'Correto. Torre expressa ambição concentrada.',
          wrong: {
            b: 'Arca é história de Noé.',
            c: 'Moriá aparece mais tarde.',
            d: 'Éden tinha rios; Babel é urbano.',
          },
          verseRef: 'Gênesis 11:4',
          learningObjective: 'Identificar projeto arquitetônico de Babel.',
          passageText:
            'Disseram: Eia, edifiquemos nós uma cidade e uma torre cujo cume toque nos céus.',
        },
        {
          question: 'Deus confundiu a língua do povo para impedir que fizessem o quê?',
          options: [
            ['true', 'Verdadeiro — impedir que nada lhes fosse impossível'],
            ['false', 'Falso — apenas para ensinar novo idioma como bênção'],
          ],
          correct: 'true',
          ok: 'Correto. Confusão freia centralização orgulhosa.',
          wrong: {
            false: 'Texto apresenta juízo sobre ambição autônoma.',
          },
          verseRef: 'Gênesis 11:6–9',
          type: 'true_false',
          learningObjective: 'Reconhecer motivo divino na confusão das línguas.',
        },
      ],
      caminhada: [
        {
          question: 'Qual ambição humana a torre de Babel representa?',
          options: [
            ['a', 'Autossuficiência e fama sem dependência de Deus'],
            ['b', 'Adoração humilde ao Criador'],
            ['c', 'Missão de abençoar todas as nações'],
            ['d', 'Obediência ao mandato de povoar a terra'],
          ],
          correct: 'a',
          ok: 'Perfeito. "Façamos nome" revela orgulho coletivo.',
          wrong: {
            b: 'Projeto busca nome humano, não glória divina.',
            c: 'Bênção universal virá com Abraão.',
            d: 'Texto sugere concentração, não dispersão obediente.',
          },
          verseRef: 'Gênesis 11:4',
          learningObjective: 'Compreender torre como símbolo de autonomia.',
        },
        {
          question: 'Por que "fazer nome" é problemático neste texto?',
          options: [
            ['a', 'Usurpa lugar de Deus como fonte de identidade e glória'],
            ['b', 'Porque nomes são proibidos em toda Escritura'],
            ['c', 'Porque cidades são sempre pecaminosas por existirem'],
            ['d', 'Porque Deus quer humanos anônimos para sempre'],
          ],
          correct: 'a',
          ok: 'Exato. Nome próprio substitui confiança no Senhor.',
          wrong: {
            b: 'Nomear é atividade legítima em Gênesis 1–2.',
            c: 'Cidades não são intrinsecamente más.',
            d: 'Deus chama Abraão pelo nome depois.',
          },
          verseRef: 'Gênesis 11:4',
          learningObjective: 'Entender busca de fama como rival teológica.',
        },
      ],
      profundezas: [
        {
          question: 'Como Babel contrasta com a bênção de Gênesis 1:28?',
          options: [
            ['a', 'Em vez de povoar e stewardar, humanos concentram poder e fama'],
            ['b', 'Babel cumpre perfeitamente mandato de domínio'],
            ['c', 'Não há relação temática entre os textos'],
            ['d', '1:28 proíbe qualquer construção humana'],
          ],
          correct: 'a',
          ok: 'Correto. Dispersão pós-Babel prepara chamado de Abraão.',
          wrong: {
            b: 'Torre distorce domínio em orgulho.',
            c: 'Leitura canonical conecta os trechos.',
            d: 'Construir não é problema; motivação sim.',
          },
          verseRef: 'Gênesis 11:1–9',
          skill: 'interpret',
          learningObjective: 'Contrastar Babel com mandato de 1:28.',
          evidence: ['Gênesis 1:28', 'Gênesis 11:4'],
        },
        {
          question: 'Que eco Babel tem na vocação de Abraão (12:1–3)?',
          options: [
            ['a', 'Deus escolhe uma família para reorientar bênção às nações'],
            ['b', 'Abraão repete exatamente projeto da torre'],
            ['c', 'Abraão rejeita qualquer contato com o mundo'],
            ['d', 'Não há continuidade entre capítulos 11 e 12'],
          ],
          correct: 'a',
          ok: 'Excelente. Abraão recebe bênção para ser bênção.',
          wrong: {
            b: 'Abraão confia, não constrói torre.',
            c: 'Promessa inclui todas famílias da terra.',
            d: 'Capítulo 12 responde crise de 11.',
          },
          verseRef: 'Gênesis 12:1–3',
          skill: 'connect',
          learningObjective: 'Conectar juízo de Babel com chamado de Abraão.',
          evidence: ['Gênesis 11:9', 'Gênesis 12:3'],
        },
      ],
    }),

    ...pack('gen-11-abraao', {
      semente: [
        {
          question: 'De onde Deus chamou Abrão?',
          options: [
            ['a', 'De sua terra, parentela e casa paterna'],
            ['b', 'Do monte Sinai'],
            ['c', 'Do jardim do Éden'],
            ['d', 'Do Egito, após o exílio de José'],
          ],
          correct: 'a',
          ok: 'Correto. Chamado exige deixar seguranças familiares.',
          wrong: {
            b: 'Sinai pertence a Êxodo.',
            c: 'Éden já havia sido perdido.',
            d: 'José é narrativa posterior.',
          },
          verseRef: 'Gênesis 12:1',
          learningObjective: 'Identificar ponto de partida do chamado.',
          passageText:
            'Disse o SENHOR a Abrão: Sai da tua terra, da tua parentela e da casa de teu pai.',
        },
        {
          question: 'O que Deus prometeu a Abrão em Gênesis 12:1–3?',
          options: [
            ['a', 'Terra, grande descendência e bênção às nações'],
            ['b', 'Riqueza instantânea sem jornada'],
            ['c', 'Imunidade a qualquer provação'],
            ['d', 'Retorno imediato à terra de Ur no mesmo dia'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Promessas estruturam toda narrativa patriarcal.',
          wrong: {
            b: 'Jornada inclui provações.',
            c: 'Abraão enfrentará testes.',
            d: 'Chamado implica partida definitiva.',
          },
          verseRef: 'Gênesis 12:2–3',
          learningObjective: 'Reconhecer tríade de promessas abraâmicas.',
        },
      ],
      caminhada: [
        {
          question: 'Por que o chamado exige deixar terra, parentela e casa?',
          options: [
            ['a', 'Porque fidelidade a Deus pode reorientar identidade e lealdades'],
            ['b', 'Porque família é irrelevante para Deus'],
            ['c', 'Porque Deus odeia cidades e parentes'],
            ['d', 'Porque Abrão buscava fama como em Babel'],
          ],
          correct: 'a',
          ok: 'Perfeito. Chamado separa para missão, não por desprezo à família.',
          wrong: {
            b: 'Aliança envolve descendência prometida.',
            c: 'Deus trabalha com famílias ao longo de Gênesis.',
            d: 'Abraão confia na palavra, não busca torre.',
          },
          verseRef: 'Gênesis 12:1',
          learningObjective: 'Compreender custo e sentido da partida.',
        },
        {
          question: 'Como as promessas de 12:1–3 revertem o juízo de Babel?',
          options: [
            ['a', 'Bênção flui por uma família para alcançar todas as famílias da terra'],
            ['b', 'Repetem confusão de línguas em nova forma'],
            ['c', 'Concentram bênção apenas em Ur'],
            ['d', 'Eliminam missão com as nações'],
          ],
          correct: 'a',
          ok: 'Exato. "Em ti serão benditas todas as famílias".',
          wrong: {
            b: 'Promessa unifica bênção, não confunde.',
            c: 'Missão é para Canaã e além.',
            d: '12:3 enfatiza alcance universal.',
          },
          verseRef: 'Gênesis 12:3',
          learningObjective: 'Relacionar promessa abraâmica com crise de Babel.',
          evidence: ['Gênesis 11:9', 'Gênesis 12:3'],
        },
      ],
      profundezas: [
        {
          question: 'De que modo Abraão inaugura resposta de Deus à humanidade caída?',
          options: [
            ['a', 'Por meio de aliança promissória que recupera bênção para o mundo'],
            ['b', 'Negando qualquer continuidade com Adão e Noé'],
            ['c', 'Estabelecendo reino político imediato em Canaã'],
            ['d', 'Abolindo necessidade de fé e obediência'],
          ],
          correct: 'a',
          ok: 'Correto. Abraão é eixo de promessa pós-queda/dilúvio/Babel.',
          wrong: {
            b: 'Genealogias conectam Abraão a Noé e Adão.',
            c: 'Posse da terra é promessa futura e gradual.',
            d: 'Abraão creu e partiu — fé é central.',
          },
          verseRef: 'Gênesis 12:1–3',
          skill: 'interpret',
          learningObjective: 'Interpretar Abraão como resposta promissória.',
        },
        {
          question: 'Como 12:1–3 conecta Gênesis 1–11 ao restante do livro?',
          options: [
            ['a', 'Fecha arco de queda/juízo e abre história de aliança e descendência'],
            ['b', 'Encerra Gênesis sem narrativa posterior'],
            ['c', 'Anula temas de criação e queda'],
            ['d', 'Substitui completamente o Deus criador por outro deus'],
          ],
          correct: 'a',
          ok: 'Excelente. Capítulo 12 funciona como hinge do Pentateuco.',
          wrong: {
            b: 'Patriarcas continuam por dezenas de capítulos.',
            c: 'Temas anteriores permanecem em segundo plano.',
            d: 'É o mesmo Deus criador que chama.',
          },
          verseRef: 'Gênesis 12:1–3',
          skill: 'connect',
          learningObjective: 'Conectar Gênesis 1–11 com narrativa patriarcal.',
        },
      ],
    }),

    ...pack('gen-boss-01', {
      semente: [
        {
          question: 'Qual frase abre o relato da criação em Gênesis 1:1?',
          options: [
            ['a', 'No princípio, criou Deus os céus e a terra'],
            ['b', 'No princípio era o Verbo'],
            ['c', 'Estas são as gerações dos céus'],
            ['d', 'Havia um homem na terra de Uz'],
          ],
          correct: 'a',
          ok: 'Correto. Abertura solene do módulo criação.',
          wrong: {
            b: 'Abertura de João 1.',
            c: 'Fórmula aparece em Gênesis 2:4.',
            d: 'Abertura de Jó.',
          },
          verseRef: 'Gênesis 1:1',
          learningObjective: 'Revisar abertura do relato da criação.',
        },
        {
          question: 'Em qual dia Deus criou o ser humano?',
          options: [
            ['a', 'Sexto dia'],
            ['b', 'Primeiro dia'],
            ['c', 'Sétimo dia'],
            ['d', 'Terceiro dia'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Humanos coroam a criação terrestre.',
          wrong: {
            b: 'Primeiro dia traz luz.',
            c: 'Sétimo dia é descanso.',
            d: 'Terceiro dia traz terra seca e vegetação.',
          },
          verseRef: 'Gênesis 1:26–31',
          learningObjective: 'Revisar colocação do humano na semana creativa.',
        },
        {
          question: 'O sétimo dia foi santificado porque Deus descansou de toda a sua obra.',
          options: [
            ['true', 'Verdadeiro'],
            ['false', 'Falso'],
          ],
          correct: 'true',
          ok: 'Correto. Shabat coroa módulo criação.',
          wrong: {
            false: 'Gênesis 2:2–3 afirma descanso e santificação.',
          },
          verseRef: 'Gênesis 2:3',
          type: 'true_false',
          learningObjective: 'Revisar teologia do sétimo dia.',
        },
      ],
      caminhada: [
        {
          question: 'Qual tema une Gênesis 1:1–2:3 como um bloco?',
          options: [
            ['a', 'Deus traz ordem boa ao caos e institui ritmo de descanso'],
            ['b', 'Humanos criam a si mesmos sem Deus'],
            ['c', 'Criação é má e deve ser abandonada'],
            ['d', 'Shabat cancela valor do trabalho'],
          ],
          correct: 'a',
          ok: 'Perfeito. Cosmos ordenado culmina em repouso santificado.',
          wrong: {
            b: 'Deus cria e avalia.',
            c: 'Refrão "era bom" domina.',
            d: 'Seis dias permanecem bons.',
          },
          verseRef: 'Gênesis 1–2',
          learningObjective: 'Sintetizar teologia do módulo criação.',
        },
        {
          question: 'Como imagem de Deus e mandato de domínio se relacionam?',
          options: [
            ['a', 'Representação divina implica governar a criação com responsabilidade'],
            ['b', 'Imagem autoriza tirania sobre outros humanos'],
            ['c', 'Domínio elimina necessidade de descanso'],
            ['d', 'São temas sem conexão no capítulo 1'],
          ],
          correct: 'a',
          ok: 'Exato. Vocacao humana reflete governança de Deus.',
          wrong: {
            b: 'Imagem inclui homem e mulher igualmente.',
            c: 'Shabat integra ritmo humano.',
            d: '1:26–28 os une explicitamente.',
          },
          verseRef: 'Gênesis 1:26–28',
          learningObjective: 'Relacionar imago Dei e domínio responsável.',
        },
        {
          question: 'Por que Gênesis 1 e 2 são complementares, não contraditórios?',
          options: [
            ['a', 'Capítulo 1 apresenta panorama; capítulo 2 aprofunda vocação edénica'],
            ['b', 'Capítulo 2 nega criação por palavra'],
            ['c', 'Apenas um pode ser considerado canônico'],
            ['d', 'Capítulo 2 elimina Shabat'],
          ],
          correct: 'a',
          ok: 'Correto. Perspectivas distintas, mesma teologia.',
          wrong: {
            b: 'Deus fala também em Gênesis 2.',
            c: 'Tradição recebe ambos.',
            d: 'Shabat encerra capítulo 1/2:1–3.',
          },
          verseRef: 'Gênesis 1–2',
          learningObjective: 'Integrar leitura de Gênesis 1 e 2.',
        },
      ],
      profundezas: [
        {
          question: 'O que o módulo criação ensina sobre identidade humana?',
          options: [
            ['a', 'Somos criados bons, com dignidade, vocação e limite rítmico'],
            ['b', 'Valor humano depende de produtividade infinita'],
            ['c', 'Corpo e matéria são malditos por natureza'],
            ['d', 'Humanos existem à margem do plano de Deus'],
          ],
          correct: 'a',
          ok: 'Excelente. Síntese fiel de Gênesis 1–2.',
          wrong: {
            b: 'Shabat limita produção como ideal.',
            c: 'Criação material é boa.',
            d: 'Humanos ocupam lugar central no relato.',
          },
          verseRef: 'Gênesis 1–2',
          skill: 'interpret',
          learningObjective: 'Sintetizar antropologia de Gênesis 1–2.',
        },
        {
          question: 'Como este módulo prepara leitor para queda e resto de Gênesis?',
          options: [
            ['a', 'Estabelece ordem e vocação que serão perturbadas, mas não apagadas'],
            ['b', 'Mostra que pecado era plano divino desde o princípio'],
            ['c', 'Prova que Deus abandona criação após capítulo 2'],
            ['d', 'Elimina esperança de restauração futura'],
          ],
          correct: 'a',
          ok: 'Correto. Bondade original ecoa nas promessas posteriores.',
          wrong: {
            b: 'Queda é ruptura, não plano.',
            c: 'Deus continua buscando humanos.',
            d: '3:15 e 12:1–3 abrem esperança.',
          },
          verseRef: 'Gênesis 1–3',
          skill: 'connect',
          learningObjective: 'Conectar criação com narrativa seguinte.',
        },
      ],
    }),

    ...pack('gen-boss-02', {
      semente: [
        {
          question: 'Qual árvore estava no meio do jardim além da árvore da vida?',
          options: [
            ['a', 'Árvore do conhecimento do bem e do mal'],
            ['b', 'Árvore dos reis de Israel'],
            ['c', 'Árvore do dilúvio'],
            ['d', 'Árvore de Babel'],
          ],
          correct: 'a',
          ok: 'Correto. Proibição centraliza tentação.',
          wrong: {
            b: 'Reis aparecem muito depois.',
            c: 'Dilúvio não envolve árvore específica.',
            d: 'Babel é torre, não árvore.',
          },
          verseRef: 'Gênesis 2:9',
          learningObjective: 'Revisar árvores simbólicas do Éden.',
        },
        {
          question: 'Quem ofereceu fruto proibido a Adão?',
          options: [
            ['a', 'Eva'],
            ['b', 'Lilith'],
            ['c', 'Um anjo desconhecido'],
            ['d', 'Noé'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Ambos comem e são abordados.',
          wrong: {
            b: 'Nome não aparece em Gênesis.',
            c: 'Serpente tenta Eva; Eva dá a Adão.',
            d: 'Noé é posterior.',
          },
          verseRef: 'Gênesis 3:6',
          learningObjective: 'Revisar participação na desobediência.',
        },
        {
          question: 'Que marca Deus colocou em Caim após o fratricídio?',
          options: [
            ['a', 'Um sinal de proteção'],
            ['b', 'Coroa real'],
            ['c', 'Arco-íris na testa'],
            ['d', 'Nenhuma consequência'],
          ],
          correct: 'a',
          ok: 'Correto. Mesmo julgado, Caim recebe limite à vingança.',
          wrong: {
            b: 'Não há coroa mencionada.',
            c: 'Arco-íris pertence a Gênesis 9.',
            d: 'Ele vaga como fugitivo marcado.',
          },
          verseRef: 'Gênesis 4:15',
          learningObjective: 'Revisar misericórdia limitada a Caim.',
        },
      ],
      caminhada: [
        {
          question: 'Como queda, juízo e vestimenta em Gênesis 3 se relacionam?',
          options: [
            ['a', 'Deus julga ruptura, mas ainda cobre vergonha e preserva vida'],
            ['b', 'Deus ignora pecado para evitar confronto'],
            ['c', 'Vestir peles prova abandono total'],
            ['d', 'Juízo elimina promessa alguma'],
          ],
          correct: 'a',
          ok: 'Perfeito. Padrão graça/juízo aparece claramente.',
          wrong: {
            b: 'Deus busca, questiona e sentencia.',
            c: 'Cobrir é ato de cuidado.',
            d: '3:15 inclui promessa.',
          },
          verseRef: 'Gênesis 3:8–21',
          learningObjective: 'Sintetizar graça e juízo na queda.',
        },
        {
          question: 'Por que Gênesis 4 expande tema da queda?',
          options: [
            ['a', 'Mostra pecado migrando para violência fraterna e culto distorcido'],
            ['b', 'Apresenta humanidade imediatamente perfeita'],
            ['c', 'Nega conexão com capítulo 3'],
            ['d', 'Substitui promessa de 3:15'],
          ],
          correct: 'a',
          ok: 'Exato. Ira não dominada leva ao sangue.',
          wrong: {
            b: 'Primeiro homicídio ocorre cedo.',
            c: 'Continuidade genealógica e temática é clara.',
            d: 'Promessa permanece em segundo plano.',
          },
          verseRef: 'Gênesis 4:1–16',
          learningObjective: 'Relacionar queda e fratricídio.',
        },
        {
          question: 'O que une Éden, queda e Caim como módulo?',
          options: [
            ['a', 'Comunhão quebrada, responsabilidade evitada e violência crescente'],
            ['b', 'Progresso moral constante da humanidade'],
            ['c', 'Ausência de envolvimento de Deus'],
            ['d', 'Eliminação do trabalho humano'],
          ],
          correct: 'a',
          ok: 'Correto. Arco vai de cuidado a ocultação a crime.',
          wrong: {
            b: 'Texto mostra regressão.',
            c: 'Deus fala em cada etapa.',
            d: 'Trabalho persiste, embora frustrado.',
          },
          verseRef: 'Gênesis 2–4',
          learningObjective: 'Sintetizar módulo jardim/queda.',
        },
      ],
      profundezas: [
        {
          question: 'Como protoevangelium (3:15) orienta leitura de Gênesis 4?',
          options: [
            ['a', 'Conflito com serpente continua nas gerações, mas Deus preserva linhagem'],
            ['b', 'Promessa se cumpre imediatamente em Caim'],
            ['c', '3:15 não tem relação com violência posterior'],
            ['d', 'Serpente vence definitivamente em capítulo 4'],
          ],
          correct: 'a',
          ok: 'Excelente. Sete nasce como continuidade da linhagem.',
          wrong: {
            b: 'Caim é marcado, não redimido ali.',
            c: 'Violência ecoa conflito das descendências.',
            d: 'História aponta além de Caim.',
          },
          verseRef: 'Gênesis 3:15',
          skill: 'interpret',
          learningObjective: 'Interpretar 3:15 à luz de Gênesis 4.',
          evidence: ['Gênesis 3:15', 'Gênesis 4:25–26'],
        },
        {
          question: 'Que lição pastoral o módulo jardim/queda oferece hoje?',
          options: [
            ['a', 'Tentação e culpa não têm a última palavra; Deus busca e promete'],
            ['b', 'Esconder-se de Deus é caminho recomendado'],
            ['c', 'Violência fraterna é indiferente para Deus'],
            ['d', 'Consequências do pecado provam ausência de amor divino'],
          ],
          correct: 'a',
          ok: 'Correto. Busca divina e promessa sustentam esperança.',
          wrong: {
            b: 'Adão/Eva se escondem; Deus chama.',
            c: 'Sangue de Abel clama.',
            d: 'Juízo e graça coexistem.',
          },
          verseRef: 'Gênesis 3–4',
          skill: 'connect',
          learningObjective: 'Aplicar teologia da queda pastoralmente.',
        },
      ],
    }),

    ...pack('gen-boss-final', {
      semente: [
        {
          question: 'Qual evento segue imediatamente genealogia de Noé em Gênesis 11?',
          options: [
            ['a', 'Chamado de Abrão'],
            ['b', 'Construção do tabernáculo'],
            ['c', 'Queda de Jerusalém'],
            ['d', 'Nascimento de Moisés no Nilo'],
          ],
          correct: 'a',
          ok: 'Correto. Capítulo 12 abre nova fase.',
          wrong: {
            b: 'Tabernáculo é Êxodo.',
            c: 'Jerusalém é história real posterior.',
            d: 'Moisés nasce em Êxodo 2.',
          },
          verseRef: 'Gênesis 12:1',
          learningObjective: 'Revisar transição Gênesis 11→12.',
        },
        {
          question: 'Qual sinal Deus deu da aliança pós-diluviana?',
          options: [
            ['a', 'Arco-íris'],
            ['b', 'Circuncisão imediata de Noé'],
            ['c', 'Torre de Babel'],
            ['d', 'Fogo no monte Carmelo'],
          ],
          correct: 'a',
          ok: 'Isso mesmo. Sinal visível de misericórdia.',
          wrong: {
            b: 'Circuncisão aparece com Abraão.',
            c: 'Babel é juízo distinto.',
            d: 'Carmelo é 1 Reis.',
          },
          verseRef: 'Gênesis 9:13',
          learningObjective: 'Revisar sinal da aliança noéica.',
        },
        {
          question: 'Gênesis 1–11 termina com Deus chamando uma família para ser bênção às nações.',
          options: [
            ['true', 'Verdadeiro'],
            ['false', 'Falso'],
          ],
          correct: 'true',
          ok: 'Perfeito. 12:1–3 fecha arco com promessa missionária.',
          wrong: {
            false: 'Promessa abraâmica oferece esperança — não destruição total.',
          },
          verseRef: 'Gênesis 12:3',
          type: 'true_false',
          learningObjective: 'Sintetizar conclusão de Gênesis 1–11.',
        },
      ],
      caminhada: [
        {
          question: 'Qual padrão narrativo percorre Gênesis 1–11?',
          options: [
            ['a', 'Criação boa → ruptura → escalada do mal → juízo → promessa'],
            ['b', 'Caos permanente sem ação divina'],
            ['c', 'Progresso humano linear sem pecado'],
            ['d', 'Deus ausente após capítulo 2'],
          ],
          correct: 'a',
          ok: 'Exato. Repetição educa leitor sobre pecado e graça.',
          wrong: {
            b: 'Deus fala, julga e promete repetidamente.',
            c: 'Queda, Caim, dilúvio e Babel mostram regressão.',
            d: 'Deus permanece protagonista.',
          },
          verseRef: 'Gênesis 1–11',
          learningObjective: 'Mapear arco narrativo de Gênesis 1–11.',
        },
        {
          question: 'Como dilúvio e Babel funcionam como respostas divinas semelhantes?',
          options: [
            ['a', 'Ambos julgam orgulho/corrupção, mas preservam futuro promissório'],
            ['b', 'Ambos eliminam plano de salvação'],
            ['c', 'Nenhum envolve linguagem de juízo'],
            ['d', 'Somente Babel inclui misericórdia'],
          ],
          correct: 'a',
          ok: 'Perfeito. Juízo limitado abre espaço para aliança/chamado.',
          wrong: {
            b: 'Arca e Abraão continuam história.',
            c: 'Juízo explícito nos dois.',
            d: 'Dilúvio inclui aliança com arco.',
          },
          verseRef: 'Gênesis 6–11',
          learningObjective: 'Comparar juízos do dilúvio e Babel.',
        },
        {
          question: 'Por que Abraão é resposta adequada à crise de Babel?',
          options: [
            ['a', 'Família separada recebe bênção para re-unir humanidade espiritualmente'],
            ['b', 'Repete centralização da torre em Canaã'],
            ['c', 'Rejeita missão com outras nações'],
            ['d', 'Fundamenta império por espada imediatamente'],
          ],
          correct: 'a',
          ok: 'Correto. Bênção universal através de uma linhagem.',
          wrong: {
            b: 'Abraão confia na palavra, não edifica torre.',
            c: '12:3 inclui todas famílias.',
            d: 'Conquista Canaã é processo longo.',
          },
          verseRef: 'Gênesis 12:1–3',
          learningObjective: 'Relacionar Abraão com crise de Babel.',
        },
        {
          question: 'Como Gênesis 1–11 prepara tema de aliança em Gênesis 12+?',
          options: [
            ['a', 'Mostra necessidade de promessa estável após repetidas rupturas'],
            ['b', 'Prova que aliança substitui criação'],
            ['c', 'Elimina relevância de descendência'],
            ['d', 'Encerra interesse de Deus no mundo'],
          ],
          correct: 'a',
          ok: 'Exato. Aliança abraâmica responde história de queda.',
          wrong: {
            b: 'Mesmo Deus criador promete.',
            c: 'Descendência é eixo central.',
            d: 'Deus continua envolvido.',
          },
          verseRef: 'Gênesis 1–12',
          learningObjective: 'Conectar primeiros capítulos com aliança patriarcal.',
        },
      ],
      profundezas: [
        {
          question: 'Qual teologia de Deus emerge de Gênesis 1–11?',
          options: [
            ['a', 'Criador soberano, juiz justo e prometedor fiel'],
            ['b', 'Deus distante que abandona criação'],
            ['c', 'Força impessoal sem palavra ou aliança'],
            ['d', 'Deus competidor igual à serpente'],
          ],
          correct: 'a',
          ok: 'Excelente. Tríplice retrato percorre o arco.',
          wrong: {
            b: 'Deus busca, veste, salva e chama.',
            c: 'Palavra e aliança são centrais.',
            d: 'Monoteísmo permeia todo relato.',
          },
          verseRef: 'Gênesis 1–11',
          skill: 'interpret',
          learningObjective: 'Sintetizar doutrina de Deus em Gênesis 1–11.',
        },
        {
          question: 'Como Gênesis 1–11 informa expectativa messiânica cristã?',
          options: [
            ['a', 'Promessas de 3:15 e 12:3 apontam vitória sobre mal e bênção universal'],
            ['b', 'Nada em 1–11 prepara Cristo'],
            ['c', 'Somente Babel fala de salvação'],
            ['d', 'Protoevangelium nega descendência da mulher'],
          ],
          correct: 'a',
          ok: 'Correto. Semente da mulher e bênção às nações ecoam no NT.',
          wrong: {
            b: 'Tradição cristã lê continuidade promissória.',
            c: '3:15 e 12:3 são centrais.',
            d: '3:15 menciona descendência da mulher.',
          },
          verseRef: 'Gênesis 3:15',
          skill: 'connect',
          learningObjective: 'Conectar Gênesis 1–11 com esperança messiânica.',
          evidence: ['Gênesis 3:15', 'Gênesis 12:3'],
        },
        {
          question: 'Que convite prático Gênesis 1–11 oferece ao leitor hoje?',
          options: [
            ['a', 'Confiar no Deus que cria, julga com justiça e promete restauração'],
            ['b', 'Buscar autonomia total como em Babel'],
            ['c', 'Tratar pecado como irrelevante'],
            ['d', 'Rejeitar descanso e limites rítmicos'],
          ],
          correct: 'a',
          ok: 'Perfeito. Arco convida a fé, responsabilidade e esperança.',
          wrong: {
            b: 'Babel é advertência, não modelo.',
            c: 'Pecado tem consequências reais.',
            d: 'Shabat integra vida saudável.',
          },
          verseRef: 'Gênesis 1–12',
          skill: 'connect',
          learningObjective: 'Aplicar teologia de Gênesis 1–11 hoje.',
        },
      ],
    }),
  ];
}
