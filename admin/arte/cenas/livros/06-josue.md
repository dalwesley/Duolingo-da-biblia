# Josué — 22 cena(s)

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

## Josué — 22 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Josué — Josué capítulo a capítulo: a entrada na terra, a conquista e a aliança renovada.

1. scene_jsc-01-ordens-de-josue.jpg — "Ordens de Josué" (Josué 1:10–15) · bloco "Entrada · cap. 1–4"
Momento: Moisés morreu. Josué prepara o povo para atravessar o Jordão em três dias e lembra as tribos do leste do compromisso de ajudar os irmãos.
Texto: "Então, Josué deu ordens aos líderes do povo, dizendo: Passai pelo meio do acampamento e ordenai ao povo, dizendo: "Provede-vos de comida, pois em três dias passareis este Jordão, para que entreis na terra que o Senhor, vosso Deus, vos dá para a possuirdes." Josué dirigiu-se aos rubenitas, gaditas e …"
Destaque: descansar — O Senhor dá descanso e terra; o povo ainda precisa atravessar e ajudar.

2. scene_jsc-02-raabe-esconde-os-espias.jpg — "Raabe esconde os espias" (Josué 2:1–6) · bloco "Entrada · cap. 1–4"
Momento: Josué envia dois espias a Jericó. Eles entram na casa de Raabe; o rei manda buscá-los, e ela os esconde no telhado.
Texto: "Josué, filho de Num, enviou secretamente dois homens de Sitim para explorar a terra, dizendo: Vão e observem a terra e a cidade de Jericó. Eles foram e entraram na casa de uma mulher chamada Raabe, que era prostituta, e ali permaneceram Então, o rei de Jericó recebeu a notícia, dizendo: "Esta …"
Destaque: esconder — Raabe oculta os espias e desvia os perseguidores com coragem.

3. scene_jsc-03-a-arca-na-frente.jpg — "A arca na frente" (Josué 3:1–6) · bloco "Entrada · cap. 1–4"
Momento: Depois de três dias junto ao Jordão, o povo recebe ordem de seguir a arca da aliança, mantendo distância, e de santificar-se.
Texto: "Josué levantou-se de madrugada, e, ele e todos os filhos de Israel, partiram de Sitim e vieram até o Jordão, onde acamparam antes de atravessar. E aconteceu que, ao fim de três dias, os oficiais passaram pelo meio do acampamento E ordenaram ao povo, dizendo: Quando virdes a arca da Aliança do …"
Destaque: arca — A arca da aliança vai à frente: sinal de que o Deus vivo está no meio do povo.

4. scene_jsc-04-doze-pedras.jpg — "Doze pedras" (Josué 4:1–6) · bloco "Entrada · cap. 1–4"
Momento: Depois que todo o povo passou o Jordão, o Senhor manda tirar doze pedras do meio do rio para memorial.
Texto: "Sucedeu que, ao passar todo o povo pelo Jordão, o Senhor falou a Josué, dizendo: Escolham do povo doze homens, um de cada tribo. E ordenei-lhes que dissessem: "Tirem do meio do Jordão, do local onde os sacerdotes estiveram parados, doze pedras e levem-nas com vocês para o outro lado, e coloquem-nas …"
Destaque: memorial — As pedras guardam a memória do que o Senhor fez, para quando os filhos perguntarem.

5. scene_jsc-boss-1.jpg — "Travessia: Entrada" (Josué 1:16–18) · Travessia · bloco "Entrada · cap. 1–4"
Momento: Esta Travessia revisa a Entrada: ordens de Josué, Raabe, a arca na frente e as doze pedras de memorial.
Texto: "Então, responderam a Josué, dizendo: Tudo quanto nos ordenares faremos e aonde quer que nos envias iremos. Como em tudo ouvimos a Moisés, assim também te ouviremos; somente que o Senhor, teu Deus, esteja contigo, como esteve com Moisés. Todo homem que se rebelar contra a tua palavra e não ouvir as …"
Destaque: memorial — As pedras e a arca guardam a memória do Senhor que abre caminho.

