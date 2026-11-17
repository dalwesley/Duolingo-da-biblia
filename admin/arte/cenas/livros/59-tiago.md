# Tiago — 6 cena(s)

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

## Tiago — 6 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Tiago — Tiago capítulo a capítulo: fé que se vê na prova, na fala e nas obras.

1. scene_tjc-01-alegria-na-prova.jpg — "Alegria na prova" (Tiago 1:2–5) · bloco "Fé que se vê · cap. 1–5"
Momento: Tiago escreve a irmãos que passam por diversas provações. Antes de falar de obras, ele ensina a olhar a prova de outro modo e a pedir a Deus a sabedoria que falta.
Texto: "Meus irmãos, considerem como um motivo de grande alegria o passarem por diversas provações. Sabendo que a provação da sua fé, uma vez confirmada, gera perseverança. Tenha, pois, a perseverança a sua obra completa, para que sejais perfeitos e íntegros, em nada deficientes. E, se algum de vocês …"
Destaque: perseverança — Firmeza que permanece debaixo da prova e faz a fé amadurecer.

2. scene_tjc-02-sem-acepcao.jpg — "Sem acepção" (Tiago 2:1–6) · bloco "Fé que se vê · cap. 1–5"
Momento: A igreja se reúne e entram um homem rico e um pobre. Tiago mostra como o tratamento dado a cada um revela se a fé em Cristo está sendo vivida ou apenas declarada.
Texto: "Meus irmãos, não tenhais a fé em nosso Senhor Jesus Cristo, Senhor da glória, sem fazer acepção de pessoas. Porque, se em vosso encontro entrar algum homem com anéis de ouro e vestes luxuosas, e também entrar um pobre com roupas esfarrapadas, E prestardes atenção àquele que veste roupas luxuosas e …"
Destaque: acepção de pessoas — Tratar alguém melhor ou pior por posição, riqueza ou aparência.

3. scene_tjc-03-sabedoria-do-alto.jpg — "Sabedoria do alto" (Tiago 3:13–18) · bloco "Fé que se vê · cap. 1–5"
Momento: Tiago pergunta quem é sábio entre os irmãos e mostra que a sabedoria se prova pela vida, e não pelo discurso. Ele coloca lado a lado duas formas de sabedoria e os frutos de cada uma.
Texto: "Quem entre vocês é sábio e entendido? Mostre por meio de suas boas ações, a mansidão que é fruto da sabedoria. Mas, se vocês têm inveja amarga e contendas no coração, não se gloriem disso, nem mintam contra a verdade. Essa sabedoria não vem do alto; antes, é terrena, animal e demoníaca. Pois, onde …"
Destaque: sabedoria do alto — A sabedoria que vem de Deus e se reconhece pelo caráter e pelos frutos.

4. scene_tjc-04-aproximem-se-de-deus.jpg — "Aproximem-se de Deus" (Tiago 4:7–12) · bloco "Fé que se vê · cap. 1–5"
Momento: Tiago chama os irmãos a se voltarem para Deus, com sujeição, arrependimento e humildade. Depois, mostra como essa postura muda o modo de tratar o irmão, sem falar mal nem julgar.
Texto: "Sujeitem-se, portanto, a Deus; mas resistam ao diabo, e ele fugirá de vós. Aproximem-se de Deus, e Ele se aproximará de vocês. Purifiquem as mãos, pecadores; e, vocês que são de ânimo dobre, limpem os corações. Afligi-vos, lamentai e chorai; converta-se o vosso riso em pranto e a vossa alegria em …"
Destaque: Aproximem-se de Deus — Voltar-se para Deus com sujeição e coração limpo; ele responde se aproximando.

5. scene_tjc-05-paciencia-ate-a-vinda.jpg — "Paciência até a vinda" (Tiago 5:7–12) · bloco "Fé que se vê · cap. 1–5"
Momento: Tiago escreve a irmãos que sofrem e esperam. Ele os chama à paciência, aponta o exemplo dos profetas e de Jó e termina pedindo uma palavra simples e sincera.
Texto: "Portanto, irmãos, sejam pacientes até a vinda do Senhor. Observem que o lavrador aguarda com paciência o precioso fruto da terra, esperando receber as primeiras e as últimas chuvas. Sejam também pacientes e fortaleçam os corações, pois a vinda do Senhor está próxima. Irmãos, não se queixem uns dos …"
Destaque: paciência — Esperar com firmeza, sem se queixar, confiando que o Senhor virá.

6. scene_tjc-boss-1.jpg — "Travessia: Fé que se vê" (Tiago 1:2–5) · Travessia · bloco "Fé que se vê · cap. 1–5"
Momento: Esta Travessia revisa Tiago 1–5: alegria na prova, fé sem acepção, sabedoria do alto, humildade perante Deus e paciência até a vinda do Senhor.
Texto: "Meus irmãos, considerem como um motivo de grande alegria o passarem por diversas provações. Sabendo que a provação da sua fé, uma vez confirmada, gera perseverança. Tenha, pois, a perseverança a sua obra completa, para que sejais perfeitos e íntegros, em nada deficientes. E, se algum de vocês …"
Destaque: fé — Confiança que se vê no caráter, nas relações e na espera paciente.

Gere todas as 6 imagens com foco no ícone do STWAY.
```
