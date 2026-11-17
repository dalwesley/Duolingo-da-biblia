# Lamentações — 6 cena(s)

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

## Lamentações — 6 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Lamentações — Lamentações capítulo a capítulo: o choro sobre Jerusalém e a esperança no Senhor.

1. scene_lmc-01-olhai-e-vede.jpg — "Olhai e vede" (Lamentações 1:13–18) · bloco "A cidade caída · cap. 1–5"
Momento: Jerusalém caíra. A cidade personificada chama quem passa a olhar sua dor e confessa a justiça do Senhor.
Texto: "Do alto, enviou fogo aos meus ossos, que se apoderou de mim; estendeu uma rede aos meus pés, arrojou-me para trás, causando-me desolação e enfermidade durante todo o dia. O jugo das minhas transgressões está atado pela Sua mão; elas estão entrelaçadas, subiram sobre o meu pescoço, e Ele abateu a …"
Destaque: justo — A cidade admite: o Senhor é justo, porque ela se rebelou contra a sua palavra.

2. scene_lmc-02-a-ira-do-senhor.jpg — "A ira do Senhor" (Lamentações 2:1–6) · bloco "A cidade caída · cap. 1–5"
Momento: O segundo canto mostra a ira do Senhor sobre Sião: moradas, altar, santuário e muros caem.
Texto: "Como o Senhor cobriu de nuvens, na sua ira, a filha de Sião! Precipitou do céu à terra a glória de Israel e não se lembrou do estrado de seus pés no dia da sua ira. O Senhor destruiu todas as moradas de Jacó e não se apiedou; derrubou, na sua ira, as fortalezas da filha de Judá e as lançou por …"
Destaque: ira — A indignação santa do Senhor que cobre Sião e derruba o que parecia seguro.

3. scene_lmc-03-nao-rejeita-para-sempre.jpg — "Não rejeita para sempre" (Lamentações 3:31–36) · bloco "A cidade caída · cap. 1–5"
Momento: No centro do livro, o lamento abre espaço à esperança: o Senhor não rejeita para sempre e se compadece.
Texto: "Pois o Senhor não rejeitará para sempre. Antes, se ele entristecer a alguém, usará de compaixão, conforme a grandeza das suas misericórdias. Porque Ele não aflige nem entristece os filhos dos homens de bom grado. Para calcar aos pés todos os presos da terra. Para perverter o direito do homem …"
Destaque: misericórdias — A grandeza do cuidado do Senhor que acompanha até a disciplina.

4. scene_lmc-04-ouro-escurecido.jpg — "Ouro escurecido" (Lamentações 4:1–6) · bloco "A cidade caída · cap. 1–5"
Momento: O ouro perde o brilho: os filhos de Sião, antes preciosos, viram objetos de barro na fome e na ira.
Texto: "Como se escureceu o ouro! Como se alterou o ouro refinado! Como estão espalhadas as pedras do santuário pelas esquinas de todas as ruas! Os nobres filhos de Sião, comparáveis a ouro puro, agora são tidos como objetos de barro, obra das mãos do oleiro! Até os chacais dão o peito e amamentam seus …"
Destaque: ouro — Imagem da glória perdida: o que era precioso escureceu na ruína.

5. scene_lmc-05-lembra-te-senhor.jpg — "Lembra-te, Senhor" (Lamentações 5:1–6) · bloco "A cidade caída · cap. 1–5"
Momento: O povo clama: Lembra-te, Senhor. Herança, casas, água e descanso foram perdidos na ruína.
Texto: "Lembra-te, Senhor, do que nos tem sucedido; considera e olha para a nossa desonra. A nossa herança foi entregue a estranhos, e as nossas casas, a estrangeiros. Órfãos somos, já não temos pai; nossas mães são como viúvas. A nossa água bebemos por preço e a nossa lenha vem a custo. Sofremos …"
Destaque: Lembra-te — O apelo do povo ferido: pedir que o Senhor considere a desonra.

6. scene_lmc-boss-1.jpg — "Travessia: A cidade caída" (Lamentações 1:12–17) · Travessia · bloco "A cidade caída · cap. 1–5"
Momento: Nesta travessia, revise a confissão de Jerusalém, a ira sobre o santuário, a misericórdia, o ouro escurecido e o clamor.
Texto: "Não vos comove isto, a todos vós que passais pelo caminho? Considerai e vede se há dor igual à minha, que me sobreveio, com a qual o Senhor me afligiu no dia do furor da sua ira. Do alto, enviou fogo aos meus ossos, que se apoderou de mim; estendeu uma rede aos meus pés, arrojou-me para trás, …"
Destaque: confissão — Admitir a justiça do Senhor e voltar a ele mesmo na ruína.

Gere todas as 6 imagens com foco no ícone do STWAY.
```
