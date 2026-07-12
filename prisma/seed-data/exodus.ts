import type { SeedModule } from "./genesis";

export const exodusTrail = {
  slug: "exodo",
  title: "Êxodo",
  description: "Do Egito à entrega da Lei — a libertação do povo de Deus.",
  icon: "⛰️",
  color: "#0984E3",
  modules: [
    {
      title: "Opressão no Egito",
      icon: "⛓️",
      missions: [
        {
          slug: "exo-01-opressao",
          title: "O povo no Egito",
          intro:
            "Gênesis termina com Israel no Egito. Êxodo começa séculos depois: um novo faraó escraviza o povo. Deus ouve o clamor de Seu povo.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Por que o faraó escravizou os israelitas?",
              options: [
                { id: "a", text: "Porque eram numerosos e ele os temia" },
                { id: "b", text: "Porque roubaram o tesouro do Egito" },
                { id: "c", text: "Porque se recusaram a trabalhar" },
                { id: "d", text: "Porque adoravam outros deuses" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! O faraó disse que o povo era forte demais e temia que se aliasse aos inimigos do Egito.",
              feedbackWrong: {
                b: "Não há registro de roubo do tesouro como motivo da escravidão.",
                c: "O texto diz que os egípcios os oprimiram com trabalhos forçados.",
                d: "A opressão veio do medo político, não diretamente da adoração.",
              },
              verseRef: "Êxodo 1:8-11",
            },
            {
              question: "O que Deus fez quando o povo clamou?",
              options: [
                { id: "a", text: "Ouviu o seu clamor e lembrou da aliança" },
                { id: "b", text: "Permaneceu em silêncio por 400 anos" },
                { id: "c", text: "Enviou anjos para destruir o Egito imediatamente" },
                { id: "d", text: "Mudou o povo de lugar sem libertá-lo" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Deus ouviu, lembrou de Abraão, Isaque e Jacó e conheceu a aflição do povo.",
              feedbackWrong: {
                b: "Deus estava presente e agiu no tempo certo.",
                c: "A libertação veio por meio de Moisés e das pragas, em etapas.",
                d: "Deus interveio para libertar, não apenas relocar.",
              },
              verseRef: "Êxodo 2:23-25",
            },
          ],
        },
        {
          slug: "exo-02-moises",
          title: "O chamado de Moisés",
          intro:
            "Deus chama Moisés na sarça ardente. Ele hesita, mas Deus promete estar com ele.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Onde Deus apareceu a Moisés?",
              options: [
                { id: "a", text: "Na sarça ardente" },
                { id: "b", text: "No monte Sinai" },
                { id: "c", text: "No palácio do faraó" },
                { id: "d", text: "No Mar Vermelho" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto! A sarça ardia mas não se consumia — sinal da presença santa de Deus.",
              feedbackWrong: {
                b: "O Sinai vem depois, na entrega da Lei.",
                c: "Moisés fugiu do palácio anos antes.",
                d: "O Mar Vermelho é cruzado muito depois.",
              },
              verseRef: "Êxodo 3:2",
            },
            {
              question: "Qual nome Deus revela a Moisés?",
              options: [
                { id: "a", text: "EU SOU O QUE SOU" },
                { id: "b", text: "Senhor dos Exércitos" },
                { id: "c", text: "Príncipe da Paz" },
                { id: "d", text: "El Shaddai apenas" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Deus se revela como 'EU SOU' — eterno, fiel, autoexistente.",
              feedbackWrong: {
                b: "Esse título aparece em outros contextos, mas não aqui.",
                c: "Esse é um título messiânico em Isaías.",
                d: "El Shaddai é usado, mas neste momento Deus revela 'EU SOU'.",
              },
              verseRef: "Êxodo 3:14",
            },
          ],
        },
      ],
    },
    {
      title: "A Libertação",
      icon: "🌊",
      missions: [
        {
          slug: "exo-03-pragas",
          title: "As dez pragas",
          intro:
            "Deus envia pragas sobre o Egito para que o faraó liberte Israel. Cada praga mostra o poder de Deus sobre os deuses do Egito.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Qual foi a última praga que convenceu o faraó a deixar o povo ir?",
              options: [
                { id: "a", text: "A morte dos primogênitos" },
                { id: "b", text: "As pragas de gafanhotos" },
                { id: "c", text: "A praga de sangue" },
                { id: "d", text: "A escuridão por três dias" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Correto! A morte dos primogênitos foi a praga final antes da Páscoa e da saída.",
              feedbackWrong: {
                b: "Gafanhotos foram uma praga grave, mas não a última.",
                c: "O Nilo tornou-se sangue foi a primeira praga.",
                d: "A escuridão foi a nona praga.",
              },
              verseRef: "Êxodo 12:29-31",
            },
          ],
        },
        {
          slug: "exo-04-pascoa",
          title: "A Páscoa",
          intro:
            "Deus institui a Páscoa: o sangue do cordeiro no lintel protegeria as casas. É memorial da libertação.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "O que o sangue no lintel simbolizava na Páscoa?",
              options: [
                { id: "a", text: "Proteção contra o anjo da morte" },
                { id: "b", text: "Pagamento de impostos ao faraó" },
                { id: "c", text: "Marca de escravidão" },
                { id: "d", text: "Sinal de vitória militar" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Exato! O sangue era sinal — o Senhor passaria por cima daquela casa.",
              feedbackWrong: {
                b: "Não tinha relação com impostos.",
                c: "Era sinal de libertação, não de escravidão.",
                d: "A vitória viria depois, no Mar Vermelho.",
              },
              verseRef: "Êxodo 12:13",
            },
          ],
        },
        {
          slug: "exo-05-mar",
          title: "O Mar Vermelho",
          intro:
            "O faraó persegue Israel. Deus abre o mar, o povo passa em terra seca e os egípcios são vencidos.",
          type: "lesson",
          xpReward: 50,
          questions: [
            {
              question: "Como Israel atravessou o Mar Vermelho?",
              options: [
                { id: "a", text: "Deus abriu o mar e eles passaram em terra seca" },
                { id: "b", text: "Construíram pontes de madeira" },
                { id: "c", text: "Nadaram durante a noite" },
                { id: "d", text: "O faraó os deixou atravessar de barco" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Sim! Moisés estendeu a mão e o Senhor fez o mar retroceder.",
              feedbackWrong: {
                b: "Não há menção de pontes.",
                c: "O texto fala em terra seca, não natação.",
                d: "O faraó perseguia para destruí-los.",
              },
              verseRef: "Êxodo 14:21-22",
            },
          ],
        },
        {
          slug: "exo-boss-01",
          title: "Desafio: A saída do Egito",
          intro:
            "Hora de provar que você entendeu a grande narrativa da libertação. Este desafio cobre opressão, Moisés, pragas e o Mar Vermelho.",
          type: "boss",
          xpReward: 100,
          questions: [
            {
              question: "Qual é a ordem correta dos eventos?",
              options: [
                { id: "a", text: "Opressão → Moisés → Pragas → Páscoa → Mar Vermelho" },
                { id: "b", text: "Moisés → Opressão → Mar Vermelho → Pragas" },
                { id: "c", text: "Páscoa → Opressão → Moisés → Pragas" },
                { id: "d", text: "Pragas → Mar Vermelho → Moisés → Páscoa" },
              ],
              correctOptionId: "a",
              feedbackCorrect: "Perfeito! Você entendeu a sequência da libertação.",
              feedbackWrong: {
                b: "A opressão veio antes do chamado de Moisés.",
                c: "A Páscoa ocorre após as pragas.",
                d: "Moisés é chamado antes das pragas.",
              },
              verseRef: "Êxodo 1-14",
            },
            {
              question: "O que a Páscoa antecipa na história da redenção?",
              options: [
                { id: "a", text: "O sacrifício substitutivo que protege do juízo" },
                { id: "b", text: "A construção do templo" },
                { id: "c", text: "A queda de Jerusalém" },
                { id: "d", text: "O dilúvio de Noé" },
              ],
              correctOptionId: "a",
              feedbackCorrect:
                "Excelente! O cordeiro pascal aponta para Cristo, nosso cordeiro.",
              feedbackWrong: {
                b: "O templo vem muito depois, no deserto e em Israel.",
                c: "A queda de Jerusalém é evento posterior.",
                d: "O dilúvio é narrativa de Gênesis.",
              },
              verseRef: "Êxodo 12",
            },
          ],
        },
      ],
    },
  ] as const,
};
