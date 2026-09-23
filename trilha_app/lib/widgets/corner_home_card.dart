import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/corner_challenge.dart';
import '../models/portrait_style.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Convite de esquina na Home — duelo aceso, ouro no escuro.
class CornerHomeCard extends StatelessWidget {
  final CornerChallenge challenge;
  final VoidCallback? onWalk;

  const CornerHomeCard({
    super.key,
    required this.challenge,
    this.onWalk,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<BackendService>().uid ?? '';
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final incoming = challenge.status == CornerStatus.pending &&
        challenge.iAmOpponent(uid);
    final waiting = challenge.status == CornerStatus.pending &&
        challenge.iAmChallenger(uid);
    final canWalk = challenge.status == CornerStatus.active &&
        !challenge.iDone(uid) &&
        onWalk != null;
    final settled = challenge.bothDone ||
        challenge.status == CornerStatus.settled ||
        (!challenge.isThisWeek && !incoming && !waiting);

    final myName = progress.userName;
    final theirName = challenge.peerName(uid);
    final days = LeagueService.daysLeft();
    final when = days <= 1 ? 'Fecha hoje' : '$days dias';

    final whisper = incoming
        ? CornerCopy.incomingFrom(theirName)
        : waiting
            ? CornerCopy.waitingOn(theirName)
            : settled
                ? challenge.subline(uid)
                : 'Com ${CornerCopy.firstName(theirName)} · $when';

    final ctaLabel = incoming
        ? CornerCopy.accept
        : canWalk
            ? CornerCopy.walk
            : null;

    void primary() {
      HapticFeedback.mediumImpact();
      if (incoming) {
        context.read<CornerService>().accept(challenge.id);
      } else if (canWalk) {
        onWalk?.call();
      }
    }

    final radius = AppMetrics.cardRadius;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            ...AppMetrics.cardShadow(elevated: true, hardLip: false),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: ctaLabel == null ? null : primary,
            borderRadius: BorderRadius.circular(radius),
            splashColor: AppColors.accent.withValues(alpha: 0.08),
            highlightColor: AppColors.accent.withValues(alpha: 0.05),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(AppColors.night, AppColors.accentDark, 0.28)!,
                    AppColors.night,
                    AppColors.night,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.72),
                  width: 1.35,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius - 1.35),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 8,
                      height: 132,
                      child: _DuelBloom(),
                    ),
                    const Positioned(
                      left: 36,
                      right: 36,
                      top: 0,
                      child: _GoldFilament(),
                    ),
                    Padding(
                      padding: AppMetrics.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                CornerCopy.kicker.toUpperCase(),
                                style: AppTypography.label(
                                  size: 11,
                                  letterSpacing: 1.8,
                                  color: AppColors.accent,
                                ),
                              ),
                              const Spacer(),
                              if (incoming)
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context
                                        .read<CornerService>()
                                        .decline(challenge.id);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: CinematicIcon(
                                      glyph: CinematicGlyph.close,
                                      size: 16,
                                      accent: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      framed: false,
                                    ),
                                  ),
                                )
                              else
                                const _RewardChip(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DuelRow(
                            myName: myName,
                            theirName: theirName,
                            myPhoto: backend.userPhotoUrl,
                            mySeed: backend.uid,
                            portrait: progress.settings.portraitStyle,
                            incoming: incoming,
                          ),
                          const SizedBox(height: 16),
                          if (incoming) ...[
                            Text(
                              CornerCopy.incomingTitle.toUpperCase(),
                              style: AppTypography.label(
                                size: 10,
                                letterSpacing: 1.4,
                                color: AppColors.accent.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            challenge.missionTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            whisper,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 13,
                              height: 1.35,
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                          if (ctaLabel != null) ...[
                            const SizedBox(height: 16),
                            CopperCta(
                              label: ctaLabel,
                              leading: incoming
                                  ? CinematicGlyph.check
                                  : CinematicGlyph.path,
                              trailing: null,
                              dense: true,
                              onTap: primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '+$cornerArrivalBonusSteps',
        style: AppTypography.label(
          size: 11,
          letterSpacing: 0.4,
          color: AppColors.inkOnAccent,
        ),
      ),
    );
  }
}

class _GoldFilament extends StatelessWidget {
  const _GoldFilament();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0, 0.18, 0.5, 0.82, 1],
        ),
      ),
    );
  }
}

class _DuelBloom extends StatelessWidget {
  const _DuelBloom();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, 0.15),
            radius: 0.72,
            colors: [
              AppColors.accent.withValues(alpha: 0.34),
              AppColors.accent.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }
}

class _DuelRow extends StatelessWidget {
  final String myName;
  final String theirName;
  final String? myPhoto;
  final String? mySeed;
  final PortraitStyle portrait;
  final bool incoming;

  const _DuelRow({
    required this.myName,
    required this.theirName,
    required this.myPhoto,
    required this.mySeed,
    required this.portrait,
    required this.incoming,
  });

  @override
  Widget build(BuildContext context) {
    final leftName = incoming ? theirName : myName;
    final rightName = incoming ? myName : theirName;
    final leftPhoto = incoming ? null : myPhoto;
    final rightPhoto = incoming ? myPhoto : null;
    final leftSeed = incoming ? theirName : mySeed;
    final rightSeed = incoming ? mySeed : theirName;

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                left: 62,
                right: 62,
                child: _GoldFilament(),
              ),
              Row(
                children: [
                  UserAvatar(
                    name: leftName,
                    photoUrl: leftPhoto,
                    seed: leftSeed,
                    radius: 28,
                    style: portrait,
                    borderColor: AppColors.accent,
                  ),
                  const Spacer(),
                  const _VersusMark(),
                  const Spacer(),
                  UserAvatar(
                    name: rightName,
                    photoUrl: rightPhoto,
                    seed: rightSeed,
                    radius: 28,
                    style: portrait,
                    borderColor: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _FighterName(name: leftName),
            const Spacer(),
            _FighterName(name: rightName, alignEnd: true),
          ],
        ),
      ],
    );
  }
}

class _FighterName extends StatelessWidget {
  final String name;
  final bool alignEnd;

  const _FighterName({required this.name, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final first = CornerCopy.firstName(name);
    return SizedBox(
      width: 96,
      child: Text(
        first.isEmpty ? '—' : first,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: AppTypography.label(
          size: 12,
          letterSpacing: 0.3,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _VersusMark extends StatefulWidget {
  const _VersusMark();

  @override
  State<_VersusMark> createState() => _VersusMarkState();
}

class _VersusMarkState extends State<_VersusMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              AppColors.night,
              AppColors.accent,
              0.16 + 0.1 * t,
            ),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.72 + 0.28 * t),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.22 + 0.38 * t),
                blurRadius: 10 + 10 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CustomPaint(painter: _CrossedSwordsPainter()),
        ),
      ),
    );
  }
}

class _CrossedSwordsPainter extends CustomPainter {
  const _CrossedSwordsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blade = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    void sword(Offset hilt, Offset tip, Offset guardA, Offset guardB) {
      canvas.drawLine(hilt, tip, blade);
      canvas.drawLine(guardA, guardB, blade);
      canvas.drawCircle(hilt, 1.35, fill);
    }

    sword(
      Offset(size.width * 0.22, size.height * 0.78),
      Offset(size.width * 0.78, size.height * 0.18),
      Offset(size.width * 0.12, size.height * 0.62),
      Offset(size.width * 0.38, size.height * 0.78),
    );
    sword(
      Offset(size.width * 0.78, size.height * 0.78),
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.62, size.height * 0.78),
      Offset(size.width * 0.88, size.height * 0.62),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
