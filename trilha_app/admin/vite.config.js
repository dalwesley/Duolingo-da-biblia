import { defineConfig, loadEnv } from 'vite';

const FIREBASE_ENV = [
  'VITE_FIREBASE_API_KEY',
  'VITE_FIREBASE_AUTH_DOMAIN',
  'VITE_FIREBASE_PROJECT_ID',
  'VITE_FIREBASE_STORAGE_BUCKET',
  'VITE_FIREBASE_MESSAGING_SENDER_ID',
  'VITE_FIREBASE_APP_ID',
];

function assertProductionEnv(env) {
  if (env.VITE_ADMIN_SKIP_AUTH === 'true') {
    throw new Error(
      'Build bloqueado: VITE_ADMIN_SKIP_AUTH=true. Defina false em admin/.env antes do deploy.',
    );
  }
  const missing = FIREBASE_ENV.filter((key) => !env[key]);
  if (missing.length) {
    throw new Error(`Build bloqueado: variáveis ausentes → ${missing.join(', ')}`);
  }
}

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  if (mode === 'production') assertProductionEnv(env);

  return {
    server: { port: 5174 },
    build: {
      outDir: 'dist',
      emptyOutDir: true,
      sourcemap: false,
    },
  };
});
