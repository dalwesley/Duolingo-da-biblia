import { doc, getDoc } from 'firebase/firestore';
import { db } from './firebase.js';
import { getUser, skipAuth } from './auth.js';

let cachedProfile = null;
let profileLoadError = null;

export async function loadUserRole() {
  const user = getUser();
  profileLoadError = null;
  if (!user?.uid) {
    cachedProfile = null;
    return null;
  }

  if (skipAuth) {
    cachedProfile = {
      role: 'admin',
      email: user.email || 'dev@local',
      permissions: { trails: true, bank: true, studies: true },
      devBypass: true,
    };
    return 'admin';
  }

  try {
    const snap = await getDoc(doc(db, 'admin_users', user.uid));
    if (!snap.exists()) {
      cachedProfile = null;
      return null;
    }
    cachedProfile = snap.data();
  } catch (err) {
    cachedProfile = null;
    profileLoadError = err?.code === 'permission-denied' ? 'permission' : 'load';
  }
  return cachedProfile?.role || null;
}

export function getProfileLoadError() {
  return profileLoadError;
}

export function getProfile() {
  return cachedProfile;
}

export function getRole() {
  return cachedProfile?.role || null;
}

export function getUserEmail() {
  return cachedProfile?.email || getUser()?.email || '';
}

export function canAccessRoute(routeKey) {
  if (!cachedProfile) return false;
  if (cachedProfile.role === 'admin') return true;
  if (routeKey === 'dashboard' || routeKey === 'import') return true;
  if (routeKey === 'trails' || routeKey.startsWith('trail:')) {
    return Boolean(cachedProfile.permissions?.trails);
  }
  if (routeKey === 'bank') return Boolean(cachedProfile.permissions?.bank);
  if (routeKey === 'studies') return Boolean(cachedProfile.permissions?.studies);
  return false;
}

export function can(action) {
  if (!cachedProfile) return false;
  if (cachedProfile.role === 'admin') return true;
  if (action === 'edit' || action === 'delete') return true;
  return false;
}

export function roleLabel(role) {
  return { admin: 'Administrador', editor: 'Editor' }[role] || role;
}
