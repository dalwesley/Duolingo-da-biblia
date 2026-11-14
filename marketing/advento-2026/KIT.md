# Advento 2026: kit de divulgação

Campanha: **26 cenas até o Natal**, de 29/11 a 24/12/2026. É presente de lançamento: todos os dias estão abertos sem Plus (`SeasonWalkAccess.giftCampaigns`).

Página: **stway.com.br/advento** (`site/advento/`). O link do Play no botão leva a origem `utm_campaign=advento-2026`. Ela aparece em Aquisição no Firebase Analytics.

O que tem neste kit:
0. [Plano para os nossos canais](#0-plano-para-os-nossos-canais) ← comece aqui
1. [Imagens](#1-imagens)
2. [Calendário de publicação](#2-calendário-de-publicação)
3. [WhatsApp](#3-whatsapp)
4. [Reels e TikTok](#4-reels-e-tiktok)
5. [Push pelo console (FCM)](#5-push-pelo-console-fcm)
6. [Play Store](#6-play-store)
7. [Como medir](#7-como-medir)

---

## 0. Plano para os nossos canais

Situação em 11/11: Instagram do Stway com 31 seguidores, perfil pessoal com 486, cerca de 10 pastores e líderes ao alcance direto e R$ 100 para anúncio.

O que isso significa: o alcance vem de **pessoas, não de perfis**. A ordem de força é:

1. **Os 10 líderes.** Cada "sim" coloca o Advento num grupo de 10 a 50 pessoas, todos os dias, por 26 dias.
2. **O perfil pessoal (486).** As pessoas confiam em quem conhecem. Um post contando por que você criou o app converte mais do que qualquer arte.
3. **O Instagram do Stway (31).** Funciona como vitrine: quem ouvir falar e for procurar encontra as artes. Não é canal de alcance agora.
4. **R$ 100.** Serve para testar uma mensagem, não para crescer. Gastar no fim (ver abaixo).

### Meta realista

| | Conta |
|---|---|
| 10 líderes contatados → 3 topam × ~20 pessoas no grupo × ~40% instalam | ~25 pessoas |
| Perfil pessoal: 486 × ~3% | ~15 pessoas |
| Anúncio de R$ 100 | 10 a 40 pessoas |
| **Total** | **~50 a 80 pessoas no Advento** |

É pouco em número e suficiente para o que importa agora: **medir o D7 de verdade** pelo Funil. Se 3 líderes toparem e os grupos deles seguirem caminhando, você tem a prova para levar a 30 líderes em janeiro.

### Os líderes (o mais importante)

- **Não mande só texto.** Ligue ou mande um **áudio de 40 segundos** no WhatsApp. Texto frio de desconhecido é ignorado; a voz de alguém que o pastor conhece, não. Roteiro do áudio:

  > "Pastor [nome], tudo bem? Aqui é o [seu nome]. Eu criei um app de estudo bíblico, o Stway, e neste Advento ele está de graça: uma cena de 5 minutos por dia até o Natal, da Criação até Jesus. Queria te oferecer para a igreja. Eu mesmo te mando todo dia a imagem e o texto prontos, você só encaminha no grupo. Te mando o link para dar uma olhada?"

- Depois do áudio, mande a **mensagem 3c** com o link.
- O pedido concreto é **"você encaminha a mensagem do dia no grupo"**. Isso é fácil de aceitar e faz o Advento aparecer 26 vezes no grupo.
- **Todo dia às 6h**, mande para cada líder que topou a imagem `story/dia-NN.png` e o texto do dia em `marketing/out/advento-2026/whatsapp-diario.md`. Use uma **lista de transmissão** no WhatsApp com esses líderes: uma mensagem só chega a todos.
- Meta: **3 de 10 topam.** Se tiverem 5 minutos, mostre o app no seu celular.

### O perfil pessoal (486)

Post no **feed pessoal** em 22/11 com o `anuncio-feed.png` e este texto, que você pode ajustar com a sua história:

```text
Nos últimos meses eu construí um app.

Ele nasceu de uma frustração minha: eu lia a Bíblia, mas não sabia ler a Bíblia. Passava os olhos e fechava. Então criei o Stway, onde cada dia é uma cena curta de 5 minutos e você responde no próprio versículo, como quem estuda de verdade.

Neste Advento ele está de graça: 26 cenas, de 29/11 até a véspera do Natal, da Criação até Jesus.

Se você quiser caminhar comigo até o Natal, o link está aqui: stway.com.br/advento

E se puder compartilhar com alguém, ajuda demais um projeto que está só começando. 🙏
```

Depois, todo dia, **reposte nos seus stories** o story do dia que o Stway publicar.

### Os R$ 100

- **Não gaste antes de 27/11.** Primeiro veja qual post orgânico teve mais reações: o pessoal ou o anúncio do Stway.
- De **27/11 a 3/12**, impulsione **esse post** a cerca de R$ 15 por dia durante 6 a 7 dias.
- **Público:** Brasil, 18–45 anos, interesses Bíblia, Cristianismo e igreja evangélica. Pelo Gerenciador de Anúncios (não pelo botão "Turbinar"), limite os dispositivos a **Android**, porque no iPhone ainda não há app.
- **Destino:** stway.com.br/advento. Objetivo: tráfego.
- O que medir: quantos instalaram (Funil, contas novas de 27/11 a 3/12) e o custo por pessoa. Isso diz se anúncio vale a pena quando o orçamento for maior.

### Calendário simplificado (uma pessoa só)

| Quando | O quê | Onde |
|---|---|---|
| 19–21/11 | Áudio + mensagem 3c para os 10 líderes | WhatsApp |
| 22/11 | Post pessoal (texto acima) + `anuncio-feed` no Stway + mensagem 3a nos seus grupos | Instagram, WhatsApp |
| 24/11 | Acompanhamento com quem não respondeu | WhatsApp |
| 27/11 | Começa o anúncio de R$ 100 | Instagram |
| 28/11 | `anuncio-story`: "começa amanhã" | stories, status |
| 29/11 a 24/12, 6h | Story do dia no Stway + repost pessoal + lista de transmissão para os líderes | Instagram, WhatsApp |
| seg, qua e sex | Feed do dia + legenda (`legendas.md`) | Instagram do Stway |
| domingos | Reels de resumo (opcional) | Reels |

Feed **3 vezes por semana**, não todo dia: com 31 seguidores, o esforço diário de feed não se paga. O story diário e o WhatsApp, sim.

---

## 1. Imagens

Gere com:

```bash
python3 marketing/tools/advento_cards.py          # tudo
python3 marketing/tools/advento_cards.py --day 3  # só um dia
```

A saída fica em `marketing/out/advento-2026/`, fora do git:

| Arquivo | Uso |
|---|---|
| `anuncio-story.png` / `anuncio-feed.png` | convite antes do dia 1 |
| `story/dia-NN.png` (1080×1920) | stories, status do WhatsApp |
| `feed/dia-NN.png` (1080×1350) | feed do Instagram/Facebook |
| `legendas.md` | legenda pronta de cada dia |

Os textos de cada dia (título, versículo, reflexão e pergunta) ficam em `marketing/advento-2026/dias.json`. O versículo sai da Almeida do app (JFAAL), então a citação é igual à do Stway. Se o roteiro do app mudar (`season_walk_catalog.dart`), atualize o JSON e gere de novo.

## 2. Calendário de publicação

| Quando | O quê | Onde |
|---|---|---|
| 22/11 (dom) | `anuncio-feed.png` + legenda de convite (abaixo) | feed + story |
| 22–28/11 | Mensagem 3a no grupo da igreja ou célula; mensagem 3c para 5 a 10 líderes | WhatsApp |
| 26/11 (qui) | Reels "a pintura que se revela" com o dia 1 | Reels/TikTok |
| 28/11 (sáb) | `anuncio-story.png`: "começa amanhã" | story + status |
| 29/11 a 24/12, todo dia às 6h | `story/dia-NN.png` | story + status |
| todo dia às 12h | `feed/dia-NN.png` + legenda do dia | feed |
| 06/12, 13/12, 20/12 (domingos) | Reels de resumo da semana (4 postais em sequência) | Reels/TikTok |
| 24/12 | Story do dia 26 + "Feliz Natal, obrigado por caminhar com a gente" | story |

Todo dia: responda os comentários com a pergunta do dia. Comentário gera alcance.

Legenda de convite (22/11):

```text
26 cenas até o Natal.

De 29 de novembro a 24 de dezembro, uma cena bíblica de 5 minutos por dia: da Criação à promessa cumprida em Jesus. Você lê o texto, responde no próprio versículo e guarda o postal de cada dia.

Grátis no Stway. Link na bio (stway.com.br/advento).

Marque quem vai caminhar com você 👇

#advento #natal #biblia #estudobiblico #devocional
```

## 3. WhatsApp

**3a. Grupo da igreja ou célula**

```text
Gente, vamos fazer o Advento juntos este ano? 🎄

São 26 cenas curtas da Bíblia, uma por dia, de 29/11 até a véspera do Natal. Leva uns 5 minutos: você lê o texto e responde no próprio versículo.

É de graça, no app Stway: stway.com.br/advento

Quem topar responde aqui com um 🙋 e a gente comenta a cena do dia no grupo.
```

**3b. Amigo ou família (1 a 1)**

```text
Oi! Vou fazer um Advento diferente este ano: uma cena da Bíblia por dia até o Natal, 5 minutinhos. Quer fazer comigo? A gente pode caminhar junto no app.

stway.com.br/advento
```

**3c. Pastor ou líder de célula (contato frio, curto)**

```text
Olá, pastor(a) [nome]! Sou o [seu nome], criei o Stway, um app brasileiro de estudo bíblico em cenas de 5 minutos.

Neste Advento estamos oferecendo grátis 26 cenas, de 29/11 a 24/12, da Criação até Jesus. Pensei que pode servir para a [igreja/célula] caminhar junta no fim do ano.

Dá uma olhada: stway.com.br/advento

Se fizer sentido, eu te mando todo dia, às 6h, a imagem e o texto da cena prontos. O senhor(a) só encaminha no grupo da igreja. Sem custo nenhum.
```

Acompanhamento três dias depois, se a pessoa não respondeu:

```text
Pastor(a), só para não se perder: o Advento começa domingo (29/11). Se quiser, mando a imagem do convite pronta para o grupo da igreja. 🙏
```

**3d. Status do WhatsApp:** poste o `story/dia-NN.png` do dia, sem texto. A imagem já tem tudo.

## 4. Reels e TikTok

**"O postal que se revela" (15 s, vertical)**

1. 0–2 s: gravação de tela do app na cena do dia 1, com a pintura velada. Texto na tela: *"Uma cena por dia até o Natal"*.
2. 2–9 s: dois ou três toques respondendo no versículo (acelerado 1,5x).
3. 9–13 s: o postal se revelando (a animação do app). Texto: *"Cada dia vira um postal"*.
4. 13–15 s: `anuncio-story.png`. Texto: *"Grátis · link na bio"*.

Áudio: instrumental natalino calmo da biblioteca do Instagram. Grave no aparelho em tema escuro.

**Resumo da semana (domingos):** quatro `story/dia-NN.png` da semana, 2 s cada, mais o texto *"Você caminhou com a gente? A semana que vem começa amanhã."*

## 5. Push pelo console (FCM)

O app já avisa no dia 1 (`notifWalkStartsTitle`/`Body`). Para reforçar, mande pelo console do Firebase (Messaging → nova campanha), para todo mundo:

| Quando | Título | Texto |
|---|---|---|
| 28/11, 19h | O Advento começa amanhã | 26 cenas até o Natal, uma por dia. Amanhã: "O Verbo se fez carne". |
| 06/12, 18h | Uma semana de Advento | Já são 8 postais na caminhada. Faltou algum? Ainda dá para pôr em dia. |
| 20/12, 18h | Última semana do Advento | Hoje, a Cruz; amanhã, a Ressurreição. A promessa se cumpre esta semana. |
| 24/12, 9h | Véspera de Natal | A última cena do Advento está aberta. Feliz Natal! |

Use no máximo uma por semana fora do aviso automático. Notificação demais leva à desinstalação.

## 6. Play Store

**Conteúdo promocional** (Play Console → Crescimento → Conteúdo promocional → Oferta/Evento):

- Nome: `Advento: 26 cenas até o Natal`
- Período: 29/11/2026 a 24/12/2026
- Descrição curta: `Uma cena bíblica de 5 minutos por dia até o Natal. Grátis.`
- Imagem: `anuncio-feed.png` (recorte 16:9 se o console pedir)

**"Novidades" da próxima versão:**

```text
Advento 2026: 26 cenas até o Natal, de presente para todo mundo. Uma por dia, de 29/11 a 24/12. Cada cena vira um postal no seu álbum.
```

## 7. Como medir

- **Painel → Funil**, com "Desde" em 22/11: contas novas por dia, 1ª cena e D1/D7. Compare a semana de 22/11 com as anteriores.
- **Analytics → Aquisição:** `utm_campaign = advento-2026` mostra quem veio pela página.
- Pergunte no onboarding ou no grupo "como conheceu?" se ficar dúvida sobre o canal. Indicação no WhatsApp não aparece em nenhum painel.

Meta honesta para a campanha: **sair de dezembro com um D7 medido em pelo menos 50 pessoas** e saber qual canal trouxe quem ficou. O número de downloads importa menos.
