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

const { FieldValue } = require('firebase-admin/firestore');

const ENTITLEMENT_ID = 'peregrino_plus';
const SUPPORT_PREFIX = 'apoio';

/// Pioneiro: vitalício de lançamento (compra única, sem teste), as
/// primeiras 200 vagas. A vaga conta na compra. `plus_founder_annual` era
/// o anual de lançamento antigo (só testadores): continua reconhecido
/// para o selo, e a conversão do teste dele ainda conta vaga.
const PIONEER_PRODUCT_ID = 'plus_pioneer_lifetime';
const PIONEER_LEGACY_IDS = ['plus_founder_annual'];
const PIONEER_CAP = 200;
const PIONEER_SLOT_TYPES = new Set([
  'NON_RENEWING_PURCHASE',
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
  // Reembolso desfeito: o acesso volta.
  'REFUND_REVERSED',
  // Loja fora do ar: o RevenueCat concede o acesso por um tempo curto.
  'TEMPORARY_ENTITLEMENT_GRANT',
]);
// Pausa (Play) é agendada para o fim do período: o acesso vai até lá,
// e a loja manda EXPIRATION quando a pausa começar de fato.
const STILL_ACTIVE = new Set(['CANCELLATION', 'SUBSCRIPTION_PAUSED']);
const DEACTIVATE = new Set(['EXPIRATION']);

/**
 * Estado Plus a gravar para um evento, ou null se o evento não muda nada.
 * Pura para testar: recebe o `event` do webhook e devolve {uid, fields}.
 * Não conhece SKU/preço: decide pelo entitlement, não pelo produto.
 */