6. scene_jsc-05-pascoa-e-o-principe.jpg — "Páscoa e o príncipe" (Josué 5:10–15) · bloco "Conquista · cap. 5–9"
Momento: Em Gilgal o povo celebra a Páscoa; o maná cessa, e Josué encontra perto de Jericó um homem de espada nua.
Texto: "Estando, pois, os filhos de Israel acampados em Gilgal, celebraram a Páscoa no dia catorze do mês, à tarde, nas campinas de Jericó. E comeram do fruto da terra, no dia seguinte à Páscoa, pães asmos e grãos tostados, naquele mesmo dia. E o maná cessou no dia seguinte, depois que comeram do produto …"
Destaque: santo — O lugar onde o príncipe do exército do Senhor aparece exige sandálias tiradas.

7. scene_jsc-06-sete-trombetas.jpg — "Sete trombetas" (Josué 6:6–11) · bloco "Conquista · cap. 5–9"
Momento: Josué manda sacerdotes levar a arca e tocar trombetas ao redor de Jericó; o povo marcha em silêncio.
Texto: "Então, Josué, filho de Num, chamou os sacerdotes e lhes disse: "Levem a arca da Aliança; e que sete sacerdotes toquem sete trombetas de chifre de carneiro diante da arca do Senhor." E disse ao povo: "Passai e rodeai a cidade; e quem estiver armado vá adiante da arca do Senhor." E assim ocorreu, …"
Destaque: trombetas — Sete trombetas de chifre de carneiro soam diante da arca do Senhor.

8. scene_jsc-07-derrota-em-ai.jpg — "Derrota em Ai" (Josué 7:1–6) · bloco "Conquista · cap. 5–9"
Momento: Israel prevarica nas coisas consagradas; em Ai os homens fogem e Josué se prostra diante da arca.
Texto: "Os filhos de Israel prevaricaram nas coisas consagradas, pois Acã, filho de Carmi, filho de Zabdi, filho de Zera, da tribo de Judá, tomou do que era destinado à destruição, e a ira do Senhor se acendeu contra os filhos de Israel. Josué, portanto, enviou de Jericó alguns homens a Ai, que está perto …"
Destaque: prevaricaram — Israel quebrou a consagração; a ira do Senhor se acendeu.

9. scene_jsc-08-altar-no-ebal.jpg — "Altar no Ebal" (Josué 8:30–35) · bloco "Conquista · cap. 5–9"
Momento: Depois de Ai, Josué edifica um altar no monte Ebal e lê a lei diante de todo o povo.
Texto: "Então, Josué edificou um altar ao Senhor, Deus de Israel, no monte Ebal, Como Moisés, servo do Senhor, ordenou aos filhos de Israel, conforme está escrito no Livro da Lei de Moisés, um altar de pedras toscas, sobre o qual não se manejou instrumento de ferro; e sobre ele ofereceram holocaustos ao …"
Destaque: lei — Bênçãos e maldições lidas conforme o livro da lei de Moisés.

10. scene_jsc-09-engano-de-gibeao.jpg — "Engano de Gibeão" (Josué 9:3–8) · bloco "Conquista · cap. 5–9"
Momento: Os gibeonitas fingem vir de longe com pães mofados e pedem aliança a Israel em Gilgal.
Texto: "E os moradores de Gibeão, ao ouvirem o que Josué fizera a Jericó e a Ai, Eles agiram com astúcia e se passaram por embaixadores: levaram sacos velhos sobre os jumentos e odres de vinho, velhos, rasgados e consertados; E nos pés, sapatos velhos e remendados, e roupas antigas sobre si; e todo o pão …"
Destaque: astúcia — Os gibeonitas enganam com aparência de viagem longa.

11. scene_jsc-boss-2.jpg — "Travessia: Conquista" (Josué 6:10–15) · Travessia · bloco "Conquista · cap. 5–9"
Momento: Esta Travessia revisa a Conquista: Páscoa e príncipe, trombetas, derrota em Ai, altar no Ebal e engaño de Gibeão.
Texto: "Porém, Josué havia ordenado ao povo dizendo: Não gritem, nem façam ouvir a sua voz, nem saia palavra alguma de sua boca, até o dia em que eu lhes disser: Gritem! Então, gritarão. Assim, a arca do Senhor rodeou a cidade, contornando-a uma vez; depois, retornaram ao acampamento e ali pernoitaram. …"
Destaque: ouvir — Vitória e queda dependem de ouvir o Senhor e não confiar só nos olhos.

