# Eclesiastes — 14 cena(s)

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

## Eclesiastes — 14 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Eclesiastes — Eclesiastes capítulo a capítulo: vaidade sob o sol e o temor de Deus.

1. scene_ecc-01-geracoes-que-passam.jpg — "Gerações que passam" (Eclesiastes 1:5–10) · bloco "Sob o sol · cap. 1–6"
Momento: O Pregador, rei em Jerusalém, observa o mundo debaixo do sol: sol, vento e rios repetem o mesmo ciclo, e as gerações esquecem o que veio antes.
Texto: "O sol se levanta, e se põe, e retorna ao lugar de onde nasce de novo. O vento vai para o sul e faz seu giro para o norte; gira e revolve-se em sua trajetória, retornando aos seus circuitos. Todos os rios correm para o mar, mas o mar não se enche; ao lugar para onde correm os rios, ali sempre …"
Destaque: debaixo do sol — O horizonte do Pregador: a vida vista só a partir do chão, sem a chave do eternidade.

2. scene_ecc-02-trabalho-e-herdeiro.jpg — "Trabalho e herdeiro" (Eclesiastes 2:18–23) · bloco "Sob o sol · cap. 1–6"
Momento: O Pregador olha o fruto do seu esforço e vê que outro o herdará — sábio ou insensato. Depois descobre o simples prazer como dom de Deus.
Texto: "Também aborreci todo o meu trabalho, com o qual me afadiguei debaixo do sol, pois teria que deixá-lo àquele que viria depois de mim. Porque quem pode saber se será sábio ou insensato? No entanto, ele dominará todo o fruto do meu esforço, que realizei com sabedoria debaixo do sol; também isto é …"
Destaque: mão de Deus — A origem do prazer simples no trabalho: não é conquista solitária, vem de Deus.

3. scene_ecc-03-tempo-para-tudo.jpg — "Tempo para tudo" (Eclesiastes 3:1–6) · bloco "Sob o sol · cap. 1–6"
Momento: O Pregador acabou de ver que o esforço sob o sol não se sustenta nas mãos. Agora ele olha para o ritmo da vida: pares de tempos opostos que não dependem do nosso relógio.
Texto: "Para tudo há um tempo designado, e para cada propósito debaixo do céu há um momento apropriado. Há tempo de nascer e tempo de morrer; tempo de plantar e tempo de arrancar o que se plantou. Tempo de matar e tempo de curar; tempo de derrubar e tempo de edificar; Tempo de chorar e tempo de rir; tempo …"
Destaque: Tempo — Cada coisa debaixo do céu tem sua hora, e reconhecê-la é parte da sabedoria.

4. scene_ecc-04-melhor-serem-dois.jpg — "Melhor serem dois" (Eclesiastes 4:7–12) · bloco "Sob o sol · cap. 1–6"
Momento: O Pregador vê o solitário que trabalha sem fim e sem perguntar para quem. Em seguida elogia os dois que se ajudam e o cordão de três dobras.
Texto: "Mais uma vez, considerei que tudo era vaidade debaixo do sol. Há um homem que é solitário e não tem ninguém, nem filho nem irmã; e de todo o seu trabalho não há fim, nem seus olhos se fartam de riquezas; e não diz: "Para quem trabalho eu, e privo minha alma do bem?" Também isso é vaidade e um …"
Destaque: dois — Companhia que sustenta: melhor recompensa, levantamento mútuo e calor compartilhado.

5. scene_ecc-05-chega-te-para-ouvir.jpg — "Chega-te para ouvir" (Eclesiastes 5:1–7) · bloco "Sob o sol · cap. 1–6"
Momento: O Pregador ensina a entrar na casa de Deus com pé guardado: ouvir antes de falar, cumprir o voto e temer a Deus.
Texto: "Guarde o pé ao entrar na casa de Deus; é melhor inclinar-se para ouvir do que oferecer sacrifícios de tolos, pois não sabem que estão fazendo o mal. Não te apresses a falar, nem deixes que o teu coração se precipite em pronunciar qualquer palavra diante de Deus; porque Deus está nos céus, e tu, na …"
Destaque: teme a Deus — A conclusão prática diante de muitas palavras: reverência que escuta e cumpre.

6. scene_ecc-06-riqueza-sem-proveito.jpg — "Riqueza sem proveito" (Eclesiastes 6:1–6) · bloco "Sob o sol · cap. 1–6"
Momento: O Pregador vê um mal debaixo do sol: riquezas sem poder de usufruir, desejo que não se farta e a vantagem do que os olhos veem.
Texto: "Há um mal que observei debaixo do sol e que pesa sobre os homens: Um homem a quem Deus deu riquezas, bens e honra, e que nada lhe falta do que sua alma deseja; porém, Deus não lhe concede o poder para usufruir disso, sendo um estranho quem o consome. Isso também é vaidade e uma grave aflição. …"
Destaque: usufruir — O poder de saborear o que se tem — sem isso, a riqueza vira aflição.

7. scene_ecc-boss-1.jpg — "Travessia: Sob o sol" (Eclesiastes 1:7–9) · Travessia · bloco "Sob o sol · cap. 1–6"
Momento: Esta Travessia revisa o bloco sob o sol: ciclos cansativos, trabalho que outro herda, tempo designado, companhia, escuta na casa de Deus e riqueza sem usufruto.
Texto: "Todos os rios correm para o mar, mas o mar não se enche; ao lugar para onde correm os rios, ali sempre retornam. Todas essas coisas são tão cansativas que ninguém pode expressar; os olhos nunca se fartam de ver, nem os ouvidos se satisfazem de ouvir. O que foi, isso é o que há de ser; e o que se …"
Destaque: debaixo do sol — O horizonte do cansaço: e ainda assim há dons como tempo, companhia e escuta.

