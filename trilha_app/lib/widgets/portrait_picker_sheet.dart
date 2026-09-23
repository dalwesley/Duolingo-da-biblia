import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'immersive_background.dart';
import 'user_avatar.dart';

/// Escolha do retrato — foto, letra ou peregrino ilustrado.
Future<void> showPortraitPickerSheet(BuildContext context) {
  HapticFeedback.selectionClick();
  context.read<BackendService>().ensureAccountPhoto(allowPrompt: true);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    isScrollControlled: true,
    builder: (_) => const _PortraitPickerSheet(),
  );
}

class _PortraitPickerSheet extends StatelessWidget {
  const _PortraitPickerSheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final selected = progress.settings.portraitStyle;
    final hasPhoto = PortraitFace.isUsablePhotoUrl(backend.userPhotoUrl);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final name = progress.userName.trim().isEmpty
        ? 'Peregrino'
        : progress.userName.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
      child: GlassCard(
        elevated: true,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: a.textMuted(0.28),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'RETRATO',
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.8,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Como você aparece no caminho',
              textAlign: TextAlign.center,
              style: AppTypography.title(size: 18, color: a.text),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                for (var i = 0; i < PortraitStyle.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _PortraitChoice(
                      style: PortraitStyle.values[i],
                      name: name,
                      photoUrl: backend.userPhotoUrl,
                      seed: backend.uid,
                      selected: selected == PortraitStyle.values[i],
                      available: PortraitStyle.values[i] != PortraitStyle.photo ||
                          hasPhoto,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        progress.updateSettings(
                          progress.settings.copyWith(
                            portraitStyle: PortraitStyle.values[i],
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PortraitChoice extends StatelessWidget {
  final PortraitStyle style;
  final String name;
  final String? photoUrl;
  final String? seed;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  const _PortraitChoice({
    required this.style,
    required this.name,
    required this.photoUrl,
    required this.seed,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final hint = style == PortraitStyle.photo && !available
        ? 'Sem foto nesta conta'
        : style.hint;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: available || selected ? 1 : 0.72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.accent
                      : a.cardBorder.withValues(alpha: 0.7),
                  width: selected ? 2.2 : 1.2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: UserAvatar(
                name: name,
                photoUrl: photoUrl,
                seed: seed,
                style: style,
                radius: 32,
                borderColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              style.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(
                size: 13,
                color: selected ? AppColors.accent : a.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hint,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 11,
                height: 1.25,
                color: a.textMuted(selected ? 0.7 : 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
