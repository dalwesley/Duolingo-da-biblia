import { buildScene } from './_weak_scene_build.mjs';

const V = {
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
  hcTemplo:
    'Jeová, porém, está no seu santo templo; cale-se diante dele toda a terra.',
  hcFigueira:
    'Pois, embora não floresça a figueira, nem haja fruto nas vides; embora falhe o produto da oliveira, e os campos não produzam mantimento; embora o rebanho seja exterminado do curral, e não haja gado nos presépios, contudo, eu me regozijarei em Jeová, exultarei no Deus da minha salvação.',
  sfDia:
    'O grande Dia de Jeová está perto e vem chegando a toda a pressa, a saber, a voz do Dia de Jeová; ali, o valente clama amargamente.',
  sfMansos:
    'Buscai a Jeová, todos os mansos da terra, que tendes posto por obra o seu juízo; buscai a justiça, buscai a mansidão; pode ser que sejais escondidos no dia da ira de Jeová.',
  sfLingua:
    'Nesse tempo, darei aos povos uma língua pura, para que todos invoquem o nome de Jeová, a fim de o servirem de um só acordo.',
};

function pack(trail, bank, module, scenes) {
  return { trail, bank, module, built: scenes.map((item) => buildScene({ trail, ...item })) };
}
const tf = (claim, answer, ok, why) => ({ claim, answer, ok, why });
const tap = (quote, word, wrong, ok, why) => ({ quote, word, wrong, ok, why });
const ch = (q, ok, options, why) => ({ q, ok, options, why });
const gap = (template, word, wrong, ok, why) => ({ template, word, wrong, ok, why });
const link = (options, correct, ok, why) => ({ options, correct, ok, why });

