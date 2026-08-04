/**
 * Fecha Cena 2 do Sermão: sm-09-perseguidos + sm-boss-02-carater-do-reino
 * Usage: node scripts/build_sermao_cena2_close.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const assets = join(__dirname, '../../trilha_app/assets/data');
const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };

function q(section, diff, n, question, options, correct, ok, wrong, verse) {
  return {
    id: `sermao-do-monte-${SHORT[diff]}-${section}-${String(n).padStart(2, '0')}`,
    trail: 'sermao-do-monte',
    difficulty: diff,
    section,
    question,
    options: options.map(([id, text]) => ({ id, text })),
    correctOptionId: correct,
    feedbackCorrect: ok,
    feedbackWrong: wrong,
    verseRef: verse,
    reveal: null,
  };
}

function pack(section, levels) {
  const out = [];
  for (const [diff, items] of Object.entries(levels)) {
    if (items.length !== 5) throw new Error(`${section}/${diff}: ${items.length}`);
    items.forEach((it, i) => out.push(q(section, diff, i + 1, ...it)));
  }
  return out;
}

const sm09 = {
  slug: 'sm-09-perseguidos',
  title: 'Perseguidos por causa da justiça',
  subtitle: 'Mateus 5:10–12',
  intro:
    'Viver como cidadão do Reino pode gerar oposição. Jesus não esconde isso — e ainda chama de bem-aventurados os que sofrem por causa da justiça. A perseguição não anula a alegria nem a esperança do discípulo.',
  type: 'lesson',
  xpReward: 60,
  questions: [],
};

const boss = {
  slug: 'sm-boss-02-carater-do-reino',
  title: 'Desafio: O Caráter do Reino',
  subtitle: 'Mateus 5:7–12',
  intro:
    'Você chegou ao desafio da Cena 2. Mostre que compreendeu como o cidadão do Reino vive: misericórdia, pureza de coração, paz e fidelidade sob pressão.',
  type: 'boss',
  xpReward: 150,
  questions: [],
};

const study09 = {
  slug: 'sm-09-perseguidos',
  passageRef: 'Mateus 5:10–12',
  passageText:
    'Bem-aventurados os perseguidos por causa da justiça, porque deles é o Reino dos céus. Bem-aventurados sois quando, por minha causa, vos injuriarem, e vos perseguirem, e, mentindo, disserem todo mal contra vós. Regozijai-vos e exultai, porque é grande o vosso galardão nos céus; pois assim perseguiram aos profetas que foram antes de vós.',
  context:
    'As bem-aventuranças terminam com um choque: o caminho do Reino pode custar rejeição. Jesus liga a perseguição à justiça e a si mesmo (“por minha causa”). Não é qualquer sofrimento — é oposição por fidelidade a Deus. A promessa ecoa a dos pobres de espírito: “deles é o Reino”. Os discípulos entram na linhagem dos profetas perseguidos. A alegria não nega a dor; nasce da esperança do galardão e da comunhão com Cristo.',
  keyword: 'Perseguição',
  keywordGloss:
    'Oposição, injúria ou sofrimento enfrentados por causa da fidelidade a Cristo e à justiça do Reino.',
  focusQuestion:
    'Estou disposto a permanecer fiel a Jesus mesmo quando isso me custar aprovação das pessoas?',
  reflectionPrompts: [
    'Fidelidade pode custar aprovação humana',
    'A alegria do discípulo está ancorada no céu',
    'Seguir Jesus é entrar na linhagem dos profetas',
  ],
  relatedVerses: [
    {
      reference: 'João 15:18–20',
      reason: 'Se o mundo odiou a Cristo, também odiará seus discípulos.',
    },
    {
      reference: '2 Timóteo 3:12',
      reason: 'Todos os que querem viver piedosamente em Cristo serão perseguidos.',
    },
    {
      reference: '1 Pedro 4:12–14',
      reason: 'Não estranheis a fornalha — sois bem-aventurados se sofreis por Cristo.',
    },
    {
      reference: 'Atos 5:41',
      reason: 'Os apóstolos se alegravam por serem dignos de sofrer pelo Nome.',
    },
  ],
};

const bank09 = pack('sm-09-perseguidos', {
  semente: [
    [
      'Segundo Jesus, quem é bem-aventurado nesta passagem?',
      [
        ['a', 'Os perseguidos por causa da justiça'],
        ['b', 'Os que nunca sofrem'],
        ['c', 'Os mais populares'],
        ['d', 'Os que evitam qualquer conflito'],
      ],
      'a',
      'Correto! A bem-aventurança é para quem sofre por fidelidade.',
      {
        b: 'Jesus fala de perseguição.',
        c: 'Popularidade não é o critério.',
        d: 'A paz do Reino não é fuga da verdade.',
      },
      'Mateus 5:10',
    ],
    [
      'Qual promessa acompanha os perseguidos por causa da justiça?',
      [
        ['a', 'Deles é o Reino dos céus'],
        ['b', 'Nunca serão criticados'],
        ['c', 'Receberão ouro imediatamente'],
        ['d', 'Governarão Roma'],
      ],
      'a',
      'Exato. A mesma promessa dos pobres de espírito.',
      { b: 'A injúria é mencionada.', c: 'Não é a promessa.', d: 'Não.' },
      'Mateus 5:10',
    ],
    [
      'Jesus diz que seus discípulos são bem-aventurados quando:',
      [
        ['a', 'Os injuriarem e perseguirem por causa Dele'],
        ['b', 'Ficarem ricos'],
        ['c', 'Evangelizarem sem custo'],
        ['d', 'Agradarem a todos'],
      ],
      'a',
      'Perfeito. “Por minha causa”.',
      {
        b: 'Não.',
        c: 'Pode haver custo.',
        d: 'Jesus não promete aprovação universal.',
      },
      'Mateus 5:11',
    ],
    [
      'Qual deve ser a reação do discípulo perseguido?',
      [
        ['a', 'Regozijar-se e exultar'],
        ['b', 'Abandonar a fé'],
        ['c', 'Odiar os perseguidores'],
        ['d', 'Negar a Cristo para se proteger'],
      ],
      'a',
      'Correto. A alegria está no galardão celestial.',
      { b: 'Não.', c: 'O Sermão ensina amor.', d: 'Fidelidade é o chamado.' },
      'Mateus 5:12',
    ],
    [
      'Jesus compara os discípulos perseguidos a quem?',
      [
        ['a', 'Aos profetas que foram antes deles'],
        ['b', 'Aos fariseus'],
        ['c', 'Aos reis de Israel'],
        ['d', 'Aos mercadores'],
      ],
      'a',
      'Muito bem. Eles entram na linhagem dos fiéis.',
      { b: 'Não.', c: 'Não.', d: 'Não.' },
      'Mateus 5:12',
    ],
  ],
  caminhada: [
    [
      'Nem todo sofrimento é essa bem-aventurança. O que a distingue?',
      [
        ['a', 'Sofrer por causa da justiça e por causa de Jesus'],
        ['b', 'Qualquer dor da vida'],
        ['c', 'Sofrer por erros próprios sem arrependimento'],
        ['d', 'Sofrer por ambição política'],
      ],
      'a',
      'Excelente. O motivo importa: justiça e Cristo.',
      {
        b: 'Nem toda dor é perseguição por Cristo.',
        c: 'Consequência do pecado é outra categoria.',
        d: 'Não é o foco do texto.',
      },
      'Mateus 5:10–11',
    ],
    [
      'Por que “deles é o Reino” aparece no início e no fim das bem-aventuranças?',
      [
        ['a', 'Forma um arco: humildade e fidelidade sob pressão pertencem ao Reino'],
        ['b', 'É coincidência literária sem sentido'],
        ['c', 'Só vale para os pobres financeiros'],
        ['d', 'Cancela as bem-aventuranças do meio'],
      ],
      'a',
      'Perfeito. Inclusio literária em Mateus 5.',
      {
        b: 'Mateus é cuidadoso na estrutura.',
        c: 'É espiritual.',
        d: 'Não.',
      },
      'Mateus 5:3,10',
    ],
    [
      '“Por minha causa” significa principalmente:',
      [
        ['a', 'Oposição por lealdade a Jesus'],
        ['b', 'Sofrer por ser antipático'],
        ['c', 'Sofrer por falta de sabedoria'],
        ['d', 'Sofrer por tradição familiar'],
      ],
      'a',
      'Isso. A identidade cristã é o eixo.',
      {
        b: 'Caráter difícil não é martírio.',
        c: 'Imprudência não é a bem-aventurança.',
        d: 'Não necessariamente.',
      },
      'Mateus 5:11',
    ],
    [
      'Qual vínculo existe entre esta bem-aventurança e os profetas?',
      [
        ['a', 'O povo de Deus historicamente sofreu por falar a verdade'],
        ['b', 'Os profetas nunca sofreram'],
        ['c', 'Profetas eram sempre populares'],
        ['d', 'Jesus rejeita os profetas'],
      ],
      'a',
      'Muito bem.',
      {
        b: 'Muitos foram perseguidos.',
        c: 'Frequentemente rejeitados.',
        d: 'Ele os valida.',
      },
      'Mateus 5:12',
    ],
    [
      'A injúria “mentindo” destaca o quê?',
      [
        ['a', 'Calúnia e falsidade contra o discípulo'],
        ['b', 'Crítica justa sempre é perseguição'],
        ['c', 'Todo feedback é ataque satânico'],
        ['d', 'Discípulo nunca erra'],
      ],
      'a',
      'Correto. Jesus menciona mentira deliberada.',
      {
        b: 'Correção verdadeira pode ser graça.',
        c: 'Discernimento importa.',
        d: 'Todos pecam.',
      },
      'Mateus 5:11',
    ],
  ],
  profundezas: [
    [
      'Estou disposto a permanecer fiel a Jesus mesmo quando isso me custar aprovação?',
      [
        ['a', 'Sim — a fidelidade vale mais que a popularidade'],
        ['b', 'Não — aprovação humana vem primeiro'],
        ['c', 'Só se não houver nenhum custo'],
        ['d', 'Só na igreja, nunca no trabalho'],
      ],
      'a',
      'Isso. Cidadania do Reino tem preço.',
      {
        b: 'Jesus inverte essa lógica.',
        c: 'Ele prepara para o custo.',
        d: 'A fé cobre toda a vida.',
      },
      'Mateus 5:10–12',
    ],
    [
      'Como João 15:18–20 aprofunda este ensino?',
      [
        ['a', 'O discípulo não deve estranhar o ódio do mundo a Cristo'],
        ['b', 'O mundo sempre amará a igreja'],
        ['c', 'Jesus promete ausência de conflito'],
        ['d', 'Só os apóstolos sofreriam'],
      ],
      'a',
      'Excelente.',
      { b: 'Jesus prevê oposição.', c: 'Não.', d: 'O padrão se estende.' },
      'João 15:18–20',
    ],
    [
      'Segundo 2 Timóteo 3:12, a piedade em Cristo tende a gerar:',
      [
        ['a', 'Perseguição'],
        ['b', 'Sucesso garantido'],
        ['c', 'Isenção de sofrimento'],
        ['d', 'Poder político automático'],
      ],
      'a',
      'Correto.',
      { b: 'Não é a promessa.', c: 'Não.', d: 'Não.' },
      '2 Timóteo 3:12',
    ],
    [
      'Como os apóstolos em Atos 5:41 reagiram ao sofrer pelo Nome?',
      [
        ['a', 'Alegraram-se por serem dignos disso'],
        ['b', 'Abandonaram a missão'],
        ['c', 'Pediram vingança imediata'],
        ['d', 'Negaram conhecer Jesus'],
      ],
      'a',
      'Perfeito. Alegria ancorada no céu.',
      { b: 'Eles perseveraram.', c: 'Não.', d: 'Não.' },
      'Atos 5:41',
    ],
    [
      'Qual resposta cristã a uma calúnia no trabalho ou na família?',
      [
        ['a', 'Permanecer íntegro, sem retribuir o mal, confiando em Deus'],
        ['b', 'Revidar com a mesma mentira'],
        ['c', 'Esconder a fé para sempre'],
        ['d', 'Odiar quem caluniou'],
      ],
      'a',
      'Muito bem. Mansidão + fidelidade.',
      {
        b: 'Mal não cura mal.',
        c: 'Testemunho importa.',
        d: 'O Sermão ensina amor ao inimigo.',
      },
      'Mateus 5:11–12',
    ],
  ],
});

const bankBoss = pack('sm-boss-02-carater-do-reino', {
  semente: [
    [
      'Qual bem-aventurança promete que alcançarão misericórdia?',
      [
        ['a', 'Os misericordiosos'],
        ['b', 'Os mansos'],
        ['c', 'Os ricos'],
        ['d', 'Os populares'],
      ],
      'a',
      'Correto.',
      { b: 'Mansos herdam a terra.', c: 'Não.', d: 'Não.' },
      'Mateus 5:7',
    ],
    [
      'Quem verá a Deus, segundo Jesus?',
      [
        ['a', 'Os limpos de coração'],
        ['b', 'Os mais inteligentes'],
        ['c', 'Os sacerdotes apenas'],
        ['d', 'Os que nunca sofrem'],
      ],
      'a',
      'Exato.',
      { b: 'Não.', c: 'Acesso ampliado no Reino.', d: 'Não.' },
      'Mateus 5:8',
    ],
    [
      'Quem será chamado filho de Deus nesta cena?',
      [
        ['a', 'Os pacificadores'],
        ['b', 'Os violentos'],
        ['c', 'Os neutros em tudo'],
        ['d', 'Os que evitam a verdade'],
      ],
      'a',
      'Correto.',
      { b: 'Não.', c: 'Paz não é neutralidade.', d: 'Paz com verdade.' },
      'Mateus 5:9',
    ],
    [
      'Os perseguidos por causa da justiça recebem qual promessa?',
      [
        ['a', 'Deles é o Reino dos céus'],
        ['b', 'Nunca serão criticados'],
        ['c', 'Riqueza imediata'],
        ['d', 'Fama religiosa'],
      ],
      'a',
      'Perfeito.',
      { b: 'Podem ser injuriados.', c: 'Não.', d: 'Não.' },
      'Mateus 5:10',
    ],
    [
      'Qual sequência resume a Cena 2?',
      [
        ['a', 'Misericordiosos → Limpos de coração → Pacificadores → Perseguidos'],
        ['b', 'Pobres de espírito → Mansos → Rico → Popular'],
        ['c', 'Pacificadores → Pobres → Reis → Fariseus'],
        ['d', 'Perseguidos → Misericordiosos → Mansos → Criação'],
      ],
      'a',
      'Excelente.',
      { b: 'Mistura cenas.', c: 'Não.', d: 'Não.' },
      'Mateus 5:7–12',
    ],
  ],
  caminhada: [
    [
      'O que as bem-aventuranças da Cena 2 enfatizam em conjunto?',
      [
        ['a', 'Como o discípulo se relaciona com Deus e com o próximo'],
        ['b', 'Apenas prosperidade material'],
        ['c', 'Estratégias de guerra'],
        ['d', 'Genealogias'],
      ],
      'a',
      'Muito bem. Do interior ao relacionamento e ao custo.',
      { b: 'Não.', c: 'Não.', d: 'Não.' },
      'Mateus 5:7–12',
    ],
    [
      'Qual elo une misericórdia e pureza de coração?',
      [
        ['a', 'Um coração transformado age com graça e sinceridade'],
        ['b', 'Ambas exigem riqueza'],
        ['c', 'Ambas rejeitam a Escritura'],
        ['d', 'Ambas são só rituais'],
      ],
      'a',
      'Isso.',
      { b: 'Não.', c: 'Não.', d: 'Não.' },
      'Mateus 5:7–8',
    ],
    [
      'Por que pacificadores são chamados filhos de Deus?',
      [
        ['a', 'Porque refletem o caráter do Pai que reconcilia'],
        ['b', 'Porque evitam toda conversa'],
        ['c', 'Porque concordam com o pecado'],
        ['d', 'Porque dominam pela força'],
      ],
      'a',
      'Perfeito.',
      { b: 'Paz exige coragem.', c: 'Não.', d: 'Contrário a Jesus.' },
      'Mateus 5:9',
    ],
    [
      'Qual diferença entre paz do Reino e mera ausência de conflito?',
      [
        ['a', 'Shalom é restauração na verdade; silêncio omisso não é paz'],
        ['b', 'São a mesma coisa'],
        ['c', 'Paz bíblica é só política romana'],
        ['d', 'Paz dispensa Cristo'],
      ],
      'a',
      'Excelente.',
      { b: 'Não.', c: 'Pax Romana contrastava.', d: 'Cristo é o Pacificador.' },
      'Mateus 5:9',
    ],
    [
      'A perseguição “por causa da justiça” e “por minha causa” ensinam que:',
      [
        ['a', 'Fidelidade a Cristo e à retidão pode gerar oposição'],
        ['b', 'Crentes nunca sofrem'],
        ['c', 'Todo sofrimento é castigo'],
        ['d', 'Popularidade prova fidelidade'],
      ],
      'a',
      'Correto.',
      { b: 'Jesus prevê oposição.', c: 'Nem sempre.', d: 'Às vezes o contrário.' },
      'Mateus 5:10–11',
    ],
  ],
  profundezas: [
    [
      'Qual aplicação resume o caráter do Reino nesta cena?',
      [
        ['a', 'Ser misericordioso, íntegro, agente de paz e fiel sob pressão'],
        ['b', 'Parecer espiritual e evitar custo'],
        ['c', 'Buscar status e evitar o próximo'],
        ['d', 'Amar a Deus sem amar pessoas'],
      ],
      'a',
      'Excelente síntese.',
      {
        b: 'Aparência sem custo não basta.',
        c: 'Relacionamento é central.',
        d: 'As duas tábuas caminham juntas.',
      },
      'Mateus 5:7–12',
    ],
    [
      'Se alguém é “pacífico” mas recusa perdoar, o que falta?',
      [
        ['a', 'Misericórdia genuína'],
        ['b', 'Mais regras'],
        ['c', 'Mais debates'],
        ['d', 'Mais isolamento'],
      ],
      'a',
      'Isso. Paz sem misericórdia é frágil.',
      { b: 'O coração importa.', c: 'Não.', d: 'Não.' },
      'Mateus 5:7,9',
    ],
    [
      'Como pureza de coração prepara alguém para a perseguição?',
      [
        ['a', 'Integridade no oculto sustenta fidelidade sob pressão pública'],
        ['b', 'Pureza evita qualquer sofrimento'],
        ['c', 'Pureza é só emoção'],
        ['d', 'Pureza dispensa coragem'],
      ],
      'a',
      'Muito bem.',
      {
        b: 'Jesus une pureza e possível oposição.',
        c: 'É vontade e desejo diante de Deus.',
        d: 'Exige coragem.',
      },
      'Mateus 5:8,10',
    ],
    [
      'Diante de uma calúnia por causa da fé, o cidadão do Reino:',
      [
        ['a', 'Permanece fiel e se alegra na esperança celestial'],
        ['b', 'Abandona a fé'],
        ['c', 'Retribui com calúnia'],
        ['d', 'Esconde Cristo definitivamente'],
      ],
      'a',
      'Perfeito. Mateus 5:11–12.',
      { b: 'Não.', c: 'Mal não cura mal.', d: 'Testemunho importa.' },
      'Mateus 5:11–12',
    ],
    [
      'Qual progresso as cenas 1 e 2 formam juntos?',
      [
        ['a', 'Quem é o cidadão (interior) → como ele vive (relacionamentos e custo)'],
        ['b', 'Só história de Israel'],
        ['c', 'Só regras alimentares'],
        ['d', 'Só milagres sem ética'],
      ],
      'a',
      'Excelente. Essa foi a progressão pedagógica da trilha.',
      { b: 'O foco é o Reino.', c: 'Não.', d: 'Ética do Reino é central.' },
      'Mateus 5:3–12',
    ],
  ],
});

// trails
const trails = JSON.parse(readFileSync(join(assets, 'trails.json'), 'utf8'));
const trail = trails.find((t) => t.slug === 'sermao-do-monte');
const mod = trail.modules.find(
  (m) => m.section === 'carater-do-reino' || m.title === 'O Caráter do Reino',
);
for (const ms of [sm09, boss]) {
  const i = mod.missions.findIndex((x) => x.slug === ms.slug);
  if (i >= 0) mod.missions[i] = ms;
  else mod.missions.push(ms);
}
writeFileSync(join(assets, 'trails.json'), JSON.stringify(trails, null, 2) + '\n');

// studies
const studiesData = JSON.parse(readFileSync(join(assets, 'mission_studies.json'), 'utf8'));
studiesData.studies[study09.slug] = study09;
Object.assign(studiesData.verses || (studiesData.verses = {}), {
  'Mateus 5:10':
    'Bem-aventurados os perseguidos por causa da justiça, porque deles é o Reino dos céus.',
  'Mateus 5:10–12': study09.passageText,
  'Mateus 5:11': 'Bem-aventurados sois quando, por minha causa, vos injuriarem…',
  'Mateus 5:12':
    'Regozijai-vos e exultai, porque é grande o vosso galardão nos céus…',
  'Mateus 5:7–12':
    'Bem-aventurados os misericordiosos… os limpos de coração… os pacificadores… os perseguidos…',
  'João 15:18–20':
    'Se o mundo vos odeia, sabei que, primeiro do que a vós, me odiou a mim…',
  '2 Timóteo 3:12':
    'Ora, todos quantos querem viver piedosamente em Cristo Jesus serão perseguidos.',
  '1 Pedro 4:12–14':
    'Amados, não estranheis a fornalha… se pelo nome de Cristo sois vituperados, sois bem-aventurados…',
  'Atos 5:41':
    'Retiraram-se… regozijando-se por terem sido considerados dignos de sofrer afrontas pelo Nome.',
});
writeFileSync(join(assets, 'mission_studies.json'), JSON.stringify(studiesData, null, 2) + '\n');

// bank
const bankPath = join(assets, 'sermao_questions.json');
const bankData = JSON.parse(readFileSync(bankPath, 'utf8'));
bankData.questions = bankData.questions.filter(
  (qq) => !['sm-09-perseguidos', 'sm-boss-02-carater-do-reino'].includes(qq.section),
);
const neu = [...bank09, ...bankBoss];
bankData.questions.push(...neu);
writeFileSync(bankPath, JSON.stringify(bankData, null, 2) + '\n');

console.log('Cena 2 missions:', mod.missions.map((m) => m.slug).join(', '));
console.log(`+${neu.length} bank (total ${bankData.questions.length})`);
