# Levítico — 30 cena(s)

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

## Levítico — 30 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Levítico — Levítico capítulo a capítulo: o Senhor santifica um povo para morar no meio dele.

1. scene_lvc-01-holocausto-no-altar.jpg — "Holocausto no altar" (Levítico 1:1–5) · bloco "Ofertas · cap. 1–6"
Momento: O Senhor fala a Moisés da Tenda da Congregação sobre como trazer holocausto de gado.
Texto: "E o Senhor chamou a Moisés e falou com ele da Tenda da Congregação, dizendo: Fale aos filhos de Israel e diga-lhes: Quando alguém de vocês trouxer uma oferta ao Senhor, trarão suas ofertas de gado, de rebanho ou de animais pequenos. Se sua oferta for um holocausto de gado, trará um macho sem …"
Destaque: Holocausto — Oferta queimada inteira, aroma agradável ao Senhor, animal sem defeito.

2. scene_lvc-02-oferta-de-cereais.jpg — "Oferta de cereais" (Levítico 2:1–6) · bloco "Ofertas · cap. 1–6"
Momento: Cena de Oferta de cereais: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Quando alguém fizer uma oferta de manjares ao Senhor, sua oferta será de flor de farinha; nela, deve derramar azeite e colocar incenso por cima. E a levará aos filhos de Arão, os sacerdotes; um deles tomará um punhado da flor de farinha, do seu azeite e de todo o incenso e o sacerdote queimará como …"
Destaque: Senhor — Nome ou título central neste trecho.

3. scene_lvc-03-pecado-sem-querer.jpg — "Pecado sem querer" (Levítico 4:1–6) · bloco "Ofertas · cap. 1–6"
Momento: Cena de Pecado sem querer: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Disse, então, o SENHOR a Moisés: Fale aos filhos de Israel, dizendo: Quando alguém pecar por ignorância contra qualquer um dos mandamentos do SENHOR, por fazer o que não se deve fazer, e agir contra um deles. Se o sacerdote ungido pecar causando escândalo ao povo, oferecerá por seu pecado um …"
Destaque: SENHOR — Nome ou título central neste trecho.

4. scene_lvc-04-confissao-e-oferta.jpg — "Confissão e oferta" (Levítico 5:1–6) · bloco "Ofertas · cap. 1–6"
Momento: Cena de Confissão e oferta: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Quando alguém pecar ao ouvir a voz de uma imprecação, sendo testemunha do ocorrido, por ter visto ou sabido e, no entanto, não o revelar, levará sobre si sua iniquidade. Ou, quando alguém tocar em algo imundo, seja o corpo de um animal impuro, seja o corpo de um réptil imundo, ainda que não saiba, …"
Destaque: SENHOR — Nome ou título central neste trecho.

5. scene_lvc-05-fogo-continuo.jpg — "Fogo contínuo" (Levítico 6:8–13) · bloco "Ofertas · cap. 1–6"
Momento: Cena de Fogo contínuo: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "O Senhor disse mais a Moisés: Ordene a Arão e seus filhos, dizendo: Esta é a lei do holocausto: o holocausto permanecerá na lareira do altar toda a noite até pela manhã, e o fogo do altar se manterá aceso. O sacerdote vestirá sua túnica de linho e colocará calções de linho sobre a pele nua, e …"
Destaque: Senhor — Nome ou título central neste trecho.

6. scene_lvc-boss-1.jpg — "Travessia: Ofertas" (Levítico 1:1–5) · Travessia · bloco "Ofertas · cap. 1–6"
Momento: Cena de Travessia: Ofertas: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "E o Senhor chamou a Moisés e falou com ele da Tenda da Congregação, dizendo: Fale aos filhos de Israel e diga-lhes: Quando alguém de vocês trouxer uma oferta ao Senhor, trarão suas ofertas de gado, de rebanho ou de animais pequenos. Se sua oferta for um holocausto de gado, trará um macho sem …"
Destaque: Senhor — Nome ou título central neste trecho.

7. scene_lvc-06-oferta-de-paz.jpg — "Oferta de paz" (Levítico 7:11–16) · bloco "Sacerdotes · cap. 7–10"
Momento: Cena de Oferta de paz: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Esta é a lei das ofertas pacíficas que alguém pode apresentar ao Senhor: Se oferecer como ação de graças, junto com o sacrifício de louvor, trará bolos sem fermento amassados com azeite; também apresentará obreias sem fermento untadas com azeite e bolos de flor de farinha bem amassados com azeite. …"
Destaque: Senhor — Nome ou título central neste trecho.

