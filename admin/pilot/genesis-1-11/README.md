# Piloto V3 — `genesis-1-11`

Banco de perguntas e estudos reescrito para a trilha Gênesis 1–11 no formato V3 ([SPEC_V3.md](SPEC_V3.md)).
**Nada aqui está publicado.** O banco atual (`trilha_app/assets/data/genesis_questions.json` e o Firestore) continua intacto.

## O que muda em relação ao banco atual

| Problema do banco atual | Como o V3 resolve |
|---|---|
| Perguntas escritas numa tradução, palco mostrando outra (JFAAL) | Todo texto bíblico é JFAAL exata; o validador confere palavra por palavra |
| Toque era sempre uma lacuna, igual ao Completar | Toque usa `find_in_text`: o aluno toca no versículo inteiro (o app já suporta, sem mudança de código) |
| Conectar ligava o versículo a uma paráfrase dele mesmo | Compreensão e Interpretação ligam a um texto bíblico real |
| Mesmas palavras e peças repetidas nos três modos | Cada modo tem uma tarefa mental diferente; o validador bloqueia repetição de resposta e de peça |
| V/F com cerca de 70% de "Verdadeiro" | Equilíbrio fixado em 21 de 42 |
| Distratores de modelo pronto | Distratores de Interpretação vêm de leituras erradas reais, registradas no estudo |
| Estudo raso | Estudo com fatos, termos-chave, estrutura, relações, textos cruzados e leituras erradas |

## Arquivos

- `cenas/<slug>.json` — uma cena por arquivo (`study` + `questions`). É aqui que se edita
- `studies_v3.json`, `questions_v3.json` — gerados por `node admin/scripts/merge_pilot_v3.mjs`
- `SPEC_V3.md` — regras (também serve de prompt para gerar outras trilhas)

## Validar

```bash
node admin/scripts/validate_pilot_v3.mjs
node admin/scripts/merge_pilot_v3.mjs
node admin/scripts/validate_bank.mjs admin/pilot/genesis-1-11/questions_v3.json
```

## Como revisar (equipe)

Para cada cena, abrir `cenas/<slug>.json` e conferir:

1. **Fidelidade:** a resposta certa se defende só pelo texto?
2. **Teologia:** nada toma lado onde tradições cristãs divergem (dias da criação, extensão do dilúvio etc.)? Os textos cruzados do Novo Testamento são ligações legítimas?
3. **Distratores:** plausíveis para quem leu rápido, nunca absurdos?
4. **Modo:** Observação pede fato; Compreensão pede relação; Interpretação pede sentido?
5. **Tom:** claro, respeitoso, sem jargão?

Anotar ajustes por `id` de pergunta.

## Campos novos (o app atual ignora sem quebrar)

`evidenceSpan` (trecho que prova a resposta), `hint` (dica em texto) e, no estudo, `passages`, `facts`, `keyTerms`, `structure`, `relations`, `crossRefs`, `misreadings`, `anchorQuestion`. Passam a ter efeito quando o app for atualizado para lê-los.

## Publicar (só depois da revisão)

1. Exportar o banco atual do Firestore como backup
2. Substituir as perguntas `genesis-1-11` e os estudos `gen-*` pelas versões V3
3. Rodar o seed com confirmação explícita
