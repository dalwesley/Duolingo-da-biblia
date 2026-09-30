import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';

import '../data/entry_trails.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'embossed_glyph.dart';
import 'share_seal_card.dart';
import 'ui_primitives.dart';
import 'profile_privacy.dart';
import 'relic_panel.dart';
import '../models/caravan_profile_prefs.dart';

Future<void> showCharacterSealSheet(BuildContext context, CharacterSeal seal) {
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
    builder: (_) => _SealEncounterSheet(seal: seal),
  );
}

class _SealEncounterSheet extends StatefulWidget {
  final CharacterSeal seal;

  const _SealEncounterSheet({required this.seal});

  @override
  State<_SealEncounterSheet> createState() => _SealEncounterSheetState();
}

class _SealEncounterSheetState extends State<_SealEncounterSheet> {
  final _shareKey = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await shareSealImage(boundaryKey: _shareKey, seal: widget.seal);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final seal = widget.seal;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                width: 360,
                child: RepaintBoundary(
                  key: _shareKey,
                  child: ShareSealCard(seal: seal),
                ),
              ),
            ),
          ),
        ),
        AppSheetPanel(
          background: const RelicAtmosphere(accent: AppRoles.reward),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EncounterSeal(glyph: seal.glyph, size: 72, unlocked: true),
              const SizedBox(height: 14),
              SectionLabel(seal.name, size: 12, color: AppRoles.reward),
              const SizedBox(height: 10),
              Text(
                seal.fact,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 14, color: a.text),
              ),
              const SizedBox(height: 18),
              Text(
                seal.verseRef,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: a.textFaint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                seal.verseText,
                textAlign: TextAlign.center,
                style: AppTypography.verse(size: 18, height: 1.45),
              ),
              const SizedBox(height: 22),
              CopperCta(
                label: _busy ? context.l10n.bibleSharePreparing : context.l10n.commonShare,
                expanded: true,
                leading: CinematicGlyph.share,
                trailing: null,
                busy: _busy,
                onTap: _busy ? null : _share,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Galeria 2×3 — seis selos de cera. Travado = cera fria, sem “?”.
class CharacterSealsStrip extends StatelessWidget {
  final Iterable<String> completed;
  final bool acquiredOnly;

  const CharacterSealsStrip({
    super.key,
    required this.completed,
    this.acquiredOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = CharacterSeals.unlocked(completed);
    if (acquiredOnly && unlocked.isEmpty) return const SizedBox.shrink();

    final next = CharacterSeals.nextLocked(completed);
    final shown = acquiredOnly
        ? unlocked
        : [
            ...unlocked,
            ...CharacterSeals.all.where(
              (s) => unlocked.every((u) => u.id != s.id),
            ),
          ];

    final l10n = context.l10n;
    final subtitle = acquiredOnly
        ? l10n.sealsCountFact(unlocked.length)
        : unlocked.isEmpty
        ? (next == null
              ? l10n.sealsEmptyHint
              : l10n.sealsStartsAt(next.name))
        : next == null
        ? l10n.sealsAllRevealed(unlocked.length, CharacterSeals.all.length)
        : l10n.sealsStillInText(
            unlocked.length,
            CharacterSeals.all.length,
            next.name,
          );

    // Selo é recompensa: o card leva o wash e o filete de [AppRoles.reward].
    return RelicPanel(
      accent: AppRoles.reward,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: l10n.sealsTitle,
            whisper: subtitle,
            action: PrivacyEye(
              sections: const {CaravanProfileSection.trails},
              label: l10n.pilgrimSealsAndTrails,
            ),
          ),
          const SizedBox(height: 16),
          _EncounterGallery(seals: shown, unlocked: unlocked),
        ],
      ),
    );
  }
}

class _EncounterGallery extends StatelessWidget {
  final List<CharacterSeal> seals;
  final List<CharacterSeal> unlocked;

