import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_language.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/caravan_profile_prefs.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/family_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/guest_gate.dart';
import 'app_sheet.dart';
import 'caravan_pilgrim_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'profile_section.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Texto do motivo que o servidor devolveu (functions/family.js).
String familyErrorMessage(AppLocalizations l10n, String? reason) =>
    switch (reason) {
      'invalid' => l10n.familyErrorInvalid,
      'own' => l10n.familyErrorOwn,
      'full' => l10n.familyErrorFull,
      'other_family' => l10n.familyErrorOther,
      'inactive' => l10n.familyErrorInactive,
      'has_plus' => l10n.familyErrorHasPlus,
      'needs_account' => l10n.familyErrorNeedsAccount,
      _ => l10n.familyErrorFailed,
    };

/// Abriu o link do convite: confere, pergunta e entra. Sem conta, o
/// convite espera o login (o shell chama de novo depois).
Future<void> joinFamilyByCode(BuildContext context, String code) async {
  final l10n = context.l10n;
  final backend = context.read<BackendService>();
  final family = context.read<FamilyService>();
  void track(String result) => unawaited(
    AnalyticsService.instance.logEvent('family_join', {'result': result}),
  );
  Future<void> toast(String message, {bool ok = false}) => showAppToastFor(
    context,
    message: message,
    glyph: ok ? CinematicGlyph.people : CinematicGlyph.wrong,
    tone: ok ? AppToastTone.accent : AppToastTone.warn,
  );

  if (!backend.isActive || GuestGate.isGuest(context)) {
    InviteDeepLinkService.instance.holdFamilyCode(code);
    track('needs_account');
    return toast(l10n.familyErrorNeedsAccount);
  }
  final peek = await family.peek(code);
  if (!context.mounted) return;
  if (peek == null) {
    track('invalid');
    return toast(l10n.familyErrorInvalid);
  }
  if (peek.own) {
    track('own');
    return toast(l10n.familyErrorOwn);
  }
  if (peek.member) {
    track('already');
    return toast(l10n.familyAlreadyIn, ok: true);
  }
  final owner = peek.ownerName.isEmpty ? l10n.familySomeone : peek.ownerName;
  final yes = await showAppConfirm(
    context,
    title: l10n.familyJoinTitle,
    body: l10n.familyJoinBody(owner),
    confirmLabel: l10n.familyJoinCta,
    face: CloudFace.feliz,
  );
  if (!yes || !context.mounted) {
    track('declined');
    return;
  }
  final result = await family.join(code);
  if (!context.mounted) return;
  if (!result.ok) {
    track(result.reason ?? 'failed');
    return toast(familyErrorMessage(l10n, result.reason));
  }
  track('joined');
  // O Plus entra como promocional no RevenueCat: relê o entitlement.
  unawaited(context.read<SubscriptionService>().refreshCustomerInfo());
  await toast(l10n.familyJoinDone(owner), ok: true);
}

/// Semana de uma pessoa da família: dias caminhados e sequência.
class _MemberWeek {
  final Set<String> days;
  final int streak;

  /// Escondeu a presença do perfil: a semana fica guardada.
  final bool hidden;
  final String? photoUrl;
  final PortraitStyle style;

  /// Para abrir a folha do perfil (o resto ela mesma lê).
  final int steps;
  final String? lastWalkDate;
  final String? lastSeenDate;

  const _MemberWeek({
    required this.days,
    required this.streak,
    this.hidden = false,
    this.photoUrl,
    this.style = PortraitStyle.photo,
    this.steps = 0,
    this.lastWalkDate,
    this.lastSeenDate,
  });
}

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Segunda a domingo desta semana (mesma conta do [StreakWeek]).
List<DateTime> _thisWeek() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
}

/// Sequência só vale se a última caminhada foi hoje ou ontem.
int _liveStreak(int streak, Iterable<String> days) {
  if (streak <= 0) return 0;
  final now = DateTime.now();
  final today = _ymd(now);
  final yesterday = _ymd(now.subtract(const Duration(days: 1)));
  return days.contains(today) || days.contains(yesterday) ? streak : 0;
}

/// "Minha família" no Perfil: a semana da casa em bolinhas — cada pessoa
/// numa linha, e o dia em que todos caminharam acende a coluna. O titular
/// convida, gera link novo e (em Gerenciar) tira pessoas; o membro sai.
class FamilyPlanCard extends StatefulWidget {
  const FamilyPlanCard({super.key});

  /// Há algo a mostrar: plano no servidor ou compra de família recém-feita.
  static bool visible(FamilyService family, SubscriptionService sub) =>
      family.plan != null || sub.plusIsFamily;

