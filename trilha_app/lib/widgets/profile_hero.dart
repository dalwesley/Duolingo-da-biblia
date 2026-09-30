import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../models/caravan_profile_prefs.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'pilgrim_profile_sections.dart';
import 'profile_privacy.dart';
import 'top_bar.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Topo do perfil do dono: retrato grande, nome, título e os três números
/// que contam a caminhada, sobre o gradiente da fase do dia (sem cenário).
/// Substitui barra + cartão de identidade.
class ProfileHero extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;
  final VoidCallback? onEditPortrait;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  /// Título curto (posição na caravana, recorde…), já pronto para exibir.
  final String? epithet;
  final Color? epithetColor;

  /// "Peregrino desde setembro de 2026".
  final String? sinceLabel;
  final int steps;
  final int missions;
  final int? accuracyPercent;

  const ProfileHero({
    super.key,
    required this.name,
    this.photoUrl,
    this.seed,
    this.style = PortraitStyle.photo,
    this.onEditPortrait,
    this.onBack,
    this.onSettings,
    this.epithet,
    this.epithetColor,
    this.sinceLabel,
    required this.steps,
    required this.missions,
    this.accuracyPercent,
  });

  static String sinceFrom(String? ymd) {
    final l = L10n.current;
    if (ymd == null || ymd.length < 7) return l.pilgrimFallbackName;
    final parts = ymd.split('-');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      return l.pilgrimFallbackName;
    }
    final monthName = DateFormat.MMMM(l.localeName)
        .format(DateTime(year, month))
        .replaceAll('.', '');
    return l.profileSince(monthName, year);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final top = MediaQuery.viewPaddingOf(context).top;
    final displayName =
        name.trim().isEmpty ? l10n.pilgrimFallbackName : name.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        top + AppSpace.sm,
        AppSpace.screen,
        0,
      ),
      child: Column(
        children: [
          if (onBack != null || onSettings != null)
            TopBar(
              inline: true,
              immersive: true,
              dark: a.onDark,
              title: l10n.profileTitle,
              subtitle: l10n.profileYourJourney,
              leadingGlyph: CinematicGlyph.spark,
              onBack: onBack,
              onTrailingTap: onSettings,
              trailingGlyph: CinematicGlyph.tune,
            ),
          const SizedBox(height: AppSpace.afterTopBar),
          _GlowPortrait(
            child: UserAvatar(
              name: displayName,
              photoUrl: photoUrl,
              seed: seed,
              style: style,
              radius: AppMetrics.avatarHero,
              borderColor: AppRoles.chrome,
              editable: onEditPortrait != null,
              onTap: onEditPortrait,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(
              size: 28,
              weight: FontWeight.w900,
              height: 1.05,
              color: a.text,
            ),
          ),
          if ((epithet ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              epithet!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w800,
                color: epithetColor ?? AppRoles.chrome,
              ),
            ),
          ],
          if ((sinceLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sinceLabel!,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          _HeroStats(
            steps: steps,
            missions: missions,
            accuracyPercent: accuracyPercent,
          ),
        ],
      ),
    );
  }
}

/// Brilho neutro que respira devagar em volta do retrato.
class _GlowPortrait extends StatefulWidget {
  final Widget child;

  const _GlowPortrait({required this.child});

  @override
  State<_GlowPortrait> createState() => _GlowPortraitState();
}

