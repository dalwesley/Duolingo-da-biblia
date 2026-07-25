# Release — STWAY App

## Pré-requisitos de produção

- [x] Keystore de release em máquina segura (não commitado) — `~/.stway/stway-release.keystore`
- [x] `android/key.properties` preenchido (gitignored; ver `key.properties.example`)
- [ ] Firebase Crashlytics + Analytics ativos no Console
- [ ] SHA-1/SHA-256 no Firebase (Google Sign-In) — **upload key + App signing key da Play** (ver abaixo)
- [ ] `firestore.rules` publicados (`firebase deploy --only firestore:rules`)
- [ ] Conteúdo seeded (`cd admin && npm run seed`)
- [ ] iOS: `GoogleService-Info.plist` + `flutterfire configure` (ainda pendente)

### Fingerprints Android (Firebase → Project settings → Android app)

Sem esses SHA no Firebase, o Google Sign-In no app da Play (teste interno / produção) falha com **"Login cancelado."** O `google-services.json` commitado hoje só tem o SHA de **debug**.

**1. Upload key** (keystore `~/.stway/stway-release.keystore`):

```
SHA-1:   22:07:64:79:DE:62:17:88:8B:B0:E0:9F:9C:26:44:A1:E9:1B:B5:71
SHA-256: 88:73:25:4D:9D:17:5F:B0:32:E2:C2:A8:EA:62:17:3C:67:70:B3:56:0C:4E:F9:EB:D7:73:BA:AE:62:97:E9:43
```

**2. App signing key da Play** (obrigatório para builds da loja):

Play Console → STWAY → Configuração → Integridade do app → Assinatura do app → copie SHA-1 e SHA-256 de **Assinatura de apps do Google Play** e cole no Firebase também.

Depois: baixe de novo o `google-services.json`, substitua `android/app/google-services.json`, e aguarde ~5–15 min (propagação OAuth). Não precisa subir novo AAB só por causa do SHA.

Credenciais locais: `~/.stway/release-credentials.txt` (guarde no password manager e apague o arquivo).

## Build de release (Android)

1. Keystore (já criado nesta máquina):
```bash
# Localização: ~/.stway/stway-release.keystore
# Alias: stway
```

2. `trilha_app/android/key.properties` (não commitar) — já configurado localmente:
```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=stway
storeFile=/Users/SEU_USER/.stway/stway-release.keystore
```

Sem `key.properties`, o Gradle usa signing **debug** (só para `flutter run --release` local).

3. Build:
```bash
cd trilha_app
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle --release
```

O AAB estará em `build/app/outputs/bundle/release/app-release.aab`.

## Play Store — Teste interno (beta fechado)

1. [Google Play Console](https://play.google.com/console) → app "STWAY"
2. Envie o AAB em **Teste interno**
3. Convide 10–20 testadores
4. No Firebase Analytics, acompanhe: `app_open`, `login`, `home_view`, `lesson_start`, `lesson_complete`

## Telemetria (funil D1/D7)

Eventos em `AnalyticsService`:
- `app_open` — splash autenticado
- `login` / `login_failed`
- `home_view`
- `difficulty_pick`
- `lesson_start` / `lesson_complete`

Crashes: Firebase Crashlytics (coleta só em release).

## Admin / conteúdo

```bash
cd admin
npm run prepare:content
npm run seed
```

Ou painel **Importar**. Após o 1º seed, `content_meta/bootstrap_locked` fecha self-create de `admin_users`.

## Ícone

```bash
cd trilha_app
dart run flutter_launcher_icons
```

## Backup de progresso

Configurações → Exportar / Importar JSON.
