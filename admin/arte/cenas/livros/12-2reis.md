# 2 Reis — 30 cena(s)

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

## 2 Reis — 30 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: 2 Reis — 2 Reis capítulo a capítulo: Eliseu, Jeú, a queda de Samaria e de Jerusalém.

1. scene_r2c-01-fogo-do-ceu.jpg — "Fogo do céu" (2 Reis 1:9–16) · bloco "Elias e Eliseu · cap. 1–4"
Momento: O rei manda capitães buscar Elias, e o fogo do céu responde. Respeitar o profeta
Texto: "Então, o rei enviou um capitão de cinquenta soldados para subirem até o profeta, que estava sentado no cimo do monte; e o capitão disse-lhe: Homem de Deus, o rei manda dizer: Desça. Mas Elias respondeu ao capitão de cinquenta: "Se eu sou homem de Deus, desça fogo do céu e te consuma a ti e aos teus …"
Destaque: enviou — É uma palavra central deste trecho: aparece no texto da cena.

2. scene_r2c-02-carro-de-fogo.jpg — "Carro de fogo" (2 Reis 2:1–11) · bloco "Elias e Eliseu · cap. 1–4"
Momento: Eliseu acompanha Elias até o Jordão e pede porção dobrada do espírito. Seguir até o fim
Texto: "Quando o Senhor estava prestes a levar Elias ao céu por meio de um redemoinho, Elias partiu de Gilgal acompanhado de Eliseu. Elias disse a Eliseu: "Fica aqui, pois o SENHOR me enviou a Betel." Eliseu, porém, respondeu: "Tão certo como vive o SENHOR e vive a tua alma, não te deixarei." E assim …"
Destaque: Senhor — É uma palavra central deste trecho: aparece no texto da cena.

3. scene_r2c-03-agua-no-deserto.jpg — "Água no deserto" (2 Reis 3:15–20) · bloco "Elias e Eliseu · cap. 1–4"
Momento: Três reis marcham contra Moabe e ficam sem água. Josafá busca um profeta; Eliseu, por causa de Josafá, anuncia vales cheios sem vento nem chuva visível.
Texto: "Agora, pois, tragam-me um tocador. E aconteceu que, quando o tocador começava a tocar, o poder de Deus veio sobre Eliseu. E disse: Assim diz o SENHOR: Façam neste vale covas e mais covas. Porque assim diz o Senhor: Vocês não sentirão vento, nem verão chuva; contudo, este vale se encherá de tanta …"
Destaque: água — A provisão que o Senhor põe no vale sem sinais de chuva.

4. scene_r2c-04-o-azeite-que-multiplica.jpg — "O azeite que multiplica" (2 Reis 4:1–6) · bloco "Elias e Eliseu · cap. 1–4"
Momento: A viúva de um discípulo dos profetas tem dívida e risco de perder os filhos. Eliseu manda pedir vasilhas vazias; o azeite corre até não haver mais vasos.
Texto: "Uma mulher dos discípulos dos profetas clamou a Eliseu, dizendo: “Meu marido, teu servo, morreu; e tu sabes que ele temia ao SENHOR. Agora o credor chegou para levar meus dois filhos e torná-los seus escravos.” E Eliseu lhe perguntou: O que posso fazer por você? Diga-me o que você tem em sua casa. …"
Destaque: azeite — O pouco que a viúva tem e que o Senhor multiplica até cobrir a dívida.

5. scene_r2c-boss-1.jpg — "Travessia: Elias e Eliseu" (2 Reis 2:8–10) · Travessia · bloco "Elias e Eliseu · cap. 1–4"
Momento: Esta Travessia revisa o fogo sobre os capitães, a fidelidade de Eliseu até o Jordão, a água no vale sem chuva e o azeite que cobre a dívida da viúva.
Texto: "Então, Elias tomou sua capa, enrolou-a e feriu as águas, que se dividiram para os dois lados; e ambos passaram em seco. Sucedeu que, após passarem, Elias disse a Eliseu: "Pede-me o que desejas que eu te faça, antes que eu seja levado de ti." Eliseu respondeu: "Peço-te que me concedas uma porção …"
Destaque: profeta — O servo pela palavra do Senhor: juízo, sucessão, provisão e cuidado.

