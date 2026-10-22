/**
 * Fornecedor configurável do pipeline V3: --provider openai | anthropic.
 * Cada fornecedor fica no seu arquivo; aqui só se escolhe e se limpa a saída.
 */
export async function complete(opts) {
  const provider = opts.provider || 'anthropic';
  if (provider === 'openai') {
    const { completeOpenAI } = await import('./_llm_openai.mjs');
    return completeOpenAI(opts);
  }
  if (provider === 'anthropic') {
    let mod;
    try {
      mod = await import('./_llm_anthropic.mjs');
    } catch (e) {
      if (String(e.message).includes('@anthropic-ai/sdk')) {
        throw new Error('SDK da Anthropic não instalado. Rode em admin/: npm i -D @anthropic-ai/sdk');
      }
      throw e;
    }
    return mod.completeAnthropic(opts);
  }
  if (provider === 'mock') {
    // Teste sem API: devolve V3_MOCK_DIR/<tag>.json como se fosse a resposta.
    const { readFileSync } = await import('fs');
    const text = readFileSync(`${process.env.V3_MOCK_DIR}/${opts.tag}.json`, 'utf8');
    return { text, stop: 'end_turn', model: 'mock', usage: { input: 0, output: 0, cached: 0 } };
  }
  throw new Error(`Fornecedor desconhecido: ${provider} (use openai ou anthropic)`);
}

/** Primeiro objeto JSON da resposta (tolera cerca de ```json). */
export function parseJsonReply(text) {
  const t = String(text || '').trim();
  const fenced = t.match(/```(?:json)?\s*([\s\S]*?)```/);
  const raw = fenced ? fenced[1] : t;
  const start = raw.indexOf('{');
  const end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) throw new Error('Resposta sem objeto JSON.');
  return JSON.parse(raw.slice(start, end + 1));
}