8. scene_lvc-07-sangue-na-ordenacao.jpg — "Sangue na ordenação" (Levítico 8:14–19) · bloco "Sacerdotes · cap. 7–10"
Momento: Cena de Sangue na ordenação: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Então, trouxe o novilho da oferta pelo pecado; e Arão e seus filhos impuseram as mãos sobre a cabeça do novilho da oferta pelo pecado. E Moisés o imolou, pegou o sangue e, com o dedo, o colocou nos chifres do altar ao redor, e purificou o altar; em seguida, derramou o restante do sangue na base do …"
Destaque: Senhor — Nome ou título central neste trecho.

9. scene_lvc-08-fogo-que-sai.jpg — "Fogo que sai" (Levítico 9:18–23) · bloco "Sacerdotes · cap. 7–10"
Momento: Cena de Fogo que sai: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Depois, imolou o boi e o carneiro em sacrifício pacífico, que era pelo povo; e os filhos de Arão lhe entregaram o sangue, que aspergiu em torno do altar. E a gordura do boi e do carneiro, a cauda, o que cobre as entranhas, os rins e o redenho do fígado. E puseram a gordura sobre o peito e a …"
Destaque: Senhor — Nome ou título central neste trecho.

10. scene_lvc-09-santos-e-sobrios.jpg — "Santos e sóbrios" (Levítico 10:3–8) · bloco "Sacerdotes · cap. 7–10"
Momento: Cena de Santos e sóbrios: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "E Moisés disse a Arão: "Isto é o que o SENHOR falou: Mostrarei minha santidade entre aqueles que se aproximarem de mim e serei glorificado diante de todo o povo." E Arão se calou. E Moisés chamou Misael e Elzafã, filhos de Uziel, tio de Arão, e disse-lhes: Venham, tirem seus irmãos de diante do …"
Destaque: Senhor — Nome ou título central neste trecho.

11. scene_lvc-boss-2.jpg — "Travessia: Sacerdotes" (Levítico 7:11–12) · Travessia · bloco "Sacerdotes · cap. 7–10"
Momento: Cena de Travessia: Sacerdotes: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Esta é a lei das ofertas pacíficas que alguém pode apresentar ao Senhor: Se oferecer como ação de graças, junto com o sacrifício de louvor, trará bolos sem fermento amassados com azeite; também apresentará obreias sem fermento untadas com azeite e bolos de flor de farinha bem amassados com azeite."
Destaque: Senhor — Nome ou título central neste trecho.

12. scene_lvc-10-santos-porque-eu-sou.jpg — "Santos porque eu sou" (Levítico 11:41–46) · bloco "Pureza · cap. 11–15"
Momento: Cena de Santos porque eu sou: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Todo réptil que se arrasta sobre a terra será abominação; não se comerá. Não comereis nada que se rasteje pelo chão, seja o que anda sobre o ventre, o que se move sobre quatro patas ou o que possui muitos pés, pois todos esses são considerados abominação. Não tornem suas almas abomináveis por causa …"
Destaque: SENHOR — Nome ou título central neste trecho.

13. scene_lvc-11-purificacao-da-mae.jpg — "Purificação da mãe" (Levítico 12:1–6) · bloco "Pureza · cap. 11–15"
Momento: Cena de Purificação da mãe: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Disse ainda o Senhor a Moisés: Fale aos filhos de Israel, dizendo: Se uma mulher conceber e tiver um menino, ficará impura durante sete dias, assim como nos dias de sua menstruação, estará imunda. No oitavo dia, a carne do prepúcio do menino deverá ser circuncidada. E ela permanecerá trinta e três …"
Destaque: Senhor — Nome ou título central neste trecho.

14. scene_lvc-12-o-sacerdote-examina.jpg — "O sacerdote examina" (Levítico 13:1–6) · bloco "Pureza · cap. 11–15"
Momento: Cena de O sacerdote examina: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "O Senhor falou a Moisés e a Arão, dizendo: Quando um homem tiver na pele da sua carne uma inchação, uma pústula ou uma mancha lustrosa, que se manifeste como uma praga de lepra, será levado a Arão, o sacerdote, ou a um de seus filhos, sacerdotes. O sacerdote examinará a lesão na pele; se o cabelo …"
Destaque: Senhor — Nome ou título central neste trecho.

15. scene_lvc-13-limpo-de-novo.jpg — "Limpo de novo" (Levítico 14:1–6) · bloco "Pureza · cap. 11–15"
Momento: Cena de Limpo de novo: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Disse, então, o Senhor a Moisés: Esta é a lei do leproso no dia da sua purificação: será levado ao sacerdote. E o sacerdote sairá do acampamento e, ao examiná-lo, se constatar que a praga da lepra do leproso está curada, Então o sacerdote ordenará que, para aquele que deve se purificar, se tomem …"
Destaque: Senhor — Nome ou título central neste trecho.

