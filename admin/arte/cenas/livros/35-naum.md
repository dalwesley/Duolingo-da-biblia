# Naum — 4 cena(s)

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

## Naum — 4 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Naum — Naum capítulo a capítulo: o juízo do Senhor sobre Nínive.

1. scene_nac-01-o-senhor-e-bom.jpg — "O Senhor é bom" (Naum 1:2–7) · bloco "Queda de Nínive · cap. 1–3"
Momento: Naum anuncia a sentença sobre Nínive. O mesmo Senhor que se ira contra o culpado é bom e fortaleza para quem nele se refugia.
Texto: "O Senhor é Deus zeloso e vingador; o Senhor é vingador e cheio de furor; o Senhor toma vingança contra seus adversários e reserva indignação para seus inimigos. O Senhor é lento para se irar, mas grande em poder e jamais considera inocente o culpado. O Senhor tem o seu caminho na tempestade e na …"
Destaque: fortaleza — O Senhor como abrigo seguro no dia da angústia.

2. scene_nac-02-o-saque-de-ninive.jpg — "O saque de Nínive" (Naum 2:5–10) · bloco "Queda de Nínive · cap. 1–3"
Momento: Nínive, potência que saqueava outras, é cercada. Carros, escudos e pânico enchem as ruas; o juízo anunciado se concretiza na cidade.
Texto: "Ele se lembrará de seus valentes, mas eles tropeçarão em seu caminho; apressar-se-ão até seu muro, mas encontrarão o inimigo preparado. As comportas do rio se abrirão, e o palácio será arrasado. Pois está decretado: a cidade-rainha será despida e levada em cativeiro; suas servas gemem como pombas e …"
Destaque: saqueiem — Ordem que inverte o destino de Nínive: a saqueadora é saqueada.

3. scene_nac-03-eis-me-contra-ti.jpg — "Eis-me contra ti" (Naum 3:5–10) · bloco "Queda de Nínive · cap. 1–3"
Momento: O Senhor se declara contra Nínive por causa da violência e da humilhação que ela impôs. Até No-Amon, cidade forte, caiu; Nínive não será exceção.
Texto: "Eis que estou contra você, diz o SENHOR dos Exércitos; levantarei as abas de suas vestes sobre seu rosto e mostrarei às nações a sua nudez e aos reinos a sua humilhação. Lançarei sobre você imundícias, te tratarei com desprezo e te porei como um espetáculo. E será que todos os que te virem fugirão …"
Destaque: humilhação — Exposição pública da vergonha de quem oprimiu as nações.

4. scene_nac-boss-1.jpg — "Travessia: Queda de Nínive" (Naum 1:2–7) · Travessia · bloco "Queda de Nínive · cap. 1–3"
Momento: Nesta travessia, revise o Senhor bom e fortaleza, o esvaziamento de Nínive e a vergonha pública de quem oprime as nações.
Texto: "O Senhor é Deus zeloso e vingador; o Senhor é vingador e cheio de furor; o Senhor toma vingança contra seus adversários e reserva indignação para seus inimigos. O Senhor é lento para se irar, mas grande em poder e jamais considera inocente o culpado. O Senhor tem o seu caminho na tempestade e na …"
Destaque: fortaleza — O Senhor como abrigo dos seus e juiz da violência de Nínive.

Gere todas as 4 imagens com foco no ícone do STWAY.
```
