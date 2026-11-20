import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/caravan_profile_prefs.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'profile_privacy.dart';

/// Sequência em calendário de chamas: o número grande com a chama viva, a
/// meta em barra e o mês em grade — cada dia caminhado é uma chama, dias
/// seguidos se ligam numa faixa, gelo é cristal, hoje é um anel.
class StreakFlameCalendar extends StatefulWidget {
  final int streak;
  final int goal;
  final bool atRisk;
  final bool freezeAvailable;
  final bool freezeUsed;

  /// O olho de privacidade; false quando o quadro já o mostra no cabeçalho.
  final bool showEye;

  const StreakFlameCalendar({
    super.key,
    required this.streak,
    required this.goal,
    this.atRisk = false,
    this.freezeAvailable = false,
    this.freezeUsed = false,
    this.showEye = true,
  });

  @override
  State<StreakFlameCalendar> createState() => _StreakFlameCalendarState();
}

class _StreakFlameCalendarState extends State<StreakFlameCalendar> {
  /// 0 = mês atual; 1 = o anterior…
  int _back = 0;

  /// Quantos meses dá para voltar: até o primeiro dia caminhado (máx. 12).
  int _maxBack(ProgressService p, DateTime now) {
    final first = p.playDates.isEmpty
        ? null
        : DateTime.tryParse(([...p.playDates]..sort()).first);
    if (first == null) return 0;
    final months = (now.year - first.year) * 12 + now.month - first.month;
    return months.clamp(0, 12);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final progress = context.watch<ProgressService>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final streak = widget.streak;
    final goal = math.max(1, widget.goal);
    final done = streak >= goal;
    final hot = done ? AppRoles.reward : AppRoles.streak;
    final growth = SpiritualGrowth.fromStreak(streak);
    final maxBack = _maxBack(progress, now);
    final back = _back.clamp(0, maxBack);
    final month = DateTime(now.year, now.month - back);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final monthLabel = toBeginningOfSentenceCase(
      DateFormat.yMMMM(tag).format(month),
    );
    final best = math.max(progress.bestStreak, streak);

    bool played(DateTime d) => progress.playedOnDate(d);
    bool frozen(DateTime d) => progress.wasFrozenOnDate(d);
    bool repaired(DateTime d) => progress.wasRepairedOnDate(d);
    bool kept(DateTime d) => played(d) || frozen(d) || repaired(d);

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    var walkedInMonth = 0;
    for (var i = 1; i <= daysInMonth; i++) {
      if (played(DateTime(month.year, month.month, i))) walkedInMonth++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho compacto: chama, número com rótulo e selos na mesma
        // coluna; o olho no canto.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _LiveFlame(lit: streak > 0, hot: hot, atRisk: widget.atRisk),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$streak',
                        style:
                            AppTypography.title(
                              size: 32,
                              weight: FontWeight.w900,
                              height: 1,
                              color: a.ink(hot),
                            ).copyWith(
                              fontFeatures: const [FontFeature.liningFigures()],
                              shadows: [
                                if (streak > 0)
                                  Shadow(
                                    color: hot.withValues(alpha: 0.5),
                                    blurRadius: 14,
                                  ),
                              ],
                            ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.profileStatStreak,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w800,
                            color: a.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (streak > 0)
                        _Chip(
                          glyph: _stageGlyph(growth.stage),
                          text: growth.title,
                          color: AppRoles.streak,
                        ),
                      if (widget.atRisk)
                        _Chip(
                          glyph: CinematicGlyph.hourglass,
                          text: l10n.homeStatAtRisk,
                          color: AppRoles.risk,
                        ),
                      if (widget.freezeUsed || widget.freezeAvailable)
                        _Chip(
                          glyph: CinematicGlyph.frost,
                          text: widget.freezeUsed
                              ? l10n.homeStatFreezeUsed
                              : l10n.homeStatFreeze,
                          color: widget.freezeUsed ? a.textFaint : a.chrome,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.showEye)
              PrivacyEye(
                sections: const {CaravanProfileSection.presence},
                label: l10n.pilgrimStreak,
              ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        _GoalBar(streak: streak, goal: goal, hot: hot, done: done),
        const SizedBox(height: AppSpace.sm),
        // Mês.
        Row(
          children: [
            Expanded(
              child: Text(
                monthLabel,
                style: AppTypography.title(
                  size: 15,
                  weight: FontWeight.w900,
                  color: a.text,
                ),
              ),
            ),
            _NavButton(
              glyph: CinematicGlyph.back,
              enabled: back < maxBack,
              onTap: () => setState(() => _back = back + 1),
            ),
            const SizedBox(width: 4),
            _NavButton(
              glyph: CinematicGlyph.forward,
              enabled: back > 0,
              onTap: () => setState(() => _back = back - 1),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xs),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _MonthGrid(
            key: ValueKey(month),
            month: month,
            today: today,
            tag: tag,
            hot: hot,
            played: played,
            frozen: frozen,
            repaired: repaired,
            kept: kept,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.trophy,
              size: 16,
              accent: AppRoles.reward,
              framed: false,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.profileBestStreak(best),
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: a.text,
                ),
              ),
            ),
            Text(
              l10n.profileMonthWalked(walkedInMonth),
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

CinematicGlyph _stageGlyph(GrowthStage stage) => switch (stage) {
  GrowthStage.seed => CinematicGlyph.seed,
  GrowthStage.sprout => CinematicGlyph.sprout,
  GrowthStage.branch => CinematicGlyph.rise,
  GrowthStage.tree => CinematicGlyph.tree,
  GrowthStage.fruit => CinematicGlyph.gem,
};

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime today;
  final String tag;
  final Color hot;
  final bool Function(DateTime) played;
  final bool Function(DateTime) frozen;
  final bool Function(DateTime) repaired;
  final bool Function(DateTime) kept;

  const _MonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.tag,
    required this.hot,
    required this.played,
    required this.frozen,
    required this.repaired,
    required this.kept,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final narrow = DateFormat('EEEEE', tag);
    final first = DateTime(month.year, month.month, 1);
    final lead = first.weekday - 1; // segunda primeiro
    final days = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((lead + days) / 7).ceil();
    // Segunda de referência para os nomes dos dias.
    final monday = DateTime(2024, 1, 1);

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    narrow.format(monday.add(Duration(days: i))).toUpperCase(),
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0.6,
                      color: a.textFaint,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        for (var r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: _cell(context, r * 7 + c - lead + 1, days, c),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, int day, int days, int col) {
    if (day < 1 || day > days) return const SizedBox(height: 24);
    final d = DateTime(month.year, month.month, day);
    final prev = d.subtract(const Duration(days: 1));
    final next = d.add(const Duration(days: 1));
    final isKept = kept(d);
    // Faixa ligando dias seguidos na mesma linha.
    final joinLeft = isKept && col > 0 && day > 1 && kept(prev);
    final joinRight = isKept && col < 6 && day < days && kept(next);
    return _DayCell(
      day: day,
      isToday: d == today,
      future: d.isAfter(today),
      played: played(d),
      frozen: frozen(d),
      repaired: repaired(d),
      joinLeft: joinLeft,
      joinRight: joinRight,
      hot: hot,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool future;
  final bool played;
  final bool frozen;
  final bool repaired;
  final bool joinLeft;
  final bool joinRight;
  final Color hot;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.future,
    required this.played,
    required this.frozen,
    required this.repaired,
    required this.joinLeft,
    required this.joinRight,
    required this.hot,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const size = 22.0;
    final ink = a.ink(hot);
    final band = ink.withValues(alpha: 0.22);

    Widget mark;
    if (played) {
      mark = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFFE8452C), Color(0xFFFF9A2E)],
          ),
          boxShadow: [
            BoxShadow(color: hot.withValues(alpha: 0.45), blurRadius: 5),
          ],
        ),
        alignment: Alignment.center,
        child: const CinematicIcon(
          glyph: CinematicGlyph.flame,
          size: 10,
          accent: Colors.white,
          framed: false,
        ),
      );
    } else if (frozen) {
      mark = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFBFE6FF), Color(0xFF6FB7EA)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6FB7EA).withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const CinematicIcon(
          glyph: CinematicGlyph.frost,
          size: 11,
          accent: Colors.white,
          framed: false,
        ),
      );
    } else if (repaired) {
      mark = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ink, width: 2),
        ),
        alignment: Alignment.center,
        child: CinematicIcon(
          glyph: CinematicGlyph.flame,
          size: 12,
          accent: ink,
          framed: false,
        ),
      );
    } else {
      mark = Container(
        width: size,
        height: size,
        decoration: isToday
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ink, width: 2),
              )
            : null,
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: AppTypography.body(
            size: 11,
            weight: isToday ? FontWeight.w900 : FontWeight.w700,
            color: isToday
                ? ink
                : future
                ? a.textFaint.withValues(alpha: 0.5)
                : a.textFaint,
          ),
        ),
      );
    }

    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (joinLeft || joinRight)
            Row(
              children: [
                Expanded(
                  child: Container(height: 14, color: joinLeft ? band : null),
                ),
                Expanded(
                  child: Container(height: 14, color: joinRight ? band : null),
                ),
              ],
            ),
          mark,
        ],
      ),
    );
  }
}

