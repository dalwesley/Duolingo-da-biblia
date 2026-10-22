import { buildScene } from './_weak_scene_build.mjs';

const V = {
  mqMonte:
    'Mas acontecerá nos últimos dias que o monte da casa de Jeová será estabelecido no cume dos montes e será exaltado sobre os outeiros; e a ele concorrerão povos. Irão muitas nações e dirão: Vinde, subamos ao monte de Jeová e à Casa do Deus de Jacó; ele nos ensinará acerca dos seus caminhos, e andaremos nas suas veredas; porque de Sião sairá a lei, e de Jerusalém, a palavra do Senhor.',
  mqBelem:
    'Mas tu, Belém Efrata, que és pequena para se achar entre os milhares de Judá, de ti é que me sairá aquele que há de ser reinante em Israel e cujas saídas são desde os tempos antigos, desde a eternidade.',
  mqMar:
    'Quem é Deus semelhante a ti, que perdoas a iniquidade e que te esqueces da transgressão do resto da tua herança? Ele não retém para sempre a sua ira, porque se deleita na misericórdia. Ele voltará e terá compaixão de nós; pisará aos pés as nossas iniquidades. Tu lançarás todos os seus pecados no fundo do mar.',
  naTardio:
    'Jeová é tardio em irar-se e grande em poder, e de maneira alguma terá por inocente o culpado; Jeová tem o seu caminho no turbilhão e na tempestade, e as nuvens são o pó dos seus pés.',
  naPaz:
    'Eis sobre os montes os pés do que traz boas-novas, que anuncia paz! Celebra as tuas festas, ó Judá, cumpre os teus votos, porque o ímpio não tornará mais a passar por ti; ele é de todo exterminado.',
  naCidade:
    'Ai da cidade ensanguentada! Está toda cheia de mentiras e de rapina; não se aparta dela a presa.',
  hcClamor:
    'Até quando, Jeová, clamarei eu, e tu não ouvirás? Grito a ti: Violência, e não salvarás. Por que me mostras a iniquidade e vês a perversidade? Pois a rapina e a violência estão diante de mim; há contendas, e o litígio se suscita.',
  hcTemplo: 'Jeová, porém, está no seu santo templo; cale-se diante dele toda a terra.',
  hcFigueira:
    'Pois, embora não floresça a figueira, nem haja fruto nas vides; embora falhe o produto da oliveira, e os campos não produzam mantimento; embora o rebanho seja exterminado do curral, e não haja gado nos presépios, contudo, eu me regozijarei em Jeová, exultarei no Deus da minha salvação.',
  rtMara:
    'Respondeu-lhes ela: Não me chameis Noemi, chamai-me Mara, pois o Todo-Poderoso me encheu de grande amargura. Eu saí daqui cheia, e Jeová me fez voltar vazia. Por que me chamais Noemi, visto que Jeová deu testemunho contra mim, e o Todo-Poderoso me afligiu?',
  rtAsas:
    'Jeová te dê o galardão do que fizeste, e te seja concedida plena recompensa da parte de Jeová, Deus de Israel, debaixo de cujas asas vieste buscar refúgio.',
  rtCapa:
    'perguntou-lhe: Quem és tu? Respondeu-lhe ela: Sou Rute, tua serva. Estende a tua capa sobre a tua serva; porque tu és parente chegado. Ele disse: Bendita sejas de Jeová, minha filha. Mostraste mais bondade agora do que em outro tempo, visto que não escolheste mancebos pobres ou ricos. Agora, minha filha, não temas; eu farei tudo o que disseres, porque todo o povo da minha cidade sabe que és mulher virtuosa.',
  jnVentre:
    'Então, orou Jonas a Jeová, seu Deus, lá do ventre do peixe. Ele disse: Da minha aflição, clamei a Jeová, e ele me respondeu; do ventre do Sheol gritei, e tu ouviste a minha voz.',
  jnIra:
    'Orou a Jeová e disse: Ah! Jeová, não foi esta a minha palavra, estando eu ainda no meu país? Por isso é que me apressei a fugir para Társis, pois eu sabia que tu és um Deus clemente e misericordioso, tardio em irar-se e de grande beneficência e que te arrependes do mal.',
  jnCidade:
    'Jeová disse: Tu tiveste compaixão do palma-christi, pela qual não trabalhaste, nem fizeste crescer; que nasceu numa noite e numa noite pereceu. Não hei de eu ter compaixão da grande cidade de Nínive, em que há mais de cento e vinte mil pessoas que não sabem discernir entre a sua mão direita e a sua esquerda, e também muito gado?',
};

function pack(trail, bank, module, scenes, place) {
  return {
    trail,
    bank,
    module,
    place,
    built: scenes.map((item) => buildScene({ trail, ...item })),
  };
}
const tf = (claim, answer, ok, why) => ({ claim, answer, ok, why });
const tap = (quote, word, wrong, ok, why) => ({ quote, word, wrong, ok, why });
const ch = (q, ok, options, why) => ({ q, ok, options, why });
const gap = (template, word, wrong, ok, why) => ({ template, word, wrong, ok, why });
const link = (options, correct, ok, why) => ({ options, correct, ok, why });

