# Lucas — 29 cena(s)

No ChatGPT: uma conversa por livro (ou um Projeto com as instruções nas Instruções do Projeto).

1. Cole as instruções uma vez.
2. Anexe o ícone (trilha_app/assets/icon/app_icon_ios.png) e cole o bloco do livro.
3. Salve cada imagem em admin/arte/cenas/provisorio/ com o nome que o ChatGPT escrever. Se parar no meio, diga "continue".
4. Se vier grade ou várias cenas numa imagem só, diga "refaz N, uma imagem só".
5. No fim: node admin/scripts/scene_art_install.mjs

## Instruções (uma vez por conversa)

```text
Você vai pintar a arte das cenas do app STWAY.

Como vamos trabalhar:
- O ícone do STWAY vai anexado: o caminho branco em S sobre camadas azuis. Ele é a base de toda cena: cada imagem carrega esse caminho. Não copie o ícone em si; traga o caminho para dentro da paisagem.
- Eu mando a lista de cenas de uma trilha. Gere todas, em ordem, uma imagem por cena. Antes de cada imagem, escreva só o nome do arquivo dela (ex.: scene_gen-01-criador.jpg).
- Se parar no meio, eu digo "continue" e você segue da próxima cena. Quando eu disser "refaz N", pinte de novo só a cena N.
- Cada imagem = uma cena. Nunca junte cenas numa imagem só: nada de grade, mosaico, colagem, painéis, quadrinhos, tiras, folha de referência ou números nos cantos. Nunca mande variações da mesma cena.
- A imagem ocupa o quadro inteiro, de borda a borda, sem margem branca.

Estilo de todas as imagens:
Pintura digital cinematográfica e rica em detalhe, com pinceladas e textura visíveis, como quadro de filme épico bíblico. Luz de hora dourada: sol baixo no horizonte (pôr do sol ou aurora), céu que vai do azul profundo no alto ao laranja e dourado perto do sol, nuvens iluminadas por baixo, raios de luz no ar. Sombras e primeiro plano em azul-marinho e marrom profundo, com contraluz dourada recortando as figuras. Cena de noite também vale quando o texto pede: céu azul-escuro com estrelas ou lua, e o calor vem de fogo, tocha ou lamparina. Clima épico, sereno e reverente.
Formato paisagem 3:2 (1536×1024).
Composição em três planos:
- Primeiro plano: uma figura (ou um grupo pequeno) em tamanho médio, de costas ou de perfil, em pé com cajado ou sentada numa pedra, olhando a paisagem. Rosto em sombra ou de perfil, sem close. Moldura natural nas bordas: galho de árvore no alto, coluna ou ruína de pedra, rochas e mato embaixo. Às vezes, em vez da figura, um objeto da cena (pão, cálice, lamparina, rolo) sobre a pedra.
- Plano do meio: o caminho (abaixo) saindo de perto da figura e serpenteando pelo vale.
- Fundo: colinas, ciprestes, oliveiras, montanhas, e uma cidade, muralha ou templo no alto, onde o caminho chega, perto do sol.
Roupas, casas e objetos do mundo bíblico da época do texto: túnicas e mantos de linho e lã, casas de pedra, tendas, muralhas. Deus nunca aparece como figura humana: a presença dele é luz, raios, nuvem ou fogo. Jesus, se aparecer, de costas ou de perfil, rosto em sombra; na cruz, a cruz fica longe, recortada contra o céu.
Sem texto, letras, legendas, placas, inscrições, moldura, logotipo ou marca d'água; rolos e livros aparecem fechados ou com a escrita ilegível.

O caminho do ícone em toda cena: uma linha sinuosa em S, clara e luminosa, que atravessa a paisagem e some no horizonte rumo à luz. Ele vira algo do mundo da cena: estrada de terra ou de pedra, trilha, rio que reflete o sol, ou, quando a cena é do Espírito ou de Deus, fitas de vento e luz no céu. Nunca é uma faixa branca chapada nem um símbolo desenhado por cima.

Cena marcada como Travessia: é o desafio do bloco. Panorama mais amplo, de um ponto alto: o caminho mais longo e visível, atravessando o vale inteiro rumo à luz, e muitas vezes uma multidão ou caravana caminhando por ele.
Cena que trata de uma ideia e não de um acontecimento: pinte um lugar concreto do mundo bíblico que a represente (estrada, colina, porta em arco, mesa com pão e cálice, campo, videira, mar, rolo, lamparina). Nada de símbolos abstratos, diagramas ou ícones.
```