12. scene_jsc-10-sol-em-gibeao.jpg — "Sol em Gibeão" (Josué 10:8–14) · bloco "Vitória e herança · cap. 10–17"
Momento: Gibeão pede socorro; Josué sobe de Gilgal, e o Senhor luta com pedras do céu e ouve a voz de Josué sobre o sol.
Texto: "E o Senhor disse a Josué: Não os tema, pois os entreguei em suas mãos; nenhum deles poderá resistir a você. Josué os atacou de surpresa, pois ele havia subido de Gilgal durante toda a noite. E o Senhor os conturbou diante de Israel, e os feriu com grande matança em Gibeão; e os perseguiu pelo …"
Destaque: detém-te — Josué manda o sol deter-se em Gibeão enquanto o Senhor luta.

13. scene_jsc-11-josue-cumpriu-tudo.jpg — "Josué cumpriu tudo" (Josué 11:15–20) · bloco "Vitória e herança · cap. 10–17"
Momento: Josué cumpre tudo o que o Senhor ordenou a Moisés; conquista a terra e ela repousa da guerra.
Texto: "Como o Senhor havia ordenado a Moisés, seu servo, assim Moisés ordenou a Josué; e Josué cumpriu tudo o que o Senhor havia ordenado a Moisés, sem deixar de lado nenhuma palavra. Assim, Josué tomou toda aquela terra, a saber, a região montanhosa, todo o Neguebe, toda a terra de Gósen, as planícies, a …"
Destaque: cumpriu — Josué não deixou de lado nenhuma palavra do Senhor.

14. scene_jsc-12-calebe-pede-hebrom.jpg — "Calebe pede Hebrom" (Josué 14:6–12) · bloco "Vitória e herança · cap. 10–17"
Momento: Calebe, aos oitenta e cinco anos, pede a Josué o monte prometido: Hebrom, ainda com anaquins.
Texto: "Chegaram os filhos de Judá a Josué em Gilgal; e Calebe, filho de Jefoné, o quenezeu, disse: Tu sabes o que o Senhor falou a Moisés, homem de Deus, em Cades-Barnéia, a respeito de mim e de ti. Tinha eu quarenta anos quando Moisés, servo do Senhor, me enviou de Cades-Barnéia para espiar a terra; e eu …"
Destaque: perseveraste — Calebe perseverou em seguir o Senhor; por isso recebe a herança.

15. scene_jsc-13-um-quinhao-so.jpg — "Um quinhão só" (Josué 17:12–18) · bloco "Vitória e herança · cap. 10–17"
Momento: A casa de José reclama um quinhão só; Josué manda subir ao bosque e expulsar, mesmo com carros de ferro.
Texto: "Mas os filhos de Manassés não puderam expulsar os habitantes daquelas cidades, pois os cananeus persistiam em habitar nessa terra. E aconteceu que, tornando-se fortes os filhos de Israel, impuseram aos cananeus trabalhos forçados; contudo, não os expulsaram de todo. Então os filhos de José falaram …"
Destaque: quinhão — A sorte de herança que a casa de José acha pequena demais.

16. scene_jsc-boss-3.jpg — "Travessia: Vitória e herança" (Josué 10:12–14) · Travessia · bloco "Vitória e herança · cap. 10–17"
Momento: Esta Travessia revisa Vitória e herança: sol em Gibeão, cumprimento total, Calebe e o quinhão da casa de José.
Texto: "Então, Josué falou ao Senhor, no dia em que o Senhor entregou os amorreus nas mãos dos filhos de Israel; e disse na presença dos israelitas: Sol, detém-te em Gibeão, e tu, lua, no vale de Aijalom. E o sol se deteve e a lua parou até que o povo se vingou de seus inimigos. Não está isto escrito no …"
Destaque: possuir — O Senhor dá a terra; o povo precisa tomar posse com fé.

