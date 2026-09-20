import 'package:flutter/material.dart';

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
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
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
          // Opacity 0 still paints — needed for toImage.
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
            padding: AppMetrics.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CinematicIcon(
                  glyph: seal.glyph,
                  size: 22,
                  accent: AppColors.accent,
                  framed: false,
                ),
                const SizedBox(height: 10),
                Text(
                  seal.name,
                  style: AppTypography.display(size: 22, color: a.text),
                ),
                const SizedBox(height: 8),
                Text(
                  seal.fact,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 15, color: a.text),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 20),
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
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Encontros', style: AppTypography.title(size: 16, color: a.text)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.body(size: 12, color: a.textMuted(0.6)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final seal in shown)
                _SealMedallion(
                  seal: seal,
                  unlocked: unlocked.any((s) => s.id == seal.id),
                ),
            ],
          ),
        ],
      ),
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
    return GestureDetector(
      key: ValueKey(seal.id),
      behavior: HitTestBehavior.opaque,
      onTap: unlocked ? () => showCharacterSealSheet(context, seal) : null,
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.28),
                  border: Border.all(
                    color: unlocked
                        ? AppColors.accent.withValues(alpha: 0.55)
                        : a.cardBorder,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: unlocked ? 1 : 0.28,
                    child: CinematicIcon(
                      glyph: seal.glyph,
                      size: 18,
                      accent: unlocked ? AppColors.accent : a.textMuted(0.7),
                      framed: false,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              unlocked ? seal.name : '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(size: 11, color: a.text),
            ),
          ],
        ),
      ),
    );
  }
}