16. scene_lvc-14-fluxo-e-oferta.jpg — "Fluxo e oferta" (Levítico 15:25–30) · bloco "Pureza · cap. 11–15"
Momento: Cena de Fluxo e oferta: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Também a mulher que tiver fluxo de sangue por muitos dias, fora do seu tempo de menstruação, ou que tiver fluxo de sangue por mais tempo do que o costumado, será considerada imunda todos os dias do seu fluxo, assim como nos dias da sua menstruação. Toda cama em que ela se deitar durante os dias do …"
Destaque: SENHOR — Nome ou título central neste trecho.

17. scene_lvc-boss-3.jpg — "Travessia: Pureza" (Levítico 11:41–44) · Travessia · bloco "Pureza · cap. 11–15"
Momento: Cena de Travessia: Pureza: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Todo réptil que se arrasta sobre a terra será abominação; não se comerá. Não comereis nada que se rasteje pelo chão, seja o que anda sobre o ventre, o que se move sobre quatro patas ou o que possui muitos pés, pois todos esses são considerados abominação. Não tornem suas almas abomináveis por causa …"
Destaque: Senhor — Nome ou título central neste trecho.

18. scene_lvc-15-sangue-e-bode.jpg — "Sangue e bode" (Levítico 16:15–20) · bloco "Expiação e santidade · cap. 16–20"
Momento: Cena de Sangue e bode: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Então, degolará o bode da oferta pelo pecado, que é para o povo, e levará seu sangue para dentro do véu; e com o seu sangue fará como fez com o sangue do novilho, aspergindo-o sobre o propiciatório e diante dele. Assim, fará a expiação pelo santuário em razão das impurezas dos filhos de Israel, de …"
Destaque: Senhor — Nome ou título central neste trecho.

19. scene_lvc-16-so-perante-a-tenda.jpg — "Só perante a tenda" (Levítico 17:1–6) · bloco "Expiação e santidade · cap. 16–20"
Momento: Cena de Só perante a tenda: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "E o Senhor falou a Moisés, dizendo. Fale a Arão, a seus filhos e a todos os filhos de Israel e diga-lhes: Isto é o que o Senhor ordenou, dizendo: Qualquer homem da casa de Israel que sacrificar um boi, um cordeiro ou uma cabra no acampamento ou fora dele, E, se não trouxer à porta da tenda da …"
Destaque: Senhor — Nome ou título central neste trecho.

20. scene_lvc-17-nao-vos-contamineis.jpg — "Não vos contamineis" (Levítico 18:24–29) · bloco "Expiação e santidade · cap. 16–20"
Momento: Cena de Não vos contamineis: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Não vos contamineis com nenhuma dessas práticas, pois, por todas essas coisas, as nações que eu expulso diante de vós se tornaram impuras. Por isso, a terra se tornou contaminada; e eu farei recair sobre ela a sua iniquidade, e a terra expulsará os seus moradores. Porém, vocês guardarão os meus …"
Destaque: Senhor — Nome ou título central neste trecho.

21. scene_lvc-18-amaras-o-teu-proximo.jpg — "Amarás o teu próximo" (Levítico 19:9–14) · bloco "Expiação e santidade · cap. 16–20"
Momento: Cena de Amarás o teu próximo: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Quando vocês colherem a messe da sua terra, não colherão completamente as bordas do seu campo, nem pegarão as espigas caídas durante a colheita. Não rebuscarás a tua vinha, nem colherás os bagos caídos dela; deixá-los-ás para o pobre e para o estrangeiro. Eu sou o SENHOR, vosso Deus. Não roubarão, …"
Destaque: Senhor — Nome ou título central neste trecho.

22. scene_lvc-19-separados-para-mim.jpg — "Separados para mim" (Levítico 20:19–24) · bloco "Expiação e santidade · cap. 16–20"
Momento: Cena de Separados para mim: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Não descobrirás a nudez da irmã de tua mãe ou da irmã de teu pai; pois quem descobrir a nudez de sua parente levará sobre si a sua iniquidade. Se um homem se deitar com sua tia, ele terá revelado a nudez de seu tio; seu pecado será sobre ele e morrerá sem deixar filhos. Se um homem se casar com a …"
Destaque: Senhor — Nome ou título central neste trecho.