8. scene_ecc-07-dia-da-morte-e.jpg — "Dia da morte e da prosperidade" (Eclesiastes 7:1–4) · bloco "Sabedoria e fim · cap. 7–12"
Momento: O Pregador elogia a casa do luto e a sabedoria que dá vida. No fim, ensina a aproveitar a prosperidade e refletir na adversidade: Deus fez um e outro.
Texto: "Melhor é a boa fama do que o unguento precioso, e o dia da morte é preferível ao dia do nascimento. Melhor é ir à casa do luto do que à casa onde há banquete, pois naquela se vê o fim de todos os homens; e os vivos devem considerar isso Melhor é a tristeza do que o riso, porque com a tristeza do …"
Destaque: adversidade — O dia difícil que Deus também fez: tempo de refletir, não de fingir controle.

9. scene_ecc-08-juizo-e-misterio.jpg — "Juízo e mistério" (Eclesiastes 8:11–15) · bloco "Sabedoria e fim · cap. 7–12"
Momento: O Pregador vê a demora do juízo, a confusão das recompensas e o limite da mente: temer a Deus é mais seguro que explicar tudo.
Texto: "Porque a sentença acerca de uma má ação não é imediatamente executada, o coração dos filhos dos homens está totalmente predisposto a praticar o mal. Embora o pecador faça o mal cem vezes e seus dias se estendam, eu sei com certeza que será bem com aqueles que temem a Deus e o reverenciam. Contudo, …"
Destaque: temem a Deus — A certeza no meio do mistério: será bem com quem teme e reverencia a Deus.

10. scene_ecc-09-come-teu-pao-com.jpg — "Come teu pão com alegria" (Eclesiastes 9:7–12) · bloco "Sabedoria e fim · cap. 7–12"
Momento: O Pregador manda comer com alegria, amar a esposa e trabalhar com força, porque a morte chega de súbito e o tempo não favorece só os velozes.
Texto: "Vá, pois, coma com alegria o seu pão e beba com prazer o seu vinho, pois Deus já se agrada das suas obras. Esteja sempre com vestes brancas, e que nunca falte óleo sobre a sua cabeça. Aproveite a vida com a mulher que ama todos os dias da sua existência que Deus lhe deu debaixo do sol; porque essa …"
Destaque: seu tempo — A hora que o homem não conhece: a calamidade pode sobrevir de forma repentina.

11. scene_ecc-10-labios-do-sabio.jpg — "Lábios do sábio" (Eclesiastes 10:12–20) · bloco "Sabedoria e fim · cap. 7–12"
Momento: O Pregador contrapõe a palavra do sábio à do tolo, mostra o peso da preguiça na casa e adverte: até o pensamento contra o rei pode voar.
Texto: "As palavras do sábio são favoráveis, mas os lábios do tolo o devoram. As primeiras palavras da boca do tolo são insensatez, e o final da sua fala é uma loucura perversa. Embora o tolo multiplique as palavras, o homem não sabe o que sucederá; e quem poderá informá-lo sobre o que será depois? O …"
Destaque: palavras — O que sai da boca: favor no sábio, ruína no tolo.

12. scene_ecc-11-lanca-o-pao.jpg — "Lança o pão" (Eclesiastes 11:1–6) · bloco "Sabedoria e fim · cap. 7–12"
Momento: O Pregador manda repartir o pão e semear sem esperar o vento perfeito: ninguém compreende toda a obra de Deus.
Texto: "Reparte o teu pão sobre as águas, pois depois de muitos dias o encontrarás Reparte com sete e ainda com oito, pois não sabes que mal pode sobrevir à terra. Se as nuvens estiverem cheias, derramarão aguaceiro sobre a terra; e se a árvore cair para o sul ou para o norte, no lugar em que cair, ali …"
Destaque: semeie — A ação pedida de manhã e à tarde, sem saber qual semente prosperará.

13. scene_ecc-12-lembra-te-do-teu.jpg — "Lembra-te do teu Criador" (Eclesiastes 12:1–8) · bloco "Sabedoria e fim · cap. 7–12"
Momento: O Pregador chama a juventude a lembrar o Criador antes dos dias ruins. No fim, o pó volta à terra e o espírito a Deus; tudo é vaidade.
Texto: "Lembre-se do seu Criador nos dias da sua juventude, antes que cheguem os dias ruins e os anos em que você dirá: Não tenho prazer neles; Antes que se escureçam o sol, a luz, a lua e as estrelas, e voltem a surgir as nuvens após a chuva. No dia em que tremerem os guardas da casa, se encurvarem os …"
Destaque: Criador — Aquele a quem se deve lembrar na juventude, antes que o prazer se apague.

14. scene_ecc-boss-2.jpg — "Travessia: Sabedoria e fim" (Eclesiastes 12:1–5) · Travessia · bloco "Sabedoria e fim · cap. 7–12"
Momento: Esta Travessia revisa o segundo bloco: luto que ensina, temor a Deus, pão com alegria, língua, semeadura sem vento perfeito e o lembrar do Criador.
Texto: "Lembre-se do seu Criador nos dias da sua juventude, antes que cheguem os dias ruins e os anos em que você dirá: Não tenho prazer neles; Antes que se escureçam o sol, a luz, a lua e as estrelas, e voltem a surgir as nuvens após a chuva. No dia em que tremerem os guardas da casa, se encurvarem os …"
Destaque: Criador — Aquele a lembrar na juventude: o caminho que resta no fim.

Gere todas as 14 imagens com foco no ícone do STWAY.
```
