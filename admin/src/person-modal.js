/**
 * Ficha de um peregrino: perfil público, conta (Auth), denúncias e histórico
 * de moderação — e, para admin, as ações (functions/moderation.js).
 *
 * Abre de qualquer nome clicável (Relatos, Suporte). Com `reportId`, a ação
 * fecha a denúncia que motivou a abertura.
 */
import { getFunctions, httpsCallable } from 'firebase/functions';
import { app } from './firebase.js';
import { COL, formatDate, getDocById, listWhere } from './db.js';
import { getRole } from './roles.js';
import { confirmAction, escapeHtml, hideModalElement, setLoading, showModalElement, showToast } from './ui.js';

const moderateUser = httpsCallable(getFunctions(app, 'us-central1'), 'moderateUser');

const REASON = {
  offensive_name: 'Nome ofensivo',
  offensive_photo: 'Foto imprópria',
  harassment: 'Assédio ou ameaça',
  spam: 'Spam ou golpe',
  other: 'Outro',
};

const REPORT_STATUS = { open: 'aberta', actioned: 'já agi', dismissed: 'sem fundamento' };

const PROVIDER = { 'google.com': 'Google', 'apple.com': 'Apple', password: 'E-mail e senha' };

const STATE = {
  active: ['Ativa', 'ok'],
  suspended: ['Suspensa', 'warn'],
  banned: ['Inativa', 'bad'],
  deleted: ['Excluída', 'bad'],
};

const ACTION_LABEL = {
  warn: 'Aviso',
  rename: 'Nome trocado',
  removePhoto: 'Foto removida',
  suspend: 'Suspensão',
  ban: 'Conta inativada',
  reactivate: 'Reativada',
  autoReactivate: 'Fim da suspensão',
  delete: 'Conta excluída',
};

const SUSPEND_DAYS = [1, 3, 7, 15, 30];

/**
 * Do mais leve ao mais grave. `confirm` diz o que acontece, em uma frase.
 */
const ACTIONS = [
  {
    id: 'warn',
    label: 'Advertir',
    hint: 'Push com a sua mensagem. Fica no histórico mesmo se o push não chegar.',
    confirm: (name) => `Mandar o aviso para ${name}?`,
  },
  {
    id: 'rename',
    label: 'Trocar nome',
    hint: 'Vira “Peregrino XXXX” no perfil, placares, grupos e companhias.',
    confirm: (name) => `Trocar o nome de ${name} por um nome neutro?`,
  },
  {
    id: 'removePhoto',
    label: 'Remover foto',
    hint: 'Tira a foto do perfil, dos placares e da conta.',
    confirm: (name) => `Remover a foto de ${name}?`,
  },
  {
    id: 'suspend',
    label: 'Suspender',
    hint: 'Desliga o login pelo prazo escolhido e volta sozinho.',
    confirm: (name, days) => `Suspender ${name} por ${days} dia(s)? A pessoa sai do app em até 1 hora.`,
    tone: 'warn',
  },
  {
    id: 'ban',
    label: 'Inativar conta',
    hint: 'Bloqueia o login sem prazo: com esse e-mail (Google ou Apple) a pessoa não entra mais. Perfil e placares ficam como estão. Dá para reativar.',
    confirm: (name) => `Inativar a conta de ${name}? A pessoa sai do app em até 1 hora e não entra mais com esse e-mail até alguém reativar.`,
    tone: 'danger',
  },
];

function pill(label, tone = '') {
  return `<span class="rv-pill ${tone}">${escapeHtml(label)}</span>`;
}

function row(label, value) {
  return `<li><span>${escapeHtml(label)}</span><strong>${value}</strong></li>`;
}

function yesNo(v) {
  return v ? pill('sim', 'ok') : pill('não');
}

function isoDate(v) {
  return v ? escapeHtml(new Date(v).toLocaleString('pt-BR')) : '—';
}

/**
 * Abas no topo da folha da conta: Conta e Plus (suporte) | Moderação (ficha).
 * Quem abre passa o callback da outra aba; sem callback, não há abas.
 */
