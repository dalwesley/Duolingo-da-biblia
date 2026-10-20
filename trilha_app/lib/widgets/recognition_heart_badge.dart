import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/recognition.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Coração com o número. No cofre é só o número; na medalha aberta, o toque
/// mostra quem reconheceu.
class HeartCountMark extends StatelessWidget {
  final int count;
  final bool compact;
  final VoidCallback? onTap;

  const HeartCountMark({
    super.key,
    required this.count,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final mark = DecoratedBox(
      decoration: BoxDecoration(
        color: AppRoles.success.withValues(alpha: compact ? 0.92 : 0.16),
        borderRadius: BorderRadius.circular(compact ? 10 : 22),
        border: Border.all(
          color: compact
              ? Appearance.of(context).cardFill
              : AppRoles.success.withValues(alpha: 0.7),
          width: compact ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8,
          vertical: compact ? 2 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.heart,
              size: compact ? 12 : AppMetrics.iconSm,
              accent: compact ? AppColors.textOnDark : AppRoles.success,
              framed: false,
            ),
            SizedBox(width: compact ? 2 : 4),
            Text(
              '$count',
              style: AppTypography.title(
                size: compact ? 10 : 14,
                color: compact ? AppColors.textOnDark : AppRoles.success,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      label: context.l10n.recognitionHeartOnMedal(count),
      excludeSemantics: true,
      child: onTap == null
          ? IgnorePointer(child: mark)
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(22),
                child: mark,
              ),
            ),
    );
  }
}

/// Número de corações recebidos nesta medalha.
class ReceivedHeartBadge extends StatelessWidget {
  final Set<String> subjectKeys;
  final bool compact;
  final VoidCallback? onTap;

  const ReceivedHeartBadge({
    super.key,
    required this.subjectKeys,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (subjectKeys.isEmpty) return const SizedBox.shrink();
    final count = countRecognitions(
      context.watch<RecognitionService>().received,
      kind: RecognitionKind.medal,
      subjectKeys: subjectKeys,
    );
    return HeartCountMark(count: count, compact: compact, onTap: onTap);
  }
}
