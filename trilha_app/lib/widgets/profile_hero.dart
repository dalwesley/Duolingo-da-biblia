import 'dart:ui' show ImageFilter;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import 'package:intl/intl.dart';

import '../l10n/app_language.dart';
import '../models/caravan_profile_prefs.dart';
import '../l10n/l10n_global.dart';
import '../theme/app_theme.dart';
import '../utils/layout_utils.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'pilgrim_profile_cover.dart';
import 'profile_privacy.dart';
import 'profile_section.dart';
import 'streak_calendar.dart';
import 'streak_week.dart';
import 'top_bar.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Topo do perfil do dono: um cartão só — retrato, nome, título e os três
/// números da caminhada — sobre o gradiente da fase do dia (sem cenário).
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

  /// Selo de Apoiador (apoio avulso) — selo próprio, distinto do de
  /// Peregrino ([pilgrim]).
  final bool supporter;

  /// Selo de Peregrino (assinatura Peregrino+) — exclusivo do assinante.
  final bool pilgrim;

  /// Selo de Pioneiro: assinante do plano de lançamento. Aparece no lugar
  /// do de Peregrino (é o mesmo Peregrino+, com o preço do começo).
  final bool pioneer;
  final int streak;
  final int missions;
  final int postcards;
  final int steps;
  final int? accuracyPercent;
  final int accuracyCorrect;
  final int accuracyTotal;

  /// Posição no ranking do mês (0 = fora).
  final int rank;

  /// Canto da capa, ao lado de "Trocar capa" (o olho dos números).
  final Widget? coverAction;

  /// Cena da capa (escolhida ou a mais recente).
  final String? coverScene;
  final VoidCallback? onChangeCover;

  /// A barra já está presa acima do scroll (perfil com voltar).
  final bool chromePinned;

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
    this.supporter = false,
    this.pilgrim = false,
    this.pioneer = false,
    required this.streak,
    required this.missions,
    required this.postcards,
    this.steps = 0,
    this.accuracyPercent,
    this.accuracyCorrect = 0,
    this.accuracyTotal = 0,
    this.rank = 0,
    this.coverAction,
    this.coverScene,
    this.onChangeCover,
    this.chromePinned = false,
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
    final monthName = DateFormat.MMMM(
      l.localeName,
    ).format(DateTime(year, month)).replaceAll('.', '');
    return l.profileSince(monthName, year);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.viewPaddingOf(context).top;
    final displayName = ProgressService.isPlaceholderUserName(name)
        ? l10n.pilgrimFallbackName
        : name.trim();

    final hasChrome = onBack != null || onSettings != null;
    final showBar = hasChrome && !chromePinned;
    return Column(
      children: [
        if (showBar) ProfileHeroBar(onBack: onBack, onSettings: onSettings),
        ContentFrame(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              hasChrome ? 0 : top + AppSpace.sm,
              AppSpace.screen,
              0,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpace.afterTopBar),
                PilgrimProfileTop(
                  name: displayName,
                  photoUrl: photoUrl,
                  seed: seed,
                  style: style,
                  onEditPortrait: onEditPortrait,
                  coverScene: coverScene,
                  onChangeCover: onChangeCover,
                  coverAction: coverAction,
                  rank: rank,
                  epithet: epithet,
                  sinceLabel: sinceLabel,
                  supporter: supporter,
                  pilgrim: pilgrim,
                  pioneer: pioneer,
                  // Sequência fica só no card de baixo (sem repetir aqui).
                  stats: [
                    PilgrimStat(
                      glyph: CinematicGlyph.sneaker,
                      tone: AppRoles.lamp,
                      value: steps,
                      label: l10n.pilgrimStatSteps,
                    ),
                    PilgrimStat(
                      glyph: CinematicGlyph.scroll,
                      tone: AppRoles.navTrails,
                      value: missions,
                      label: l10n.pilgrimStatScenes,
                    ),
                    if (accuracyPercent != null && accuracyTotal > 0)
                      PilgrimStat(
                        glyph: CinematicGlyph.target,
                        tone: AppRoles.success,
                        value: accuracyPercent!,
                        suffix: '%',
                        label: l10n.pilgrimAccuracyTitle,
                        caption: l10n.pilgrimCorrectRatio(
                          accuracyCorrect,
                          accuracyTotal,
                        ),
                      )
                    else
                      PilgrimStat(
                        glyph: CinematicGlyph.gem,
                        tone: AppColors.clay,
                        value: postcards,
                        label: l10n.postcardsTitle,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Barra do perfil. Com voltar, o dono da tela a deixa fora do scroll.
class ProfileHeroBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const ProfileHeroBar({super.key, this.onBack, this.onSettings});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final top = MediaQuery.viewPaddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        top + AppSpace.sm,
        AppSpace.screen,
        0,
      ),
      child: TopBar(
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
    );
  }
}

/// "Sequência": anel da sequência contra o compromisso firmado, o mesmo
/// pulso da Home (risco + gelo), a semana dia a dia ([StreakWeek], igual à
/// Home), o próximo marco (Semente → Fruto), as missões da semana e, no
/// Peregrino+, a tendência das últimas 12 semanas (sob demanda).
class ConstancyCard extends StatefulWidget {
  final List<String> playDates;
  final int streak;
  final int goal;

  /// Tendência das últimas 12 semanas (Peregrino+).
  final bool showHistory;

  /// Sem [showHistory]: a tendência aparece desfocada, com cadeado, e o
  /// toque chama isto (o paywall). Null esconde a vitrine.
  final VoidCallback? onPlusHistory;

  /// Missões da semana em curso, dentro do card.
  final Widget? quests;

  /// Mesmo estado do pulso da Home: sem cena hoje e a sequência cai à
  /// meia-noite.
  final bool atRisk;

  /// Gelo da semana: ainda disponível / já gasto. Sem nenhum dos dois, o
  /// gelo não aparece (mesma regra da Home).
  final bool freezeAvailable;
  final bool freezeUsed;

  const ConstancyCard({
    super.key,
    required this.playDates,
    required this.streak,
    required this.goal,
    this.showHistory = true,
    this.onPlusHistory,
    this.quests,
    this.atRisk = false,
    this.freezeAvailable = false,
    this.freezeUsed = false,
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
    // Colunas = semanas (segunda→domingo); a última termina nesta semana.
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
    return ProfileSection(
      // Em risco, a moldura acende no tom de alerta da Home.
      accent: widget.atRisk ? AppRoles.risk : AppRoles.streak,
      glyph: CinematicGlyph.flame,
      title: l10n.pilgrimStreak,
      trailing: PrivacyEye(
        sections: const {CaravanProfileSection.presence},
        label: l10n.pilgrimStreak,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreakFlameCalendar(
            showEye: false,
            streak: widget.streak,
            goal: widget.goal,
            atRisk: widget.atRisk,
            freezeAvailable: widget.freezeAvailable,
            freezeUsed: widget.freezeUsed,
          ),
          if (widget.quests case final quests?) ...[
            const SizedBox(height: AppSpace.lg),
            const ListDivider(),
            const SizedBox(height: AppSpace.md),
            quests,
          ],
          if (!widget.showHistory && widget.onPlusHistory != null) ...[
            const SizedBox(height: AppSpace.lg),
            const ListDivider(),
            const SizedBox(height: AppSpace.sm),
            Semantics(
              button: true,
              label: '${l10n.profileWeekHistory} · ${l10n.paywallTitle}',
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ActHaptics.tap();
                  widget.onPlusHistory!();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SectionLabel(l10n.profileWeekHistory),
                          ),
                          const CinematicIcon(
                            glyph: CinematicGlyph.lock,
                            size: AppMetrics.iconSm,
                            accent: AppRoles.reward,
                            framed: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    // A tendência da própria pessoa, desfocada: dá para ver
                    // que existe, não para ler.
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: _WeeksTrend(
                        perWeek: perWeek,
                        walked: walked,
                        weeks: ConstancyCard.weeks,
                        start: start,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      l10n.heroEndPlusCta,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w800,
                        color: AppRoles.reward,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.showHistory) ...[
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
                      Expanded(child: SectionLabel(l10n.profileWeekHistory)),
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
                start: start,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Últimas semanas: uma lamparina por semana, agrupadas pelo mês.
/// O número dentro do frasco é os dias caminhados, de 7.
class _WeeksTrend extends StatefulWidget {
  final List<int> perWeek;
  final int walked;
  final int weeks;

  /// Segunda-feira da primeira coluna.
  final DateTime start;

  const _WeeksTrend({
    required this.perWeek,
    required this.walked,
    required this.weeks,
    required this.start,
  });

  @override
  State<_WeeksTrend> createState() => _WeeksTrendState();
}

class _WeeksTrendState extends State<_WeeksTrend>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWave();
  }

  @override
  void didUpdateWidget(_WeeksTrend oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWave();
  }

  void _syncWave() {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final lit = widget.perWeek.any((days) => days > 0);
    if (lit && !still) {
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

  /// A semana fica no mês da quinta: é o dia que cai na maior parte dela.
  static List<_MonthSpan> _spans(DateTime start, int weeks) {
    final spans = <_MonthSpan>[];
    for (var i = 0; i < weeks; i++) {
      final thursday = start.add(Duration(days: 7 * i + 3));
      final month = DateTime(thursday.year, thursday.month);
      if (spans.isNotEmpty &&
          spans.last.month.year == month.year &&
          spans.last.month.month == month.month) {
        spans.last.count++;
      } else {
        spans.add(_MonthSpan(month, i));
      }
    }
    return spans;
  }

  static String _monthName(DateTime month, String locale) {
    return DateFormat('MMM', locale).format(month).replaceAll('.', '');
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    const maxBar = 48.0;
    const monthGap = 12.0;
    const weekGap = 4.0;
    final spans = _spans(widget.start, widget.perWeek.length);
    return Semantics(
      label: l10n.profileWeeksWalkedSemantics(widget.walked, widget.weeks),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var g = 0; g < spans.length; g++) ...[
                if (g > 0) const SizedBox(width: monthGap),
                Expanded(
                  flex: spans[g].count,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < spans[g].count; i++) ...[
                        if (i > 0) const SizedBox(width: weekGap),
                        Expanded(
                          child: _WeekBar(
                            days: widget.perWeek[spans[g].start + i],
                            height: maxBar,
                            current:
                                spans[g].start + i == widget.perWeek.length - 1,
                            index: spans[g].start + i,
                            wave: _wave,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              for (var g = 0; g < spans.length; g++) ...[
                if (g > 0) const SizedBox(width: monthGap),
                Expanded(
                  flex: spans[g].count,
                  child: Text(
                    _monthName(spans[g].month, l10n.localeName),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: AppTypography.body(
                      size: 12,
                      weight: g == spans.length - 1
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: g == spans.length - 1
                          ? AppRoles.streak
                          : a.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            l10n.profileLampHelp,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w600,
              color: a.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSpan {
  final DateTime month;
  final int start;
  int count;

  _MonthSpan(this.month, this.start) : count = 1;
}

/// Uma semana como jarro de azeite: cada dia caminhado enche um pouco mais
/// — o óleo da unção, a lâmpada que não se apaga (Mt 25:4).
class _WeekBar extends StatelessWidget {
  final int days;
  final double height;
  final bool current;
  final int index;
  final Animation<double> wave;

  const _WeekBar({
    required this.days,
    required this.height,
    required this.current,
    required this.index,
    required this.wave,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final target = days / 7;
    return Column(
      children: [
        // Chama só diz se a semana acendeu. A conta fica no número.
        ClipRect(
          child: days == 0
              ? const SizedBox(height: 22)
              // Camada própria: a chama em loop não repinta o card todo.
              : RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: wave,
                    builder: (context, _) => CustomPaint(
                      size: const Size(double.infinity, 22),
                      painter: _WickFlamePainter(
                        days: days,
                        phase: wave.value * 2 * math.pi + index * 1.3,
                      ),
                    ),
                  ),
                ),
        ),
        // O azeite sobe reto até o dia. O número fica no meio do frasco:
        // escuro quando o azeite cobre o centro, claro quando fica no vidro.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: target),
          duration: Duration(milliseconds: 700 + index * 40),
          curve: AppMotion.enter,
          builder: (context, level, _) {
            final onOil = level >= 0.5;
            return SizedBox(
              height: height,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(double.infinity, height),
                    painter: _OilVesselPainter(
                      level: level,
                      glass: a.text,
                      current: current,
                    ),
                  ),
                  Text(
                    '$days',
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w800,
                      height: 1,
                      color: onOil ? AppRoles.onAction : a.text,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // A seta cabe numa coluna só. "Esta semana" escrito embaixo
        // cobria os três últimos frascos.
        const SizedBox(height: 3),
        SizedBox(
          height: 7,
          child: current
              ? const Center(
                  child: CustomPaint(
                    size: Size(12, 7),
                    painter: _WeekCaretPainter(color: AppRoles.streak),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _OilVesselPainter extends CustomPainter {
  final double level;
  final Color glass;
  final bool current;

  _OilVesselPainter({
    required this.level,
    required this.glass,
    required this.current,
  });

  // Jarro reto: paredes retas, fundo arredondado e aba na boca — o
  // recipiente simples do azeite, sem virar garrafa.
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

    // Vidro visível mesmo na semana vazia — o jarro vazio também é um dado.
    canvas.drawPath(
      vessel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            glass.withValues(alpha: current ? 0.18 : 0.14),
            glass.withValues(alpha: 0.07),
          ],
        ).createShader(Offset.zero & size),
    );

    // Cheio encosta na boca. A borda do azeite é reta para o nível ser óbvio.
    final top = _rim;
    final span = h - top;
    final surface = h - span * level;

    if (level > 0) {
      canvas.save();
      canvas.clipPath(vessel);
      canvas.drawRect(
        Rect.fromLTRB(0, surface, w, h),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFE08A).withValues(alpha: current ? 1 : 0.9),
              AppRoles.streak.withValues(alpha: current ? 1 : 0.9),
              const Color(0xFFB07A00).withValues(alpha: current ? 1 : 0.9),
            ],
            stops: const [0, 0.35, 1],
          ).createShader(Rect.fromLTRB(0, surface, w, h)),
      );
      // A linha do nível não corta o algarismo no meio do frasco.
      final numberBand = 8.0;
      if ((surface - h / 2).abs() >= numberBand) {
        canvas.drawLine(
          Offset(0, surface),
          Offset(w, surface),
          Paint()
            ..color = const Color(0xFFFFF4C8).withValues(alpha: 0.95)
            ..strokeWidth = 1.5,
        );
      }
      canvas.restore();
    }

    // Reflexo vertical na parede.
    canvas.drawLine(
      Offset(w * 0.26, h * 0.28),
      Offset(w * 0.26, h * 0.78),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );

    // Aba da boca: o sétimo dia, o jarro cheio.
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, w, _rim, const Radius.circular(2)),
      Paint()
        ..color = (current ? AppRoles.streak : glass).withValues(
          alpha: current ? 0.9 : 0.45,
        ),
    );

    canvas.drawPath(
      vessel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = current ? 1.6 : 1.1
        ..color = (current ? AppRoles.streak : glass).withValues(
          alpha: current ? 0.85 : 0.4,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _OilVesselPainter old) =>
      old.level != level || old.glass != glass || old.current != current;
}

/// Seta para cima, na largura de um frasco: marca só a semana atual.
class _WeekCaretPainter extends CustomPainter {
  final Color color;

  const _WeekCaretPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WeekCaretPainter old) => old.color != color;
}

/// Chama sobre o jarro: apagada (semana vazia), acesa (houve caminhada)
/// ou alta na semana inteira. A quantidade de dias está no número.
class _WickFlamePainter extends CustomPainter {
  final int days;
  final double phase;

  _WickFlamePainter({required this.days, required this.phase});

  double get _tier => switch (days) {
    <= 0 => 0,
    < 7 => 0.62,
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
