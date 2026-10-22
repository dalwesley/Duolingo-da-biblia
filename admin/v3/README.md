# Banco V3 gerado por modelo

Pipeline para levar as trilhas da V2 para a V3 com um modelo de linguagem (OpenAI ou Anthropic). As regras são as do piloto escrito à mão: [SPEC_V3.md](../pilot/genesis-1-11/SPEC_V3.md). As cenas de Gênesis 1–11 servem de exemplo no prompt.

Cada trilha tem uma pasta `admin/v3/<trilha>/`:

| Pasta / arquivo | O que é |
|---|---|
| `inputs/<cena>.json` | pacote da cena: dados de `trails.json`, pistas da V2 e os versos da JFAAL, um a um |
| `cenas/<cena>.json` | cena gerada que passou no validador |
| `falhas/<cena>.json` | cena que não passou depois das correções, com os erros |
| `log/usage.jsonl` | tokens e tempo de cada chamada |
| `questions_v3.json`, `studies_v3.json` | junção das cenas (merge) |
| `l10n/` | tradução EN/ES, antes de ir para o app |

## Passo a passo

Rode de `admin/`. Troque `mateus` pela trilha.

```bash
# 0. Uma vez: credencial do fornecedor
export OPENAI_API_KEY=...            # para --provider openai
npm i -D @anthropic-ai/sdk           # para --provider anthropic (usa ANTHROPIC_API_KEY ou `ant auth login`)

# 1. Pacotes por cena (versos da JFAAL)
npm run v3:inputs -- --trail mateus

# 2. Simular: monta os prompts em log/ e estima tokens, sem chamar a API
npm run v3:generate -- --trail mateus --provider openai --model <id-do-modelo> --dry-run

# 3. Gerar (valida e devolve os erros ao modelo até 2 vezes por cena)
npm run v3:generate -- --trail mateus --provider openai --model <id-do-modelo>
npm run v3:generate -- --trail mateus --provider anthropic                     # claude-opus-5-5

# 4. Embaralhar opções, validar de novo e juntar
npm run v3:shuffle -- --trail mateus
npm run v3:validate -- --trail mateus --final
npm run v3:merge -- --trail mateus
npm run validate:bank -- v3/mateus/questions_v3.json

# 5. Revisão humana das cenas (roteiro no README do piloto)

# 6. Traduzir para EN/ES, revisar e aplicar nos overlays do app
npm run v3:translate -- --trail mateus --provider openai --model <id-do-modelo>
npm run v3:translate -- --trail mateus --apply

# 7. Publicar (simula e faz backup; só grava com --apply)
npm run v3:publish -- --trail mateus
npm run v3:publish -- --trail mateus --apply
```

Opções do gerador: `--only cena-a,cena-b`, `--limit N`, `--retries N`, `--concurrency N`, `--effort low|medium|high` (Anthropic), `--force` (refaz cenas já geradas). Cenas que já estão em `cenas/` são puladas.

Na OpenAI, `V3_OPENAI_REASONING=low|medium|high` envia o esforço de raciocínio para modelos que aceitam esse campo.

## O que o modelo escreve e o que o script preenche

O modelo escreve só o que pede julgamento: enunciados, opções, feedback, dica, estudo. O script (`_v3_hydrate.mjs`) preenche ids, `prompt`/`cue`, opções do V/F, `correctAnswer`, `template` do Completar, `relatedVerses` e **todo texto bíblico** (`passageText`, `passages`, `crossRefs`, `passageA`/`passageB`) a partir da JFAAL. Assim o modelo não cita a Bíblia de memória, e a saída fica cerca de 40% menor.

## Antes de escalar

1. Faça o piloto com três trilhas de tipos diferentes (narrativa, epístola, temática) e compare com Gênesis.
2. Some os tokens em `log/usage.jsonl` para saber o custo real por cena.
3. Algumas cenas em `trails.json` têm `hookRef` que é título, não referência, ou `centralInsight` cortado. O pacote usa só referências válidas, e o modelo propõe um insight novo quando o da cena vem cortado. Esse insight novo vai só para o estudo: `trails.json` e o Firestore (`content_trails`) não mudam sozinhos.
