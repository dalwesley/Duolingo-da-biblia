import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../models/difficulty.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/trail_progress.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Modo de estudo — uma escolha, uma regra, uma aparência.
///
/// - [ModeBanner]: resumo vivo no mapa da trilha; abre [showModeSheet].
/// - [ModeCarousel]: os três portais (sheet e primeira escolha).
/// - [ModeSwitch.select]: a única regra de troca.

/// Estado de um modo para a trilha atual.
class ModeStatus {
  final TrailDifficulty difficulty;
  final bool locked;
  final bool cleared;

  /// Modo que o app está usando agora (sessão ou gravado).
  final bool current;

  /// Modo para onde o app volta ao reabrir — difere de [current] numa
  /// troca só de sessão.
  final bool canonical;

  /// Cenas feitas / total neste modo (0/0 sem trilha carregada).
  final int done;
  final int total;

  const ModeStatus({
    required this.difficulty,
    required this.locked,
    required this.cleared,
    required this.current,
    required this.canonical,
    this.done = 0,
    this.total = 0,
  });

  static List<ModeStatus> forTrail(
    ProgressService progress,
    String slug, {
    List<String> missionSlugs = const [],
  }) {
    final currentId =
        TrailProgress.resolvedDifficultyId(
          slug,
          progress.difficultyForTrail(slug),
        ) ??
        TrailDifficulty.semente.id;
    final canonicalId = progress.canonicalDifficultyId(slug);
    final total = missionSlugs.length;
    // Progresso gravado pertence ao modo em andamento (o canônico).
    final canonicalDone = missionSlugs
        .where(progress.completedMissions.contains)
        .length;
    return [
      for (final d in TrailDifficulty.values)
        () {
          final cleared = progress.hasClearedMode(slug, d.id);
          final canonical = d.id == canonicalId;
          final locked = !progress.isDifficultyUnlocked(slug, d);
          final prevCanonical = d.previous?.id == canonicalId;
          return ModeStatus(
            difficulty: d,
            locked: locked,
            cleared: cleared,
            current: d.id == currentId,
            canonical: canonical,
            total: total,
            done: cleared
                ? total
                : canonical || (locked && prevCanonical)
                ? canonicalDone
                : 0,
          );
        }(),
    ];
  }

  double get fraction => total <= 0 ? 0 : (done / total).clamp(0.0, 1.0);

  /// Selo curto — null quando não há o que dizer.
  String? get badge {
    final l10n = L10n.current;
    if (locked) return l10n.modeBadgeLocked;
    if (current && cleared) return l10n.modeBadgeReview;
    if (current) return l10n.modeBadgeHere;
    if (cleared) return l10n.modeBadgeCleared;
    if (canonical) return l10n.modeBadgeInProgress;
    return null;
  }

  String get lockHint {
    final prev = difficulty.previous;
    return prev == null
        ? L10n.current.modeBadgeLocked
        : L10n.current.modeLockHint(prev.labelPt);
  }

  /// Linha sob a barra de progresso.
  String? get progressLine {
    if (total <= 0) return null;
    final l10n = L10n.current;
    if (locked) {
      final prev = difficulty.previous;
      if (prev == null) return null;
      final left = total - done;
      return left <= 0
          ? l10n.modePrevAlmostDone(prev.labelPt)
          : l10n.modeScenesLeft(left, prev.labelPt);
    }
    if (cleared) return l10n.modeClearedReview;
    if (done == 0) return l10n.modeStartFirstScene;
    return l10n.modeScenesProgress(done, total);
  }
}

class ModeSwitch {
  ModeSwitch._();

  /// Aplica o modo [d] na trilha. Primeira escolha grava; depois, a troca
  /// vale só nesta sessão (ao reabrir, volta ao modo em andamento).
  /// Retorna `true` quando o modo ficou ativo.
  static Future<bool> select(
    BuildContext context, {
    required String trailSlug,
    required TrailDifficulty d,
    List<String> missionSlugs = const [],
  }) async {
    final progress = context.read<ProgressService>();
    if (!progress.isDifficultyUnlocked(trailSlug, d)) return false;
    if (!progress.hasDifficultyForTrail(trailSlug)) {
      await progress.setTrailDifficulty(
        trailSlug,
        d.id,
        missionSlugs: missionSlugs,
      );
    } else if (progress.difficultyForTrail(trailSlug) == d.id) {
      return true;
    } else {
      progress.setSessionTrailDifficulty(
        trailSlug,
        d.id,
        missionSlugs: missionSlugs,
      );
    }
    AnalyticsService.instance.logDifficultyPick(
      trailSlug: trailSlug,
      difficulty: d.id,
    );
    return true;
  }

