import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/corner_challenge.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'corner_withdraw.dart';
import 'corner_burst.dart';
import 'crossing_burst.dart';
import 'immersive_background.dart';
import 'juntos_chrome.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Desafio — duas pessoas, a mesma cena, a bandeira no meio.
///
/// Lê-se de cima para baixo: quem atravessa com quem (e quem já chegou), a cena,
/// quanto tempo resta na semana e a única ação que importa agora.
class CornerHomeCard extends StatelessWidget {
  final CornerChallenge challenge;
  final VoidCallback? onWalk;

  const CornerHomeCard({super.key, required this.challenge, this.onWalk});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final uid = context.watch<BackendService>().uid ?? '';
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final incoming =
        challenge.status == CornerStatus.pending && challenge.iAmOpponent(uid);
    final waiting =
        challenge.status == CornerStatus.pending &&
        challenge.iAmChallenger(uid);
    final canWalk = challenge.opensFor(uid, challenge.missionSlug) &&
        onWalk != null;
    final settled =
        challenge.isClosed || (!challenge.isThisWeek && !incoming && !waiting);
    final live = challenge.status == CornerStatus.active;

    final myName = progress.userName;
    final theirName = challenge.peerName(uid);
    final days = LeagueService.daysLeft();
    final when = days <= 1 ? CornerCopy.closesToday : CornerCopy.daysLeft(days);

    final whisper = incoming
        ? CornerCopy.incomingFrom(theirName)
        : waiting
        ? CornerCopy.waitingOn(theirName)
        : settled ||
              challenge.iDone(uid) ||
              challenge.theyDone(uid) ||
              challenge.theyLeft(uid)
        ? challenge.subline(uid)
        : CornerCopy.withPeer(theirName);

    final hasCta = incoming || canWalk;
    final acceptBlocked =
        incoming && context.watch<CornerService>().isBusy(except: challenge.id);
    final canWithdraw = !settled && challenge.canWithdraw(uid);

    void primary() => onWalk?.call();

    Future<void> accept() async {
      final corners = context.read<CornerService>();
      await showCornerBurst(
        context,
        peerName: theirName,
        peerPhoto: challenge.peerPhoto(uid),
        caption: CornerCopy.burstAccepted,
        kicker: challenge.missionTitle,
      );
      await corners.accept(challenge.id);
    }

    void decline() => context.read<CornerService>().decline(challenge.id);

    final meDone = live || settled ? challenge.iDone(uid) : false;
    final themDone = live || settled ? challenge.theyDone(uid) : false;
    final meLeft = challenge.iLeft(uid);
    final themLeft = challenge.theyLeft(uid);