## Lucas — 29 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Lucas — Lucas capítulo a capítulo: o Salvador que busca e salva o perdido.

1. scene_lcc-01-o-anjo-e-maria.jpg — "O anjo e Maria" (Lucas 1:34–38) · bloco "O Salvador nasce · cap. 1–4"
Momento: No sexto mês da gravidez de Isabel, Deus envia o anjo Gabriel a Nazaré. Maria, virgem desposada com José, da linhagem de Davi, ouve uma saudação que não esperava.
Texto: "Maria indagou ao anjo: "Como acontecerá isso, visto que não tenho relação com homem algum?" E o anjo respondeu: O Espírito Santo descerá sobre você, e o poder do Altíssimo a envolverá com a sua sombra; portanto, também o Santo que há de nascer será chamado Filho de Deus. Eis que também Isabel, tua …"
Destaque: serva — Maria se apresenta como serva do Senhor e pede que a palavra dele se cumpra nela.

2. scene_lcc-02-na-casa-do-meu.jpg — "Na casa do meu Pai" (Lucas 2:46–51) · bloco "O Salvador nasce · cap. 1–4"
Momento: Todo ano a família de Jesus subia a Jerusalém para a festa da Páscoa. Terminados os dias da festa, a caravana parte. Os pais só percebem no caminho que o menino não está com o grupo.
Texto: "Após três dias, encontraram-no no templo, assentado no meio dos doutores, ouvindo-os e interrogando-os. E todos os que o ouviam se admiravam grandemente da sua inteligência e das suas respostas. E, ao vê-lo ficaram maravilhados, e sua mãe lhe disse: Filho, por que fizeste isso conosco? Teu pai e eu …"
Destaque: Pai — Jesus chama Deus de Pai e aponta a casa dele como o lugar onde precisa estar.

3. scene_lcc-03-que-devemos-fazer.jpg — "Que devemos fazer?" (Lucas 3:10–14) · bloco "O Salvador nasce · cap. 1–4"
Momento: João Batista fala às multidões que saíam para o batismo. Ele anuncia a ira que se aproxima e pede fruto, não apenas o nome de Abraão. Multidão, publicanos e soldados passam a perguntar o que devem fazer.
Texto: "A multidão o questionava, dizendo: "O que devemos, então, fazer?" Aquele que tiver duas túnicas, compartilhe com quem não tem; e quem tiver alimento faça o mesmo. Chegaram também alguns publicanos para serem batizados e perguntaram-lhe: Mestre, o que devemos fazer? E ele lhes disse: Não exijam além …"
Destaque: frutos — No texto, fruto é o sinal de arrependimento que sai da frase e aparece no gesto.

4. scene_lcc-04-o-espirito-esta-sobre.jpg — "O Espírito está sobre mim" (Lucas 4:16–21) · bloco "O Salvador nasce · cap. 1–4"
Momento: Jesus volta a Nazaré, a cidade onde cresceu. No sábado, a sinagoga se reúne para ouvir a Escritura. Ele entra, como fazia sempre, e se levanta para a leitura.
Texto: "E, ao chegar a Nazaré, onde fora criado, em um sábado, conforme seu costume, entrou na sinagoga e levantou-se para ler. E foi-lhe entregue o livro do profeta Isaías, e, ao abrir o livro, encontrou o local onde estava escrito: O Espírito do Senhor está sobre mim, porque me ungiu para evangelizar os …"
Destaque: cumprimento — Cumprimento, aqui, é a Escritura se realizando naquele dia, diante de quem acabou de ouvir.