  /// Rodapé: explica a troca de sessão ou a regra de liberação.
  static String footnote(ProgressService progress, String trailSlug) {
    if (progress.hasSessionDifficulty(trailSlug)) {
      final back = TrailProgress.modeLabel(
        progress.canonicalDifficultyId(trailSlug),
      );
      return L10n.current.modeSessionFootnote(back);
    }
    return L10n.current.modeRuleFootnote;
  }
}

/// Sheet "Modo de estudo" — a mesma no mapa da trilha e em Ajustes.
Future<void> showModeSheet(
  BuildContext context, {
  required String trailSlug,
  required String trailTitle,
  List<String> missionSlugs = const [],
  Color? tint,
}) {
  ActHaptics.tap();
  final tone = tint ?? AppColors.accent;
  return showAppSheet<void>(
    context,
    builder: (sheetContext) => AppSheetPanel(
      tint: tone,
      padding: const EdgeInsets.fromLTRB(0, AppSpace.md, 0, AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            child: AppSheetHeader(
              eyebrow: context.l10n.modeSheetEyebrow,
              eyebrowColor: tone,
              title: context.l10n.modeSheetTitle,
              subtitle: trailTitle,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          ModeCarousel(
            trailSlug: trailSlug,
            missionSlugs: missionSlugs,
            onCommitted: (_) => Navigator.of(sheetContext).maybePop(),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Carrossel de portais
// ─────────────────────────────────────────────────────────────────────────

/// Três portais, um por modo — deslize para conhecer, confirme no botão.
///
/// O vizinho aparece na borda (convite a deslizar); o portal em foco
/// respira, e sua cena corre: luzes que sobem (Observação), um pulso que
/// liga a constelação (Compreensão), ondas que descem fundo (Interpretação).
class ModeCarousel extends StatefulWidget {
  final String trailSlug;
  final List<String> missionSlugs;
  final double height;
  final ValueChanged<TrailDifficulty>? onCommitted;

  const ModeCarousel({
    super.key,
    required this.trailSlug,
    this.missionSlugs = const [],
    this.height = 372,
    this.onCommitted,
  });

  @override
  State<ModeCarousel> createState() => _ModeCarouselState();
}

class _ModeCarouselState extends State<ModeCarousel>
    with TickerProviderStateMixin {
  static const _modes = TrailDifficulty.values;

  late final PageController _pages;
  late final AnimationController _life;
  late final AnimationController _nudge;
  int _page = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final progress = context.read<ProgressService>();
    final statuses = ModeStatus.forTrail(progress, widget.trailSlug);
    final i = statuses.indexWhere((s) => s.current);
    _page = i < 0 ? 0 : i;
    _pages = PageController(viewportFraction: 0.80, initialPage: _page);
    _life = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _nudge = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    _life.dispose();
    _nudge.dispose();
    super.dispose();
  }

  double get _offset {
    if (!_pages.hasClients || !_pages.position.haveDimensions) {
      return _page.toDouble();
    }
    return _pages.page ?? _page.toDouble();
  }

  void _goTo(int i) {
    _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _confirm(ModeStatus s) async {
    if (_busy) return;
    if (s.locked) {
      ActHaptics.tap();
      _nudge.forward(from: 0);
      return;
    }
    setState(() => _busy = true);
    final ok = await ModeSwitch.select(
      context,
      trailSlug: widget.trailSlug,
      d: s.difficulty,
      missionSlugs: widget.missionSlugs,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    ActHaptics.confirm();
    widget.onCommitted?.call(s.difficulty);
  }

  String _ctaLabel(ModeStatus s, bool firstPick) {
    final name = s.difficulty.labelPt;
    if (s.locked) return s.lockHint;
    final l10n = context.l10n;
    if (firstPick) return l10n.modeCtaStart(name);
    if (s.current) return l10n.modeCtaContinue(name);
    if (s.cleared) return l10n.modeCtaReview(name);
    return l10n.modeCtaStudy(name);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final statuses = ModeStatus.forTrail(
      progress,
      widget.trailSlug,
      missionSlugs: widget.missionSlugs,
    );
    final firstPick = !progress.hasDifficultyForTrail(widget.trailSlug);

    return AnimatedBuilder(
      animation: Listenable.merge([_pages, _nudge]),
      builder: (context, _) {
        final offset = _offset;
        final focused = offset.round().clamp(0, _modes.length - 1);
        final accent = _accentAt(offset);
        final status = statuses[focused];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.height,
              child: PageView.builder(
                controller: _pages,
                itemCount: _modes.length,
                clipBehavior: Clip.none,
                onPageChanged: (i) {
                  ActHaptics.tap();
                  setState(() => _page = i);
                },
                itemBuilder: (context, i) {
                  final delta = (offset - i).clamp(-1.0, 1.0);
                  final focus = 1 - delta.abs();
                  var shake = 0.0;
                  if (i == focused && _nudge.isAnimating) {
                    final t = _nudge.value;
                    shake = math.sin(t * math.pi * 6) * 7 * (1 - t);
                  }
                  final scale = 1 - 0.10 * delta.abs();
                  return GestureDetector(
                    onTap: () =>
                        i == focused ? _confirm(statuses[i]) : _goTo(i),
                    child: Transform(
                      alignment: delta > 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..translateByDouble(shake, 0, 0, 1)
                        ..rotateY(delta * 0.32)
                        ..scaleByDouble(scale, scale, 1, 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _ModePortal(
                          status: statuses[i],
                          focus: focus,
                          parallax: delta,
                          life: _life,
                          alive: i == focused,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            _ModeDots(offset: offset, statuses: statuses, onTap: _goTo),
            const SizedBox(height: AppSpace.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
              child: _ModeCta(
                label: _ctaLabel(status, firstPick),
                accent: accent,
                locked: status.locked,
                busy: _busy,
                onTap: () => _confirm(status),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
              child: Text(
                ModeSwitch.footnote(progress, widget.trailSlug),
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  color: Appearance.of(context).textFaint,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Color _accentAt(double x) {
    final v = x.clamp(0.0, (_modes.length - 1).toDouble());
    final i = v.floor().clamp(0, _modes.length - 2);
    final t = Curves.easeInOut.transform(v - i);
    return Color.lerp(
      DifficultyVisuals.accentFor(_modes[i]),
      DifficultyVisuals.accentFor(_modes[i + 1]),
      t,
    )!;
  }
}

/// Um portal: cena viva de fundo, emblema que respira, nome, pergunta,
/// descrição, habilidades e progresso.
class _ModePortal extends StatelessWidget {
  final ModeStatus status;
  final double focus;
  final double parallax;
  final Animation<double> life;
  final bool alive;

  const _ModePortal({
    required this.status,
    required this.focus,
    required this.parallax,
    required this.life,
    required this.alive,
  });

  @override
  Widget build(BuildContext context) {
    final d = status.difficulty;
    final accent = DifficultyVisuals.accentFor(d);
    final onSky = DifficultyVisuals.onSky(accent);
    final locked = status.locked;
    final running = alive && !locked;
    final badge = status.badge;

    Widget scene(double t) => CustomPaint(
      painter: ModeScenePainter(
        difficulty: d,
        color: accent,
        t: t,
        intensity: 0.35 + 0.65 * focus,
        parallax: parallax,
        locked: locked,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: onSky.withValues(alpha: locked ? 0.22 : 0.25 + 0.55 * focus),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: locked ? 0.06 : 0.30 * focus),
            blurRadius: 34,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: running
                  ? AnimatedBuilder(
                      animation: life,
                      builder: (context, _) => scene(life.value),
                    )
                  : scene(0),
            ),
            // Véu inferior: texto sempre legível sobre a cena.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                  colors: [Color(0x00070B14), Color(0xE0070B14)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.modeOrdinal(d.ordinalPt),
                        style: AppTypography.label(
                          size: 11,
                          letterSpacing: 2.2,
                          color: onSky.withValues(alpha: locked ? 0.5 : 0.9),
                        ),
                      ),
                      const Spacer(),
                      if (badge != null)
                        _GlassPill(
                          text: badge,
                          accent: accent,
                          solid: status.current,
                          glyph: locked
                              ? CinematicGlyph.lock
                              : status.cleared
                              ? CinematicGlyph.check
                              : null,
                        ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(parallax * -24, 0),
                        child: _Halo(
                          difficulty: d,
                          accent: accent,
                          locked: locked,
                          life: running ? life : null,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    d.labelPt,
                    style: AppTypography.display(
                      size: 30,
                      height: 1.05,
                      color: locked
                          ? Colors.white.withValues(alpha: 0.62)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.taglinePt,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w800,
                      color: locked
                          ? Colors.white.withValues(alpha: 0.5)
                          : onSky,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.blurbPt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.35,
                      color: Colors.white.withValues(
                        alpha: locked ? 0.45 : 0.78,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final skill in d.skillsPt)
                        _SkillChip(text: skill, accent: accent, dim: locked),
                    ],
                  ),
                  if (status.progressLine != null) ...[
                    const SizedBox(height: 14),
                    _PortalProgress(status: status, accent: accent),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Emblema com auréola que respira (ou cadeado, se bloqueado).
class _Halo extends StatelessWidget {
  final TrailDifficulty difficulty;
  final Color accent;
  final bool locked;
  final Animation<double>? life;
  final double size;

  const _Halo({
    required this.difficulty,
    required this.accent,
    this.locked = false,
    this.life,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    final onSky = DifficultyVisuals.onSky(accent);
    final core = size * 0.66;

    Widget frame(double breathe) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + 0.07 * breathe,
              child: Container(
                width: size * 0.94,
                height: size * 0.94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: locked ? 0.08 : 0.36),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: core,
              height: core,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.night.withValues(alpha: 0.42),
                border: Border.all(
                  color: onSky.withValues(
                    alpha: locked ? 0.25 : 0.55 + 0.3 * breathe,
                  ),
                  width: 1.6,
                ),
                boxShadow: locked
                    ? null
                    : [
                        BoxShadow(
                          color: accent.withValues(
                            alpha: 0.22 + 0.22 * breathe,
                          ),
                          blurRadius: size * 0.22,
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: CinematicIcon(
                glyph: locked
                    ? CinematicGlyph.lock
                    : DifficultyVisuals.glyphFor(difficulty),
                size: core * (locked ? 0.36 : 0.46),
                accent: locked ? Colors.white.withValues(alpha: 0.6) : onSky,
                framed: false,
                glowing: !locked,
              ),
            ),
          ],
        ),
      );
    }

    final l = life;
    if (l == null) return frame(0);
    return AnimatedBuilder(
      animation: l,
      builder: (context, _) =>
          frame(0.5 + 0.5 * math.sin(l.value * math.pi * 2 * 2)),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;
  final Color accent;
  final bool dim;

  const _SkillChip({
    required this.text,
    required this.accent,
    required this.dim,
  });

  @override
  Widget build(BuildContext context) {
    final onSky = DifficultyVisuals.onSky(accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: dim ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: onSky.withValues(alpha: dim ? 0.15 : 0.35),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.label(
          size: 11,
          letterSpacing: 0.2,
          color: Colors.white.withValues(alpha: dim ? 0.45 : 0.88),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String text;
  final Color accent;
  final bool solid;
  final CinematicGlyph? glyph;

  const _GlassPill({
    required this.text,
    required this.accent,
    required this.solid,
    this.glyph,
  });

  @override
  Widget build(BuildContext context) {
    final ink = solid ? AppColors.inkOnAccent : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? accent : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: solid
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            CinematicIcon(glyph: glyph!, size: 11, accent: ink, framed: false),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.4,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de progresso que enche ao aparecer + linha de contexto.
class _PortalProgress extends StatelessWidget {
  final ModeStatus status;
  final Color accent;
  final String? line;

  const _PortalProgress({
    required this.status,
    required this.accent,
    this.line,
  });

  @override
  Widget build(BuildContext context) {
    final prev = status.difficulty.previous;
    final fill = status.locked && prev != null
        ? DifficultyVisuals.accentFor(prev)
        : accent;
    final text = line ?? status.progressLine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white.withValues(alpha: 0.10)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: status.fraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [fill.withValues(alpha: 0.7), fill],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 6),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 0.2,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ],
      ],
    );
  }
}

/// Indicador: três pílulas que se esticam e tomam a cor do modo em foco.
class _ModeDots extends StatelessWidget {
  final double offset;
  final List<ModeStatus> statuses;
  final ValueChanged<int> onTap;

  const _ModeDots({
    required this.offset,
    required this.statuses,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < statuses.length; i++)
          GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Builder(
                builder: (context) {
                  final focus = (1 - (offset - i).abs()).clamp(0.0, 1.0);
                  final accent = DifficultyVisuals.accentFor(
                    statuses[i].difficulty,
                  );
                  return Container(
                    width: 8 + 22 * focus,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: Color.lerp(
                        Appearance.of(context).textFaint.withValues(
                          alpha: statuses[i].locked ? 0.35 : 0.7,
                        ),
                        accent,
                        focus,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Botão que assume a cor do portal em foco.
class _ModeCta extends StatefulWidget {
  final String label;
  final Color accent;
  final bool locked;
  final bool busy;
  final VoidCallback onTap;

  const _ModeCta({
    required this.label,
    required this.accent,
    required this.locked,
    required this.busy,
    required this.onTap,
  });

  @override
  State<_ModeCta> createState() => _ModeCtaState();
}

class _ModeCtaState extends State<_ModeCta> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final locked = widget.locked;
    const ink = AppColors.inkOnAccent;
    final a = Appearance.of(context);
    final muted = a.textSecondary;
    return Semantics(
      button: true,
      enabled: !locked,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.busy ? null : widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: 54,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: locked ? a.text.withValues(alpha: 0.06) : null,
              gradient: locked
                  ? null
                  : LinearGradient(
                      colors: [Color.lerp(accent, Colors.white, 0.2)!, accent],
                    ),
              border: locked
                  ? Border.all(color: a.text.withValues(alpha: 0.16))
                  : null,
              boxShadow: locked
                  ? null
                  : [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.42),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: widget.busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: ink,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (locked) ...[
                        CinematicIcon(
                          glyph: CinematicGlyph.lock,
                          size: 14,
                          accent: muted,
                          framed: false,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 15,
                            weight: FontWeight.w800,
                            color: locked ? muted : ink,
                          ),
                        ),
                      ),
                      if (!locked) ...[
                        const SizedBox(width: 8),
                        const CinematicIcon(
                          glyph: CinematicGlyph.forward,
                          size: 14,
                          accent: ink,
                          framed: false,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Banner do mapa
// ─────────────────────────────────────────────────────────────────────────

/// Resumo vivo do modo no mapa: a cena do modo atual corre ao fundo, com
/// nome, pergunta, progresso e a escada dos três modos. Toque abre a sheet.
class ModeBanner extends StatefulWidget {
  final String trailSlug;
  final String trailTitle;
  final List<String> missionSlugs;

  /// Linha de contexto (ex.: "Observação concluída · o próximo modo é…").
  final String? caption;

  const ModeBanner({
    super.key,
    required this.trailSlug,
    required this.trailTitle,
    this.missionSlugs = const [],
    this.caption,
  });

  @override
  State<ModeBanner> createState() => _ModeBannerState();
}

class _ModeBannerState extends State<ModeBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _life = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final statuses = ModeStatus.forTrail(
      progress,
      widget.trailSlug,
      missionSlugs: widget.missionSlugs,
    );
    final current = statuses.firstWhere(
      (s) => s.current,
      orElse: () => statuses.first,
    );
    final d = current.difficulty;
    final accent = DifficultyVisuals.accentFor(d);
    final onSky = DifficultyVisuals.onSky(accent);
    final session = progress.hasSessionDifficulty(widget.trailSlug);
    final line = session
        ? ModeSwitch.footnote(progress, widget.trailSlug)
        : widget.caption ?? current.progressLine;

    return Semantics(
      button: true,
      label: context.l10n.modeBannerSemantics(d.labelPt, d.taglinePt),
      value: line,
      hint: context.l10n.modeBannerHint,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () => showModeSheet(
          context,
          trailSlug: widget.trailSlug,
          trailTitle: widget.trailTitle,
          missionSlugs: widget.missionSlugs,
          tint: accent,
        ),
        child: AnimatedScale(
          scale: _down ? 0.98 : 1,
          duration: const Duration(milliseconds: 140),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: onSky.withValues(alpha: 0.6),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.24),
                  blurRadius: 26,
                  spreadRadius: -6,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _life,
                        builder: (context, _) => CustomPaint(
                          painter: ModeScenePainter(
                            difficulty: d,
                            color: accent,
                            t: _life.value,
                            intensity: 0.85,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xD9070B14), Color(0x33070B14)],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Row(
                      children: [
                        _Halo(
                          difficulty: d,
                          accent: accent,
                          life: _life,
                          size: 64,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.modeOrdinalBadge(
                                  d.ordinalPt,
                                  current.badge ?? context.l10n.modeBadgeCurrent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  size: 10,
                                  letterSpacing: 1.6,
                                  color: onSky.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                d.labelPt,
                                style: AppTypography.display(
                                  size: 22,
                                  height: 1.05,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                d.taglinePt,
                                style: AppTypography.body(
                                  size: 12,
                                  weight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                              ),
                              if (current.total > 0) ...[
                                const SizedBox(height: 10),
                                _PortalProgress(
                                  status: current,
                                  accent: accent,
                                  line: line,
                                ),
                              ] else if (line != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  line,
                                  style: AppTypography.label(
                                    size: 11,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _ModeLadder(statuses: statuses),
                            const SizedBox(height: 12),
                            _GlassPill(
                              text: context.l10n.modeSwitch,
                              accent: accent,
                              solid: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Escada vertical dos modos (III no topo): concluído cheio, atual com
/// anel aceso, bloqueado vazado.
class _ModeLadder extends StatelessWidget {
  final List<ModeStatus> statuses;

  const _ModeLadder({required this.statuses});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = statuses.length - 1; i >= 0; i--) {
      final s = statuses[i];
      final accent = DifficultyVisuals.accentFor(s.difficulty);
      if (i < statuses.length - 1) {
        children.add(
          Container(
            width: 2,
            height: 8,
            color: s.cleared
                ? accent.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.18),
          ),
        );
      }
      children.add(
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: s.cleared
                ? accent
                : s.current
                ? accent.withValues(alpha: 0.25)
                : Colors.transparent,
            border: Border.all(
              color: s.locked ? Colors.white.withValues(alpha: 0.25) : accent,
              width: s.current ? 2.2 : 1.4,
            ),
            boxShadow: s.current
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: s.cleared
              ? CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: 8,
                  accent: DifficultyVisuals.inkOn(s.difficulty),
                  framed: false,
                )
              : null,
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Cenas
// ─────────────────────────────────────────────────────────────────────────

/// Cena viva de cada modo. [t] em 0–1 fecha o ciclo sem salto.
///
/// - Observação: amanhecer — feixes de luz e pontos que sobem do chão.
/// - Compreensão: constelação — um pulso percorre e acende as ligações.
/// - Interpretação: profundeza — anéis que se abrem e ondas em camadas.
class ModeScenePainter extends CustomPainter {
  final TrailDifficulty difficulty;
  final Color color;
  final double t;
  final double intensity;
  final double parallax;
  final bool locked;

  ModeScenePainter({
    required this.difficulty,
    required this.color,
    required this.t,
    this.intensity = 1,
    this.parallax = 0,
    this.locked = false,
  });

  static double _frac(double x) => x - x.floorToDouble();
  static const _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = locked ? 0.12 : 0.34;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: switch (difficulty) {
            TrailDifficulty.semente => [
              Color.lerp(AppColors.night, color, base * 0.25)!,
              Color.lerp(AppColors.night, color, base * 0.9)!,
            ],
            TrailDifficulty.caminhada => [
              Color.lerp(AppColors.night, color, base * 0.55)!,
              Color.lerp(AppColors.night, color, base * 0.2)!,
            ],
            TrailDifficulty.profundezas => [
              Color.lerp(AppColors.night, color, base * 0.7)!,
              Color.lerp(AppColors.night, Colors.black, 0.4)!,
            ],
          },
        ).createShader(rect),
    );
    final k = (locked ? 0.25 : 1.0) * intensity;
    canvas.save();
    canvas.translate(parallax * size.width * 0.12, 0);
    switch (difficulty) {
      case TrailDifficulty.semente:
        _dawn(canvas, size, k);
      case TrailDifficulty.caminhada:
        _constellation(canvas, size, k);
      case TrailDifficulty.profundezas:
        _depths(canvas, size, k);
    }
    canvas.restore();
  }

  void _dawn(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    // Feixes que abrem do alto e balançam devagar.
    final origin = Offset(w * 0.18, -h * 0.08);
    final sway = math.sin(t * _tau) * 0.05;
    final len = math.max(w, h) * 1.6;
    for (var i = 0; i < 4; i++) {
      final a = 0.55 + i * 0.22 + sway;
      final spread = 0.07 + 0.02 * i;
      final p1 =
          origin + Offset(math.cos(a - spread), math.sin(a - spread)) * len;
      final p2 =
          origin + Offset(math.cos(a + spread), math.sin(a + spread)) * len;
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close(),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.16 * k),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: origin, radius: len * 0.7)),
      );
    }
    // Chão que brilha.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 1.04),
        width: w * 1.3,
        height: h * 0.42,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                color.withValues(alpha: 0.42 * k),
                color.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(w / 2, h), radius: w * 0.7),
            ),
    );
    // Pontos de luz que sobem.
    final count = (w * h / 3200).clamp(10, 30).round();
    final mote = Color.lerp(color, Colors.white, 0.4)!;
    for (var i = 0; i < count; i++) {
      final x = w * (0.04 + 0.92 * _frac(i * 0.618));
      final speed = (i % 3 + 1).toDouble();
      final p = _frac(t * speed + _frac(i * 0.293));
      final y = h * (1.05 - p * 1.12);
      final dx = math.sin((p * 2 + i * 0.17) * _tau) * 4;
      final alpha = math.sin(p * math.pi) * k;
      final r = 1.0 + 1.8 * _frac(i * 0.731);
      canvas.drawCircle(
        Offset(x + dx, y),
        r * 3,
        Paint()..color = color.withValues(alpha: alpha * 0.14),
      );
      canvas.drawCircle(
        Offset(x + dx, y),
        r,
        Paint()..color = mote.withValues(alpha: alpha * 0.9),
      );
    }
  }

  void _constellation(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    // Céu de fundo que cintila.
    for (var i = 0; i < 34; i++) {
      final x = w * _frac(i * 0.754 + 0.1);
      final y = h * _frac(i * 0.381 + 0.05);
      final tw = 0.5 + 0.5 * math.sin((t * 2 + _frac(i * 0.47)) * _tau);
      canvas.drawCircle(
        Offset(x, y),
        0.6 + 0.6 * _frac(i * 0.29),
        Paint()..color = Colors.white.withValues(alpha: (0.12 + 0.3 * tw) * k),
      );
    }
    final tall = h > w * 0.8;
    final pts = tall
        ? const [
            Offset(0.14, 0.52),
            Offset(0.34, 0.24),
            Offset(0.52, 0.42),
            Offset(0.70, 0.16),
            Offset(0.86, 0.36),
            Offset(0.66, 0.56),
          ]
        : const [
            Offset(0.40, 0.74),
            Offset(0.52, 0.30),
            Offset(0.64, 0.62),
            Offset(0.76, 0.22),
            Offset(0.90, 0.52),
            Offset(0.98, 0.80),
          ];
    final nodes = [for (final p in pts) Offset(p.dx * w, p.dy * h)];
    final segs = nodes.length - 1;
    // Ciclo: desenha (0–0.7), segura (0.7–0.85), apaga (0.85–1).
    final draw = (t / 0.7).clamp(0.0, 1.0);
    final fade = t < 0.85 ? 1.0 : 1 - (t - 0.85) / 0.15;
    final p = draw * segs;
    final seg = p.floor().clamp(0, segs - 1);
    final local = p - seg;
    final head = Offset.lerp(nodes[seg], nodes[seg + 1], local)!;

    final all = Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (final n in nodes.skip(1)) {
      all.lineTo(n.dx, n.dy);
    }
    canvas.drawPath(
      all,
      Paint()
        ..color = color.withValues(alpha: 0.16 * k)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    final lit = Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (var i = 1; i <= seg; i++) {
      lit.lineTo(nodes[i].dx, nodes[i].dy);
    }
    lit.lineTo(head.dx, head.dy);
    canvas.drawPath(
      lit,
      Paint()
        ..color = color.withValues(alpha: 0.3 * k * fade)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      lit,
      Paint()
        ..color = color.withValues(alpha: 0.9 * k * fade)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    final star = Color.lerp(color, Colors.white, 0.3)!;
    for (var i = 0; i < nodes.length; i++) {
      final reached = i < p + 0.02;
      final pop = reached ? 1 - (p - i).clamp(0.0, 1.0) : 0.0;
      final r = 2.4 + (reached ? 1.2 : 0) + 2.2 * pop;
      canvas.drawCircle(
        nodes[i],
        r * 3,
        Paint()
          ..color = color.withValues(
            alpha: (reached ? 0.22 + 0.3 * pop : 0.05) * k * fade,
          ),
      );
      canvas.drawCircle(
        nodes[i],
        r,
        Paint()
          ..color = (reached ? star : color).withValues(
            alpha: (reached ? 1.0 : 0.4) * k,
          ),
      );
    }
    if (draw < 1) {
      canvas.drawCircle(
        head,
        9,
        Paint()
          ..color = color.withValues(alpha: 0.35 * k)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        head,
        2.6,
        Paint()..color = Colors.white.withValues(alpha: 0.95 * k),
      );
    }
  }

  void _depths(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w * 0.5, h * 0.40);
    // Anéis que se abrem do centro.
    for (var i = 0; i < 4; i++) {
      final p = _frac(t * 2 + i / 4);
      final r = w * (0.08 + 0.62 * Curves.easeOut.transform(p));
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2, height: r * 1.1),
        Paint()
          ..color = color.withValues(alpha: (1 - p) * 0.55 * k)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8 * (1 - p) + 0.4,
      );
    }
    canvas.drawCircle(
      c,
      w * 0.3,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.3 * k),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: w * 0.3)),
    );
    // Ondas em camadas — cada uma com ritmo inteiro (loop limpo).
    for (var layer = 0; layer < 3; layer++) {
      final baseY = h * (0.62 + layer * 0.12);
      final amp = h * (0.035 - layer * 0.008);
      final phase = t * _tau * (layer + 1) * (layer.isEven ? 1 : -1);
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w + 4; x += 4) {
        final y =
            baseY + math.sin(x / w * _tau * (1.2 + layer * 0.4) + phase) * amp;
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            color,
            AppColors.night,
            0.45 + layer * 0.18,
          )!.withValues(alpha: (0.34 + layer * 0.16) * k),
      );
    }
    // Partículas que afundam devagar.
    final grain = Color.lerp(color, Colors.white, 0.3)!;
    for (var i = 0; i < 14; i++) {
      final x = w * (0.06 + 0.88 * _frac(i * 0.414));
      final p = _frac(t + _frac(i * 0.57));
      final y = h * (-0.04 + p * 1.08);
      canvas.drawCircle(
        Offset(x + math.sin((p + i * 0.3) * _tau) * 3, y),
        0.8 + _frac(i * 0.63) * 1.2,
        Paint()
          ..color = grain.withValues(alpha: math.sin(p * math.pi) * 0.6 * k),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ModeScenePainter old) =>
      old.t != t ||
      old.intensity != intensity ||
      old.parallax != parallax ||
      old.locked != locked ||
      old.color != color ||
      old.difficulty != difficulty;
}
