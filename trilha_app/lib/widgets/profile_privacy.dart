import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/caravan_profile_prefs.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Marca a árvore do **próprio** perfil. Só dentro dele os cards mostram o
/// olho de privacidade; no perfil de outra pessoa (sheet da caravana) o
/// mesmo card aparece sem olho.
class ProfilePrivacyScope extends InheritedWidget {
  const ProfilePrivacyScope({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfilePrivacyScope>() != null;

  @override
  bool updateShouldNotify(ProfilePrivacyScope oldWidget) => false;
}

/// Olho no canto do card: aberto = a caravana vê; riscado = só você.
///
/// [sections] podem ser várias (a faixa de números cobre ranking, clareza e
/// dias no topo): o olho fica aberto só se todas estão visíveis, e o toque
/// liga ou desliga todas juntas.
class PrivacyEye extends StatelessWidget {
  final Set<CaravanProfileSection> sections;

  /// Nome do que o card mostra, para o aviso ("Constância aparece…").
  final String label;

  const PrivacyEye({super.key, required this.sections, required this.label});

  @override
  Widget build(BuildContext context) {
    if (!ProfilePrivacyScope.of(context)) return const SizedBox.shrink();
    final progress = context.watch<ProgressService>();
    final prefs = progress.caravanProfilePrefs;
    final visible = sections.every(prefs.isVisible);
    final a = Appearance.of(context);
    final ink = visible ? AppColors.teal : a.textFaint;

    void toggle() {
      ActHaptics.tap();
      final next = !visible;
      var updated = prefs;
      for (final s in sections) {
        updated = updated.copyWithSection(s, next);
      }
      progress.updateCaravanProfilePrefs(updated);
      showAppToastFor(
        context,
        message: next
            ? context.l10n.profilePrivacyShownToast(label)
            : context.l10n.profilePrivacyHiddenToast(label),
        glyph: next ? CinematicGlyph.people : CinematicGlyph.lock,
        tone: next ? AppToastTone.accent : AppToastTone.warn,
      );
    }

    return Semantics(
      button: true,
      toggled: visible,
      label: visible
          ? context.l10n.profilePrivacyShownSemantics(label)
          : context.l10n.profilePrivacyHiddenSemantics(label),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle,
        // Alvo de 44dp em volta de um olho pequeno.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: visible
                    ? AppColors.teal.withValues(alpha: 0.12)
                    : Colors.transparent,
                border: Border.all(
                  color: visible
                      ? AppColors.teal.withValues(alpha: 0.55)
                      : a.cardBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
