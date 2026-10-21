'use strict';

/**
 * RevenueCat → Firestore: o registro no servidor do Peregrino+.
 *
 * O app continua lendo o entitlement do SDK no aparelho (é ele que abre
 * os recursos). Isto aqui é a cópia no servidor para o que o aparelho
 * sozinho não resolve: Família (várias contas), bolsa pastoral no admin
 * e auditoria. Sem esta cópia, `supporter` era gravado pelo cliente —
 * qualquer um podia se dar o selo mexendo no próprio doc.
 *
 * A função HTTP só liga quando o segredo estiver configurado:
 *   firebase functions:config:set revenuecat.auth="Bearer <segredo>"
 * (ou a variável REVENUECAT_WEBHOOK_AUTH no ambiente da função).
 * Sem segredo, responde 503 e não grava nada.
 */

const ENTITLEMENT_ID = 'peregrino_plus';
const SUPPORT_PREFIX = 'apoio';

/// Anual de lançamento, com teste de 14 dias. A vaga é do primeiro
/// pagamento, não do início do teste: quem desiste no teste não ocupa
/// vaga. Cancelar depois de pagar não devolve, renovar não soma de novo.
const PIONEER_PRODUCT_ID = 'plus_founder_annual';
const PIONEER_CAP = 200;
const PIONEER_SLOT_TYPES = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'PRODUCT_CHANGE',
  'TRANSFER',
]);

const ACTIVATE = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'PRODUCT_CHANGE',
  'UNCANCELLATION',
  'SUBSCRIPTION_EXTENDED',
]);
const STILL_ACTIVE = new Set(['CANCELLATION']);
const DEACTIVATE = new Set(['EXPIRATION', 'SUBSCRIPTION_PAUSED']);

/**
 * Estado Plus a gravar para um evento, ou null se o evento não muda nada.
 * Pura para testar: recebe o `event` do webhook e devolve {uid, fields}.
 * Não conhece SKU/preço: decide pelo entitlement, não pelo produto.
 */
function plusStateFromEvent(event) {
  if (!event || typeof event !== 'object') return null;
  const type = String(event.type || '');
  // TRANSFER: quem recebe é o destino — a origem pode ser anônima.
  let uid = String(event.app_user_id || '').trim();
  if (type === 'TRANSFER' && Array.isArray(event.transferred_to)) {
    uid = String(event.transferred_to[0] || '').trim();
  }
  if (!uid || uid.startsWith('$RCAnonymousID')) return null;
  const entitlements = Array.isArray(event.entitlement_ids)
    ? event.entitlement_ids
    : Array.isArray(event.entitlement_id)
      ? event.entitlement_id
      : null;
  const hasEntitlement =
    entitlements == null || entitlements.includes(ENTITLEMENT_ID);

  // Apoio avulso (consumível): não é assinatura, só o selo.
  if (type === 'NON_RENEWING_PURCHASE') {
    const product = String(event.product_id || '');
    if (!product.startsWith(SUPPORT_PREFIX)) return null;
    return { uid, fields: { supporter: true } };
  }

  if (!hasEntitlement) return null;
  const expiresMs =
    typeof event.expiration_at_ms === 'number' ? event.expiration_at_ms : null;
  const expiresAt = expiresMs ? new Date(expiresMs).toISOString() : null;
  const base = {
    plusProductId: String(event.product_id || '') || null,
    plusExpiresAt: expiresAt,
    plusSource: 'revenuecat',
  };

  // Assinatura mudou de conta (compra anônima que ganhou login, troca
  // de usuário da loja): o Plus nasce no destino — e morre na origem,
  // que vem em `also` para a função gravar junto.
  if (type === 'TRANSFER') {
    const from = Array.isArray(event.transferred_from)
      ? event.transferred_from
          .map((u) => String(u || '').trim())
          .filter((u) => u && !u.startsWith('$RCAnonymousID') && u !== uid)
      : [];
    return {
      uid,
      fields: { ...base, plusActive: true, plusWillRenew: true },
      also: from.map((u) => ({
        uid: u,
        fields: { plusActive: false, plusWillRenew: false },
      })),
    };
  }
  // Cobrança falhou mas a loja ainda concede o entitlement (graça da
  // loja): no aparelho a pessoa continua Plus, então o servidor também.
  if (type === 'BILLING_ISSUE') {
    return { uid, fields: { ...base, plusActive: true, plusWillRenew: false } };
  }
  if (ACTIVATE.has(type)) {
    return { uid, fields: { ...base, plusActive: true, plusWillRenew: true } };
  }
  if (STILL_ACTIVE.has(type)) {
    // Cancelou ≠ acabou: o acesso vai até a data de fim.
    return {
      uid,
      fields: {
        ...base,
        plusActive: expiresAt == null || expiresAt > new Date().toISOString(),
        plusWillRenew: false,
      },
    };
  }
  if (DEACTIVATE.has(type)) {
    return { uid, fields: { ...base, plusActive: false, plusWillRenew: false } };
  }
  return null;
}

