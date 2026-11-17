# Joel — 4 cena(s)

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

## Joel — 4 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Joel — Joel capítulo a capítulo: o dia do Senhor, o arrependimento e a restauração.

1. scene_jlc-01-lamento-no-templo.jpg — "Lamento no templo" (Joel 1:13–18) · bloco "O dia do Senhor · cap. 1–3"
Momento: Uma praga e a seca deixam Judá sem oferta, sem pasto e sem alegria. Joel chama sacerdotes e povo a jejum e clamor na Casa do Senhor.
Texto: "Cingi-vos de pano de saco e lamentai, sacerdotes; uivai, ministros do altar; vinde e passai a noite vestidos de pano de saco, ministros do meu Deus; pois da casa de vosso Deus foram cortadas a oferta de manjares e a libação. Santificai um jejum, proclamai um dia sagrado, convocai os anciãos e todos …"
Destaque: jejum — Tempo santificado de clamor ao Senhor diante da calamidade.

2. scene_jlc-02-trombeta-em-siao.jpg — "Trombeta em Sião" (Joel 2:1–6) · bloco "O dia do Senhor · cap. 1–3"
Momento: Joel anuncia o dia do Senhor com trombeta em Sião. Um povo grande e poderoso avança como fogo; a terra treme diante dele.
Texto: "Toca a trombeta em Sião e clama em alta voz no meu monte santo; que tremam todos os habitantes da terra, pois o Dia do Senhor vem, já está próximo; Dia de escuridão e densas trevas, dia de nuvens e negridão! Como a alva que se espalha sobre os montes, assim se propaga um povo grande e poderoso, …"
Destaque: trombeta — O sinal que desperta Sião: o Dia do Senhor vem e já está próximo.

3. scene_jlc-03-no-vale-da-decisao.jpg — "No vale da decisão" (Joel 3:14–19) · bloco "O dia do Senhor · cap. 1–3"
Momento: Multidões se reúnem no vale da Decisão. O Senhor ruge de Sião, mas é refúgio do seu povo e promete restaurar Judá.
Texto: "Multidões, multidões no vale da Decisão! Porque o Dia do Senhor se aproxima, neste vale da Decisão. O sol e a lua se escurecerão e as estrelas deixarão de brilhar E o Senhor bramará de Sião, e fará ouvir a sua voz de Jerusalém; e os céus e a terra tremerão; mas o Senhor será o refúgio do seu povo, …"
Destaque: refúgio — O Senhor como abrigo do seu povo enquanto céus e terra tremem.

4. scene_jlc-boss-1.jpg — "Travessia: O dia do Senhor" (Joel 1:13–18) · Travessia · bloco "O dia do Senhor · cap. 1–3"
Momento: Nesta travessia, revise o lamento e o jejum de Joel 1, a trombeta e o Dia terrível de Joel 2, e o refúgio no vale da Decisão em Joel 3.
Texto: "Cingi-vos de pano de saco e lamentai, sacerdotes; uivai, ministros do altar; vinde e passai a noite vestidos de pano de saco, ministros do meu Deus; pois da casa de vosso Deus foram cortadas a oferta de manjares e a libação. Santificai um jejum, proclamai um dia sagrado, convocai os anciãos e todos …"
Destaque: Dia do Senhor — O dia próximo que chama ao arrependimento e oferece refúgio ao povo.

Gere todas as 4 imagens com foco no ícone do STWAY.
```