export function accountTabsHtml(active) {
  const tab = (key, label) => `<button type="button" class="ez-chip${active === key ? ' active' : ''}" data-account-tab="${key}"${active === key ? ' aria-current="page"' : ''}>${label}</button>`;
  return `<nav class="pm-tabs" aria-label="Seções da conta">${tab('support', 'Conta e Plus')}${tab('ficha', 'Moderação')}</nav>`;
}

/**
 * @param {{ uid: string, name?: string, reportId?: string, onChanged?: () => void, onOpenSupport?: (uid: string, name: string) => void }} opts
 */
export async function openPersonModal({ uid, name = '', reportId = '', onChanged, onOpenSupport } = {}) {
  const modal = document.getElementById('modal');
  if (!modal || !uid) return;
  const isAdmin = getRole() === 'admin';
  let changed = false;
  let info = null;

  async function load() {
    const safe = (p, fallback) => p.catch((e) => {
      console.warn(e);
      return fallback;
    });
    const [user, against, by, log, mod, appReports] = await Promise.all([
      safe(getDocById(COL.users, uid), null),
      safe(listWhere(COL.userReports, 'targetUid', uid), []),
      safe(listWhere(COL.userReports, 'reporterUid', uid), []),
      isAdmin ? safe(listWhere('moderation_log', 'uid', uid), []) : [],
      isAdmin ? safe(moderateUser({ uid, action: 'info' }).then((r) => r.data), { error: true }) : null,
      safe(listWhere(COL.appReports, 'uid', uid), []),
    ]);
    const ms = (x) => x?.toMillis?.() ?? (x ? new Date(x).getTime() : 0);
    log.sort((a, b) => ms(b.at) - ms(a.at));
    against.sort((a, b) => ms(b.createdAt) - ms(a.createdAt));
    appReports.sort((a, b) => ms(b.createdAt) - ms(a.createdAt));
    info = { user, against, by, log, mod, appReports };
  }

  function platformOf() {
    const u = info.user || {};
    const raw = String(u.platform || '').toLowerCase();
    if (raw) return { key: raw, source: 'perfil' };
    const fromReport = info.appReports?.find((r) => r.platform);
    if (fromReport?.platform) {
      return { key: String(fromReport.platform).toLowerCase(), source: 'relato do app' };
    }
    const providers = info.mod?.auth?.providers || [];
    if (providers.includes('apple.com') && !providers.includes('google.com')) {
      return { key: 'ios', source: 'login Apple' };
    }
    return null;
  }

  /** Perfil primeiro; senão último relato com versão. */
  function appVersionOf() {
    const u = info.user || {};
    if (u.appVersion) {
      const build = u.buildNumber ? ` (${u.buildNumber})` : '';
      return { label: `${u.appVersion}${build}`, source: 'perfil' };
    }
    const fromReport = info.appReports?.find((r) => r.appVersion);
    if (fromReport?.appVersion) {
      const build = fromReport.buildNumber ? ` (${fromReport.buildNumber})` : '';
      return { label: `${fromReport.appVersion}${build}`, source: 'relato do app' };
    }
    return null;
  }

  function displayName() {
    return info.user?.userName || info.user?.name || name || '(sem nome)';
  }

  function stateOf() {
    if (info.mod?.auth && info.mod.auth.exists === false) return 'deleted';
    const s = info.mod?.state?.state;
    if (s) return s;
    return info.mod?.auth?.disabled ? 'banned' : 'active';
  }

  function headHtml() {
    const u = info.user || {};
    const photo = u.photoUrl
      ? `<img class="pm-avatar" src="${escapeHtml(u.photoUrl)}" alt="" referrerpolicy="no-referrer" />`
      : `<span class="pm-avatar pm-initial">${escapeHtml(displayName().trim().charAt(0).toUpperCase() || '?')}</span>`;
    const st = isAdmin ? STATE[stateOf()] : null;
    const until = info.mod?.state?.state === 'suspended' && info.mod.state.until ? ` até ${isoDate(info.mod.state.until)}` : '';
    return `
      <header class="qs-head pm-head">
        <div class="pm-id">
          ${photo}
          <div>
            <p class="simple-kicker">Peregrino</p>
            <h2>${escapeHtml(displayName())}</h2>
            <p class="pm-sub">
              <button type="button" class="rp-uid" data-copy="${escapeHtml(uid)}" title="Copiar uid"><code>${escapeHtml(uid)}</code><span aria-hidden="true">⧉</span></button>
              ${(() => {
                const plat = platformOf();
                if (!plat) return '';
                const label = ({ android: 'Android', ios: 'iOS', web: 'Web', macos: 'macOS' })[plat.key] || plat.key;
                const tone = plat.key === 'ios' ? 'ok' : plat.key === 'android' ? 'warn' : '';
                return `<span class="rv-pill ${tone}">${escapeHtml(label)}</span>`;
              })()}
              ${(() => {
                const ver = appVersionOf();
                if (!ver) return '';
                return `<span class="rv-pill sm">v${escapeHtml(ver.label)}</span>`;
              })()}
              ${st ? `<span class="rv-pill ${st[1]}">${escapeHtml(st[0] + until)}</span>` : ''}
            </p>
          </div>
        </div>
        ${onOpenSupport ? accountTabsHtml('ficha') : ''}
        <button type="button" class="modal-close" aria-label="Fechar">×</button>
      </header>`;
  }

  function accountHtml() {
    const u = info.user;
    const a = info.mod?.auth;
    const authRows = !isAdmin
      ? ''
      : info.mod?.error
        ? '<p class="ez-hint">Dados de login indisponíveis (a Function <code>moderateUser</code> já foi publicada?).</p>'
        : a?.exists === false
          ? '<p class="ez-hint">Conta não existe mais no login (excluída).</p>'
          : `<ul class="db-list">
              ${row('E-mail', a?.email ? `${escapeHtml(a.email)} <button type="button" class="rp-uid" data-copy="${escapeHtml(a.email)}" title="Copiar e-mail"><span aria-hidden="true">⧉</span></button>` : '—')}
              ${row('Login', escapeHtml((a?.providers || []).map((p) => PROVIDER[p] || p).join(', ') || '—'))}
              ${row('Conta criada', isoDate(a?.createdAt))}
              ${row('Último login', isoDate(a?.lastSignInAt))}
              ${row('Login ligado', yesNo(!a?.disabled))}
            </ul>`;
    const plat = platformOf();
    const platLabel = plat
      ? ({ android: 'Android', ios: 'iOS', web: 'Web', macos: 'macOS' }[plat.key] || plat.key)
      : '—';
    const platValue = plat
      ? `${escapeHtml(platLabel)}${plat.source !== 'perfil' ? ` <span class="field-hint">· ${escapeHtml(plat.source)}</span>` : ''}`
      : '— <span class="field-hint">· ainda sem sync do app</span>';
    const ver = appVersionOf();
    const verValue = ver
      ? `${escapeHtml(ver.label)}${ver.source !== 'perfil' ? ` <span class="field-hint">· ${escapeHtml(ver.source)}</span>` : ''}`
      : '— <span class="field-hint">· ainda sem sync do app</span>';
    const appRows = u
      ? `<ul class="db-list">
          ${row('Aparelho', platValue)}
          ${row('Versão do app', verValue)}
          ${row('Peregrino+', yesNo(u.plusActive))}
          ${row('Passos', escapeHtml(String(u.xp ?? u.steps ?? 0)))}
          ${row('Sequência', escapeHtml(String(u.streak ?? 0)))}
          ${row('Visto por último', escapeHtml(u.lastSeenDate || '—'))}
        </ul>`
      : '<p class="ez-hint">Sem perfil no app (nunca fez backup ou foi excluído).</p>';
    return `
      <section class="qs-block"><p class="qs-block-title">Conta</p>${authRows || '<p class="ez-hint">E-mail e login: só admin vê.</p>'}</section>
      <section class="qs-block"><p class="qs-block-title">No app</p>${appRows}</section>`;
  }

  function reportsHtml() {
    const { against, by } = info;
    return `
      <section class="qs-block">
        <p class="qs-block-title">Denúncias contra · ${against.length}</p>
        ${against.length
          ? `<ul class="db-list">${against.slice(0, 8).map((r) => `
              <li><span>${escapeHtml(REASON[r.reason] || r.reason || '—')}${r.comment ? ` — <em>“${escapeHtml(String(r.comment).slice(0, 90))}”</em>` : ''}</span>
              <strong>${escapeHtml(REPORT_STATUS[r.status || 'open'] || r.status)} · ${escapeHtml(formatDate(r.createdAt, { time: false }))}</strong></li>`).join('')}</ul>`
          : '<p class="ez-hint">Nenhuma.</p>'}
        <p class="ez-hint pm-gap">Denúncias que esta pessoa fez: ${by.length}</p>
      </section>`;
  }

  function historyHtml() {
    if (!isAdmin) return '';
    const { log } = info;
    return `
      <section class="qs-block">
        <p class="qs-block-title">Histórico de moderação</p>
        ${log.length
          ? `<ul class="db-list">${log.map((l) => `
              <li><span><strong>${escapeHtml(ACTION_LABEL[l.action] || l.action)}</strong>${l.details?.days ? ` · ${l.details.days} dia(s)` : ''} — ${escapeHtml(l.reason || '')}${l.details?.message ? `<br><small>“${escapeHtml(l.details.message)}”${l.details.pushed === false ? ' · push não chegou' : ''}</small>` : ''}</span>
              <strong>${escapeHtml(formatDate(l.at, { time: false }))}<br><small>${escapeHtml(l.byEmail || l.by || '')}</small></strong></li>`).join('')}</ul>`
          : '<p class="ez-hint">Nenhuma ação ainda.</p>'}
      </section>`;
  }

  /** Denúncia que motivou a ação: a da abertura (se for contra esta pessoa) ou a aberta mais recente. */
  function sourceReport() {
    const mine = info.against.find((r) => r.id === reportId);
    return mine || info.against.find((r) => (r.status || 'open') === 'open') || null;
  }

  function reasonHtml() {
    const r = sourceReport();
    const picked = r?.reason || '';
    const detail = r
      ? `Denúncia de ${formatDate(r.createdAt, { time: false })}${r.comment ? `: “${String(r.comment).slice(0, 120)}”` : ''}`
      : '';
    return `
      <div class="ez-field">
        <span class="ez-label">Motivo (fica no histórico)</span>
        <select data-pm="reasonId">
          <option value="">Escolha…</option>
          ${Object.entries(REASON).map(([id, label]) => `<option value="${id}" ${id === picked ? 'selected' : ''}>${escapeHtml(label)}</option>`).join('')}
        </select>
        <input data-pm="reasonDetail" value="${escapeHtml(detail)}" placeholder="Detalhe (obrigatório em Outro)" />
        ${r ? '<span class="ez-hint">Preenchido pela denúncia. Ajuste se precisar.</span>' : ''}
      </div>`;
  }

  function actionsHtml() {
    if (!isAdmin) {
      return '<aside class="pm-actions"><p class="ez-hint">Só administradores moderam contas.</p></aside>';
    }
    const st = stateOf();
    if (st === 'deleted') {
      return '<aside class="pm-actions"><p class="ez-hint">Conta excluída. Nada a fazer.</p></aside>';
    }
    const blocked = st === 'suspended' || st === 'banned';
    return `
      <aside class="pm-actions">
        <p class="qs-block-title">Moderar</p>
        ${reasonHtml()}
        ${blocked ? `
          <div class="pm-act">
            <button type="button" class="btn btn-primary btn-sm" data-act="reactivate">Reativar conta</button>
            <span class="ez-hint">Liga o login de novo agora.</span>
          </div>` : ''}
        ${ACTIONS.map((a) => {
          if (blocked && (a.id === 'suspend' || a.id === 'ban')) return '';
          const cls = a.tone === 'danger' ? 'btn-danger' : a.tone === 'warn' ? 'btn-secondary pm-warn' : 'btn-secondary';
          return `
            <div class="pm-act">
              ${a.id === 'warn' ? `<textarea data-pm="message" rows="2" maxlength="300" placeholder="Mensagem do aviso (até 300 letras). Ex.: Seu nome no ranking fere as regras. Troque em Ajustes."></textarea>` : ''}
              <div class="pm-act-row">
                ${a.id === 'suspend' ? `<select data-pm="days" aria-label="Prazo">${SUSPEND_DAYS.map((d) => `<option value="${d}" ${d === 7 ? 'selected' : ''}>${d} dia${d > 1 ? 's' : ''}</option>`).join('')}</select>` : ''}
                <button type="button" class="btn btn-sm ${cls}" data-act="${a.id}">${escapeHtml(a.label)}</button>
              </div>
              <span class="ez-hint">${escapeHtml(a.hint)}</span>
            </div>`;
        }).join('')}
        <p class="ez-hint pm-legal">Base: Termos de Uso. Não conte a quem foi denunciado quem denunciou. Inativar guarda os dados: se houver suspeita de crime (ameaça, golpe), eles servem de prova.</p>
      </aside>`;
  }

  function paint() {
    modal.innerHTML = `
      <div class="modal-backdrop qs-backdrop">
        <div class="modal-card card qs-modal pm-modal" role="dialog" aria-modal="true">
          ${headHtml()}
          <div class="pm-layout">
            <div class="qs-form">
              ${accountHtml()}
              ${reportsHtml()}
              ${historyHtml()}
            </div>
            ${actionsHtml()}
          </div>
        </div>
      </div>`;
    showModalElement(modal);
    bind();
  }

  function close() {
    hideModalElement(modal);
    document.removeEventListener('keydown', onKey);
    if (changed) onChanged?.();
  }

  function onKey(e) {
    if (e.key === 'Escape' && !document.querySelector('.confirm-backdrop')) close();
  }

  async function run(actionId) {
    const val = (k) => modal.querySelector(`[data-pm="${k}"]`)?.value?.trim() || '';
    const reasonId = val('reasonId');
    const detail = val('reasonDetail');
    if (!reasonId) {
      showToast('Escolha o motivo', 'error');
      modal.querySelector('[data-pm="reasonId"]')?.focus();
      return;
    }
    if (reasonId === 'other' && detail.length < 3) {
      showToast('Em “Outro”, escreva o detalhe', 'error');
      modal.querySelector('[data-pm="reasonDetail"]')?.focus();
      return;
    }
    const reason = `${REASON[reasonId]}${detail ? ` — ${detail}` : ''}`;
    // Só fecha a denúncia se ela for contra esta pessoa (não contra quem denunciou).
    const report = info.against.find((r) => r.id === reportId);
    const payload = { uid, action: actionId, reason, ...(report ? { reportId } : {}) };
    if (actionId === 'warn') {
      payload.message = val('message');
      if (payload.message.length < 5) {
        showToast('Escreva a mensagem do aviso', 'error');
        modal.querySelector('[data-pm="message"]')?.focus();
        return;
      }
    }
    if (actionId === 'suspend') payload.days = Number(val('days')) || 7;

    const a = ACTIONS.find((x) => x.id === actionId);
    const question = actionId === 'reactivate' ? `Reativar a conta de ${displayName()}?` : a.confirm(displayName(), payload.days);
    const ok = await confirmAction(question, {
      confirmLabel: actionId === 'reactivate' ? 'Reativar' : a.label,
      danger: a?.tone === 'danger',
    });
    if (!ok) return;

    setLoading(true);
    try {
      const { data } = await moderateUser(payload);
      changed = true;
      const extra = actionId === 'warn' && data?.details?.pushed === false ? ' (push não chegou: sem aparelho registrado)' : '';
      showToast(`Feito: ${ACTION_LABEL[actionId] || actionId}${extra}`, data?.details?.pushed === false ? 'info' : 'success');
      await load();
      paint();
    } catch (e) {
      showToast(e.message || 'Falhou', 'error');
    } finally {
      setLoading(false);
    }
  }

  function bind() {
    document.removeEventListener('keydown', onKey);
    document.addEventListener('keydown', onKey);
    modal.querySelector('.modal-close')?.addEventListener('click', close);
    modal.querySelector('.modal-backdrop')?.addEventListener('click', (e) => {
      if (e.target.classList.contains('modal-backdrop')) close();
    });
    modal.querySelector('[data-account-tab="support"]')?.addEventListener('click', () => {
      close();
      onOpenSupport?.(uid, displayName());
    });
    modal.querySelectorAll('[data-copy]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(btn.dataset.copy);
          showToast('Copiado', 'success');
        } catch {
          showToast(btn.dataset.copy, 'info');
        }
      });
    });
    modal.querySelectorAll('[data-act]').forEach((btn) => {
      btn.addEventListener('click', () => run(btn.dataset.act));
    });
  }

  setLoading(true);
  try {
    await load();
  } finally {
    setLoading(false);
  }
  paint();
}