    return GlassCard(
      glow: hasCta ? 0.9 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.flag,
                size: 14,
                accent: AppColors.accent,
                framed: false,
              ),
              const SizedBox(width: 6),
              SectionLabel(
                incoming ? CornerCopy.incomingTitle : CornerCopy.kicker,
                color: AppColors.accent,
              ),
              const Spacer(),
              const _RewardChip(),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _PairRow(
            myName: myName,
            theirName: theirName,
            myPhoto: backend.userPhotoUrl,
            theirPhoto: challenge.peerPhoto(uid),
            mySeed: backend.uid,
            portrait: progress.settings.portraitStyle,
            incoming: incoming,
            meDone: meDone,
            themDone: themDone,
            meLeft: meLeft,
            themLeft: themLeft,
            showStatus: live || settled,
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            challenge.missionTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(size: 24, color: a.text),
          ),
          const SizedBox(height: 4),
          Text(
            whisper,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
          if (!settled) ...[
            const SizedBox(height: AppSpace.md),
            _WeekFuse(daysLeft: days, label: when),
          ],
          if (incoming) ...[
            const SizedBox(height: AppSpace.lg),
            HoldToConfirmCta(
              label: CornerCopy.holdAccept,
              leading: CinematicGlyph.check,
              onConfirm: acceptBlocked ? null : accept,
            ),
            if (acceptBlocked) ...[
              const SizedBox(height: 6),
              Text(
                CornerCopy.busyAccept,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 12, color: a.textSecondary),
              ),
            ],
          ] else if (canWalk) ...[
            const SizedBox(height: AppSpace.lg),
            CopperCta(
              label: CornerCopy.walk,
              leading: CinematicGlyph.path,
              trailing: null,
              dense: true,
              onTap: primary,
            ),
          ],
          if (incoming) ...[
            const SizedBox(height: AppSpace.xs),
            Center(
              child: TextCta(label: CornerCopy.decline, onTap: decline),
            ),
          ] else if (canWithdraw) ...[
            SizedBox(height: hasCta ? AppSpace.xs : AppSpace.md),
            Center(
              child: TextCta(
                label: CornerCopy.withdraw,
                danger: true,
                onTap: () => confirmCornerWithdraw(
                  context,
                  challenge: challenge,
                  myUid: uid,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pavio da semana: um traço por dia, os que restam acesos.
class _WeekFuse extends StatelessWidget {
  final int daysLeft;
  final String label;

  const _WeekFuse({required this.daysLeft, required this.label});

  @override
  Widget build(BuildContext context) {
    final urgent = daysLeft <= 1;
    final tone = urgent ? AppColors.streak : AppColors.accent;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.hair),
                      color: i >= 7 - daysLeft
                          ? tone
                          : Colors.white.withValues(alpha: 0.1),
                      boxShadow: i >= 7 - daysLeft
                          ? [
                              BoxShadow(
                                color: tone.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpace.md),
        Text(
          label,
          style: AppTypography.label(size: 11, letterSpacing: 0.4, color: tone),
        ),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip();

  @override
  Widget build(BuildContext context) {
    return const SoftBadge(text: CornerCopy.reward, solid: true);
  }
}

/// Os dois lado a lado, o fio entre eles e a bandeira de chegada no meio.
class _PairRow extends StatelessWidget {
  final String myName;
  final String theirName;
  final String? myPhoto;
  final String? theirPhoto;
  final String? mySeed;
  final PortraitStyle portrait;
  final bool incoming;
  final bool meDone;
  final bool themDone;
  final bool meLeft;
  final bool themLeft;
  final bool showStatus;

  const _PairRow({
    required this.myName,
    required this.theirName,
    required this.myPhoto,
    required this.theirPhoto,
    required this.mySeed,
    required this.portrait,
    required this.incoming,
    required this.meDone,
    required this.themDone,
    required this.meLeft,
    required this.themLeft,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context) {
    final leftName = incoming ? theirName : myName;
    final rightName = incoming ? myName : theirName;
    final leftPhoto = incoming ? theirPhoto : myPhoto;
    final rightPhoto = incoming ? myPhoto : theirPhoto;
    final leftSeed = incoming ? theirName : mySeed;
    final rightSeed = incoming ? mySeed : theirName;
    final leftDone = incoming ? themDone : meDone;
    final rightDone = incoming ? meDone : themDone;
    final leftLeft = incoming ? themLeft : meLeft;
    final rightLeft = incoming ? meLeft : themLeft;

    final bond = leftDone && rightDone
        ? BondState.both
        : leftDone
        ? BondState.left
        : rightDone
        ? BondState.right
        : BondState.none;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Walker(
          name: leftName,
          photo: leftPhoto,
          seed: leftSeed,
          portrait: portrait,
          done: leftDone,
          left: leftLeft,
          showStatus: showStatus,
        ),
        Expanded(
          child: SizedBox(
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Center(child: BondThread(state: bond)),
                ),
                _FinishMark(lit: leftDone && rightDone),
              ],
            ),
          ),
        ),
        _Walker(
          name: rightName,
          photo: rightPhoto,
          seed: rightSeed,
          portrait: portrait,
          done: rightDone,
          left: rightLeft,
          showStatus: showStatus,
        ),
      ],
    );
  }
}

class _Walker extends StatelessWidget {
  final String name;
  final String? photo;
  final String? seed;
  final PortraitStyle portrait;
  final bool done;
  final bool left;
  final bool showStatus;

  const _Walker({
    required this.name,
    required this.photo,
    required this.seed,
    required this.portrait,
    required this.done,
    required this.left,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final first = CornerCopy.firstName(name);
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          JuntosHalo(
            size: 56,
            lit: done,
            child: UserAvatar(
              name: name,
              photoUrl: photo,
              seed: seed,
              radius: 28,
              style: portrait,
              borderColor: done
                  ? AppColors.accent
                  : AppColors.accent.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            first.isEmpty ? '—' : first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 12,
              letterSpacing: 0.3,
              color: a.text,
            ),
          ),
          if (showStatus) ...[
            const SizedBox(height: 2),
            Text(
              done
                  ? CornerCopy.arrivedMark
                  : left
                  ? CornerCopy.leftMark
                  : CornerCopy.onTheWay,
              style: AppTypography.label(
                size: 10,
                letterSpacing: 0.3,
                weight: FontWeight.w700,
                color: done ? AppColors.accent : a.textFaint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bandeira de chegada no meio do fio. Acende inteira quando os dois chegam.
class _FinishMark extends StatefulWidget {
  final bool lit;

  const _FinishMark({required this.lit});

  @override
  State<_FinishMark> createState() => _FinishMarkState();
}

class _FinishMarkState extends State<_FinishMark>
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
    final boost = widget.lit ? 1.0 : 0.0;
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
              0.16 + 0.1 * t + 0.2 * boost,
            ),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.72 + 0.28 * t),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(
                  alpha: 0.22 + 0.38 * t + 0.2 * boost,
                ),
                blurRadius: 10 + 10 * t,
              ),
            ],
          ),
          child: CustomPaint(painter: _FinishFlagPainter(wave: _pulse.value)),
        );
      },
    );
  }
}

class _FinishFlagPainter extends CustomPainter {
  final double wave;

  const _FinishFlagPainter({required this.wave});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = Offset(w * 0.38, h * 0.76);
    final top = Offset(w * 0.38, h * 0.24);
    canvas.drawLine(
      base,
      top,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final fw = w * 0.3;
    final fh = h * 0.2;
    final bend = (wave - 0.5) * 2.4;
    final cloth = Path()
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(top.dx + fw / 2, top.dy - bend, top.dx + fw, top.dy)
      ..lineTo(top.dx + fw, top.dy + fh)
      ..quadraticBezierTo(
        top.dx + fw / 2,
        top.dy + fh - bend,
        top.dx,
        top.dy + fh,
      )
      ..close();
    canvas.drawPath(cloth, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant _FinishFlagPainter old) => old.wave != wave;
}
