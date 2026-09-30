import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../theme/app_theme.dart';

/// Mini bandeira do seletor de idioma — pintada, sem emoji.
/// Auto não tem bandeira própria: usa a do idioma que o aparelho resolve.
enum LanguageFlagId { br, us, es }

extension LanguageFlagIdX on LanguageFlagId {
  static LanguageFlagId fromLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => LanguageFlagId.us,
      'es' => LanguageFlagId.es,
      _ => LanguageFlagId.br, // pt e fallback
    };
  }

  /// Auto → idioma do aparelho; senão a bandeira fixa da escolha.
  static LanguageFlagId forAppLanguage(AppLanguage lang) {
    if (lang == AppLanguage.device) {
      return fromLocale(L10n.resolve(AppLanguage.device));
    }
    return switch (lang) {
      AppLanguage.pt => LanguageFlagId.br,
      AppLanguage.en => LanguageFlagId.us,
      AppLanguage.es => LanguageFlagId.es,
      AppLanguage.device => LanguageFlagId.br,
    };
  }
}

class LanguageFlag extends StatelessWidget {
  final LanguageFlagId id;
  final double width;
  final double height;

  /// Selo “Auto” sobre a bandeira resolvida do aparelho.
  final bool autoBadge;

  const LanguageFlag({
    super.key,
    required this.id,
    this.width = 18,
    this.height = 12,
    this.autoBadge = false,
  });

  factory LanguageFlag.forAppLanguage(
    AppLanguage lang, {
    Key? key,
    double width = 18,
    double height = 12,
  }) {
    return LanguageFlag(
      key: key,
      id: LanguageFlagIdX.forAppLanguage(lang),
      width: width,
      height: height,
      autoBadge: lang == AppLanguage.device,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = height * 0.55;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.5),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.28),
                  width: 0.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CustomPaint(painter: _FlagPainter(id)),
              ),
            ),
          ),
          if (autoBadge)
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: badge,
                height: badge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.nightElevated,
                  border: Border.all(
                    color: AppRoles.presence.withValues(alpha: 0.9),
                    width: 1,
                  ),
                ),
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: badge * 0.55,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: AppRoles.chrome,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  final LanguageFlagId id;

  _FlagPainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    switch (id) {
      case LanguageFlagId.br:
        _br(canvas, size);
      case LanguageFlagId.us:
        _us(canvas, size);
      case LanguageFlagId.es:
        _es(canvas, size);
    }
  }

  void _br(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF009C3B));
    final diamond = Path()
      ..moveTo(size.width * 0.5, size.height * 0.12)
      ..lineTo(size.width * 0.92, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.88)
      ..lineTo(size.width * 0.08, size.height * 0.5)
      ..close();
    canvas.drawPath(diamond, Paint()..color = const Color(0xFFFFDF00));
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.shortestSide * 0.22,
      Paint()..color = const Color(0xFF002776),
    );
  }

  void _us(Canvas canvas, Size size) {
    const red = Color(0xFFB22234);
    const white = Color(0xFFFFFFFF);
    const blue = Color(0xFF3C3B6E);
    final stripeH = size.height / 7;
    for (var i = 0; i < 7; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, stripeH * i, size.width, stripeH + 0.5),
        Paint()..color = i.isEven ? red : white,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.42, stripeH * 4),
      Paint()..color = blue,
    );
    final paint = Paint()..color = white;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.07 + col * size.width * 0.1,
            stripeH * 0.55 + row * stripeH * 1.15,
          ),
          0.7,
          paint,
        );
      }
    }
  }

  void _es(Canvas canvas, Size size) {
    const red = Color(0xFFAA151B);
    const yellow = Color(0xFFF1BF00);
    canvas.drawRect(Offset.zero & size, Paint()..color = red);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.25, size.width, size.height * 0.5),
      Paint()..color = yellow,
    );
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) => oldDelegate.id != id;
}
