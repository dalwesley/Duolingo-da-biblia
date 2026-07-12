export type SeedQuestion = {
  question: string;
  options: { id: string; text: string }[];
  correctOptionId: string;
  feedbackCorrect: string;
  feedbackWrong: Record<string, string>;
  verseRef?: string;
};

export type SeedMission = {
  slug: string;
  title: string;
  intro: string;
  type: "lesson" | "boss";
  xpReward: number;
  questions: SeedQuestion[];
};

export type SeedModule = {
  title: string;
  icon: string;
  missions: SeedMission[];
};

export const genesisTrail = {
  slug: "genesis-1-11",
  title: "Gênesis 1–11",
  description: "Da Criação ao chamado de Abraão — sua jornada pela Palavra.",
  icon: "📖",
  modules: [
    {
      title: "A Criação",
      icon: "🌍",
      missions: [
        {
          slug: "gen-01-criador",
          title: "Quem criou o mundo?",
          intro:
            "Gênesis 1 abre com uma declaração poderosa: Deus é o Criador de tudo. Antes de qualquer coisa existir, Deus já era. Vamos começar por aqui.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Segundo Gênesis 1:1, quem criou os céus e a terra?",
              options: [
                { id: "a", text: "Deus" },
                { id: "b", text: "Os anjos" },
                { id: "c", text: "O homem" },
                { id: "d", text: "O acaso" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! 'No princípio, Deus criou os céus e a terra.' A Bíblia começa afirmando que tudo tem origem em Deus.",
              feedbackWrong: {
                b: "Os anjos são criaturas de Deus, não o Criador.",
                c: "O homem foi criado no sexto dia — muito depois do início.",
                d: "Gênesis afirma claramente que a origem é Deus, não o acaso.",
              },
              verseRef: "Gênesis 1:1",
            },
            {
              question: "No princípio da criação, como era a terra?",
              options: [
                { id: "a", text: "Sem forma e vazia" },
                { id: "b", text: "Perfeita e habitada" },
                { id: "c", text: "Coberta de florestas" },
                { id: "d", text: "Já com montanhas e rios" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto! A terra estava 'sem forma e vazia' — Deus iria dar forma e propósito a tudo.",
              feedbackWrong: {
                b: "Ainda não havia ordem completa; Deus organizaria tudo nos dias seguintes.",
                c: "A vegetação só foi criada no terceiro dia.",
                d: "Montanhas e rios fazem parte da organização posterior da criação.",
              },
              verseRef: "Gênesis 1:2",
            },
            {
              question: "O que pairava sobre as águas no início?",
              options: [
                { id: "a", text: "O Espírito de Deus" },
                { id: "b", text: "As nuvens" },
                { id: "c", text: "O sol" },
                { id: "d", text: "Os pássaros" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! O Espírito de Deus pairava sobre as águas — mostrando que Deus estava presente e ativo na criação.",
              feedbackWrong: {
                b: "Nuvens não são mencionadas neste momento inicial.",
                c: "O sol foi criado no quarto dia.",
                d: "Os pássaros foram criados no quinto dia.",
              },
              verseRef: "Gênesis 1:2",
            },
          ],
        },
        {
          slug: "gen-02-dias",
          title: "Os dias da criação",
          intro:
            "Deus criou o mundo em seis dias, cada um com um propósito. Observe a ordem: primeiro os ambientes, depois os habitantes.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "O que Deus criou no primeiro dia?",
              options: [
                { id: "a", text: "A luz" },
                { id: "b", text: "O sol" },
                { id: "c", text: "As plantas" },
                { id: "d", text: "Os peixes" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Certo! Deus criou a luz e separou a luz das trevas, chamando à luz 'dia' e às trevas 'noite'.",
              feedbackWrong: {
                b: "O sol foi criado no quarto dia — a luz veio antes.",
                c: "As plantas foram criadas no terceiro dia.",
                d: "Os peixes foram criados no quinto dia.",
              },
              verseRef: "Gênesis 1:3-5",
            },
            {
              question: "O que Deus criou para encher os mares?",
              options: [
                { id: "a", text: "Peixes e seres marinhos" },
                { id: "b", text: "Apenas plantas aquáticas" },
                { id: "c", text: "O sol e a lua" },
                { id: "d", text: "O homem" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Deus criou os peixes e tudo o que se move nas águas — os mares se encheram de vida.",
              feedbackWrong: {
                b: "Plantas aquáticas fazem parte da criação, mas os peixes foram criados no quinto dia.",
                c: "Luminares foram criados no quarto dia.",
                d: "O homem foi criado no sexto dia.",
              },
              verseRef: "Gênesis 1:20-21",
            },
            {
              options: [
                { id: "a", text: "Sexto dia" },
                { id: "b", text: "Primeiro dia" },
                { id: "c", text: "Terceiro dia" },
                { id: "d", text: "Quinto dia" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Perfeito! O ser humano é a coroa da criação — criado no sexto dia, à imagem de Deus.",
              feedbackWrong: {
                b: "No primeiro dia foi criada apenas a luz.",
                c: "No terceiro dia: terra seca e vegetação.",
                d: "No quinto dia: peixes e aves.",
              },
              verseRef: "Gênesis 1:26-27",
            },
            {
              question: "Como Deus avaliou Sua criação ao final de cada dia?",
              options: [
                { id: "a", text: "Era bom" },
                { id: "b", text: "Era perfeito demais" },
                { id: "c", text: "Precisava melhorar" },
                { id: "d", text: "Era incompleto" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Repetidamente Deus vê que Sua criação 'era boa' — tudo feito com sabedoria e propósito.",
              feedbackWrong: {
                b: "A expressão bíblica é 'era bom', não 'perfeito demais'.",
                c: "Deus não precisou corrigir — cada etapa foi boa.",
                d: "A criação seguia o plano de Deus; nada ficou incompleto.",
              },
              verseRef: "Gênesis 1:10",
            },
            {
              question: "O que Deus criou no terceiro dia?",
              options: [
                { id: "a", text: "Terra seca e vegetação" },
                { id: "b", text: "Sol, lua e estrelas" },
                { id: "c", text: "Animais terrestres" },
                { id: "d", text: "Peixes e aves" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto! As águas se ajuntaram, apareceu a terra seca, e Deus fez brotar vegetação.",
              feedbackWrong: {
                b: "Luminares foram criados no quarto dia.",
                c: "Animais terrestres no sexto dia.",
                d: "Peixes e aves no quinto dia.",
              },
              verseRef: "Gênesis 1:9-13",
            },
          ],
        },
        {
          slug: "gen-03-imagem",
          title: "Imagem de Deus",
          intro:
            "De todos os seres criados, apenas o ser humano foi feito à imagem e semelhança de Deus. Isso define nosso valor e propósito.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "De que forma Deus criou o homem?",
              options: [
                { id: "a", text: "À sua imagem e semelhança" },
                { id: "b", text: "À imagem dos anjos" },
                { id: "c", text: "Do pó apenas, sem propósito" },
                { id: "d", text: "Por acaso evolutivo" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! Ser imagem de Deus significa dignidade, capacidade de relacionamento e responsabilidade.",
              feedbackWrong: {
                b: "A Bíblia diz imagem de Deus, não dos anjos.",
                c: "Deus deu propósito claro: dominar e cuidar da criação.",
                d: "Gênesis apresenta criação intencional por Deus.",
              },
              verseRef: "Gênesis 1:26-27",
            },
            {
              question: "Qual mandato Deus deu ao ser humano sobre a criação?",
              options: [
                { id: "a", text: "Dominar e cultivar" },
                { id: "b", text: "Destruir e consumir" },
                { id: "c", text: "Ignorar a natureza" },
                { id: "d", text: "Adorar a criação" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Certo! Dominar aqui significa cuidar com responsabilidade — ser administrador da criação de Deus.",
              feedbackWrong: {
                b: "O mandato é de cuidado, não destruição irresponsável.",
                c: "Deus colocou o homem para cuidar do jardim.",
                d: "Devemos adorar a Deus, não a criação.",
              },
              verseRef: "Gênesis 1:28",
            },
            {
              question: "Como Deus criou o homem e a mulher?",
              options: [
                { id: "a", text: "Homem e mulher os criou" },
                { id: "b", text: "Apenas o homem" },
                { id: "c", text: "Separadamente sem relação" },
                { id: "d", text: "Como rivais" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Ambos foram criados à imagem de Deus — igual dignidade e valor.",
              feedbackWrong: {
                b: "Gênesis 1:27 menciona explicitamente homem e mulher.",
                c: "Eles foram criados para comunhão, não isolamento.",
                d: "A Bíblia apresenta complementaridade, não rivalidade.",
              },
              verseRef: "Gênesis 1:27",
            },
          ],
        },
        {
          slug: "gen-04-descanso",
          title: "O descanso de Deus",
          intro:
            "No sétimo dia, Deus descansou. Não porque estava cansado, mas para estabelecer um ritmo sagrado de trabalho e descanso.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "O que Deus fez no sétimo dia?",
              options: [
                { id: "a", text: "Descansou e santificou o dia" },
                { id: "b", text: "Criou mais animais" },
                { id: "c", text: "Destruiu o que fez" },
                { id: "d", text: "Se ausentou da criação" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto! Deus descansou e abençoou o sétimo dia — modelo para o ritmo humano de vida.",
              feedbackWrong: {
                b: "A criação estava completa em seis dias.",
                c: "Deus viu tudo que fizera e era muito bom.",
                d: "Deus permanece presente; descanso não é abandono.",
              },
              verseRef: "Gênesis 2:2-3",
            },
            {
              question: "Como Deus resumiu a criação ao final do sexto dia?",
              options: [
                { id: "a", text: "Era muito bom" },
                { id: "b", text: "Era aceitável" },
                { id: "c", text: "Precisava de ajustes" },
                { id: "d", text: "Era incompleta" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! 'Era muito bom' — a criação reflete a perfeição do Criador.",
              feedbackWrong: {
                b: "A avaliação de Deus foi mais forte: 'muito bom'.",
                c: "Nada precisou ser corrigido.",
                d: "Tudo estava completo conforme o plano de Deus.",
              },
              verseRef: "Gênesis 1:31",
            },
          ],
        },
        {
          slug: "gen-boss-01",
          title: "Desafio: A Criação",
          intro: "Hora de provar o que aprendeu sobre a Criação. Respire fundo — você consegue!",
          type: "boss",
          xpReward: 100,
          questions: [
            {
              question: "Qual a ordem correta dos primeiros três dias?",
              options: [
                { id: "a", text: "Luz → Firmamento → Terra seca e plantas" },
                { id: "b", text: "Sol → Lua → Estrelas" },
                { id: "c", text: "Animais → Homem → Plantas" },
                { id: "d", text: "Água → Fogo → Ar" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Excelente! Você entendeu a ordem da criação nos primeiros dias.",
              feedbackWrong: {
                b: "Sol e lua foram criados no quarto dia.",
                c: "Animais e homem vieram depois.",
                d: "Fogo não é mencionado como elemento criado nesses dias.",
              },
              verseRef: "Gênesis 1",
            },
            {
              question: "Por que o ser humano é especial na criação?",
              options: [
                { id: "a", text: "Foi feito à imagem de Deus" },
                { id: "b", text: "É o mais forte animal" },
                { id: "c", text: "Foi criado primeiro" },
                { id: "d", text: "Não precisa de Deus" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Perfeito! A imagem de Deus é o que nos torna únicos.",
              feedbackWrong: {
                b: "Nossa singularidade é teológica, não apenas física.",
                c: "O homem foi criado no sexto dia.",
                d: "Dependemos de Deus para vida e propósito.",
              },
              verseRef: "Gênesis 1:27",
            },
            {
              question: "O que significa Deus 'descansar' no sétimo dia?",
              options: [
                { id: "a", text: "Completar e santificar o ritmo da criação" },
                { id: "b", text: "Estar exausto" },
                { id: "c", text: "Abandonar o mundo" },
                { id: "d", text: "Arrepender-se da criação" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Muito bem! Descanso aqui é celebração e modelo para nós.",
              feedbackWrong: {
                b: "Deus não se cansa como nós (Is 40:28).",
                c: "Deus continua sustentando tudo.",
                d: "Deus viu que tudo era muito bom.",
              },
              verseRef: "Gênesis 2:2-3",
            },
          ],
        },
      ],
    },
    {
      title: "O Jardim",
      icon: "🌿",
      missions: [
        {
          slug: "gen-05-eden",
          title: "O Éden",
          intro:
            "Gênesis 2 dá zoom no sexto dia: Deus planta um jardim e coloca o homem lá para cultivar e guardar.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Como se chamava o jardim onde Deus colocou o homem?",
              options: [
                { id: "a", text: "Éden" },
                { id: "b", text: "Sião" },
                { id: "c", text: "Jerusalém" },
                { id: "d", text: "Babilônia" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Sim! O Éden era um lugar de comunhão perfeita com Deus.",
              feedbackWrong: {
                b: "Sião é associado a Jerusalém, muito depois.",
                c: "Jerusalém surge bem mais tarde na história bíblica.",
                d: "Babilônia aparece em Gênesis 11.",
              },
              verseRef: "Gênesis 2:8",
            },
            {
              question: "De que Deus formou o homem?",
              options: [
                { id: "a", text: "Pó da terra" },
                { id: "b", text: "Luz pura" },
                { id: "c", text: "Água do mar" },
                { id: "d", text: "Fogo do céu" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto! Deus formou o homem do pó e soprou nele o fôlego de vida.",
              feedbackWrong: {
                b: "O homem é formado da terra, mostrando humildade de origem.",
                c: "Não é água do mar, mas pó da terra.",
                d: "Fogo não é mencionado na formação do homem.",
              },
              verseRef: "Gênesis 2:7",
            },
            {
              question: "Qual era o trabalho do homem no jardim?",
              options: [
                { id: "a", text: "Cultivar e guardar" },
                { id: "b", text: "Dormir o dia todo" },
                { id: "c", text: "Destruir as árvores" },
                { id: "d", text: "Sair e explorar o deserto" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! Trabalho e cuidado faziam parte do plano de Deus desde o início.",
              feedbackWrong: {
                b: "O homem tinha responsabilidade no jardim.",
                c: "Era para cuidar, não destruir.",
                d: "O foco era o jardim que Deus plantou.",
              },
              verseRef: "Gênesis 2:15",
            },
          ],
        },
        {
          slug: "gen-06-queda",
          title: "A desobediência",
          intro:
            "A serpente tenta Eva, e a desobediência entra no mundo. Um momento que muda toda a história humana.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Que árvore estava proibida no meio do jardim?",
              options: [
                { id: "a", text: "Árvore do conhecimento do bem e do mal" },
                { id: "b", text: "Árvore da vida" },
                { id: "c", text: "Árvore de figos" },
                { id: "d", text: "Árvore de oliveiras" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Certo! Comer dela traria consequências graves — era o limite dado por Deus.",
              feedbackWrong: {
                b: "A árvore da vida existia, mas a proibição era outra.",
                c: "Figos aparecem depois, na narrativa.",
                d: "Oliveiras não são o foco desta proibição.",
              },
              verseRef: "Gênesis 2:17",
            },
            {
              question: "Quem a serpente tentou primeiro?",
              options: [
                { id: "a", text: "A mulher (Eva)" },
                { id: "b", text: "Adão diretamente" },
                { id: "c", text: "Um anjo" },
                { id: "d", text: "Ninguém" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim. A serpente enganou Eva questionando a palavra de Deus.",
              feedbackWrong: {
                b: "Adão também comeu, mas a tentação começou com Eva.",
                c: "A narrativa foca na serpente e nos humanos.",
                d: "Houve tentação clara no jardim.",
              },
              verseRef: "Gênesis 3:1-6",
            },
            {
              question: "O que a serpente disse que contradizia Deus?",
              options: [
                { id: "a", text: "Certamente não morrerão" },
                { id: "b", text: "Deus os ama demais" },
                { id: "c", text: "O fruto é venenoso" },
                { id: "d", text: "Vocês devem jejuar" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! A serpente negou a consequência que Deus havia anunciado.",
              feedbackWrong: {
                b: "O amor de Deus não foi o argumento da serpente.",
                c: "O problema foi desobediência, não veneno.",
                d: "Jejum não aparece nesta cena.",
              },
              verseRef: "Gênesis 3:4",
            },
          ],
        },
        {
          slug: "gen-07-consequencias",
          title: "As consequências",
          intro:
            "A desobediência traz consequências: culpa, vergonha, expulsão — mas também a primeira promessa de redenção.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "O que Adão e Eva sentiram após desobedecer?",
              options: [
                { id: "a", text: "Vergonha e medo" },
                { id: "b", text: "Alegria imediata" },
                { id: "c", text: "Indiferença total" },
                { id: "d", text: "Poder ilimitado" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto. Eles se esconderam de Deus — o pecado quebrou a comunhão.",
              feedbackWrong: {
                b: "O resultado não foi alegria, mas ruptura.",
                c: "Eles reagiram escondendo-se.",
                d: "Não ganharam poder; perderam inocência.",
              },
              verseRef: "Gênesis 3:7-10",
            },
            {
              question: "O que Deus prometeu sobre a descendência da mulher?",
              options: [
                { id: "a", text: "Ela ferirá a cabeça da serpente" },
                { id: "b", text: "Ela reinará sobre os anjos" },
                { id: "c", text: "Nunca terá filhos" },
                { id: "d", text: "Viverá para sempre no Éden" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! O Protoevangelho — primeira promessa de vitória sobre o mal (Gn 3:15).",
              feedbackWrong: {
                b: "A promessa é sobre a serpente, não anjos.",
                c: "A mulher teria descendência.",
                d: "Eles foram expulsos do jardim.",
              },
              verseRef: "Gênesis 3:15",
            },
          ],
        },
        {
          slug: "gen-boss-02",
          title: "Desafio: A Queda",
          intro: "Teste seus conhecimentos sobre o Éden e a Queda. Vamos lá!",
          type: "boss",
          xpReward: 100,
          questions: [
            {
              question: "Qual foi a primeira consequência espiritual do pecado?",
              options: [
                { id: "a", text: "Ruptura na comunhão com Deus" },
                { id: "b", text: "Mais sabedoria imediata" },
                { id: "c", text: "Vida eterna no jardim" },
                { id: "d", text: "Anjos servindo Adão" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Perfeito! O pecado separa — mas Deus já aponta para redenção.",
              feedbackWrong: {
                b: "O conhecimento trouxe culpa, não plenitude.",
                c: "Foram expulsos do Éden.",
                d: "Não é o que a narrativa descreve.",
              },
              verseRef: "Gênesis 3",
            },
            {
              question: "O que Gênesis 3:15 antecipa?",
              options: [
                { id: "a", text: "Vitória futura sobre o mal" },
                { id: "b", text: "Fim da humanidade" },
                { id: "c", text: "Nova criação imediata" },
                { id: "d", text: "Fim da descendência humana" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Excelente! Mesmo no juízo, Deus promete esperança.",
              feedbackWrong: {
                b: "A humanidade continua — com consequências.",
                c: "A nova criação é promessa futura.",
                d: "Haverá descendência da mulher.",
              },
              verseRef: "Gênesis 3:15",
            },
          ],
        },
      ],
    },
    {
      title: "Depois do Éden",
      icon: "⛰️",
      missions: [
        {
          slug: "gen-08-caim",
          title: "Caim e Abel",
          intro:
            "Fora do Éden, o pecado se intensifica. Caim mata Abel — o primeiro assassinato da história.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Por que Caim se irou contra Abel?",
              options: [
                { id: "a", text: "Deus aceitou a oferta de Abel, não a de Caim" },
                { id: "b", text: "Abel roubou seu rebanho" },
                { id: "c", text: "Abel mentiu para Deus" },
                { id: "d", text: "Deus rejeitou Caim sem motivo" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Certo. O coração de Caim estava errado — Deus o alertou antes do crime.",
              feedbackWrong: {
                b: "Não há roubo na narrativa.",
                c: "Abel não é acusado de mentira.",
                d: "Deus explicou o problema do coração de Caim.",
              },
              verseRef: "Gênesis 4:4-7",
            },
            {
              question: "O que Deus fez com Caim após o assassinato?",
              options: [
                { id: "a", text: "O marcou e o enviou errante" },
                { id: "b", text: "O matou imediatamente" },
                { id: "c", text: "O ignorou completamente" },
                { id: "d", text: "O fez rei" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim. Há juízo, mas também misericórdia — Deus protege Caim da vingança.",
              feedbackWrong: {
                b: "Deus não o matou na hora.",
                c: "Deus confrontou e julgou Caim.",
                d: "Caim se tornou errante, não rei.",
              },
              verseRef: "Gênesis 4:15-16",
            },
          ],
        },
        {
          slug: "gen-09-diluvio",
          title: "O dilúvio e Noé",
          intro:
            "A maldade cresce na terra. Deus julga o mundo, mas preserva Noé e sua família — um novo começo.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Por que Deus decidiu enviar o dilúvio?",
              options: [
                { id: "a", text: "A maldade do homem era grande na terra" },
                { id: "b", text: "Queria destruir Noé" },
                { id: "c", text: "A terra estava vazia demais" },
                { id: "d", text: "Os animais dominaram os homens" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto. O coração humano se corrompeu — Deus julga, mas salva os fiéis.",
              feedbackWrong: {
                b: "Noé achou graça aos olhos de Deus.",
                c: "A terra estava cheia de violência.",
                d: "Não é o motivo narrado.",
              },
              verseRef: "Gênesis 6:5-8",
            },
            {
              question: "Como Noé é descrito diante de Deus?",
              options: [
                { id: "a", text: "Homem justo e íntegro" },
                { id: "b", text: "Homem violento" },
                { id: "c", text: "Indiferente a Deus" },
                { id: "d", text: "Rei da terra" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Noé andava com Deus em meio a uma geração corrupta.",
              feedbackWrong: {
                b: "A violência era da geração, não de Noé.",
                c: "Noé obedeceu a Deus fielmente.",
                d: "Noé não era rei.",
              },
              verseRef: "Gênesis 6:9",
            },
            {
              question: "Qual sinal Deus deu da aliança após o dilúvio?",
              options: [
                { id: "a", text: "O arco-íris" },
                { id: "b", text: "O fogo" },
                { id: "c", text: "A estrela da manhã" },
                { id: "d", text: "O trovão" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Perfeito! O arco-íris lembra a promessa de Deus de não destruir a terra com dilúvio.",
              feedbackWrong: {
                b: "Fogo não é o sinal desta aliança.",
                c: "Estrela da manhã não é mencionada aqui.",
                d: "Trovão não é o sinal da aliança.",
              },
              verseRef: "Gênesis 9:13",
            },
          ],
        },
        {
          slug: "gen-10-babel",
          title: "Torre de Babel",
          intro:
            "A humanidade se une para fazer fama a si mesma. Deus confunde as línguas e espalha os povos.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Qual era o objetivo da torre de Babel?",
              options: [
                { id: "a", text: "Fazer um nome e não se espalhar" },
                { id: "b", text: "Adorar a Deus no alto" },
                { id: "c", text: "Salvar-se de outro dilúvio" },
                { id: "d", text: "Estudar as estrelas" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Certo. Era orgulho humano — queriam glória própria, não dependência de Deus.",
              feedbackWrong: {
                b: "O objetivo não era adoração a Deus.",
                c: "Não mencionam dilúvio como motivo.",
                d: "Atorização não é o foco do texto.",
              },
              verseRef: "Gênesis 11:4",
            },
            {
              question: "O que Deus fez em Babel?",
              options: [
                { id: "a", text: "Confundiu a língua deles" },
                { id: "b", text: "Destruiu a torre com fogo" },
                { id: "c", text: "Abençoou o projeto" },
                { id: "d", text: "Ignorou a cidade" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! A diversidade de línguas dispersou os povos conforme o plano de Deus.",
              feedbackWrong: {
                b: "O texto não fala em fogo destruindo a torre.",
                c: "Deus interveio contra o orgulho.",
                d: "Deus agiu diretamente.",
              },
              verseRef: "Gênesis 11:7-9",
            },
          ],
        },
        {
          slug: "gen-11-abraao",
          title: "Chamado de Abraão",
          intro:
            "Gênesis 12 muda o rumo: Deus chama Abrão para uma jornada de fé e promessa — o início da história de Israel.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Para onde Deus chamou Abrão para ir?",
              options: [
                { id: "a", text: "Terra que lhe mostraria" },
                { id: "b", text: "De volta ao Éden" },
                { id: "c", text: "Egito permanentemente" },
                { id: "d", text: "Babilônia" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! Abrão saiu sem saber o destino — fé pura em Deus.",
              feedbackWrong: {
                b: "O Éden não é o destino de Abrão.",
                c: "Egito aparece depois, não como destino inicial.",
                d: "Ele sai de Ur, não vai para Babel.",
              },
              verseRef: "Gênesis 12:1",
            },
            {
              question: "O que Deus prometeu a Abrão?",
              options: [
                { id: "a", text: "Torná-lo grande nação e bênção às famílias" },
                { id: "b", text: "Riqueza imediata sem jornada" },
                { id: "c", text: "Um trono mundial agora" },
                { id: "d", text: "Vida sem provações" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Perfeito! A promessa a Abraão é central para toda a Bíblia.",
              feedbackWrong: {
                b: "A promessa envolve jornada e fé.",
                c: "O trono não é imediato.",
                d: "Abraão enfrentou muitas provações.",
              },
              verseRef: "Gênesis 12:2-3",
            },
          ],
        },
        {
          slug: "gen-boss-final",
          title: "Desafio Final: Gênesis 1–11",
          intro: "Último desafio desta jornada. Mostre tudo que aprendeu!",
          type: "boss",
          xpReward: 150,
          questions: [
            {
              question: "Qual evento marca o início da redenção prometida?",
              options: [
                { id: "a", text: "Gênesis 3:15 — a serpente será ferida" },
                { id: "b", text: "Construção da torre de Babel" },
                { id: "c", text: "Morte de Abel" },
                { id: "d", text: "Criação do sol" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Excelente! A esperança aparece logo após a Queda.",
              feedbackWrong: {
                b: "Babel é juízo e dispersão.",
                c: "Abel é tragédia, não promessa messiânica.",
                d: "O sol é parte da criação.",
              },
              verseRef: "Gênesis 3:15",
            },
            {
              question: "O que conecta Noé e Abraão na narrativa?",
              options: [
                { id: "a", text: "Ambos recebem promessas de Deus em contextos de juízo" },
                { id: "b", text: "Ambos constroem torres" },
                { id: "c", text: "Ambos matam irmãos" },
                { id: "d", text: "Ambos negam Deus" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Muito bem! Deus preserva e promete — padrão que segue na Bíblia.",
              feedbackWrong: {
                b: "Só Babel tem torre.",
                c: "Caim matou Abel, não esses personagens.",
                d: "Ambos são exemplos de fé.",
              },
              verseRef: "Gênesis 6-12",
            },
            {
              question: "Qual é o fio narrativo de Gênesis 1–11?",
              options: [
                { id: "a", text: "Criação → Queda → Juízo → Promessa" },
                { id: "b", text: "Guerras → Reis → Templos" },
                { id: "c", text: "Leis → Profetas → Salmos" },
                { id: "d", text: "Êxodo → Deserto → Canaã" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Perfeito! Você entendeu a grande narrativa. Próximo passo: a história de Abraão!",
              feedbackWrong: {
                b: "Reis vem muito depois.",
                c: "Leis e profetas são fases posteriores.",
                d: "Êxodo é depois de Abraão.",
              },
              verseRef: "Gênesis 1-11",
            },
          ],
        },
      ],
    },
  ] as SeedModule[],
};