5. scene_lcc-boss-1.jpg — "Travessia: O Salvador nasce" (Lucas 4:16–21) · Travessia · bloco "O Salvador nasce · cap. 1–4"
Momento: Esta travessia revisa o anúncio a Maria, o menino no templo, a pregação de João e a leitura em Nazaré. Gabriel fala com Maria. Aos doze anos, Jesus fica em Jerusalém. João pede frutos. Depois, Jesus lê na sinagoga.
Texto: "E, ao chegar a Nazaré, onde fora criado, em um sábado, conforme seu costume, entrou na sinagoga e levantou-se para ler. E foi-lhe entregue o livro do profeta Isaías, e, ao abrir o livro, encontrou o local onde estava escrito: O Espírito do Senhor está sobre mim, porque me ungiu para evangelizar os …"
Destaque: cumpriu — Na sinagoga, Jesus diz que a Escritura lida se cumpriu naquele dia, diante dos ouvintes.

6. scene_lcc-05-a-pesca-maravilhosa.jpg — "A pesca maravilhosa" (Lucas 5:5–10) · bloco "O Reino de perto · cap. 5–9"
Momento: Jesus estava à margem do lago de Genesaré, e a multidão o apertava para ouvir a palavra de Deus. Simão trabalhava na pesca com os parceiros, e os barcos estavam na beira do lago.
Texto: "Mestre, trabalhamos a noite toda e nada apanhamos, mas, sob tua palavra lançarei a rede. E, ao fazerem isso, apanharam uma grande quantidade de peixes; e as redes começaram a se romper. Fizeram sinais aos companheiros que estavam no outro barco para que os ajudassem; eles foram e encheram ambos os …"
Destaque: palavra — Na fala de Simão, a palavra de Jesus é o motivo para lançar a rede depois da noite vazia.

7. scene_lcc-06-a-trave-no-olho.jpg — "A trave no olho" (Lucas 6:37–42) · bloco "O Reino de perto · cap. 5–9"
Momento: No sermão da planície, Jesus vem do amor aos inimigos para o convívio entre discípulos. Fala de julgar, condenar, perdoar e dar, e segue com a imagem do cego e a do olho.
Texto: "Não julguem e não serão julgados; não condenem e não serão condenados; perdoem e receberão perdão. Deem, e será dado a vocês; boa medida, recalcada bem cheia, sacudida e transbordante, será colocada no colo de vocês; porque com a mesma medida que usarem para medir, também serão medidos. E …"
Destaque: trave — É a falta grande no próprio olho, que precisa sair para a pessoa ver e ajudar o irmão.

8. scene_lcc-07-muito-perdoada-muito-amou.jpg — "Muito perdoada, muito amou" (Lucas 7:44–49) · bloco "O Reino de perto · cap. 5–9"
Momento: Jesus está à mesa na casa de Simão, um fariseu. Uma mulher conhecida como pecadora aproximou-se durante a refeição e cuidou dos pés dele. Jesus se volta para Simão e compara a recepção dos dois.
Texto: "E, voltando-se para a mulher, disse a Simão: Vês esta mulher? Entrei em tua casa, e não me deste água para os pés; esta, porém, regou os meus pés com lágrimas e os enxugou com os seus cabelos. Não me ofereceste um beijo; mas esta mulher, desde que entrei, não cessa de me beijar os pés. Não me …"
Destaque: perdão — Perdão é a declaração de Jesus sobre os pecados da mulher, posta na mesma medida do amor dela.

9. scene_lcc-08-quem-e-este.jpg — "Quem é este?" (Lucas 8:22–25) · bloco "O Reino de perto · cap. 5–9"
Momento: A mãe e os irmãos de Jesus tentam chegar até ele, com a multidão no caminho. Em seguida, ele entra num barco com os discípulos para cruzar o lago.
Texto: "Certa vez, em um daqueles dias, ele entrou em um barco com seus discípulos e lhes disse: "Vamos para a outra margem do lago." E partiram. E, enquanto navegavam, ele adormeceu; então, uma tempestade de vento irrompeu no lago, e as águas começaram a encher o barco, correndo eles o risco de afundar. …"
Destaque: fé — Fé é o que Jesus pergunta aos discípulos no barco, no meio do medo.

