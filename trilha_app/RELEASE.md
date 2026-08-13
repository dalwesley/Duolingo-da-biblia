# Release — STWAY App

## Pré-requisitos de produção

- [x] Keystore de release em máquina segura (não commitado) — `~/.stway/stway-release.keystore`
- [x] `android/key.properties` preenchido (gitignored; ver `key.properties.example`)
- [ ] Firebase Crashlytics + Analytics ativos no Console
- [x] SHA-1/SHA-256 no Firebase (Google Sign-In) — **upload key + App signing key real da Play** (ver abaixo)
- [ ] `firestore.rules` publicados (`firebase deploy --only firestore:rules`)
- [ ] Conteúdo seeded (`cd admin && npm run seed`)
- [ ] iOS: `GoogleService-Info.plist` + `flutterfire configure` (ainda pendente)

### Fingerprints Android (Firebase → Project settings → Android app)

Sem esses SHA no Firebase, o Google Sign-In no app da Play falha com **"Login cancelado. [16] Account reauth failed"** ou **`invalid-cert-hash`**.

Confira o SHA **do APK instalado** (Play re-assina; o valor da Console às vezes confunde com chave pós-quântica / anterior):

```bash
adb pull "$(adb shell pm path com.trilha.trilha_app | sed 's/package://')" /tmp/stway.apk
apksigner verify --print-certs /tmp/stway.apk
```

**1. Upload key** (keystore `~/.stway/stway-release.keystore` — builds locais / AAB enviado):

```
SHA-1:   22:07:64:79:DE:62:17:88:8B:B0:E0:9F:9C:26:44:A1:E9:1B:B5:71
SHA-256: 88:73:25:4D:9D:17:5F:B0:32:E2:C2:A8:EA:62:17:3C:67:70:B3:56:0C:4E:F9:EB:D7:73:BA:AE:62:97:E9:43
```

**2. App signing key da Play** (obrigatório — o que o celular recebe da loja; validado em 29/jul/2026):

```
SHA-1:   45:E8:CB:89:4B:6D:41:C7:DB:0A:D9:A4:EA:66:36:34:FF:E8:C8:19
SHA-256: 26:BB:D8:CE:0E:2D:FA:D4:5C:3C:B8:CE:A4:D7:9B:89:6F:26:46:C4:7F:1A:22:CE:F6:04:40:3E:44:67:25:C3
```

> Não use um SHA “clássico” da Console se ele não bater com o `apksigner` do APK instalado.

Depois de cadastrar: baixe de novo o `google-services.json`, substitua `android/app/google-services.json`, e aguarde ~5–15 min (propagação OAuth). Não precisa subir novo AAB só por causa do SHA.

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
4. No Firebase Analytics, acompanhe: `app_open`, `login`, `first_lesson_complete`, `retention_pulse`, `lesson_complete`
5. Protocolo humano: [`docs/D7_TESTER_PROTOCOLO.md`](../docs/D7_TESTER_PROTOCOLO.md)

### iOS — Sign in with Apple

- [ ] Firebase Console → Authentication → Sign-in method → **Apple** habilitado
- [x] Entitlement `com.apple.developer.applesignin` em `Runner.entitlements`
- [ ] Apple Developer → App ID `com.dalwesley.stway` com capability Sign In with Apple
- Build loja: **não** passar `OPEN_ALL_TRAILS=true` (default já é fechado)

## Telemetria (funil D1/D7)

Eventos em `AnalyticsService`:
- `app_open` — splash autenticado
- `login` / `login_failed` (`method`: google|apple)
- `retention_pulse` — `days_since_first_open`, `days_since_first_lesson`, `cohort_trail`
- `first_lesson_complete` — `ttv_seconds`, `trail_slug`, `mission_slug`
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
