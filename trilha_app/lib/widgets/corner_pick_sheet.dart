import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/corner_challenge.dart';
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/moderation_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'corner_burst.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Quantos perfis da caravana a lista lê de uma vez (uma leitura cada).
const _maxPeople = 40;

/// Escolher quem desafiar — a caravana inteira, quem está na mesma cena
/// primeiro (com o botão), os outros com o motivo de não dar ainda.
Future<void> showCornerPickSheet(
  BuildContext context, {
  required List<LeagueEntry> people,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => _CornerPickSheet(people: people),
  );
}

class _Candidate {
  final LeagueEntry entry;
  final CornerProposal? proposal;
  final String? reason;

  const _Candidate(this.entry, this.proposal, this.reason);
}

class _CornerPickSheet extends StatefulWidget {
  final List<LeagueEntry> people;

  const _CornerPickSheet({required this.people});

  @override
  State<_CornerPickSheet> createState() => _CornerPickSheetState();
}

class _CornerPickSheetState extends State<_CornerPickSheet> {
  List<_Candidate>? _candidates;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final backend = context.read<BackendService>();
    final progress = context.read<ProgressService>();
    final people = widget.people.take(_maxPeople).toList();
    List<Trail> catalog = const [];
    try {
      catalog = await TrailRepository().getTrails();
    } catch (e) {
      debugPrint('CornerPickSheet: catálogo falhou: $e');
    }
    final candidates = await Future.wait([
      for (final person in people)
        _candidate(person, backend, progress, catalog),
    ]);
    candidates.sort((a, b) {
      final ready = (b.proposal != null ? 1 : 0) - (a.proposal != null ? 1 : 0);
      if (ready != 0) return ready;
      return a.entry.name.toLowerCase().compareTo(b.entry.name.toLowerCase());
    });
    if (!mounted) return;
    setState(() => _candidates = candidates);
  }

  Future<_Candidate> _candidate(
    LeagueEntry person,
    BackendService backend,
    ProgressService progress,
    List<Trail> catalog,
  ) async {
    final uid = person.uid;
    if (uid == null || uid.isEmpty || catalog.isEmpty) {
      return _Candidate(person, null, CornerCopy.noCorner);
    }
    try {
      final result = await backend.fetchPilgrimProfile(uid);
      if (!result.hasDocument) {
        return _Candidate(person, null, CornerCopy.noCorner);
      }
      final profile = CaravanPilgrimProfile.fromCloudMap(
        uid: uid,
        data: result.data!,
        fallbackName: person.name,
        fallbackPhotoUrl: person.photoUrl,
      );
      final proposal = CornerMatch.propose(
        catalog: catalog,
        myCompleted: progress.completedMissions,
        myClearedModes: progress.clearedTrailModes,
        theirCompleted: profile.completedMissions,
        theirClearedModes: profile.clearedTrailModes,
      );
      if (proposal != null) return _Candidate(person, proposal, null);
      final reason = CornerMatch.blockReason(
        catalog: catalog,
        myCompleted: progress.completedMissions,
        myClearedModes: progress.clearedTrailModes,
        theirCompleted: profile.completedMissions,
        theirClearedModes: profile.clearedTrailModes,
      );
      return _Candidate(person, null, reason ?? CornerCopy.noCorner);
    } catch (e) {
      debugPrint('CornerPickSheet: perfil falhou ($uid): $e');
      return _Candidate(person, null, CornerCopy.noCorner);
    }
  }

  Future<void> _challenge(_Candidate c) async {
    final proposal = c.proposal;
    final uid = c.entry.uid;
    if (proposal == null || uid == null || _sending) return;
    setState(() => _sending = true);
    final corners = context.read<CornerService>();
    final progress = context.read<ProgressService>();
    final navigator = Navigator.of(context);
    final host = navigator.overlay?.context;
    navigator.pop();
    if (host == null || !host.mounted) return;
    await showCornerBurst(
      host,
      peerName: c.entry.name,
      peerPhoto: c.entry.photoUrl,
      caption: CornerCopy.burstSent,
      kicker: proposal.missionTitle,
    );
    final created = await corners.propose(
      opponentId: uid,
      opponentName: c.entry.name,
      myName: progress.publicUserName,
      proposal: proposal,
      opponentPhotoUrl: c.entry.photoUrl,
    );
    if (created == null && host.mounted) {
      await showAppToastFor(
        host,
        message: corners.lastError ?? CornerCopy.sendFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moderation = context.watch<ModerationService>();
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    final candidates = [
      for (final c in _candidates ?? const <_Candidate>[])
        if (!moderation.isBlocked(c.entry.uid)) c,
    ];

    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: CornerCopy.pickTitle,
              subtitle: CornerCopy.pickSubtitle,
            ),
            const SizedBox(height: AppSpace.md),
            if (_candidates == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpace.xl),
                child: AppSpinner(),
              )
            else if (candidates.isEmpty)
              EmptyState(title: CornerCopy.pickEmpty)
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final c in candidates)
                      _PickRow(
                        candidate: c,
                        enabled: !_sending,
                        onChallenge: () => _challenge(c),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  final _Candidate candidate;
  final bool enabled;
  final VoidCallback onChallenge;

  const _PickRow({
    required this.candidate,
    required this.enabled,
    required this.onChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final person = candidate.entry;
    final proposal = candidate.proposal;
    final ready = proposal != null;
    final sub = ready
        ? CornerCopy.inviteTitle(proposal.missionTitle)
        : candidate.reason ?? CornerCopy.noCorner;

    return Opacity(
      opacity: ready ? 1 : 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            UserAvatar(
              name: person.name,
              photoUrl: person.photoUrl,
              seed: person.uid ?? person.name,
              radius: AppMetrics.avatarMd,
              style: person.portraitStyle,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 14, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(size: 12, color: a.textSecondary),
                  ),
                ],
              ),
            ),
            if (ready)
              TextCta(
                label: CornerCopy.pickCta,
                color: AppRoles.action,
                onTap: enabled ? onChallenge : null,
              ),
          ],
        ),
      ),
    );
  }
}