function plusStateFromEvent(event, { allowSandbox = false } = {}) {
  if (!event || typeof event !== 'object') return null;
  // Compra de teste (licença do Play, TestFlight) não liga Plus de
  // verdade no banco de produção (passe de trilha, aceno, regras).
  if (!allowSandbox && String(event.environment || '') === 'SANDBOX') {
    return null;
  }
  const type = String(event.type || '');
  // TRANSFER: quem recebe é o destino — a origem pode ser anônima.
  let uid = String(event.app_user_id || '').trim();
  if (type === 'TRANSFER' && Array.isArray(event.transferred_to)) {
    uid = String(event.transferred_to[0] || '').trim();
  }
  if (!uid || uid.startsWith('$RCAnonymousID')) return null;
  // Sem a lista de entitlements não dá para saber se o evento é do Plus:
  // ausência não liga nada (antes contava como Plus).
  const entitlements = Array.isArray(event.entitlement_ids)
    ? event.entitlement_ids
    : Array.isArray(event.entitlement_id)
      ? event.entitlement_id
      : typeof event.entitlement_id === 'string'
        ? [event.entitlement_id]
        : null;
  const hasEntitlement =
    entitlements != null && entitlements.includes(ENTITLEMENT_ID);
  const product = String(event.product_id || '');

  const expiresMs =
    typeof event.expiration_at_ms === 'number' ? event.expiration_at_ms : null;

  // Compra única: apoio avulso (só o selo) ou o Pioneiro vitalício
  // (Plus sem data de fim).
  if (type === 'NON_RENEWING_PURCHASE') {
    if (product.startsWith(SUPPORT_PREFIX)) return { uid, fields: { supporter: true } };
    if (!hasEntitlement) return null;
    return {
      uid,
      fields: {
        plusProductId: product || null,
        plusExpiresAt: expiresMs ? new Date(expiresMs).toISOString() : null,
        plusSource: 'revenuecat',
        plusActive: true,
        plusWillRenew: false,
        plusInTrial: false,
      },
    };
  }
  const expiresAt = expiresMs ? new Date(expiresMs).toISOString() : null;
  // Teste grátis: o passe de trilha exige Plus pago. plusInTrial trava
  // a create em firestore.rules — quem inicia o teste e cancela não
  // doa trilhas Plus nos 14 dias (nem 2 se atravessar o mês).
  const inTrial = String(event.period_type || '') === 'TRIAL';
  const base = {
    plusProductId: product || null,
    plusExpiresAt: expiresAt,
    plusSource: 'revenuecat',
  };

  // Assinatura mudou de conta (compra anônima que ganhou login, troca
  // de usuário da loja): o Plus morre na origem, que vem em `also` para
  // a função gravar junto. No destino só nasce se ainda vale — restaurar
  // recibo vencido ou de apoio não dá Plus. Vitalício vem sem data de fim:
  // o destino é lido no RevenueCat ([withTransferLookup]).
  // Sem nada a ligar no destino, `fields` é null e só a origem é gravada.
  if (type === 'TRANSFER') {
    const from = Array.isArray(event.transferred_from)
      ? event.transferred_from
          .map((u) => String(u || '').trim())
          .filter((u) => u && !u.startsWith('$RCAnonymousID') && u !== uid)
      : [];
    let fields = null;
    if (product.startsWith(SUPPORT_PREFIX)) {
      fields = { supporter: true };
    } else if (hasEntitlement && expiresMs != null && expiresMs > Date.now()) {
      fields = {
        ...base,
        plusActive: true,
        plusWillRenew: true,
        plusInTrial: inTrial,
      };
    }
    if (!fields && from.length === 0) return null;
    return {
      uid,
      fields,
      also: from.map((u) => ({
        uid: u,
        fields: {
          plusActive: false,
          plusWillRenew: false,
          plusInTrial: false,
        },
      })),
    };
  }

  if (!hasEntitlement) return null;
  // Cobrança falhou mas a loja ainda concede o entitlement (graça da
  // loja): no aparelho a pessoa continua Plus, então o servidor também.
  if (type === 'BILLING_ISSUE') {
    return {
      uid,
      fields: {
        ...base,
        plusActive: true,
        plusWillRenew: false,
        plusInTrial: inTrial,
      },
    };
  }
  if (ACTIVATE.has(type)) {
    return {
      uid,
      fields: {
        ...base,
        plusActive: true,
        plusWillRenew: true,
        plusInTrial: inTrial,
      },
    };
  }
  // Compra única sem data de fim (vitalício) só é cancelada por
  // reembolso: o acesso acaba na hora.
  if (type === 'CANCELLATION' && expiresMs == null) {
    return {
      uid,
      fields: {
        ...base,
        plusActive: false,
        plusWillRenew: false,
        plusInTrial: false,
      },
    };
  }
  if (STILL_ACTIVE.has(type)) {
    // Cancelou ≠ acabou: o acesso vai até a data de fim.
    const active =
      expiresAt == null || expiresAt > new Date().toISOString();
    return {
      uid,
      fields: {
        ...base,
        plusActive: active,
        plusWillRenew: false,
        // Sem acesso, não há trial; com acesso, o period_type do evento.
        plusInTrial: active && inTrial,
      },
    };
  }
  if (DEACTIVATE.has(type)) {
    return {
      uid,
      fields: {
        ...base,
        plusActive: false,
        plusWillRenew: false,
        plusInTrial: false,
      },
    };
  }
  return null;
}

function isPioneerProduct(id) {
  const product = String(id || '').split(':')[0];
  return product === PIONEER_PRODUCT_ID || PIONEER_LEGACY_IDS.includes(product);
}

