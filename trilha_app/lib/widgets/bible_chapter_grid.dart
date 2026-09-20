import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'ui_primitives.dart';

/// Grade de capítulos — 6 colunas, lido em ouro cheio.
class BibleChapterGrid extends StatelessWidget {
  final int count;
  final bool Function(int chapter) isRead;
  final ValueChanged<int> onPick;

  const BibleChapterGrid({
    super.key,
    required this.count,
    required this.isRead,
    required this.onPick,
  });

  static const columns = 6;
  static const gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(count, (i) {
            final chapter = i + 1;
            return _ChapterDot(
              chapter: chapter,
              size: size,
              read: isRead(chapter),
              onTap: () {
                HapticFeedback.selectionClick();
                onPick(chapter);
              },
            );
          }),
        );
      },
    );
  }
}

class _ChapterDot extends StatelessWidget {
  final int chapter;
  final double size;
  final bool read;
  final VoidCallback onTap;

  const _ChapterDot({
    required this.chapter,
    required this.size,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final label = '$chapter';
    final fontSize = label.length > 2 ? 13.0 : 15.0;

    return Semantics(
      button: true,
      label: read ? 'Capítulo $chapter, lido' : 'Capítulo $chapter',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: read
              ? AppColors.inkOnAccent.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.08),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: read ? AppColors.accent : a.cardFillSoft,
              shape: BoxShape.circle,
              border: read
                  ? null
                  : Border.all(
                      color: a.cardBorder,
                      width: AppMetrics.cardBorderWidth,
                    ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.title(
                  size: fontSize,
                  color: read ? AppColors.inkOnAccent : a.text,
                ).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
