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
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Convite de esquina na Home — painel social, não poster de missão.
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: GlassCard(
        elevated: true,
        tint: AppColors.accent,
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
                      context.read<CornerService>().decline(challenge.id);
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
            const SizedBox(height: 14),
            _DuelRow(
              myName: myName,
              theirName: theirName,
              myPhoto: backend.userPhotoUrl,
              mySeed: backend.uid,
              portrait: progress.settings.portraitStyle,
              incoming: incoming,
            ),
            const SizedBox(height: 14),
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
              style: AppTypography.title(size: 18, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              whisper,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 13,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 14),
              OutlineCta(
                label: ctaLabel,
                leading: incoming
                    ? CinematicGlyph.check
                    : CinematicGlyph.path,
                onTap: primary,
              ),
            ],
          ],
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
