import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../cinematic/cinematic_resolver.dart';
import '../models/corner_challenge.dart';
import '../models/portrait_style.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'cinematic_backdrop.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Poster do desafio na Home — mesma família do card de continuar.
class CornerHomeCard extends StatefulWidget {
  final CornerChallenge challenge;
  final VoidCallback? onWalk;

  const CornerHomeCard({
    super.key,
    required this.challenge,
    this.onWalk,
  });

  @override
  State<CornerHomeCard> createState() => _CornerHomeCardState();
}

class _CornerHomeCardState extends State<CornerHomeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final uid = context.watch<BackendService>().uid ?? '';
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final incoming = challenge.status == CornerStatus.pending &&
        challenge.iAmOpponent(uid);
    final waiting = challenge.status == CornerStatus.pending &&
        challenge.iAmChallenger(uid);
    final canWalk = challenge.status == CornerStatus.active &&
        !challenge.iDone(uid) &&
        widget.onWalk != null;
    final settled = challenge.bothDone ||
        challenge.status == CornerStatus.settled ||
        (!challenge.isThisWeek && !incoming && !waiting);

    final myName = progress.userName;
    final theirName = challenge.peerName(uid);
    final days = LeagueService.daysLeft();
    final when = days <= 1 ? 'Fecha hoje' : '$days dias';
    final world = CinematicResolver.ambientForHome(
      trailSlug: challenge.trailSlug,
      missionTitle: challenge.missionTitle,
      missionSlug: challenge.missionSlug,
    );

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
        widget.onWalk?.call();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: GestureDetector(
        onTapDown: ctaLabel == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: ctaLabel == null
            ? null
            : (_) {
                setState(() => _pressed = false);
                if (!incoming) primary();
              },
        child: AnimatedScale(
          scale: _pressed ? 0.986 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.42),
                width: 1.5,
              ),
              boxShadow: AppMetrics.cardShadow(elevated: true),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius - 1.5),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CinematicBackdrop(world: world),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x33070B14),
                            Color(0x99070B14),
                            Color(0xF2070B14),
                          ],
                          stops: [0, 0.42, 1],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
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
                                    accent: Colors.white.withValues(alpha: 0.4),
                                    framed: false,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '+$cornerArrivalBonusSteps',
                                style: AppTypography.label(
                                  size: 11,
                                  letterSpacing: 0.6,
                                  color: AppColors.accent,
                                ),
                              ),
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
                        const SizedBox(height: 18),
                        if (incoming) ...[
                          Text(
                            CornerCopy.incomingTitle.toUpperCase(),
                            style: AppTypography.label(
                              size: 11,
                              letterSpacing: 1.4,
                              color: AppColors.accent.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          'CENA',
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 1.8,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          challenge.missionTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.display(
                            size: 28,
                            height: 1.08,
                            weight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          whisper,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 13,
                            height: 1.35,
                            weight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                        if (ctaLabel != null) ...[
                          const SizedBox(height: 18),
                          _GoldBar(
                            label: ctaLabel,
                            onTap: incoming ? primary : null,
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              incoming
                                  ? '+$cornerArrivalBonusSteps na caravana · $when'
                                  : '+$cornerArrivalBonusSteps na caravana se você fizer',
                              style: AppTypography.body(
                                size: 13,
                                weight: FontWeight.w800,
                                color: AppColors.accent.withValues(alpha: 0.88),
                              ),
                            ),
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

    return Row(
      children: [
        _Fighter(
          name: leftName,
          photoUrl: leftPhoto,
          seed: leftSeed,
          style: portrait,
          gold: incoming,
        ),
        Expanded(
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.night.withValues(alpha: 0.55),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.55),
                ),
              ),
              child: const Center(child: _VersusMark()),
            ),
          ),
        ),
        _Fighter(
          name: rightName,
          photoUrl: rightPhoto,
          seed: rightSeed,
          style: portrait,
          gold: !incoming,
          alignEnd: true,
        ),
      ],
    );
  }
}

class _Fighter extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;
  final bool gold;
  final bool alignEnd;

  const _Fighter({
    required this.name,
    required this.photoUrl,
    required this.seed,
    required this.style,
    required this.gold,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final first = CornerCopy.firstName(name);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        UserAvatar(
          name: name,
          photoUrl: photoUrl,
          seed: seed,
          radius: 26,
          style: style,
          borderColor: gold
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.28),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 88,
          child: Text(
            first.isEmpty ? '—' : first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.6,
              color: gold
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _VersusMark extends StatelessWidget {
  const _VersusMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _CrossedSwordsPainter()),
    );
  }
}

class _CrossedSwordsPainter extends CustomPainter {
  const _CrossedSwordsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blade = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 1.7
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

class _GoldBar extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _GoldBar({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: AppTypography.cta(size: 15),
      ),
    );
    if (onTap == null) return bar;
    return GestureDetector(
      onTap: onTap,
      child: bar,
    );
  }
}
