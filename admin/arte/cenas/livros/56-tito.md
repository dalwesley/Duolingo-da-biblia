# Tito — 4 cena(s)

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

## Tito — 4 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Tito — Tito capítulo a capítulo: sã doutrina, boa conduta e a esperança da graça.

1. scene_tic-01-repreender-com-firmeza.jpg — "Repreender com firmeza" (Tito 1:10–13) · bloco "Doutrina que transforma · cap. 1–3"
Momento: Paulo escreve a Tito sobre Creta. Há muitos insubordinados e enganadores; a boca deles precisa ser fechada para a fé ficar sadia.
Texto: "Pois existem muitos insubordinados, faladores fúteis e enganadores, especialmente os da circuncisão. É necessário fazê-los calar, pois estão transtornando casas inteiras, ensinando coisas que não devem, por avareza Um deles, seu próprio profeta, disse: Os cretenses são sempre mentirosos, feras …"
Destaque: repreenda — Corrigir com rigor para que estejam sadios na fé, não para humilhar.

2. scene_tic-02-ensinar-o-que-convem.jpg — "Ensinar o que convém" (Tito 2:1–5) · bloco "Doutrina que transforma · cap. 1–3"
Momento: Paulo detalha o que convém a homens e mulheres, jovens e servos. A sã doutrina molda a conduta para que a palavra de Deus não seja difamada.
Texto: "Você, porém, fale o que é adequado à sã doutrina. Que os homens mais velhos sejam sóbrios, respeitáveis, sensatos, saudáveis na fé, no amor e na constância. As mulheres mais velhas da mesma forma devem ser respeitáveis em seu modo de viver, como convém a santas; não caluniadoras, não escravizadas a …"
Destaque: doutrina — Ensino sadio que se traduz em conduta e embelezamento do evangelho.

3. scene_tic-03-salvos-pela-misericordia.jpg — "Salvos pela misericórdia" (Tito 3:4–7) · bloco "Doutrina que transforma · cap. 1–3"
Momento: Paulo lembra o passado: éramos insensatos. Então apareceu a benignidade de Deus. A salvação vem pela misericórdia, não pelas obras, e leva a boas obras.
Texto: "Mas quando se manifestaram a benignidade e o amor de Deus, nosso Salvador, para com todos os seres humanos, não por meio das obras de justiça que realizamos, mas segundo a sua misericórdia, ele nos salvou pelo lavar regenerador e renovador do Espírito Santo; Ele derramou sobre nós ricamente, por …"
Destaque: misericórdia — O motivo pelo qual Deus salvou: não obras de justiça, mas a sua misericórdia.

4. scene_tic-boss-1.jpg — "Travessia: Doutrina que transforma" (Tito 3:4–7) · Travessia · bloco "Doutrina que transforma · cap. 1–3"
Momento: Este desafio revisa Tito: firmeza contra o engano, conduta que convém e salvação pela misericórdia que gera boas obras.
Texto: "Mas quando se manifestaram a benignidade e o amor de Deus, nosso Salvador, para com todos os seres humanos, não por meio das obras de justiça que realizamos, mas segundo a sua misericórdia, ele nos salvou pelo lavar regenerador e renovador do Espírito Santo; Ele derramou sobre nós ricamente, por …"
Destaque: misericórdia — Deus salva pela misericórdia; a sã doutrina e a conduta nascem dessa graça.

Gere todas as 4 imagens com foco no ícone do STWAY.
```