6. scene_r2c-05-naama-no-jordao.jpg — "Naamã no Jordão" (2 Reis 5:8–14) · bloco "Sinais de Eliseu · cap. 5–8"
Momento: Eliseu manda o leproso sírio lavar-se sete vezes no Jordão. Obedecer com humildade
Texto: "Sucedeu que, ao ouvir Eliseu, homem de Deus, que o rei de Israel rasgara as suas vestes, enviou ao rei a seguinte mensagem: "Por que rasgaste as tuas vestes? Deixa-o vir até mim, e ele saberá que há um profeta em Israel." Então, Naamã chegou com seus cavalos e carros e parou à porta da casa de …"
Destaque: Sucedeu — É uma palavra central deste trecho: aparece no texto da cena.

7. scene_r2c-06-carros-de-fogo.jpg — "Carros de fogo" (2 Reis 6:15–23) · bloco "Sinais de Eliseu · cap. 5–8"
Momento: O moço de Eliseu teme o exército sírio, até ter os olhos abertos. Ver o que Deus vê
Texto: "E o jovem do homem de Deus levantou-se muito cedo, saiu e viu que tropas, cavalos e carros cercavam a cidade; então, ele disse ao seu mestre: Ai, meu senhor! O que faremos? Não tema, porque são mais os que estão conosco do que os que estão com eles. E Eliseu orou e disse: Senhor, peço-te que lhe …"
Destaque: jovem — É uma palavra central deste trecho: aparece no texto da cena.

8. scene_r2c-07-boas-novas-a-porta.jpg — "Boas-novas à porta" (2 Reis 7:1–6) · bloco "Sinais de Eliseu · cap. 5–8"
Momento: Samaria está sob cerco e fome. Eliseu anuncia abundância para o dia seguinte; quatro leprosos descobrem o acampamento sírio vazio.
Texto: "Então, disse Eliseu: Ouçam a palavra do Senhor; assim diz o Senhor: Amanhã, a estas horas um alqueire de flor de farinha custará um siclo, e dois alqueires de cevada, por um siclo, à porta de Samaria. Entretanto, um capitão em quem o rei se apoiava respondeu ao homem de Deus: "Ainda que o Senhor …"
Destaque: boas novas — O livramento achado pelos leprosos — notícia que não pode ficar em silêncio.

9. scene_r2c-08-hazael-e-a-lagrima.jpg — "Hazael e a lágrima" (2 Reis 8:7–12) · bloco "Sinais de Eliseu · cap. 5–8"
Momento: Eliseu chega a Damasco enquanto Ben-Hadade está doente. Hazael vem perguntar se o rei sarará; o profeta vê o futuro cruel e chora.
Texto: "Eliseu chegou a Damasco, onde Ben-Hadade, rei da Síria, se encontrava doente; e lhe disseram, informando: O homem de Deus está aqui. Então o rei disse a Hazael: leve um presente em suas mãos e vá ao encontro do homem de Deus; pergunte ao Senhor por intermédio dele: Sararei eu desta doença? Então …"
Destaque: chorou — A lágrima de Eliseu diante do mal que Hazael fará a Israel.

10. scene_r2c-boss-2.jpg — "Travessia: Sinais de Eliseu" (2 Reis 5:10–14) · Travessia · bloco "Sinais de Eliseu · cap. 5–8"
Momento: Esta Travessia revisa os sinais de Eliseu: a cura de Naamã, os carros de fogo, os leprosos anunciantes e a lágrima diante de Hazael.
Texto: "Então, Eliseu enviou um mensageiro, dizendo: "Vá, lave-se sete vezes no Jordão, e a sua carne será restaurada, e você ficará limpo. Naamã, porém, se indignou com isso e se retirou, dizendo: Eu pensava que ele sairia, colocaria-se de pé, invocaria o nome do Senhor, seu Deus, moveria a mão sobre o …"
Destaque: profeta — Eliseu, homem de Deus, por quem o Senhor cura, protege, livra e revela juízos.

