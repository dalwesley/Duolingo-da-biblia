# Frase "Hoje" de cada cena

A frase "Hoje" é o que a pessoa leva da cena. Ela aparece no fim da cena ("Hoje: …"), no selo da coleção, na Bíblia ("Você esteve aqui"), no card de story e na retrospectiva do ano. Precisa funcionar sozinha, fora da cena, meses depois.

Campo no banco: `centralInsight` da missão em `content_trails` (e `trails.json`). Tradução: `assets/l10n/content/trails_{en,es}.json`, chave `missions.<slug>.centralInsight`.

## Regras

1. Afirmação, nunca pergunta. Sem reticências, sem ponto final.
2. Entre 20 e 70 caracteres; nunca mais de 80. Uma ideia só.
3. Sai do texto da cena (`ref`), não de doutrina geral. Quem fez a cena reconhece a frase.
4. Teste da troca: se a frase serve igual em outra cena da mesma trilha, está genérica. Reescreva.
5. Voz direta, no presente. Pode falar de Deus ("Deus ouve quem chora no deserto") ou de mim ("Posso descansar porque Deus terminou a obra"). Evite "nós", "a igreja deve" e ordens moralistas ("Seja…", "Você precisa…").
6. Palavras que um adolescente entende. Termos do próprio texto (aliança, redenção, graça) valem quando a cena é sobre eles.
7. Nunca comece com "Este texto", "Esta missão", "Aprendemos que", "Deus nos ensina que", "A cena mostra".
8. Nomes próprios ancoram cenas narrativas ("Rute escolhe o Deus de Noemi"), mas a frase ainda precisa tocar a vida de quem lê.
9. Nada de frase repetida na mesma trilha. Evite três frases seguidas começando com "Deus".
10. Desafio e Revisão (`type: boss`) resumem o bloco ou a trilha inteira.
11. Fé evangélica ampla. Em tema disputado entre denominações (batismo, dons, escatologia), fique no que o texto afirma.
12. Mantenha a frase atual quando ela já cumpre todas as regras.

## Tradução

- `en`: inglês natural, mesmo peso e tamanho, sem traduzir palavra por palavra.
- `es`: espanhol latino neutro (usted só se o texto pedir; prefira formas impessoais ou "yo").
- Nomes bíblicos na forma usual de cada língua (Rute → Ruth / Rut; Noemi → Naomi / Noemí).

## Exemplos

Boas:
- Deus é o centro, não eu
- Deus traz ordem ao caos
- Fui libertado para pertencer
- Deus quer o coração, não só a veste
- A perda pode fazer Deus parecer adversário
- Redenção pede quem aceite o custo

Ruins:
- "O que isso revela sobre a aliança de Deus?" — pergunta, serve para qualquer cena
- "Este texto chama a igreja a viver a fé recebida de Deus…" — genérica e longa
- "O luto da cidade é concreto" — fato solto, a pessoa não leva nada
- "A vontade de Deus é santidade com corpo honrado e irmão respeitado" — longa, duas ideias

## Formato da resposta

Um JSON com um objeto por cena, na ordem dos pacotes:

```json
[
  { "slug": "rute-04-asas", "pt": "Meu refúgio é debaixo das asas de Deus", "en": "My refuge is under God's wings", "es": "Mi refugio está bajo las alas de Dios", "fonte": "nova" }
]
```

`fonte`: `mantida` (frase atual da missão), `estudo` (frase do estudo V3, talvez ajustada) ou `nova`.