  @override
  State<FamilyPlanCard> createState() => _FamilyPlanCardState();
}

class _FamilyPlanCardState extends State<FamilyPlanCard> {
  /// Perfis públicos já lidos (uid → semana), por 10 minutos.
  static final _cache = <String, (_MemberWeek, DateTime)>{};

  final _weeks = <String, _MemberWeek>{};
  final _loading = <String>{};
  bool _managing = false;

  void _ensureLoaded(Iterable<String> uids) {
    for (final uid in uids) {
      if (_weeks.containsKey(uid) || _loading.contains(uid)) continue;
      final cached = _cache[uid];
      if (cached != null &&
          DateTime.now().difference(cached.$2) < const Duration(minutes: 10)) {
        _weeks[uid] = cached.$1;
        continue;
      }
      _loading.add(uid);
      unawaited(_load(uid));
    }
  }

  Future<void> _load(String uid) async {
    _MemberWeek? week;
    if (kDebugMode && uid.startsWith('lab-')) {
      week = _labWeek(uid);
    } else {
      try {
        final r = await context.read<BackendService>().fetchPilgrimProfile(uid);
        final data = r.data;
        if (data != null) {
          final p = CaravanPilgrimProfile.fromCloudMap(uid: uid, data: data);
          week = _MemberWeek(
            days: p.playDates.toSet(),
            streak: _liveStreak(p.streak, p.playDates),
            hidden: !p.prefs.isVisible(CaravanProfileSection.presence),
            photoUrl: p.photoUrl,
            style: PortraitStyleX.fromStorage(data['portraitStyle'] as String?),
            steps: p.steps,
            lastWalkDate: p.lastWalkDate,
            lastSeenDate: p.lastSeenDate,
          );
        }
      } catch (e) {
        debugPrint('Família: perfil $uid falhou: $e');
      }
    }
    if (!mounted) return;
    setState(() {
      _loading.remove(uid);
      final w = week ?? const _MemberWeek(days: {}, streak: 0);
      _weeks[uid] = w;
      if (week != null) _cache[uid] = (w, DateTime.now());
    });
  }

