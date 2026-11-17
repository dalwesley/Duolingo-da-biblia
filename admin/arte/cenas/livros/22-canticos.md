# Cânticos — 10 cena(s)

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

## Cânticos — 10 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Cânticos — Cânticos capítulo a capítulo: o amor fiel da aliança.

1. scene_cnc-01-como-e-bela-amada.jpg — "Como é bela, amada" (Cantares 1:9–14) · bloco "Desejo e encontro · cap. 1–4"
Momento: No Cântico, o amado e a amada se olham e se nomeiam. A cena abre com elogio, perfume e a casa compartilhada.
Texto: "Comparo-te, ó querida minha, às éguas dos carros de Faraó Formosas são as tuas faces entre os teus enfeites, e o teu pescoço, com os colares. Faremos enfeites de ouro, com incrustações de prata. Enquanto o rei se encontra à sua mesa, o meu nardo exala o seu perfume. O meu amado é para mim um …"
Destaque: formosa — Beleza reconhecida e dita em voz alta: o amor não esconde o elogio.

2. scene_cnc-02-a-voz-do-meu.jpg — "A voz do meu amado" (Cantares 2:7–12) · bloco "Desejo e encontro · cap. 1–4"
Momento: A amada se descreve entre flores e espinhos; o amado a chama quando o inverno passa. O amor tem tempo certo.
Texto: "Eu as conjuro, ó filhas de Jerusalém, pelas gazelas e cervas do campo, que não acordeis nem desperteis o amor até que este queira. A voz do meu amado! Ei-lo aí, galgando os montes, saltando sobre os outeiros. Meu amado é semelhante ao cervo ou ao filho da gazela; eis que está atrás da nossa parede, …"
Destaque: inverno — A estação que já se foi: o chamado do amado chega no tempo certo.

3. scene_cnc-03-o-cortejo-de-salomao.jpg — "O cortejo de Salomão" (Cantares 3:6–11) · bloco "Desejo e encontro · cap. 1–4"
Momento: Uma pergunta sobe do deserto: quem é esta? Em seguida aparece a liteira de Salomão, com valentes, e o dia do desposório em alegria pública.
Texto: "Quem é esta que sobe do deserto, como colunas de fumo, perfumada de mirra, e de incenso, e de toda sorte de pós aromáticos? Eis a liteira de Salomão; ao seu redor estão sessenta valentes, dos valentes de Israel Todos estão armados com suas espadas e são destros na guerra; cada um com a espada à …"
Destaque: desposório — O dia da união celebrada: coroa, testemunhas e alegria do coração.

4. scene_cnc-04-como-es-formosa.jpg — "Como és formosa" (Cantares 4:7–11) · bloco "Desejo e encontro · cap. 1–4"
Momento: O amado descreve a amada detalhe a detalhe e conclui: toda formosa, sem defeito. O amor responde com elogio generoso e convite.
Texto: "Tu és toda formosa, amada minha, e em ti não há defeito. Vem comigo do Líbano, ó minha noiva, vem comigo do Líbano; olha do cume de Amana, do cume de Senir e de Hermom, das moradas dos leões, dos montes dos leopardos. Arrebataste-me o coração, minha irmã, ó noiva; capturaste-me com um único olhar …"
Destaque: formosa — A beleza vista e dita: toda formosa, e em ti não há defeito.

5. scene_cnc-boss-1.jpg — "Travessia: Desejo e encontro" (Cantares 4:7–10) · Travessia · bloco "Desejo e encontro · cap. 1–4"
Momento: Esta Travessia revisa o bloco do desejo e encontro: nomear a beleza, esperar o tempo do amor, celebrar em público e elogiar sem reserva.
Texto: "Tu és toda formosa, amada minha, e em ti não há defeito. Vem comigo do Líbano, ó minha noiva, vem comigo do Líbano; olha do cume de Amana, do cume de Senir e de Hermom, das moradas dos leões, dos montes dos leopardos. Arrebataste-me o coração, minha irmã, ó noiva; capturaste-me com um único olhar …"
Destaque: nomear — O amor fiel vê, nomeia e celebra o outro.