export const MORE_PACKS_3 = [
  pack('amos', 'ot', { title: 'O chamado', icon: '🐑', section: 'chamado-amos' }, [
    {
      slug: 'am-03-conhecido',
      title: 'Só a vós tenho conhecido',
      intro: 'Amós diz que conhecer Israel não é favor sem conta. A eleição aumenta a visita sobre a iniquidade.',
      hookRef: 'Amós 3:2',
      verse: V.amConhecido,
      note: '“Conhecer”, aqui, é relação de aliança. Por isso a visita vem sobre este povo, não apesar disso.',
      insight: 'Eleição aumenta a responsabilidade',
      objective: 'Sair sabendo que ser conhecido por Jeová torna a iniquidade mais grave.',
      echo: 'O juízo deve correr como águas. Por que ele começa pela casa conhecida?',
      keyword: 'Conhecer',
      gloss: 'Ser conhecido de Deus é aliança, e aliança pesa.',
      context: 'De todas as famílias, só Israel foi conhecido; por isso a iniquidade será visitada.',
      tf: [
        tf('Jeová diz que, de todas as famílias, só a este povo conheceu.', 'true', 'Certo: o conhecer é particular.', 'O versículo abre com essa exclusividade.'),
        tf('Conhecer o povo, no texto, significa deixar a iniquidade sem visita.', 'false', 'Certo: o portanto é a visita sobre a iniquidade.', 'Conhecer e visitar estão ligados.'),
        tf('A eleição, em Amós, aumenta a conta, não a cancela.', 'true', 'Certo: ser conhecido explica a visita.', 'O portanto une aliança e responsabilidade.'),
      ],
      tap: [
        tap('vos tenho ___', 'conhecido', ['famílias', 'terra'], 'Exato: ele os tem conhecido.', ['Famílias são todas as da terra.', 'Terra é o âmbito das famílias.']),
        tap('todas as ___ da terra', 'famílias', ['iniquidades', 'conhecido'], 'Exato: de todas as famílias.', ['Iniquidades são o que será visitado.', 'Conhecido é o verbo da eleição.']),
        tap('___ sobre vós', 'visitarei', ['famílias', 'terra'], 'Exato: visitarei sobre vós.', ['Famílias são o conjunto das nações.', 'Terra é onde estão as famílias.']),
      ],
      choice: [
        ch('O que “só a vós vos tenho conhecido” explica?', 'Certo: por isso a iniquidade deles é visitada.', ['A visita sobre as iniquidades de Israel.', 'Que as outras famílias são mais culpadas.', 'Que Israel fica livre de prestação de contas.', 'Que conhecer é o mesmo que ignorar o mal.'], ['O portanto aponta para este povo.', 'A visita cai sobre quem foi conhecido.', 'Conhecer não apaga a iniquidade.']),
        ch('Como eleição e juízo se encontram neste versículo?', 'Certo: a aliança torna o mal mais sério.', ['Quem foi conhecido é o primeiro a ser visitado.', 'Eleição e juízo ficam em livros separados.', 'Conhecer cancela as iniquidades de antemão.', 'A terra inteira é conhecida do mesmo modo.'], ['O portanto junta as duas frases.', 'A visita pressupõe o mal, não o apaga.', 'Só a vós marca a diferença.']),
        ch('O que essa frase impede o povo de pensar?', 'Certo: que a aliança é escudo para o mal.', ['Que ser de Deus dispensa a justiça.', 'Que Jeová conhece o povo de perto.', 'Que a iniquidade tem resposta.', 'Que as outras famílias existem na terra.'], ['O conhecer é real.', 'A visita é a resposta.', 'As famílias da terra estão no texto.']),
      ],
      order: {
        pieces: ['De todas as famílias, só este povo foi conhecido.', 'Esse conhecer é de aliança, não de informação.', 'Por isso Jeová visitará as iniquidades deles.'],
        ok: 'Certo: eleição, sentido e então a visita.',
        why: ['O sentido do conhecer prepara o portanto.', 'A visita fecha o versículo.'],
      },
      complete: [
        gap('todas as vossas ___', 'iniquidades', ['famílias', 'terra'], 'Certo: a visita é sobre as iniquidades.', ['Famílias são as da terra.', 'Terra é o lugar delas.']),
        gap('famílias da ___', 'terra', ['conhecido', 'iniquidades'], 'Certo: famílias da terra.', ['Conhecido é o que ele fez com Israel.', 'Iniquidades são o objeto da visita.']),
        gap('visitarei sobre ___', 'vós', ['famílias', 'terra'], 'Certo: a visita é sobre vós.', ['Famílias são o contraste.', 'Terra não é o destinatário direto.']),
      ],
      connect: [
        link(['Conta da aliança', 'Favor sem peso', 'Família qualquer'], 0, 'Certo: conhecer traz responsabilidade.', ['O portanto é uma visita.', 'Não é uma família entre outras.']),
        link(['Juízo sem eleição', 'Aliança que pesa', 'Terra sem nome'], 1, 'Certo: a aliança explica a visita.', ['Há um “só a vós”.', 'O povo é nomeado na segunda pessoa.']),
        link(['Escudo para o mal', 'Eleição responsável', 'Visita às nações só'], 1, 'Certo: eleição não cobre o mal.', ['O mal do povo conhecido é visitado.', 'A visita é sobre vós, não só sobre os outros.']),
      ],
    },
    {
      slug: 'am-04-bem',
      title: 'Buscai o bem',
      intro: 'Amós não separa culto e porta da cidade. Buscar o bem é o caminho para viver.',
      hookRef: 'Amós 5:14–15',
      verse: V.amBem,
      note: 'O juízo na porta é o lugar onde o pobre encontra ou não encontra justiça.',
      insight: 'Deus pede o bem, não só o culto',
      objective: 'Sair sabendo que viver diante de Jeová inclui odiar o mal e julgar na porta.',
      echo: 'Ser conhecido aumenta a conta. O que, então, o povo deve buscar?',
      keyword: 'Bem',
      gloss: 'Buscar o bem e estabelecer o juízo na porta.',
      context: 'Amós manda buscar o bem, odiar o mal e pôr o juízo na porta, para que vivam.',
      tf: [
        tf('Amós manda buscar o bem e não o mal, para que vivam.', 'true', 'Certo: a vida está ligada a buscar o bem.', 'A frase abre o convite.'),
        tf('O juízo deve ficar fora da porta, só dentro do templo.', 'false', 'Certo: o juízo se estabelece na porta.', 'A porta é o lugar nomeado.'),
        tf('Há esperança de compaixão para o resto de José.', 'true', 'Certo: pode ser que Jeová se compadeça.', 'A compaixão é possibilidade, não automática.'),
      ],
      tap: [
        tap('Buscai o ___ e não o mal', 'bem', ['juízo', 'porta'], 'Exato: buscai o bem.', ['Juízo é o que se estabelece na porta.', 'Porta é o lugar do juízo.']),
        tap('na ___ o juízo', 'porta', ['bem', 'mal'], 'Exato: o juízo é na porta.', ['Bem é o que se busca.', 'Mal é o que se aborrece.']),
        tap('Aborrecei o ___', 'mal', ['bem', 'porta'], 'Exato: aborrecei o mal.', ['Bem é o que se ama.', 'Porta é onde o juízo se estabelece.']),
      ],
      choice: [
        ch('O que Amós manda buscar para que o povo viva?', 'Certo: o bem, e não o mal.', ['O bem, em vez do mal.', 'Só o altar, sem olhar a porta.', 'O mal, para conhecer o bem depois.', 'A compaixão, sem mudar o juízo.'], ['A porta entra no mandamento.', 'O mal é o que se deve aborrecer.', 'A compaixão é de Jeová, não o atalho.']),
        ch('O que “na porta” acrescenta ao buscar o bem?', 'Certo: o bem chega ao julgamento público.', ['A justiça tem de aparecer onde as causas se julgam.', 'A porta dispensa odiar o mal.', 'O templo substitui a causa do pobre.', 'Viver não depende do que se busca.'], ['Odiar o mal continua no texto.', 'O juízo na porta é público.', 'O para que vivais liga a busca à vida.']),
        ch('Como a compaixão aparece no convite?', 'Certo: como possibilidade depois da volta ao bem.', ['Pode ser que Jeová se compadeça do resto.', 'A compaixão chega sem buscar o bem.', 'O resto de José já está fora do alcance.', 'Estabelecer o juízo fecha a misericórdia.'], ['O convite vem antes do “pode ser”.', 'Há um resto de quem ele pode se compadecer.', 'O juízo na porta cabe na mesma fala.']),
      ],
      order: {
        pieces: ['Buscai o bem e não o mal, para que vivais.', 'Aborrecei o mal e amai o bem.', 'Estabelecei o juízo na porta.'],
        ok: 'Certo: buscar, odiar o mal e então a porta.',
        why: ['Odiar o mal especifica a busca.', 'A porta é o lugar concreto do juízo.'],
      },
      complete: [
        gap('para que ___', 'vivais', ['mal', 'porta'], 'Certo: buscai o bem para que vivais.', ['Mal é o que se evita.', 'Porta é o lugar do juízo.']),
        gap('estabelecei na porta o ___', 'juízo', ['bem', 'mal'], 'Certo: o que se estabelece é o juízo.', ['Bem é o que se busca e se ama.', 'Mal é o que se aborrece.']),
        gap('do resto de ___', 'José', ['porta', 'bem'], 'Certo: o resto é de José.', ['Porta é o lugar do juízo.', 'Bem é o caminho, não o nome do resto.']),
      ],
      connect: [
        link(['Bem na porta', 'Culto sozinho', 'Mal útil'], 0, 'Certo: o bem desce até o juízo público.', ['O altar não substitui a porta.', 'O mal é o que se deve odiar.']),
        link(['Vida sem justiça', 'Justiça que faz viver', 'Porta fechada'], 1, 'Certo: buscar o bem é para que vivam.', ['A vida está ligada ao bem.', 'A porta é onde o juízo se abre.']),
        link(['Misericórdia barata', 'Volta que julga reto', 'Resto esquecido'], 1, 'Certo: a compaixão não pula a justiça.', ['Há juízo na porta.', 'O resto de José ainda é nomeado.']),
      ],
    },
    {
      slug: 'am-05-pastor',
      title: 'Não era profeta',
      intro: 'Amós responde a Amazias: não vinha de escola de profetas. Jeová o tirou de seguir o rebanho.',
      hookRef: 'Amós 7:14–15',
      verse: V.amPastor,
      note: 'O chamado não depende do currículo. Pastor de gado e de sicômoros é enviado a Israel.',
      insight: 'Deus chama quem não se candidatou',
      objective: 'Sair sabendo que Jeová tirou Amós do rebanho para profetizar a Israel.',
      echo: 'O bem se busca na porta. Quem Jeová manda dizer isso?',
      keyword: 'Rebanho',
      gloss: 'O profeta era pastor até Jeová o tirar dali.',
      context: 'Amós não era profeta nem filho de profeta; Jeová o tirou do rebanho.',
      tf: [
        tf('Amós diz a Amazias que não era profeta nem filho de profeta.', 'true', 'Certo: ele nega a carreira de profeta.', 'A resposta começa com essa negativa.'),
        tf('Amós se ofereceu sozinho para deixar o rebanho.', 'false', 'Certo: Jeová o tirou de seguir o rebanho.', 'O sujeito do chamado é Jeová.'),
        tf('O chamado alcança quem estava no trabalho comum.', 'true', 'Certo: pastor e cultivador é enviado.', 'Gado e sicômoros são o ofício anterior.'),
      ],
      tap: [
        tap('Eu não era ___', 'profeta', ['gado', 'rebanho'], 'Exato: ele não era profeta.', ['Gado é o que pastoreava.', 'Rebanho é de onde Jeová o tirou.']),
        tap('pastor de ___', 'gado', ['profeta', 'Israel'], 'Exato: era pastor de gado.', ['Profeta é o que ele não era.', 'Israel é o povo a quem vai.']),
        tap('seguir o ___', 'rebanho', ['profeta', 'gado'], 'Exato: Jeová o tirou de seguir o rebanho.', ['Profeta é o ofício negado.', 'Gado especifica o pastoreio.']),
      ],
      choice: [
        ch('Quem tirou Amós de seguir o rebanho?', 'Certo: Jeová, para profetizar a Israel.', ['Jeová, e o mandou a Israel.', 'Amazias, para calar a profecia.', 'O próprio Amós, por ambição de ofício.', 'O rebanho, que o rejeitou.'], ['Amazias é quem ouve a resposta.', 'Amós não se apresenta como candidato.', 'O rebanho é o lugar de onde sai.']),
        ch('O que a negativa “não era profeta” protege?', 'Certo: o chamado não nasce do currículo.', ['A palavra vem de Jeová, não da escola.', 'Amós esconde que cuidava de gado.', 'Israel deixa de ser o destinatário.', 'Sicômoros provam que ele já era sacerdote.'], ['Ele conta o ofício antigo.', 'O mandato é ao povo de Israel.', 'Sicômoros são cultivo, não sacerdócio.']),
        ch('O que esse chamado ensina sobre quem Deus envia?', 'Certo: ele tira gente do trabalho comum.', ['Deus envia quem não se candidatou.', 'Só fala quem nasceu em casa de profeta.', 'O rebanho é mais importante que a palavra.', 'Amazias é quem autoriza o envio.'], ['Amós nega ser filho de profeta.', 'Jeová o tira do rebanho para falar.', 'Quem envia é Jeová, não Amazias.']),
      ],
      order: {
        pieces: ['Amós diz que não era profeta nem filho de profeta.', 'Era pastor de gado e cultivava sicômoros.', 'Jeová o tirou do rebanho e o mandou a Israel.'],
        ok: 'Certo: negativa, ofício e então o envio.',
        why: ['O ofício explica de onde ele veio.', 'O envio fecha a resposta a Amazias.'],
      },
      complete: [
        gap('cultivador de ___', 'sicômoros', ['profeta', 'rebanho'], 'Certo: ele cultivava sicômoros.', ['Profeta é o que ele não era.', 'Rebanho é o pastoreio.']),
        gap('ao meu povo de ___', 'Israel', ['gado', 'profeta'], 'Certo: o povo é Israel.', ['Gado é o ofício antigo.', 'Profeta é o título que ele recusa.']),
        gap('disse a ___', 'Amazias', ['rebanho', 'gado'], 'Certo: a resposta é dita a Amazias.', ['Rebanho é de onde ele saiu.', 'Gado é o que pastoreava.']),
      ],
      connect: [
        link(['Chamado do campo', 'Escola de profetas', 'Silêncio pedido'], 0, 'Certo: Jeová tira o pastor do rebanho.', ['Ele nega ser filho de profeta.', 'A ordem é ir e profetizar.']),
        link(['Currículo primeiro', 'Palavra que chama', 'Rebanho como fim'], 1, 'Certo: a autoridade é o chamado.', ['O ofício antigo não é a fonte.', 'O rebanho é o que ele deixa.']),
        link(['Vocação hereditária', 'Envio sem candidatura', 'Profeta de ofício'], 1, 'Certo: Deus chama quem não se ofereceu.', ['Ele não era filho de profeta.', 'O ofício antigo era outro.']),
      ],
    },
  ]),
  pack('obadias', 'ot', { title: 'O irmão', icon: '⛰️', section: 'irmao' }, [
    {
      slug: 'ob-03-soberba',
      title: 'Quem me derrubará?',
      intro: 'Edom mora no alto e diz que ninguém o derruba. Jeová responde do mesmo alto.',
      hookRef: 'Obadias 3–4',
      verse: V.obSoberba,
      note: 'Penhasco, águia e estrelas não são abrigo quando a soberba engana o coração.',
      insight: 'Altura não protege do juízo',
      objective: 'Sair sabendo que a soberba de Edom será derrubada de onde ela se esconde.',
      echo: 'O reino será de Jeová. O que a altura de Edom não consegue segurar?',
      keyword: 'Soberba',
      gloss: 'O coração elevado se engana ao achar que o penhasco o salva.',
      context: 'A soberba engana Edom; mesmo entre as estrelas, Jeová o derruba.',
      tf: [
        tf('A soberba do coração de Edom acaba de enganá-lo.', 'true', 'Certo: o engano nasce da soberba.', 'O versículo abre com essa frase.'),
        tf('Jeová diz que o ninho entre as estrelas ficará intocado.', 'false', 'Certo: dali ele o derrubará.', 'A altura não cancela a queda.'),
        tf('Segurança geográfica não segura quem se exalta contra Deus.', 'true', 'Certo: penhasco e estrelas não bastam.', 'Jeová derruba de lá.'),
      ],
      tap: [
        tap('A ___ do teu coração', 'soberba', ['águia', 'ninho'], 'Exato: a soberba engana.', ['Águia é a comparação da subida.', 'Ninho é onde ele se põe.']),
        tap('o teu ___ posto entre as estrelas', 'ninho', ['soberba', 'terra'], 'Exato: o ninho está entre as estrelas.', ['Soberba é do coração.', 'Terra é para onde a queda aponta.']),
        tap('fendas do ___', 'penhasco', ['águia', 'estrelas'], 'Exato: ele habita nas fendas do penhasco.', ['Águia é a imagem da subida.', 'Estrelas são a altura do ninho.']),
      ],
      choice: [
        ch('O que Edom diz no coração?', 'Certo: quem me derrubará em terra?', ['Que ninguém o derrubará em terra.', 'Que o penhasco já o entregou.', 'Que a águia o leva para Jeová.', 'Que o ninho entre as estrelas é humilde.'], ['Ele confia na altura.', 'A águia é comparação de subida, não de culto.', 'O ninho alto é vanglória.']),
        ch('O que Jeová responde à altura de Edom?', 'Certo: dali te derrubarei.', ['Mesmo entre as estrelas, ele o derruba.', 'A altura confirma que Edom está seguro.', 'O penhasco anula a palavra de Jeová.', 'A águia é quem executa o juízo.'], ['A resposta é derrubar.', 'Jeová fala contra a segurança.', 'Quem derruba é Jeová.']),
        ch('O que a soberba faz com Edom antes da queda?', 'Certo: engana o coração.', ['Faz o coração confiar na própria altura.', 'Leva Edom a descer do penhasco.', 'Ensina Edom a temer as estrelas.', 'Apaga a frase “quem me derrubará”.'], ['Ele se acha inalcançável.', 'As estrelas são o esconderijo, não o temor.', 'A frase do coração é justamente essa.']),
      ],
      order: {
        pieces: ['A soberba do coração engana Edom.', 'Ele habita no penhasco e põe o ninho entre as estrelas.', 'Jeová diz: dali te derrubarei.'],
        ok: 'Certo: engano, altura e então a queda.',
        why: ['A altura é o esconderijo da soberba.', 'A palavra de Jeová fecha a cena.'],
      },
      complete: [
        gap('subas ao alto como ___', 'águia', ['ninho', 'soberba'], 'Certo: a subida é como águia.', ['Ninho é o lugar entre as estrelas.', 'Soberba é o engano do coração.']),
        gap('entre as ___', 'estrelas', ['penhasco', 'águia'], 'Certo: o ninho está entre as estrelas.', ['Penhasco é a habitação.', 'Águia é a comparação.']),
        gap('dizes no teu ___', 'coração', ['ninho', 'águia'], 'Certo: a frase nasce no coração.', ['Ninho é o esconderijo.', 'Águia é a imagem da subida.']),
      ],
      connect: [
        link(['Altura enganosa', 'Penhasco fiel', 'Águia salvadora'], 0, 'Certo: a altura engana e não salva.', ['O penhasco não o protege.', 'A águia não é salvação.']),
        link(['Abrigo nas estrelas', 'Queda do alto', 'Coração humilde'], 1, 'Certo: do alto Jeová o derruba.', ['As estrelas não são abrigo.', 'O coração está soberbo, não humilde.']),
        link(['Geografia como deus', 'Juízo acima do ninho', 'Segurança eterna'], 1, 'Certo: nenhum ninho fica acima de Jeová.', ['O penhasco virou confiança falsa.', 'A segurança é desmentida.']),
      ],
    },
    {
      slug: 'ob-04-irmao',
      title: 'Violência contra o irmão',
      intro: 'Edom não ficou neutro no dia de Jacó. Ficou do lado oposto e entrou na partilha.',
      hookRef: 'Obadias 10–11',
      verse: V.obIrmao,
      note: 'A vergonha vem da violência contra o irmão, não de uma guerra qualquer.',
      insight: 'Festejar a queda do irmão é culpa',
      objective: 'Sair sabendo que Edom se fez como um dos que saquearam Jerusalém.',
      echo: 'A altura não protege. Contra quem essa altura se voltou?',
      keyword: 'Irmão',
      gloss: 'No dia de Jacó, Edom ficou com os estrangeiros.',
      context: 'A violência contra Jacó cobre Edom de vergonha, porque ele ficou do lado oposto.',
      tf: [
        tf('A vergonha de Edom vem da violência contra o irmão Jacó.', 'true', 'Certo: o irmão é o motivo nomeado.', 'A frase liga violência e vergonha.'),
        tf('Edom ficou ao lado de Jacó e impediu o saque.', 'false', 'Certo: ficou do lado oposto, como um deles.', 'Estrangeiros levaram os bens, e Edom era como eles.'),
        tf('Neutralidade diante da queda do irmão, aqui, já é participação.', 'true', 'Certo: estar do lado oposto o iguala aos saqueadores.', 'O texto diz: tu também eras como um deles.'),
      ],
      tap: [
        tap('a teu ___ Jacó', 'irmão', ['vergonha', 'bens'], 'Exato: a violência é contra o irmão.', ['Vergonha é a consequência.', 'Bens são o que levaram.']),
        tap('lhe levaram os ___', 'bens', ['irmão', 'portas'], 'Exato: levaram os bens.', ['Irmão é Jacó.', 'Portas são por onde entraram.']),
        tap('deitaram ___ sobre Jerusalém', 'sortes', ['vergonha', 'irmão'], 'Exato: deitaram sortes sobre a cidade.', ['Vergonha cobre Edom.', 'Irmão é Jacó, não o objeto da sorte.']),
      ],
      choice: [
        ch('Por que a vergonha cobre Edom?', 'Certo: pela violência contra Jacó.', ['Porque violentou o irmão Jacó.', 'Porque defendeu as portas de Jerusalém.', 'Porque recusou a parte nos bens.', 'Porque ficou longe no dia da queda.'], ['Ele ficou do lado oposto.', 'Os bens foram levados com a participação dele.', 'Ele estava nesse dia.']),
        ch('O que “eras como um deles” faz com a desculpa de neutralidade?', 'Certo: tira a desculpa.', ['Põe Edom junto de quem saqueou.', 'Prova que Edom só observou de longe.', 'Mostra que os estrangeiros agiram sem ele.', 'Separa Edom da vergonha de Jacó.'], ['Como um deles é participação.', 'Os estrangeiros entram com ele na frase.', 'A vergonha é dele por causa do irmão.']),
        ch('O que essa acusação ensina sobre o irmão caído?', 'Certo: alegrar-se do lado oposto é culpa.', ['Ficar contra o irmão no dia mau é violência.', 'Irmão caído dispensa solidariedade.', 'Sorte sobre a cidade é gesto neutro.', 'Vergonha só cabe a quem entra armado primeiro.'], ['O lado oposto já condena.', 'Deitar sortes é tomar parte.', 'A vergonha alcança quem se fez como eles.']),
      ],
      order: {
        pieces: ['A violência contra Jacó traz vergonha a Edom.', 'No dia mau, Edom ficou do lado oposto.', 'Ele era como os que levaram os bens e deitaram sortes.'],
        ok: 'Certo: culpa, lado oposto e então a igualdade com os saqueadores.',
        why: ['O lado oposto especifica a violência.', 'Ser como eles fecha a acusação.'],
      },
      complete: [
        gap('cobrir-te-á a ___', 'vergonha', ['irmão', 'bens'], 'Certo: a vergonha o cobrirá.', ['Irmão é Jacó.', 'Bens são o saque.']),
        gap('entraram nas ___', 'portas', ['sortes', 'irmão'], 'Certo: entraram nas portas.', ['Sortes são lançadas sobre a cidade.', 'Irmão é a vítima.']),
        gap('sobre ___', 'Jerusalém', ['vergonha', 'bens'], 'Certo: as sortes caem sobre Jerusalém.', ['Vergonha cai sobre Edom.', 'Bens são o que foi levado.']),
      ],
      connect: [
        link(['Culpa fraterna', 'Guerra neutra', 'Defesa da cidade'], 0, 'Certo: a culpa é contra o irmão.', ['Não há neutralidade no texto.', 'Ele não defendeu a cidade.']),
        link(['Distância inocente', 'Lado dos saqueadores', 'Portas fechadas'], 1, 'Certo: Edom ficou com quem saqueou.', ['Ele era como um deles.', 'As portas foram entradas.']),
        link(['Violência só armada', 'Participar da queda', 'Irmão sem dever'], 1, 'Certo: participar da queda do irmão é culpa.', ['O lado oposto já é a acusação.', 'Jacó é irmão, e isso pesa.']),
      ],
    },
    {
      slug: 'ob-05-dia',
      title: 'Como tens feito',
      intro: 'O dia de Jeová está perto de todas as nações. O que Edom fez volta sobre a sua cabeça.',
      hookRef: 'Obadias 15',
      verse: V.obDia,
      note: 'O juízo não é só local. O feito retorna sobre quem o praticou.',
      insight: 'O mal feito volta sobre quem o fez',
      objective: 'Sair sabendo que o dia de Jeová devolve a cada nação o que ela fez.',
      echo: 'Edom ficou contra o irmão. O que acontece com esse feito?',
      keyword: 'Dia',
      gloss: 'O dia de Jeová alcança as nações e devolve o feito.',
      context: 'O dia está perto; como Edom fez, assim se fará a ele.',
      tf: [
        tf('O dia de Jeová está perto sobre todas as nações.', 'true', 'Certo: o dia não é só de Edom.', 'A frase inclui todas as nações.'),
        tf('O feito de Edom fica no passado e não volta sobre ele.', 'false', 'Certo: o feito tornará sobre a sua cabeça.', 'A retribuição está dita.'),
        tf('O juízo de Jeová corresponde ao que a pessoa fez.', 'true', 'Certo: como tens feito, assim se te fará.', 'A medida é o próprio feito.'),
      ],
      tap: [
        tap('está ___ sobre todas as nações', 'perto', ['feito', 'cabeça'], 'Exato: o dia está perto.', ['Feito é o que retorna.', 'Cabeça é sobre quem volta.']),
        tap('como tens ___, assim se te fará', 'feito', ['perto', 'nações'], 'Exato: como tens feito.', ['Perto fala do dia.', 'Nações são o alcance do dia.']),
        tap('Dia de ___', 'Jeová', ['perto', 'cabeça'], 'Exato: é o dia de Jeová.', ['Perto é o tempo.', 'Cabeça é o destino do feito.']),
      ],
      choice: [
        ch('Sobre quem o dia de Jeová está perto?', 'Certo: sobre todas as nações.', ['Sobre todas as nações.', 'Só sobre Jerusalém.', 'Só sobre quem não fez mal.', 'Sobre o passado, sem alcançar Edom.'], ['O dia alcança as nações.', 'Edom entra no “assim se te fará”.', 'O feito volta agora, não fica só atrás.']),
        ch('O que “tornará sobre a tua cabeça” significa?', 'Certo: o mal praticado volta ao autor.', ['O feito de Edom volta para ele.', 'A cabeça de Edom fica fora do juízo.', 'As nações pagam no lugar de Edom.', 'O dia se afasta de quem fez o mal.'], ['A cabeça é a dele.', 'O “a ti” é direto.', 'O dia está perto, não longe.']),
        ch('O que essa medida revela sobre o juízo?', 'Certo: não é arbitrário; responde ao feito.', ['O juízo corresponde ao que foi feito.', 'Jeová ignora o que as nações praticaram.', 'O dia premia a violência contra o irmão.', 'A cabeça recebe o contrário do feito.'], ['Como tens feito é a medida.', 'O feito torna, não se inverte em prêmio.', 'A retribuição segue o mal feito.']),
      ],
      order: {
        pieces: ['O dia de Jeová está perto sobre todas as nações.', 'Como Edom fez, assim se fará a ele.', 'O feito tornará sobre a sua cabeça.'],
        ok: 'Certo: o dia, a medida e então a volta sobre a cabeça.',
        why: ['A medida vem depois do anúncio do dia.', 'A cabeça é o destino final do feito.'],
      },
      complete: [
        gap('sobre todas as ___', 'nações', ['feito', 'cabeça'], 'Certo: o dia está sobre as nações.', ['Feito é o que retorna.', 'Cabeça é de quem fez.']),
        gap('sobre a tua ___', 'cabeça', ['perto', 'nações'], 'Certo: o feito volta sobre a cabeça.', ['Perto qualifica o dia.', 'Nações são o alcance.']),
        gap('assim se te ___ a ti', 'fará', ['perto', 'nações'], 'Certo: assim se fará a ti.', ['Perto é o tempo do dia.', 'Nações são o horizonte.']),
      ],
      connect: [
        link(['Feito que volta', 'Dia distante', 'Nação inocente'], 0, 'Certo: o mal retorna ao autor.', ['O dia está perto.', 'A nação que fez não fica inocente.']),
        link(['Juízo sem medida', 'Medida do próprio mal', 'Cabeça poupada'], 1, 'Certo: a medida é o que ele fez.', ['Há correspondência.', 'A cabeça recebe o feito.']),
        link(['Acaso entre nações', 'Justiça que retribui', 'Violência premiada'], 1, 'Certo: o dia retribui o feito.', ['Não é acaso: é o dia de Jeová.', 'O mal não é premiado.']),
      ],
    },
  ]),
];
