/**
 * Chamada à API da OpenAI (Chat Completions, JSON mode) para o pipeline V3.
 * Chave: OPENAI_API_KEY. O modelo vem sempre de quem chama (--model): nada de
 * id adivinhado aqui.
 */
const ENDPOINT = process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1';

export async function completeOpenAI({ model, system, user, maxTokens }) {
  const key = process.env.OPENAI_API_KEY;
  if (!key) throw new Error('OPENAI_API_KEY não definida.');
  if (!model) throw new Error('Informe o modelo da OpenAI com --model.');
  const body = {
    model,
    messages: [
      { role: 'system', content: system },
      { role: 'user', content: user },
    ],
    response_format: { type: 'json_object' },
    max_completion_tokens: maxTokens,
  };
  // Modelos de raciocínio aceitam esforço; os demais recusam o campo.
  if (process.env.V3_OPENAI_REASONING) body.reasoning_effort = process.env.V3_OPENAI_REASONING;

  let lastError;
  for (let attempt = 0; attempt < 4; attempt++) {
    const res = await fetch(`${ENDPOINT}/chat/completions`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', authorization: `Bearer ${key}` },
      body: JSON.stringify(body),
    });
    if (res.status === 429 || res.status >= 500) {
      lastError = new Error(`OpenAI ${res.status}: ${await res.text()}`);
      const wait = Number(res.headers.get('retry-after')) || 2 ** attempt * 5;
      await new Promise((r) => setTimeout(r, wait * 1000));
      continue;
    }
    if (!res.ok) throw new Error(`OpenAI ${res.status}: ${await res.text()}`);
    const data = await res.json();
    const choice = data.choices?.[0];
    return {
      text: choice?.message?.content || '',
      stop: choice?.finish_reason === 'length' ? 'max_tokens' : choice?.finish_reason || 'unknown',
      usage: {
        input: data.usage?.prompt_tokens ?? 0,
        output: data.usage?.completion_tokens ?? 0,
        cached: data.usage?.prompt_tokens_details?.cached_tokens ?? 0,
      },
    };
  }
  throw lastError;
}
