import 'package:flutter/material.dart';

import '../data/entry_trails.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

void showCharacterSealSheet(BuildContext context, CharacterSeal seal) {
  final a = Appearance.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: GlassCard(
          elevated: true,
          padding: AppMetrics.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: seal.glyph,
                size: 56,
                accent: AppColors.accent,
                glowing: true,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              CopperCta(
                label: 'Guardar',
                expanded: true,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      );
    },
  );
}

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
            ? '1 selo — fato e verso, no texto.'
            : '${unlocked.length} selos — fato e verso, no texto.')
        : unlocked.isEmpty
            ? (next == null
                ? 'Fato e verso de quem o texto já mostrou.'
                : 'O próximo abre em ${next.name}.')
            : next == null
                ? '${unlocked.length} de ${CharacterSeals.all.length} — fato e verso, no texto.'
                : '${unlocked.length} de ${CharacterSeals.all.length} · próximo: ${next.name}';
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selos', style: AppTypography.title(size: 16, color: a.text)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.body(size: 12, color: a.textMuted(0.6)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final seal in shown)
                GestureDetector(
                  onTap: unlocked.any((s) => s.id == seal.id)
                      ? () => showCharacterSealSheet(context, seal)
                      : null,
                  child: Opacity(
                    opacity: unlocked.any((s) => s.id == seal.id) ? 1 : 0.35,
                    child: Column(
                      children: [
                        CinematicIcon(
                          glyph: seal.glyph,
                          size: 44,
                          accent: AppColors.accent,
                          framed: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unlocked.any((s) => s.id == seal.id) ? seal.name : '?',
                          style: AppTypography.body(size: 11, color: a.text),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