10. scene_lcc-09-seguir-sem-olhar-para.jpg — "Seguir sem olhar para trás" (Lucas 9:57–62) · bloco "O Reino de perto · cap. 5–9"
Momento: Jesus vai pelo caminho com os discípulos. Três pessoas falam em acompanhá-lo. Uma oferece ir a qualquer lugar. As outras duas pedem para tratar de um assunto de família antes.
Texto: "E aconteceu que, enquanto eles caminhavam um homem lhe disse: Senhor, eu te seguirei para onde quer que vás. E Jesus lhe respondeu: As raposas têm seus covis, e as aves do céu, ninhos; mas o Filho do Homem não tem onde reclinar a cabeça. E disse a outro: Segue-me! Mas ele respondeu: Senhor, …"
Destaque: seguir — No relato, seguir é partir com Jesus na hora, sem pôr outra tarefa na frente.

11. scene_lcc-boss-2.jpg — "Travessia: O Reino de perto" (Lucas 9:57–62) · Travessia · bloco "O Reino de perto · cap. 5–9"
Momento: Esta travessia revisa a pesca no lago, a trave no olho, a mulher na casa de Simão, a tempestade no barco e três homens chamados a seguir Jesus. Cada cena põe alguém diante dele.
Texto: "E aconteceu que, enquanto eles caminhavam um homem lhe disse: Senhor, eu te seguirei para onde quer que vás. E Jesus lhe respondeu: As raposas têm seus covis, e as aves do céu, ninhos; mas o Filho do Homem não tem onde reclinar a cabeça. E disse a outro: Segue-me! Mas ele respondeu: Senhor, …"
Destaque: Reino — O Reino é o anúncio que Jesus pede para levar agora, sem voltar o olhar ao que ficou atrás.

12. scene_lcc-10-o-bom-samaritano.jpg — "O bom samaritano" (Lucas 10:30–35) · bloco "No caminho de Jerusalém · cap. 10–14"
Momento: Um mestre da Lei pergunta a Jesus quem é o seu próximo. Judeus e samaritanos viviam afastados. Jesus responde com uma história na descida de Jerusalém para Jericó.
Texto: "E, prosseguindo, Jesus disse: Certo homem descia de Jerusalém para Jericó e caiu nas mãos de salteadores, os quais, depois de lhe roubarem tudo e causarem-lhe muitos ferimentos, retiraram-se, deixando-o semimorto. E, por acaso, descia um sacerdote pelo mesmo caminho; ao vê-lo, passou de largo. E da …"
Destaque: misericórdia — Misericórdia, neste relato, é chegar perto de quem sofre e cuidar dele de fato.

13. scene_lcc-11-pecam-e-receberao.jpg — "Peçam e receberão" (Lucas 11:9–13) · bloco "No caminho de Jerusalém · cap. 10–14"
Momento: Jesus acabou de ensinar os discípulos a orar. Em seguida, conta de um homem que, à meia-noite, vai pedir três pães a um amigo. A história abre o ensino sobre pedir, buscar e bater.
Texto: "Peçam, e será-lhes dado; busquem e encontrarão; batam, e a porta se abrirá Pois todo aquele que pede recebe; quem busca encontra; e a quem bate, abrir-se-lhe-á. Qual de vocês, pais, se o filho lhe pedir pão, lhe dará uma pedra? Ou se pedir peixe, lhe dará uma cobra em lugar de peixe? Ou, se lhe …"
Destaque: pedir — Pedir é a oração que Jesus manda fazer, com a certeza de que há resposta.

14. scene_lcc-12-o-rico-insensato.jpg — "O rico insensato" (Lucas 12:16–21) · bloco "No caminho de Jerusalém · cap. 10–14"
Momento: Alguém na multidão pede a Jesus que reparta uma herança. Jesus recusa o papel de juiz e alerta contra a avareza. Depois, a parábola apresenta um homem cuja propriedade produziu em excesso.
Texto: "E lhes propôs uma parábola, dizendo: A propriedade de um homem rico havia produzido com abundância. E ele refletia consigo mesmo, dizendo: O que farei, pois não tenho onde guardar os meus frutos? E disse: Farei o seguinte: destruirei os meus celeiros, reconstruí-los-ei maiores e ali recolherei …"
Destaque: insensato — Nome que Deus dá a quem conta com muitos anos de bens e guarda tudo para si.