17. scene_jsc-14-a-tenda-em-silo.jpg — "A tenda em Siló" (Josué 18:1–6) · bloco "Repouso e aliança · cap. 18–24"
Momento: Em Siló arma-se a tenda da congregação; sete tribos ainda sem herança ouvem Josué mandar mapear a terra.
Texto: "Toda a congregação dos filhos de Israel se reuniu em Siló, e ali armaram a tenda da congregação; e a terra se encontrava sujeita diante deles. E dentre os filhos de Israel permaneceram sete tribos que ainda não haviam recebido a sua herança. Josué disse aos filhos de Israel: Até quando vocês serão …"
Destaque: sortes — Josué lança as sortes perante o Senhor para repartir a terra.

18. scene_jsc-15-cidades-de-refugio.jpg — "Cidades de refúgio" (Josué 20:1–6) · bloco "Repouso e aliança · cap. 18–24"
Momento: O Senhor manda separar cidades de refúgio para o homicida sem intenção, até o juízo da congregação.
Texto: "Então, o Senhor falou a Josué: Fala aos filhos de Israel, dizendo: Separem para vocês as cidades de refúgio, das quais lhes falei por meio de Moisés. Para que o homicida que, por engano, matar alguma pessoa sem intenção, possa fugir para ali; esses lugares serão refúgio contra o vingador do sangue. …"
Destaque: refúgio — Cidade que guarda a vida do homicida involuntário até o juízo.

19. scene_jsc-16-altar-junto-ao-jordao.jpg — "Altar junto ao Jordão" (Josué 22:10–15) · bloco "Repouso e aliança · cap. 18–24"
Momento: As tribos do leste edificam um altar junto ao Jordão; Israel se reúne em Siló para pelear, mas primeiro envia Finéias.
Texto: "E, ao chegarem aos limites do Jordão, na terra de Canaã, os filhos de Rúben, os filhos de Gade e a meia tribo de Manassés edificaram um altar junto ao Jordão, um altar grande e vistoso. E os filhos de Israel ouviram dizer: Eis que os filhos de Rúben, os filhos de Gade e a meia-tribo de Manassés …"
Destaque: altar — Construção que Israel teme como rebelião, antes de ouvir o motivo.

20. scene_jsc-17-josue-ja-velho.jpg — "Josué já velho" (Josué 23:1–6) · bloco "Repouso e aliança · cap. 18–24"
Momento: Depois do descanso, Josué já velho convoca Israel: apeguem-se ao Senhor, cumpram a lei e não se misturem aos povos.
Texto: "E aconteceu que, após muito tempo em que o Senhor concedeu descanso a Israel de todos os seus inimigos ao redor, e Josué já era velho e avançado em idade, Josué convocou todo o Israel, seus anciãos, os líderes, os juízes e os oficiais, e lhes disse: "Já sou velho e estou em idade avançada;" E vocês …"
Destaque: apegai-vos — Ordem de permanecer firmes no Senhor, como até hoje.

21. scene_jsc-18-historia-em-siquem.jpg — "História em Siquém" (Josué 24:1–6) · bloco "Repouso e aliança · cap. 18–24"
Momento: Em Siquém, Josué conta a história do Senhor: tirou, guiou e deu a terra; Israel não conquistou com espada própria.
Texto: "Então Josué reuniu todas as tribos de Israel em Siquém, e convocou os anciãos de Israel, os seus cabeças, os juízes e os oficiais; e eles se apresentaram diante de Deus. E Josué disse a todo o povo: Assim diz o SENHOR, Deus de Israel: Antigamente, os seus pais habitaram além do rio, Tera, pai de …"
Destaque: dei — O Senhor deu a terra, cidades e vinhas que o povo não fez.

22. scene_jsc-boss-4.jpg — "Travessia: Repouso e aliança" (Josué 23:1–8) · Travessia · bloco "Repouso e aliança · cap. 18–24"
Momento: Esta Travessia revisa Repouso e aliança: Siló e a herança, cidades de refúgio, o altar no Jordão, a exortação de Josué e a memória em Siquém.
Texto: "E aconteceu que, após muito tempo em que o Senhor concedeu descanso a Israel de todos os seus inimigos ao redor, e Josué já era velho e avançado em idade, Josué convocou todo o Israel, seus anciãos, os líderes, os juízes e os oficiais, e lhes disse: "Já sou velho e estou em idade avançada;" E vocês …"
Destaque: aliança — Fidelidade ao Senhor que deu a terra e pede memória.

Gere todas as 22 imagens com foco no ícone do STWAY.
```