class _GlowPortraitState extends State<_GlowPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
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
    // Só a sombra anima: retrato em cache e o hero não repinta por frame.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = 0.5 + 0.5 * math.sin(_c.value * math.pi * 2);
          // Só o brilho respira em volta — sem anel afastado, o retrato
          // encosta na própria borda.
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppRoles.chrome.withValues(alpha: 0.1 + 0.1 * t),
                  blurRadius: 26 + 14 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  final int steps;
  final int missions;
  final int? accuracyPercent;

  const _HeroStats({
    required this.steps,
    required this.missions,
    required this.accuracyPercent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final items = <(String, String, CinematicGlyph, Color)>[
      (
        pilgrimFormatCount(steps),
        l10n.pilgrimStatSteps,
        CinematicGlyph.path,
        AppRoles.reward,
      ),
      (
        pilgrimFormatCount(missions),
        l10n.pilgrimStatScenes,
        CinematicGlyph.scroll,
        AppRoles.success,
      ),
      if (accuracyPercent != null)
        (
          '$accuracyPercent%',
          l10n.pilgrimAccuracyTitle,
          CinematicGlyph.check,
          AppRoles.success,
        ),
    ];
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Container(width: 1, height: 36, color: a.cardBorder),
            Expanded(
              child: Semantics(
                label: '${items[i].$1} ${items[i].$2}',
                excludeSemantics: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CinematicIcon(
                          glyph: items[i].$3,
                          size: AppMetrics.iconSm,
                          accent: items[i].$4,
                          framed: false,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              items[i].$1,
                              style: AppTypography.display(
                                size: 20,
                                weight: FontWeight.w900,
                                color: a.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Passos, clareza e dias no topo: um olho só para os números.
          PrivacyEye(
            sections: const {
              CaravanProfileSection.ranking,
              CaravanProfileSection.accuracy,
              CaravanProfileSection.daysAsLeader,
            },
            label: l10n.profileYourNumbers,
          ),
        ],
      ),
    );
  }
}

/// "Sua sequência": anel da sequência contra o compromisso firmado, a
/// semana dia a dia e a tendência das últimas 12 semanas (sob demanda).
class ConstancyCard extends StatefulWidget {
  final List<String> playDates;
  final int streak;
  final int goal;

  const ConstancyCard({
    super.key,
    required this.playDates,
    required this.streak,
    required this.goal,
  });

  static const weeks = 12;

  /// Abre o histórico de jarros por padrão após ~3 semanas de caminhada.
  static const historyAutoOpenDays = 21;

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  State<ConstancyCard> createState() => _ConstancyCardState();
}

class _ConstancyCardState extends State<ConstancyCard> {
  late bool _historyOpen;

  @override
  void initState() {
    super.initState();
    _historyOpen = widget.playDates.length >= ConstancyCard.historyAutoOpenDays;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final played = widget.playDates.toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Colunas = semanas (segunda→domingo, como no resto do app); a última
    // termina nesta semana.
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final start = monday.subtract(
      const Duration(days: 7 * (ConstancyCard.weeks - 1)),
    );
    var walked = 0;
    final perWeek = List<int>.filled(ConstancyCard.weeks, 0);
    for (var i = 0; i <= today.difference(start).inDays; i++) {
      if (played.contains(ConstancyCard._key(start.add(Duration(days: i))))) {
        walked++;
        perWeek[i ~/ 7]++;
      }
    }
    final goal = widget.goal;
    final streak = widget.streak;
    final ratio = goal <= 0 ? 0.0 : (streak / goal).clamp(0.0, 1.0);
    final done = streak >= goal && goal > 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                label: l10n.profileStreakOf(streak, goal),
                excludeSemantics: true,
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: CustomPaint(
                    painter: _RingPainter(
                      ratio: ratio,
                      track: a.cardBorder,
                      done: done,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$streak',
                            style: AppTypography.display(
                              size: 24,
                              weight: FontWeight.w900,
                              height: 1,
                              color: a.text,
                            ),
                          ),
                          Text(
                            l10n.profileStreakOfGoal(goal),
                            style: AppTypography.body(
                              size: 11,
                              weight: FontWeight.w700,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.profileYourStreak,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title(
                                    size: 16,
                                    color: a.text,
                                  ),
                                ),
                              ),
                              if (streak > 0) ...[
                                const SizedBox(width: 8),
                                SoftBadge(
                                  text: SpiritualGrowth.fromStreak(
                                    streak,
                                  ).title,
                                  accent: AppRoles.streak,
                                  textColor: AppRoles.streak,
                                  bordered: false,
                                ),
                              ],
                            ],
                          ),
                        ),
                        PrivacyEye(
                          sections: const {CaravanProfileSection.presence},
                          label: l10n.pilgrimStreak,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      done
                          ? l10n.profileStreakGoalDone(goal)
                          : streak == 0
                          ? l10n.profileStreakStart
                          : l10n.profileStreakRemaining(goal - streak, goal),
                      style: AppTypography.body(
                        size: 13,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _WeekDots(start: monday, today: today, played: played),
          const SizedBox(height: AppSpace.lg),
          const ListDivider(),
          const SizedBox(height: AppSpace.sm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ActHaptics.tap();
                setState(() => _historyOpen = !_historyOpen);
              },
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: SectionLabel(l10n.profileWeekHistory),
                    ),
                    RotatedBox(
                      quarterTurns: _historyOpen ? 3 : 1,
                      child: ListChevron(color: a.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_historyOpen) ...[
            const SizedBox(height: AppSpace.sm),
            _WeeksTrend(
              perWeek: perWeek,
              walked: walked,
              weeks: ConstancyCard.weeks,
            ),
          ],
        ],
      ),
    );
  }
}

