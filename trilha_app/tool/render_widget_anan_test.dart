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
import 'dart:typed_data';
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

  // Prévia da lista "Adicionar widgets": o card em risco, como no aparelho.
  testWidgets('render preview', (tester) async {
    final fonts =
        '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
    await tester.runAsync(() async {
      await _loadFont('Roboto', '$fonts/Roboto-Bold.ttf');
      await _loadFont('MaterialIcons', '$fonts/MaterialIcons-Regular.otf');
    });
    const scale = 2.0;
    final key = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(320 * scale, 130 * scale));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: Transform.scale(scale: scale, child: const _PreviewCard()),
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
      'android/app/src/main/res/drawable-nodpi/widget_preview.png',
    ).writeAsBytesSync(await _capture(tester, key));
  });
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    const ink = Color(0xFFD9634A);
    return SizedBox(
      width: 320 * 2,
      height: 130 * 2,
      child: Center(
        child: Container(
          width: 320,
          height: 130,
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFFE9795A), Color(0xFFF6B784)],
            ),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Roboto', color: white),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xF2FFFFFF),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: ink,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '12',
                                  style: TextStyle(fontSize: 13, color: ink),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'MANTENHA SUA SEQUÊNCIA',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.66,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('12:10:53', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 4),
                      const Text(
                        '12 dias seguidos · falta 1 cena',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xE6FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const CloudMascot(
                  face: CloudFace.triste,
                  size: 84,
                  react: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