class _GoalBar extends StatelessWidget {
  final int streak;
  final int goal;
  final Color hot;
  final bool done;

  const _GoalBar({
    required this.streak,
    required this.goal,
    required this.hot,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ratio = (streak / goal).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: a.progressTrack,
            ),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => FractionallySizedBox(
                widthFactor: math.max(t, ratio > 0 ? 0.04 : 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [hot.withValues(alpha: 0.7), hot],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: hot.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        CinematicIcon(
          glyph: CinematicGlyph.crown,
          size: 18,
          accent: done ? AppRoles.reward : a.textFaint,
          framed: false,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak/$goal',
          style: AppTypography.title(
            size: 13,
            weight: FontWeight.w900,
            color: done ? a.ink(AppRoles.reward) : a.textSecondary,
          ).copyWith(fontFeatures: const [FontFeature.liningFigures()]),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final CinematicGlyph glyph;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.glyph,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              ActHaptics.tap();
              onTap();
            }
          : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: a.cardBorder.withValues(alpha: enabled ? 1 : 0.4),
          ),
        ),
        alignment: Alignment.center,
        child: CinematicIcon(
          glyph: glyph,
          size: 14,
          accent: enabled ? a.text : a.textFaint.withValues(alpha: 0.4),
          framed: false,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final CinematicGlyph glyph;
  final String text;
  final Color color;

  const _Chip({required this.glyph, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final ink = Appearance.of(context).ink(color);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 8, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        color: ink.withValues(alpha: 0.14),
        border: Border.all(color: ink.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(glyph: glyph, size: 12, accent: ink, framed: false),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w800,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chama pintada que tremula; apagada (brasa cinza) sem sequência.
class _LiveFlame extends StatefulWidget {
  final bool lit;
  final Color hot;
  final bool atRisk;

  const _LiveFlame({
    required this.lit,
    required this.hot,
    required this.atRisk,
  });

  @override
  State<_LiveFlame> createState() => _LiveFlameState();
}

class _LiveFlameState extends State<_LiveFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.lit || MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = Appearance.of(context).cardBorder;
    return SizedBox(
      width: 36,
      height: 44,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _FlamePainter(
              phase: _c.value * math.pi * 2,
              lit: widget.lit,
              hot: widget.hot,
              atRisk: widget.atRisk,
              track: track,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double phase;
  final bool lit;
  final Color hot;
  final bool atRisk;
  final Color track;

  _FlamePainter({
    required this.phase,
    required this.lit,
    required this.hot,
    required this.atRisk,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final base = Offset(w / 2, h - 4);
    final speed = atRisk ? 2.0 : 1.0;
    final flicker =
        1 + 0.06 * math.sin(phase * 4 * speed) + 0.03 * math.sin(phase * 11);
    final fh = (h - 8) * flicker;
    final fw = w * 0.42;
    final sway = math.sin(phase * 3 * speed) * fw * 0.14;

    Path flame(double hh, double ww, double s) => Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(
        base.dx - ww * 1.1,
        base.dy - hh * 0.1,
        base.dx - ww * 0.75,
        base.dy - hh * 0.62,
        base.dx + s,
        base.dy - hh,
      )
      ..cubicTo(
        base.dx + ww * 0.75,
        base.dy - hh * 0.62,
        base.dx + ww * 1.1,
        base.dy - hh * 0.1,
        base.dx,
        base.dy,
      )
      ..close();

    if (!lit) {
      canvas.drawPath(flame(fh * 0.8, fw * 0.9, 0), Paint()..color = track);
      return;
    }
    final bounds = Rect.fromLTWH(0, 0, w, h);
    canvas.drawPath(
      flame(fh, fw * 1.25, sway),
      Paint()
        ..color = hot.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      flame(fh, fw, sway),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFE8452C), Color(0xFFFF8A2A), Color(0xFFFFC94A)],
        ).createShader(bounds),
    );
    canvas.drawPath(
      flame(fh * 0.55, fw * 0.45, sway * 0.6),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFF6D6), Color(0xFFFFE08A)],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) =>
      old.phase != phase ||
      old.lit != lit ||
      old.hot != hot ||
      old.atRisk != atRisk ||
      old.track != track;
}