/**
 * Esta compra ocupa uma vaga de Pioneiro? Null se não.
 * Sandbox não conta. O vitalício conta na compra (NON_RENEWING_PURCHASE).
 * No anual antigo, começo de teste não conta: a vaga vem na conversão
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
  // Troca de plano conta só quando o destino é o Pioneiro: sair dele
  // (Pioneiro → mensal) não ocupa vaga.
  const pioneer =
    type === 'PRODUCT_CHANGE'
      ? isPioneerProduct(event.new_product_id)
      : isPioneerProduct(event.product_id);
  if (!pioneer) return null;
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
  const bare = secret.startsWith('Bearer ') ? secret.slice(7) : secret;
  // O RevenueCat manda o header como foi digitado no painel: com ou sem
  // "Bearer ". Comparação simples: o segredo é longo e o endpoint só grava
  // 3 campos.
  return header === `Bearer ${bare}` || header === bare;
}

// ---- Gravação no Firestore (o handler em index.js só confere e chama) ----

/// Lápide da conta excluída (account.js grava antes de apagar o perfil):
/// evento atrasado do RevenueCat não recria `users/{uid}` de quem saiu.
/// O uid do Firebase não volta — entrar de novo cria outro.
const TOMBSTONES = 'deletedAccounts';

/**
 * Grava o estado Plus só se o evento não for mais velho que o último
 * aplicado: a RevenueCat pode entregar fora de ordem (reenvio de falha),
 * e uma EXPIRATION atrasada não pode desligar quem já renovou.
 * A marca fica em `users/{uid}/server/revenuecat`, fora do alcance do
 * cliente (sem regra = negado) e apagada junto com a conta.
 * Só evento de assinatura (mexe em `plusActive`) lê e carimba a marca:
 * o selo do apoio avulso não pode fazer uma EXPIRATION reenviada parecer
 * velha. `mustExist`: só grava em doc que já existe (origem do TRANSFER).
 * Devolve 'stale' (evento velho), 'gone' (conta excluída / doc ausente)
 * ou null quando gravou.
 */
