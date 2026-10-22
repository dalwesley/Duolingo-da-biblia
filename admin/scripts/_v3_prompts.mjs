/**
 * Textos que o modelo recebe no pipeline V3. Os mesmos servem à API
 * (v3_generate.mjs) e ao uso manual no ChatGPT (v3_manual.mjs).
 */
import { readFileSync } from 'fs';
import { join } from 'path';
import { compactCena } from './_v3_hydrate.mjs';
import { PILOT_DIR, SPEC_PATH, readJson } from './_v3_paths.mjs';

export const EXAMPLES = { lesson: 'gen-01-criador', boss: 'gen-boss-01' };

export const ROLE = `Você é editor pedagógico do STWAY, app de formação bíblica em português do Brasil. Você escreve o banco V3 de uma cena: o estudo e as perguntas dos três modos (Observação = semente, Compreensão = caminhada, Interpretação = profundezas).`;

export const FORMAT_RULES = `Responda com UM objeto JSON e nada mais: {"study": {...}, "questions": [...]}.

Um script completa a cena depois. NÃO escreva estes campos (ele preenche):
- em cada pergunta: id, trail, section, skill, prompt, cue, passageText, template, correctAnswer; no V/F, options; no Ordenar, correctOptionId;
- no estudo: slug, passageText, relatedVerses; em passages, crossRefs, passageA e passageB com referência bíblica, escreva só "ref" (o texto vem da JFAAL). Exceção: passageA pode trazer "text" quando for um recorte exato de parte do versículo.

Ordem das perguntas: todas as de semente, depois caminhada, depois profundezas; dentro do modo, na ordem dos gestos (lição: 01 V/F, 02 Toque, 03 Escolha, 04 Ordenar, 05 Completar, 06 Conectar; desafio: as mesmas e mais 07 Toque e 08 Ordenar). O número do id é a posição da pergunta no modo.

Texto bíblico: use SÓ os versos que vêm no pedido (campo "verses"), copiados letra por letra. verseRef de cada pergunta: um capítulo, até 2 versos, escolhidos desses versos. evidenceSpan, opções do Toque, peças da Observação no Ordenar, facts[].evidenceSpan, keyTerms[].term e relations[].marker saem literalmente desse texto. Para crossRefs e Conectar (Compreensão e Interpretação), escolha referências reais de 1 ou 2 versos que você conhece bem; o script põe o texto.

Nome de Deus: escreva "Senhor", como a JFAAL. Os dados da V2 às vezes dizem "Jeová" (outra tradução); não copie.

Se o "centralInsight" da cena vier cortado (termina em "…") ou genérico, escreva em study.centralInsight um insight próprio da cena, até 140 caracteres. Senão, copie o da cena.`;

export function specText() {
  return readFileSync(SPEC_PATH, 'utf8');
}

/** Cena de exemplo de Gênesis no formato enxuto que o modelo devolve. */
export function exampleJson(kind) {
  return JSON.stringify(compactCena(readJson(join(PILOT_DIR, 'cenas', `${EXAMPLES[kind]}.json`))), null, 1);
}

/** Instruções fixas: iguais em todas as cenas, para o fornecedor guardar em cache. */
export function systemPrompt() {
  return `${ROLE}

A especificação abaixo é a regra. A trilha de exemplo é Gênesis 1–11; para outra trilha, troque o prefixo dos ids e as referências, e mantenha tudo o mais.

<especificacao>
${specText()}
</especificacao>

<formato_de_saida>
${FORMAT_RULES}
</formato_de_saida>

<exemplo_licao>
${exampleJson('lesson')}
</exemplo_licao>

<exemplo_desafio>
${exampleJson('boss')}
</exemplo_desafio>`;
}

export function userPrompt(packet, index) {
  const boss = packet.mission.type === 'boss';
  // V/F equilibrado na trilha: cenas pares com 2 verdadeiras, ímpares com 1.
  const trues = index % 2 === 0 ? 2 : 1;
  return `Escreva a cena "${packet.mission.slug}" da trilha "${packet.trail.slug}" (${packet.trail.title}).
Tipo: ${boss ? 'desafio — 8 perguntas por modo, misturando as cenas anteriores do bloco' : 'lição — 6 perguntas por modo'}.
V/F: ${trues === 1 ? '1 das 3 afirmações (uma por modo) deve ser verdadeira' : '2 das 3 afirmações (uma por modo) devem ser verdadeiras'}.

<cena>
${JSON.stringify(packet, null, 1)}
</cena>`;
}

export function fixPrompt(packet, index, previous, errors) {
  return `${userPrompt(packet, index)}

Sua versão anterior falhou na validação. Corrija TODOS os erros abaixo e devolva a cena inteira, no mesmo formato.

${errorsBlock(errors)}

<versao_anterior>
${previous}
</versao_anterior>`;
}

/** Correção dentro da mesma conversa (ChatGPT): a versão anterior já está lá. */
export function fixPromptInChat(errors) {
  return `A validação encontrou os erros abaixo na sua resposta. Corrija TODOS e devolva a cena inteira, no mesmo formato, só o JSON.

${errorsBlock(errors)}`;
}

function errorsBlock(errors) {
  return `<erros>
${errors.map((e) => `- ${e}`).join('\n')}
</erros>`;
}