11. scene_r2c-09-jeu-ungido.jpg — "Jeú ungido" (2 Reis 9:1–6) · bloco "Jeú e Judá · cap. 9–12"
Momento: Eliseu envia um discípulo a Ramote-Gileade. Em segredo, Jeú é ungido rei e recebe a ordem de ferir a casa de Acabe.
Texto: "Então, o profeta Eliseu chamou um dos discípulos dos profetas e lhe disse: Cinge os lombos, leva contigo este vaso de azeite e vai-te a Ramote-Gileade. E, ao chegar lá, veja onde está Jeú, filho de Josafá, filho de Ninsi; entre, faça-o levantar-se do meio de seus irmãos e leve-o para a câmara …"
Destaque: ungi — O Senhor declara Jeú rei sobre Israel pela unção com azeite.

12. scene_r2c-10-baal-destruido.jpg — "Baal destruído" (2 Reis 10:18–23) · bloco "Jeú e Judá · cap. 9–12"
Momento: Jeú convoca os adoradores de Baal com um estratagema. Depois do holocausto, a casa de Baal é destruída.
Texto: "Então Jeú convocou todo o povo e disse: "Acabe serviu pouco a Baal; eu, porém, o servirei muito." Portanto, mande chamar todos os profetas de Baal, todos os seus servidores e todos os seus sacerdotes; que nenhum falte, pois tenho um grande sacrifício a oferecer a Baal; todo aquele que faltar não …"
Destaque: astúcia — Jeú age com astúcia para reunir e destruir os servidores de Baal.

13. scene_r2c-11-joas-escondido.jpg — "Joás escondido" (2 Reis 11:1–6) · bloco "Jeú e Judá · cap. 9–12"
Momento: Atalia tenta apagar a linhagem real. Jeoseba esconde Joás no templo; no sétimo ano, Joiada o unge rei.
Texto: "Vendo, então, Atalia, mãe de Acazias, que seu filho havia morrido, levantou-se e exterminou toda a linhagem real. Mas Jeoseba, filha do rei Jorão e irmã de Acazias, tomou Joás, filho de Acazias, e o furtou entre os filhos do rei, que estavam sendo mortos. Colocou-o, a ele e à sua ama, em uma câmara …"
Destaque: escondido — Joás permanece escondido na Casa do Senhor enquanto Atalia governa.

14. scene_r2c-12-reparar-a-casa.jpg — "Reparar a casa" (2 Reis 12:1–6) · bloco "Jeú e Judá · cap. 9–12"
Momento: Joás reina em Jerusalém sob a orientação de Joiada. Ele manda usar o dinheiro sagrado para reparar a Casa do Senhor.
Texto: "No sétimo ano de Jeú, Joás começou a reinar e governou durante quarenta anos em Jerusalém. O nome de sua mãe era Zíbia, de Berseba. E Joás fez o que era justo perante o Senhor, todos os dias em que o sacerdote Joiada o guiou. Entretanto, os altos não foram removidos, e o povo ainda sacrificava e …"
Destaque: reparar — O rei insiste em restaurar os danos da casa do Senhor.

15. scene_r2c-boss-3.jpg — "Travessia: Jeú e Judá" (2 Reis 9:1–6) · Travessia · bloco "Jeú e Judá · cap. 9–12"
Momento: Revise a unção de Jeú, a queda de Baal, Joás escondido no templo e o reparo da casa do Senhor.
Texto: "Então, o profeta Eliseu chamou um dos discípulos dos profetas e lhe disse: Cinge os lombos, leva contigo este vaso de azeite e vai-te a Ramote-Gileade. E, ao chegar lá, veja onde está Jeú, filho de Josafá, filho de Ninsi; entre, faça-o levantar-se do meio de seus irmãos e leve-o para a câmara …"
Destaque: ungi — O Senhor unge Jeú e preserva a linhagem; juízo e promessa andam juntos.

