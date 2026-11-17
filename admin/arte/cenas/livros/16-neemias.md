# Neemias — 11 cena(s)

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

## Neemias — 11 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Neemias — Neemias capítulo a capítulo: muros, oposição, Lei e um povo que se renova.

1. scene_nec-01-vamos-edificar.jpg — "Vamos edificar" (Neemias 2:11–16) · bloco "O muro sob oposição · cap. 1–6"
Momento: Cena de Vamos edificar: o texto acompanha personagens e decisões diante de Deus.
Texto: "Cheguei a Jerusalém, onde permaneci por três dias. E à noite levantei-me, acompanhado de alguns homens; não revelei a ninguém o que o meu Deus havia colocado em meu coração para fazer em Jerusalém. Não havia comigo nenhum animal, exceto aquele em que eu montava. E, à noite, saí pela porta do Vale, …"
Destaque: Deus — Nome ou título central neste trecho.

2. scene_nec-02-edificam-apesar-do-escarnio.jpg — "Edificam apesar do escárnio" (Neemias 4:1–6) · bloco "O muro sob oposição · cap. 1–6"
Momento: Cena de Edificam apesar do escárnio: o texto acompanha personagens e decisões diante de Deus.
Texto: "E aconteceu que, ao ouvir Sanballate que estávamos edificando o muro, ficou furioso e se indignou bastante; e zombou dos judeus. E falou na presença de seus irmãos e do exército de Samaria, e disse: O que fazem esses fracos judeus? Conseguirão fazer isso? Sacrificarão? Completarão a obra em um só …"
Destaque: Deus — Nome ou título central neste trecho.

3. scene_nec-03-basta-de-usura.jpg — "Basta de usura" (Neemias 5:6–11) · bloco "O muro sob oposição · cap. 1–6"
Momento: Cena de Basta de usura: o texto acompanha personagens e decisões diante de Deus.
Texto: "Ouvindo eu, portanto, o seu clamor e estas palavras, fiquei muito aborrecido. E refleti em meu coração após isso; confrontei os nobres e os magistrados, e lhes disse: "Vocês estão cobrando juros de cada um de seus irmãos." E convoquei contra eles um grande ajuntamento. E lhes disse: Nós resgatamos …"
Destaque: Senhor — Nome ou título central neste trecho.

4. scene_nec-04-intrigas-no-caminho.jpg — "Intrigas no caminho" (Neemias 6:1–6) · bloco "O muro sob oposição · cap. 1–6"
Momento: Cena de Intrigas no caminho: o texto acompanha personagens e decisões diante de Deus.
Texto: "Sucedendo isso, ao ouvirem Sambalate, Tobias, Gesém, o árabe e o restante de nossos inimigos que eu havia edificado o muro e que nele já não havia brecha alguma, embora até aquele momento eu ainda não tivesse colocado as portas nos portais; Sambalate e Gesém enviaram uma mensagem dizendo: "Vem, …"
Destaque: Deus — Nome ou título central neste trecho.

5. scene_nec-boss-1.jpg — "Travessia: O muro sob oposição" (Neemias 2:11–12) · Travessia · bloco "O muro sob oposição · cap. 1–6"
Momento: Cena de Travessia: O muro sob oposição: o texto acompanha personagens e decisões diante de Deus.
Texto: "Cheguei a Jerusalém, onde permaneci por três dias. E à noite levantei-me, acompanhado de alguns homens; não revelei a ninguém o que o meu Deus havia colocado em meu coração para fazer em Jerusalém. Não havia comigo nenhum animal, exceto aquele em que eu montava."
Destaque: Deus — Nome ou título central neste trecho.

