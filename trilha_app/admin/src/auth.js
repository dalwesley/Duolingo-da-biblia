import {
  onAuthStateChanged,
  signInAnonymously,
  signInWithEmailAndPassword,
  signOut,
} from 'firebase/auth';
import { auth } from './firebase.js';

export { auth };
export const skipAuth = import.meta.env.VITE_ADMIN_SKIP_AUTH === 'true';

let currentUser = null;
let anonAttempted = false;

export function getUser() {
  return currentUser;
}

export function mapAuthError(err) {
  const code = err?.code || '';
  const map = {
    'auth/invalid-credential': 'E-mail ou senha incorretos.',
    'auth/wrong-password': 'E-mail ou senha incorretos.',
    'auth/user-not-found': 'E-mail ou senha incorretos.',
    'auth/invalid-email': 'E-mail inválido.',
    'auth/user-disabled': 'Conta desativada.',
    'auth/too-many-requests': 'Muitas tentativas. Aguarde alguns minutos.',
    'auth/network-request-failed': 'Sem conexão. Verifique a internet.',
    'auth/operation-not-allowed': 'Auth anônimo/e-mail não habilitado no Firebase.',
  };
  return map[code] || err?.message || 'Não foi possível entrar.';
}

export function watchAuth(onChange) {
  return onAuthStateChanged(auth, async (user) => {
    currentUser = user;
    if (!user && skipAuth && !anonAttempted) {
      anonAttempted = true;
      try {
        await signInAnonymously(auth);
        return;
      } catch (err) {
        if (import.meta.env.DEV) {
          console.warn('Auth anônimo falhou:', err);
        }
        onChange(null);
        return;
      }
    }
    onChange(user);
  });
}

export async function signIn(email, password) {
  return signInWithEmailAndPassword(auth, email.trim(), password);
}

export async function logOut() {
  await signOut(auth);
}

export function isAuthenticated() {
  return currentUser != null;
}