6. scene_cnc-05-abre-me-minha-irma.jpg — "Abre-me, minha irmã" (Cantares 5:2–8) · bloco "Busca e selo · cap. 5–8"
Momento: Ela dorme com o coração vigilante; ele bate e pede: abre-me. Ela hesita, levanta tarde, e ele já se retirou. Sai à procura, ferida, e conjura as filhas de Jerusalém.
Texto: "Estou dormindo, mas meu coração está vigilante; eis a voz do meu amado batendo: “Abre-me, minha irmã, querida minha, pomba minha, imaculada, pois a minha cabeça está cheia de orvalho e os meus cabelos, das gotas da noite.” Despi minhas vestes, como poderei vesti-las outra vez? Já lavei meus pés, …"
Destaque: busca — Quem ama não fica parado: abre, chama e sai à procura.

7. scene_cnc-06-para-onde-foi-o.jpg — "Para onde foi o amado" (Cantares 6:1–9) · bloco "Busca e selo · cap. 5–8"
Momento: As filhas perguntam para onde foi o amado. Ela sabe: desceu ao jardim. Depois ele a nomeia formosa como Tirza e, entre sessenta rainhas, escolhe uma: a pomba imaculada.
Texto: "Para onde foi o teu amado, ó mais formosa entre as mulheres? Que caminho tomou o teu amado? E o buscaremos contigo. Meu amado desceu ao seu jardim, aos canteiros de bálsamo, para pastorear nos jardins e colher os lírios. Eu sou do meu amado, e meu amado é meu; ele pastoreia entre os lírios. Formosa …"
Destaque: uma — Entre muitas, o amor da aliança escolhe uma e a chama perfeita.

8. scene_cnc-07-quao-formosa-e-quao.jpg — "Quão formosa e quão agradável" (Cantares 7:6–13) · bloco "Busca e selo · cap. 5–8"
Momento: O amado celebra a formosura e o desejo. Ela responde com pertença e convite: vem, saiamos ao campo; ali te darei o meu amor. O desejo é mútuo e verbal.
Texto: "Quão formosa e quão aprazível és, ó amor em delícias! A tua estatura é semelhante à palmeira, e os teus seios, a seus cachos. Dizia eu: subirei à palmeira, colherei os seus ramos; e os teus seios serão como os cachos da videira, e o aroma da tua respiração será como o das maçãs. E o teu paladar é …"
Destaque: amor — O desejo dentro da aliança é convite mútuo, não posse brusca.

9. scene_cnc-08-eu-era-muro.jpg — "Eu era muro" (Cantares 8:7–14) · bloco "Busca e selo · cap. 5–8"
Momento: O amor não se apaga com muitas águas. Ela se declara muro digno de confiança, cuida da própria vinha e ainda pede: faz-me ouvir a tua voz; vem depressa.
Texto: "As muitas águas não poderiam apagar esse amor, nem os rios, afogá-lo; ainda que alguém desse todos os bens de sua casa por esse amor, seria de todo desprezado. Temos uma irmã mais nova, que ainda não tem seios; o que faremos por ela no dia em que for pedida? Se ela for um muro, construiremos sobre …"
Destaque: muro — O amor maduro sabe de si, guarda o que é precioso e ainda deseja a presença.

10. scene_cnc-boss-2.jpg — "Travessia: Busca e selo" (Cantares 8:7–14) · Travessia · bloco "Busca e selo · cap. 5–8"
Momento: Esta Travessia revisa o bloco da busca e do selo: atraso e procura, escolha de uma, convite mútuo e amor maduro que ainda diz vem.
Texto: "As muitas águas não poderiam apagar esse amor, nem os rios, afogá-lo; ainda que alguém desse todos os bens de sua casa por esse amor, seria de todo desprezado. Temos uma irmã mais nova, que ainda não tem seios; o que faremos por ela no dia em que for pedida? Se ela for um muro, construiremos sobre …"
Destaque: permanece — O amor da aliança busca, escolhe e permanece.

Gere todas as 10 imagens com foco no ícone do STWAY.
```
