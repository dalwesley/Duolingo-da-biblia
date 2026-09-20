import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/entry_trails.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'share_seal_card.dart';
import 'ui_primitives.dart';

Future<void> showCharacterSealSheet(
  BuildContext context,
  CharacterSeal seal,
) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    isScrollControlled: true,
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
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Stack(
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
          GlassCard(
            elevated: true,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
              child: Stack(
                children: [
                  const Positioned.fill(child: _EncounterAtmosphere()),
                  Padding(
                    padding: AppMetrics.cardPadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _EncounterSeal(
                          glyph: seal.glyph,
                          size: 72,
                          unlocked: true,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          seal.name.toUpperCase(),
                          style: AppTypography.label(
                            size: 12,
                            letterSpacing: 2.2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          seal.fact,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(size: 15, color: a.text),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          seal.verseRef,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w700,
                            color: a.textMuted(0.55),
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
                          label: _busy ? 'Preparando…' : 'Compartilhar',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Galeria 2×3 — os seis encontros. Travado = cera opaca, sem “?”.
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
    final a = Appearance.of(context);
    final unlocked = CharacterSeals.unlocked(completed);
    if (acquiredOnly && unlocked.isEmpty) return const SizedBox.shrink();

    final next = CharacterSeals.nextLocked(completed);
    final shown = acquiredOnly ? unlocked : CharacterSeals.all;

    final subtitle = acquiredOnly
        ? (unlocked.length == 1
            ? '1 encontro — fato e verso, no texto.'
            : '${unlocked.length} encontros — fato e verso, no texto.')
        : unlocked.isEmpty
            ? (next == null
                ? 'Fato e verso de quem o texto já mostrou.'
                : 'O próximo encontro abre em ${next.name}.')
            : next == null
                ? '${unlocked.length} de ${CharacterSeals.all.length} — a galeria está cheia.'
                : '${unlocked.length} de ${CharacterSeals.all.length} · próximo: ${next.name}';

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        child: Stack(
          children: [
            const Positioned.fill(child: _EncounterAtmosphere()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Encontros',
                          style: AppTypography.title(size: 16, color: a.text),
                        ),
                      ),
                      CountBadge(
                        '${unlocked.length}/${CharacterSeals.all.length}',
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: Text(
                      subtitle,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textMuted(0.58),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EncounterGallery(
                    seals: shown,
                    unlocked: unlocked,
                    nextId: next?.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncounterAtmosphere extends StatelessWidget {
  const _EncounterAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.92),
            radius: 1.18,
            colors: [
              AppColors.accent.withValues(alpha: 0.14),
              AppColors.accent.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }
}

class _EncounterGallery extends StatelessWidget {
  final List<CharacterSeal> seals;
  final List<CharacterSeal> unlocked;
  final String? nextId;

  const _EncounterGallery({
    required this.seals,
    required this.unlocked,
    this.nextId,
  });

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
                  next: seal.id == nextId,
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
  final bool next;

  const _SealMedallion({
    required this.seal,
    required this.unlocked,
    this.next = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      key: ValueKey(seal.id),
      behavior: HitTestBehavior.opaque,
      onTap: unlocked ? () => showCharacterSealSheet(context, seal) : null,
      child: Column(
        children: [
          _EncounterSeal(
            glyph: seal.glyph,
            size: 52,
            unlocked: unlocked,
            next: next && !unlocked,
          ),
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
                color: a.textMuted(0.78),
              ),
            ),
          ),
        ],
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
    final accent = unlocked
        ? AppColors.accent
        : next
            ? AppColors.accent.withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.22);
    final halo = size * 1.28;

    return SizedBox(
      width: halo,
      height: halo,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (unlocked || next)
            Container(
              width: size * 1.12,
              height: size * 1.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: unlocked ? 0.35 : 0.16),
                    blurRadius: unlocked ? 16 : 10,
                  ),
                ],
              ),
            ),
          CustomPaint(
            size: Size.square(size),
            painter: _EncounterSealPainter(
              accent: accent,
              unlocked: unlocked,
              next: next,
            ),
            child: Center(
              child: Opacity(
                opacity: unlocked
                    ? 1
                    : next
                        ? 0.42
                        : 0.22,
                child: CinematicIcon(
                  glyph: glyph,
                  size: size * 0.38,
                  accent: unlocked
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: next ? 0.7 : 0.45),
                  framed: false,
                  glowing: unlocked,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncounterSealPainter extends CustomPainter {
  final Color accent;
  final bool unlocked;
  final bool next;

  const _EncounterSealPainter({
    required this.accent,
    required this.unlocked,
    required this.next,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final rimR = outerR * 0.96;
    final faceR = outerR * 0.78;

    final rimLight = unlocked
        ? const Color(0xFFE8C878)
        : next
            ? const Color(0xFF8A7A48)
            : const Color(0xFF4A5260);
    final rimMid = unlocked
        ? const Color(0xFFC9A048)
        : next
            ? const Color(0xFF4A4230)
            : const Color(0xFF2E3540);
    final rimDark = unlocked
        ? const Color(0xFF8A6020)
        : const Color(0xFF181C22);
    final faceLight = unlocked
        ? const Color(0xFF3A2E14)
        : const Color(0xFF323A48);
    final faceMid = unlocked
        ? const Color(0xFF1C1810)
        : const Color(0xFF1A1E26);
    final faceDark = const Color(0xFF0A0C10);

    final rimRect = Rect.fromCircle(center: center, radius: rimR);
    final rim = Paint()
      ..shader = SweepGradient(
        colors: [rimDark, rimMid, rimLight, rimDark],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(rimRect);
    canvas.drawCircle(center, rimR, rim);

    final faceRect = Rect.fromCircle(center: center, radius: faceR);
    final face = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.42),
        radius: 1.05,
        colors: [faceLight, faceMid, faceDark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(faceRect);
    canvas.drawCircle(center, faceR, face);

    final well = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: unlocked ? 0.22 : next ? 0.1 : 0.04),
          Colors.transparent,
        ],
      ).createShader(faceRect);
    canvas.drawCircle(center, faceR * 0.82, well);

    final inner = Paint()
      ..color = rimLight.withValues(alpha: unlocked ? 0.45 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, outerR * 0.62, inner);

    final edge = Paint()
      ..color = rimDark.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, rimR, edge);

    final tick = Paint()
      ..color = rimLight.withValues(alpha: unlocked ? 0.5 : 0.18)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    const count = 12;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        center + Offset(cos * rimR * 0.88, sin * rimR * 0.88),
        center + Offset(cos * rimR * 0.97, sin * rimR * 0.97),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EncounterSealPainter old) =>
      old.accent != accent || old.unlocked != unlocked || old.next != next;
}
