import { buildScene } from './_weak_scene_build.mjs';

const V = {
  osToma:
    'Quando Jeová falou, ao princípio, com Oseias, disse Jeová a Oseias: Vai, toma uma mulher de fornicação e filhos de fornicação, porque a terra comete fornicação, apartando-se de Jeová.',
  osDeserto:
    'Portanto, eis que eu a atrairei, e a levarei para o deserto, e lhe falarei ao coração. Dali, lhe darei as suas vinhas e o vale de Acor, para uma porta de esperança; ali, cantará ela como nos dias da sua mocidade e como no dia em que subiu da terra do Egito.',
  osMenino:
    'Quando Israel era menino, eu o amei e do Egito chamei a meu filho. Todavia, eu ensinava a Efraim a andar; levava-os nos meus braços, porém não conheceram que eu os curava. Eu os atraía com cordas de homem, com laços de amor; eu era para com eles como quem tira o jugo de cima dos seus queixos e lhes punha diante o mantimento.',
  jlComeu:
    'O gafanhoto comeu o que a lagarta deixou; e o brugo comeu o que o gafanhoto deixou; e o hasil comeu o que o brugo deixou.',
  jlCoracao:
    'Rasgai o vosso coração, e não os vossos vestidos, e convertei-vos a Jeová, vosso Deus, porque ele é clemente, cheio de compaixão, tardio para se irar e de muita misericórdia e se arrepende do mal.',
  jlAnos:
    'Restituir-vos-ei os anos que tem comido o gafanhoto, o brugo, o hasil e a lagarta, o meu grande exército que enviei entre vós.',
  amConhecido:
    'De todas as famílias da terra só a vós vos tenho conhecido; portanto, visitarei sobre vós todas as vossas iniquidades.',
  amBem:
    'Buscai o bem e não o mal, para que vivais; e assim Jeová, Deus dos Exércitos, será convosco, como dizeis. Aborrecei o mal, e amai o bem, e estabelecei na porta o juízo. Pode ser que Jeová, Deus dos Exércitos, se compadeça do resto de José.',
  amPastor:
    'Então, respondeu Amós e disse a Amazias: Eu não era profeta nem filho de profeta, mas era pastor de gado e cultivador de sicômoros. Jeová tirou-me de seguir o rebanho e disse-me: Vai, profetiza ao meu povo de Israel.',
  obSoberba:
    'A soberba do teu coração acaba de te enganar, ó tu que habitas nas fendas do penhasco, e cuja habitação é elevada; que dizes no teu coração: Quem me derrubará em terra? Embora subas ao alto como águia, e embora seja o teu ninho posto entre as estrelas, dali te derrubarei, diz Jeová.',
  obIrmao:
    'Por causa da violência feita a teu irmão Jacó, cobrir-te-á a vergonha, e serás exterminado para sempre. No dia em que estiveste do lado oposto, no dia em que estrangeiros lhe levaram os bens, e forasteiros lhe entraram nas portas e deitaram sortes sobre Jerusalém, tu também eras como um deles.',
  obDia:
    'Pois o Dia de Jeová está perto sobre todas as nações; como tens feito, assim se te fará a ti; o teu feito tornará sobre a tua cabeça.',
};

function pack(trail, bank, module, scenes) {
  return { trail, bank, module, built: scenes.map((item) => buildScene({ trail, ...item })) };
}

const tf = (claim, answer, ok, why) => ({ claim, answer, ok, why });
const tap = (quote, word, wrong, ok, why) => ({ quote, word, wrong, ok, why });
const ch = (q, ok, options, why) => ({ q, ok, options, why });
const gap = (template, word, wrong, ok, why) => ({ template, word, wrong, ok, why });
const link = (options, correct, ok, why) => ({ options, correct, ok, why });

