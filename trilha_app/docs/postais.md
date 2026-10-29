# Postais da caminhada

Status: proposta (28 out 2026). Houve um protótipo visual em HTML (trilha de Rute), já removido.

## A ideia

Cada cena concluída vira um postal: a pintura da cena, a referência, a frase "Hoje" e o carimbo do dia. Os postais formam um álbum por trilha, ficam marcados na Bíblia no versículo da cena e, no fim do ano, viram a retrospectiva.

Frase de venda: *Cada passo vira um postal. Cada postal fica na sua Bíblia. No fim do ano, a sua história com Deus.*

O momento que se quer provocar: meses depois, a pessoa abre Rute 1 e encontra "Você esteve aqui em 12 de outubro. Hoje: Ficar também é fé".

## Nome

O glossário (`design_language.md`) reserva **selo** para os selos de personagem (`CharacterSeal`, cera de lacre). Para não dar dois sentidos à mesma palavra, a peça nova se chama **postal**: o peregrino manda um postal de cada lugar por onde passa. O verso do postal é onde entra a linha pessoal, e o card de compartilhar já é um postal.

Glossário a acrescentar: `postal / postcard / postal`. O selo postal picotado e o carimbo são só desenho do postal, não nomes.

## Tudo sai de dados que já existem

| Peça do postal | Fonte |
|---|---|
| Cena concluída e data | `ProgressService.missionCompletedOn[slug]` (YYYY-MM-DD) |
| Pintura | `TrailArt.ofScene(trail, slug)`; 456 de 459 cenas têm pintura própria |
| Frase "Hoje" | `Mission.localizedCentralInsight` (`content_trails` + overlays EN/ES) |
| Referência | `MissionStudy.passageRef`; sem estudo em cache, `Mission.hookRef` |
| Linha pessoal | `ProgressService.bibleNotes` no primeiro versículo da referência (nota que já existe na Bíblia) |

O postal tem registro próprio no progresso (doc privado): `postcardsOn[slug]` (dia da revelação) e `postcardRefs[slug]` ("Rute 1:16"). Não usa `missionCompletedOn` porque "Sair da trilha" apaga as datas da trilha, e o postal nunca some. `ProgressService.sceneRevealed(slug)` diz se a pintura já aparece sem véu (postal, ou cena feita antes dos postais).

## Pré-requisito de conteúdo

O postal depende de uma frase "Hoje" boa. Em 28 out 2026, 347 das 459 cenas tinham uma frase fraca no `centralInsight` (155 com "O que isso revela sobre a aliança de Deus?"). As frases novas, em pt/en/es, estão em `admin/v3/_hoje/` (guia em `GUIA.md`). Revisar e publicar antes de construir as telas.

## Peças

### 1. Revelar (fim da cena), grátis

- Antes de concluída, a pintura da cena aparece velada (desfoque, sem cor) no mapa da trilha e nos cards de cena. A cena atual também, para a revelação ser o prêmio.
- Momento em tela cheia (`showPostcardReveal`, `widgets/postcard.dart`), aberto pela `CelebrationScreen` 2,6 s depois da contagem, antes dos outros momentos (sequência, fim de trilha). O postal chega velado; tocar nele ou em "Revelar o postal" clareia a pintura, pousa o carimbo do dia (háptica + som) e sobe a frase "Hoje". O Anan fica ao lado e comemora no carimbo.
- Depois: "Ver na minha Bíblia" e "Compartilhar" entram com as peças 3 e 5.
- Véu: decode da pintura em 36 px de largura + tom apagado (`SceneArtImage`, `sceneVeilFilter`), sem blur por frame. Vale no mapa da trilha, nas folhas de prévia e do Plus e no card da Hoje.
- Refazer uma cena já concluída não revela de novo; o postal mantém a data da primeira vez.

### 2. Álbum, grátis

- Terceira gaveta do Cofre no Perfil: Medalhas | Selos | Postais (`PostcardAlbum`, `widgets/postcard_album.dart`). Só no perfil próprio: os postais moram no doc privado, então a Caravana não os mostra e a gaveta não tem olho de privacidade.
- Um álbum por trilha, a do postal mais recente primeiro: título, "3 de 9" e uma fileira horizontal com todas as cenas em ordem. Revelados com a pintura; os que faltam velados, com "?".
- Tocar num postal abre o mesmo palco da revelação, já revelado e carimbado (`showPostcardDetail`): a data no lugar de "Novo postal", o Anan com a frase "Hoje" e "Refazer a cena".
- Cena feita antes dos postais entra já revelada, com o dia em que foi feita (`missionCompletedOn`); sem o postal gravado, a referência vem do `hookRef` quando ele é referência.

### 3. Na Bíblia, grátis

