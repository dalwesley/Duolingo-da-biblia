# Êxodo — 44 cena(s)

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

## Êxodo — 44 cena(s)

Anexe `trilha_app/assets/icon/app_icon_ios.png` e cole:

```text
Trilha: Êxodo — Êxodo capítulo a capítulo: Deus liberta o povo e habita no meio dele.

1. scene_exc-01-as-parteiras-temeram.jpg — "As parteiras temeram" (Êxodo 1:15–20) · bloco "Opressão e chamado · cap. 1–6"
Momento: Israel multiplica no Egito. O rei vê ameaça e ordena às parteiras hebraicas matar os meninos ao nascer.
Texto: "E o rei do Egito falou às parteiras hebraicas, uma das quais se chamava Sifrá, e a outra, Puá. Disse: Quando ajudarem as hebreias a dar à luz e as virem nos bancos de parto, examinai: se for filho, matai-o; mas, se for filha, que viva. As parteiras, porém, temeram a Deus e não agiram conforme a …"
Destaque: Temeram — As parteiras temeram a Deus e desobedeceram à ordem do rei.

2. scene_exc-02-um-cesto-no-rio.jpg — "Um cesto no rio" (Êxodo 2:1–6) · bloco "Opressão e chamado · cap. 1–6"
Momento: Faraó ordenou lançar os meninos hebreus no Nilo. Uma mãe da casa de Levi esconde o filho e o põe no rio.
Texto: "Um homem da casa de Levi partiu e casou-se com uma mulher da sua linhagem. E a mulher concebeu e deu à luz um filho; vendo que era formoso, escondeu-o por três meses. Não podendo mais escondê-lo, tomou um cesto de juncos, impermeabilizou-o com betume e piche e, colocando nele o menino, largou-o …"
Destaque: Cesto — O menino é colocado num cesto entre os juncos; Deus o guarda até a filha de Faraó.

3. scene_exc-03-este-e-o-meu.jpg — "Este é o meu nome" (Êxodo 3:15–20) · bloco "Opressão e chamado · cap. 1–6"
Momento: No monte, Deus chama Moisés. O povo está no Egito; Moisés deve dizer quem o envia e o que Faraó fará.
Texto: "E Deus disse ainda mais a Moisés: Assim dirás aos filhos de Israel: O SENHOR, o Deus de vossos pais, o Deus de Abraão, o Deus de Isaque e o Deus de Jacó, me enviou a vocês; este é o meu nome eternamente, e assim serei lembrado de geração em geração. Vá e reúna os anciãos de Israel e diga-lhes: O …"
Destaque: SENHOR — O nome pelo qual Deus quer ser lembrado de geração em geração.

4. scene_exc-04-sinais-na-mao.jpg — "Sinais na mão" (Êxodo 4:1–5) · bloco "Opressão e chamado · cap. 1–6"
Momento: Moisés teme que Israel não creia que o Senhor apareceu. Deus responde com sinais na mão.
Texto: "Então Moisés respondeu: Mas, se eu os convocar, não crerão em mim, nem atenderão à minha voz, pois dirão: O SENHOR não te apareceu. E o Senhor perguntou a ele: "O que é isso que tens na mão?" Ele respondeu: "Um bordão." Disse-lhe: "Lance-a ao chão." Ele a lançou ao chão e se transformou em uma …"
Destaque: Sinais — Provas que Deus dá para que o povo creia no envio de Moisés.

5. scene_exc-05-deixem-o-povo-ir.jpg — "Deixem o povo ir" (Êxodo 5:1–6) · bloco "Opressão e chamado · cap. 1–6"
Momento: Moisés e Arão pedem a Faraó que deixe Israel ir. Ele diz não conhecer o Senhor e agrava o trabalho dos tijolos.
Texto: "Depois, Moisés e Arão foram até Faraó e lhe disseram: Assim diz o Senhor, Deus de Israel: Deixe ir o meu povo, para que me celebre uma festividade no deserto. Mas Faraó respondeu: Quem é o Senhor para que eu ouça a sua voz e deixe Israel partir? Não conheço o Senhor e não deixarei Israel ir. …"
Destaque: Deixe ir — Ordem do Senhor a Faraó: libertar o povo para celebrar no deserto.

6. scene_exc-06-eu-sou-o-senhor.jpg — "Eu sou o Senhor" (Êxodo 6:2–7) · bloco "Opressão e chamado · cap. 1–6"
Momento: Deus fala a Moisés: revela-se, lembra a aliança e promete libertar, resgatar e tomar Israel por povo.
Texto: "Deus também falou a Moisés dizendo: Eu sou o SENHOR. E eu me revelei a Abraão, a Isaque e a Jacó como Deus Todo-Poderoso; mas pelo meu nome, O SENHOR, não lhes fui conhecido. Também estabeleci a minha aliança com eles, para lhes dar a terra de Canaã, a terra em que habitaram como estrangeiros. E …"
Destaque: Senhor — Nome pelo qual Deus se dá a conhecer e promete agir por Israel.

7. scene_exc-boss-1.jpg — "Travessia: Opressão e chamado" (Êxodo 5:1–6) · Travessia · bloco "Opressão e chamado · cap. 1–6"
Momento: Este desafio revisa a opressão e o chamado: parteiras, cesto, nome, sinais, Faraó e a promessa do Senhor.
Texto: "Depois, Moisés e Arão foram até Faraó e lhe disseram: Assim diz o Senhor, Deus de Israel: Deixe ir o meu povo, para que me celebre uma festividade no deserto. Mas Faraó respondeu: Quem é o Senhor para que eu ouça a sua voz e deixe Israel partir? Não conheço o Senhor e não deixarei Israel ir. …"
Destaque: Libertar — Deus ouve o clamor e chama para tirar Israel do Egito.

8. scene_exc-07-piolhos-e-moscas.jpg — "Piolhos e moscas" (Êxodo 8:16–21) · bloco "Pragas · cap. 7–11"
Momento: Arão fere o pó e nascem piolhos; os magos falham e confessam o dedo de Deus. Depois vêm moscas, e Gósen é separada.
Texto: "Disse o Senhor a Moisés: Diga a Arão: Estenda sua vara e fira o pó da terra, para que se torne em piolhos por toda a terra do Egito. Fizeram assim; Arão estendeu a mão com sua vara e feriu o pó da terra, e surgiram muitos piolhos nos homens e no gado; todo o pó da terra se transformou em piolhos …"
Destaque: Dedo de Deus — Confissão dos magos: o sinal ultrapassa suas artes.

9. scene_exc-08-a-saraiva-anunciada.jpg — "A saraiva anunciada" (Êxodo 9:13–18) · bloco "Pragas · cap. 7–11"
Momento: O Senhor anuncia saraiva sem igual. Quem teme a palavra recolhe gado e servos; quem ignora deixa tudo no campo.
Texto: "Então o Senhor disse a Moisés: Levanta-te de manhã cedo e apresenta-te a Faraó, e diga-lhe: Assim diz o Senhor, o Deus dos hebreus: Deixa ir o meu povo, para que me sirva. Porque desta vez enviarei todas as minhas pragas sobre o teu coração, sobre os teus oficiais e sobre o teu povo, para que …"
Destaque: Temia — Oficiais que temem a palavra do Senhor agem e buscam refúgio.

10. scene_exc-09-trevas-espessas.jpg — "Trevas espessas" (Êxodo 10:21–26) · bloco "Pragas · cap. 7–11"
Momento: Trevas cobrem o Egito; em Israel há luz. Faraó tenta negociar e depois manda Moisés sair.
Texto: "Então o Senhor disse a Moisés: Estende a mão para o céu, e virão trevas sobre a terra do Egito, trevas que se podem tocar. Moisés estendeu a mão para o céu, e houve trevas espessas sobre toda a terra do Egito por três dias. Não se viam uns aos outros, e ninguém se levantou do seu lugar por três …"
Destaque: Trevas — Escuridão espessa que se pode tocar, enquanto Israel tem luz.

11. scene_exc-10-mais-uma-praga.jpg — "Mais uma praga" (Êxodo 11:1–7) · bloco "Pragas · cap. 7–11"
Momento: O Senhor anuncia a última praga: os primogênitos morrerão; Israel será distinguido e despedido.
Texto: "Então, o Senhor disse a Moisés: Ainda trarei mais uma praga sobre Faraó e sobre o Egito; então, ele os deixará ir daqui, e quando o fizer, será de forma completa. Fale agora aos ouvidos do povo que todo homem peça ao seu vizinho e toda mulher à sua vizinha, objetos de prata e objetos de ouro. E o …"
Destaque: Distinção — O Senhor separa egípcios e israelitas no julgamento final.

12. scene_exc-boss-2.jpg — "Travessia: Pragas" (Êxodo 11:1–6) · Travessia · bloco "Pragas · cap. 7–11"
Momento: Este desafio revisa as pragas: piolhos e moscas, saraiva, trevas e a última praga dos primogênitos.
Texto: "Então, o Senhor disse a Moisés: Ainda trarei mais uma praga sobre Faraó e sobre o Egito; então, ele os deixará ir daqui, e quando o fizer, será de forma completa. Fale agora aos ouvidos do povo que todo homem peça ao seu vizinho e toda mulher à sua vizinha, objetos de prata e objetos de ouro. E o …"
Destaque: Distinção — O Senhor julga o Egito e guarda o seu povo.

13. scene_exc-11-o-sangue-na-porta.jpg — "O sangue na porta" (Êxodo 12:21–26) · bloco "Libertação · cap. 12–15"
Momento: Moisés ordena imolar a Páscoa e marcar as portas com sangue. O Senhor passa por cima e o povo obedece.
Texto: "Então Moisés convocou todos os anciãos de Israel e lhes disse: Escolham e tomem cordeiros para as suas famílias, e imolem a Páscoa. Então, tome um ramo de hissopo, molhe-o no sangue que está na bacia e marque a verga da porta e suas ombreiras com o sangue que está na bacia; nenhum de vocês saia da …"
Destaque: Sangue — Sinal na porta: o Senhor passa por cima e o Destruidor não entra.

14. scene_exc-12-coluna-de-nuvem-e.jpg — "Coluna de nuvem e fogo" (Êxodo 13:17–22) · bloco "Libertação · cap. 12–15"
Momento: Deus não leva Israel pelo caminho curto dos filisteus. Vai adiante em coluna de nuvem e de fogo.
Texto: "E aconteceu que, quando o faraó deixou o povo ir, Deus não os conduziu pelo caminho da terra dos filisteus, que era mais próxima, pois Deus disse: "Para que o povo não desanime ao ver a guerra e retorne ao Egito." Mas Deus fez com que o povo rodeasse o caminho pelo deserto em direção ao mar …"
Destaque: Coluna — Presença do Senhor que guia de dia e ilumina de noite.

15. scene_exc-13-presos-entre-o-mar.jpg — "Presos entre o mar" (Êxodo 14:1–6) · bloco "Libertação · cap. 12–15"
Momento: O Senhor manda acampar junto ao mar. Faraó persegue; o povo teme e pergunta se não havia sepulcros no Egito.
Texto: "O Senhor disse a Moisés: Diga aos filhos de Israel que retrocedam e acampem defronte de Pi-Hairote, entre Migdol e o mar, diante de Baal-Zefom; em frente dele vos acampareis junto ao mar. Então Faraó dirá dos filhos de Israel: Estão desorientados na terra; o deserto os encerrou. Endurecerei o …"
Destaque: Temeram — O medo diante dos egípcios antes de ver a salvação no mar.

16. scene_exc-14-cantarei-ao-senhor.jpg — "Cantarei ao Senhor" (Êxodo 15:1–6) · bloco "Libertação · cap. 12–15"
Momento: Depois do mar Vermelho, Moisés e Israel entoam um cântico: o Senhor triunfou e salvou o seu povo.
Texto: "Então, Moisés e os filhos de Israel entoaram este cântico ao Senhor, e disseram: Cantarei ao Senhor, porque triunfou gloriosamente; lançou no mar o cavalo e o seu cavaleiro. O Senhor é a minha força e o meu cântico; Ele me foi por salvação; este é o meu Deus; portanto, eu o louvarei; Ele é o Deus …"
Destaque: Cantarei — Resposta de louvor: Israel canta porque o Senhor triunfou e salvou.

17. scene_exc-boss-3.jpg — "Travessia: Libertação" (Êxodo 12:21–28) · Travessia · bloco "Libertação · cap. 12–15"
Momento: Esta Travessia revisa o sangue na porta, a coluna, o medo no mar e o cântico ao Senhor.
Texto: "Então Moisés convocou todos os anciãos de Israel e lhes disse: Escolham e tomem cordeiros para as suas famílias, e imolem a Páscoa. Então, tome um ramo de hissopo, molhe-o no sangue que está na bacia e marque a verga da porta e suas ombreiras com o sangue que está na bacia; nenhum de vocês saia da …"
Destaque: Libertação — O Senhor liberta pelo sangue, guia e salva no mar; o povo canta.

18. scene_exc-15-pao-do-ceu.jpg — "Pão do céu" (Êxodo 16:11–16) · bloco "Deserto até Sinai · cap. 16–20"
Momento: No deserto, o povo murmura. O Senhor promete carne à tarde e pão de manhã, e ensina a colher o bastante.
Texto: "E o Senhor falou a Moisés, dizendo: Ouvi as queixas dos filhos de Israel; diga-lhes: Ao entardecer comerão carne, e pela manhã se fartarão de pão; e saberão que eu sou o Senhor, seu Deus. E aconteceu que, à tarde, subiram codornizes e cobriram o arraial; pela manhã, havia orvalho ao redor do …"
Destaque: Pão — O pão que o Senhor dá no deserto: cada um colhe o que pode comer.

19. scene_exc-16-agua-da-rocha.jpg — "Água da rocha" (Êxodo 17:1–6) · bloco "Deserto até Sinai · cap. 16–20"
Momento: Em Refidim não havia água. O povo contende com Moisés; o Senhor manda ferir a rocha em Horebe.
Texto: "Toda a comunidade dos filhos de Israel partiu do deserto de Sin, segundo o mandamento do SENHOR, e acamparam-se em Refidim; entretanto, não havia ali água para o povo beber. Então o povo contendeu com Moisés e disse: Dê-nos água para beber. Moisés lhes respondeu: Por que contendeis comigo? Por que …"
Destaque: Rocha — O Senhor dá água da rocha mesmo quando o povo pergunta se Ele está no meio deles.

20. scene_exc-17-jetro-aconselha.jpg — "Jetro aconselha" (Êxodo 18:13–18) · bloco "Deserto até Sinai · cap. 16–20"
Momento: Moisés julga o povo sozinho o dia inteiro. Jetro, seu sogro, vê o peso e aconselha partilhar a carga.
Texto: "E aconteceu que, no dia seguinte, Moisés se assentou para julgar o povo; e o povo ficou em pé diante de Moisés desde a manhã até ao pôr do sol. Vendo, assim, o sogro de Moisés tudo o que ele fazia ao povo, disse: "Que é isto que você está fazendo ao povo? Por que você se assenta sozinho, enquanto …"
Destaque: Aconselhar — Jetro oferece conselho sábio para Moisés não carregar tudo sozinho.

21. scene_exc-18-preparai-o-povo.jpg — "Preparai o povo" (Êxodo 19:10–15) · bloco "Deserto até Sinai · cap. 16–20"
Momento: Antes de o Senhor descer no Sinai, Moisés deve preparar o povo: lavar vestes, limites e temor.
Texto: "Disse também o Senhor a Moisés: Vá ao povo e purifique-os hoje e amanhã, e que lavem as suas vestes. E estejam prontos para o terceiro dia, pois no terceiro dia o Senhor, à vista de todo o povo, descerá sobre o monte Sinai. E você marcará limites ao redor do povo, dizendo: Cuidem para não subir ao …"
Destaque: Preparai — O encontro com o Senhor pede povo pronto, limpo e respeitoso dos limites.

22. scene_exc-19-as-palavras-do-sinai.jpg — "As palavras do Sinai" (Êxodo 20:7–12) · bloco "Deserto até Sinai · cap. 16–20"
Momento: No Sinai, o Senhor fala palavras que guardam o seu nome, o sábado e o amor concreto ao próximo.
Texto: "Não tomarás o nome do Senhor, teu Deus, em vão, pois o Senhor não considerará inocente aquele que tomar o seu nome em vão. Lembre-se do dia de sábado, para santificá-lo. Seis dias trabalharás e farás toda a tua obra. Mas o sétimo dia é o sábado do Senhor, teu Deus; não farás nenhum trabalho nem tu, …"
Destaque: Palavras — Mandamentos que protegem o nome de Deus, o descanso e o próximo.

23. scene_exc-boss-4.jpg — "Travessia: Deserto até Sinai" (Êxodo 16:11–16) · Travessia · bloco "Deserto até Sinai · cap. 16–20"
Momento: Esta Travessia revisa o pão do céu, a água da rocha, o conselho de Jetro, o preparo do Sinai e as palavras da lei.
Texto: "E o Senhor falou a Moisés, dizendo: Ouvi as queixas dos filhos de Israel; diga-lhes: Ao entardecer comerão carne, e pela manhã se fartarão de pão; e saberão que eu sou o Senhor, seu Deus. E aconteceu que, à tarde, subiram codornizes e cobriram o arraial; pela manhã, havia orvalho ao redor do …"
Destaque: Sustento — O Senhor sustenta no deserto e fala no monte.

24. scene_exc-20-servo-e-liberdade.jpg — "Servo e liberdade" (Êxodo 21:1–6) · bloco "Aliança e justiça · cap. 21–24"
Momento: Depois da lei, vêm estatutos: o escravo hebreu serve seis anos e no sétimo sai livre; há também regras para a escrava.
Texto: "Estes são os estatutos que você lhes proporá. Se você comprar um escravo hebreu, ele servirá por seis anos; mas, no sétimo ano, ele sairá livre sem custo algum. Se entrou solteiro, sairá sozinho; se era casado, sua esposa sairá com ele. Se o seu senhor lhe der uma mulher, e ela lhe der à luz filhos …"
Destaque: Livre — No sétimo ano o escravo hebreu sai livre, sem custo.

25. scene_exc-21-o-estrangeiro-e-a.jpg — "O estrangeiro e a viúva" (Êxodo 22:21–27) · bloco "Aliança e justiça · cap. 21–24"
Momento: A lei protege forasteiro, viúva e órfão. O Senhor ouve o clamor do fraco e cuida da veste do pobre.
Texto: "Não afligirás nem oprimirás o forasteiro, pois vocês foram forasteiros na terra do Egito. A viúva e o órfão não afligirás. Se de alguma forma os afligires e eles clamarem a mim, eu certamente ouvirei o clamor deles; E a minha ira se acenderá, e vos matarei à espada; e as vossas mulheres ficarão …"
Destaque: Clamor — O grito do aflito que o Senhor certamente ouve.

26. scene_exc-22-nao-seguir-a-multidao.jpg — "Não seguir a multidão" (Êxodo 23:1–6) · bloco "Aliança e justiça · cap. 21–24"
Momento: A lei exige justiça limpa: não seguir a multidão no mal, não torcer o direito, nem odiar o inimigo no caminho.
Texto: "Não espalharemos rumores falsos, nem uniremos nossas mãos com o ímpio para sermos testemunhas desonestas. Não seguirás a multidão para praticar o mal; nem numa demanda perverterás o direito, inclinando-te para a maioria. Não serás parcial em favor do pobre em sua causa. Se encontrares o boi ou o …"
Destaque: Multidão — A maioria não justifica o mal nem a perversão do direito.

27. scene_exc-23-sangue-da-alianca.jpg — "Sangue da aliança" (Êxodo 24:3–8) · bloco "Aliança e justiça · cap. 21–24"
Momento: O povo promete fazer tudo. Moisés asperge o sangue da aliança; depois sobem e veem a Deus, e comem e bebem.
Texto: "Moisés veio e relatou ao povo todas as palavras do Senhor e todos os estatutos; então, todo o povo respondeu em uníssono: "Faremos tudo o que o Senhor disse." Moisés escreveu todas as palavras do SENHOR e, levantando-se de madrugada, erigiu um altar ao pé do monte, e doze colunas, conforme as doze …"
Destaque: Aliança — Pacto selado com sangue entre o Senhor e o povo.

28. scene_exc-boss-5.jpg — "Travessia: Aliança e justiça" (Êxodo 21:1–6) · Travessia · bloco "Aliança e justiça · cap. 21–24"
Momento: Esta Travessia revisa a dignidade do servo, a proteção do fraco, a justiça limpa e o sangue da aliança.
Texto: "Estes são os estatutos que você lhes proporá. Se você comprar um escravo hebreu, ele servirá por seis anos; mas, no sétimo ano, ele sairá livre sem custo algum. Se entrou solteiro, sairá sozinho; se era casado, sua esposa sairá com ele. Se o seu senhor lhe der uma mulher, e ela lhe der à luz filhos …"
Destaque: Aliança — Pacto que pede justiça e se sela com sangue.

29. scene_exc-24-o-propiciatorio.jpg — "O propiciatório" (Êxodo 25:17–22) · bloco "O santuário · cap. 25–31"
Momento: Deus manda fazer o propiciatório de ouro com querubins. Ali, sobre a arca, Ele promete encontrar-se com Moisés.
Texto: "Farás também um propiciatório de ouro puro; seu comprimento será de dois côvados e meio, e sua largura, de um côvado e meio. Fará dois querubins de ouro; de ouro batido os fará nas duas extremidades do propiciatório. Farás um querubim na extremidade de uma parte e o outro na extremidade da outra …"
Destaque: Propiciatório — Tampa da arca onde o Senhor fala, entre os querubins.

30. scene_exc-25-segundo-o-modelo.jpg — "Segundo o modelo" (Êxodo 26:30–35) · bloco "O santuário · cap. 25–31"
Momento: Deus manda levantar o tabernáculo conforme o modelo do monte. O véu separa o Santo Lugar do Santo dos Santos.
Texto: "Levantarás o tabernáculo de acordo com o modelo que te foi mostrado no monte. Farás um véu de estofo azul, e púrpura, e carmesim e linho fino retorcido; com querubins, será feito por obra de artista. E o suspenderás sobre quatro colunas de madeira de acácia, revestidas de ouro; os seus colchetes …"
Destaque: Modelo — Padrão mostrado no monte, que Moisés deve seguir ao levantar o tabernáculo.

31. scene_exc-26-aarao-no-peito.jpg — "Áarão no peito" (Êxodo 28:1–6) · bloco "O santuário · cap. 25–31"
Momento: Deus chama Arão e os filhos ao sacerdócio. Nas pedras do éfode, Arão leva os nomes de Israel diante do Senhor.
Texto: "Depois, você fará com que seu irmão Arão se aproxime juntamente com seus filhos do meio dos filhos de Israel, para me oficiarem como sacerdotes: Arão e seus filhos Nadabe, Abiú, Eleazar e Itamar. Farás vestes sagradas para Arão, teu irmão, para glória e ornamentação. Falarás também a todos os …"
Destaque: Memória — Os nomes de Israel nas pedras, levados por Arão diante do Senhor.

32. scene_exc-27-holocausto-continuo.jpg — "Holocausto contínuo" (Êxodo 29:38–43) · bloco "O santuário · cap. 25–31"
Momento: Cada dia, dois cordeiros no altar. Deus promete encontrar-se ali e habitar no meio de Israel.
Texto: "Este é o que oferecerão sobre o altar: dois cordeiros de um ano, todos os dias, continuamente. Um cordeiro oferecerás pela manhã, e o outro cordeiro oferecerás ao pôr do sol. Com um cordeiro, uma décima parte de um efa de flor de farinha, amassada com um quarto de um hin de azeite batido; e, para a …"
Destaque: Contínuo — O holocausto diário, manhã e tarde, perante o Senhor.

33. scene_exc-28-o-sabado-e-as.jpg — "O sábado e as tábuas" (Êxodo 31:12–18) · bloco "O santuário · cap. 25–31"
Momento: No fim das instruções do santuário, o Senhor liga o sábado à aliança e entrega a Moisés as tábuas escritas a dedo.
Texto: "Disse também o Senhor a Moisés: Você falará aos filhos de Israel, dizendo: Certamente guardareis os meus sábados; pois é um sinal entre mim e vós nas vossas gerações; para que saibam que eu sou o Senhor, que vos santifica. Portanto, vocês guardarão o sábado, pois é santo para vocês; quem o profanar …"
Destaque: Sábado — Sinal entre o Senhor e Israel, aliança perpétua nas gerações.

34. scene_exc-boss-6.jpg — "Travessia: O santuário" (Êxodo 25:17–22) · Travessia · bloco "O santuário · cap. 25–31"
Momento: Esta travessia revisa o santuário: propiciatório, modelo, Arão, culto diário e sábado.
Texto: "Farás também um propiciatório de ouro puro; seu comprimento será de dois côvados e meio, e sua largura, de um côvado e meio. Fará dois querubins de ouro; de ouro batido os fará nas duas extremidades do propiciatório. Farás um querubim na extremidade de uma parte e o outro na extremidade da outra …"
Destaque: Santuário — Deus quer habitar no meio do povo santificado.

35. scene_exc-29-moises-intercede.jpg — "Moisés intercede" (Êxodo 32:7–14) · bloco "Queda e glória · cap. 32–34"
Momento: Enquanto Moisés está no monte, o povo faz um bezerro. Deus fala em consumi-los; Moisés intercede.
Texto: "Então, o Senhor disse a Moisés: Vá, desça; porque o seu povo, que você trouxe do Egito, se corrompeu. Eles rapidamente se desviaram do caminho que eu havia ordenado; fizeram para si um bezerro de fundição, adoraram-no, sacrificaram-lhe e disseram: Estes são os teus deuses, ó Israel, que te tiraram …"
Destaque: Intercede — Moisés suplica ao Senhor e lembra a promessa aos patriarcas.

36. scene_exc-30-mostra-me-a-tua.jpg — "Mostra-me a tua glória" (Êxodo 33:12–23) · bloco "Queda e glória · cap. 32–34"
Momento: Após a queda, Moisés pede que a presença vá com o povo e quer ver a glória do Senhor.
Texto: "Então, Moisés disse ao Senhor: "Eis que me dizes: 'Faz subir este povo, mas não me revelaste a quem enviarás comigo. Contudo, disseste: 'Conheço-te pelo nome e também achaste graça aos meus olhos.'" Agora, pois, se realmente encontrei graça diante de Ti, eu te rogo que me ensines o Teu caminho para …"
Destaque: Glória — Moisés pede ver a glória; o Senhor faz passar sua bondade e proclama o nome.

37. scene_exc-31-novas-tabuas.jpg — "Novas tábuas" (Êxodo 34:1–9) · bloco "Queda e glória · cap. 32–34"
Momento: Moisés sobe de novo com tábuas novas. O Senhor passa e proclama que é compassivo e justo.
Texto: "Então, disse o Senhor a Moisés: "Lavra duas tábuas de pedra, como as primeiras; e eu escreverei nelas as mesmas palavras que estavam nas primeiras tábuas, que você quebrou." E prepare-se para amanhã, para que você suba ao monte Sinai pela manhã e ali se apresente a mim no cume do monte. E ninguém …"
Destaque: Compassivo — O Senhor se proclama compassivo, clemente e grande em misericórdia.

38. scene_exc-32-o-rosto-que-brilha.jpg — "O rosto que brilha" (Êxodo 34:27–35) · bloco "Queda e glória · cap. 32–34"
Momento: Moisés escreve as palavras, fica quarenta dias e desce com o rosto resplandecente; o povo teme.
Texto: "Disse ainda o Senhor a Moisés: Escreve estas palavras, pois é de acordo com o conteúdo delas que fiz aliança contigo e com Israel. E ficou ali com o Senhor quarenta dias e quarenta noites; não comeu pão, nem bebeu água; e escreveu nas tábuas as palavras da aliança, as dez palavras. E aconteceu que, …"
Destaque: Resplandecia — A pele do rosto de Moisés brilhava por ter Deus falado com ele.

39. scene_exc-boss-7.jpg — "Travessia: Queda e glória" (Êxodo 32:7–14) · Travessia · bloco "Queda e glória · cap. 32–34"
Momento: Esta travessia revisa a queda do bezerro, a intercessão, a glória pedida e o rosto que brilha.
Texto: "Então, o Senhor disse a Moisés: Vá, desça; porque o seu povo, que você trouxe do Egito, se corrompeu. Eles rapidamente se desviaram do caminho que eu havia ordenado; fizeram para si um bezerro de fundição, adoraram-no, sacrificaram-lhe e disseram: Estes são os teus deuses, ó Israel, que te tiraram …"
Destaque: Misericórdia — Depois da queda, Deus renova a aliança e mostra a glória.

40. scene_exc-33-coracao-disposto.jpg — "Coração disposto" (Êxodo 35:20–29) · bloco "A obra concluída · cap. 35–40"
Momento: A congregação sai da presença de Moisés. Quem tem o coração movido traz oferta para a obra.
Texto: "Então toda a congregação dos filhos de Israel saiu da presença de Moisés. E todo homem a quem seu coração moveu e todo aquele cujo espírito o impeliu vieram e trouxeram a oferta ao Senhor para a obra da tenda da congregação, para todo o seu serviço e para as vestes sagradas. E todo homem e mulher …"
Destaque: Disposto — Coração que se move a trazer oferta voluntária ao Senhor.

41. scene_exc-34-bastante-oferta.jpg — "Bastante oferta" (Êxodo 36:2–7) · bloco "A obra concluída · cap. 35–40"
Momento: Bezalel e Aoliabe recebem os materiais. O povo traz tanto que Moisés manda parar.
Texto: "E Moisés chamou a Bezalel, a Aoliabe e a todos os homens habilidosos de coração, a quem o SENHOR havia concedido sabedoria; todos aqueles a quem o coração impelia a se aproximar da obra para efetuá-la. Tomaram, então, de diante de Moisés todas as ofertas que os filhos de Israel haviam trazido para …"
Destaque: Suficiente — O material era suficiente para toda a obra e ainda sobejava.

42. scene_exc-35-como-o-senhor-ordenou.jpg — "Como o Senhor ordenou" (Êxodo 39:32–43) · bloco "A obra concluída · cap. 35–40"
Momento: Toda a obra do tabernáculo fica pronta. Trazem a Moisés; ele vê e abençoa.
Texto: "Assim, foi concluída toda a obra do tabernáculo da tenda da congregação; e os filhos de Israel fizeram tudo conforme o que o Senhor tinha ordenado a Moisés; assim o fizeram. Depois trouxeram a Moisés o tabernáculo, a tenda e todos os seus utensílios: os colchetes, as tábuas, as vergas, as colunas e …"
Destaque: Ordenou — Fizeram tudo conforme o Senhor havia ordenado a Moisés.

43. scene_exc-36-a-gloria-enche.jpg — "A glória enche" (Êxodo 40:34–38) · bloco "A obra concluída · cap. 35–40"
Momento: A obra acaba. A nuvem cobre a tenda, e a glória do SENHOR enche o tabernáculo.
Texto: "Então, a nuvem cobriu a tenda da congregação, e a glória do SENHOR encheu o tabernáculo. Moisés não podia entrar na tenda da congregação, pois a nuvem permanecia sobre ela, e a glória do SENHOR enchia o tabernáculo. Sempre que a nuvem se elevava sobre o tabernáculo, os filhos de Israel prosseguiam …"
Destaque: Glória — A glória do SENHOR enche o tabernáculo; a nuvem guia Israel.

44. scene_exc-boss-8.jpg — "Travessia: A obra concluída" (Êxodo 35:20–29) · Travessia · bloco "A obra concluída · cap. 35–40"
Momento: Esta travessia revisa a oferta, a generosidade, a obra pronta e a glória que enche.
Texto: "Então toda a congregação dos filhos de Israel saiu da presença de Moisés. E todo homem a quem seu coração moveu e todo aquele cujo espírito o impeliu vieram e trouxeram a oferta ao Senhor para a obra da tenda da congregação, para todo o seu serviço e para as vestes sagradas. E todo homem e mulher …"
Destaque: Glória — Quando o povo obedece, a glória do Senhor habita no meio.

Gere todas as 44 imagens com foco no ícone do STWAY.
```
