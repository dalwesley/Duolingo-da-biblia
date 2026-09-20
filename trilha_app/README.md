# STWAY App (Flutter)

App nativo para iOS e Android — missões diárias para criar hábito de ler e estudar a Bíblia.

Versão: ver `pubspec.yaml` (**1.0.24+24**). Norte do produto: [`../docs/PRODUTO.md`](../docs/PRODUTO.md).

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

## Conteúdo das trilhas

O app lê trilhas do Firestore (`content_trails`), com cache em disco. Currículo não vem empacotado no app.

Para editar / publicar conteúdo, use o painel em `../admin/`.

## Estudo bíblico (Strong)

Na leitura **e na missão**, toque na referência → **Estudar** para Strong, morfologia, concordância (offline). Na aba Bíblia há TTS (voz alta).

Dados em `assets/data/bible_study.sqlite.gz` (STEPBible / openbible.info, CC BY). Para regenerar:

```bash
python3 scripts/build_bible_study_db.py
```

## Build para publicar

```bash
# Android APK
flutter build apk --release

# iOS (requer Mac + Xcode)
flutter build ios --release
```

## Estrutura

- `lib/screens/` — splash, home, trilhas, Bíblia, juntos, config, mapa, lição, celebração  
- `lib/services/` — progresso, Firebase, catálogo, FCM, Remote Config, assinatura (casca)  
- `assets/data/` — Bíblia + Strong empacotados; currículo vem do Firestore

O painel web Firebase fica em `../admin/`, separado do app.