16. scene_r2c-13-flechas-da-vitoria.jpg — "Flechas da vitória" (2 Reis 13:14–19) · bloco "Declínio do norte · cap. 13–17"
Momento: Eliseu está doente de morte. Jeoás, rei de Israel, chora sobre ele. O profeta manda atirar flechas: vitória prometida, mas a fé tímida limita o alcance.
Texto: "E Eliseu estava enfermo da doença da qual morreria. Então, Jeoás, rei de Israel, desceu até ele e chorou sobre seu rosto, dizendo: Meu pai, meu pai! O carro de Israel e seus cavaleiros! E Eliseu lhe disse: Toma um arco e flechas; e ele tomou um arco e flechas. Disse então ao rei de Israel: Retenha …"
Destaque: vitória — A flecha aponta o livramento do Senhor contra os sírios — e o limite da fé tímida.

17. scene_r2c-14-amazias-em-juda.jpg — "Amazias em Judá" (2 Reis 14:1–6) · bloco "Declínio do norte · cap. 13–17"
Momento: Amazias sobe ao trono de Judá. Faz o que é reto, porém não como Davi; os altos ficam, e ele vence Edom no Vale do Sal.
Texto: "No segundo ano de Jeoás, filho de Jeoacaz, rei de Israel, começou a reinar Amazias, filho de Joás, rei de Judá. Tinha vinte e cinco anos quando começou a reinar, e reinou em Jerusalém durante vinte e nove anos. O nome de sua mãe era Jeoadã, de Jerusalém. E fez o que era reto aos olhos do Senhor, …"
Destaque: reto — Amazias age com retidão parcial: reto aos olhos do Senhor, mas sem a medida de Davi.

18. scene_r2c-15-o-altar-de-acaz.jpg — "O altar de Acaz" (2 Reis 16:7–12) · bloco "Declínio do norte · cap. 13–17"
Momento: Rezim e Peca cercam Acaz. Em vez de confiar no Senhor, Acaz pede socorro à Assíria, esvazia a Casa do Senhor e copia um altar de Damasco.
Texto: "Acaz enviou mensageiros a Tiglate-Pileser, rei da Assíria, dizendo: Sou teu servo e teu filho; vem e livra-me do poder do rei da Síria e do poder do rei de Israel, que se levantam contra mim. E Acaz tomou a prata e o ouro que se encontraram na Casa do SENHOR e nos tesouros da casa do rei, e enviou …"
Destaque: altar — O modelo estrangeiro que Acaz manda Urias edificar e sobre o qual ele sacrifica.

19. scene_r2c-16-samaria-cai.jpg — "Samaria cai" (2 Reis 17:1–6) · bloco "Declínio do norte · cap. 13–17"
Momento: Oséias é o último rei do norte. A Assíria sobe, descobre conspiração com o Egito, cerca Samaria três anos e leva Israel ao exílio.
Texto: "No décimo segundo ano do rei Acaz, de Judá, Oséias, filho de Elá, começou a reinar e governou sobre Israel, em Samaria, durante nove anos. E fez o que era mau perante o Senhor, mas não como os reis de Israel que o antecederam. Contra ele subiu Salmanasar rei da Assíria; e Oséias se tornou seu …"
Destaque: Samaria — A capital do norte que cai e marca o fim do reino de Israel.

20. scene_r2c-boss-4.jpg — "Travessia: Declínio do norte" (2 Reis 17:1–6) · Travessia · bloco "Declínio do norte · cap. 13–17"
Momento: Esta Travessia revisa o declínio do norte: flechas de Eliseu, retidão parcial de Amazias, o altar de Acaz e a queda de Samaria.
Texto: "No décimo segundo ano do rei Acaz, de Judá, Oséias, filho de Elá, começou a reinar e governou sobre Israel, em Samaria, durante nove anos. E fez o que era mau perante o Senhor, mas não como os reis de Israel que o antecederam. Contra ele subiu Salmanasar rei da Assíria; e Oséias se tornou seu …"
Destaque: Samaria — A capital que cai e marca o fim do reino do norte no exílio.