async function writePlusState(db, uid, fields, event, { mustExist = false } = {}) {
  const userRef = db.doc(`users/${uid}`);
  const markRef = db.doc(`users/${uid}/server/revenuecat`);
  const tombRef = db.doc(`${TOMBSTONES}/${uid}`);
  const subscription = Object.prototype.hasOwnProperty.call(fields, 'plusActive');
  const at =
    subscription && event && typeof event.event_timestamp_ms === 'number'
      ? event.event_timestamp_ms
      : null;
  return db.runTransaction(async (tx) => {
    const tomb = await tx.get(tombRef);
    if (tomb.exists) return 'gone';
    if (mustExist) {
      const user = await tx.get(userRef);
      if (!user.exists) return 'gone';
    }
    if (subscription) {
      const mark = await tx.get(markRef);
      const last = mark.exists ? mark.get('lastEventAtMs') : undefined;
      if (at != null && typeof last === 'number' && at < last) return 'stale';
    }
    tx.set(
      userRef,
      { ...fields, plusUpdatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    if (at != null) {
      tx.set(markRef, { lastEventAtMs: at, lastEventType: String(event.type || '') });
    }
    return null;
  });
}

/**
 * Primeiro pagamento do Pioneiro soma 1 em `stats/pioneer`. A mesma conta
 * não soma de novo. Transferência de quem já contou só marca o destino.
 * Conta excluída não ganha marca nem vaga.
 */
async function claimPioneerSlot(db, slot) {
  const userRef = db.doc(`users/${slot.uid}`);
  const tombRef = db.doc(`${TOMBSTONES}/${slot.uid}`);
  const statRef = db.doc('stats/pioneer');
  const sourceRefs = (slot.from || []).map((uid) => db.doc(`users/${uid}`));
  await db.runTransaction(async (tx) => {
    const tomb = await tx.get(tombRef);
    if (tomb.exists) return;
    const user = await tx.get(userRef);
    const sources = [];
    for (const ref of sourceRefs) sources.push(await tx.get(ref));
    const stat = await tx.get(statRef);
    const decision = pioneerClaimDecision({
      alreadyCounted: user.get('pioneerCounted') === true,
      sourceCounted: sources.some((s) => s.get('pioneerCounted') === true),
      count: stat.get('count'),
      inheritOnly: slot.inheritOnly === true,
    });
    if (decision.action === 'skip') return;
    tx.set(userRef, { pioneerCounted: true }, { merge: true });
    if (decision.action === 'increment') {
      tx.set(
        statRef,
        {
          count: decision.count,
          cap: PIONEER_CAP,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
  });
}

/**
 * TRANSFER costuma vir sem entitlement nem data de fim: pergunta ao
 * RevenueCat se o destino tem Plus agora (senão ficava sem Plus no
 * servidor até a próxima renovação, que pode levar um ano). Sem resposta,
 * devolve o estado como veio: a origem desliga mesmo assim e o destino
 * liga na próxima renovação ou no "Restaurar compras".
 */
async function withTransferLookup(state, event, rc) {
  if (
    !rc ||
    !state ||
    state.fields ||
    String((event && event.type) || '') !== 'TRANSFER' ||
    !state.uid ||
    state.uid.startsWith('$RCAnonymousID')
  ) {
    return state;
  }
  try {
    const info = await rc.plusInfo(state.uid);
    if (!info.active) return state;
    return {
      ...state,
      fields: {
        plusActive: true,
        plusWillRenew: info.willRenew,
        plusInTrial: info.inTrial,
        plusProductId: info.productId,
        plusExpiresAt: info.expiresAt,
        plusSource: 'revenuecat',
      },
    };
  } catch (_) {
    return state;
  }
}

/**
 * Um evento fala de um produto, não da conta. Quem tem o mensal e compra
 * o Pioneiro recebe depois o CANCELLATION/EXPIRATION do mensal, e o
 * evento sozinho desligaria o Plus (ou trocaria o produto gravado para o
 * mensal, tirando o selo de Pioneiro). Antes de gravar um estado com data
 * de fim ou desligado, pergunta ao RevenueCat o entitlement da conta
 * inteira. Se ele diz ativo, vale o que ele diz. A consulta só pode manter
 * ou ligar o Plus, nunca desligar: se ele diz inativo (ou não responde),
 * fica o estado do evento, como antes.
 * Compra do vitalício (ativo, sem data de fim) não precisa perguntar.
 */
async function withAccountLookup(state, event, rc) {
  if (
    !rc ||
    !state ||
    !state.fields ||
    String((event && event.type) || '') === 'TRANSFER' ||
    !Object.prototype.hasOwnProperty.call(state.fields, 'plusActive')
  ) {
    return state;
  }
  const f = state.fields;
  if (f.plusActive === true && f.plusExpiresAt == null) return state;
  try {
    const info = await rc.plusInfo(state.uid);
    if (!info || !info.active) return state;
    return {
      ...state,
      fields: {
        plusActive: true,
        plusWillRenew: info.willRenew === true,
        plusInTrial: info.inTrial === true,
        plusProductId: info.productId || f.plusProductId || null,
        plusExpiresAt: info.expiresAt == null ? null : info.expiresAt,
        plusSource: 'revenuecat',
      },
    };
  } catch (_) {
    return state;
  }
}

/**
 * Aplica um evento já conferido. Devolve null se o evento não muda nada;
 * senão o resumo para o log.
 */
async function applyEvent(db, event, { rc = null, allowSandbox = false } = {}) {
  let state = plusStateFromEvent(event, { allowSandbox });
  const slot = pioneerSlotFromEvent(event);
  state = await withTransferLookup(state, event, rc);
  state = await withAccountLookup(state, event, rc);
  if (!state && !slot) return null;
  let skipped = null;
  if (state && state.fields) {
    skipped = await writePlusState(db, state.uid, state.fields, event);
  }
  // Escritas companheiras (TRANSFER: desligar a conta de origem). Cada
  // origem passa pela mesma marca: evento mais velho que o TRANSFER não
  // a religa, e o TRANSFER atrasado não desliga quem já assinou de novo.
  // Só em doc que já existe: nada de doc-zumbi de conta excluída.
  if (state) {
    for (const extra of state.also || []) {
      await writePlusState(db, extra.uid, extra.fields, event, { mustExist: true });
    }
  }
  if (slot) await claimPioneerSlot(db, slot);
  return {
    uid: (state && state.uid) || slot.uid,
    pioneer: Boolean(slot),
    skipped,
  };
}

module.exports = {
  applyEvent,
  withTransferLookup,
  withAccountLookup,
  TOMBSTONES,
  plusStateFromEvent,
  pioneerSlotFromEvent,
  pioneerClaimDecision,
  authorized,
  ENTITLEMENT_ID,
  PIONEER_PRODUCT_ID,
  PIONEER_CAP,
  isPioneerProduct,
};
