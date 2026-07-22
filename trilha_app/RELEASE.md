# Release — Steway App

## Build de release (Android)

1. Crie um keystore:
```bash
keytool -genkey -v -keystore ~/trilha-release.keystore -alias trilha -keyalg RSA -keysize 2048 -validity 10000
```

2. Crie `android/key.properties` (não commitar):
```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=trilha
storeFile=/caminho/para/trilha-release.keystore
```

3. Build:
```bash
cd trilha_app
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle --release
```

O AAB estará em `build/app/outputs/bundle/release/`.

## Play Store — Teste interno

1. Acesse [Google Play Console](https://play.google.com/console)
2. Crie o app "Steway"
3. Envie o AAB em **Teste interno**
4. Convide testadores por e-mail

## Ícone do app

```bash
cd trilha_app
dart run flutter_launcher_icons
```

Substitua `assets/icon/app_icon.png` por um ícone 1024×1024 antes de gerar.

## Exportar conteúdo

```bash
npm run db:export-flutter
```

## Backup de progresso

Configurações → Exportar → compartilhe o JSON.
Para restaurar: copie o JSON e use Importar.