  /// Semanas de mentira para o laboratório (uid `lab-…`).
  _MemberWeek _labWeek(String uid) {
    final week = _thisWeek();
    final today = DateTime.now().weekday;
    final pattern = switch (uid) {
      'lab-ana' => [1, 2, 3, 4, 5, 6, 7],
      'lab-lucas' => [1, 3, 4],
      'lab-davi' => [2, 3],
      'lab-marta' => [1, 2, 3, 4, 5, 6, 7],
      'lab-pedro' => [1, 3, 5, 7],
      _ => <int>[],
    };
    final days = {
      for (final d in pattern)
        if (d <= today) _ymd(week[d - 1]),
    };
    return _MemberWeek(
      days: days,
      streak: _liveStreak(uid == 'lab-ana' ? 12 : days.length, days),
      hidden: uid == 'lab-davi',
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final family = context.watch<FamilyService>();
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final plan = family.plan;
    final me = backend.uid;

    if (plan == null) {
      // Comprou agora: o webhook ainda vai criar o plano.
      return ProfileSection(
        accent: AppRoles.reward,
        glyph: CinematicGlyph.people,
        title: l10n.familyTitle,
        caption: l10n.familyPreparing,
      );
    }

    final owner = plan.ownerUid == me;
    final ownerName = plan.ownerName.isEmpty
        ? l10n.familySomeone
        : plan.ownerName;
    String nameOf(FamilyMember m) => m.uid == me
        ? progress.publicUserName
        : (m.name.isEmpty ? l10n.familySomeone : m.name);

    // Todos da casa, titular primeiro.
    final people = <({String uid, String name, String? tag, FamilyMember? m})>[
      (
        uid: plan.ownerUid,
        name: owner ? progress.publicUserName : ownerName,
        tag: owner ? l10n.familyOwnerYou : l10n.familyOwnerNamed(ownerName),
        m: null,
      ),
      for (final m in plan.members)
        (
          uid: m.uid,
          name: nameOf(m),
          tag: m.uid == me ? l10n.familyMemberYou : null,
          m: m,
        ),
    ];

    _ensureLoaded([
      for (final p in people)
        if (p.uid != me) p.uid,
    ]);
    final mine = _MemberWeek(
      days: progress.playDates.toSet(),
      streak: _liveStreak(progress.streak, progress.playDates),
      photoUrl: backend.userPhotoUrl,
      style: progress.settings.portraitStyle,
    );
    _MemberWeek? weekOf(String uid) => uid == me ? mine : _weeks[uid];

    final week = _thisWeek();
    final todayIdx = DateTime.now().weekday - 1;
    final keys = [for (final d in week) _ymd(d)];
    // Contam para "juntos" só as semanas que aparecem.
    final shown = [
      for (final p in people)
        if (weekOf(p.uid) case final w? when !w.hidden) (p: p, w: w),
    ];
    final together = <int>{
      if (shown.length > 1)
        for (var i = 0; i <= todayIdx; i++)
          if (shown.every((s) => s.w.days.contains(keys[i]))) i,
    };
    final walks = shown.fold<int>(
      0,
      (n, s) => n + keys.where(s.w.days.contains).length,
    );
    final walkedToday = shown.where((s) => s.w.days.contains(keys[todayIdx]));
    final missing = [
      for (final s in shown)
        if (!s.w.days.contains(keys[todayIdx])) s.p.name.split(' ').first,
    ];

    final caption = !plan.active
        ? l10n.familyPaused
        : owner
        ? l10n.familySeatsLeft(plan.freeSeats)
        : null;

    const cell = 24.0;
    const gridW = cell * 7;

    Widget avatar(String uid, String name, _MemberWeek? w) => UserAvatar(
      name: name,
      seed: uid,
      photoUrl: w?.photoUrl,
      radius: 18,
      style: w?.style ?? PortraitStyle.photo,
      // Anel sempre (mesmo tamanho para todos); azul = caminhou hoje.
      borderColor: (w?.days.contains(keys[todayIdx]) ?? false)
          ? AppRoles.presence
          : a.cardBorder,
    );

    Widget dots(_MemberWeek? w) {
      if (w == null) {
        return const SizedBox(
          width: gridW,
          height: cell,
          child: Center(child: AppSpinner(inline: true)),
        );
      }
      if (w.hidden) {
        return SizedBox(
          width: gridW,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.lock,
                size: 12,
                accent: a.textFaint,
                framed: false,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.familyWalkPrivate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 11, color: a.textFaint),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        width: gridW,
        child: Row(
          children: [
            for (var i = 0; i < 7; i++)
              SizedBox(
                width: cell,
                height: cell,
                child: Center(
                  child: _FamilyDot(
                    walked: w.days.contains(keys[i]),
                    today: i == todayIdx,
                    future: i > todayIdx,
                    together: together.contains(i),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget personRow(
      ({String uid, String name, String? tag, FamilyMember? m}) p,
    ) {
      final w = weekOf(p.uid);
      final streak = w == null || w.hidden ? 0 : w.streak;
      final canRemove = _managing && owner && p.m != null && p.uid != me;
      final row = Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            avatar(p.uid, p.name, w),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w800,
                      color: a.text,
                    ),
                  ),
                  Row(
                    children: [
                      if (streak > 0) ...[
                        const CinematicIcon(
                          glyph: CinematicGlyph.flame,
                          size: 11,
                          accent: AppRoles.streak,
                          framed: false,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Flexible(
                        child: Text(
                          p.tag ??
                              (streak > 0
                                  ? l10n.familyStreak(streak)
                                  : l10n.familyNoStreak),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 11,
                            weight: FontWeight.w700,
                            color: streak > 0 && p.tag == null
                                ? AppRoles.streak
                                : a.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.xs),
            if (canRemove)
              TextCta(
                label: l10n.familyRemove,
                danger: true,
                onTap: family.busy ? null : () => _remove(context, p.m!),
              )
            else
              dots(w),
          ],
        ),
      );
      if (_managing) return row;
      return Semantics(
        button: true,
        label: p.name,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openProfile(p.uid, p.name, w, me: p.uid == me),
          child: row,
        ),
      );
    }

    final narrow = DateFormat(
      'EEEEE',
      Localizations.localeOf(context).toLanguageTag(),
    );
    final header = Row(
      children: [
        const Spacer(),
        SizedBox(
          width: gridW,
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                SizedBox(
                  width: cell,
                  child: Text(
                    narrow.format(week[i]).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0.4,
                      color: together.contains(i)
                          ? AppRoles.reward
                          : i == todayIdx
                          ? a.text
                          : a.textFaint,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    // A coluna do dia em família: uma faixa dourada atrás das bolinhas.
    final grid = Stack(
      children: [
        for (final i in together)
          Positioned(
            top: 0,
            bottom: 0,
            right: (6 - i) * cell,
            width: cell,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cell / 2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppRoles.reward.withValues(alpha: 0.28),
                    AppRoles.reward.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(
                  color: AppRoles.reward.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: 2),
            for (final p in people) personRow(p),
          ],
        ),
      ],
    );

    final seats = [
      if (owner)
        for (var i = 0; i < plan.freeSeats; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _EmptySeat(color: a.insetBorder, ink: a.textFaint),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    l10n.familyEmptySeat,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: a.textFaint,
                    ),
                  ),
                ),
                if (plan.active)
                  TextCta(
                    label: l10n.familyInviteShort,
                    color: AppRoles.reward,
                    onTap: () => _share(context, plan),
                  ),
              ],
            ),
          ),
    ];

    final total = shown.length;
    final todayLine = total < 2
        ? null
        : missing.isEmpty
        ? l10n.familyAllWalkedToday
        : l10n.familyMissingToday(missing.join(', '));

    return ProfileSection(
      accent: AppRoles.reward,
      glyph: CinematicGlyph.people,
      title: l10n.familyTitle,
      caption: caption,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InsetPanel(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _FamilyStat(
                  value: '${walkedToday.length}/$total',
                  label: l10n.familyStatToday,
                  tone: AppRoles.presence,
                  lit: walkedToday.isNotEmpty,
                ),
                Container(width: 1, height: 28, color: a.cardBorder),
                _FamilyStat(
                  value: '${together.length}',
                  label: l10n.familyStatTogether,
                  tone: AppRoles.reward,
                  lit: together.isNotEmpty,
                  glyph: CinematicGlyph.crown,
                ),
                Container(width: 1, height: 28, color: a.cardBorder),
                _FamilyStat(
                  value: '$walks',
                  label: l10n.familyStatWalks,
                  tone: AppRoles.streak,
                  lit: walks > 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          grid,
          ...seats,
          if (todayLine != null) ...[
            const SizedBox(height: AppSpace.sm),
            Row(
              children: [
                CinematicIcon(
                  glyph: missing.isEmpty
                      ? CinematicGlyph.crown
                      : CinematicGlyph.sneaker,
                  size: 14,
                  accent: missing.isEmpty ? AppRoles.reward : a.textSecondary,
                  framed: false,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    todayLine,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: missing.isEmpty
                          ? AppRoles.reward
                          : a.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (total > 1 && together.isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.familyTogetherHint,
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          if (owner && plan.active && plan.freeSeats > 0)
            CopperCta(
              label: l10n.familyInvite,
              expanded: true,
              dense: true,
              trailing: null,
              onTap: () => _share(context, plan),
            ),
          if (owner)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (plan.members.isNotEmpty) ...[
                  TextCta(
                    label: _managing
                        ? l10n.familyManageDone
                        : l10n.familyManage,
                    color: a.textSecondary,
                    onTap: () => setState(() => _managing = !_managing),
                  ),
                  Text(
                    ' · ',
                    style: AppTypography.body(size: 12, color: a.textFaint),
                  ),
                ],
                TextCta(
                  label: l10n.familyNewLink,
                  color: a.textSecondary,
                  onTap: family.busy ? null : () => _rotate(context),
                ),
              ],
            ),
          if (!owner)
            GhostCta(
              label: l10n.familyLeave,
              expanded: true,
              onTap: family.busy ? null : () => _leave(context),
            ),
        ],
      ),
    );
  }

  /// Mesma folha da caravana; a própria linha abre "como a caravana te vê".
  void _openProfile(
    String uid,
    String name,
    _MemberWeek? w, {
    required bool me,
  }) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (me) {
      final progress = context.read<ProgressService>();
      final backend = context.read<BackendService>();
      unawaited(
        showCaravanSelfPreviewSheet(
          context,
          rank: 0,
          entry: LeagueEntry(
            uid: uid,
            name: progress.publicUserName,
            steps: progress.steps,
            isUser: true,
            portraitStyle: progress.settings.portraitStyle,
            lastWalkDate: progress.lastPlayedDate,
            lastSeenDate: today,
            photoUrl: backend.userPhotoUrl,
          ),
        ),
      );
      return;
    }
    unawaited(
      showCaravanPilgrimSheet(
        context,
        rank: 0,
        entry: LeagueEntry(
          uid: uid,
          name: name,
          steps: w?.steps ?? 0,
          portraitStyle: w?.style ?? PortraitStyle.photo,
          lastWalkDate: w?.lastWalkDate,
          lastSeenDate: w?.lastSeenDate,
          photoUrl: w?.photoUrl,
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, FamilyPlan plan) async {
    final l10n = context.l10n;
    final name = context.read<ProgressService>().publicUserName;
    final link = InviteDeepLinkService.familyHttpsUrl(plan.inviteCode);
    unawaited(
      AnalyticsService.instance.logEvent('family_invite', {
        'free': plan.freeSeats,
      }),
    );
    await SharePlus.instance.share(
      ShareParams(text: l10n.familyInviteMessage(name, link)),
    );
  }

  Future<void> _rotate(BuildContext context) async {
    final l10n = context.l10n;
    final r = await context.read<FamilyService>().rotateCode();
    if (!context.mounted) return;
    await showAppToastFor(
      context,
      message: r.ok
          ? l10n.familyNewLinkDone
          : familyErrorMessage(l10n, r.reason),
      glyph: r.ok ? CinematicGlyph.link : CinematicGlyph.wrong,
      tone: r.ok ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  Future<void> _remove(BuildContext context, FamilyMember m) async {
    final l10n = context.l10n;
    final name = m.name.isEmpty ? l10n.familySomeone : m.name;
    final yes = await showAppConfirm(
      context,
      title: l10n.familyRemove,
      body: l10n.familyRemoveConfirm(name),
      confirmLabel: l10n.familyRemove,
      danger: true,
    );
    if (!yes || !context.mounted) return;
    final r = await context.read<FamilyService>().remove(m.uid);
    if (!context.mounted) return;
    await showAppToastFor(
      context,
      message: r.ok
          ? l10n.familyRemoved(name)
          : familyErrorMessage(l10n, r.reason),
      glyph: r.ok ? CinematicGlyph.check : CinematicGlyph.wrong,
      tone: r.ok ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  Future<void> _leave(BuildContext context) async {
    final l10n = context.l10n;
    final yes = await showAppConfirm(
      context,
      title: l10n.familyLeave,
      body: l10n.familyLeaveConfirm,
      confirmLabel: l10n.familyLeave,
      danger: true,
    );
    if (!yes || !context.mounted) return;
    // Lido antes: ao sair, o plano some do Firestore e o card é desmontado
    // antes da resposta — sem isto o Plus promocional seguia na tela.
    final sub = context.read<SubscriptionService>();
    final r = await context.read<FamilyService>().leave();
    if (r.ok) unawaited(sub.refreshCustomerInfo());
    if (!context.mounted) return;
    await showAppToastFor(
      context,
      message: r.ok ? l10n.familyLeft : familyErrorMessage(l10n, r.reason),
      glyph: r.ok ? CinematicGlyph.check : CinematicGlyph.wrong,
      tone: r.ok ? AppToastTone.accent : AppToastTone.warn,
    );
  }
}

class _FamilyDot extends StatelessWidget {
  final bool walked;
  final bool today;
  final bool future;
  final bool together;

  const _FamilyDot({
    required this.walked,
    required this.today,
    required this.future,
    required this.together,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Caminhou: bolinha cheia. Faltou: anel vazio. Ainda não chegou:
    // ponto apagado. Hoje leva o anel de seleção.
    final fill = walked
        ? (together ? AppRoles.reward : AppRoles.presence)
        : future && !today
        ? a.textFaint.withValues(alpha: 0.35)
        : Colors.transparent;
    final size = walked
        ? 16.0
        : future && !today
        ? 6.0
        : 14.0;
    return AnimatedContainer(
      duration: AppMotion.quick,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: future && !today
            ? null
            : Border.all(
                color: today
                    ? a.selected
                    : walked
                    ? fill
                    : a.textFaint.withValues(alpha: 0.6),
                width: today ? 2 : 1.2,
              ),
        boxShadow: walked
            ? [BoxShadow(color: fill.withValues(alpha: 0.45), blurRadius: 6)]
            : null,
      ),
    );
  }
}

class _FamilyStat extends StatelessWidget {
  final String value;
  final String label;
  final Color tone;
  final bool lit;
  final CinematicGlyph? glyph;

  const _FamilyStat({
    required this.value,
    required this.label,
    required this.tone,
    required this.lit,
    this.glyph,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (glyph != null && lit) ...[
                CinematicIcon(
                  glyph: glyph!,
                  size: 14,
                  accent: tone,
                  framed: false,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: AppTypography.title(
                  size: 20,
                  weight: FontWeight.w900,
                  color: lit ? tone : a.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.6,
              color: a.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySeat extends StatelessWidget {
  final Color color;
  final Color ink;

  const _EmptySeat({required this.color, required this.ink});

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 1.5),
    ),
    alignment: Alignment.center,
    child: CinematicIcon(
      glyph: CinematicGlyph.plus,
      size: 16,
      accent: ink,
      framed: false,
    ),
  );
}
