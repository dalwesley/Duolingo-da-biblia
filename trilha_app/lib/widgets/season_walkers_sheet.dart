import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../screens/me_screen.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/moderation_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/season_walk_debug.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'caravan_pilgrim_sheet.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Peregrinos falsos do Laboratório ([SeasonWalkDebug.crowd]).
List<SeasonWalker> fakeSeasonWalkers(int count) {
  const names = ['Ana', 'Bruno', 'Clara', 'Davi', 'Ester', 'Filipe'];
  return [
    for (var i = 0; i < count; i++)
      SeasonWalker(
        uid: 'lab-$i',
        name: '${names[i % names.length]} $i',
        portraitStyle: i.isEven ? PortraitStyle.avatar : PortraitStyle.letter,
      ),
  ];
}

/// Toque numa bolinha ou linha: o próprio perfil, ou a vitrine do outro.
void openSeasonWalker(
  BuildContext context,
  SeasonWalker walker, {
  required bool isSelf,
}) {
  ActHaptics.tap();
  if (isSelf) {
    openMeProfile(context);
    return;
  }
  showCaravanPilgrimSheet(
    context,
    entry: LeagueEntry(
      uid: walker.uid,
      name: walker.name,
      steps: 0,
      portraitStyle: walker.portraitStyle,
    ),
    rank: 0,
  );
}

/// Todos que entraram na Caminhada, em páginas de 40 (rola e carrega mais).
Future<void> showSeasonWalkersSheet(
  BuildContext context, {
  required String campaignId,
  required int total,
  required Color accent,
  SeasonWalker? self,
  String? selfPhotoUrl,
}) {
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
    builder: (_) => _SeasonWalkersSheet(
      campaignId: campaignId,
      total: total,
      accent: accent,
      self: self,
      selfPhotoUrl: selfPhotoUrl,
    ),
  );
}

class _SeasonWalkersSheet extends StatefulWidget {
  final String campaignId;
  final int total;
  final Color accent;
  final SeasonWalker? self;
  final String? selfPhotoUrl;

  const _SeasonWalkersSheet({
    required this.campaignId,
    required this.total,
    required this.accent,
    this.self,
    this.selfPhotoUrl,
  });

  @override
  State<_SeasonWalkersSheet> createState() => _SeasonWalkersSheetState();
}

class _SeasonWalkersSheetState extends State<_SeasonWalkersSheet> {
  static const _page = 40;

  final List<SeasonWalker> _walkers = [];
  bool _loading = false;
  bool _done = false;

  /// Último doc da página crua — não o da lista sem repetidos.
  Object? _cursor;

  @override
  void initState() {
    super.initState();
    _more();
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    final fake = SeasonWalkDebug.crowd;
    if (fake != null) {
      setState(() {
        _walkers.addAll(fakeSeasonWalkers(fake));
        _done = true;
      });
      return;
    }
    setState(() => _loading = true);
    final backend = context.read<BackendService>();
    final page = await backend.fetchSeasonWalkers(
      widget.campaignId,
      limit: _page,
      after: _cursor,
    );
    if (!mounted) return;
    // Página por updatedAt: quem caminhou entre uma página e outra sobe e
    // voltaria repetido.
    final seen = {for (final w in _walkers) w.uid};
    setState(() {
      _walkers.addAll(page.where((w) => seen.add(w.uid)));
      if (page.isNotEmpty) _cursor = page.last.cursor;
      _loading = false;
      _done = page.length < _page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final moderation = context.watch<ModerationService>();
    final self = widget.self;
    final others = [
      for (final w in _walkers)
        if (w.uid != self?.uid && !moderation.isBlocked(w.uid)) w,
    ];
    final rows = [?self, ...others];
    final height = MediaQuery.sizeOf(context).height * 0.62;

    return AppSheetPanel(
      tint: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            cloud: false,
            title: l10n.walkTogetherWalkers(widget.total),
            subtitle: l10n.walkCrowdListSubtitle,
          ),
          const SizedBox(height: AppSpace.md),
          SizedBox(
            height: height,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 300) _more();
                return false;
              },
              child: ListView.builder(
                itemCount: rows.length + (_loading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i >= rows.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpace.md),
                      child: Center(
                        child: SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final w = rows[i];
                  final isSelf = identical(w, self);
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    onTap: () => openSeasonWalker(context, w, isSelf: isSelf),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          UserAvatar(
                            name: w.name,
                            seed: w.uid,
                            radius: AppMetrics.avatarMd,
                            style: w.portraitStyle,
                            photoUrl: isSelf ? widget.selfPhotoUrl : null,
                            borderColor: isSelf ? widget.accent : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSelf ? l10n.commonYou : w.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title(
                                size: 15,
                                color: a.text,
                              ),
                            ),
                          ),
                          ListChevron(color: a.textSecondary),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