/// Esta semana, dia a dia (S T Q Q S S D): o mesmo idioma das bolinhas da
/// Home — acesa com check, hoje com anel, futuro apagado.
class _WeekDots extends StatelessWidget {
  final DateTime start;
  final DateTime today;
  final Set<String> played;

  const _WeekDots({
    required this.start,
    required this.today,
    required this.played,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final letters = [
      l10n.profileWdMon,
      l10n.profileWdTue,
      l10n.profileWdWed,
      l10n.profileWdThu,
      l10n.profileWdFri,
      l10n.profileWdSat,
      l10n.profileWdSun,
    ];
    final days = [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];
    final count = days
        .where((d) => played.contains(ConstancyCard._key(d)))
        .length;
    return Semantics(
      label: l10n.profileThisWeekSemantics(count),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SectionLabel(l10n.profileThisWeek),
              const Spacer(),
              Text(
                l10n.profileOfSevenDays(count),
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: count > 0 ? AppRoles.streak : a.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _DayDot(
                  letter: letters[i],
                  on: played.contains(ConstancyCard._key(days[i])),
                  isToday: days[i] == today,
                  future: days[i].isAfter(today),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String letter;
  final bool on;
  final bool isToday;
  final bool future;

  const _DayDot({
    required this.letter,
    required this.on,
    required this.isToday,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const size = 34.0;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on
                ? AppRoles.streak
                : future
                ? Colors.transparent
                : a.divider,
            border: on
                ? null
                : Border.all(
                    color: isToday
                        ? AppRoles.streak
                        : future
                        ? a.divider
                        : Colors.transparent,
                    width: isToday ? 2 : 1,
                  ),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: AppRoles.streak.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: on
              ? const CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: AppMetrics.iconSm,
                  accent: AppColors.textOnDark,
                  framed: false,
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          isToday ? context.l10n.profileTodayLower : letter,
          style: AppTypography.body(
            size: 11,
            weight: FontWeight.w800,
            color: isToday
                ? AppRoles.streak
                : (future ? a.textFaint : a.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Últimas semanas em barras: altura = dias caminhados naquela semana.
/// Lê como tendência ("estou caminhando mais?"), não como grade de dados.
class _WeeksTrend extends StatelessWidget {
  final List<int> perWeek;
  final int walked;
  final int weeks;

  const _WeeksTrend({
    required this.perWeek,
    required this.walked,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    const maxBar = 28.0;
    return Semantics(
      label: l10n.profileWeeksWalkedSemantics(walked, weeks),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SectionLabel(l10n.profileLastThreeMonths),
              const Spacer(),
              Text(
                l10n.profileDaysPerWeek,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: a.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          // Cada coluna é uma semana: trilho = 7 dias, ouro = dias
          // caminhados, número em cima quando houve caminhada.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var w = 0; w < perWeek.length; w++) ...[
                if (w > 0) const SizedBox(width: 6),
                Expanded(
                  child: _WeekBar(
                    days: perWeek[w],
                    height: maxBar,
                    current: w == perWeek.length - 1,
                    index: w,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                l10n.profileThreeMonthsAgo,
                style: AppTypography.body(
                  size: 11,
                  weight: FontWeight.w600,
                  color: a.textFaint,
                ),
              ),
              const Spacer(),
              Text(
                l10n.profileThisWeekLower,
                style: AppTypography.body(
                  size: 11,
                  weight: FontWeight.w600,
                  color: a.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            l10n.profileLampHelp,
            style: AppTypography.verse(
              size: 14,
              color: a.textSecondary,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Uma semana como jarro de azeite: cada dia caminhado enche um pouco mais
/// — o óleo da unção, a lâmpada que não se apaga (Mt 25:4).
class _WeekBar extends StatefulWidget {
  final int days;
  final double height;
  final bool current;
  final int index;

  const _WeekBar({
    required this.days,
    required this.height,
    required this.current,
    required this.index,
  });

  @override
  State<_WeekBar> createState() => _WeekBarState();
}

class _WeekBarState extends State<_WeekBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.days > 0 && !still) {
      if (!_wave.isAnimating) _wave.repeat();
    } else {
      _wave.stop();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final target = widget.days / 7;
    return Column(
      children: [
        SizedBox(
          height: 16,
          child: widget.days > 0
              ? Text(
                  '${widget.days}',
                  style: AppTypography.body(
                    size: 11,
                    weight: FontWeight.w800,
                    color: widget.current ? a.text : a.textSecondary,
                  ),
                )
              : null,
        ),
        // Chama no pavio: cresce com a semana; semana vazia, sem chama.
        AnimatedBuilder(
          animation: _wave,
          builder: (context, _) => CustomPaint(
            size: const Size(double.infinity, 22),
            painter: _WickFlamePainter(
              days: widget.days,
              phase: _wave.value * 2 * math.pi + widget.index * 1.3,
            ),
          ),
        ),
        // O azeite é derramado ao abrir: sobe do fundo até o nível.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: target),
          duration: Duration(milliseconds: 700 + widget.index * 40),
          curve: Curves.easeOutCubic,
          builder: (context, level, _) => AnimatedBuilder(
            animation: _wave,
            builder: (context, _) => CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _OilVesselPainter(
                level: level,
                phase: _wave.value * 2 * math.pi + widget.index * 0.9,
                glass: a.text,
                current: widget.current,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OilVesselPainter extends CustomPainter {
  final double level;
  final double phase;
  final Color glass;
  final bool current;

  _OilVesselPainter({
    required this.level,
    required this.phase,
    required this.glass,
    required this.current,
  });

  // Jarro reto: paredes retas, fundo arredondado e aba na boca — o
  // recipiente simples do azeite, sem virar garrafa.
  static const _neckBottom = 0.0;
  static const _rim = 4.0;

  Path _vessel(Size size) {
    final w = size.width;
    final h = size.height;
    final inset = w * 0.06;
    return Path()..addRRect(
      RRect.fromLTRBAndCorners(
        inset,
        _rim - 1,
        w - inset,
        h,
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: Radius.circular(w * 0.28),
        bottomRight: Radius.circular(w * 0.28),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final vessel = _vessel(size);

    // Vidro translúcido o bastante para ver o azeite.
    canvas.drawPath(
      vessel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            glass.withValues(alpha: 0.12),
            glass.withValues(alpha: 0.05),
          ],
        ).createShader(Offset.zero & size),
    );

    if (level > 0) {
      canvas.save();
      canvas.clipPath(vessel);
      final top = _rim + 2 + h * _neckBottom;
      final surface = h - (h - top) * level;
      final amp = level >= 0.99 ? 0.0 : 1.1;
      final oil = Path()..moveTo(0, surface);
      for (var x = 0.0; x <= w; x += 1) {
        oil.lineTo(x, surface + math.sin(phase + x / w * 2 * math.pi) * amp);
      }
      oil
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        oil,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFE08A).withValues(alpha: current ? 1 : 0.85),
              AppColors.accent.withValues(alpha: current ? 1 : 0.85),
              const Color(0xFFB07A00).withValues(alpha: current ? 1 : 0.85),
            ],
            stops: const [0, 0.35, 1],
          ).createShader(Rect.fromLTRB(0, surface - 2, w, h)),
      );
      canvas.drawLine(
        Offset(w * 0.2, surface + 1.1),
        Offset(w * 0.5, surface + 1.1),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    // Reflexo vertical na parede.
    canvas.drawLine(
      Offset(w * 0.26, h * 0.3),
      Offset(w * 0.26, h * 0.78),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );

    // Aba da boca: faixa um pouco mais larga que o corpo.
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, w, _rim, const Radius.circular(2)),
      Paint()
        ..color = glass.withValues(alpha: current ? 0.7 : 0.3),
    );

    // Contorno: a semana atual um pouco mais acesa.
    canvas.drawPath(
      vessel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = current ? 1.4 : 1
        ..color = glass.withValues(alpha: current ? 0.55 : 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _OilVesselPainter old) =>
      old.level != level ||
      old.phase != phase ||
      old.glass != glass ||
      old.current != current;
}

/// Chama sobre o jarro: nenhuma (semana vazia), pequena (1–3 dias), média
/// (4–6) ou grande com brilho (semana inteira) — Lv 6:13, Mt 25:4.
class _WickFlamePainter extends CustomPainter {
  final int days;
  final double phase;

  _WickFlamePainter({required this.days, required this.phase});

  double get _tier => switch (days) {
    <= 0 => 0,
    <= 3 => 0.45,
    <= 6 => 0.72,
    _ => 1,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final base = h - 2.5;

    final tier = _tier;
    if (tier == 0) return;

    // Pavio.
    canvas.drawLine(
      Offset(cx, h),
      Offset(cx, base),
      Paint()
        ..color = const Color(0xFF3A2A1A)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    final flicker = 1 + 0.07 * math.sin(phase * 3) + 0.03 * math.sin(phase * 7);
    final fh = (h - 2) * tier * flicker;
    final fw = (w * 0.5).clamp(6.0, 14.0) * (0.55 + 0.45 * tier);
    final sway = math.sin(phase * 2) * 0.9 * tier;

    // Brilho em volta — mais forte na semana inteira.
    final glowC = Offset(cx, base - fh * 0.4);
    final glowR = fh * (days >= 7 ? 1.25 : 0.9);
    canvas.drawCircle(
      glowC,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: days >= 7 ? 0.45 : 0.25),
            AppColors.accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: glowC, radius: glowR)),
    );

    final outer = _drop(cx, base, fw, fh, sway);
    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: const [
            Color(0xFFFF6A1A),
            Color(0xFFFFA82E),
            Color(0xFFFFD36B),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromLTRB(cx - fw, base - fh, cx + fw, base)),
    );
    // Miolo claro.
    canvas.drawPath(
      _drop(cx, base - 0.5, fw * 0.5, fh * 0.55, sway * 0.6),
      Paint()..color = const Color(0xFFFFF4C8).withValues(alpha: 0.95),
    );
  }

  /// Gota de chama: base redonda no pavio, ponta que balança.
  Path _drop(double cx, double base, double fw, double fh, double sway) {
    final r = fw / 2;
    final tip = Offset(cx + sway, base - fh);
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(
        cx + sway * 0.4 + r * 0.3,
        base - fh * 0.65,
        cx + r,
        base - fh * 0.45,
        cx + r,
        base - r,
      )
      ..arcToPoint(Offset(cx - r, base - r), radius: Radius.circular(r))
      ..cubicTo(
        cx - r,
        base - fh * 0.45,
        cx + sway * 0.4 - r * 0.3,
        base - fh * 0.65,
        tip.dx,
        tip.dy,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant _WickFlamePainter old) =>
      old.days != days || old.phase != phase;
}

class _RingPainter extends CustomPainter {
  final double ratio;
  final Color track;
  final bool done;

  _RingPainter({required this.ratio, required this.track, required this.done});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = track,
    );
    if (ratio <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * ratio,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = done ? AppRoles.reward : AppRoles.streak,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.ratio != ratio || old.track != track || old.done != done;
}
