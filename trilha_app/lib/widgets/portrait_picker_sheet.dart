import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Escolha do retrato — foto, letra ou peregrino ilustrado.
Future<void> showPortraitPickerSheet(BuildContext context) {
  ActHaptics.tap();
  context.read<BackendService>().ensureAccountPhoto(allowPrompt: true);
  return showAppSheet<void>(
    context,
    builder: (_) => const _PortraitPickerSheet(),
  );
}

class _PortraitPickerSheet extends StatelessWidget {
  const _PortraitPickerSheet();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final selected = progress.settings.portraitStyle;
    final hasPhoto = PortraitFace.isUsablePhotoUrl(backend.userPhotoUrl);
    final name = progress.userName.trim().isEmpty
        ? context.l10n.pilgrimFallbackName
        : progress.userName.trim();

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            eyebrow: context.l10n.portraitEyebrow,
            eyebrowColor: AppColors.accent,
            title: context.l10n.portraitTitle,
            center: true,
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
                    available:
                        PortraitStyle.values[i] != PortraitStyle.photo ||
                        hasPhoto,
                    onTap: () {
                      ActHaptics.tap();
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
        ? context.l10n.portraitNoPhoto
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
                size: 14,
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
                color: selected ? a.textSecondary : a.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