export const MORE_PACKS_4 = [
  pack('miqueias', 'ot', { title: 'A promessa', icon: '🌟', section: 'promessa-mq' }, [
    {
      slug: 'mq-03-monte',
      title: 'O monte da casa',
      intro: 'Miquéias vê povos subindo ao monte de Jeová para aprender os caminhos dele.',
      hookRef: 'Miquéias 4:1–2',
      verse: V.mqMonte,
      note: 'A paz que o livro espera não começa na força das nações. Começa na instrução que sai de Sião.',
      insight: 'A paz das nações começa na instrução',
      objective: 'Sair sabendo que as nações sobem ao monte para aprender os caminhos de Jeová.',
      echo: 'Deus pede justiça, misericórdia e humildade. Para onde as nações caminham?',
      keyword: 'Monte',
      gloss: 'O monte é lugar de ensino, e de Sião sai a lei.',
      context: 'Povos sobem ao monte, aprendem os caminhos e andam nas veredas de Jeová.',
      tf: [
        tf('Muitas nações sobem ao monte de Jeová para serem ensinadas.', 'true', 'Certo: elas pedem ensino, não só visita.', 'O convite é: ele nos ensinará os seus caminhos.'),
        tf('A lei, no texto, sai de outra cidade que não Sião.', 'false', 'Certo: de Sião sairá a lei.', 'Jerusalém é de onde sai a palavra.'),
        tf('Andar nas veredas é o fruto de aprender os caminhos.', 'true', 'Certo: ensino e caminhada vêm juntos.', 'O versículo liga ensinar e andar.'),
      ],
      tap: [
        tap('o ___ da casa de Jeová', 'monte', ['povos', 'lei'], 'Exato: é o monte da casa.', ['Povos são quem sobe.', 'Lei é o que sai de Sião.']),
        tap('muitas ___', 'nações', ['monte', 'veredas'], 'Exato: muitas nações vão.', ['Monte é o destino.', 'Veredas são onde se anda.']),
        tap('de ___ sairá a lei', 'Sião', ['monte', 'povos'], 'Exato: a lei sai de Sião.', ['Monte é a casa.', 'Povos são quem sobe.']),
      ],
      choice: [
        ch('Para que as nações sobem ao monte?', 'Certo: para aprender os caminhos.', ['Para que Jeová lhes ensine os caminhos.', 'Para impor a sua lei a Sião.', 'Para evitar as veredas e ficar nos outeiros.', 'Para ouvir a palavra sair de outra cidade.'], ['Quem ensina é Jeová.', 'Elas querem andar nas veredas.', 'A palavra sai de Jerusalém.']),
        ch('Como se ligam monte, lei e veredas?', 'Certo: sobe-se para aprender e então andar.', ['O ensino no monte vira caminho andado.', 'A lei substitui a necessidade de andar.', 'Os outeiros ensinam no lugar de Sião.', 'Os povos sobem e recusam as veredas.'], ['Andar está no versículo.', 'Sião é a fonte da lei.', 'Elas pedem os caminhos.']),
        ch('O que essa visão diz sobre a paz?', 'Certo: a paz nasce de ser instruído por Deus.', ['Nações em paz são nações ensinadas.', 'A paz dispensa a palavra que sai de Sião.', 'Subir ao monte é conquista militar.', 'As veredas ficam vazias enquanto a lei sai.'], ['A lei e a palavra são o centro.', 'O tom é de subida para aprender.', 'Andar nas veredas acompanha o ensino.']),
      ],
      order: {
        pieces: ['O monte da casa de Jeová é exaltado.', 'Povos e nações sobem para ser ensinados.', 'De Sião sai a lei, e eles andam nas veredas.'],
        ok: 'Certo: o monte, a subida e então a lei andada.',
        why: ['A subida vem depois da exaltação do monte.', 'Andar é o fruto do ensino.'],
      },
      complete: [
        gap('concorrerão ___', 'povos', ['lei', 'monte'], 'Certo: povos concorrerão ao monte.', ['Lei é o que sai de Sião.', 'Monte é o destino.']),
        gap('sairá a ___', 'lei', ['povos', 'veredas'], 'Certo: de Sião sairá a lei.', ['Povos são quem sobe.', 'Veredas são o lugar de andar.']),
        gap('nas suas ___', 'veredas', ['Sião', 'nações'], 'Certo: andaremos nas suas veredas.', ['Sião é de onde sai a lei.', 'Nações são quem sobe.']),
      ],
      connect: [
        link(['Ensino que pacifica', 'Monte vazio', 'Lei escondida'], 0, 'Certo: a instrução reúne as nações.', ['Os povos sobem.', 'A lei sai à vista.']),
        link(['Conquista do monte', 'Caminho aprendido', 'Outeiro sem palavra'], 1, 'Certo: elas sobem para andar no que aprendem.', ['O motivo é o ensino.', 'A palavra sai de Jerusalém.']),
        link(['Paz sem instrução', 'Sião que ensina', 'Nações mudas'], 1, 'Certo: a paz aqui é povo instruído.', ['Sem a lei que sai, não há essa paz.', 'Elas falam: vinde, subamos.']),
      ],
    },
    {
      slug: 'mq-04-belem',
      title: 'A pequena Belém',
      intro: 'O reinante de Israel não sai de uma capital orgulhosa. Sai de Belém, pequena entre os milhares de Judá.',
      hookRef: 'Miquéias 5:2',
      verse: V.mqBelem,
      note: 'Pequena não é esquecida. De Belém sai aquele cujas origens vêm desde a eternidade.',
      insight: 'O reinante prometido nasce pequeno',
      objective: 'Sair sabendo que o governante prometido sai de Belém e vem desde a eternidade.',
      echo: 'As nações sobem ao monte. De onde sai quem há de reinar?',
      keyword: 'Belém',
      gloss: 'A pequenez de Belém não impede a origem eterna do reinante.',
      context: 'De Belém, pequena em Judá, sai o reinante de Israel, desde a eternidade.',
      tf: [
        tf('Belém Efrata é chamada pequena entre os milhares de Judá.', 'true', 'Certo: a cidade é pequena, e mesmo assim escolhida.', 'O versículo marca a pequenez.'),
        tf('O reinante sai de Belém, mas a origem dele começa em Belém.', 'false', 'Certo: as saídas dele vêm desde a eternidade.', 'Belém é o nascimento prometido, não a origem primeira.'),
        tf('Deus escolhe o lugar pequeno para fazer sair o reinante.', 'true', 'Certo: a pequenez não veta a promessa.', 'De ti sairá aquele que há de reinar.'),
      ],
      tap: [
        tap('Mas tu, ___ Efrata', 'Belém', ['Judá', 'Israel'], 'Exato: a cidade é Belém.', ['Judá é a tribo dos milhares.', 'Israel é quem ele rege.']),
        tap('há de ser ___ em Israel', 'reinante', ['pequena', 'Efrata'], 'Exato: ele será reinante.', ['Pequena qualifica Belém.', 'Efrata é o outro nome do lugar.']),
        tap('entre os milhares de ___', 'Judá', ['Belém', 'eternidade'], 'Exato: os milhares são de Judá.', ['Belém é a cidade pequena.', 'Eternidade é a origem das saídas.']),
      ],
      choice: [
        ch('De onde sai aquele que há de reinar em Israel?', 'Certo: de Belém Efrata.', ['De Belém, pequena em Judá.', 'Da maior cidade entre os milhares.', 'De um lugar cuja origem é recente.', 'De Efrata, sem ligação com Israel.'], ['O texto chama Belém de pequena.', 'As saídas vêm desde a eternidade.', 'Ele reina em Israel.']),
        ch('O que “desde a eternidade” acrescenta à pequenez de Belém?', 'Certo: o reinante é maior que o vilarejo.', ['A origem dele atravessa os tempos.', 'Belém deixa de ser pequena no mapa.', 'Judá fica fora da promessa.', 'Efrata é só um título recente.'], ['A cidade continua pequena.', 'Judá é o chão da promessa.', 'Eternidade não é um começo recente.']),
        ch('O que essa promessa corrige?', 'Certo: a ideia de que Deus só age no lugar grande.', ['Deus faz sair o reinante do lugar pequeno.', 'O reinante precisa nascer numa capital.', 'Eternidade significa que Belém é antiga e basta.', 'Israel espera um governante sem origem.'], ['Belém não é a capital.', 'A origem eterna é da pessoa, não só da vila.', 'Há um reinante prometido.']),
      ],
      order: {
        pieces: ['Belém é pequena entre os milhares de Judá.', 'Dela sairá o reinante em Israel.', 'As saídas dele vêm desde a eternidade.'],
        ok: 'Certo: pequenez, saída e então a origem eterna.',
        why: ['A saída vem da cidade pequena.', 'A eternidade fecha a grandeza dele.'],
      },
      complete: [
        gap('que és ___', 'pequena', ['Belém', 'Judá'], 'Certo: Belém é pequena.', ['Belém é o nome.', 'Judá é a tribo.']),
        gap('desde a ___', 'eternidade', ['Israel', 'Efrata'], 'Certo: as saídas vêm desde a eternidade.', ['Israel é onde ele reina.', 'Efrata nomeia o lugar.']),
        gap('reinante em ___', 'Israel', ['Judá', 'pequena'], 'Certo: ele reina em Israel.', ['Judá é onde Belém está.', 'Pequena qualifica a cidade.']),
      ],
      connect: [
        link(['Grandeza no pequeno', 'Capital orgulhosa', 'Origem recente'], 0, 'Certo: o reinante sai do lugar pequeno.', ['Belém não é a grande capital.', 'A origem vem da eternidade.']),
        link(['Vila sem promessa', 'Origem que atravessa', 'Judá esquecida'], 1, 'Certo: as saídas dele vêm de longe.', ['Há promessa justamente para Belém.', 'Judá é nomeada.']),
        link(['Poder que escolhe o grande', 'Rei que nasce pequeno', 'Eternidade da vila'], 1, 'Certo: a pequenez não impede o reinante.', ['Deus escolhe Belém.', 'Eterna é a saída dele, não a fama da vila.']),
      ],
    },
    {
      slug: 'mq-05-mar',
      title: 'No fundo do mar',
      intro: 'Miquéias fecha perguntando quem é semelhante a Deus: ele perdoa, não retém a ira e lança os pecados no mar.',
      hookRef: 'Miquéias 7:18–19',
      verse: V.mqMar,
      note: 'A misericórdia não é esquecimento vago. É perdão que pisa a iniquidade e a lança no fundo.',
      insight: 'Deus lança os pecados no fundo do mar',
      objective: 'Sair sabendo que o perdão de Deus deleita-se na misericórdia e não retém a ira.',
      echo: 'O reinante nasce pequeno. O que esse Deus faz com a iniquidade?',
      keyword: 'Mar',
      gloss: 'O fundo do mar é a imagem do pecado lançado fora.',
      context: 'Deus perdoa, deleita-se na misericórdia e lança os pecados no fundo do mar.',
      tf: [
        tf('Miquéias pergunta quem é Deus semelhante a este, que perdoa a iniquidade.', 'true', 'Certo: o perdão é o que o torna incomparável.', 'A pergunta abre o louvor.'),
        tf('Ele retém a ira para sempre e recusa a misericórdia.', 'false', 'Certo: não retém a ira, porque se deleita na misericórdia.', 'O texto nega a ira permanente.'),
        tf('Lançar os pecados no mar é imagem de perdão que não os guarda à mão.', 'true', 'Certo: o fundo do mar é distância.', 'Ele pisa as iniquidades e as lança no mar.'),
      ],
      tap: [
        tap('se deleita na ___', 'misericórdia', ['ira', 'mar'], 'Exato: ele se deleita na misericórdia.', ['Ira é o que ele não retém para sempre.', 'Mar é para onde vão os pecados.']),
        tap('todos os seus ___', 'pecados', ['ira', 'herança'], 'Exato: ele lança os pecados no mar.', ['Ira não é o que é lançado.', 'Herança é o resto que ele não esquece.']),
        tap('perdoas a ___', 'iniquidade', ['mar', 'misericórdia'], 'Exato: ele perdoa a iniquidade.', ['Mar é o destino dos pecados.', 'Misericórdia é o deleite dele.']),
      ],
      choice: [
        ch('O que torna Deus incomparável neste louvor?', 'Certo: ele perdoa e não retém a ira.', ['Perdoar a iniquidade e deleitar-se na misericórdia.', 'Guardar a ira para sempre sobre a herança.', 'Esquecer o resto e reter a transgressão.', 'Lançar o povo, e não os pecados, no mar.'], ['A ira não fica para sempre.', 'Ele se esquece da transgressão do resto.', 'O que vai ao mar são os pecados.']),
        ch('O que “fundo do mar” acrescenta ao perdão?', 'Certo: o pecado não fica à mão para ser cobrado de novo.', ['Os pecados são levados para longe.', 'O mar guarda o pecado perto da praia.', 'A misericórdia é só um nome da ira.', 'A herança é que é lançada fora.'], ['Fundo é distância.', 'Ele se deleita na misericórdia.', 'A herança é o resto que ele trata com compaixão.']),
        ch('O que esse louvor sustenta sobre o juízo?', 'Certo: a ira não é a última palavra dele.', ['Deus volta em compaixão e pisa a iniquidade.', 'A ira permanece porque a misericórdia é fraca.', 'Perdoar é esquecer que houve transgressão sem lidar com ela.', 'O mar devolve os pecados à herança.'], ['Ele não retém a ira para sempre.', 'Há perdão nomeado, não só silêncio.', 'Lançar no fundo é não devolver.']),
      ],
      order: {
        pieces: ['Deus perdoa a iniquidade e não retém a ira para sempre.', 'Ele se deleita na misericórdia e volta em compaixão.', 'Lança os pecados no fundo do mar.'],
        ok: 'Certo: perdão, misericórdia e então o mar.',
        why: ['A misericórdia explica por que a ira não fica.', 'O mar é a imagem final do afastamento.'],
      },
      complete: [
        gap('no fundo do ___', 'mar', ['ira', 'herança'], 'Certo: os pecados vão para o fundo do mar.', ['Ira é o que ele não retém.', 'Herança é o resto do povo.']),
        gap('terá ___ de nós', 'compaixão', ['pecados', 'mar'], 'Certo: ele terá compaixão.', ['Pecados são o que é lançado.', 'Mar é o lugar.']),
        gap('a sua ___', 'ira', ['mar', 'herança'], 'Certo: ele não retém a sua ira para sempre.', ['Mar recebe os pecados.', 'Herança é o resto.']),
      ],
      connect: [
        link(['Perdão que afasta', 'Ira sem fim', 'Mar da culpa'], 0, 'Certo: os pecados são lançados longe.', ['A ira não fica para sempre.', 'O mar não guarda a culpa à mão.']),
        link(['Misericórdia relutante', 'Deleite em perdoar', 'Herança rejeitada'], 1, 'Certo: ele se deleita na misericórdia.', ['O deleite é explícito.', 'A herança é tratada com perdão.']),
        link(['Juízo sem volta', 'Compaixão que pisa o mal', 'Esquecimento vazio'], 1, 'Certo: há compaixão que lida com a iniquidade.', ['Ele volta e tem compaixão.', 'Pisar e lançar não é fingir que não houve mal.']),
      ],
    },
  ]),
  pack('rute', 'ot', { title: 'O custo', icon: '🌾', section: 'custo' }, [
    {
      slug: 'rute-03-mara',
      title: 'Chamai-me Mara',
      intro: 'Noemi volta a Belém e recusa o nome doce. Pede Mara, porque saiu cheia e voltou vazia.',
      hookRef: 'Rute 1:20–21',
      verse: V.rtMara,
      note: 'A amargura não é falta de fé muda. É oração que diz o que ela sente de Deus.',
      insight: 'A perda pode fazer Deus parecer adversário',
      objective: 'Sair sabendo que Noemi nomeia a amargura e atribui o vazio a Jeová.',
      echo: 'Rute colou a vida a Noemi. Como Noemi nomeia o que sente ao chegar?',
      keyword: 'Mara',
      gloss: 'Mara é amargura: o nome que Noemi pede no lugar de Noemi.',
      context: 'Noemi pede o nome Mara, porque saiu cheia e Jeová a fez voltar vazia.',
      tf: [
        tf('Noemi pede que não a chamem Noemi, e sim Mara.', 'true', 'Certo: ela troca o nome doce pelo amargo.', 'O pedido abre a fala.'),
        tf('Noemi diz que voltou tão cheia quanto saiu.', 'false', 'Certo: saiu cheia e voltou vazia.', 'O contraste está na frase.'),
        tf('A amargura de Noemi fala de Deus, não só da fome.', 'true', 'Certo: ela diz que o Todo-Poderoso a afligiu.', 'Jeová é nomeado como quem a fez voltar vazia.'),
      ],
      tap: [
        tap('chamai-me ___', 'Mara', ['Noemi', 'cheia'], 'Exato: o nome pedido é Mara.', ['Noemi é o nome que ela recusa.', 'Cheia é como saiu.']),
        tap('voltar ___', 'vazia', ['Mara', 'amargura'], 'Exato: Jeová a fez voltar vazia.', ['Mara é o nome.', 'Amargura é o que a encheu por dentro.']),
        tap('grande ___', 'amargura', ['Noemi', 'vazia'], 'Exato: o Todo-Poderoso a encheu de amargura.', ['Noemi é o nome doce.', 'Vazia é como ela voltou.']),
      ],
      choice: [
        ch('Que nome Noemi pede em Belém?', 'Certo: Mara, por causa da amargura.', ['Mara, porque o Todo-Poderoso a amargurou.', 'Noemi, para lembrar que ainda está cheia.', 'Rute, para apagar a própria história.', 'Belém, como se a cidade fosse a culpa.'], ['Ela recusa Noemi neste momento.', 'Rute é quem a acompanha, não o nome pedido.', 'A fala é sobre Deus, não sobre o nome da cidade.']),
        ch('O que “saí cheia e voltei vazia” revela?', 'Certo: a perda virou leitura sobre Deus.', ['Ela lê o vazio como ato de Jeová.', 'A viagem não mudou nada do que ela levava.', 'O Todo-Poderoso a encheu de bens na volta.', 'Mara significa que a perda ficou sem nome.'], ['O contraste é o centro da frase.', 'Ela se diz vazia.', 'Mara é justamente o nome da amargura.']),
        ch('O que essa fala permite ao leitor?', 'Certo: levar a Deus a sensação de que ele afligiu.', ['Nomear a amargura diante de Deus.', 'Esconder a perda para proteger o nome doce.', 'Concluir que Jeová não entra na história dela.', 'Trocar Mara por uma alegria imediata.'], ['Ela fala, não esconde.', 'Jeová é o sujeito que ela nomeia.', 'A cena não pula para o consolo.']),
      ],
      order: {
        pieces: ['Noemi pede que a chamem Mara.', 'O Todo-Poderoso a encheu de amargura.', 'Ela saiu cheia e Jeová a fez voltar vazia.'],
        ok: 'Certo: o nome, a amargura e então o vazio da volta.',
        why: ['A amargura explica o nome Mara.', 'A volta vazia fecha o lamento.'],
      },
      complete: [
        gap('Não me chameis ___', 'Noemi', ['Mara', 'vazia'], 'Certo: ela recusa o nome Noemi.', ['Mara é o nome que pede.', 'Vazia descreve a volta.']),
        gap('saí daqui ___', 'cheia', ['Mara', 'amargura'], 'Certo: ela saiu cheia.', ['Mara é o nome da volta.', 'Amargura é o que a encheu por dentro.']),
        gap('deu ___ contra mim', 'testemunho', ['Mara', 'cheia'], 'Certo: Jeová deu testemunho contra ela.', ['Mara é o nome pedido.', 'Cheia é como ela saiu.']),
      ],
      connect: [
        link(['Nome da amargura', 'Volta cheia', 'Cidade culpada'], 0, 'Certo: Mara nomeia o que ela sente.', ['Ela voltou vazia.', 'A fala é sobre Deus, não sobre Belém.']),
        link(['Perda sem Deus', 'Deus no vazio', 'Nome ainda doce'], 1, 'Certo: ela atribui o vazio a Jeová.', ['Jeová é nomeado.', 'Ela não quer o nome doce agora.']),
        link(['Alegria obrigatória', 'Lamento que fala', 'Fome sem rosto'], 1, 'Certo: a fé aqui tem voz de amargura.', ['Ela não finge doçura.', 'Há nome, Deus e vazio.']),
      ],
    },
    {
      slug: 'rute-04-asas',
      title: 'Debaixo das asas',
      intro: 'Boaz vê a lealdade de Rute e pede que Jeová a recompense. O abrigo é debaixo das asas do Deus de Israel.',
      hookRef: 'Rute 2:12',
      verse: V.rtAsas,
      note: 'O favor no campo ganha nome teológico: refúgio sob as asas de Jeová.',
      insight: 'Refúgio debaixo das asas de Deus',
      objective: 'Sair sabendo que Boaz liga a lealdade de Rute ao refúgio no Deus de Israel.',
      echo: 'Noemi voltou vazia. Onde Rute busca abrigo no campo?',
      keyword: 'Asas',
      gloss: 'As asas são o refúgio do Deus de Israel, não só a sombra do campo.',
      context: 'Boaz pede recompensa a Rute, que buscou refúgio sob as asas de Jeová.',
      tf: [
        tf('Boaz pede que Jeová recompense o que Rute fez.', 'true', 'Certo: o galardão é pedido a Jeová.', 'A bênção abre com esse pedido.'),
        tf('O refúgio de Rute, no texto, é debaixo das asas de outro deus.', 'false', 'Certo: as asas são do Deus de Israel.', 'O versículo nomeia Jeová, Deus de Israel.'),
        tf('A lealdade de Rute é lida como busca de refúgio em Deus.', 'true', 'Certo: Boaz interpreta o gesto dela assim.', 'Vir buscar refúgio é a frase final.'),
      ],
      tap: [
        tap('debaixo de cujas ___', 'asas', ['galardão', 'refúgio'], 'Exato: as asas são o abrigo.', ['Galardão é a recompensa pedida.', 'Refúgio é o que ela veio buscar.']),
        tap('plena ___', 'recompensa', ['asas', 'Israel'], 'Exato: ele pede plena recompensa.', ['Asas são o lugar do refúgio.', 'Israel nomeia o Deus.']),
        tap('vieste buscar ___', 'refúgio', ['galardão', 'asas'], 'Exato: ela veio buscar refúgio.', ['Galardão é o que Boaz pede a Jeová.', 'Asas são onde o refúgio se abriga.']),
      ],
      choice: [
        ch('A quem Boaz pede o galardão de Rute?', 'Certo: a Jeová, Deus de Israel.', ['A Jeová, debaixo de cujas asas ela buscou refúgio.', 'Ao campo, como se a terra pagasse sozinha.', 'A outro deus, fora de Israel.', 'A Noemi, para que devolva o que perdeu.'], ['O campo é o cenário, não o pagador.', 'O Deus nomeado é o de Israel.', 'Noemi não é quem retribui nesta frase.']),
        ch('O que as asas significam na boca de Boaz?', 'Certo: o abrigo do Deus de Israel.', ['Refúgio em Jeová, não só sombra humana.', 'Um detalhe do campo, sem Deus.', 'A recompensa que Rute já recebeu por inteiro.', 'A volta de Noemi para Moabe.'], ['Ele nomeia Jeová.', 'A recompensa ainda é pedida.', 'O caminho de Rute é para Israel.']),
        ch('O que essa bênção ensina sobre bondade humana?', 'Certo: o favor de Boaz aponta para o refúgio de Deus.', ['Acolhida humana nomeia o Deus que abriga.', 'O galardão dispensa Jeová.', 'Refúgio nas asas é medo de Israel.', 'Rute é recompensada por ter ficado em Moabe.'], ['Boaz ora a Jeová.', 'As asas são dele.', 'Ela deixou Moabe para buscar esse refúgio.']),
      ],
      order: {
        pieces: ['Boaz pede que Jeová dê o galardão a Rute.', 'Pede plena recompensa da parte do Deus de Israel.', 'Reconhece que ela buscou refúgio debaixo das asas.'],
        ok: 'Certo: pedido, recompensa e então o refúgio.',
        why: ['A recompensa especifica o galardão.', 'As asas fecham a bênção.'],
      },
      complete: [
        gap('te dê o ___', 'galardão', ['asas', 'refúgio'], 'Certo: o pedido é o galardão.', ['Asas são o abrigo.', 'Refúgio é o que ela buscou.']),
        gap('Deus de ___', 'Israel', ['asas', 'galardão'], 'Certo: é o Deus de Israel.', ['Asas são a imagem.', 'Galardão é a recompensa.']),
        gap('cujas ___ vieste buscar refúgio', 'asas', ['Israel', 'galardão'], 'Certo: o refúgio é debaixo das asas.', ['Israel nomeia o Deus.', 'Galardão é o pedido de Boaz.']),
      ],
      connect: [
        link(['Abrigo em Deus', 'Pagamento do campo', 'Volta a Moabe'], 0, 'Certo: as asas são de Jeová.', ['Boaz não deixa o campo pagar sozinho.', 'O caminho dela é para Israel.']),
        link(['Favor sem nome', 'Lealdade como refúgio', 'Asas de outro deus'], 1, 'Certo: o que ela fez é busca de abrigo.', ['Jeová é nomeado.', 'O Deus é o de Israel.']),
        link(['Bondade fechada em si', 'Acolhida que aponta a Deus', 'Recompensa já quitada'], 1, 'Certo: o favor humano aponta para Jeová.', ['Boaz ora.', 'A recompensa ainda é pedida.']),
      ],
    },
    {
      slug: 'rute-05-capa',
      title: 'Estende a tua capa',
      intro: 'Na eira, Rute pede a Boaz que estenda a capa. O resgate tem nome: parente chegado, e tem custo.',
      hookRef: 'Rute 3:9–11',
      verse: V.rtCapa,
      note: 'Estender a capa é pedir cobertura de resgate. Boaz não zomba: chama-a virtuosa e promete fazer.',
      insight: 'Redenção pede quem aceite o custo',
      objective: 'Sair sabendo que Rute pede a Boaz cobertura de parente e ele aceita o encargo.',
      echo: 'Há refúgio debaixo das asas. Que cobertura Rute pede a Boaz?',
      keyword: 'Capa',
      gloss: 'A capa é o sinal do resgate que o parente pode aceitar.',
      context: 'Rute pede que Boaz estenda a capa, porque ele é parente chegado, e ele promete agir.',
      tf: [
        tf('Rute pede que Boaz estenda a capa sobre ela, porque ele é parente chegado.', 'true', 'Certo: o pedido une capa e parentesco.', 'A frase dela junta as duas coisas.'),
        tf('Boaz recusa e diz que Rute escolheu mal ao não buscar os jovens.', 'false', 'Certo: ele a abençoa e promete fazer o que ela disse.', 'Ele elogia a bondade maior e a chama virtuosa.'),
        tf('O resgate, aqui, depende de alguém que aceite cobrir.', 'true', 'Certo: a capa não se estende sozinha.', 'Boaz responde que fará o que ela pediu.'),
      ],
      tap: [
        tap('Estende a tua ___', 'capa', ['serva', 'cidade'], 'Exato: o pedido é a capa.', ['Serva é como ela se nomeia.', 'Cidade é onde o povo a conhece.']),
        tap('és mulher ___', 'virtuosa', ['capa', 'parente'], 'Exato: o povo a conhece como virtuosa.', ['Capa é o que ela pede.', 'Parente é o motivo do pedido.']),
        tap('tu és ___ chegado', 'parente', ['capa', 'serva'], 'Exato: Boaz é parente chegado.', ['Capa é o sinal do pedido.', 'Serva é como Rute se chama.']),
      ],
      choice: [
        ch('O que Rute pede a Boaz na eira?', 'Certo: que estenda a capa, por ser parente.', ['Cobertura de parente chegado.', 'Um caminho de volta para Moabe.', 'Que ele a entregue aos mancebos.', 'Silêncio, sem assumir o resgate.'], ['Ela ficou com Noemi.', 'Ele elogia por ela não ter escolhido os mancebos.', 'Ele promete fazer.']),
        ch('Como Boaz recebe o pedido?', 'Certo: abençoa, elogia e promete agir.', ['Chama-a virtuosa e diz que fará.', 'Recusa a capa e a manda embora.', 'Diz que o povo da cidade a despreza.', 'Adia tudo porque ela escolheu os jovens.'], ['A resposta é favor.', 'Ele fala do que a cidade sabe.', 'Ele nota que ela não escolheu os mancebos.']),
        ch('O que a capa ensina sobre redenção?', 'Certo: alguém precisa aceitar o custo da cobertura.', ['Resgate é cobertura que um parente assume.', 'Resgate acontece sem que ninguém se comprometa.', 'Virtude dispensa o parente chegado.', 'A eira substitui a necessidade de Boaz.'], ['Ela pede a ele, não ao vazio.', 'O parentesco é o motivo.', 'Boaz é quem pode fazer.']),
      ],
      order: {
        pieces: ['Rute se nomeia serva e pede a capa.', 'O motivo é que Boaz é parente chegado.', 'Ele a abençoa, a chama virtuosa e promete fazer.'],
        ok: 'Certo: pedido, parentesco e então a promessa.',
        why: ['O parentesco fundamenta a capa.', 'A promessa de Boaz fecha a cena.'],
      },
      complete: [
        gap('tua ___', 'serva', ['capa', 'cidade'], 'Certo: ela se chama serva.', ['Capa é o que pede.', 'Cidade é onde a conhecem.']),
        gap('não temas; eu ___', 'farei', ['capa', 'parente'], 'Certo: Boaz diz que fará.', ['Capa é o pedido.', 'Parente é o título.']),
        gap('mancebos pobres ou ___', 'ricos', ['virtuosa', 'capa'], 'Certo: ela não escolheu mancebos pobres ou ricos.', ['Virtuosa é o que a cidade sabe.', 'Capa é o pedido da eira.']),
      ],
      connect: [
        link(['Cobertura de resgate', 'Volta a Moabe', 'Festa da eira'], 0, 'Certo: a capa pede resgate.', ['Ela permanece no caminho de Israel.', 'Não é só o lugar; é o pedido.']),
        link(['Pedido recusado', 'Parente que assume', 'Virtude escondida'], 1, 'Certo: Boaz aceita o encargo.', ['Ele promete fazer.', 'A cidade a conhece como virtuosa.']),
        link(['Redenção sem custo', 'Alguém paga a cobertura', 'Eira sem promessa'], 1, 'Certo: o resgate tem quem o aceite.', ['A capa é compromisso.', 'Boaz responde com ação.']),
      ],
    },
  ], 'before-last'),
  pack('jonas', 'ot', { title: 'A misericórdia', icon: '🌿', section: 'misericordia-jn' }, [
    {
      slug: 'jonas-03-ventre',
      title: 'Do ventre do peixe',
      intro: 'Dentro do peixe, Jonas ora. Do Sheol ele grita, e diz que Jeová ouviu a sua voz.',
      hookRef: 'Jonas 2:1–2',
      verse: V.jnVentre,
      note: 'A oração não espera o templo. Nasce na aflição, no fundo, e ainda assim é ouvida.',
      insight: 'A oração pode nascer no fundo',
      objective: 'Sair sabendo que Jonas clamou do ventre e Jeová respondeu.',
      echo: 'A cidade se arrependeu. Antes disso, o que Jonas fez no fundo do peixe?',
      keyword: 'Ventre',
      gloss: 'O ventre do peixe e do Sheol é de onde a oração sobe.',
      context: 'Jonas ora a Jeová de dentro do peixe e diz que o clamor foi ouvido.',
      tf: [
        tf('Jonas orou a Jeová de dentro do ventre do peixe.', 'true', 'Certo: o lugar da oração é o ventre.', 'O versículo situa a oração ali.'),
        tf('Do Sheol, Jonas gritou e ficou sem resposta.', 'false', 'Certo: ele diz que Jeová ouviu a sua voz.', 'O clamor e a resposta vêm juntos.'),
        tf('Profundidade não impede que a oração chegue a Deus.', 'true', 'Certo: do fundo ele é ouvido.', 'Sheol e ventre não fecham a voz.'),
      ],
      tap: [
        tap('lá do ___ do peixe', 'ventre', ['aflição', 'voz'], 'Exato: a oração sai do ventre.', ['Aflição é de onde ele clamou.', 'Voz é o que foi ouvido.']),
        tap('Da minha ___, clamei', 'aflição', ['peixe', 'Sheol'], 'Exato: o clamor nasce da aflição.', ['Peixe é o lugar.', 'Sheol é a profundidade nomeada.']),
        tap('ouviste a minha ___', 'voz', ['ventre', 'aflição'], 'Exato: Jeová ouviu a voz.', ['Ventre é o lugar.', 'Aflição é o motivo do grito.']),
      ],
      choice: [
        ch('De onde Jonas ora?', 'Certo: do ventre do peixe.', ['Do ventre do peixe, a Jeová.', 'Do templo, antes de embarcar.', 'De Társis, em segurança.', 'Do convés, enquanto foge.'], ['O templo não é o lugar desta oração.', 'Társis era a fuga.', 'A fuga já o lançou ao fundo.']),
        ch('O que o Sheol acrescenta ao ventre do peixe?', 'Certo: a oração sobe de uma profundidade de morte.', ['Ele grita de um lugar de morte e é ouvido.', 'Sheol prova que a voz não saiu.', 'O peixe é só imagem, sem aflição.', 'Jeová responde só a quem ora no alto.'], ['Ele diz que a voz foi ouvida.', 'Há aflição nomeada.', 'O lugar é o fundo, não o alto.']),
        ch('O que essa oração ensina sobre clamar?', 'Certo: dá para orar do fundo, e Deus ouve.', ['O fundo não cala a oração.', 'Só ora quem já saiu do peixe.', 'Sheol é silêncio sem resposta.', 'A voz de Jonas ficou no ventre.'], ['Ele ora lá de dentro.', 'Há resposta.', 'A voz foi ouvida.']),
      ],
      order: {
        pieces: ['Jonas ora a Jeová do ventre do peixe.', 'Da aflição ele clama, e Jeová responde.', 'Do Sheol grita, e a sua voz é ouvida.'],
        ok: 'Certo: o lugar, o clamor e então a voz ouvida.',
        why: ['O clamor vem de dentro do peixe.', 'Ser ouvido fecha a oração.'],
      },
      complete: [
        gap('orou Jonas a ___', 'Jeová', ['peixe', 'voz'], 'Certo: a oração é a Jeová.', ['Peixe é o lugar.', 'Voz é o que foi ouvido.']),
        gap('do ventre do ___', 'Sheol', ['peixe', 'aflição'], 'Certo: ele gritou do ventre do Sheol.', ['Peixe é o outro ventre, no início.', 'Aflição é o estado, não o nome do lugar.']),
        gap('ele me ___', 'respondeu', ['ventre', 'voz'], 'Certo: Jeová respondeu ao clamor.', ['Ventre é o lugar.', 'Voz é o que subiu.']),
      ],
      connect: [
        link(['Oração do fundo', 'Fuga concluída', 'Templo obrigatório'], 0, 'Certo: ele ora de dentro do peixe.', ['A fuga não é o sucesso.', 'Não há templo nesta cena.']),
        link(['Grito sem ouvido', 'Voz que sobe do Sheol', 'Peixe em silêncio'], 1, 'Certo: do Sheol a voz é ouvida.', ['Ele diz que foi ouvido.', 'A oração quebra o silêncio.']),
        link(['Profundidade muda', 'Deus ouve no abismo', 'Resposta só no alto'], 1, 'Certo: o abismo não fecha o ouvido de Deus.', ['Há resposta no ventre.', 'O lugar é o fundo.']),
      ],
    },
    {
      slug: 'jonas-04-ira',
      title: 'Jonas se ira',
      intro: 'Quando Deus perdoa Nínive, Jonas se ira. Ele foge porque sabia que Jeová é clemente.',
      hookRef: 'Jonas 4:2',
      verse: V.jnIra,
      note: 'A misericórdia de Deus, que salva a cidade, ofende o profeta que queria o juízo.',
      insight: 'A misericórdia de Deus pode ofender',
      objective: 'Sair sabendo que Jonas fugiu porque conhecia a clemência de Jeová.',
      echo: 'Do fundo ele foi ouvido. Por que essa mesma misericórdia o ira?',
      keyword: 'Clemência',
      gloss: 'Jonas sabia que Jeová é tardio em irar-se e se arrepende do mal.',
      context: 'Jonas explica a fuga: sabia que Deus é clemente e se arrepende do mal.',
      tf: [
        tf('Jonas diz que fugiu para Társis porque sabia que Jeová é clemente.', 'true', 'Certo: a teologia dele motivou a fuga.', 'Ele mesmo dá essa razão.'),
        tf('Jonas esperava um Deus rápido em irar-se e fechado à misericórdia.', 'false', 'Certo: ele descreve Deus como tardio em irar-se.', 'A confissão lista clemência e beneficência.'),
        tf('Conhecer a misericórdia de Deus não garante que o coração a deseje.', 'true', 'Certo: Jonas sabe e mesmo assim se ira.', 'O conhecimento vira queixa.'),
      ],
      tap: [
        tap('fugir para ___', 'Társis', ['país', 'mal'], 'Exato: a fuga era para Társis.', ['País é de onde ele fala.', 'Mal é aquilo de que Deus se arrepende.']),
        tap('Deus ___ e misericordioso', 'clemente', ['Társis', 'país'], 'Exato: ele sabia que Deus é clemente.', ['Társis é o destino da fuga.', 'País é o lugar da palavra anterior.']),
        tap('te arrependes do ___', 'mal', ['Társis', 'país'], 'Exato: Deus se arrepende do mal.', ['Társis é a fuga.', 'País é de onde ele saiu.']),
      ],
      choice: [
        ch('Por que Jonas diz que fugiu?', 'Certo: porque sabia que Deus perdoa.', ['Sabia que Jeová é clemente e se arrepende do mal.', 'Porque achava Deus incapaz de misericórdia.', 'Porque Társis era o lugar da profecia.', 'Porque Nínive já tinha sido destruída.'], ['Ele lista a clemência.', 'Társis é fuga, não púlpito.', 'A cidade ainda será o assunto da misericórdia.']),
        ch('O que a ira de Jonas revela?', 'Certo: ele queria juízo, não perdão.', ['A misericórdia de Deus o ofende.', 'Ele se alegra com o arrependimento do mal.', 'A fuga foi ignorância sobre quem Deus é.', 'Clemência e ira do profeta coincidem.'], ['A oração é queixa.', 'Ele conhecia a misericórdia.', 'A ira mostra que ele não a desejava.']),
        ch('O que essa confissão impede?', 'Certo: achar que saber de Deus é o mesmo que amar a misericórdia.', ['Conhecer o credo não basta para querer o perdão.', 'Deus deixa de ser tardio em irar-se.', 'Társis passa a ser o centro da missão.', 'A beneficência de Deus era desconhecida de Jonas.'], ['O credo dele está certo.', 'A missão era Nínive.', 'Ele sabia, e mesmo assim fugiu.']),
      ],
      order: {
        pieces: ['Jonas lembra o que disse ainda no seu país.', 'Por isso se apressou a fugir para Társis.', 'Ele sabia que Jeová é clemente e se arrepende do mal.'],
        ok: 'Certo: a palavra antiga, a fuga e então a razão.',
        why: ['A fuga executa o que ele já temia.', 'A clemência é a razão confessada.'],
      },
      complete: [
        gap('ainda no meu ___', 'país', ['Társis', 'mal'], 'Certo: a palavra foi dita no país dele.', ['Társis é para onde fugiu.', 'Mal é o que Deus deixa.']),
        gap('tardio em ___', 'irar-se', ['Társis', 'país'], 'Certo: Deus é tardio em irar-se.', ['Társis é a fuga.', 'País é a origem.']),
        gap('grande ___', 'beneficência', ['país', 'Társis'], 'Certo: ele conhecia a grande beneficência.', ['País é de onde falou.', 'Társis é o destino.']),
      ],
      connect: [
        link(['Misericórdia que ofende', 'Deus desconhecido', 'Fuga sem motivo'], 0, 'Certo: o perdão de Deus irrita Jonas.', ['Ele conhecia o caráter de Deus.', 'A razão da fuga está dita.']),
        link(['Ignorância do credo', 'Credo contra o desejo', 'Alegria com Nínive'], 1, 'Certo: ele sabe e não quer.', ['O credo está na boca dele.', 'A queixa não é alegria.']),
        link(['Juízo desejado', 'Perdão celebrado', 'Társis como altar'], 0, 'Certo: ele queria que o mal não fosse suspenso.', ['A ira mostra a preferência.', 'Társis é fuga, não culto.']),
      ],
    },
    {
      slug: 'jonas-05-cidade',
      title: 'E Nínive?',
      intro: 'Jonas tem pena da planta que não cultivou. Jeová pergunta se não terá compaixão da cidade inteira.',
      hookRef: 'Jonas 4:10–11',
      verse: V.jnCidade,
      note: 'A planta durou uma noite. A cidade tem gente que não distingue a mão direita da esquerda, e também gado.',
      insight: 'Deus se importa com a cidade desprezada',
      objective: 'Sair sabendo que a compaixão de Jeová alcança Nínive, não só a planta de Jonas.',
      echo: 'A misericórdia o ofendeu. Com quem Jeová compara essa pena?',
      keyword: 'Nínive',
      gloss: 'A cidade vale mais que a planta que Jonas não fez crescer.',
      context: 'Jeová confronta a pena de Jonas pela planta com a sua compaixão por Nínive.',
      tf: [
        tf('Jonas teve compaixão da planta pela qual não trabalhou.', 'true', 'Certo: a planta não era obra dele.', 'Jeová descreve assim o palma-christi.'),
        tf('Jeová diz que Nínive não merece compaixão, por ser grande demais.', 'false', 'Certo: ele pergunta se não terá compaixão da grande cidade.', 'A grandeza aumenta a pena, não a cancela.'),
        tf('A compaixão de Deus alcança pessoas que Jonas não queria poupar.', 'true', 'Certo: a cidade entra na conta de Deus.', 'Há mais de cento e vinte mil pessoas, e gado.'),
      ],
      tap: [
        tap('compaixão do ___', 'palma-christi', ['noite', 'gado'], 'Exato: a pena de Jonas era da planta.', ['Noite é o tempo em que ela nasceu e morreu.', 'Gado está na cidade, não na planta.']),
        tap('grande cidade de ___', 'Nínive', ['noite', 'gado'], 'Exato: a cidade é Nínive.', ['Noite é o tempo da planta.', 'Gado está na cidade, mas não é o nome dela.']),
        tap('muito ___', 'gado', ['noite', 'mão'], 'Exato: Jeová menciona também muito gado.', ['Noite é o prazo da planta.', 'Mão é o que a gente da cidade não distingue.']),
      ],
      choice: [
        ch('Com o que Jeová compara a pena de Jonas?', 'Certo: a planta que durou uma noite e a cidade inteira.', ['A planta efêmera e a grande cidade de Nínive.', 'Dois reinos que Jonas queria visitar.', 'O peixe e o templo de Jerusalém.', 'Társis e o país de onde ele fugiu.'], ['Nínive é o segundo termo.', 'O peixe ficou para trás.', 'Társis foi a fuga, não a comparação.']),
        ch('Por que a planta enfraquece o argumento de Jonas?', 'Certo: ele sofre por algo que não cultivou e que durou uma noite.', ['A pena dele é pequena perto da cidade.', 'A planta prova que Nínive devia cair.', 'Jonas trabalhou anos para fazer a planta crescer.', 'O gado diminui o valor das pessoas.'], ['Ele não a fez crescer.', 'A comparação favorece a cidade.', 'Pessoas e gado estão na conta de Deus.']),
        ch('O que a pergunta final revela sobre Deus?', 'Certo: a compaixão dele é mais larga que a do profeta.', ['Deus se importa com a cidade que o profeta despreza.', 'Deus aprende compaixão com a planta.', 'Nínive fica fora do cuidado porque é pagã.', 'O gado importa mais que as pessoas.'], ['A pergunta espera um sim à cidade.', 'Nínive é incluída.', 'Pessoas e gado vêm juntos, as pessoas primeiro.']),
      ],
      order: {
        pieces: ['Jonas teve pena da planta que não cultivou.', 'A planta nasceu numa noite e numa noite pereceu.', 'Jeová pergunta se não terá compaixão de Nínive e do seu gado.'],
        ok: 'Certo: a planta, a brevidade e então a cidade.',
        why: ['A brevidade mostra como a pena era pequena.', 'Nínive é o contraste final.'],
      },
      complete: [
        gap('numa ___ pereceu', 'noite', ['Nínive', 'gado'], 'Certo: a planta pereceu numa noite.', ['Nínive é a cidade.', 'Gado está na pergunta final.']),
        gap('não ___', 'trabalhaste', ['noite', 'gado'], 'Certo: Jonas não trabalhou pela planta.', ['Noite é o tempo da planta.', 'Gado é da cidade.']),
        gap('cento e vinte mil ___', 'pessoas', ['noite', 'gado'], 'Certo: a cidade tem milhares de pessoas.', ['Noite é o tempo da planta.', 'Gado também é contado, mas não nesta lacuna.']),
      ],
      connect: [
        link(['Cidade maior que a planta', 'Pena sem contraste', 'Gado esquecido'], 0, 'Certo: Nínive pesa mais que a planta.', ['O contraste é o ponto.', 'O gado também entra.']),
        link(['Planta que justifica a ira', 'Compaixão mais larga', 'Noite sem cidade'], 1, 'Certo: a pergunta alarga a compaixão.', ['A planta não ganha a discussão.', 'A cidade é nomeada.']),
        link(['Profeta mais misericordioso', 'Deus que vê a cidade', 'Planta eterna'], 1, 'Certo: quem vê Nínive é Jeová.', ['Jonas para na planta.', 'A planta durou uma noite.']),
      ],
    },
  ]),
];
