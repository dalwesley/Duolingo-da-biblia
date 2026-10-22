/** Cenas novas das trilhas com um só versículo repetido. Texto: Tradução Brasileira. */
import { buildScene } from './_weak_scene_build.mjs';
import { MORE_PACKS } from './_weak_scenes_more.mjs';
import { MORE_PACKS_2 } from './_weak_scenes_more2.mjs';
import { MORE_PACKS_3 } from './_weak_scenes_more3.mjs';
import { MORE_PACKS_4 } from './_weak_scenes_more4.mjs';

const V = {
  ctBeijos:
    'Beije-me ele com os beijos de sua boca; Pois melhor é o teu amor do que o vinho. Os teus perfumes têm um odor suave, O teu nome é como unguento derramado, Por isso as donzelas te amam. Atrai-me tu; correremos após ti: O rei acaba de me introduzir nos seus aposentos; Nós nos alegraremos e regozijaremos em ti, Faremos menção do teu amor mais do que do vinho; É com razão que te amam.',
  ctMeu:
    'O meu amado é meu, e eu sou dele; Ele apascenta o seu rebanho entre as açucenas.',
  ctBusca:
    'De noite no meu leito, busquei aquele, a quem a minha alma ama: Busquei-o, porém não o achei. Levantar-me-ei, pois, e rodearei a cidade; Pelas ruas e pelas praças Buscarei aquele a quem a minha alma ama: Busquei-o, porém não o achei. Encontraram-me os guardas que rondam a cidade, Aos quais disse eu: Vistes, porventura, aquele a quem a minha alma ama? Apenas me tinha apartado deles, Quando achei aquele a quem a minha alma ama. Agarrei-me a ele, e não o deixei ir embora, Até tê-lo eu introduzido na casa de minha mãe, E na câmara daquela que me concebeu.',
  lmSozinha:
    'Como está sentada solitária a cidade que estava cheia de povo! Tornou-se viúva a que era grande entre as nações; Ficou sujeita ao trabalho forçado a que era princesa entre as províncias.',
  lmPalavra:
    'Fez Jeová o que intentou; cumpriu a sua palavra que ordenou nos dias antigos; derrubou e não mostrou piedade. Fez que o inimigo se alegrasse sobre ti, exaltou o poder dos teus adversários.',
  lmTrono:
    'Tu, Jeová, permaneces para sempre; o teu trono subsiste de geração em geração. Por que te esqueces de nós para sempre? E nos abandonas por tanto tempo? Converte-nos a ti, Jeová, e seremos convertidos; renova os nossos dias como dantes, se é que não nos tens, de todo, rejeitado, se é que não estás sobremaneira irado contra nós.',
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
  agCaminhos:
    'Agora, pois, assim diz Jeová dos Exércitos: Considerai os vossos caminhos. Tendes semeado muito e recolhido pouco; comeis, porém não vos fartais; bebeis, porém não vos saciais; vesti-vos, mas ninguém fica quente; e quem recebe salário, recebe-o para o meter num saco furado.',
  agNacoes:
    'Pois assim diz Jeová dos Exércitos: Ainda uma vez falta um pouco, e eu comoverei os céus, e a terra, e o mar, e a terra seca; comoverei todas as nações, e as coisas preciosas de todas as nações virão, e encherei de glória esta casa, diz Jeová dos Exércitos.',
  agGloria:
    'A última glória desta casa será maior do que a primeira, diz Jeová dos Exércitos; e neste lugar darei a paz, diz Jeová dos Exércitos.',
  zcTornai:
    'Portanto, dize-lhes: Assim diz Jeová dos Exércitos: Tornai para mim, diz Jeová dos Exércitos, e tornarei para vós, diz Jeová dos Exércitos.',
  zcTrajos:
    'Este começou a falar e disse aos que estavam diante dele: Tirai-lhe estes hábitos sujos. A Josué disse: Eis que hei feito passar de ti a tua iniquidade e te vestirei de ricos trajos.',
  zcEspirito:
    'Ele prosseguiu e me disse: Esta é a palavra de Jeová a Zorobabel, a qual diz: Não por força nem por poder, mas por meu Espírito, diz Jeová dos Exércitos.',
  mlCego:
    'Quando oferecerdes em sacrifício um animal cego, isso não é mau? E, quando oferecerdes o que é coxo e doente, isso não é mau? Apresenta-o, pois, ao teu governador; acaso, terá ele agrado em ti? Ou aceitará ele a tua pessoa? — diz Jeová dos Exércitos.',
  mlDizimo:
    'Trazei o dízimo todo à casa do Tesouro, para que haja mantimento na minha casa e provai-me nisto, diz Jeová dos Exércitos, se não vos abrir eu as janelas do céu e não derramar sobre vós uma bênção até que não haja mais lugar para a recolherdes.',
  mlSol:
    'Mas para vós, os que temeis o meu nome, nascerá o sol da justiça, trazendo curas nas suas asas; vós saireis e saltareis como os bezerros da estrebaria.',
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
  ttNegam:
    'Confessam que conhecem a Deus, mas, pelas suas obras, o negam, sendo abomináveis, desobedientes e réprobos para toda boa obra.',
  ttLavou:
    'não por obras de justiça que nós fizemos, mas segundo a sua misericórdia nos salvou, pelo lavatório da regeneração e renovação do Espírito Santo,',
  ttVaas:
    'Mas evita questões tolas, genealogias, contendas e disputas relativas à Lei, pois elas são inúteis e vãs.',
  fmFilho:
    'Rogo-te por meu filho Onésimo, que eu gerei nas minhas prisões, o qual, outrora, te foi inútil, mas agora é útil a ti e a mim; e eu to envio a ele, que é meu próprio coração.',
  fmIrmao:
    'Talvez por isso ele se apartasse de ti por algum tempo, para que tu o recuperasses para sempre, não mais como servo, mas, em vez de servo, como irmão amado, de mim principalmente e mais ainda de ti, quer na carne quer no Senhor.',
  fmConta:
    'Se, pois, me tens por companheiro, recebe-o como a mim. Se te fez algum mal ou se te deve alguma coisa, lança-o na minha conta. Eu, Paulo, o escrevo com o meu próprio punho: eu o pagarei; por não dizer que tu me deves até a tua própria pessoa.',
  jdFurtivos:
    'Pois certos homens se introduziram furtivamente (ímpios, cuja sentença há muito tempo está lavrada), os quais transformam a graça de nosso Deus em dissolução e negam a nosso único Mestre e Senhor, Jesus Cristo.',
  jdEnoque:
    'A estes também é que profetizou Enoque, o sétimo depois de Adão, quando disse: Eis que o Senhor veio, com miríades de seus santos, a executar juízo sobre todos e a convencer a todos os ímpios de todas as obras ímpias que impiamente cometeram e de todas as palavras duras que os ímpios pecadores falaram contra ele.',
  jdGuarda:
    'Àquele que vos pode guardar de tropeçardes e vos apresentar diante da sua glória sem defeito, em grande gozo, ao único Deus, nosso Salvador, por Jesus Cristo, nosso Senhor, seja glória, majestade, domínio e poder, antes de toda a eternidade, e agora, e por todos os séculos. Amém.',
};

