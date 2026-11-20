import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../services/progress_service.dart';

import '../l10n/app_language.dart';
import '../models/recognition.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'pilgrim_profile_sections.dart';
import 'recognition_actions.dart';
import 'relic_panel.dart';
import 'streak_week.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';
import 'cinematic_icon.dart';

/// Cartão de identidade do perfil — o mesmo no perfil e na vitrine da caravana.
class PilgrimIdentityCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;
  final bool editable;
  final VoidCallback? onEditPortrait;
  final int steps;
  final int missions;
  final int? accuracyPercent;
  final int accuracyCorrect;
  final int accuracyTotal;
  final int rank;
  final int leaderDays;
  final String? recordLine;
  final bool showSteps;
  final bool showMissions;
  final bool showRank;
  final bool showLeaderDays;
  final bool showAccuracy;
  final bool showWeek;
  final bool Function(DateTime day)? playedOnDate;

  /// Coração para reconhecer a caminhada (perfil de outra pessoa).
  final String? recognizeWalkToUid;
  final String? recognizeWalkDate;

  /// Selo de apoiador ao lado do nome (apoio avulso).
  final bool supporter;

  /// Selo de Peregrino ao lado do nome (assinatura) — selo distinto.
  final bool pilgrim;

  /// Selo de Pioneiro: assinante do plano de lançamento. Aparece no lugar
  /// do de Peregrino (é o mesmo Peregrino+, com o preço do começo).
  final bool pioneer;

  const PilgrimIdentityCard({
    super.key,
    required this.name,
    this.photoUrl,
    this.seed,
    this.style = PortraitStyle.photo,
    this.editable = false,
    this.onEditPortrait,
    required this.steps,
    required this.missions,
    required this.accuracyPercent,
    required this.accuracyCorrect,
    required this.accuracyTotal,
    required this.rank,
    required this.leaderDays,
    this.recordLine,
    this.showSteps = true,
    this.showMissions = true,
    this.showRank = true,
    this.showLeaderDays = true,
    this.showAccuracy = true,
    this.showWeek = true,
    this.playedOnDate,
    this.recognizeWalkToUid,
    this.recognizeWalkDate,
    this.supporter = false,
    this.pilgrim = false,
    this.pioneer = false,
  });

  bool get _showPrecision =>
      showAccuracy && accuracyPercent != null && accuracyTotal > 0;

  String? _whisper(AppLocalizations l10n) {
    final parts = <String>[];
    if (showRank && rank > 0) {
      parts.add(rank <= 3 ? pilgrimRankEpithet(rank) : l10n.pilgrimRank(rank));
    }
    if (showLeaderDays && leaderDays > 0) {
      parts.add(l10n.profileDaysOnTop(leaderDays));
    }
    final record = recordLine?.trim();
    if (record != null && record.isNotEmpty) parts.add(record);
    if (parts.isEmpty && _showPrecision) {
      parts.add(pilgrimAccuracyEpithet(accuracyPercent!));
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final displayName = ProgressService.isPlaceholderUserName(name)
        ? l10n.pilgrimFallbackName
        : name.trim();
    final whisper = _whisper(l10n);
    final podium = showRank && rank > 0 && rank <= 3;
    // Pódio acende em metal; fora dele, a luz é a da presença.
    final tone = podium ? pilgrimRankAccent(rank) : AppRoles.presence;

    final stats = <_StatData>[
      if (showSteps)
        _StatData(
          value: steps,
          label: l10n.pilgrimStatSteps,
          glyph: CinematicGlyph.sneaker,
          tone: AppRoles.lamp,
        ),
      if (showMissions)
        _StatData(
          value: missions,
          label: l10n.pilgrimStatScenes,
          glyph: CinematicGlyph.scroll,
          tone: AppRoles.navTrails,
        ),
      if (_showPrecision)
        _StatData(
          value: accuracyPercent!,
          suffix: '%',
          label: l10n.pilgrimAccuracyTitle,
          caption: l10n.pilgrimCorrectRatio(accuracyCorrect, accuracyTotal),
          glyph: CinematicGlyph.target,
          tone: AppRoles.success,
        ),
    ];

    final canRecognize =
        recognizeWalkToUid != null && recognizeWalkDate != null;

    return RelicPanel(
      elevated: true,
      accent: tone,
      glow: podium ? 0.9 : 0.6,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.xl,
        AppSpace.lg,
        AppSpace.lg,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _HaloPortrait(
                  tone: tone,
                  rank: showRank ? rank : 0,
                  child: UserAvatar(
                    name: displayName,
                    photoUrl: photoUrl,
                    seed: seed,
                    style: style,
                    radius: 54,
                    editable: editable,
                    onTap: editable ? onEditPortrait : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  size: 30,
                  color: a.text,
                  height: 1.05,
                ),
              ),
              // Selos quebram linha abaixo do nome — dois selos
              // lado a lado não cabem com o nome em telas estreitas.
              if (pioneer || pilgrim || supporter) ...[
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.xs,
                  children: [
                    if (pioneer || pilgrim)
                      SoftBadge(
                        text: pioneer ? l10n.pioneerBadge : l10n.pilgrimBadge,
                        glyph: CinematicGlyph.plus,
                        accent: AppRoles.reward,
                      ),
                    if (supporter)
                      SoftBadge(
                        text: l10n.supporterBadge,
                        glyph: CinematicGlyph.gift,
                        accent: AppRoles.reward,
                      ),
                  ],
                ),
              ],
              if (whisper != null) ...[
                const SizedBox(height: AppSpace.md),
                Center(
                  child: _EpithetRibbon(
                    text: whisper,
                    tone: podium ? tone : a.chrome,
                    glyph: podium
                        ? (rank == 1
                              ? CinematicGlyph.crown
                              : CinematicGlyph.podium)
                        : null,
                  ),
                ),
              ] else if (editable) ...[
                const SizedBox(height: AppSpace.xs + 2),
                Text(
                  l10n.pilgrimFallbackName,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: AppSpace.xl),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: _StatTile(data: stats[i], order: i),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (showWeek) ...[
                const SizedBox(height: AppSpace.lg),
                const RelicHairline(),
                const SizedBox(height: AppSpace.md),
                StreakWeek(orbSize: 30, playedOnDate: playedOnDate),
              ],
            ],
          ),
          if (canRecognize)
            Positioned(
              top: -AppSpace.sm,
              right: -AppSpace.xs,
              child: RecognizeHeartButton(
                toUid: recognizeWalkToUid,
                kind: RecognitionKind.walk,
                subjectKey: recognizeWalkDate!,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}

/// Retrato com auréola que gira devagar na cor da posição, brilho atrás e,
/// no pódio, a medalha com o número pendurada no pé.
class _HaloPortrait extends StatefulWidget {
  final Color tone;
  final int rank;
  final Widget child;

  const _HaloPortrait({
    required this.tone,
    required this.rank,
    required this.child,
  });

  @override
  State<_HaloPortrait> createState() => _HaloPortraitState();
}

class _HaloPortraitState extends State<_HaloPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 136.0;
    final tone = widget.tone;
    final rank = widget.rank;
    final podium = rank > 0 && rank <= 3;
    return SizedBox(
      width: size,
      height: size + (rank > 0 ? 12 : 0),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Brilho atrás do retrato.
          Positioned(
            top: -18,
            child: IgnorePointer(
              child: Container(
                width: size + 36,
                height: size + 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      tone.withValues(alpha: podium ? 0.45 : 0.3),
                      tone.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Auréola girando.
          SizedBox(
            width: size,
            height: size,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _spin,
                builder: (context, _) => CustomPaint(
                  painter: _HaloPainter(
                    turn: _spin.value,
                    tone: tone,
                    strong: podium,
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 14, child: widget.child),
          if (rank > 0)
            Positioned(
              bottom: 0,
              child: _RankMedal(rank: rank, tone: tone),
            ),
        ],
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  final double turn;
  final Color tone;
  final bool strong;

  _HaloPainter({required this.turn, required this.tone, required this.strong});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: c, radius: r);
    // Trilho fino e fixo.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = tone.withValues(alpha: 0.25),
    );
    // Arco de luz que corre em volta.
    final shader = SweepGradient(
      transform: GradientRotation(turn * math.pi * 2),
      colors: [
        tone.withValues(alpha: 0),
        tone.withValues(alpha: strong ? 0.95 : 0.75),
        Colors.white.withValues(alpha: strong ? 0.9 : 0.6),
        tone.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.32, 0.4, 0.62],
    ).createShader(rect);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strong ? 4.5 : 3.5
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _HaloPainter old) =>
      old.turn != turn || old.tone != tone || old.strong != strong;
}

/// Medalha com a posição: metal no pódio, chrome do 4º em diante.
class _RankMedal extends StatelessWidget {
  final int rank;
  final Color tone;

  const _RankMedal({required this.rank, required this.tone});

  @override
  Widget build(BuildContext context) {
    final podium = rank <= 3;
    final ink = podium ? const Color(0xFF241A06) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: podium
              ? [Color.lerp(tone, Colors.white, 0.45)!, tone]
              : [
                  AppRoles.presence.withValues(alpha: 0.9),
                  AppRoles.presence.withValues(alpha: 0.6),
                ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: tone.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank == 1) ...[
            CinematicIcon(
              glyph: CinematicGlyph.crown,
              size: 16,
              accent: ink,
              framed: false,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$rankº',
            style: AppTypography.title(
              size: 15,
              weight: FontWeight.w900,
              color: ink,
              height: 1.1,
            ).copyWith(fontFeatures: const [FontFeature.liningFigures()]),
          ),
        ],
      ),
    );
  }
}

/// Título curto em faixa luminosa (Líder do ranking · 17 dias no topo).
class _EpithetRibbon extends StatelessWidget {
  final String text;
  final Color tone;
  final CinematicGlyph? glyph;

  const _EpithetRibbon({required this.text, required this.tone, this.glyph});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = a.ink(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        gradient: LinearGradient(
          colors: [
            ink.withValues(alpha: 0.08),
            ink.withValues(alpha: 0.24),
            ink.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: ink.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            CinematicIcon(glyph: glyph!, size: 18, accent: ink, framed: false),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 13,
                height: 1.25,
                weight: FontWeight.w800,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final int value;
  final String suffix;
  final String label;
  final String? caption;
  final CinematicGlyph glyph;
  final Color tone;

  const _StatData({
    required this.value,
    required this.label,
    required this.glyph,
    required this.tone,
    this.suffix = '',
    this.caption,
  });
}

/// Número em ficha colorida, subindo do zero quando o perfil abre.
class _StatTile extends StatelessWidget {
  final _StatData data;
  final int order;

  const _StatTile({required this.data, required this.order});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = a.ink(data.tone);
    final still = MediaQuery.disableAnimationsOf(context);
    final caption = data.caption;
    return Semantics(
      label: '${pilgrimFormatCount(data.value)}${data.suffix} ${data.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, AppSpace.md, 6, AppSpace.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ink.withValues(alpha: 0.08), ink.withValues(alpha: 0.26)],
          ),
          border: Border.all(color: ink.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Column(
          children: [
            CinematicIcon(
              glyph: data.glyph,
              size: AppMetrics.iconLg,
              accent: data.tone,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: still ? 1 : 0, end: 1),
                  duration: Duration(milliseconds: 900 + order * 150),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => Text(
                    '${pilgrimFormatCount((data.value * t).round())}'
                    '${data.suffix}',
                    maxLines: 1,
                    style:
                        AppTypography.display(
                          size: 26,
                          weight: FontWeight.w900,
                          color: a.text,
                          height: 1,
                        ).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w800,
                color: ink,
              ),
            ),
            if (caption != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  caption,
                  maxLines: 1,
                  style: AppTypography.body(size: 11, color: a.textFaint),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dias caminhados de um perfil público, no formato que [StreakWeek] espera.
bool pilgrimPlayedOnDate({
  required DateTime day,
  required List<String> playDates,
  required bool walkedToday,
}) {
  final key = day.toIso8601String().substring(0, 10);
  final now = DateTime.now();
  final isToday =
      day.year == now.year && day.month == now.month && day.day == now.day;
  return playDates.contains(key) || (isToday && walkedToday);
}