  const _EncounterGallery({required this.seals, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 3;
        const gap = 12.0;
        final cellW = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [
            for (final seal in seals)
              SizedBox(
                width: cellW,
                child: _SealMedallion(
                  seal: seal,
                  unlocked: unlocked.any((s) => s.id == seal.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SealMedallion extends StatelessWidget {
  final CharacterSeal seal;
  final bool unlocked;

  const _SealMedallion({required this.seal, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: unlocked,
      label: unlocked ? context.l10n.sealsSemanticsNamed(seal.name) : context.l10n.sealsSemanticsLocked,
      child: GestureDetector(
        key: ValueKey(seal.id),
        behavior: HitTestBehavior.opaque,
        onTap: unlocked ? () => showCharacterSealSheet(context, seal) : null,
        child: Transform.rotate(
          angle: ((seal.id.hashCode % 9) - 4) * 0.028,
          child: Column(
            children: [
              _EncounterSeal(glyph: seal.glyph, size: 58, unlocked: unlocked),
              const SizedBox(height: 8),
              SizedBox(
                height: 16,
                child: Text(
                  unlocked ? seal.name : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 0.3,
                    color: a.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EncounterSeal extends StatelessWidget {
  final CinematicGlyph glyph;
  final double size;
  final bool unlocked;
  final bool next;

  const _EncounterSeal({
    required this.glyph,
    required this.size,
    required this.unlocked,
    this.next = false,
  });

  @override
  Widget build(BuildContext context) {
    final glyphSize = size * 0.36;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _WaxSealPainter(unlocked: unlocked, next: next),
          ),
          if (unlocked || next)
            EmbossedGlyph(
              glyph: glyph,
              size: glyphSize,
              fill: unlocked
                  ? const Color(0xFFE8C878)
                  : const Color(0xFF8A7050),
              groove: unlocked
                  ? const Color(0xFF3A1808)
                  : const Color(0xFF121018),
              ridge: unlocked
                  ? const Color(0xFFFFF0C8)
                  : const Color(0xFF6A5A40),
              depth: unlocked ? 1.2 : 0.7,
              opacity: unlocked ? 1 : 0.38,
            ),
        ],
      ),
    );
  }
}

/// Cera recortada — lóbulos de lacre, não um poço de ícone.
class _WaxSealPainter extends CustomPainter {
  final bool unlocked;
  final bool next;

  const _WaxSealPainter({required this.unlocked, required this.next});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final path = _waxPath(center, r * 0.92);

    final waxLight = unlocked
        ? const Color(0xFFB24A28)
        : next
        ? const Color(0xFF5A3A28)
        : const Color(0xFF2E323A);
    final waxMid = unlocked
        ? const Color(0xFF7A2414)
        : next
        ? const Color(0xFF3A2418)
        : const Color(0xFF1A1E26);
    final waxDark = unlocked
        ? const Color(0xFF2C0C08)
        : const Color(0xFF0C0E12);

    canvas.drawPath(
      path.shift(const Offset(0, 2.4)),
      Paint()
        ..color = Colors.black.withValues(alpha: unlocked ? 0.5 : 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.38),
          radius: 1.05,
          colors: [waxLight, waxMid, waxDark],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    final pressR = r * 0.58;
    canvas.drawCircle(
      center,
      pressR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 0.95,
          colors: [
            waxDark.withValues(alpha: 0.15),
            waxDark.withValues(alpha: unlocked ? 0.55 : 0.7),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: pressR)),
    );

    if (unlocked || next) {
      final thread = Paint()
        ..color = (unlocked ? AppRoles.reward : const Color(0xFF8A7048))
            .withValues(alpha: unlocked ? 0.85 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = unlocked ? 1.6 : 1.1;
      canvas.drawCircle(center, pressR * 0.96, thread);
      canvas.drawCircle(
        center,
        pressR * 0.82,
        Paint()
          ..color = waxDark.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    canvas.save();
    canvas.clipPath(path);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.18, -r * 0.28),
        width: r * 1.05,
        height: r * 0.48,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: unlocked ? 0.28 : 0.06),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = waxDark.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  Path _waxPath(Offset center, double r) {
    const lobes = 9;
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r * 0.74));
    for (var i = 0; i < lobes; i++) {
      final a = (i / lobes) * math.pi * 2 - math.pi / 2;
      final lobe =
          center + Offset(math.cos(a) * r * 0.24, math.sin(a) * r * 0.24);
      path.addOval(Rect.fromCircle(center: lobe, radius: r * 0.58));
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _WaxSealPainter old) =>
      old.unlocked != unlocked || old.next != next;
}
