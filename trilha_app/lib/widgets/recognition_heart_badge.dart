import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/recognition.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

/// Coração com o número. No cofre é o selo pequeno; na medalha aberta, o toque
/// mostra quem reconheceu. Some quando ninguém curtiu.
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
    // No cofre o selo é pequeno. Na medalha aberta cabe na marca de ~32×60
    // e o toque continua com 44.
    final mark = DecoratedBox(
      decoration: BoxDecoration(
        color: AppRoles.heart.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Appearance.of(context).cardFill,
          width: compact ? 1.5 : 1,
        ),
      ),
      child: SizedBox(
        height: compact ? null : 32,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 8,
            vertical: compact ? 2 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.heart,
                size: compact ? 12 : 16,
                accent: AppColors.textOnDark,
                framed: false,
              ),
              SizedBox(width: compact ? 2 : 3),
              Text(
                '$count',
                style: AppTypography.title(
                  size: compact ? 10 : 12,
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
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
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Center(child: mark),
                ),
              ),
            ),
    );
  }
}

/// Corações recebidos nesta medalha.
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
