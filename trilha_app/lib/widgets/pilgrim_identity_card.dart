import 'package:flutter/material.dart';

import '../models/recognition.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'pilgrim_profile_sections.dart';
import 'recognition_actions.dart';
import 'relic_panel.dart';
import 'streak_week.dart';
import 'user_avatar.dart';

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
  });

  bool get _showPrecision =>
      showAccuracy && accuracyPercent != null && accuracyTotal > 0;

  String? get _whisper {
    final parts = <String>[];
    if (showRank && rank > 0) {
      parts.add(rank <= 3 ? pilgrimRankEpithet(rank) : '$rankº na caravana');
    }
    if (showLeaderDays && leaderDays > 0) {
      parts.add(
        leaderDays == 1 ? '1 dia no topo' : '$leaderDays dias no topo',
      );
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
    final displayName = name.trim().isEmpty ? 'Peregrino' : name.trim();
    final whisper = _whisper;
    final rankTone = showRank && rank > 0 && rank <= 3;

    final stats = <Widget>[];
    void push(Widget child) {
      if (stats.isNotEmpty) stats.add(_IdentityRule(a: a));
      stats.add(Expanded(child: child));
    }

    if (showSteps) {
      push(
        _IdentityStat(
          value: pilgrimFormatCount(steps),
          label: 'Passos',
        ),
      );
    }
    if (showMissions) {
      push(
        _IdentityStat(
          value: pilgrimFormatCount(missions),
          label: 'Cenas',
        ),
      );
    }
    if (_showPrecision) {
      push(
        PilgrimPrecisionArc(
          percent: accuracyPercent!,
          correct: accuracyCorrect,
          total: accuracyTotal,
          stat: true,
        ),
      );
    }

    return RelicPanel(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(
                name: displayName,
                photoUrl: photoUrl,
                seed: seed,
                style: style,
                radius: 40,
                borderColor: AppColors.accent.withValues(alpha: 0.85),
                editable: editable,
                onTap: editable ? onEditPortrait : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.display(
                              size: 24,
                              weight: FontWeight.w800,
                              color: a.text,
                              height: 1.05,
                            ),
                          ),
                        ),
                        if (recognizeWalkToUid != null &&
                            recognizeWalkDate != null)
                          RecognizeHeartButton(
                            toUid: recognizeWalkToUid,
                            kind: RecognitionKind.walk,
                            subjectKey: recognizeWalkDate!,
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                    if (whisper != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        whisper,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.3,
                          color: rankTone
                              ? pilgrimRankAccent(rank)
                              : a.textMuted(0.62),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 18),
            const RelicHairline(),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stats,
            ),
          ],
          if (showWeek) ...[
            const SizedBox(height: 16),
            const RelicHairline(),
            const SizedBox(height: 12),
            StreakWeek(orbSize: 30, playedOnDate: playedOnDate),
          ],
        ],
      ),
    );
  }
}

class _IdentityStat extends StatelessWidget {
  final String value;
  final String label;

  const _IdentityStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.title(
                  size: 20,
                  weight: FontWeight.w900,
                  color: a.text,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: AppTypography.label(
            size: 9,
            letterSpacing: 1.2,
            color: a.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

class _IdentityRule extends StatelessWidget {
  final AppearanceStyle a;

  const _IdentityRule({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: a.cardBorder.withValues(alpha: 0.85),
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
