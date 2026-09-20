import 'package:flutter/material.dart';
import '../data/bible_book_intros.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Resumo histórico no seletor de capítulos — prosa + ficha (quem, quando, para).
class BibleBookIntroCard extends StatelessWidget {
  final BibleBook book;

  const BibleBookIntroCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final intro = BibleBookIntros.of(
      book.abbrev,
      bookName: book.name,
    );
    if (intro == null) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final who = intro.byTradition
        ? '${intro.authorName} · tradição'
        : intro.authorName;

    return GlassCard(
      tint: AppColors.cedar,
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            intro.title,
            style: AppTypography.display(
              size: 22,
              height: 1.15,
              color: a.text,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.cedar,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            intro.summary,
            style: AppTypography.body(
              size: 15,
              height: 1.55,
              weight: FontWeight.w600,
              color: a.text.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Meta(label: 'Quem', value: who)),
              const SizedBox(width: AppSpace.md),
              Expanded(child: _Meta(label: 'Quando', value: intro.when)),
              const SizedBox(width: AppSpace.md),
              Expanded(child: _Meta(label: 'Para quem', value: intro.audience)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String label;
  final String value;

  const _Meta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.label(
            size: 9,
            letterSpacing: 1.1,
            color: AppColors.cedar,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            size: 13,
            height: 1.25,
            weight: FontWeight.w800,
            color: a.text,
          ),
        ),
      ],
    );
  }
}