export const MORE_PACKS_2 = [
  pack('oseias', 'ot', { title: 'O pai', icon: '💔', section: 'pai' }, [
    {
      slug: 'os-03-fornicacao',
      title: 'Uma mulher de fornicação',
      intro: 'Jeová manda Oseias tomar uma mulher infiel. O casamento vira espelho da terra que se aparta.',
      hookRef: 'Oséias 1:2',
      verse: V.osToma,
      note: 'O profeta não observa de fora. A dor do adultério entra na casa dele.',
      insight: 'Infidelidade a Deus é adultério',
      objective: 'Sair sabendo que o casamento de Oseias retrata a terra apartada de Jeová.',
      echo: 'Deus pede misericórdia, não só sacrifício. Como essa dor aparece na vida do profeta?',
      keyword: 'Adultério',
      gloss: 'A terra se aparta de Jeová como quem quebra a aliança.',
      context: 'Jeová manda Oseias tomar mulher de fornicação porque a terra se aparta dele.',
      tf: [
        tf('Jeová manda Oseias tomar uma mulher de fornicação.', 'true', 'Certo: a ordem abre o livro.', 'O versículo traz essa ordem a Oseias.'),
        tf('A fornicação, no texto, é só da família e não tem a ver com a terra.', 'false', 'Certo: a terra é quem se aparta de Jeová.', 'O porque da ordem é a fornicação da terra.'),
        tf('O casamento do profeta torna visível a aliança rompida.', 'true', 'Certo: a casa de Oseias espelha a terra.', 'Jeová liga a ordem ao afastamento da terra.'),
      ],
      tap: [
        tap('uma mulher de ___', 'fornicação', ['filhos', 'terra'], 'Exato: mulher de fornicação.', ['Filhos vêm na sequência.', 'Terra é quem comete o mesmo mal.']),
        tap('e ___ de fornicação', 'filhos', ['mulher', 'terra'], 'Exato: também filhos de fornicação.', ['Mulher é a primeira ordem.', 'Terra explica o porque.']),
        tap('ao ___, com Oseias', 'princípio', ['mulher', 'terra'], 'Exato: Jeová falou ao princípio.', ['Mulher é a ordem, não o tempo.', 'Terra é a razão, não o momento.']),
      ],
      choice: [
        ch('O que Jeová ordena a Oseias?', 'Certo: tomar mulher infiel por causa da terra.', ['Tomar uma mulher de fornicação, porque a terra se aparta.', 'Deixar a terra e calar até o povo pedir.', 'Casar com uma princesa para selar paz com Judá.', 'Oferecer o filho no templo em lugar do casamento.'], ['Jeová fala; não manda calar.', 'Não há aliança política neste versículo.', 'O versículo não fala de oferta no templo.']),
        ch('Por que o casamento do profeta importa para ler o livro?', 'Certo: a casa dele mostra a infidelidade do povo.', ['A dor da casa revela a dor de Jeová com a terra.', 'O casamento é detalhe privado, sem ligação com Israel.', 'A terra permanece fiel, e só a mulher erra.', 'Oseias escolhe a mulher sem ordem de Jeová.'], ['Jeová liga a ordem à terra.', 'O texto acusa a terra, não só a mulher.', 'A ordem vem de Jeová.']),
        ch('O que essa ordem impede o leitor de pensar?', 'Certo: infidelidade a Deus não é falta leve.', ['Que apartar-se de Deus é quebra de aliança.', 'Que Jeová é indiferente ao culto de outros deuses.', 'Que o profeta fica de fora da dor do povo.', 'Que a terra é fiel e o problema é só político.'], ['A imagem do adultério mostra que dói.', 'Oseias entra na história, não observa de fora.', 'O texto fala de apartar-se de Jeová.']),
      ],
      order: {
        pieces: ['Jeová fala com Oseias ao princípio.', 'Manda tomar mulher e filhos de fornicação.', 'A razão é a terra que se aparta de Jeová.'],
        ok: 'Certo: fala, ordem e então a razão.',
        why: ['A ordem vem depois de Jeová falar.', 'A terra explica a ordem, não a precede.'],
      },
      complete: [
        gap('porque a ___ comete fornicação', 'terra', ['mulher', 'filhos'], 'Certo: a terra comete fornicação.', ['Mulher é quem ele deve tomar.', 'Filhos acompanham a ordem.']),
        gap('disse Jeová a ___', 'Oseias', ['terra', 'filhos'], 'Certo: a ordem é dita a Oseias.', ['Terra é a razão, não o ouvinte.', 'Filhos fazem parte da ordem.']),
        gap('toma uma ___ de fornicação', 'mulher', ['terra', 'princípio'], 'Certo: ele deve tomar uma mulher.', ['Terra é quem se aparta.', 'Princípio marca o tempo da fala.']),
      ],
      connect: [
        link(['Aliança rompida', 'Paz com Judá', 'Culto no templo'], 0, 'Certo: a ordem mostra a terra infiel.', ['Não há tratado neste versículo.', 'Não se fala de templo.']),
        link(['Casa como espelho', 'Ordem sem motivo', 'Terra ainda fiel'], 0, 'Certo: a casa do profeta espelha a terra.', ['O porque está dito.', 'A terra se aparta.']),
        link(['Falta sem peso', 'Adultério da terra', 'Silêncio do profeta'], 1, 'Certo: apartar-se de Jeová é infidelidade.', ['A imagem pesa como adultério.', 'Jeová fala; Oseias não fica mudo.']),
      ],
    },
    {
      slug: 'os-04-deserto',
      title: 'Falarei ao coração',
      intro: 'Depois da acusação, Jeová diz que vai atrair, levar ao deserto e abrir uma porta de esperança.',
      hookRef: 'Oséias 2:14–15',
      verse: V.osDeserto,
      note: 'O deserto, aqui, não é abandono. É o lugar onde ele volta a falar ao coração.',
      insight: 'Deus corteja o infiel de volta',
      objective: 'Sair sabendo que Jeová atrai a infiel e promete esperança.',
      echo: 'A infidelidade dói como adultério. O que Jeová faz com a infiel?',
      keyword: 'Esperança',
      gloss: 'O deserto vira lugar de fala e de porta aberta.',
      context: 'Jeová atrai, leva ao deserto, fala ao coração e dá o vale de Acor como porta de esperança.',
      tf: [
        tf('Jeová diz que a atrairá e falará ao seu coração.', 'true', 'Certo: o movimento é atrair e falar.', 'O versículo começa com atrair, levar e falar.'),
        tf('O deserto, neste texto, é o lugar onde ele a abandona em silêncio.', 'false', 'Certo: no deserto ele fala ao coração.', 'Levar ao deserto vem junto com falar.'),
        tf('O vale de Acor é chamado porta de esperança.', 'true', 'Certo: Acor vira porta, não só memória de culpa.', 'O texto dá esse nome ao vale.'),
      ],
      tap: [
        tap('lhe falarei ao ___', 'coração', ['deserto', 'vinhas'], 'Exato: ele fala ao coração.', ['Deserto é o lugar.', 'Vinhas são o dom que vem dali.']),
        tap('para o ___', 'deserto', ['coração', 'Egito'], 'Exato: ele a leva para o deserto.', ['Coração é a quem ele fala.', 'Egito é a memória da saída.']),
        tap('porta de ___', 'esperança', ['vinhas', 'deserto'], 'Exato: Acor é porta de esperança.', ['Vinhas são o dom ao lado.', 'Deserto é o caminho, não o nome da porta.']),
      ],
      choice: [
        ch('O que Jeová promete fazer com a infiel?', 'Certo: atrair, levar e falar ao coração.', ['Atraí-la e falar-lhe ao coração.', 'Entregá-la ao silêncio do deserto.', 'Fechar o vale e apagar a mocidade.', 'Devolvê-la ao Egito sem esperança.'], ['No deserto ele fala.', 'Acor é porta de esperança.', 'Ela canta como no dia em que subiu do Egito.']),
        ch('O que o deserto significa nesta promessa?', 'Certo: é lugar de fala, não de descarte.', ['Lugar onde ele volta a falar ao coração.', 'Castigo final, sem palavra e sem volta.', 'Troca da aliança por outra terra.', 'Fim da esperança no vale de Acor.'], ['Há fala e porta de esperança.', 'Ele a leva para restaurar, não para substituir.', 'Acor é chamado esperança.']),
        ch('O que essa promessa revela sobre o juízo de Jeová?', 'Certo: o juízo não é a última palavra dele.', ['Depois da acusação, ele ainda corteja.', 'A infiel fica sem caminho de volta.', 'Esperança aqui é só nostalgia do Egito.', 'Falar ao coração anula a aliança.'], ['Há porta de esperança.', 'O canto lembra a saída, não a volta ao jugo.', 'A fala confirma o cuidado, não o cancela.']),
      ],
      order: {
        pieces: ['Jeová a atrai e a leva ao deserto.', 'Ali fala ao coração.', 'Dá vinhas e o vale de Acor como porta de esperança.'],
        ok: 'Certo: atrair, falar e então a porta.',
        why: ['A fala acontece no deserto, não antes da atração.', 'A esperança fecha a promessa.'],
      },
      complete: [
        gap('eu a ___', 'atrairei', ['deserto', 'vinhas'], 'Certo: ele a atrairá.', ['Deserto é o destino.', 'Vinhas são o dom posterior.']),
        gap('vale de ___', 'Acor', ['deserto', 'Egito'], 'Certo: o vale é Acor.', ['Deserto é para onde ele a leva.', 'Egito é a memória da subida.']),
        gap('nos dias da sua ___', 'mocidade', ['vinhas', 'coração'], 'Certo: ela cantará como na mocidade.', ['Vinhas são o dom da terra.', 'Coração é a quem ele fala.']),
      ],
      connect: [
        link(['Convite de volta', 'Silêncio final', 'Volta ao Egito'], 0, 'Certo: ele atrai a infiel de volta.', ['Ele fala ao coração.', 'O canto lembra a saída, não a volta ao jugo.']),
        link(['Deserto sem voz', 'Fala no deserto', 'Porta fechada'], 1, 'Certo: o deserto é lugar de fala.', ['Ele promete falar.', 'Acor é porta de esperança.']),
        link(['Juízo sem fim', 'Cortejo depois da culpa', 'Nostalgia vazia'], 1, 'Certo: a culpa não fecha a boca de Deus.', ['Há esperança depois da acusação.', 'A promessa é concreta: vinhas e porta.']),
      ],
    },
    {
      slug: 'os-05-menino',
      title: 'Quando Israel era menino',
      intro: 'Jeová lembra o amor de pai: chamou o filho do Egito, ensinou a andar e tirou o jugo.',
      hookRef: 'Oséias 11:1–4',
      verse: V.osMenino,
      note: 'O tom muda de tribunal para colo. A infidelidade dói porque o laço era de pai.',
      insight: 'O amor de Deus é de pai',
      objective: 'Sair sabendo que Jeová amou Israel como filho e o curou sem ser reconhecido.',
      echo: 'Ele corteja a infiel. Que tipo de amor está por trás desse cortejo?',
      keyword: 'Filho',
      gloss: 'Deus ensina a andar, carrega nos braços e põe o mantimento.',
      context: 'Jeová amou Israel menino, chamou-o do Egito e o atraiu com laços de amor.',
      tf: [
        tf('Jeová diz que amou Israel quando era menino e o chamou do Egito.', 'true', 'Certo: o amor é de pai, desde o Egito.', 'O versículo abre com esse amor e esse chamado.'),
        tf('Efraim reconheceu logo que Jeová o curava.', 'false', 'Certo: não conheceram que ele os curava.', 'O texto marca o não reconhecimento.'),
        tf('Os laços com que Jeová atrai são laços de amor, não só de força.', 'true', 'Certo: cordas de homem e laços de amor.', 'Ele também tira o jugo e põe o mantimento.'),
      ],
      tap: [
        tap('Quando Israel era ___, eu o amei', 'menino', ['Egito', 'filho'], 'Exato: Israel era menino.', ['Egito é de onde o chamou.', 'Filho é como o chama.']),
        tap('do ___ chamei a meu filho', 'Egito', ['menino', 'amor'], 'Exato: o chamado sai do Egito.', ['Menino é a idade do amor.', 'Amor nomeia os laços.']),
        tap('com laços de ___', 'amor', ['braços', 'jugo'], 'Exato: os laços são de amor.', ['Braços são onde os levava.', 'Jugo é o que ele tira.']),
      ],
      choice: [
        ch('Como Jeová descreve o que fez por Israel?', 'Certo: amou, chamou, ensinou e alimentou.', ['Amou o menino e o chamou do Egito.', 'Deixou o filho no Egito sem chamar.', 'Cobrou o jugo e escondeu o mantimento.', 'Esperou que Efraim o curasse primeiro.'], ['Ele chama do Egito.', 'Ele tira o jugo e põe comida.', 'Quem cura é Jeová, não Efraim.']),
        ch('O que o não reconhecimento de Efraim revela?', 'Certo: o cuidado veio antes da gratidão.', ['Jeová curava e eles não conheceram.', 'Efraim entendeu cedo e retribuiu logo.', 'Os braços de Jeová eram castigo sem cura.', 'O mantimento dependia de eles pedirem certo.'], ['O texto diz que não conheceram.', 'Ele os levava nos braços para curar.', 'Ele põe o mantimento diante deles.']),
        ch('Que imagem de Deus Oséias 11 sustenta?', 'Certo: Deus se relaciona como pai que carrega.', ['Pai que ensina a andar e tira o jugo.', 'Juiz que só acusa e não se aproxima.', 'Rei que exige filho sem dar pão.', 'Estrangeiro que chama e depois some.'], ['Há braços, laços e mantimento.', 'O chamado tira do Egito.', 'O cuidado continua depois do chamado.']),
      ],
      order: {
        pieces: ['Jeová amou Israel menino e o chamou do Egito.', 'Ensinou Efraim a andar e o levou nos braços.', 'Atraiu com laços de amor, tirou o jugo e deu mantimento.'],
        ok: 'Certo: amor, colo e então o pão.',
        why: ['O colo vem depois do chamado do Egito.', 'O mantimento fecha o cuidado.'],
      },
      complete: [
        gap('chamei a meu ___', 'filho', ['menino', 'Egito'], 'Certo: chamou a seu filho.', ['Menino diz a idade.', 'Egito é o lugar.']),
        gap('nos meus ___', 'braços', ['amor', 'jugo'], 'Certo: levava-os nos braços.', ['Amor nomeia os laços.', 'Jugo é o que ele remove.']),
        gap('lhes punha diante o ___', 'mantimento', ['filho', 'Egito'], 'Certo: ele punha o mantimento diante deles.', ['Filho é quem recebe.', 'Egito ficou para trás.']),
      ],
      connect: [
        link(['Amor de pai', 'Chamado vazio', 'Jugo permanente'], 0, 'Certo: a memória é de pai.', ['Ele chama e carrega.', 'Ele tira o jugo.']),
        link(['Cura ignorada', 'Filho que ensina', 'Pão escondido'], 0, 'Certo: eles não conheceram a cura.', ['Quem ensina a andar é Jeová.', 'O mantimento é posto diante deles.']),
        link(['Distância de rei', 'Colo que alimenta', 'Egito como casa'], 1, 'Certo: Deus se chega como quem alimenta.', ['Há braços e pão.', 'Egito é de onde ele chama, não a casa final.']),
      ],
    },
  ]),
  pack('joel', 'ot', { title: 'A volta', icon: '🌾', section: 'volta' }, [
    {
      slug: 'jl-03-gafanhoto',
      title: 'O que o gafanhoto deixou',
      intro: 'Joel abre com uma cadeia de perda: o que um inseto deixa, o outro come.',
      hookRef: 'Joel 1:4',
      verse: V.jlComeu,
      note: 'O juízo chega como colheita que some de mão em mão, até não restar.',
      insight: 'O juízo pode chegar como perda',
      objective: 'Sair sabendo que Joel descreve o juízo como uma perda que se completa.',
      echo: 'Há promessa do Espírito. Antes dela, o que a terra perdeu?',
      keyword: 'Perda',
      gloss: 'Nada do que um come sobra para o povo: outro come o resto.',
      context: 'Gafanhoto, brugo e hasil comem em sequência o que o anterior deixou.',
      tf: [
        tf('O gafanhoto comeu o que a lagarta deixou.', 'true', 'Certo: a perda passa de um ao outro.', 'A primeira frase é essa passagem.'),
        tf('O hasil deixou sobra bastante depois de comer.', 'false', 'Certo: o hasil come o que o brugo deixou.', 'A cadeia não anuncia sobra para o povo.'),
        tf('A sequência mostra um juízo que não deixa resto.', 'true', 'Certo: cada um come o que o outro poupou.', 'O versículo é uma cadeia sem folga.'),
      ],
      tap: [
        tap('O ___ comeu o que a lagarta deixou', 'gafanhoto', ['brugo', 'hasil'], 'Exato: o gafanhoto come o resto da lagarta.', ['Brugo vem na frase seguinte.', 'Hasil fecha a cadeia.']),
        tap('o ___ comeu o que o gafanhoto deixou', 'brugo', ['lagarta', 'hasil'], 'Exato: o brugo come o resto do gafanhoto.', ['Lagarta é a primeira.', 'Hasil come o resto do brugo.']),
        tap('o que a ___ deixou', 'lagarta', ['brugo', 'hasil'], 'Exato: a lagarta é a primeira a deixar resto.', ['Brugo come depois do gafanhoto.', 'Hasil é o último da cadeia.']),
      ],
      choice: [
        ch('O que Joel 1:4 descreve?', 'Certo: uma perda que passa de inseto a inseto.', ['Uma cadeia em que cada um come o resto.', 'Uma colheita farta repartida entre o povo.', 'Um só inseto que deixa a maior parte.', 'A volta da chuva antes de qualquer perda.'], ['O tom é de consumo, não de fartura.', 'Cada um come o que o outro deixou.', 'A chuva não está neste versículo.']),
        ch('Por que a ordem dos insetos importa?', 'Certo: a perda se completa em etapas.', ['O que sobra de um vira comida do seguinte.', 'A ordem mostra que a praga foi leve.', 'O hasil devolve o que o gafanhoto comeu.', 'A lagarta chega por último e restaura o campo.'], ['Nada indica praga leve.', 'Ninguém devolve; todos comem.', 'A lagarta abre a cadeia.']),
        ch('O que essa cadeia prepara o leitor para ouvir?', 'Certo: o juízo pode esvaziar a colheita inteira.', ['Que a perda pode não deixar resto.', 'Que Deus ignora o que acontece no campo.', 'Que o povo guardou celeiro cheio.', 'Que inseto nenhum tocou a terra.'], ['O versículo é o retrato da perda.', 'Não há celeiro salvo aqui.', 'A terra é comida até o fim.']),
      ],
      order: {
        pieces: ['O gafanhoto comeu o que a lagarta deixou.', 'O brugo comeu o que o gafanhoto deixou.', 'O hasil comeu o que o brugo deixou.'],
        ok: 'Certo: lagarta, gafanhoto, brugo e então o hasil.',
        why: ['O brugo vem depois do gafanhoto.', 'O hasil fecha a cadeia.'],
      },
      complete: [
        gap('o que a ___ deixou', 'lagarta', ['gafanhoto', 'brugo'], 'Certo: a lagarta deixou o que o gafanhoto comeu.', ['Gafanhoto é quem come esse resto.', 'Brugo vem depois.']),
        gap('e o ___ comeu o que o brugo deixou', 'hasil', ['lagarta', 'gafanhoto'], 'Certo: o hasil come o resto do brugo.', ['Lagarta abre a sequência.', 'Gafanhoto está no meio.']),
        gap('comeu o que o ___ deixou', 'brugo', ['hasil', 'lagarta'], 'Certo: o hasil come o que o brugo deixou.', ['Hasil é quem come, não quem deixou nesta lacuna.', 'Lagarta é a primeira.']),
      ],
      connect: [
        link(['Perda sem resto', 'Colheita guardada', 'Chuva antecipada'], 0, 'Certo: a cadeia não deixa sobra.', ['Nada é guardado neste versículo.', 'Não se fala de chuva.']),
        link(['Praga leve', 'Perda em etapas', 'Campo restaurado'], 1, 'Certo: um resto vira comida do próximo.', ['A cadeia não é leve.', 'Ninguém restaura o campo aqui.']),
        link(['Acaso no campo', 'Juízo que esvazia', 'Festa da safra'], 1, 'Certo: a perda retrata um juízo.', ['Não é detalhe solto: é sequência.', 'Não há festa de safra.']),
      ],
    },
    {
      slug: 'jl-04-coracao',
      title: 'Rasgai o coração',
      intro: 'Joel não pede só roupa rasgada. Pede o coração, porque Jeová é clemente e tardio em irar-se.',
      hookRef: 'Joel 2:13',
      verse: V.jlCoracao,
      note: 'O gesto externo não substitui a volta. O convite apoia-se em quem Deus é.',
      insight: 'Deus quer o coração, não só a veste',
      objective: 'Sair sabendo que a conversão que Joel pede é interior e se apoia na misericórdia.',
      echo: 'A colheita foi comida. O que Jeová pede em resposta?',
      keyword: 'Coração',
      gloss: 'Rasgar a veste sem o coração não é a volta que ele pede.',
      context: 'Joel manda rasgar o coração, não os vestidos, e converter-se ao Deus clemente.',
      tf: [
        tf('Joel manda rasgar o coração e não os vestidos.', 'true', 'Certo: o corte pedido é interior.', 'O versículo opõe coração e vestidos.'),
        tf('A razão da volta é que Jeová é duro e rápido para se irar.', 'false', 'Certo: ele é clemente e tardio em irar-se.', 'O texto lista compaixão, misericórdia e arrependimento do mal.'),
        tf('A conversão se apoia no caráter de Deus, não no gesto da roupa.', 'true', 'Certo: o porque é quem ele é.', 'Clemente, compassivo e misericordioso sustentam o convite.'),
      ],
      tap: [
        tap('Rasgai o vosso ___', 'coração', ['vestidos', 'Deus'], 'Exato: o que se rasga é o coração.', ['Vestidos são o que não se deve rasgar no lugar.', 'Deus é para quem eles se convertem.']),
        tap('não os vossos ___', 'vestidos', ['coração', 'mal'], 'Exato: não são os vestidos.', ['Coração é o que deve ser rasgado.', 'Mal é aquilo de que ele se arrepende.']),
        tap('cheio de ___', 'compaixão', ['coração', 'vestidos'], 'Exato: ele é cheio de compaixão.', ['Coração é o do povo.', 'Vestidos são o gesto recusado.']),
      ],
      choice: [
        ch('O que Joel pede que o povo rasgue?', 'Certo: o coração, não a roupa.', ['O coração, e não os vestidos.', 'Os vestidos, deixando o coração intacto.', 'O nome de Deus, em sinal de luto.', 'A misericórdia, para merecer a volta.'], ['Os vestidos são o contraste negativo.', 'Não se rasga o nome de Deus.', 'A misericórdia é dele, não o que o povo rasga.']),
        ch('Em que o convite se apoia?', 'Certo: em quem Jeová é.', ['Na clemência e na misericórdia de Jeová.', 'No medo de um Deus que não se arrepende.', 'No valor do pano rasgado diante dos outros.', 'Na certeza de que o coração pode ficar fechado.'], ['Ele é tardio em irar-se e se arrepende do mal.', 'O pano é justamente o que não basta.', 'O coração é o que deve abrir-se.']),
        ch('O que esse convite corrige?', 'Certo: luto que fica só na aparência.', ['Aparência de luto sem volta do coração.', 'A ideia de que Deus é misericordioso.', 'O chamado para se converter a Jeová.', 'A pressa de rasgar o que está por dentro.'], ['Misericórdia é a razão da volta.', 'Converter-se está no versículo.', 'O interior é o que ele pede.']),
      ],
      order: {
        pieces: ['Rasgai o coração, não os vestidos.', 'Convertei-vos a Jeová, vosso Deus.', 'Ele é clemente, compassivo e tardio em irar-se.'],
        ok: 'Certo: coração, volta e então o caráter de Deus.',
        why: ['A conversão vem com o rasgar do coração.', 'O caráter de Deus fundamenta o convite no fim.'],
      },
      complete: [
        gap('convertei-vos a ___, vosso Deus', 'Jeová', ['coração', 'vestidos'], 'Certo: a volta é para Jeová.', ['Coração é o que se rasga.', 'Vestidos não são o destinatário.']),
        gap('tardio para se ___', 'irar', ['coração', 'mal'], 'Certo: ele é tardio para se irar.', ['Coração é o do povo.', 'Mal é o que ele deixa.']),
        gap('se arrepende do ___', 'mal', ['vestidos', 'coração'], 'Certo: ele se arrepende do mal.', ['Vestidos são o gesto humano.', 'Coração é o que o povo deve rasgar.']),
      ],
      connect: [
        link(['Volta interior', 'Roupa rasgada', 'Ira apressada'], 0, 'Certo: o pedido é o coração.', ['A roupa é o que não basta.', 'Ele é tardio em irar-se.']),
        link(['Deus fechado', 'Misericórdia que chama', 'Luto só externo'], 1, 'Certo: o convite nasce de quem ele é.', ['Ele é clemente.', 'O externo sem coração é recusado.']),
        link(['Gestos que bastam', 'Coração convertido', 'Medo sem volta'], 1, 'Certo: Deus quer o interior convertido.', ['A veste não substitui o coração.', 'Há convite, não só medo.']),
      ],
    },
    {
      slug: 'jl-05-anos',
      title: 'Restituirei os anos',
      intro: 'O mesmo exército que comeu a colheita não tem a última palavra. Jeová promete restituir os anos.',
      hookRef: 'Joel 2:25',
      verse: V.jlAnos,
      note: 'Gafanhoto, brugo, hasil e lagarta são chamados o grande exército dele. A perda também cabe na mão que restitui.',
      insight: 'Deus restitui o que o juízo comeu',
      objective: 'Sair sabendo que Jeová promete devolver os anos consumidos pela praga.',
      echo: 'Ele pediu o coração. O que promete a quem volta?',
      keyword: 'Restituição',
      gloss: 'Os anos comidos não ficam perdidos para sempre.',
      context: 'Jeová restituirá os anos que o gafanhoto e o seu exército comeram.',
      tf: [
        tf('Jeová promete restituir os anos que o gafanhoto comeu.', 'true', 'Certo: a perda não é a última frase.', 'O versículo abre com restituir.'),
        tf('O exército da praga é chamado de outro deus, não de Jeová.', 'false', 'Certo: é o grande exército que ele enviou.', 'O texto diz “que enviei”.'),
        tf('Restituir, aqui, significa que o juízo não esgota a bondade de Deus.', 'true', 'Certo: quem enviou a praga também devolve os anos.', 'O mesmo Senhor fala em restituir.'),
      ],
      tap: [
        tap('Restituir-vos-ei os ___', 'anos', ['gafanhoto', 'exército'], 'Exato: ele restitui os anos.', ['Gafanhoto é quem comeu.', 'Exército nomeia a praga.']),
        tap('o meu grande ___', 'exército', ['anos', 'hasil'], 'Exato: a praga é o grande exército dele.', ['Anos são o que se devolve.', 'Hasil é um dos que comeram.']),
        tap('e a ___, o meu grande', 'lagarta', ['anos', 'exército'], 'Exato: a lagarta está na lista dos que comeram.', ['Anos são o que se restitui.', 'Exército é o nome do conjunto.']),
      ],
      choice: [
        ch('O que Jeová promete em Joel 2:25?', 'Certo: devolver os anos consumidos.', ['Restituir os anos que a praga comeu.', 'Enviar outro exército para acabar o resto.', 'Esquecer os anos sem devolver nada.', 'Trocar o gafanhoto por uma festa sem colheita.'], ['A promessa é restituir, não repetir a perda.', 'Ele fala em devolver.', 'A colheita comida é o que entra na conta.']),
        ch('Quem enviou o exército que comeu os anos?', 'Certo: o próprio Jeová, que agora restitui.', ['Jeová, que chama a praga de meu exército.', 'Um inimigo à parte, sem ligação com ele.', 'O povo, que soltou os insetos no campo.', 'Ninguém: a praga não tem remetente.'], ['Ele diz “que enviei”.', 'Não é o povo quem envia.', 'Há um eu que enviou.']),
        ch('O que a restituição diz sobre o juízo?', 'Certo: o juízo não é o fim da história com Deus.', ['Quem feriu a colheita pode devolvê-la.', 'O juízo apaga os anos para sempre.', 'Restituir significa que a praga foi um engano.', 'O exército fica e os anos não voltam.'], ['A promessa é que os anos voltam.', 'Ele assume o envio e ainda assim restitui.', 'Os anos são o que ele devolve.']),
      ],
      order: {
        pieces: ['A praga comeu os anos do povo.', 'Jeová chama esse conjunto de meu grande exército.', 'Ele promete restituir o que foi comido.'],
        ok: 'Certo: perda, exército dele e então a restituição.',
        why: ['O nome exército interpreta a praga, não a antecede.', 'Restituir é a promessa final.'],
      },
      complete: [
        gap('o brugo, o ___ e a lagarta', 'hasil', ['anos', 'exército'], 'Certo: hasil está na lista dos que comeram.', ['Anos são o que se restitui.', 'Exército é o nome do conjunto.']),
        gap('que ___ entre vós', 'enviei', ['anos', 'gafanhoto'], 'Certo: ele enviou o exército.', ['Anos são o objeto da volta.', 'Gafanhoto é parte do exército.']),
        gap('os anos que tem comido o ___', 'gafanhoto', ['exército', 'hasil'], 'Certo: o gafanhoto encabeça os que comeram.', ['Exército é o conjunto.', 'Hasil vem na lista, não nesta lacuna.']),
      ],
      connect: [
        link(['Anos devolvidos', 'Praga sem dono', 'Perda eterna'], 0, 'Certo: a promessa é restituir.', ['Ele diz que enviou.', 'Os anos não ficam perdidos.']),
        link(['Exército alheio', 'Mão que devolve', 'Campo esquecido'], 1, 'Certo: quem enviou também restitui.', ['É o exército dele.', 'Ele se dirige ao povo.']),
        link(['Juízo sem amanhã', 'Bondade depois da perda', 'Festa sem colheita'], 1, 'Certo: há futuro depois do que foi comido.', ['A restituição abre o amanhã.', 'O que volta é o que a praga comeu.']),
      ],
    },
  ]),
];
