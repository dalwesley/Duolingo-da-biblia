import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cloud_mascot.dart';
import 'user_avatar.dart';

/// Quem entrou na Caminhada: uma bolinha (o retrato do perfil) por
/// peregrino, espalhadas sem se tocar e flutuando devagar. O próprio
/// peregrino fica no meio, maior e com anel da estação.
///
/// Sem ninguém, Anan convida a ser o primeiro.
class SeasonWalkCrowd extends StatefulWidget {
  final List<SeasonWalker> walkers;

  /// O próprio peregrino, quando já entrou.
  final SeasonWalker? self;
  final String? selfPhotoUrl;
  final Color accent;

  /// Quantos entraram ao todo (pulso). A lista vem limitada; o "+N" conta
  /// também quem não foi carregado.
  final int? total;

  /// Toque numa bolinha (perfil) e no "+N" (lista de todos).
  final void Function(SeasonWalker walker, bool isSelf)? onOpen;
  final VoidCallback? onMore;

  const SeasonWalkCrowd({
    super.key,
    required this.walkers,
    required this.accent,
    this.self,
    this.selfPhotoUrl,
    this.total,
    this.onOpen,
    this.onMore,
  });

  @override
  State<SeasonWalkCrowd> createState() => _SeasonWalkCrowdState();
}

class _Seat {
  final Offset center;
  final double radius;
  final double phase;

  const _Seat(this.center, this.radius, this.phase);
}

class _SeasonWalkCrowdState extends State<SeasonWalkCrowd>
    with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.reduced(context);
    final tickersOn = TickerMode.valuesOf(context).enabled;
    if (reduced) {
      _float.stop();
      _enter.value = 1;
    } else {
      if (tickersOn && !_float.isAnimating) _float.repeat();
      if (_enter.value == 0) _enter.forward();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _enter.dispose();
    super.dispose();
  }

  /// Lugares sem sobreposição; quem não couber vira o "+N".
  /// Semente fixa pela lista: a mesma turma cai no mesmo desenho.
  static List<_Seat> _seats(Size size, int count, bool withSelf, int seed) {
    final rng = Random(seed);
    final seats = <_Seat>[];
    const gap = 6.0;
    const edge = 4.0;
    for (var i = 0; i < count; i++) {
      final isSelf = withSelf && i == 0;
      final r = isSelf ? 30.0 : 16.0 + rng.nextDouble() * 10;
      if (size.width < r * 2 + edge * 2 || size.height < r * 2 + edge * 2) {
        break;
      }
      _Seat? seat;
      for (var t = 0; t < 60 && seat == null; t++) {
        final c = isSelf && t == 0
            ? Offset(size.width / 2, size.height / 2)
            : Offset(
                r + edge + rng.nextDouble() * (size.width - 2 * (r + edge)),
                r + edge + rng.nextDouble() * (size.height - 2 * (r + edge)),
              );
        final free = seats.every(
          (s) => (s.center - c).distance >= s.radius + r + gap,
        );
        if (free) seat = _Seat(c, r, rng.nextDouble() * 2 * pi);
      }
      if (seat == null) break;
      seats.add(seat);
    }
    return seats;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final self = widget.self;
    final people = [?self, ...widget.walkers];

    if (people.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CloudMascot(face: CloudFace.feliz, size: 64),
            const SizedBox(height: AppSpace.sm),
            Text(
              l10n.walkCrowdEmpty,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.4,
                color: a.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      container: true,
      label: l10n.walkTogetherWalkers(max(widget.total ?? 0, people.length)),
      child: LayoutBuilder(
        builder: (context, box) {
          final size = Size(box.maxWidth, box.maxHeight);
          final seed = Object.hashAll(people.map((p) => p.uid));
          final seats = _seats(size, people.length, self != null, seed);
          final everyone = max(widget.total ?? 0, people.length);
          final hidden = everyone - seats.length;
          // Sem lugar para todos: a última bolinha vira "+N".
          final overflow = hidden > 0 && seats.isNotEmpty;
          final shown = overflow ? seats.length - 1 : seats.length;
          final faces = [
            for (var i = 0; i < shown; i++)
              _tappable(
                label: identical(people[i], self)
                    ? l10n.commonYou
                    : people[i].name,
                onTap: widget.onOpen == null
                    ? null
                    : () =>
                          widget.onOpen!(people[i], identical(people[i], self)),
                child: _face(
                  people[i],
                  seats[i].radius,
                  identical(people[i], self),
                ),
              ),
            if (overflow)
              _tappable(
                label: l10n.walkTogetherWalkers(everyone),
                onTap: widget.onMore,
                child: _More(
                  count: hidden + 1,
                  radius: seats.last.radius,
                  accent: widget.accent,
                ),
              ),
          ];
          return AnimatedBuilder(
            animation: Listenable.merge([_float, _enter]),
            builder: (context, _) {
              final t = _float.value * 2 * pi;
              final n = faces.length;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < n; i++)
                    _place(seats[i], faces[i], t, i, n),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _face(SeasonWalker w, double radius, bool isSelf) {
    final avatar = UserAvatar(
      name: w.name,
      seed: w.uid,
      radius: radius,
      style: w.portraitStyle,
      photoUrl: isSelf ? widget.selfPhotoUrl : null,
      borderColor: isSelf
          ? widget.accent
          : Colors.white.withValues(alpha: 0.22),
    );
    if (!isSelf) return avatar;
    // Você: halo da estação respirando com a flutuação.
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final glow = 0.35 + 0.25 * sin(_float.value * 2 * pi * 2);
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: glow),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: avatar,
    );
  }

  Widget _tappable({
    required String label,
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget _place(_Seat seat, Widget face, double t, int i, int n) {
    final drift = Offset(
      sin(t + seat.phase) * 3,
      cos(t * 0.8 + seat.phase) * 4,
    );
    final start = n <= 1 ? 0.0 : (i / n) * 0.6;
    final pop = Curves.easeOutBack.transform(
      ((_enter.value - start) / 0.4).clamp(0.0, 1.0),
    );
    return Positioned(
      left: seat.center.dx - seat.radius + drift.dx,
      top: seat.center.dy - seat.radius + drift.dy,
      child: Opacity(
        opacity: pop.clamp(0.0, 1.0),
        child: Transform.scale(scale: pop, child: face),
      ),
    );
  }
}

class _More extends StatelessWidget {
  final int count;
  final double radius;
  final Color accent;

  const _More({
    required this.count,
    required this.radius,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.22),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Text(
        '+$count',
        style: AppTypography.body(
          size: radius * 0.6,
          weight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
