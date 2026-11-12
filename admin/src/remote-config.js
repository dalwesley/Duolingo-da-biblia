/**
 * Remote Config lido pelo painel (só leitura). Os parâmetros são os que o app
 * usa em trilha_app/lib/services/remote_config_service.dart.
 */
import { fetchAndActivate, getAll, getRemoteConfig } from 'firebase/remote-config';
import { app } from './firebase.js';

export const RC_PROJECT = import.meta.env.VITE_FIREBASE_PROJECT_ID || 'trilha-biblia';
export const RC_CONSOLE_URL = `https://console.firebase.google.com/project/${RC_PROJECT}/config`;

export const RC_GROUPS = [
  {
    title: 'Liberação de recursos',
    keys: [
      { key: 'groups_enabled', label: 'Grupos', kind: 'bool' },
      { key: 'companion_enabled', label: 'Companhia', kind: 'bool' },
      { key: 'challenge_enabled', label: 'Desafio', kind: 'bool' },
    ],
  },
  {
    title: 'Pioneiro e Plus',
    keys: [
      { key: 'pioneer_until', label: 'Pioneiro à venda até', kind: 'date' },
      { key: 'pioneer_reserved', label: 'Vagas reservadas do Pioneiro', kind: 'int' },
      { key: 'plus_launch_free_until', label: 'Plus grátis até', kind: 'date' },
    ],
  },
  {
    title: 'Calendário',
    keys: [{ key: 'year_review_from', label: 'Retrospectiva a partir de', kind: 'date' }],
  },
  {
    title: 'Pontuação',
    keys: [
      { key: 'referral_first_mission_bonus', label: 'Bônus de indicação', kind: 'int' },
      { key: 'room_chest_bonus_steps', label: 'Baú da sala (passos)', kind: 'int' },
    ],
  },
];

export async function loadRemoteConfig() {
  const rc = getRemoteConfig(app);
  rc.settings.minimumFetchIntervalMillis = 60_000;
  rc.settings.fetchTimeoutMillis = 10_000;
  await fetchAndActivate(rc);
  return getAll(rc);
}

/** { text, on } — `on` só para booleanos. */
export function rcValue(all, { key, kind }) {
  const v = all?.[key];
  if (!v || v.getSource() === 'static') return { text: 'não definido (usa o padrão do app)', on: null };
  const raw = v.asString();
  if (kind === 'bool') return { text: v.asBoolean() ? 'ligado' : 'desligado', on: v.asBoolean() };
  if (kind === 'date') return { text: raw || 'vazio', on: null };
  return { text: raw, on: null };
}
