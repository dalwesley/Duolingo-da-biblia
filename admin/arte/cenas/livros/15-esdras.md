# Esdras — 11 cena(s)

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

## Esdras — 11 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Esdras — Esdras capítulo a capítulo: a volta do exílio, a casa de Deus e a reforma do povo.

1. scene_esc-01-o-povo-que-voltou.jpg — "O povo que voltou" (Esdras 2:64–69) · bloco "Volta e oposição · cap. 1–6"
Momento: Cena de O povo que voltou: o texto acompanha personagens e decisões diante de Deus.
Texto: "Toda esta congregação reunida era de quarenta e dois mil trezentos e sessenta. Além dos seus servos e servas, que eram sete mil trezentos e trinta e sete; contavam-se também duzentos e quarenta e cinco cantores e cantoras. Seus cavalos eram setecentos e trinta e seis; seus mulos, duzentos e …"
Destaque: Senhor — Nome ou título central neste trecho.

2. scene_esc-02-altar-e-alicerces.jpg — "Altar e alicerces" (Esdras 3:1–6) · bloco "Volta e oposição · cap. 1–6"
Momento: Cena de Altar e alicerces: o texto acompanha personagens e decisões diante de Deus.
Texto: "E aconteceu que, quando chegou o sétimo mês, e os filhos de Israel já estavam nas suas cidades, o povo se reuniu como um só homem em Jerusalém. E Jesua, filho de Jozadaque, e seus irmãos, os sacerdotes, e Zorobabel, filho de Sealtiel, e seus irmãos, ergueram o altar do Deus de Israel, para que …"
Destaque: Senhor — Nome ou título central neste trecho.

3. scene_esc-03-o-povo-da-terra.jpg — "O povo da terra" (Esdras 4:4–9) · bloco "Volta e oposição · cap. 1–6"
Momento: Cena de O povo da terra: o texto acompanha personagens e decisões diante de Deus.
Texto: "Então, o povo da terra desanimou os judeus inquietando-os na construção. E alugaram conselheiros contra eles, para frustrarem o seu plano, todos os dias de Ciro, rei da Pérsia, até o reinado de Dario, rei da Pérsia. E, no princípio do reinado de Assuero, apresentaram uma acusação contra os …"
Destaque: Então — Termo que carrega o sentido desta cena.

4. scene_esc-04-profetas-animam.jpg — "Profetas animam" (Esdras 5:1–6) · bloco "Volta e oposição · cap. 1–6"
Momento: Cena de Profetas animam: o texto acompanha personagens e decisões diante de Deus.
Texto: "E Ageu e Zacarias, filho de Ido, profetas, profetizaram aos judeus que estavam em Judá e em Jerusalém, em nome do Deus de Israel, cujo Espírito estava com eles. Então, se levantaram Zorobabel, filho de Sealtiel, e Jesua, filho de Jozadaque, e começaram a edificar a Casa de Deus, a qual está em …"
Destaque: Deus — Nome ou título central neste trecho.

5. scene_esc-05-casa-dedicada.jpg — "Casa dedicada" (Esdras 6:13–18) · bloco "Volta e oposição · cap. 1–6"
Momento: Cena de Casa dedicada: o texto acompanha personagens e decisões diante de Deus.
Texto: "Então, Tatenai, o governador daquela região além do Eufrates, Setar-Bozenai e seus companheiros realizaram isso de forma pontual conforme a ordem do rei Dario. E os anciãos dos judeus continuavam a edificar e prosperar em decorrência do que haviam profetizado Ageu e Zacarias, filho de Iddo. …"
Destaque: Senhor — Nome ou título central neste trecho.

