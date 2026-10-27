#!/usr/bin/env python3
"""Banco próprio: conhecer-a-deus.json (5×18=90)."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _gen_entry_motives import pack18, write_bank

P_GN1 = (
    "No princípio, Deus criou os céus e a terra. A terra era sem forma e vazia; "
    "havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre as águas. "
    "Disse Deus: Haja luz. E houve luz."
)
P_EX3 = (
    "Disse Moisés a Deus: Eis que quando eu for aos filhos de Israel e lhes disser: "
    "O Deus de vossos pais me enviou a vós; e eles me perguntarem: Qual é o seu nome? "
    "Que lhes direi? E Deus disse a Moisés: EU SOU O QUE SOU. Disse mais: Assim dirás "
    "aos filhos de Israel: EU SOU me enviou a vós."
)
P_IS6 = (
    "No ano em que morreu o rei Uzias, eu vi o Senhor assentado sobre um alto e sublime trono, "
    "e as abas de suas vestes enchiam o templo. Serafins estavam por cima dele. "
    "E clamavam uns para os outros, dizendo: Santo, santo, santo é o SENHOR dos Exércitos; "
    "toda a terra está repleta da sua glória."
)
P_SL23 = (
    "O Senhor é o meu pastor; nada me faltará. Ele me faz repousar em pastos verdejantes; "
    "leva-me para junto das águas de descanso. Refrigera-me a alma."
)
P_JO1 = (
    "No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus. "
    "E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade, "
    "e vimos a sua glória, glória como do unigênito do Pai."
)


def conhecer():
    trail = "conhecer-a-deus"
    q = []

    q += pack18(
        trail,
        "entrada-deus-01",
        "Gênesis 1:1–3",
        ["Gênesis 1:1", "Gênesis 1:3"],
        P_GN1,
        "Ver que conhecer a Deus começa por ele, não por nós.",
        "Deus vem antes de tudo",
        {
            "semente": {
                "tf": (True, "No princípio, Deus criou os céus e a terra.", "Gênesis 1:1 diz exatamente isso."),
                "tap": (
                    "princípio", "abismo", "luz",
                    "No ___, Deus criou os céus e a terra",
                    'Em Gênesis 1:1, toque a palavra que falta em "No ___, Deus criou"?',
                    "Exato: No princípio.",
                    ("Abismo aparece no v.2.", "Luz vem no v.3."),
                ),
                "choice": (
                    "Quem age no primeiro verso da Bíblia?",
                    (("a", "Deus"), ("b", "O homem"), ("c", "A terra vazia"), ("d", "As águas")),
                    "a",
                    "Certo: Deus criou.",
                    {"b": "O homem ainda não aparece.", "c": "A terra é criada, não criadora.", "d": "As águas são cenário do v.2."},
                ),
                "order": (
                    "Qual a ordem dos fatos em Gênesis 1:1–3?",
                    ["Deus criou os céus e a terra", "O Espírito pairava sobre as águas", "Disse Deus: Haja luz"],
                    "Certo: criação → Espírito → luz.",
                ),
                "complete": (
                    "luz", "terra", "abismo",
                    "Haja ___. E houve luz",
                    'Complete: "Haja ___".',
                    "Certo: luz.",
                    ("Terra já foi nomeada no v.1.", "Abismo é do v.2."),
                ),
                "connect": (
                    "O que Gênesis 1:1 comunica que se liga a este contexto?",
                    (("a", "Deus primeiro"), ("b", "Homem no centro"), ("c", "Mundo eterno")),
                    "a",
                    "Certo: a história começa em Deus.",
                    {"b": "O verso não começa conosco.", "c": "O mundo é criado."},
                    {"ref": "Gênesis 1:1", "text": "No princípio, Deus criou os céus e a terra."},
                ),
            },
            "caminhada": {
                "tf": (False, "Gênesis 1:1 começa falando do homem e de suas necessidades.", "Começa com Deus criando."),
                "tap": (
                    "criou", "pairava", "trevas",
                    "Deus ___ os céus e a terra",
                    'Em Gênesis 1:1, toque a palavra que falta em "Deus ___ os céus e a terra"?',
                    "Exato: criou.",
                    ("Pairava descreve o Espírito.", "Trevas é do v.2."),
                ),
                "choice": (
                    "Por que Gênesis 1:1 importa para quem quer conhecer a Deus?",
                    (
                        ("a", "Porque o conhecer começa nele, não em nós"),
                        ("b", "Porque prova que o homem cria o sentido"),
                        ("c", "Porque a terra já existia sem Deus"),
                        ("d", "Porque a luz é mais importante que o Criador"),
                    ),
                    "a",
                    "Certo: o ponto de partida é Deus.",
                    {"b": "O verso põe Deus no início.", "c": "Ele cria a terra.", "d": "A luz responde à palavra dele."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Gênesis 1:1–3?",
                    ["Deus cria no princípio", "A terra está sem forma", "A palavra de Deus traz luz"],
                    "Certo: cria → vazio → luz.",
                ),
                "complete": (
                    "Espírito", "homem", "templo",
                    "o ___ de Deus pairava sobre as águas",
                    'Complete: "o ___ de Deus pairava".',
                    "Certo: Espírito.",
                    ("Homem ainda não foi criado.", "Templo não está aqui."),
                ),
                "connect": (
                    "O que Gênesis 1:1–3 comunica que se liga a este contexto?",
                    (("a", "Início em Deus"), ("b", "Autossuficiência humana"), ("c", "Criação sem palavra")),
                    "a",
                    "Certo: conhecer começa no Criador.",
                    {"b": "O texto não centra o homem.", "c": "A luz vem pela palavra."},
                    {"ref": "Gênesis 1:3", "text": "Disse Deus: Haja luz. E houve luz."},
                ),
            },
            "profundezas": {
                "tf": (True, "Conhecer a Deus, segundo Gênesis 1, começa reconhecendo que ele já age antes de nós.", "Ele cria no princípio — antes de qualquer resposta humana."),
                "tap": (
                    "vazia", "luz", "céus",
                    "A terra era sem forma e ___",
                    'Em Gênesis 1:2, toque a palavra que falta em "sem forma e ___"?',
                    "Exato: vazia.",
                    ("Luz é do v.3.", "Céus é do v.1."),
                ),
                "choice": (
                    "Qual implicação de Gênesis 1:1–3 para a fé?",
                    (
                        ("a", "Deus não é projeção nossa: ele fala e o mundo responde"),
                        ("b", "A criação prova que Deus depende do homem"),
                        ("c", "A luz existe sem a palavra de Deus"),
                        ("d", "Conhecer a Deus começa pelo eu interior"),
                    ),
                    "a",
                    "Certo: a palavra dele ordena o real.",
                    {"b": "Ele cria; não depende.", "c": "Houve luz porque ele disse.", "d": "O texto começa nele."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Gênesis 1:1–3?",
                    ["Deus é o sujeito da criação", "O caos não tem a última palavra", "A palavra dele gera luz"],
                    "Certo: sujeito → caos sob domínio → luz.",
                ),
                "complete": (
                    "Deus", "Adão", "Israel",
                    "No princípio, ___ criou",
                    'Complete: "No princípio, ___ criou".',
                    "Certo: Deus.",
                    ("Adão vem depois na narrativa.", "Israel ainda não existe."),
                ),
                "connect": (
                    "O que Gênesis 1:1 comunica que se liga a este contexto?",
                    (("a", "Prioridade de Deus"), ("b", "Prioridade do eu"), ("c", "Mundo sem origem")),
                    "a",
                    "Certo: Deus vem antes.",
                    {"b": "O verso não começa no eu.", "c": "Há criação com origem nele."},
                    {"ref": "Gênesis 1:1", "text": "No princípio, Deus criou os céus e a terra."},
                ),
            },
        },
    )

    q += pack18(
        trail,
        "entrada-deus-02",
        "Êxodo 3:13–14",
        ["Êxodo 3:13", "Êxodo 3:14"],
        P_EX3,
        "Entender o que o nome EU SOU revela sobre Deus.",
        "Deus se dá a conhecer pelo nome",
        {
            "semente": {
                "tf": (True, "Deus disse a Moisés: EU SOU O QUE SOU.", "Êxodo 3:14 registra essa resposta."),
                "tap": (
                    "nome", "Israel", "pais",
                    "Qual é o seu ___",
                    'Em Êxodo 3:13, toque a palavra que falta em "Qual é o seu ___"?',
                    "Exato: nome.",
                    ("Israel é o povo.", "Pais aparece na frase anterior."),
                ),
                "choice": (
                    "Quando Moisés pergunta o nome, o que Deus responde?",
                    (("a", "EU SOU O QUE SOU"), ("b", "Um deus entre muitos"), ("c", "Um nome secreto inútil"), ("d", "O nome de Moisés")),
                    "a",
                    "Certo: EU SOU O QUE SOU.",
                    {"b": "Não é um deus entre muitos.", "c": "O nome é revelado para ser dito.", "d": "A resposta é sobre Deus."},
                ),
                "order": (
                    "Qual a ordem dos fatos em Êxodo 3:13–14?",
                    ["Moisés pergunta qual é o nome", "Deus responde: EU SOU O QUE SOU", "Moisés deve dizer: EU SOU me enviou"],
                    "Certo: pergunta → revelação → envio.",
                ),
                "complete": (
                    "enviou", "criou", "pastos",
                    "EU SOU me ___ a vós",
                    'Complete: "EU SOU me ___ a vós".',
                    "Certo: enviou.",
                    ("Criou é linguagem de Gênesis.", "Pastos é do Salmo 23."),
                ),
                "connect": (
                    "O que Êxodo 3:14 comunica que se liga a este contexto?",
                    (("a", "Nome revelado"), ("b", "Nome inventado por Moisés"), ("c", "Deus sem identidade")),
                    "a",
                    "Certo: Deus se dá a conhecer.",
                    {"b": "Quem fala é Deus.", "c": "Há nome e envio."},
                    {"ref": "Êxodo 3:14", "text": "EU SOU O QUE SOU."},
                ),
            },
            "caminhada": {
                "tf": (False, "Em Êxodo 3, Deus se recusa a dizer qualquer nome a Moisés.", "Ele revela: EU SOU O QUE SOU."),
                "tap": (
                    "SOU", "Uzias", "Verbo",
                    "EU ___ O QUE SOU",
                    'Em Êxodo 3:14, toque a palavra que falta em "EU ___ O QUE SOU"?',
                    "Exato: SOU.",
                    ("Uzias é de Isaías 6.", "Verbo é de João 1."),
                ),
                "choice": (
                    "O que o nome EU SOU ensina sobre conhecer a Deus?",
                    (
                        ("a", "Ele se define por si mesmo, sem depender de outro"),
                        ("b", "Ele muda de nome conforme o povo pede"),
                        ("c", "Ele só existe enquanto Israel crê"),
                        ("d", "O nome é só um código militar"),
                    ),
                    "a",
                    "Certo: identidade soberana.",
                    {"b": "A revelação é estável.", "c": "Ele envia; não depende da fé para existir.", "d": "É revelação teológica, não só código."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Êxodo 3:13–14?",
                    ["A dúvida sobre o nome", "A revelação do EU SOU", "A missão de anunciar esse nome"],
                    "Certo: dúvida → revelação → anúncio.",
                ),
                "complete": (
                    "Moisés", "Abraão", "Davi",
                    "Deus disse a ___",
                    'Complete: "Deus disse a ___".',
                    "Certo: Moisés.",
                    ("Abraão não é o interlocutor aqui.", "Davi tampouco."),
                ),
                "connect": (
                    "O que Êxodo 3:13–14 comunica que se liga a este contexto?",
                    (("a", "Deus se apresenta"), ("b", "Moisés inventa Deus"), ("c", "Nome irrelevante")),
                    "a",
                    "Certo: Deus se apresenta pelo nome.",
                    {"b": "Deus fala; Moisés ouve.", "c": "O nome é central na cena."},
                    {"ref": "Êxodo 3:14", "text": "Assim dirás aos filhos de Israel: EU SOU me enviou a vós."},
                ),
            },
            "profundezas": {
                "tf": (True, "O nome revelado a Moisés mostra um Deus que é em si mesmo e que se dá a conhecer para enviar.", "EU SOU e o envio caminham juntos."),
                "tap": (
                    "filhos", "serafins", "pastos",
                    "Assim dirás aos ___ de Israel",
                    'Em Êxodo 3:14, toque a palavra que falta em "aos ___ de Israel"?',
                    "Exato: filhos.",
                    ("Serafins é de Isaías 6.", "Pastos é do Salmo 23."),
                ),
                "choice": (
                    "Qual implicação do EU SOU para quem busca conhecer a Deus?",
                    (
                        ("a", "Não o reduzimos a uma função nossa: ele se revela e envia"),
                        ("b", "Podemos moldar Deus ao nosso desejo"),
                        ("c", "Conhecer a Deus dispensa a revelação"),
                        ("d", "O nome serve só para magia"),
                    ),
                    "a",
                    "Certo: revelação e missão.",
                    {"b": "Ele se define.", "c": "A cena é revelação.", "d": "Não é magia."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Êxodo 3:13–14?",
                    ["O povo precisará de um nome", "Deus revela quem ele é", "Esse nome autoriza o envio"],
                    "Certo: necessidade → revelação → autoridade.",
                ),
                "complete": (
                    "EU SOU", "Uzias", "Verbo",
                    "___ O QUE SOU",
                    'Complete o nome: "___ O QUE SOU".',
                    "Certo: EU SOU.",
                    ("Uzias é de Isaías.", "Verbo é de João."),
                ),
                "connect": (
                    "O que Êxodo 3:14 comunica que se liga a este contexto?",
                    (("a", "Identidade que envia"), ("b", "Anonimato divino"), ("c", "Nome humano de Deus")),
                    "a",
                    "Certo: o que ele é autoriza o envio.",
                    {"b": "Há nome revelado.", "c": "O nome vem de Deus."},
                    {"ref": "Êxodo 3:14", "text": "EU SOU O QUE SOU."},
                ),
            },
        },
    )

    q += pack18(
        trail,
        "entrada-deus-03",
        "Isaías 6:1–3",
        ["Isaías 6:1", "Isaías 6:3"],
        P_IS6,
        "Ver por que a santidade de Deus muda quem se aproxima dele.",
        "Deus é santo",
        {
            "semente": {
                "tf": (True, "Os serafins clamam: Santo, santo, santo é o SENHOR dos Exércitos.", "Isaías 6:3 traz o tríplice santo."),
                "tap": (
                    "Santo", "Uzias", "templo",
                    "___, santo, santo é o SENHOR",
                    'Em Isaías 6:3, toque a palavra que falta em "___, santo, santo"?',
                    "Exato: Santo.",
                    ("Uzias marca o ano da visão.", "Templo é o lugar enchido pelas vestes."),
                ),
                "choice": (
                    "Em Isaías 6:1–3, o que enche a terra?",
                    (("a", "A glória do SENHOR"), ("b", "O trono de Uzias"), ("c", "O medo de Isaías só"), ("d", "A fumaça sem Deus")),
                    "a",
                    "Certo: a terra repleta da glória dele.",
                    {"b": "Uzias morreu; o trono visto é do Senhor.", "c": "O clamor é sobre a glória.", "d": "O centro é o SENHOR."},
                ),
                "order": (
                    "Qual a ordem dos fatos em Isaías 6:1–3?",
                    ["Isaías vê o Senhor no trono", "Serafins estão por cima", "Clamam: Santo, santo, santo"],
                    "Certo: visão → serafins → clamor.",
                ),
                "complete": (
                    "glória", "abismo", "pão",
                    "toda a terra está repleta da sua ___",
                    'Complete: "repleta da sua ___".',
                    "Certo: glória.",
                    ("Abismo é de Gênesis.", "Pão é de Mateus 6."),
                ),
                "connect": (
                    "O que Isaías 6:3 comunica que se liga a este contexto?",
                    (("a", "Santidade de Deus"), ("b", "Santidade de Uzias"), ("c", "Deus comum")),
                    "a",
                    "Certo: Deus é santo.",
                    {"b": "Uzias morreu; o Santo é o SENHOR.", "c": "O tríplice santo nega o comum."},
                    {"ref": "Isaías 6:3", "text": "Santo, santo, santo é o SENHOR dos Exércitos."},
                ),
            },
            "caminhada": {
                "tf": (False, "Em Isaías 6, a santidade de Deus o torna igual a qualquer rei humano.", "Ele está num alto e sublime trono; os serafins proclamam sua santidade."),
                "tap": (
                    "trono", "luz", "Verbo",
                    "assentado sobre um alto e sublime ___",
                    'Em Isaías 6:1, toque a palavra que falta em "sublime ___"?',
                    "Exato: trono.",
                    ("Luz é de Gênesis.", "Verbo é de João."),
                ),
                "choice": (
                    "Por que a visão de Isaías 6 importa para conhecer a Deus?",
                    (
                        ("a", "Porque revela um Deus separado em santidade, não uma versão maior de nós"),
                        ("b", "Porque prova que Deus precisa do templo humano"),
                        ("c", "Porque Uzias é o verdadeiro Santo"),
                        ("d", "Porque a glória fica só no céu e nunca toca a terra"),
                    ),
                    "a",
                    "Certo: santidade que separa e revela.",
                    {"b": "As vestes enchiam o templo; Deus não depende dele.", "c": "Uzias morreu.", "d": "A terra está repleta da glória."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Isaías 6:1–3?",
                    ["Morte de Uzias e visão do Senhor", "Serafins sobre o trono", "Proclamação da santidade e da glória"],
                    "Certo: visão → seres → proclamação.",
                ),
                "complete": (
                    "Exércitos", "Israel", "Moisés",
                    "SENHOR dos ___",
                    'Complete: "SENHOR dos ___".',
                    "Certo: Exércitos.",
                    ("Israel é o povo.", "Moisés não está no clamor."),
                ),
                "connect": (
                    "O que Isaías 6:1–3 comunica que se liga a este contexto?",
                    (("a", "Deus incomparável"), ("b", "Deus doméstico"), ("c", "Trono vazio")),
                    "a",
                    "Certo: santo e incomparável.",
                    {"b": "O tríplice santo impede reduzir Deus.", "c": "Há trono ocupado."},
                    {"ref": "Isaías 6:1", "text": "eu vi o Senhor assentado sobre um alto e sublime trono."},
                ),
            },
            "profundezas": {
                "tf": (True, "A santidade proclamada em Isaías 6 mostra que aproximar-se de Deus não é tratá-lo como igual: ele é outro em pureza e glória.", "Santo, santo, santo marca a diferença."),
                "tap": (
                    "repleta", "vazia", "penúria",
                    "toda a terra está ___ da sua glória",
                    'Em Isaías 6:3, toque a palavra que falta em "está ___ da sua glória"?',
                    "Exato: repleta.",
                    ("Vazia é de Gênesis 1.", "Penúria é de Filipenses."),
                ),
                "choice": (
                    "Qual implicação da santidade de Isaías 6 para o discípulo?",
                    (
                        ("a", "Conhecer a Deus inclui reverência: ele não é extensão do meu ego"),
                        ("b", "Posso negociar a santidade dele"),
                        ("c", "A glória dele nunca encontra a terra"),
                        ("d", "Serafins substituem o SENHOR"),
                    ),
                    "a",
                    "Certo: reverência diante do Santo.",
                    {"b": "A santidade não se negocia.", "c": "A terra está repleta.", "d": "Eles proclamam o SENHOR."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Isaías 6:1–3?",
                    ["O rei humano morre", "O Rei santo é visto", "A terra é declarada cheia de glória"],
                    "Certo: rei cai → Santo permanece → glória na terra.",
                ),
                "complete": (
                    "Santo", "pastor", "pão",
                    "___, santo, santo",
                    'Complete o clamor: "___, santo, santo".',
                    "Certo: Santo.",
                    ("Pastor é do Salmo 23.", "Pão é de Mateus 6."),
                ),
                "connect": (
                    "O que Isaías 6:3 comunica que se liga a este contexto?",
                    (("a", "Separação santa"), ("b", "Familiaridade irreverente"), ("c", "Glória privada")),
                    "a",
                    "Certo: santidade que separa e revela.",
                    {"b": "O clamor não autoriza irreverência.", "c": "A glória enche a terra."},
                    {"ref": "Isaías 6:3", "text": "toda a terra está repleta da sua glória."},
                ),
            },
        },
    )

    q += pack18(
        trail,
        "entrada-deus-04",
        "Salmo 23:1–3",
        ["Salmo 23:1", "Salmo 23:2"],
        P_SL23,
        "Ligar a santidade de Deus ao cuidado dele no dia a dia.",
        "O santo cuida de perto",
        {
            "semente": {
                "tf": (True, "O Senhor é o meu pastor; nada me faltará.", "Salmo 23:1 afirma isso."),
                "tap": (
                    "pastor", "glória", "serafins",
                    "O Senhor é o meu ___",
                    'Em Salmo 23:1, toque a palavra que falta em "meu ___"?',
                    "Exato: pastor.",
                    ("Glória é de Isaías 6.", "Serafins também."),
                ),
                "choice": (
                    "No Salmo 23, como o Senhor cuida?",
                    (("a", "Como pastor que faz repousar e conduz às águas"), ("b", "Só como juiz distante"), ("c", "Sem se aproximar"), ("d", "Apenas no templo de Isaías")),
                    "a",
                    "Certo: pastor próximo.",
                    {"b": "O tom é cuidado.", "c": "Ele conduz de perto.", "d": "Aqui a imagem é pastor."},
                ),
                "order": (
                    "Qual a ordem dos fatos no Salmo 23:1–3?",
                    ["O Senhor é pastor", "Repouso em pastos verdejantes", "Águas de descanso e refrigério"],
                    "Certo: pastor → pastos → águas.",
                ),
                "complete": (
                    "faltará", "Uzias", "Verbo",
                    "nada me ___",
                    'Complete: "nada me ___".',
                    "Certo: faltará.",
                    ("Uzias é de Isaías.", "Verbo é de João."),
                ),
                "connect": (
                    "O que Salmo 23:1 comunica que se liga a este contexto?",
                    (("a", "Cuidado próximo"), ("b", "Santidade fria"), ("c", "Deus ausente")),
                    "a",
                    "Certo: o santo também pastoreia.",
                    {"b": "O salmo mostra proximidade.", "c": "Há pastor presente."},
                    {"ref": "Salmo 23:1", "text": "O Senhor é o meu pastor; nada me faltará."},
                ),
            },
            "caminhada": {
                "tf": (False, "O Salmo 23 apresenta um Deus santo que se recusa a cuidar de perto.", "Ele pastoreia, faz repousar e refrigera a alma."),
                "tap": (
                    "verdejantes", "Exércitos", "carne",
                    "pastos ___",
                    'Em Salmo 23:2, toque a palavra que falta em "pastos ___"?',
                    "Exato: verdejantes.",
                    ("Exércitos é de Isaías 6.", "Carne é de João 1."),
                ),
                "choice": (
                    "Como o Salmo 23 completa a visão de Isaías 6 nesta trilha?",
                    (
                        ("a", "O Deus santo também se aproxima como pastor"),
                        ("b", "A santidade cancela qualquer cuidado"),
                        ("c", "Só há glória, nunca pastoreio"),
                        ("d", "O pastor substitui o Santo"),
                    ),
                    "a",
                    "Certo: santo e próximo.",
                    {"b": "O salmo é cuidado.", "c": "Há pastoreio explícito.", "d": "É o mesmo Senhor."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Salmo 23:1–3?",
                    ["Confissão do pastor", "Repouso guiado", "Refrigério da alma"],
                    "Certo: confissão → repouso → refrigério.",
                ),
                "complete": (
                    "descanso", "trono", "nome",
                    "águas de ___",
                    'Complete: "águas de ___".',
                    "Certo: descanso.",
                    ("Trono é de Isaías 6.", "Nome é de Êxodo 3."),
                ),
                "connect": (
                    "O que Salmo 23:1–3 comunica que se liga a este contexto?",
                    (("a", "Santidade acolhedora"), ("b", "Distância absoluta"), ("c", "Cuidado sem Deus")),
                    "a",
                    "Certo: o santo acolhe como pastor.",
                    {"b": "Há proximidade.", "c": "O Senhor é o pastor."},
                    {"ref": "Salmo 23:2", "text": "Ele me faz repousar em pastos verdejantes."},
                ),
            },
            "profundezas": {
                "tf": (True, "Conhecer a Deus une Isaías e o Salmo 23: o Santo também pastoreia de perto.", "Santidade e cuidado não se excluem."),
                "tap": (
                    "alma", "glória", "luz",
                    "Refrigera-me a ___",
                    'Em Salmo 23:3, toque a palavra que falta em "a ___"?',
                    "Exato: alma.",
                    ("Glória é de Isaías.", "Luz é de Gênesis."),
                ),
                "choice": (
                    "Qual leitura une santidade e pastoreio nesta cena?",
                    (
                        ("a", "Posso reverenciar o Santo e confiar no Pastor ao mesmo tempo"),
                        ("b", "Se ele é santo, não pode cuidar"),
                        ("c", "Se ele pastoreia, não é santo"),
                        ("d", "O cuidado substitui o conhecimento de Deus"),
                    ),
                    "a",
                    "Certo: reverência e confiança juntas.",
                    {"b": "O salmo mostra cuidado.", "c": "É o Senhor quem pastoreia.", "d": "O cuidado é parte de conhecê-lo."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Salmo 23:1–3 nesta trilha?",
                    ["Reconhecer o Senhor", "Receber o pastoreio dele", "Descansar sob cuidado santo"],
                    "Certo: reconhecer → pastoreio → descanso.",
                ),
                "complete": (
                    "Senhor", "Uzias", "serpente",
                    "O ___ é o meu pastor",
                    'Complete: "O ___ é o meu pastor".',
                    "Certo: Senhor.",
                    ("Uzias é rei humano.", "Serpente é da queda."),
                ),
                "connect": (
                    "O que Salmo 23 comunica que se liga a este contexto?",
                    (("a", "Proximidade santa"), ("b", "Santidade sem rosto"), ("c", "Pastor sem Senhor")),
                    "a",
                    "Certo: o Santo tem rosto de pastor.",
                    {"b": "Há relação pessoal.", "c": "O pastor é o Senhor."},
                    {"ref": "Salmo 23:1–3", "text": "O Senhor é o meu pastor… Refrigera-me a alma."},
                ),
            },
        },
    )

    q += pack18(
        trail,
        "entrada-deus-05",
        "João 1:1,14",
        ["João 1:1", "João 1:14"],
        P_JO1,
        "Ver em Jesus a forma mais clara de conhecer a Deus.",
        "Em Jesus, Deus se aproximou",
        {
            "semente": {
                "tf": (True, "O Verbo se fez carne e habitou entre nós.", "João 1:14 afirma a encarnação."),
                "tap": (
                    "carne", "pastos", "serafins",
                    "o Verbo se fez ___",
                    'Em João 1:14, toque a palavra que falta em "se fez ___"?',
                    "Exato: carne.",
                    ("Pastos é do Salmo 23.", "Serafins é de Isaías 6."),
                ),
                "choice": (
                    "Segundo João 1:1, quem era o Verbo?",
                    (("a", "Deus"), ("b", "Apenas uma ideia"), ("c", "Só um profeta posterior"), ("d", "A criação sem pessoa")),
                    "a",
                    "Certo: o Verbo era Deus.",
                    {"b": "O texto diz que era Deus.", "c": "Ele estava no princípio.", "d": "O Verbo é pessoal."},
                ),
                "order": (
                    "Qual a ordem das ideias em João 1:1,14?",
                    ["No princípio era o Verbo", "O Verbo era Deus", "O Verbo se fez carne e habitou entre nós"],
                    "Certo: princípio → deidade → encarnação.",
                ),
                "complete": (
                    "graça", "penúria", "Uzias",
                    "cheio de ___ e de verdade",
                    'Complete: "cheio de ___ e de verdade".',
                    "Certo: graça.",
                    ("Penúria é de Filipenses.", "Uzias é de Isaías."),
                ),
                "connect": (
                    "O que João 1:14 comunica que se liga a este contexto?",
                    (("a", "Deus perto em Jesus"), ("b", "Deus só distante"), ("c", "Verbo sem carne")),
                    "a",
                    "Certo: Deus se aproximou em Jesus.",
                    {"b": "Ele habitou entre nós.", "c": "Fez-se carne."},
                    {"ref": "João 1:14", "text": "E o Verbo se fez carne e habitou entre nós."},
                ),
            },
            "caminhada": {
                "tf": (False, "João 1 ensina que o Verbo nunca se aproximou da história humana.", "Ele se fez carne e habitou entre nós."),
                "tap": (
                    "habitou", "criou", "pairava",
                    "e ___ entre nós",
                    'Em João 1:14, toque a palavra que falta em "e ___ entre nós"?',
                    "Exato: habitou.",
                    ("Criou é de Gênesis.", "Pairava também."),
                ),
                "choice": (
                    "Como João 1 liga o início de Gênesis ao conhecimento de Deus?",
                    (
                        ("a", "O mesmo \"no princípio\" agora revela o Verbo feito carne"),
                        ("b", "João cancela Gênesis"),
                        ("c", "A criação substitui Jesus"),
                        ("d", "Conhecer a Deus dispensa o Verbo"),
                    ),
                    "a",
                    "Certo: eco de Gênesis na encarnação.",
                    {"b": "Há continuidade.", "c": "O Verbo é Deus e se encarna.", "d": "Jesus é a revelação clara."},
                ),
                "order": (
                    "Como se encadeiam os eventos de João 1:1,14?",
                    ["O Verbo no princípio com Deus", "O Verbo era Deus", "O Verbo habita entre nós em carne"],
                    "Certo: eternidade → deidade → proximidade.",
                ),
                "complete": (
                    "glória", "ansiedade", "celeiros",
                    "vimos a sua ___",
                    'Complete: "vimos a sua ___".',
                    "Certo: glória.",
                    ("Ansiedade é de Mateus 6.", "Celeiros também."),
                ),
                "connect": (
                    "O que João 1 comunica que se liga a este contexto?",
                    (("a", "Revelação em carne"), ("b", "Deus sem rosto"), ("c", "Só lei sem presença")),
                    "a",
                    "Certo: conhecer a Deus em Jesus.",
                    {"b": "Vimos a glória.", "c": "Há habitação entre nós."},
                    {"ref": "João 1:14", "text": "vimos a sua glória, glória como do unigênito do Pai."},
                ),
            },
            "profundezas": {
                "tf": (True, "João 1 apresenta Jesus como o modo decisivo de conhecer a Deus: o Verbo eterno veio habitar entre nós.", "Princípio divino + encarnação = revelação clara."),
                "tap": (
                    "Verbo", "pastor", "serafim",
                    "No princípio era o ___",
                    'Em João 1:1, toque a palavra que falta em "era o ___"?',
                    "Exato: Verbo.",
                    ("Pastor é do Salmo 23.", "Serafim é de Isaías."),
                ),
                "choice": (
                    "Qual implicação de João 1:1,14 para quem quer conhecer a Deus?",
                    (
                        ("a", "Olhar para Jesus é encontrar o Deus que se aproximou"),
                        ("b", "Deus permanece só no princípio, sem história"),
                        ("c", "A carne impede qualquer revelação"),
                        ("d", "Graça e verdade se excluem"),
                    ),
                    "a",
                    "Certo: Jesus é a aproximação de Deus.",
                    {"b": "Ele habitou entre nós.", "c": "A carne é o meio da revelação.", "d": "Ele é cheio de ambas."},
                ),
                "order": (
                    "Qual sequência revela o sentido de João 1:1,14?",
                    ["O Verbo eterno", "A identificação com Deus", "A habitação entre nós"],
                    "Certo: eterno → Deus → conosco.",
                ),
                "complete": (
                    "Deus", "Uzias", "Moisés",
                    "e o Verbo era ___",
                    'Complete: "e o Verbo era ___".',
                    "Certo: Deus.",
                    ("Uzias é rei humano.", "Moisés recebeu o nome; aqui o Verbo é Deus."),
                ),
                "connect": (
                    "O que João 1:14 comunica que se liga a este contexto?",
                    (("a", "Encontro em Jesus"), ("b", "Deus inacessível para sempre"), ("c", "Verbo só abstrato")),
                    "a",
                    "Certo: o encontro se dá em Jesus.",
                    {"b": "Ele habitou entre nós.", "c": "Fez-se carne."},
                    {"ref": "João 1:1,14", "text": "o Verbo era Deus… o Verbo se fez carne."},
                ),
            },
        },
    )
    return q


if __name__ == "__main__":
    write_bank("conhecer-a-deus", conhecer())
