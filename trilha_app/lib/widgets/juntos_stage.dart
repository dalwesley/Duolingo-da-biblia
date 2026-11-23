import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'pilgrim_profile_cover.dart';
import 'postcard.dart';
import 'profile_section.dart';
import 'ui_primitives.dart';

/// Capa do Perfil: a cena escolhida (se ainda é uma cena feita) ou a mais
/// recente. Também pinta o fundo dos palcos de Juntos.
String? profileCoverSceneOf(ProgressService p) {
  final chosen = p.settings.coverScene;
  if (chosen != null && p.completedMissions.contains(chosen)) return chosen;
  final days = <String, String>{...p.missionCompletedOn, ...p.postcardsOn};
  String? best;
  String bestDay = '';
  for (final e in days.entries) {
    final day = e.value as String? ?? '';
    if (best == null || day.compareTo(bestDay) > 0) {
      best = e.key;
      bestDay = day;
    }
  }
  return best;
}

/// Palco de Juntos na língua do Perfil: a moldura de luz do [ProfilePanel]
/// com a pintura da capa do usuário ao fundo, coberta por uma noite que
/// sobe de baixo — o conteúdo lê sobre o escuro, a cena respira em cima.
class PaintedStage extends StatelessWidget {
  final Color accent;
  final String? sceneSlug;
  final Widget child;

  /// Selo no canto (glifo + nome do lugar), como o chip de posição da capa.
  final CinematicGlyph? chipGlyph;
  final String? chipLabel;

  const PaintedStage({
    super.key,
    required this.accent,
    required this.child,
    this.sceneSlug,
    this.chipGlyph,
    this.chipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final slug = sceneSlug;
    final chipLabel = this.chipLabel;
    final a = Appearance.of(context);
    // Pé da pintura: o fundo do painel no céu atual (papel claro de dia,
    // noite à noite) — como nos cards de Explorar.
    final base = ProfilePanel.baseOf(a);
    return ProfilePanel(
      accent: accent,
      lit: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.md,
        AppSpace.md,
        AppSpace.lg,
      ),
      backdrop: [
        if (slug != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 260,
            child: FutureBuilder<SceneLookup>(
              future: SceneLookup.load(),
              builder: (context, snap) {
                final art = snap.data?.artOf(slug);
                return AnimatedOpacity(
                  opacity: art == null ? 0 : (a.onDark ? 0.62 : 0.9),
                  duration: const Duration(milliseconds: 420),
                  child: art == null
                      ? const SizedBox.shrink()
                      : SceneArtImage(
                          art,
                          veiled: false,
                          alignment: const Alignment(0, -0.3),
                        ),
                );
              },
            ),
          ),
        // A noite sobe de baixo e cobre a pintura até o meio do palco.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    base.withValues(alpha: 0.05),
                    base.withValues(alpha: 0.55),
                    base.withValues(alpha: 0.96),
                    base,
                  ],
                  stops: const [0, 0.22, 0.42, 1],
                ),
              ),
            ),
          ),
        ),
        // Luz da seção vazando por baixo, atrás da ação.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 1.25),
                  radius: 0.9,
                  colors: [
                    accent.withValues(alpha: 0.22),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (chipLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: StageChip(
                accent: accent,
                glyph: chipGlyph ?? CinematicGlyph.people,
                label: chipLabel,
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// Palco padrão das abas de Juntos (Companhia, Desafio, Caravana e
/// Grupos): mesma moldura pintada, mesmo título, frase, miolo e ações —
/// cada aba muda só a cor ([accent]) e o que vai no miolo.
class JuntosHero extends StatelessWidget {
  final Color accent;

  /// Pintura ao fundo (a capa do Perfil); sem ela, só a moldura de luz.
  final String? sceneSlug;
  final String title;
  final String body;

  /// Passos ([StageSteps]), relógio… entre a frase e as ações.
  final Widget? middle;

  /// Botões, na ordem: o principal ([CopperCta]) e os secundários.
  final List<Widget> actions;

  /// Troca as ações por um spinner.
  final bool loading;

  /// Aviso de erro logo abaixo das ações.
  final Widget? notice;

  /// Linha no topo do palco (selo do lugar, menu…), acima do título.
  final Widget? header;

  const JuntosHero({
    super.key,
    required this.accent,
    required this.title,
    required this.body,
    this.sceneSlug,
    this.middle,
    this.actions = const [],
    this.loading = false,
    this.notice,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return PaintedStage(
      accent: accent,
      sceneSlug: sceneSlug,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header case final header?) ...[
            header,
            const SizedBox(height: AppSpace.sm),
          ] else
            // Com pintura, ela respira um pouco antes do título.
            SizedBox(height: sceneSlug == null ? AppSpace.sm : 56),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26, color: a.text, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          if (middle case final middle?) ...[
            const SizedBox(height: AppSpace.lg),
            middle,
          ],
          if (loading) ...[
            const SizedBox(height: AppSpace.lg),
            const AppSpinner(),
          ] else if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpace.lg),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpace.sm),
              actions[i],
            ],
          ],
          if (notice case final notice?) ...[
            const SizedBox(height: 14),
            notice,
          ],
        ],
      ),
    );
  }
}

/// Selo de vidro escuro com o glifo na cor da seção.
class StageChip extends StatelessWidget {
  final Color accent;
  final CinematicGlyph glyph;
  final String label;

  const StageChip({
    super.key,
    required this.accent,
    required this.glyph,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: a.onDark
            ? Colors.black.withValues(alpha: 0.42)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 14,
            accent: a.onDark
                ? Color.lerp(accent, Colors.white, 0.2)!
                : a.ink(accent),
            framed: false,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(
                size: 12,
                weight: FontWeight.w800,
                color: a.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Os três passos em fichas de vidro, cada um aceso na sua cor.
class StageSteps extends StatelessWidget {
  final List<(CinematicGlyph, String, Color)> steps;

  /// Uma linha de detalhe por passo (opcional): o rótulo vira título curto.
  final List<String>? details;

  const StageSteps({super.key, required this.steps, this.details});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.sm),
          Expanded(
            child: _StepTile(step: steps[i], detail: details?[i]),
          ),
        ],
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final (CinematicGlyph, String, Color) step;
  final String? detail;

  const _StepTile({required this.step, this.detail});

  @override
  Widget build(BuildContext context) {
    final (glyph, label, color) = step;
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10),
              ],
            ),
            alignment: Alignment.center,
            child: CinematicIcon(
              glyph: glyph,
              size: 15,
              accent: a.onDark
                  ? Color.lerp(color, Colors.white, 0.2)!
                  : a.ink(color),
              framed: false,
            ),
          ),
          const SizedBox(height: 6),
          if (detail case final detail?) ...[
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(letterSpacing: 0, color: a.text),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 11,
                height: 1.25,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ] else
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTypography.body(
                size: 11,
                height: 1.25,
                weight: FontWeight.w700,
                color: a.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