6. scene_esc-boss-1.jpg — "Travessia: Volta e oposição" (Esdras 2:64–67) · Travessia · bloco "Volta e oposição · cap. 1–6"
Momento: Cena de Travessia: Volta e oposição: o texto acompanha personagens e decisões diante de Deus.
Texto: "Toda esta congregação reunida era de quarenta e dois mil trezentos e sessenta. Além dos seus servos e servas, que eram sete mil trezentos e trinta e sete; contavam-se também duzentos e quarenta e cinco cantores e cantoras. Seus cavalos eram setecentos e trinta e seis; seus mulos, duzentos e …"
Destaque: Senhor — Nome ou título central neste trecho.

7. scene_esc-06-mao-do-rei-e.jpg — "Mão do rei e de Deus" (Esdras 7:16–21) · bloco "Esdras e a reforma · cap. 7–10"
Momento: Cena de Mão do rei e de Deus: o texto acompanha personagens e decisões diante de Deus.
Texto: "E toda a prata e o ouro que você encontrar em toda a província da Babilônia, juntamente com as ofertas voluntárias do povo e dos sacerdotes, que forem oferecidas espontaneamente, para a casa do seu Deus, que se encontra em Jerusalém. Portanto, com este dinheiro, você diligentemente comprará …"
Destaque: Deus — Nome ou título central neste trecho.

8. scene_esc-07-jejum-no-caminho.jpg — "Jejum no caminho" (Esdras 8:21–26) · bloco "Esdras e a reforma · cap. 7–10"
Momento: Cena de Jejum no caminho: o texto acompanha personagens e decisões diante de Deus.
Texto: "Então, declarei ali um jejum junto ao rio Ahava para nos humilharmos diante do nosso Deus, a fim de lhe pedirmos uma jornada favorável para nós, para nossos filhos e para todos os nossos bens. Porque me envergonhei de pedir ao rei soldados e cavaleiros para nos defenderem do inimigo no caminho, …"
Destaque: SENHOR — Nome ou título central neste trecho.

9. scene_esc-08-oracao-de-vergonha.jpg — "Oração de vergonha" (Esdras 9:5–10) · bloco "Esdras e a reforma · cap. 7–10"
Momento: Cena de Oração de vergonha: o texto acompanha personagens e decisões diante de Deus.
Texto: "E, ao cair da tarde, levantei-me da minha humilhação após ter rasgado minhas vestes e meu manto e coloquei-me de joelhos estendendo minhas mãos ao SENHOR meu Deus. E disse: Meu Deus! Estou envergonhado e confuso por levantar a Ti a face, pois as nossas iniquidades se multiplicaram sobre a nossa …"
Destaque: Senhor — Nome ou título central neste trecho.

10. scene_esc-09-pacto-de-reforma.jpg — "Pacto de reforma" (Esdras 10:1–6) · bloco "Esdras e a reforma · cap. 7–10"
Momento: Cena de Pacto de reforma: o texto acompanha personagens e decisões diante de Deus.
Texto: "Enquanto Esdras orava e fazia confissão, chorando e prostrando-se diante da Casa de Deus, ajuntou-se a ele uma grande congregação de homens, mulheres e crianças; pois o povo chorava com grande choro. Então, Secanias, filho de Jeiel, um dos filhos de Elão, tomou a palavra e disse a Esdras: Temos …"
Destaque: Senhor — Nome ou título central neste trecho.

11. scene_esc-boss-2.jpg — "Travessia: Esdras e a reforma" (Esdras 7:16–17) · Travessia · bloco "Esdras e a reforma · cap. 7–10"
Momento: Cena de Travessia: Esdras e a reforma: o texto acompanha personagens e decisões diante de Deus.
Texto: "E toda a prata e o ouro que você encontrar em toda a província da Babilônia, juntamente com as ofertas voluntárias do povo e dos sacerdotes, que forem oferecidas espontaneamente, para a casa do seu Deus, que se encontra em Jerusalém. Portanto, com este dinheiro, você diligentemente comprará …"
Destaque: SENHOR — Nome ou título central neste trecho.

Gere todas as 11 imagens com foco no ícone do STWAY.
```