23. scene_lvc-boss-4.jpg — "Travessia: Expiação e santidade" (Levítico 16:15–19) · Travessia · bloco "Expiação e santidade · cap. 16–20"
Momento: Cena de Travessia: Expiação e santidade: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Então, degolará o bode da oferta pelo pecado, que é para o povo, e levará seu sangue para dentro do véu; e com o seu sangue fará como fez com o sangue do novilho, aspergindo-o sobre o propiciatório e diante dele. Assim, fará a expiação pelo santuário em razão das impurezas dos filhos de Israel, de …"
Destaque: Senhor — Nome ou título central neste trecho.

24. scene_lvc-20-santos-ao-seu-deus.jpg — "Santos ao seu Deus" (Levítico 21:6–11) · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Santos ao seu Deus: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Serão santos ao seu Deus e não profanarão o nome do seu Deus, pois oferecem as ofertas queimadas ao Senhor, o pão do seu Deus; portanto, serão santos. Não devem se casar com mulher prostituta ou desonrada, nem com mulher repudiada de seu marido, pois são santos diante de seu Deus. Por isso, você o …"
Destaque: Senhor — Nome ou título central neste trecho.

25. scene_lvc-21-sem-defeito.jpg — "Sem defeito" (Levítico 22:17–22) · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Sem defeito: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Disse ainda o Senhor a Moisés: Fala a Arão, a seus filhos e a todos os filhos de Israel e diz-lhes: Qualquer que, da casa de Israel ou dos estrangeiros que estão em Israel, apresentar a sua oferta, seja em cumprimento de seus votos ou como ofertas voluntárias, que a apresente ao Senhor em …"
Destaque: Senhor — Nome ou título central neste trecho.

26. scene_lvc-22-festas-e-espigas.jpg — "Festas e espigas" (Levítico 23:15–20) · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Festas e espigas: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Contarão para vocês desde o dia seguinte ao sábado, desde o dia em que trouxerem o feixe da oferta movida; serão sete semanas inteiras. Até o dia seguinte ao sétimo sábado, contareis cinquenta dias; então, trareis uma nova oferta de grãos ao Senhor. Trareis de vossas moradas dois pães de oferta …"
Destaque: Senhor — Nome ou título central neste trecho.

27. scene_lvc-23-azeite-e-paes.jpg — "Azeite e pães" (Levítico 24:1–6) · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Azeite e pães: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "E o Senhor falou a Moisés, dizendo: Ordena aos filhos de Israel que te tragam azeite puro de oliveira, batido, para o candelabro, a fim de que haja lâmpada acesa continuamente. Arão manterá em ordem perante o Senhor continuamente, desde a tarde até a manhã, fora do véu do Testemunho, na tenda da …"
Destaque: Senhor — Nome ou título central neste trecho.

28. scene_lvc-24-ano-do-jubileu.jpg — "Ano do jubileu" (Levítico 25:8–13) · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Ano do jubileu: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Contarás sete semanas de anos, sete vezes sete anos, de modo que os dias das sete semanas de anos equivalerão a quarenta e nove anos. Então, no mês sétimo, no décimo dia do mês, vós fareis tocar a trombeta vibrante; no Dia da Expiação, fareis soar a trombeta por toda a vossa terra. Santificareis o …"
Destaque: Senhor — Nome ou título central neste trecho.

29. scene_lvc-25-se-andardes-nos-meus.jpg — "Se andardes nos meus estatutos" (Levítico 26:3–8) · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Se andardes nos meus estatutos: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Se vocês andarem nos meus estatutos, guardarem os meus mandamentos e os cumprirem. Então, eu vos darei as chuvas no tempo apropriado; a terra produzirá suas colheitas e as árvores do campo darão os seus frutos. E a debulha se estenderá até à vindima, e a vindima, até à sementeira; comereis o vosso …"
Destaque: Senhor — Nome ou título central neste trecho.

30. scene_lvc-boss-5.jpg — "Travessia: Festas e aliança" (Levítico 21:6–9) · Travessia · bloco "Festas e aliança · cap. 21–27"
Momento: Cena de Travessia: Festas e aliança: o Senhor instrui Israel sobre culto, pureza e vida santa.
Texto: "Serão santos ao seu Deus e não profanarão o nome do seu Deus, pois oferecem as ofertas queimadas ao Senhor, o pão do seu Deus; portanto, serão santos. Não devem se casar com mulher prostituta ou desonrada, nem com mulher repudiada de seu marido, pois são santos diante de seu Deus. Por isso, você o …"
Destaque: Senhor — Nome ou título central neste trecho.

Gere todas as 30 imagens com foco no ícone do STWAY.
```
