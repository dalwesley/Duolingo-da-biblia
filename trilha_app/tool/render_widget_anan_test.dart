// Gera as imagens do Anan (corpo + rosto) usadas pelos widgets nativos.
//
// O rosto do Anan é desenhado no Flutter, então o widget da tela inicial
// (Android e iOS) não consegue montá-lo sozinho. Rode quando o mascote mudar:
//
//   flutter test tool/render_widget_anan_test.dart
//
// Saída: android/.../drawable-nodpi/widget_anan_<cara>.png,
// ios/TrilhaWidget/Assets.xcassets/widget_anan_<cara>.imageset e a prévia
// da lista de widgets do Android (drawable-nodpi/widget_preview.png).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/cloud_mascot.dart';

const _faces = [CloudFace.triste, CloudFace.sucesso, CloudFace.feliz];
const _size = 360.0;

Future<Uint8List> _capture(WidgetTester tester, GlobalKey key) async {
  final bytes = await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

void main() {
  for (final face in _faces) {
    testWidgets('render ${face.name}', (tester) async {
      final key = GlobalKey();
      await tester.binding.setSurfaceSize(const Size(_size, _size));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: CloudMascot(face: face, size: _size, react: false),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await precacheImage(
          AssetImage(face.body),
          tester.element(find.byKey(key)),
        );
      });
      await tester.pump();

      final bytes = await _capture(tester, key);

      final name = 'widget_anan_${face.name}';
      File('android/app/src/main/res/drawable-nodpi/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      final set = Directory('ios/TrilhaWidget/Assets.xcassets/$name.imageset')
        ..createSync(recursive: true);
      File('${set.path}/$name.png').writeAsBytesSync(bytes);
      File('${set.path}/Contents.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'images': [
            {'filename': '$name.png', 'idiom': 'universal'},
          ],
          'info': {'author': 'xcode', 'version': 1},
        }),
      );

      await tester.pumpWidget(const SizedBox());
    });
  }

  // Prévias da lista "Adicionar widgets": os dois cards em risco, como no
  // aparelho.
  const previews = {
    'widget_preview': Size(320, 146),
    'widget_preview_small': Size(170, 72),
  };
  for (final MapEntry(key: name, value: size) in previews.entries) {
    testWidgets('render $name', (tester) async {
      final fonts =
          '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
      await tester.runAsync(() async {
        await _loadFont('Roboto', '$fonts/Roboto-Bold.ttf');
        await _loadFont('MaterialIcons', '$fonts/MaterialIcons-Regular.otf');
      });
      const scale = 2.0;
      final key = GlobalKey();
      await tester.binding.setSurfaceSize(size * scale);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox.fromSize(
                  size: size * scale,
                  child: Center(
                    child: Transform.scale(
                      scale: scale,
                      child: _PreviewCard(size: size, small: size.width < 200),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await precacheImage(
          AssetImage(CloudFace.triste.body),
          tester.element(find.byKey(key)),
        );
      });
      await tester.pump();
      File(
        'android/app/src/main/res/drawable-nodpi/$name.png',
      ).writeAsBytesSync(await _capture(tester, key));
    });
  }
}

const _white = Color(0xFFFFFFFF);
const _ink = Color(0xFFD9634A);

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.size, required this.small});

  final Size size;
  final bool small;

  @override
  Widget build(BuildContext context) {
    const decoration = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(22)),
      gradient: LinearGradient(
        colors: [Color(0xFFE9795A), Color(0xFFF6B784)],
      ),
    );
    const style = TextStyle(fontFamily: 'Roboto', color: _white);
    if (!small) {
      // Igual ao trilha_home_widget.xml: Anan grande saindo pela borda.
      final anan = size.height.clamp(0.0, 140.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: decoration,
          child: DefaultTextStyle(
            style: style,
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  bottom: -18,
                  child: CloudMascot(
                    face: CloudFace.triste,
                    size: anan,
                    react: false,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 124, 14),
                  child: _LargeText(),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: decoration,
      child: DefaultTextStyle(
        style: style,
        child: const Row(
          children: [
            Expanded(child: _SmallText()),
            SizedBox(width: 4),
            CloudMascot(face: CloudFace.triste, size: 60, react: false),
          ],
        ),
      ),
    );
  }
}

class _SmallText extends StatelessWidget {
  const _SmallText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, size: 24, color: _white),
            SizedBox(width: 2),
            Text('12', style: TextStyle(fontSize: 24)),
          ],
        ),
        SizedBox(height: 2),
        Text('12:10:53', style: TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _LargeText extends StatelessWidget {
  const _LargeText();

  @override
  Widget build(BuildContext context) {
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.local_fire_department, size: 26, color: _white),
            SizedBox(width: 2),
            Text('12 dias', style: TextStyle(fontSize: 26, height: 1)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Mantenha sua sequência',
          maxLines: 1,
          style: TextStyle(fontSize: 13, color: Color(0xE6FFFFFF)),
        ),
        const SizedBox(height: 2),
        const Text('12:10:53', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Column(
                  children: [
                    Text(labels[i], style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 3),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < 3
                            ? const Color(0xF2FFFFFF)
                            : i == 3
                            ? null
                            : const Color(0x33FFFFFF),
                        border: i == 3
                            ? Border.all(color: _white, width: 2)
                            : null,
                      ),
                      child: i < 3
                          ? const Icon(Icons.check, size: 12, color: _ink)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