21. scene_r2c-17-ezequias-confia.jpg — "Ezequias confia" (2 Reis 18:1–8) · bloco "Ezequias · cap. 18–21"
Momento: Ezequias remove os altos, quebra a serpente de bronze e confia no Senhor. Apegar-se ao Senhor
Texto: "No terceiro ano de Oséias, filho de Elá, rei de Israel, começou a reinar Ezequias, filho de Acaz, rei de Judá. Tinha vinte e cinco anos quando começou a reinar, e reinou vinte e nove anos em Jerusalém. Sua mãe se chamava Abi, e era filha de Zacarias. E fez o que era reto diante do Senhor, de acordo …"
Destaque: terceiro — É uma palavra central deste trecho: aparece no texto da cena.

22. scene_r2c-18-o-anjo-no-acampamento.jpg — "O anjo no acampamento" (2 Reis 19:32–37) · bloco "Ezequias · cap. 18–21"
Momento: O Senhor responde à oração de Ezequias contra a Assíria. Deus defende Sião
Texto: "Portanto, assim diz o Senhor a respeito do rei da Assíria: Não entrará nesta cidade, nem lançará nela flecha alguma; não virá diante dela com escudo, nem levantará contra ela qualquer cerco. Pelo caminho por onde veio por esse voltará; mas, nesta cidade não entrará, diz o Senhor. Porque eu …"
Destaque: Senhor — É uma palavra central deste trecho: aparece no texto da cena.

23. scene_r2c-19-quinze-anos-a-mais.jpg — "Quinze anos a mais" (2 Reis 20:1–6) · bloco "Ezequias · cap. 18–21"
Momento: Ezequias adoece de morte. Isaías anuncia o fim; o rei ora e chora. O Senhor acrescenta quinze anos e confirma com a sombra.
Texto: "Naqueles dias, Ezequias adoeceu de uma enfermidade mortal; então, o profeta Isaías, filho de Amoz, foi até ele e disse: Assim diz o Senhor: Ponha a sua casa em ordem, pois você morrerá e não viverá. Então, Ezequias virou o rosto para a parede e orou ao Senhor, dizendo: Ah, Senhor! Peço-te que te …"
Destaque: oração — O Senhor ouve a oração de Ezequias e vê suas lágrimas.

24. scene_r2c-20-manasses-desvia.jpg — "Manassés desvia" (2 Reis 21:1–6) · bloco "Ezequias · cap. 18–21"
Momento: Manassés sucede Ezequias. Reconstrói o que o pai destruíra, enche Judá de idolatria e faz o povo pior que as nações.
Texto: "Manassés tinha doze anos quando começou a reinar e reinou cinquenta e cinco anos em Jerusalém. O nome de sua mãe era Hefzibá. E fez o que era mau perante o Senhor, conforme as abominações dos gentios que o Senhor expulsara de diante dos filhos de Israel. Porque voltou a edificar os altares que …"
Destaque: altares — Manassés ergue de novo o que Ezequias tinha derrubado, até na casa do Senhor.

25. scene_r2c-boss-5.jpg — "Travessia: Ezequias" (2 Reis 18:3–8) · Travessia · bloco "Ezequias · cap. 18–21"
Momento: Esta Travessia revisa Ezequias: confiança e reforma, o anjo no acampamento, quinze anos a mais e o desvio de Manassés.
Texto: "E fez o que era reto diante do Senhor, de acordo com tudo o que Davi, seu pai, realizou. Ele removeu os altos, quebrou as colunas, derrubou os bosques e destruiu a serpente de bronze que Moisés fizera, pois até aquele dia os filhos de Israel queimavam incenso a ela e a chamavam Neustã. Ele confiou …"
Destaque: confiou — Ezequias confia e é livrado; Manassés desfaz a reforma e prepara a queda.