- `BibleReaderScreen` monta o índice (`PostcardIndex.build`, `data/postcard_index.dart`): (livro, capítulo) → postais, a partir de `postcardRefs` e, para cena feita antes dos postais, do `hookRef` do catálogo. Referência só de capítulo ("Mateus 6") não marca.
- Os versículos do postal ganham sublinhado dourado discreto; o primeiro leva o selinho (`PostcardPin`) antes do número. Tocar no selinho abre o postal (`showPostcardDetail`) com "Você esteve aqui" acima do título; tocar no versículo continua abrindo as ações de sempre.
- Nunca some, mesmo sem Plus. A Bíblia é grátis.
- Falta: a nota da pessoa naquele versículo dentro do postal aberto pela Bíblia.

### 4. Compartilhar: imagem grátis, postal animado no Peregrino+

- Botão "Compartilhar" no palco do postal (revelação, álbum e Bíblia) abre a escolha: "Postal animado" (Peregrino+; sem Plus leva o cadeado e abre o paywall `postcard_video`) ou "Imagem".
- Card 9:16 (`PostcardShareCard`, `widgets/postcard_share.dart`): um postal de verdade, frente e verso. A frente é a pintura em papel de foto; o verso, por cima, traz a frase "Hoje" escrita, o selo com o carimbo e "Para: você / De: {nome}". No topo, "Postal 4 de 7 · Rute"; o Anan espia pelo canto; rodapé "Um postal da minha caminhada".
- O mesmo widget anima por `t` (0 → 1): a imagem é o quadro final; o vídeo (`PostcardVideo.render`) anda `t` quadro a quadro, captura e manda ao encoder nativo pelo canal `stway/video` (Android: MediaCodec + MediaMuxer, RGBA → YUV em 4 threads, `PostcardVideoEncoder.kt`; iOS: AVAssetWriter em `AppDelegate.swift`). 6 s, 24 fps, 720×1280, ~1 MB. No Redmi Note 8 (2019) leva ~13 s em profile, com o Anan e barra de progresso na tela. Se o vídeo falhar, avisa e manda a imagem.
- Por que não a pintura de fundo em tela cheia: as pinturas têm 640 px (3:2 ou faixas mais largas); esticar até 9:16 borrava e cortava a cena.
- Prévia no aparelho, com botões de imagem e vídeo: `flutter run --profile -d <device> -t tool/postcard_preview.dart`.

### 5. Retrospectiva, Peregrino+

- Abre a partir de Remote Config `year_review_from` (YYYY-MM-DD) com pelo menos 3 postais no ano: porta no topo da gaveta Postais. No Laboratório Peregrino+ há "Abrir retrospectiva do ano" para testar fora de dezembro.
- Stories (`YearReviewScreen`, dados em `data/year_review.dart`): capa grátis (Anan, "Sua caminhada em 2026", total de postais e dias); no Plus, leque dos 3 postais mais recentes com o primeiro e o último, o livro com mais postais e o modo com mais acerto de primeira; fechamento com o Anan. Sem Plus, o meio vira um slide velado com "Conhecer o Peregrino+" (paywall `year_review`).
- `PlusPerk` da retrospectiva só entra no paywall quando ela abrir (Apple 2.1).

### 6. Caderno da caminhada, depois

- PDF com os postais do ano e as linhas pessoais, para imprimir ou presentear. Peregrino+.

## Peregrino+

Grátis cria o hábito e espalha o app: revelar, álbum, marca na Bíblia, card simples. O Plus fica com o que é acabamento: card com a pintura inteira e a linha pessoal, a retrospectiva completa e o caderno. A nota no versículo já é grátis hoje, então a linha pessoal continua grátis na Bíblia; o Plus só a leva para o card.

Regra da Apple 2.1: o paywall só lista o que já funciona. `PlusPerk.postcards` entra quando o card Plus estiver no ar; `PlusPerk.yearReview` só em dezembro.

## Ordem

1. Frases "Hoje": revisar, publicar no Firestore e nos overlays.
2. Revelar + registro do postal + pinturas veladas. Feito em 28 out 2026 (sem commit).
3. Álbum no Cofre. Feito em 28 out 2026 (sem commit).
4. Marca na Bíblia. Feita em 28 out 2026 (sem commit).
5. Card de compartilhar com a camada Plus. Feito em 28 out 2026 (sem commit).
6. Retrospectiva. Feita em 28 out 2026 (sem commit); ligar `year_review_from` em dezembro.

## Medir

`postal_reveal`, `postal_album_open`, `postal_bible_open` (de onde veio), `postal_share` (`tier: free|plus`), `retro_view`, `retro_share`. A pergunta: quem revela postais volta mais no D7 e compartilha mais?

## Riscos

- As pinturas são faixas 3:1; o postal recorta o centro em 4:3. Revisar as cenas com personagem na borda e, se preciso, guardar um `focusX` por cena.
- Velar a pintura no mapa tira um convite visual. Testar com metade dos usuários (Remote Config `postal_veil`).
- Cenas sem estudo publicado não têm `passageRef`; usar `hookRef`, e quando nenhum dos dois for uma referência válida, o postal não marca a Bíblia.
