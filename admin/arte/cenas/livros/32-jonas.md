# Jonas — 5 cena(s)

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

## Jonas — 5 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Jonas — Jonas capítulo a capítulo: a misericórdia do Senhor que alcança até Nínive.

1. scene_jnc-01-a-sorte-cai-sobre.jpg — "A sorte cai sobre Jonas" (Jonas 1:11–16) · bloco "Fuga e misericórdia · cap. 1–4"
Momento: Jonas foge do Senhor num navio. A tempestade ameaça a todos, e a sorte aponta o profeta como causa do mal.
Texto: "Disseram-lhe: O que devemos fazer para que o mar se acalme? Pois o mar se tornava cada vez mais tempestuoso. Tomai-me e lançai-me ao mar, e o mar se acalmará para vós, pois eu sei que esta grande tempestade vos atingiu por minha causa. Os homens, porém, remavam, esforçando-se para levar o navio de …"
Destaque: temor — Os marinheiros passam do medo da tempestade ao temor do Senhor.

2. scene_jnc-02-oracao-no-peixe.jpg — "Oração no peixe" (Jonas 2:1–6) · bloco "Fuga e misericórdia · cap. 1–4"
Momento: Jonas foi lançado ao mar e engolido. Do ventre do peixe, ele ora e lembra o templo santo.
Texto: "Jonas orou ao SENHOR, seu Deus, do ventre do peixe. E disse: Na minha angústia, clamei ao Senhor, e ele me respondeu; do ventre do abismo, gritei, e tu ouviste a minha voz. Tu me lançaste no profundo, no coração dos mares, e a corrente das águas me cercou; todas as tuas ondas e as tuas vagas …"
Destaque: salvação — Jonas confessa: a salvação pertence ao Senhor.

3. scene_jnc-03-ninive-se-arrepende.jpg — "Nínive se arrepende" (Jonas 3:5–10) · bloco "Fuga e misericórdia · cap. 1–4"
Momento: Pela segunda vez, o Senhor manda Jonas a Nínive. Desta vez ele vai e prega; a cidade inteira se volta.
Texto: "Os habitantes de Nínive creram em Deus, proclamaram um jejum e se vestiram de panos de saco, desde o maior até o menor. A notícia chegou ao rei de Nínive, e ele se levantou do seu trono, retirou as vestes reais, cobriu-se com pano de saco e sentou-se sobre cinzas. E fez-se proclamar em Nínive, por …"
Destaque: arrependeu — Deus se arrepende do mal anunciado quando o povo se converte.

4. scene_jnc-04-a-planta-e-a.jpg — "A planta e a cidade" (Jonas 4:6–11) · bloco "Fuga e misericórdia · cap. 1–4"
Momento: Nínive foi poupada, e Jonas se ira. O Senhor usa uma planta, um verme e o sol para ensinar compaixão.
Texto: "E o Senhor Deus fez surgir uma planta, que subiu sobre a cabeça de Jonas, para lhe dar sombra e aliviar seu desconforto; e Jonas se alegrou imensamente por causa da planta. Então Deus, no dia seguinte, enviou um verme, que feriu a planta, fazendo-a secar. E aconteceu que, ao nascer o sol, Deus fez …"
Destaque: compaixão — O Senhor pergunta se não deveria ter compaixão de Nínive.

5. scene_jnc-boss-1.jpg — "Travessia: Fuga e misericórdia" (Jonas 1:9–14) · Travessia · bloco "Fuga e misericórdia · cap. 1–4"
Momento: Nesta travessia, revise a fuga no mar, a oração no peixe, o arrependimento de Nínive e a planta que ensina misericórdia a Jonas.
Texto: "Sou hebreu e temo o Senhor, o Deus do céu, que fez o mar e a terra. Então, os homens ficaram possuídos de grande temor e lhe disseram: Que é isto que fizeste? Pois sabiam os homens que ele fugia da presença do Senhor, porque lho havia declarado. Disseram-lhe: O que devemos fazer para que o mar se …"
Destaque: misericórdia — O Senhor se arrepende do mal e ensina Jonas a ter compaixão.

Gere todas as 5 imagens com foco no ícone do STWAY.
```
