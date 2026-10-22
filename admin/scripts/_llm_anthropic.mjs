/**
 * Chamada à API da Anthropic (SDK oficial) para o pipeline V3.
 * Credencial: ANTHROPIC_API_KEY ou o perfil do `ant auth login`.
 * Requer: npm i -D @anthropic-ai/sdk (em admin/).
 */
import Anthropic from '@anthropic-ai/sdk';

export const DEFAULT_ANTHROPIC_MODEL = 'claude-opus-5-5';

// Modelos com fallback no servidor quando o classificador recusa.
const SERVER_FALLBACK = new Set(['claude-opus-5-5', 'claude-opus-5', 'claude-fable-5-1', 'claude-sonnet-5-5']);

let client;

export async function completeAnthropic({ model = DEFAULT_ANTHROPIC_MODEL, system, user, maxTokens, effort = 'high' }) {
  client ??= new Anthropic();
  const params = {
    model,
    max_tokens: maxTokens,
    // Especificação + exemplos: iguais em todas as cenas, ficam em cache.
    system: [{ type: 'text', text: system, cache_control: { type: 'ephemeral' } }],
    messages: [{ role: 'user', content: user }],
    output_config: { effort },
  };
  if (SERVER_FALLBACK.has(model)) {
    params.betas = ['server-side-fallback-2026-07-01'];
    params.fallbacks = 'default';
  }
  // Streaming: a cena inteira passa de 10 mil tokens de saída.
  const stream = SERVER_FALLBACK.has(model) ? client.beta.messages.stream(params) : client.messages.stream(params);
  const message = await stream.finalMessage();
  const text = message.content
    .filter((b) => b.type === 'text')
    .map((b) => b.text)
    .join('');
  return {
    text,
    stop: message.stop_reason,
    model: message.model,
    usage: {
      input: (message.usage?.input_tokens ?? 0) + (message.usage?.cache_creation_input_tokens ?? 0),
      output: message.usage?.output_tokens ?? 0,
      cached: message.usage?.cache_read_input_tokens ?? 0,
    },
  };
}