15. scene_lcc-13-a-mulher-encurvada.jpg — "A mulher encurvada" (Lucas 13:12–17) · bloco "No caminho de Jerusalém · cap. 10–14"
Momento: Num sábado, Jesus ensinava numa sinagoga. Ali estava uma mulher encurvada havia dezoito anos, sem conseguir endireitar o corpo. O chefe da sinagoga vigiava o que se podia fazer nesse dia.
Texto: "E, ao vê-la, Jesus a chamou e disse: Mulher, você está livre da sua doença; E, impondo-lhe as mãos, imediatamente se endireitou e glorificou a Deus. E, tomando a palavra o chefe da sinagoga, indignado ao ver que Jesus curava no sábado, disse à multidão: "Seis dias há em que se deve trabalhar; …"
Destaque: livre — Jesus declara a mulher livre da doença e a solta no próprio sábado.

16. scene_lcc-14-o-grande-banquete.jpg — "O grande banquete" (Lucas 14:19–24) · bloco "No caminho de Jerusalém · cap. 10–14"
Momento: Jesus está à mesa. Um dos presentes declara feliz quem comer pão no reino de Deus. Em resposta, Jesus conta de um homem que prepara uma grande ceia e manda chamar os convidados na hora.
Texto: "E outro disse: Comprei cinco juntas de bois e vou experimentá-las; rogo-te que me tenhas por escusado. E outro disse: Casei-me e, por isso, não posso ir. E, ao voltar, aquele servo contou todas as coisas ao seu senhor. Então, o dono da casa, irado, disse ao seu servo: "Saia depressa para as ruas e …"
Destaque: ceia — Refeição grande já preparada, da qual só participa quem aceita o chamado e entra.

17. scene_lcc-boss-3.jpg — "Travessia: No caminho de Jerusalém" (Lucas 10:33–37) · Travessia · bloco "No caminho de Jerusalém · cap. 10–14"
Momento: No caminho para Jerusalém, Jesus conta o ferido na descida, a oração à meia-noite, o rico e seus celeiros, a mulher na sinagoga e a grande ceia.
Texto: "Mas um certo samaritano, que viajava, chegou perto dele e, ao vê-lo, teve compaixão. E, aproximando-se, tratou de suas feridas, aplicando azeite e vinho; depois, colocou-o sobre seu próprio animal e levou-o para uma hospedaria, onde cuidou dele. E, no dia seguinte, tomou dois denários, entregou-os …"
Destaque: misericórdia — Misericórdia, nestas cenas, é chegar perto, soltar quem está preso e abrir a casa.

18. scene_lcc-15-o-filho-que-voltou.jpg — "O filho que voltou" (Lucas 15:20–24) · bloco "Perdidos e achados · cap. 15–19"
Momento: Jesus conta de um homem com dois filhos. O mais novo pede a parte da herança, vai para longe e gasta tudo. Uma fome o deixa entre os porcos. O relato segue a decisão de voltar e a resposta do pai.
Texto: "Levantou-se e foi ao encontro de seu pai; e, enquanto estava ainda longe, seu pai o avistou, e, se encheu de compaixão, correndo, lançou-se ao seu pescoço e o beijou. Pai, pequei contra o céu e diante de ti; já não sou digno de ser chamado teu filho, disse-lhe o filho. Mas o pai disse aos seus …"
Destaque: compaixão — Compaixão é o que toma o pai ao ver o filho, e no relato esse sentimento se torna ação.

19. scene_lcc-16-o-rico-e-lazaro.jpg — "O rico e Lázaro" (Lucas 16:19–24) · bloco "Perdidos e achados · cap. 15–19"
Momento: Jesus conta esta história a pessoas apegadas ao dinheiro. Um rico se veste com luxo e faz festa todos os dias. Um mendigo cheio de chagas fica à porta dele, à espera do que cai da mesa.
Texto: "Havia um homem rico que se vestia de púrpura e de linho finíssimo e que, todos os dias, se regalava esplendidamente. Havia também um certo mendigo, chamado Lázaro, cheio de chagas, que jazia à porta daquele; E desejava alimentar-se das migalhas que caíam da mesa do rico; e até os cães vinham lamber …"
Destaque: ouçam — É o pedido de Abraão: que os irmãos escutem Moisés e os Profetas.

