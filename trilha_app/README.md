# Trilha App (Flutter)

App nativo para iOS e Android — aprenda a Bíblia em missões gamificadas.

## Rodar no celular

### iPhone (com cabo USB)

```bash
cd trilha_app
flutter pub get
flutter devices          # veja seu iPhone listado
flutter run              # instala e abre no aparelho
```

Requisitos: Xcode instalado, iPhone em modo desenvolvedor, confiar no certificado.

### Android (com cabo USB ou Wi-Fi)

```bash
cd trilha_app
flutter pub get
flutter devices
flutter run
```

Ative **Depuração USB** nas Opções do desenvolvedor.

### Sem cabo (mesma rede Wi-Fi)

```bash
flutter run -d <device-id>
```

## Atualizar conteúdo das trilhas

O conteúdo vem de `assets/data/trails.json`, gerado a partir do seed TypeScript:

```bash
# na raiz do monorepo
npm run db:export-flutter
```

## Build para publicar

```bash
# Android APK
flutter build apk --release

# iOS (requer Mac + Xcode)
flutter build ios --release
```

## Estrutura

- `lib/screens/` — splash, home, trilhas, config, mapa, lição, celebração
- `lib/services/progress_service.dart` — XP, streak, progresso local
- `assets/data/trails.json` — trilhas e perguntas
