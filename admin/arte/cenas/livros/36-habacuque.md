# Habacuque — 4 cena(s)

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

## Habacuque — 4 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Habacuque — Habacuque capítulo a capítulo: da dúvida à confiança no Senhor.

1. scene_hqc-01-olhai-entre-as-nacoes.jpg — "Olhai entre as nações" (Habacuque 1:5–10) · bloco "Da queixa à confiança · cap. 1–3"
Momento: Habacuque vê violência em Judá e pergunta a Deus. A resposta espanta: o Senhor suscita os caldeus, nação amarga, para disciplina.
Texto: "Vejam entre as nações, olhem, maravilhem-se e fiquem perplexos, pois estou realizando em seus dias uma obra tão grandiosa que vocês não crerão mesmo que alguém a declare Pois eis que suscito os caldeus, uma nação amarga e impetuosa, que avança pela extensão da terra para apoderar-se de moradas que …"
Destaque: caldeus — A nação amarga e impetuosa que Deus suscita para juízo e disciplina.

2. scene_hqc-02-ai-dos-opressores.jpg — "Ai dos opressores" (Habacuque 2:9–14) · bloco "Da queixa à confiança · cap. 1–3"
Momento: Depois de anunciar o juízo pelos caldeus, o Senhor pronuncia ais contra ganância, violência e ídolos mudos. O contraste final: o Senhor no templo, e a terra em silêncio.
Texto: "Ai daquele que acumula bens mal adquiridos em sua casa, para erguer nas alturas seu abrigo, a fim de livrar-se das garras do mal! Desonra maquinaste para a tua casa; ao destruir muitos povos, pecaste contra a tua alma. Porque a pedra da parede clamará, e a trave do madeiramento lhe responderá. Ai …"
Destaque: templo — O lugar santo onde o Senhor está; diante dele toda a terra deve calar-se.

3. scene_hqc-03-ainda-assim-me-alegrarei.jpg — "Ainda assim me alegrarei" (Habacuque 3:14–19) · bloco "Da queixa à confiança · cap. 1–3"
Momento: Habacuque viu o juízo e tremeu. Ainda assim, no meio da falta — figueira, videira, rebanho —, escolhe alegrar-se no Senhor, sua fortaleza.
Texto: "Tu traspassaste com os teus cajados a cabeça dos guerreiros do inimigo; eles avançam tempestuosos para me destruir; regozijam-se, como se estivessem prontos para devorar o pobre às ocultas. Marchas com os teus cavalos pelo mar, pela massa de grandes águas. Ouvindo isso, meu íntimo se agitou; meus …"
Destaque: Contudo — A virada da fé: mesmo sem fruto e rebanho, o profeta se alegra no Senhor.

4. scene_hqc-boss-1.jpg — "Travessia: Da queixa à confiança" (Habacuque 3:17–19) · Travessia · bloco "Da queixa à confiança · cap. 1–3"
Momento: Nesta travessia, revise a obra espantosa com os caldeus, o silêncio diante do templo e a fé que se alegra mesmo sem figueira nem rebanho.
Texto: "Embora a figueira não floresça, nem haja fruto na videira, ainda que o produto da oliveira falhe e os campos não produzam mantimento; as ovelhas da malhada sejam arrebatadas, e não haja gado nos currais: Contudo, eu me alegro no Senhor; exulto no Deus da minha salvação. O Senhor Deus é a minha …"
Destaque: Contudo — A virada da fé: alegria no Senhor apesar da falta.

Gere todas as 4 imagens com foco no ícone do STWAY.
```