20. scene_lcc-17-os-dez-leprosos.jpg — "Os dez leprosos" (Lucas 17:14–19) · bloco "Perdidos e achados · cap. 15–19"
Momento: Jesus segue para Jerusalém e passa entre a Samaria e a Galileia. Pela Lei, quem tinha lepra vivia afastado do convívio e só voltava depois que o sacerdote reconhecia a purificação.
Texto: "Ele, ao vê-los, disse-lhes: Vão e apresentem-se aos sacerdotes. E aconteceu que, enquanto iam, foram purificados. E um deles, ao perceber que estava curado, retornou, dando glória a Deus em alta voz. E prostrou-se aos pés de Jesus, com o rosto em terra, agradecendo-Lhe; e este era samaritano. E, …"
Destaque: gratidão — Gratidão, neste relato, é voltar para dar glória a Deus e reconhecer Jesus de perto.

21. scene_lcc-18-o-fariseu-e-o.jpg — "O fariseu e o publicano" (Lucas 18:9–14) · bloco "Perdidos e achados · cap. 15–19"
Momento: Jesus dirige esta parábola a quem confiava em si, se julgava justo e desprezava os outros. No templo, um fariseu e um publicano sobem para orar.
Texto: "E também propôs esta parábola a alguns que confiavam em si mesmos, por se considerarem justos e desprezavam os outros: Dois homens subiram ao templo com o propósito de orar: um fariseu e o outro, um publicano. O fariseu, de pé, orava assim consigo mesmo: "Ó Deus, te agradeço porque não sou como os …"
Destaque: humildade — Chegar diante de Deus como pecador, sem apoiar a oração em méritos próprios.

22. scene_lcc-19-zaqueu.jpg — "Zaqueu" (Lucas 19:1–6) · bloco "Perdidos e achados · cap. 15–19"
Momento: Jesus entra em Jericó e atravessa a cidade. Zaqueu, chefe dos cobradores de impostos, é rico e de pequena estatura. Ele quer ver Jesus, mas a multidão ocupa o caminho.
Texto: "E, ao entrar em Jericó, Jesus atravessava a cidade. Havia um homem chamado Zaqueu, que era o maioral dos publicanos e também rico. E procurava ver quem era Jesus, mas não podia por causa da multidão, pois era de pequena estatura. E, correndo adiante, subiu em uma sicômoro para vê-lo, pois ele ia …"
Destaque: perdidos — São as pessoas que o Filho do Homem veio buscar e salvar.

23. scene_lcc-boss-4.jpg — "Travessia: Perdidos e achados" (Lucas 19:3–8) · Travessia · bloco "Perdidos e achados · cap. 15–19"
Momento: Esta travessia revisa o filho na terra distante, o rico e Lázaro, os dez leprosos, a oração no templo e Zaqueu em Jericó. Cada cena mostra alguém afastado e uma resposta.
Texto: "E procurava ver quem era Jesus, mas não podia por causa da multidão, pois era de pequena estatura. E, correndo adiante, subiu em uma sicômoro para vê-lo, pois ele ia passar por ali. E, ao chegar àquele lugar, Jesus olhou para cima, viu Zaqueu e disse: "Desce rapidamente, pois é necessário que eu …"
Destaque: Justificado — Quem se humilha e se reconhece pecador desce justificado; quem se exalta, não.

24. scene_lcc-20-a-cesar-e-a.jpg — "A César e a Deus" (Lucas 20:20–25) · bloco "Entregue e ressuscitado · cap. 20–24"
Momento: No templo, pessoas com aparência de justas se aproximam de Jesus. Um elogio abre a conversa. A pergunta sobre o tributo a César tenta encurralá-lo diante do povo e do governador.
Texto: "E, à espreita, enviaram espiões que se faziam passar por justos, para pegá-lo em alguma palavra e entregá-lo à jurisdição e à autoridade do governador. Mestre, sabemos que você fala e ensina com retidão e sinceridade, e que não se deixa influenciar por aparências, mas ensina o caminho de Deus …"
Destaque: tributo — O imposto devido a César, tema da pergunta que tenta encurralar Jesus.

