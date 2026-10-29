// Prévia do card de compartilhar do postal num aparelho de verdade:
//   flutter run -d <device> -t tool/postcard_preview.dart
// Mostra o card animando em loop. "Imagem" captura o quadro final como o
// compartilhar faz; "Vídeo" gera o MP4 pelo encoder nativo e mostra o
// caminho (adb pull para conferir). Não sobe Firebase.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trilha_app/l10n/gen/app_localizations.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/postcard.dart';
import 'package:trilha_app/widgets/postcard_share.dart';

void main() => runApp(const _Preview());

final _card = Postcard(
  slug: 'rute-04-asas',
  title: 'Debaixo das asas',
  ref: 'Rute 2:12',
  insight: 'Meu refúgio é debaixo das asas de Deus',
  art: 'assets/art/scene_rute-04-asas.jpg',
  on: DateTime(2026, 10, 12),
);

const _info = PostcardShareInfo(
  trailTitle: 'Rute',
  index: 4,
  total: 7,
  from: 'Dalwesley',
);

class _Preview extends StatefulWidget {
  const _Preview();

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview>
    with SingleTickerProviderStateMixin {
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();
  final _key = GlobalKey();
  final _nav = GlobalKey<NavigatorState>();
  final _t = ValueNotifier<double>(1);
  bool _offscreen = false;
  String _status = '';

  @override
  void dispose() {
    _loop.dispose();
    _t.dispose();
    super.dispose();
  }

  Future<void> _prepare(double t) async {
    final ctx = _nav.currentContext!;
    for (final a in [?_card.art, ...PostcardShareCard.assets]) {
      await precacheImage(AssetImage(a), ctx);
    }
    _t.value = t;
    setState(() => _offscreen = true);
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _image() async {
    await _prepare(1);
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    setState(() => _offscreen = false);
    if (bytes == null || !mounted) return;
    await showDialog<void>(
      context: _nav.currentContext!,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Image.memory(bytes.buffer.asUint8List()),
      ),
    );
  }

  Future<void> _video() async {
    await _prepare(0);
    final watch = Stopwatch()..start();
    try {
      final path = await PostcardVideo.render(
        boundaryKey: _key,
        t: _t,
        art: _card.art,
        onProgress: (v) => setState(() => _status = '${(v * 100).round()}%'),
      );
      setState(() => _status = '$path\n${watch.elapsed.inSeconds}s');
      debugPrint('POSTCARD_VIDEO $path ${watch.elapsed.inMilliseconds}ms');
    } catch (e) {
      setState(() => _status = 'erro: $e');
      debugPrint('POSTCARD_VIDEO_ERROR $e');
    } finally {
      setState(() => _offscreen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _nav,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        backgroundColor: AppColors.night,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        child: AnimatedBuilder(
                          animation: _loop,
                          builder: (_, _) => PostcardShareCard(
                            postcard: _card,
                            info: _info,
                            t: (_loop.value * 1.2).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton(
                        onPressed: _image,
                        child: const Text('Imagem'),
                      ),
                      FilledButton(
                        onPressed: _video,
                        child: const Text('Vídeo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (_offscreen)
              Positioned(
                left: -4000,
                top: 0,
                child: RepaintBoundary(
                  key: _key,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _t,
                    builder: (_, t, _) =>
                        PostcardShareCard(postcard: _card, info: _info, t: t),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