function scene(partial) {
  return partial;
}

function pack(trail, bank, module, scenes) {
  return {
    trail,
    bank,
    module,
    built: scenes.map((item) => buildScene({ trail, ...item })),
  };
}

const BASE_PACKS = [
  pack('cantares', 'ot', { title: 'A busca', icon: '🌙', section: 'busca' }, [
    scene({
      slug: 'ct-03-beijos',
      title: 'Melhor do que o vinho',
      intro:
        'O cântico não começa com regra. Começa com desejo: a amada quer a boca, o nome e a casa do amado.',
      hookRef: 'Cantares 1:2–4',
      verse: V.ctBeijos,
      note: 'Amor, aqui, não é ideia. É presença pedida: beijo, perfume, nome e aposentos.',
      insight: 'O amor deseja a presença',
      objective:
        'Sair sabendo que o cântico abre pelo desejo da presença do amado.',
      echo: 'O amor está selado no coração. Onde esse desejo começa?',
      keyword: 'Presença',
      gloss: 'O amor pede a pessoa, não só a fama do nome.',
      context: 'A amada quer beijos, nome derramado e entrada nos aposentos do rei.',
      tf: [
        {
          claim: 'A amada diz que o amor do amado é melhor do que o vinho.',
          answer: 'true',
          ok: 'Certo: o amor é posto acima do vinho.',
          why: 'O texto faz essa comparação logo no início.',
        },
        {
          claim: 'A amada pede distância e que o nome do amado fique escondido.',
          answer: 'false',
          ok: 'Certo: ela pede beijos, atração e os aposentos.',
          why: 'O nome é unguento derramado, e ela pede para ser atraída.',
        },
        {
          claim: 'O nome comparado a unguento mostra um amor que se espalha.',
          answer: 'true',
          ok: 'Certo: unguento derramado espalha, e as donzelas amam.',
          why: 'O odor do nome alcança as donzelas; não fica guardado.',
        },
      ],
      tap: [
        {
          quote: 'melhor é o teu ___ do que o vinho',
          word: 'amor',
          wrong: ['vinho', 'nome'],
          ok: 'Exato: o amor é melhor do que o vinho.',
          why: ['O vinho é a comparação, não a lacuna.', 'O nome vem depois, como unguento.'],
        },
        {
          quote: 'O teu ___ é como unguento derramado',
          word: 'nome',
          wrong: ['amor', 'rei'],
          ok: 'Exato: o nome é como unguento derramado.',
          why: ['Amor já foi comparado ao vinho.', 'O rei aparece na entrada dos aposentos.'],
        },
        {
          quote: 'O ___ acaba de me introduzir nos seus aposentos',
          word: 'rei',
          wrong: ['nome', 'vinho'],
          ok: 'Exato: o rei a introduz nos aposentos.',
          why: ['O nome é unguento, não quem abre a porta.', 'O vinho é a comparação do amor.'],
        },
      ],
      choice: [
        {
          q: 'O que a amada pede logo no início do cântico?',
          ok: 'Certo: ela pede a presença, mais do que o vinho.',
          options: [
            'Os beijos da boca, porque o amor vale mais que o vinho.',
            'Que o amado se afaste e a deixe em silêncio.',
            'Um contrato escrito diante das donzelas da corte.',
            'Que o rei feche os aposentos e apague o nome.',
          ],
          why: [
            'Ela pede aproximação, não distância.',
            'Não há contrato; há desejo e nome.',
            'O rei a introduz; o nome é celebrado.',
          ],
        },
        {
          q: 'Como se ligam boca, nome e aposentos neste começo?',
          ok: 'Certo: o desejo caminha até a presença.',
          options: [
            'O desejo vai da boca ao nome e chega à presença.',
            'O nome substitui a presença e dispensa os aposentos.',
            'O vinho é o tema, e o amado só ilustra a festa.',
            'As donzelas impedem a entrada na casa do rei.',
          ],
          why: [
            'Os aposentos são o destino do pedido.',
            'O amado é o centro, não uma ilustração.',
            'As donzelas amam o nome; não bloqueiam a porta.',
          ],
        },
        {
          q: 'O que este começo ensina sobre o amor que o poema canta?',
          ok: 'Certo: amor de verdade deseja a pessoa.',
          options: [
            'Amor de verdade deseja a pessoa, não só o benefício.',
            'O amor maduro dispensa presença e se contenta com fama.',
            'O nome do amado deve ficar oculto para ser santo.',
            'O desejo da boca torna o amor inferior ao vinho.',
          ],
          why: [
            'Ela pede presença, não fama no lugar da pessoa.',
            'O nome é derramado, não oculto.',
            'O texto põe o amor acima do vinho.',
          ],
        },
      ],
      order: {
        pieces: [
          'A amada pede os beijos e põe o amor acima do vinho.',
          'O nome do amado é como unguento, e as donzelas o amam.',
          'Ela pede atração e entra nos aposentos do rei.',
        ],
        ok: 'Certo: desejo, nome e então a casa do rei.',
        why: [
          'O nome vem depois da comparação com o vinho.',
          'Os aposentos fecham o movimento, não o abrem.',
        ],
      },
      complete: [
        {
          template: 'Beije-me ele com os ___ de sua boca',
          word: 'beijos',
          wrong: ['amor', 'vinho'],
          ok: 'Certo: o pedido começa pelos beijos.',
          why: ['Amor é a comparação com o vinho.', 'Vinho não é o que ela pede na boca.'],
        },
        {
          template: 'Por isso as ___ te amam',
          word: 'donzelas',
          wrong: ['beijos', 'rei'],
          ok: 'Certo: as donzelas amam o nome derramado.',
          why: ['Beijos são o pedido da amada.', 'O rei a introduz; não é o sujeito desta frase.'],
        },
        {
          template: 'Os teus ___ têm um odor suave',
          word: 'perfumes',
          wrong: ['donzelas', 'aposentos'],
          ok: 'Certo: os perfumes têm odor suave.',
          why: ['Donzelas amam; não são o odor.', 'Aposentos são o lugar da entrada.'],
        },
      ],
      connect: [
        {
          options: ['Desejo da presença', 'Preço do vinho', 'Festa da corte'],
          correct: 0,
          ok: 'Certo: o trecho pede a pessoa do amado.',
          why: ['O vinho só serve de comparação.', 'Não é crónica de corte; é desejo.'],
        },
        {
          options: ['Nome que se esconde', 'Amor que atrai', 'Vinho como senhor'],
          correct: 1,
          ok: 'Certo: ela pede ser atraída até os aposentos.',
          why: ['O nome é derramado, não escondido.', 'O vinho fica abaixo do amor.'],
        },
        {
          options: ['Fama sem pessoa', 'Silêncio do nome', 'Presença desejada'],
          correct: 2,
          ok: 'Certo: o sentido é a presença, não a fama só.',
          why: ['Fama sem pessoa não é o pedido.', 'O nome se espalha; não se cala.'],
        },
      ],
    }),
    scene({
      slug: 'ct-04-pertence',
      title: 'Meu, e eu dele',
      intro:
        'No meio do poema, a amada resume a aliança numa frase só: pertença dos dois lados.',
      hookRef: 'Cantares 2:16',
      verse: V.ctMeu,
      note: 'Não é posse de um só. Ela é dele, e ele é dela. O pastor está entre as açucenas.',
      insight: 'Amor de aliança é pertença mútua',
      objective: 'Sair sabendo que o cântico fala de pertença dos dois lados.',
      echo: 'O amor deseja a presença. Essa presença vira o quê entre os dois?',
      keyword: 'Pertença',
      gloss: 'Um não absorve o outro: os dois se pertencem.',
      context: 'A amada declara mútua pertença, e o amado apascenta entre as açucenas.',
      tf: [
        {
          claim: 'A amada diz que o amado é dela e que ela é dele.',
          answer: 'true',
          ok: 'Certo: a frase é dos dois lados.',
          why: 'O versículo une “é meu” e “sou dele”.',
        },
        {
          claim: 'O amado aparece longe do rebanho, sem lugar de pasto.',
          answer: 'false',
          ok: 'Certo: ele apascenta entre as açucenas.',
          why: 'O texto o põe com o rebanho, não afastado.',
        },
        {
          claim: 'A pertença do cântico é mútua, não domínio de um lado só.',
          answer: 'true',
          ok: 'Certo: os dois se nomeiam um do outro.',
          why: '“Meu” e “dele” fecham o círculo da aliança.',
        },
      ],
      tap: [
        {
          quote: 'O meu ___ é meu, e eu sou dele',
          word: 'amado',
          wrong: ['rebanho', 'açucenas'],
          ok: 'Exato: o meu amado é meu.',
          why: ['O rebanho vem na frase seguinte.', 'Açucenas são o pasto, não o sujeito.'],
        },
        {
          quote: 'entre as ___',
          word: 'açucenas',
          wrong: ['amado', 'dele'],
          ok: 'Exato: o rebanho está entre as açucenas.',
          why: ['Amado é o pastor, não o lugar.', 'Dele fecha a pertença, não o pasto.'],
        },
        {
          quote: 'Ele ___ o seu rebanho',
          word: 'apascenta',
          wrong: ['amado', 'açucenas'],
          ok: 'Exato: ele apascenta o rebanho.',
          why: ['Amado é quem faz, não o verbo.', 'Açucenas são o lugar do pasto.'],
        },
      ],
      choice: [
        {
          q: 'O que Cantares 2:16 afirma sobre os dois?',
          ok: 'Certo: a pertença é dos dois lados.',
          options: [
            'O amado é dela, e ela é dele.',
            'Só ela pertence a ele; ele permanece livre.',
            'O rebanho é dela, e o amado fica de fora.',
            'As açucenas substituem o amado no poema.',
          ],
          why: [
            'O versículo também diz que ele é dela.',
            'O rebanho é dele; a frase é sobre os dois.',
            'As açucenas são o pasto, não o amado.',
          ],
        },
        {
          q: 'O que a imagem do rebanho acrescenta à frase de pertença?',
          ok: 'Certo: pertença aqui também é cuidado.',
          options: [
            'Ele não só é dela: ele apascenta.',
            'O pasto mostra que o amor acabou em distância.',
            'O rebanho prova que ela ficou sem pastor.',
            'As açucenas anulam a frase “eu sou dele”.',
          ],
          why: [
            'O pasto é presença, não abandono.',
            'Ele está com o rebanho, como pastor.',
            'A imagem confirma o cuidado, não o anula.',
          ],
        },
        {
          q: 'Que leitura a frase “meu” e “dele” sustenta?',
          ok: 'Certo: aliança não é posse de um lado só.',
          options: [
            'Aliança verdadeira é pertença mútua.',
            'Amor maduro evita dizer “meu” para não prender.',
            'O pastor cuida do campo e dispensa a amada.',
            'Pertença mútua é o mesmo que perder a diferença.',
          ],
          why: [
            'O poema diz “meu” sem vergonha.',
            'O pastor e a amada estão na mesma frase.',
            'Mútuo não apaga quem é quem.',
          ],
        },
      ],
      order: {
        pieces: [
          'Ela diz: o meu amado é meu.',
          'E completa: eu sou dele.',
          'Ele apascenta o rebanho entre as açucenas.',
        ],
        ok: 'Certo: pertença dela, pertença dele, depois o pastoreio.',
        why: [
          '“Eu sou dele” responde ao “é meu”, não vem antes.',
          'O rebanho fecha o versículo, não o abre.',
        ],
      },
      complete: [
        {
          template: 'Ele apascenta o seu ___ entre as açucenas',
          word: 'rebanho',
          wrong: ['amado', 'dele'],
          ok: 'Certo: o rebanho é o que ele apascenta.',
          why: ['Amado é o pastor, não o rebanho.', 'Dele é a pertença, não o gado.'],
        },
        {
          template: 'e eu sou ___',
          word: 'dele',
          wrong: ['rebanho', 'açucenas'],
          ok: 'Certo: ela também é dele.',
          why: ['Rebanho não completa “eu sou”.', 'Açucenas são o lugar do pasto.'],
        },
        {
          template: 'Ele apascenta ___ rebanho entre as açucenas',
          word: 'seu',
          wrong: ['amado', 'dele'],
          ok: 'Certo: ele apascenta o seu rebanho.',
          why: ['Amado é o pastor, não o pronome.', 'Dele fecha a pertença da amada.'],
        },
      ],
      connect: [
        {
          options: ['Pertença mútua', 'Pasto sem dono', 'Festa do vinho'],
          correct: 0,
          ok: 'Certo: o versículo é aliança dos dois lados.',
          why: ['Há pastor e rebanho, não pasto vazio.', 'Vinho não entra neste versículo.'],
        },
        {
          options: ['Cuidado do pastor', 'Fuga do amado', 'Troca de rebanho'],
          correct: 0,
          ok: 'Certo: apascentar é o cuidado da pertença.',
          why: ['Ele está no pasto, não em fuga.', 'Não há troca; há o rebanho dele.'],
        },
        {
          options: ['Domínio de um só', 'Aliança dos dois', 'Campo sem nome'],
          correct: 1,
          ok: 'Certo: o sentido é aliança, não domínio unilateral.',
          why: ['Os dois se pertencem.', 'O amado é nomeado, não anônimo.'],
        },
      ],
    }),
    scene({
      slug: 'ct-05-busca',
      title: 'Busquei o que a alma ama',
      intro:
        'De noite ela procura. Não acha no leito, pergunta aos guardas e, quando acha, não solta.',
      hookRef: 'Cantares 3:1–4',
      verse: V.ctBusca,
      note: 'O amor do cântico não é só declaração. É busca que atravessa a cidade até achar.',
      insight: 'Quem ama procura até achar',
      objective: 'Sair sabendo que o amor do cântico procura e, ao achar, não solta.',
      echo: 'Há pertença mútua. O que ela faz quando o amado não está no leito?',
      keyword: 'Busca',
      gloss: 'Amar inclui procurar de noite e segurar quando acha.',
      context: 'Ela busca na cama, rodeia a cidade, pergunta aos guardas e agarra o amado.',
      tf: [
        {
          claim: 'De noite, no leito, ela buscou o amado e logo o encontrou ali.',
          answer: 'false',
          ok: 'Certo: no leito ela buscou e não achou.',
          why: 'O texto diz: busquei-o, porém não o achei.',
        },
        {
          claim: 'Ela rodeia a cidade e pergunta aos guardas pelo amado.',
          answer: 'true',
          ok: 'Certo: a busca sai do leito e vai às ruas.',
          why: 'Ela fala aos guardas que rondam a cidade.',
        },
        {
          claim: 'Achar o amado, no cântico, leva a segurar e não soltar.',
          answer: 'true',
          ok: 'Certo: ela se agarra e não o deixa ir.',
          why: 'O encontro termina em apego, não em despedida.',
        },
      ],
      tap: [
        {
          quote: 'busquei aquele, a quem a minha ___ ama',
          word: 'alma',
          wrong: ['cidade', 'mãe'],
          ok: 'Exato: a alma ama aquele a quem ela busca.',
          why: ['A cidade é o lugar da ronda.', 'A mãe aparece só no fim, em casa.'],
        },
        {
          quote: 'Encontraram-me os ___ que rondam a cidade',
          word: 'guardas',
          wrong: ['alma', 'leito'],
          ok: 'Exato: os guardas a encontram na cidade.',
          why: ['Alma é quem ama, não quem ronda.', 'O leito é onde a busca começou.'],
        },
        {
          quote: 'Agarrei-me a ele, e não o deixei ir ___',
          word: 'embora',
          wrong: ['cidade', 'guardas'],
          ok: 'Exato: ela não o deixou ir embora.',
          why: ['A cidade já ficou para trás.', 'Os guardas não são o destino.'],
        },
      ],
      choice: [
        {
          q: 'O que acontece quando ela busca o amado no leito?',
          ok: 'Certo: no leito a busca ainda não acha.',
          options: [
            'Ela busca e não o acha.',
            'Ela o acha dormindo e permanece ali.',
            'Os guardas já o trazem até a cama.',
            'A mãe o apresenta antes de ela sair.',
          ],
          why: [
            'O encontro não é no leito.',
            'Os guardas aparecem na cidade, sem trazê-lo.',
            'A casa da mãe vem depois do encontro.',
          ],
        },
        {
          q: 'Como a busca se move do quarto até o encontro?',
          ok: 'Certo: leito, cidade, guardas e então o achado.',
          options: [
            'Ela sai, pergunta e só depois se agarra a ele.',
            'Ela desiste na praça e volta a dormir.',
            'Os guardas proíbem a pergunta e ela obedece.',
            'O encontro acontece sem ela deixar o leito.',
          ],
          why: [
            'Ela não desiste; continua até achar.',
            'Ela pergunta aos guardas; não se cala.',
            'O leito é o fracasso inicial, não o fim.',
          ],
        },
        {
          q: 'O que o gesto de agarrar revela sobre esse amor?',
          ok: 'Certo: achar não basta; ela não solta.',
          options: [
            'Quem acha segura, em vez de só passar.',
            'O encontro serve para se despedir em paz.',
            'Amar é perguntar aos guardas e seguir só.',
            'A casa da mãe substitui a pessoa do amado.',
          ],
          why: [
            'Ela não o deixa ir embora.',
            'A pergunta é caminho, não o destino.',
            'Ela o leva à casa; não troca a pessoa pela casa.',
          ],
        },
      ],
      order: {
        pieces: [
          'De noite, no leito, ela busca e não acha.',
          'Levanta-se, rodeia a cidade e pergunta aos guardas.',
          'Quando acha, agarra-se a ele e não o solta.',
        ],
        ok: 'Certo: falta, busca na cidade e então o apego.',
        why: [
          'A cidade vem depois do leito vazio.',
          'Agarrar é o fim do encontro, não o começo.',
        ],
      },
      complete: [
        {
          template: 'De noite no meu ___, busquei aquele',
          word: 'leito',
          wrong: ['alma', 'cidade'],
          ok: 'Certo: a busca começa no leito.',
          why: ['Alma é quem ama, não o lugar.', 'A cidade vem quando ela se levanta.'],
        },
        {
          template: 'Quando ___ aquele a quem a minha alma ama',
          word: 'achei',
          wrong: ['guardas', 'leito'],
          ok: 'Certo: ela acha depois de se apartar dos guardas.',
          why: ['Guardas são a quem ela pergunta.', 'O leito é onde ainda não achou.'],
        },
        {
          template: 'introduzido na casa de minha ___',
          word: 'mãe',
          wrong: ['cidade', 'alma'],
          ok: 'Certo: ela o leva à casa da mãe.',
          why: ['A cidade foi o lugar da busca.', 'Alma ama; não é a casa.'],
        },
      ],
      connect: [
        {
          options: ['Busca até achar', 'Sono sem saída', 'Ronda dos guardas'],
          correct: 0,
          ok: 'Certo: o trecho é a procura que não para.',
          why: ['Ela se levanta; não fica no sono.', 'Os guardas são passagem, não o tema.'],
        },
        {
          options: ['Desistência na praça', 'Pergunta que continua', 'Casa sem pessoa'],
          correct: 1,
          ok: 'Certo: perguntar aos guardas faz parte da busca.',
          why: ['Ela não desiste na cidade.', 'O fim é a pessoa, não a casa vazia.'],
        },
        {
          options: ['Achar e soltar', 'Amor que segura', 'Medo dos guardas'],
          correct: 1,
          ok: 'Certo: o sentido fecha em não soltar.',
          why: ['Ela não o deixa ir embora.', 'Os guardas não são ameaça no texto.'],
        },
      ],
    }),
  ]),
];

export const PACKS = [
  ...BASE_PACKS,
  ...MORE_PACKS,
  ...MORE_PACKS_2,
  ...MORE_PACKS_3,
  ...MORE_PACKS_4,
];