25. scene_lcc-21-a-oferta-da-viuva.jpg — "A oferta da viúva" (Lucas 21:1–4) · bloco "Entregue e ressuscitado · cap. 20–24"
Momento: Jesus está no templo e observa quem deposita ofertas no gazofilácio, o cofre das contribuições. Os ricos se aproximam com o que trazem. Uma viúva pobre chega e lança duas pequenas moedas.
Texto: "E, observando, viu os ricos colocando suas ofertas no gazofilácio. E viu também certa viúva pobre lançar ali duas pequenas moedas. Em verdade, eu digo a vocês que esta viúva pobre deu mais do que todos. Porque todos aqueles deram como oferta do que lhes sobrava; mas esta, da sua pobreza, deu tudo o …"
Destaque: sustento — Sustento é aquilo de que a viúva vivia, e foi isso que ela colocou no gazofilácio.

26. scene_lcc-22-orem-para-nao-cair.jpg — "Orem para não cair" (Lucas 22:39–44) · bloco "Entregue e ressuscitado · cap. 20–24"
Momento: Na noite da ceia, Jesus sai com os discípulos. O Monte das Oliveiras era o lugar a que ele costumava ir. A hora da prisão se aproxima, e eles chegam a um lugar escolhido.
Texto: "E, ao sair, foi, como era de seu hábito, para o Monte das Oliveiras; e os discípulos o seguiram. E, ao chegar ao lugar escolhido, Jesus lhes disse: Orem para que não caiam em tentação. Afastou-se deles cerca de uma lança de pedra e, colocando-se de joelhos, começou a orar Pai, se quiseres, afasta …"
Destaque: oração — O que Jesus pede aos discípulos e o que ele mesmo faz, de joelhos, diante do Pai.

27. scene_lcc-23-hoje-estaras-comigo.jpg — "Hoje estarás comigo" (Lucas 23:39–43) · bloco "Entregue e ressuscitado · cap. 20–24"
Momento: Jesus está na cruz, entre dois criminosos. Soldados zombam dele e oferecem vinagre. Uma inscrição o apresenta como rei dos judeus. Os dois homens ao lado falam com ele de modos opostos.
Texto: "Um dos criminosos crucificados o insultava, dizendo: "Você não é o Cristo? Salve a si mesmo e a nós também." Mas o outro, respondendo, o censurou, dizendo: Você nem ao menos teme a Deus, estando sob a mesma condenação? Nós, de fato, estamos aqui com justiça, pois recebemos o castigo que nossas …"
Destaque: Paraíso — Lugar que Jesus nomeia, onde o criminoso estará com ele ainda naquele dia.

28. scene_lcc-24-no-partir-do-pao.jpg — "No partir do pão" (Lucas 24:30–35) · bloco "Entregue e ressuscitado · cap. 20–24"
Momento: Dois discípulos vão a uma aldeia com um caminhante ainda desconhecido. Na chegada, o dia declina, e eles não querem que ele siga viagem.
Texto: "E aconteceu que, estando eles à mesa, tomou o pão, abençoou-o, partiu-o e lhes deu. Então, os olhos deles foram abertos e o reconheceram, mas ele desapareceu de sua vista. E disseram um ao outro: Porventura, não ardia o nosso coração quando ele nos falava pelo caminho e nos expunha as Escrituras? …"
Destaque: partir o pão — É o gesto à mesa em que os olhos se abrem e o caminhante é reconhecido.

29. scene_lcc-boss-5.jpg — "Travessia: Entregue e ressuscitado" (Lucas 24:30–35) · Travessia · bloco "Entregue e ressuscitado · cap. 20–24"
Momento: Esta travessia revisa o tributo a César, a oferta da viúva, a oração no monte, a promessa na cruz e a mesa em Emaús. Os relatos vão da pergunta sobre o tributo até o reconhecimento à mesa.
Texto: "E aconteceu que, estando eles à mesa, tomou o pão, abençoou-o, partiu-o e lhes deu. Então, os olhos deles foram abertos e o reconheceram, mas ele desapareceu de sua vista. E disseram um ao outro: Porventura, não ardia o nosso coração quando ele nos falava pelo caminho e nos expunha as Escrituras? …"
Destaque: Entrega — Entregar é dar a Deus o que é dele e aceitar a vontade do Pai.

Gere todas as 29 imagens com foco no ícone do STWAY.
```
