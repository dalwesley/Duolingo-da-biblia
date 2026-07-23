# STWAY App (Flutter)

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

## Conteúdo das trilhas

O app lê trilhas do Firestore (`content_trails`), com cache local e fallback em `assets/data/trails.json`.

Para editar / publicar conteúdo, use o painel em `../admin/`.

## Estudo bíblico (Strong)

Na leitura, toque num versículo → **Estudar** para ver palavras originais, Strong, morfologia, concordância e referências cruzadas (offline).

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

- `lib/screens/` — splash, home, trilhas, config, mapa, lição, celebração
- `lib/services/` — progresso, Firebase, catálogo de conteúdo
- `assets/data/` — fallback offline (Bíblia, trilhas)

O painel web Firebase fica em `../admin/`, separado do app.