26. scene_r2c-21-o-livro-achado.jpg — "O livro achado" (2 Reis 22:8–13) · bloco "Queda de Jerusalém · cap. 22–25"
Momento: O sacerdote acha o livro da lei, e o rei rasga as vestes ao ouvi-lo. Ouvir a lei de novo
Texto: "Então o sumo sacerdote Hilquias disse ao escrivão Safã: “Achei o Livro da Lei na Casa do SENHOR.” Hilquias entregou o livro a Safã, e este o leu. Então, o escrivão Safã foi ao rei e lhe apresentou o relatório, dizendo: "Teus servos contaram o dinheiro que foi encontrado na Casa e o entregaram nas …"
Destaque: sacerdote — É uma palavra central deste trecho: aparece no texto da cena.

27. scene_r2c-22-josias-limpa-a-terra.jpg — "Josias limpa a terra" (2 Reis 23:1–6) · bloco "Queda de Jerusalém · cap. 22–25"
Momento: Depois de achar o livro, Josias reúne o povo, lê a aliança e faz reforma: tira ídolos do templo, destitui sacerdotes idólatras e profana os altos.
Texto: "Então, o rei deu ordens e todos os anciãos de Judá e de Jerusalém se reuniram a ele. E o rei subiu à Casa do Senhor, acompanhado por todos os homens de Judá, todos os moradores de Jerusalém, os sacerdotes, os profetas e todo o povo, desde o menor até o maior; e leu diante deles todas as palavras do …"
Destaque: aliança — O compromisso público diante do Senhor, escrito no livro e confirmado pelo povo.

28. scene_r2c-23-a-primeira-leva.jpg — "A primeira leva" (2 Reis 24:10–15) · bloco "Queda de Jerusalém · cap. 22–25"
Momento: Nabucodonosor cerca Jerusalém. Joaquim se entrega; tesouros, nobres e artesãos vão à Babilônia. Só o povo pobre fica; Matanias vira Zedequias.
Texto: "Neste tempo, os servos de Nabucodonosor, rei da Babilônia, subiram a Jerusalém, e a cidade foi cercada. Nabucodonosor, rei da Babilônia, veio à cidade, quando os seus servos a sitiavam. Então, Joaquim, rei de Judá, subiu para se encontrar com o rei da Babilônia, com ele estavam sua mãe, seus …"
Destaque: cativo — Levar embora o rei, os nobres e os tesouros: o juízo em etapas.

29. scene_r2c-24-jerusalem-cai.jpg — "Jerusalém cai" (2 Reis 25:1–6) · bloco "Queda de Jerusalém · cap. 22–25"
Momento: Após longo cerco, Jerusalém é arrombada. Zedequias foge, é capturado e cegado. Nebuzaradã queima o templo, derruba os muros e leva o povo; deixa alguns pobres na terra.
Texto: "E aconteceu que, no nono ano do seu reinado, no dia dez do décimo mês, Nabucodonosor, rei da Babilônia, veio contra Jerusalém, ele e todo o seu exército, e se acamparam contra ela, levantando fortificações ao seu redor. E a cidade permaneceu sitiada até o décimo primeiro ano do rei Zedequias. No …"
Destaque: Nabucodonosor — O templo e a cidade entregues às chamas: a queda completa de Jerusalém.

30. scene_r2c-boss-6.jpg — "Travessia: Queda de Jerusalém" (2 Reis 22:8–13) · Travessia · bloco "Queda de Jerusalém · cap. 22–25"
Momento: Esta travessia revisa o bloco final: o livro achado, a reforma de Josias, a primeira leva e a queda de Jerusalém. A palavra pode renovar; a rebeldia persistente leva ao exílio.
Texto: "Então o sumo sacerdote Hilquias disse ao escrivão Safã: “Achei o Livro da Lei na Casa do SENHOR.” Hilquias entregou o livro a Safã, e este o leu. Então, o escrivão Safã foi ao rei e lhe apresentou o relatório, dizendo: "Teus servos contaram o dinheiro que foi encontrado na Casa e o entregaram nas …"
Destaque: exílio — O fim do bloco: rei, templo e povo saem; a cidade santa cai.

Gere todas as 30 imagens com foco no ícone do STWAY.
```
