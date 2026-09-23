import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'ui_primitives.dart';

/// Lista quem reconheceu o quê — Home (depois de Recebi) e Perfil.
Future<void> showRecognitionHistorySheet(BuildContext context) async {
  final service = context.read<RecognitionService>();
  unawaited(service.refreshRecent());
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RecognitionHistorySheet(),
  );
}

class _RecognitionHistorySheet extends StatelessWidget {
  const _RecognitionHistorySheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final service = context.watch<RecognitionService>();
    final items = service.recent;
    final loading = service.recentLoading && items.isEmpty;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      decoration: BoxDecoration(
        color: a.cardFill,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: a.cardBorder.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: a.textMuted(0.28),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quem reconheceu',
                  style: AppTypography.title(size: 20, color: a.text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cena do dia e medalhas que outros viram em você.',
                  style: AppTypography.body(
                    size: 14,
                    color: a.textMuted(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ainda ninguém reconheceu sua caminhada.\nNa caravana, outros podem tocar no coração.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 15,
                          height: 1.4,
                          color: a.textMuted(0.72),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: AppColors.clay,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.historyLine,
                                  style: AppTypography.body(
                                    size: 15,
                                    weight: FontWeight.w700,
                                    height: 1.3,
                                    color: a.text,
                                  ),
                                ),
                                if (_whenLine(item.createdAt) != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _whenLine(item.createdAt)!,
                                    style: AppTypography.label(
                                      size: 11,
                                      color: a.textMuted(0.55),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottom),
            child: CopperCta(
              label: 'Fechar',
              dense: true,
              leading: null,
              trailing: null,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  static String? _whenLine(DateTime? at) {
    if (at == null) return null;
    final now = DateTime.now();
    final local = at.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    if (diff < 7) return 'Há $diff dias';
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    return '$dd/$mm/${local.year}';
  }
}
