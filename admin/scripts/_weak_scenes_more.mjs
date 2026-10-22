import { buildScene } from './_weak_scene_build.mjs';

const V = {
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
};

function pack(trail, bank, module, scenes) {
  return {
    trail,
    bank,
    module,
    built: scenes.map((item) => buildScene({ trail, ...item })),
  };
}

export const MORE_PACKS = [
  pack('lamentacoes', 'ot', { title: 'A cidade', icon: '🕯️', section: 'cidade' }, [
    {
      slug: 'lm-03-solitaria',
      title: 'Sentada solitária',
      intro: 'O livro abre com uma cidade que já foi cheia e agora está só, viúva e sob trabalho.',
      hookRef: 'Lamentações 1:1',
      verse: V.lmSozinha,
      note: 'O luto não é abstrato. É Jerusalém sem povo, sem honra e sem liberdade.',
      insight: 'O luto da cidade é concreto',
      objective: 'Sair sabendo que a queda de Jerusalém aparece como solidão, viuvez e trabalho.',
      echo: 'Há misericórdia no meio do luto. Como o livro descreve a cidade caída?',
      keyword: 'Solidão',
      gloss: 'A cidade cheia tornou-se viúva e sujeita.',
      context: 'Jerusalém, antes grande, está solitária, viúva e sob trabalho forçado.',
      tf: [
        { claim: 'A cidade que estava cheia de povo agora está sentada solitária.', answer: 'true', ok: 'Certo: a plenitude virou solidão.', why: 'O versículo opõe cheia de povo e sentada solitária.' },
        { claim: 'O texto chama a cidade de princesa livre entre as províncias.', answer: 'false', ok: 'Certo: a princesa ficou sujeita a trabalho.', why: 'Ela era princesa; agora está sob trabalho forçado.' },
        { claim: 'Viuvez, aqui, nomeia a perda de honra da cidade grande.', answer: 'true', ok: 'Certo: a grande entre as nações tornou-se viúva.', why: 'O luto usa a imagem da viúva para a cidade caída.' },
      ],
      tap: [
        { quote: 'está sentada ___ a cidade', word: 'solitária', wrong: ['viúva', 'povo'], ok: 'Exato: a cidade está sentada solitária.', why: ['Viúva vem na frase seguinte.', 'Povo é o que ela tinha antes.'] },
        { quote: 'era ___ entre as províncias', word: 'princesa', wrong: ['viúva', 'povo'], ok: 'Exato: ela era princesa entre as províncias.', why: ['Viúva é o que ela se tornou.', 'Povo enchia a cidade, não o título.'] },
        { quote: 'cheia de ___', word: 'povo', wrong: ['viúva', 'princesa'], ok: 'Exato: a cidade estava cheia de povo.', why: ['Viúva é a imagem da queda.', 'Princesa era o título antigo.'] },
      ],
      choice: [
        { q: 'Como Lamentações 1:1 descreve a cidade?', ok: 'Certo: cheia virou só, grande virou viúva.', options: ['Solitária, viúva e sob trabalho.', 'Cheia, livre e princesa ainda hoje.', 'Vazia de culpa e rica entre as nações.', 'Em festa, com o povo de volta às portas.'], why: ['O texto fala do que ela era, não do que é.', 'A queda é o assunto, não a inocência.', 'Não há festa; há solidão e trabalho.'] },
        { q: 'O que a imagem da viúva faz com a grandeza antiga?', ok: 'Certo: a honra antiga agora é luto.', options: ['Mostra a honra antiga convertida em perda.', 'Prova que a cidade nunca foi grande.', 'Anuncia que o trabalho forçado já acabou.', 'Troca o povo por uma festa nas províncias.'], why: ['O texto lembra que ela era grande.', 'O trabalho forçado é o presente da cena.', 'Não há festa; há sujeição.'] },
        { q: 'O que esse retrato impede o leitor de fazer?', ok: 'Certo: o luto não pode ficar abstrato.', options: ['Tratar a queda como ideia sem rosto.', 'Lembrar que a cidade um dia foi cheia.', 'Ver trabalho forçado na princesa caída.', 'Nomear a solidão de quem perdeu o povo.'], why: ['Lembrar a plenitude é parte do luto.', 'O trabalho está no versículo.', 'A solidão é exatamente o que se deve ver.'] },
      ],
      order: {
        pieces: ['A cidade cheia está agora sentada solitária.', 'A grande entre as nações tornou-se viúva.', 'A princesa ficou sujeita a trabalho forçado.'],
        ok: 'Certo: solidão, viuvez e então o trabalho.',
        why: ['A viuvez vem depois da solidão.', 'O trabalho fecha a queda da princesa.'],
      },
      complete: [
        { template: 'Tornou-se ___ a que era grande', word: 'viúva', wrong: ['povo', 'cidade'], ok: 'Certo: a grande tornou-se viúva.', why: ['Povo é o que a enchia antes.', 'Cidade é quem sofre, não o título.'] },
        { template: 'grande entre as ___', word: 'nações', wrong: ['princesa', 'povo'], ok: 'Certo: ela era grande entre as nações.', why: ['Princesa é o título entre as províncias.', 'Povo enchia a cidade.'] },
        { template: 'sujeita ao trabalho ___', word: 'forçado', wrong: ['viúva', 'povo'], ok: 'Certo: o trabalho é forçado.', why: ['Viúva é a imagem anterior.', 'Povo não qualifica o trabalho.'] },
      ],
      connect: [
        { options: ['Luto concreto', 'Festa da princesa', 'Mapa das nações'], correct: 0, ok: 'Certo: o versículo dá corpo ao luto.', why: ['A princesa já caiu.', 'Não é geografia; é lamento.'] },
        { options: ['Honra que caiu', 'Cidade sem história', 'Trabalho voluntário'], correct: 0, ok: 'Certo: a grandeza antiga agora é perda.', why: ['O texto lembra o que ela foi.', 'O trabalho é forçado, não livre.'] },
        { options: ['Culpa abstrata', 'Queda com rosto', 'Glória intacta'], correct: 1, ok: 'Certo: a queda tem cidade, viúva e jugo.', why: ['O luto aqui tem endereço.', 'A glória é o que se perdeu.'] },
      ],
    },
    {
      slug: 'lm-04-palavra',
      title: 'Cumpriu a sua palavra',
      intro: 'O desastre não foi acidente. O poema diz que Jeová fez o que intentou e cumpriu a palavra antiga.',
      hookRef: 'Lamentações 2:17',
      verse: V.lmPalavra,
      note: 'O inimigo se alegra, mas o versículo não entrega o roteiro ao inimigo. A palavra de Jeová se cumpre.',
      insight: 'O juízo cumpre a palavra antiga',
      objective: 'Sair sabendo que a queda cumpre o que Jeová já tinha falado.',
      echo: 'A cidade está solitária. Esse desastre foi acidente ou palavra cumprida?',
      keyword: 'Palavra',
      gloss: 'O juízo executa o que foi dito nos dias antigos.',
      context: 'Jeová cumpre a palavra, derruba sem piedade e o inimigo se alegra.',
      tf: [
        { claim: 'Jeová fez o que intentou e cumpriu a palavra dos dias antigos.', answer: 'true', ok: 'Certo: o desastre cumpre a palavra.', why: 'O versículo abre com intento e palavra cumprida.' },
        { claim: 'O texto diz que Jeová derrubou e ao mesmo tempo mostrou piedade.', answer: 'false', ok: 'Certo: derrubou e não mostrou piedade.', why: 'A frase nega a piedade nesse ato.' },
        { claim: 'A alegria do inimigo não apaga que a palavra de Jeová se cumpriu.', answer: 'true', ok: 'Certo: o inimigo se alegra dentro do cumprimento.', why: 'A alegria do adversário vem depois da palavra cumprida.' },
      ],
      tap: [
        { quote: 'cumpriu a sua ___ que ordenou', word: 'palavra', wrong: ['inimigo', 'piedade'], ok: 'Exato: ele cumpriu a sua palavra.', why: ['O inimigo se alegra depois.', 'Piedade é o que ele não mostrou.'] },
        { quote: 'o ___ se alegrasse sobre ti', word: 'inimigo', wrong: ['palavra', 'poder'], ok: 'Exato: o inimigo se alegra sobre a cidade.', why: ['A palavra é o que foi cumprido.', 'Poder é o que foi exaltado nos adversários.'] },
        { quote: 'nos dias ___', word: 'antigos', wrong: ['inimigo', 'poder'], ok: 'Exato: a palavra foi ordenada nos dias antigos.', why: ['O inimigo é figura do presente.', 'Poder é o que foi exaltado nos adversários.'] },
      ],
      choice: [
        { q: 'Quem o versículo põe por trás da queda?', ok: 'Certo: Jeová fez o que intentou.', options: ['Jeová, que cumpriu a palavra antiga.', 'Só o inimigo, agindo sem Deus saber.', 'A princesa, que derrubou a própria cidade.', 'O acaso, sem palavra anterior.'], why: ['O inimigo se alegra, mas não é a origem.', 'A princesa é a cidade caída, não a causa.', 'Há palavra ordenada nos dias antigos.'] },
        { q: 'Como se relacionam palavra antiga e alegria do inimigo?', ok: 'Certo: a alegria do inimigo cabe no cumprimento.', options: ['O inimigo se alegra dentro do que Jeová cumpriu.', 'A alegria do inimigo cancela a palavra antiga.', 'A piedade de Jeová impede a queda anunciada.', 'Os adversários escrevem a palavra no lugar de Jeová.'], why: ['A palavra se cumpre; não é cancelada.', 'O texto diz que não houve piedade nesse ato.', 'A palavra é de Jeová, não dos adversários.'] },
        { q: 'O que essa leitura impede diante da catástrofe?', ok: 'Certo: o juízo não é surpresa sem palavra.', options: ['Tratar o juízo como acidente sem aviso.', 'Lembrar que a palavra antiga se cumpriu.', 'Ver o inimigo alegrar-se sobre a cidade.', 'Negar piedade nesse ato de derrubar.'], why: ['Lembrar a palavra é o centro do versículo.', 'A alegria do inimigo está no texto.', 'A falta de piedade também está dita.'] },
      ],
      order: {
        pieces: ['Jeová fez o que intentou.', 'Cumpriu a palavra ordenada nos dias antigos.', 'O inimigo se alegrou e o poder dos adversários foi exaltado.'],
        ok: 'Certo: intento, palavra e então a alegria do inimigo.',
        why: ['A palavra antiga vem antes da festa do inimigo.', 'Os adversários fecham a cena, não a abrem.'],
      },
      complete: [
        { template: 'derrubou e não mostrou ___', word: 'piedade', wrong: ['palavra', 'inimigo'], ok: 'Certo: nesse ato não houve piedade.', why: ['Palavra é o que foi cumprido.', 'Inimigo é quem se alegra.'] },
        { template: 'exaltou o ___ dos teus adversários', word: 'poder', wrong: ['palavra', 'piedade'], ok: 'Certo: o poder dos adversários foi exaltado.', why: ['Palavra pertence a Jeová.', 'Piedade é o que não foi mostrado.'] },
        { template: 'Fez ___ o que intentou', word: 'Jeová', wrong: ['inimigo', 'poder'], ok: 'Certo: Jeová fez o que intentou.', why: ['O inimigo se alegra; não é o sujeito do intento.', 'Poder é dos adversários, não quem intenta.'] },
      ],
      connect: [
        { options: ['Palavra cumprida', 'Acaso da guerra', 'Festa inocente'], correct: 0, ok: 'Certo: a queda cumpre o que foi dito.', why: ['Há intento, não acaso.', 'A alegria do inimigo não é inocente.'] },
        { options: ['Inimigo como autor', 'Juízo anunciado', 'Piedade no ato'], correct: 1, ok: 'Certo: o juízo já tinha palavra.', why: ['O autor do intento é Jeová.', 'O texto nega piedade nesse derrubar.'] },
        { options: ['Silêncio de Deus', 'Aviso que se cumpre', 'Vitória sem juiz'], correct: 1, ok: 'Certo: Deus não ficou sem palavra.', why: ['Houve palavra nos dias antigos.', 'A queda tem juiz, não só vencedor.'] },
      ],
    },
    {
      slug: 'lm-05-trono',
      title: 'Tu permaneces',
      intro: 'O poema acaba olhando para o trono que não cai e pedindo: converte-nos, renova os nossos dias.',
      hookRef: 'Lamentações 5:19–22',
      verse: V.lmTrono,
      note: 'O luto não termina em desespero mudo. Termina numa pergunta e num pedido diante de quem permanece.',
      insight: 'No luto ainda se pede restauração',
      objective: 'Sair sabendo que o lamento pede volta mesmo temendo a rejeição.',
      echo: 'A palavra se cumpriu na queda. Diante do trono, o que ainda se pede?',
      keyword: 'Restauração',
      gloss: 'Quem permanece é Jeová; o povo pede para ser convertido.',
      context: 'O trono subsiste, o povo pergunta pelo abandono e pede renovação.',
      tf: [
        { claim: 'O texto diz que o trono de Jeová caiu com a cidade.', answer: 'false', ok: 'Certo: Jeová permanece e o trono subsiste.', why: 'O versículo afirma permanência de geração em geração.' },
        { claim: 'O povo pergunta se foi esquecido e abandonado por tanto tempo.', answer: 'true', ok: 'Certo: a oração nomeia esquecimento e abandono.', why: 'As perguntas estão no meio do poema final.' },
        { claim: 'O pedido final é ser convertido e ter os dias renovados.', answer: 'true', ok: 'Certo: converte-nos, e seremos convertidos.', why: 'A renovação é pedida, não presumida.' },
      ],
      tap: [
        { quote: 'o teu ___ subsiste de geração em geração', word: 'trono', wrong: ['dias', 'geração'], ok: 'Exato: o trono subsiste.', why: ['Dias são os que se pede renovar.', 'Geração marca a duração, não o sujeito.'] },
        { quote: 'renova os nossos ___ como dantes', word: 'dias', wrong: ['trono', 'geração'], ok: 'Exato: o pedido é renovar os dias.', why: ['O trono é o que permanece.', 'Geração fala da duração do trono.'] },
        { quote: 'se é que não estás sobremaneira ___ contra nós', word: 'irado', wrong: ['trono', 'dias'], ok: 'Exato: o temor é que Jeová esteja irado.', why: ['O trono subsiste; não é o medo.', 'Dias são o objeto da renovação.'] },
      ],
      choice: [
        { q: 'O que Lamentações 5 afirma sobre Jeová?', ok: 'Certo: ele permanece e o trono subsiste.', options: ['Jeová permanece e o trono não cai.', 'Jeová acabou com a cidade e também sumiu.', 'O trono passou à geração do inimigo.', 'A rejeição final já foi declarada sem pedido.'], why: ['A oração ainda fala com ele.', 'O trono é dele, de geração em geração.', 'Há pedido, não sentença muda.'] },
        { q: 'Como a pergunta pelo abandono convive com o pedido?', ok: 'Certo: o medo não cancela a oração.', options: ['Eles perguntam e ainda assim pedem volta.', 'A pergunta substitui o pedido de renovação.', 'O trono caído impede qualquer oração.', 'A ira já fechou a boca do povo.'], why: ['O pedido de renovar vem no texto.', 'O trono subsiste.', 'Eles ainda falam.'] },
        { q: 'O que essa oração ensina sobre lamento fiel?', ok: 'Certo: lamento fiel pede restauração sem negar o temor.', options: ['Pede volta mesmo temendo rejeição.', 'Cala, porque o trono também caiu.', 'Exige renovação como direito sem graça.', 'Troca o trono pela memória dos dias antigos.'], why: ['O trono permanece.', 'O pedido é “converte-nos”, não cobrança fria.', 'Os dias antigos são o modelo, não o substituto de Jeová.'] },
      ],
      order: {
        pieces: ['Jeová permanece e o trono subsiste.', 'O povo pergunta pelo esquecimento e pelo abandono.', 'Pede conversão e renovação, temendo a rejeição.'],
        ok: 'Certo: trono, pergunta e então o pedido.',
        why: ['A pergunta vem depois da permanência.', 'O pedido fecha a oração, não a abre.'],
      },
      complete: [
        { template: 'Tu, ___, permaneces para sempre', word: 'Jeová', wrong: ['trono', 'dias'], ok: 'Certo: Jeová é quem permanece.', why: ['O trono subsiste porque ele permanece.', 'Dias são os do povo.'] },
        { template: 'permaneces para ___', word: 'sempre', wrong: ['trono', 'dias'], ok: 'Certo: Jeová permanece para sempre.', why: ['O trono subsiste; não é o prazo desta lacuna.', 'Dias são os do povo, no pedido.'] },
        { template: 'de todo, ___', word: 'rejeitado', wrong: ['trono', 'dias'], ok: 'Certo: o temor é ter sido rejeitado de todo.', why: ['O trono é esperança, não o medo.', 'Dias são a renovação pedida.'] },
      ],
      connect: [
        { options: ['Trono que fica', 'Cidade esquecida', 'Ira sem fala'], correct: 0, ok: 'Certo: quem permanece é Jeová.', why: ['Eles ainda oram; não estão só esquecidos.', 'A oração ainda tem voz.'] },
        { options: ['Pedido de volta', 'Silêncio final', 'Troca de trono'], correct: 0, ok: 'Certo: o lamento pede renovação.', why: ['Eles falam.', 'O trono não muda de dono.'] },
        { options: ['Desespero mudo', 'Oração no luto', 'Glória da cidade'], correct: 1, ok: 'Certo: o luto ainda ora.', why: ['Há palavras, não só mudez.', 'A glória da cidade já caiu.'] },
      ],
    },
  ]),
];