function isPioneerProduct(id) {
  const product = String(id || '');
  return (
    product === PIONEER_PRODUCT_ID ||
    product.startsWith(`${PIONEER_PRODUCT_ID}:`)
  );
}

/**
 * Esta compra ocupa uma vaga de Pioneiro? Null se não.
 * Sandbox não conta. Começo de teste não conta: a vaga vem na conversão
 * do teste (RENEWAL com `is_trial_conversion`). Outras renovações,
 * cancelamento e expiração não contam.
 * TRANSFER de uma conta que já ocupou vaga herda (`from`), sem somar;
 * TRANSFER ainda no teste só herda (`inheritOnly`), a conversão soma depois.
 */
function pioneerSlotFromEvent(event) {
  if (!event || typeof event !== 'object') return null;
  if (String(event.environment || '') === 'SANDBOX') return null;
  const type = String(event.type || '');
  if (!PIONEER_SLOT_TYPES.has(type)) return null;
  if (!isPioneerProduct(event.product_id) && !isPioneerProduct(event.new_product_id)) {
    return null;
  }
  const inTrial = String(event.period_type || '') === 'TRIAL';
  if (type === 'RENEWAL' && event.is_trial_conversion !== true) return null;
  if ((type === 'INITIAL_PURCHASE' || type === 'PRODUCT_CHANGE') && inTrial) {
    return null;
  }
  let uid = String(event.app_user_id || '').trim();
  if (type === 'TRANSFER' && Array.isArray(event.transferred_to)) {
    uid = String(event.transferred_to[0] || '').trim();
  }
  if (!uid || uid.startsWith('$RCAnonymousID')) return null;
  const from =
    type === 'TRANSFER' && Array.isArray(event.transferred_from)
      ? event.transferred_from
          .map((u) => String(u || '').trim())
          .filter((u) => u && !u.startsWith('$RCAnonymousID') && u !== uid)
      : [];
  return type === 'TRANSFER' && inTrial
    ? { uid, from, inheritOnly: true }
    : { uid, from };
}

/**
 * O que fazer com a vaga, dados os docs já lidos.
 * `skip`: esta conta já contou. `inherit`: a origem já contou, a vaga
 * só muda de conta. `increment`: primeiro pagamento, soma 1.
 * `inheritOnly` (transferência ainda no teste) nunca soma.
 */
function pioneerClaimDecision({ alreadyCounted, sourceCounted, count, inheritOnly }) {
  if (alreadyCounted) return { action: 'skip' };
  if (sourceCounted) return { action: 'inherit' };
  if (inheritOnly) return { action: 'skip' };
  const next = (typeof count === 'number' && count > 0 ? count : 0) + 1;
  return { action: 'increment', count: next };
}

/** O header Authorization bate com o segredo configurado? */
function authorized(header, secret) {
  if (!secret) return false;
  if (typeof header !== 'string' || !header) return false;
  const expected = secret.startsWith('Bearer ') ? secret : `Bearer ${secret}`;
  // Comparação simples: o segredo é longo e o endpoint só grava 3 campos.
  return header === expected;
}

module.exports = {
  plusStateFromEvent,
  pioneerSlotFromEvent,
  pioneerClaimDecision,
  authorized,
  ENTITLEMENT_ID,
  PIONEER_PRODUCT_ID,
  PIONEER_CAP,
};