6. scene_nec-05-deus-poe-no-coracao.jpg — "Deus põe no coração" (Neemias 7:5–10) · bloco "Lei e renovação · cap. 7–13"
Momento: Cena de Deus põe no coração: o texto acompanha personagens e decisões diante de Deus.
Texto: "Então, meu Deus colocou no meu coração que eu reunisse os nobres, os magistrados e o povo para registrar as genealogias. Encontrei o livro da genealogia dos que subiram primeiro, e nele estava escrito: Estes são os filhos da província que subiram do cativeiro, dentre os exilados que Nabucodonosor, …"
Destaque: Deus — Nome ou título central neste trecho.

7. scene_nec-06-tu-so-es-senhor.jpg — "Tu só és Senhor" (Neemias 9:5–10) · bloco "Lei e renovação · cap. 7–13"
Momento: Cena de Tu só és Senhor: o texto acompanha personagens e decisões diante de Deus.
Texto: "E os levitas, Jesua, Cadmiel, Bani, Hasabneias, Serebias, Hodias, Sebanias e Petaías disseram: "Levantem-se e bendigam ao SENHOR, seu Deus, de eternidade a eternidade; e que o nome da sua glória seja exaltado acima de toda bênção e louvor." Somente Tu és SENHOR; Tu fizeste os céus, os céus dos céus …"
Destaque: SENHOR — Nome ou título central neste trecho.

8. scene_nec-07-pacto-por-escrito.jpg — "Pacto por escrito" (Neemias 10:28–33) · bloco "Lei e renovação · cap. 7–13"
Momento: Cena de Pacto por escrito: o texto acompanha personagens e decisões diante de Deus.
Texto: "E o restante do povo, os sacerdotes, os levitas, os porteiros, os cantores, os netineus, todos os que se separaram dos povos das terras para a Lei de Deus, suas mulheres, seus filhos e suas filhas, todos os que tinham sabedoria e entendimento. Os nobres entre eles se comprometeram firmemente …"
Destaque: Senhor — Nome ou título central neste trecho.

9. scene_nec-08-dedicacao-com-alegria.jpg — "Dedicação com alegria" (Neemias 12:27–32) · bloco "Lei e renovação · cap. 7–13"
Momento: Cena de Dedicação com alegria: o texto acompanha personagens e decisões diante de Deus.
Texto: "E na dedicação dos muros de Jerusalém, buscaram os levitas de todas as suas cidades para que se reunissem a fim de realizar a dedicação com alegria, louvores, cânticos, címbalos, alaúdes e harpas. E assim, os filhos dos cantores se reuniram, tanto da campina ao redor de Jerusalém quanto das aldeias …"
Destaque: Deus — Nome ou título central neste trecho.

10. scene_nec-09-guardar-o-sabado.jpg — "Guardar o sábado" (Neemias 13:15–20) · bloco "Lei e renovação · cap. 7–13"
Momento: Cena de Guardar o sábado: o texto acompanha personagens e decisões diante de Deus.
Texto: "Nos dias em que vi em Judá aqueles que pisavam lagares no sábado e traziam trigo carregado sobre os jumentos, além de vinho, uvas, figos e toda sorte de cargas, que levavam a Jerusalém no dia de sábado; protestei contra eles por venderem mantimentos naquele dia. Também havia tírios morando ali, que …"
Destaque: Deus — Nome ou título central neste trecho.

11. scene_nec-boss-2.jpg — "Travessia: Lei e renovação" (Neemias 7:5–9) · Travessia · bloco "Lei e renovação · cap. 7–13"
Momento: Cena de Travessia: Lei e renovação: o texto acompanha personagens e decisões diante de Deus.
Texto: "Então, meu Deus colocou no meu coração que eu reunisse os nobres, os magistrados e o povo para registrar as genealogias. Encontrei o livro da genealogia dos que subiram primeiro, e nele estava escrito: Estes são os filhos da província que subiram do cativeiro, dentre os exilados que Nabucodonosor, …"
Destaque: SENHOR — Nome ou título central neste trecho.

Gere todas as 11 imagens com foco no ícone do STWAY.
```
