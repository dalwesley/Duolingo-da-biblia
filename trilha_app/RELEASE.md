# Release — Steway App

## Pré-requisitos de produção

- [ ] Keystore de release em máquina segura (não commitado)
- [ ] `android/key.properties` preenchido (ver `key.properties.example`)
- [ ] Firebase Crashlytics + Analytics ativos no Console
- [ ] SHA-1/SHA-256 do keystore no Firebase (Google Sign-In)
- [ ] `firestore.rules` publicados (`firebase deploy --only firestore:rules`)
- [ ] Conteúdo seeded (`cd admin && npm run seed`)
- [ ] iOS: `GoogleService-Info.plist` + `flutterfire configure` (ainda pendente)

## Build de release (Android)

1. Crie um keystore (uma vez):
```bash
keytool -genkey -v -keystore ~/steway-release.keystore -alias steway -keyalg RSA -keysize 2048 -validity 10000
```

2. Crie `trilha_app/android/key.properties` (não commitar):
```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=steway
storeFile=/caminho/absoluto/para/steway-release.keystore
```

Sem `key.properties`, o Gradle usa signing **debug** (só para `flutter run --release` local).

3. Build:
```bash
cd trilha_app
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle --release
```

O AAB estará em `build/app/outputs/bundle/release/`.

## Play Store — Teste interno (beta fechado)

1. [Google Play Console](https://play.google.com/console) → app "Steway"
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
