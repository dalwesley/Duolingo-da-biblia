import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/trilha_mascot.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _confirmReset = false;
  bool _nameInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final sync = context.watch<SyncService>();
    final a = Appearance.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    if (!_nameInitialized) {
      _nameController.text = progress.userName;
      _nameInitialized = true;
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 76, 20, scrollPaddingBelowNav(context)),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.hero,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: AppTheme.glow(AppColors.primary, blur: 16),
          ),
          child: Row(
            children: [
              const TrilhaMascotBadge(size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seu perfil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                    Text(progress.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _miniStat(Icons.auto_awesome_rounded, '${progress.xp} XP'),
                        const SizedBox(width: 10),
                        _miniStat(Icons.local_fire_department_rounded, '${progress.streak} dias'),
                        const SizedBox(width: 10),
                        _miniStat(Icons.flag_rounded, '${progress.completedMissions.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _section('PERFIL', a),
        _glassCard(
          a,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seu nome', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: a.textMuted(0.85))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      maxLength: 24,
                      style: TextStyle(color: a.text, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: a.cardFillSoft,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => progress.setUserName(_nameController.text),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: const Color(0xFF3D2E00)),
                    child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _section('META DIÁRIA', a),
        Row(
          children: [1, 2, 3].map((goal) {
            final selected = progress.settings.dailyGoal == goal;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: goal < 3 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => progress.updateSettings(progress.settings.copyWith(dailyGoal: goal)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent.withValues(alpha: 0.18) : a.cardFillSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? AppColors.accent : a.cardBorder, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$goal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: selected ? AppColors.accent : a.text,
                          ),
                        ),
                        Text(
                          'missão${goal > 1 ? 'ões' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? AppColors.accent : a.textMuted(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _section('APARÊNCIA', a),
        _themePicker(progress, a),
        const SizedBox(height: 24),
        _section('PREFERÊNCIAS', a),
        _toggle(a, 'Sons', 'Efeitos sonoros nas lições', progress.settings.sound, (v) {
          progress.updateSettings(progress.settings.copyWith(sound: v));
          SoundService.instance.setEnabled(v);
        }),
        const SizedBox(height: 8),
        _toggle(a, 'Notificações', 'Lembrete diário às 19h', progress.settings.notifications, (v) async {
          await progress.updateSettings(progress.settings.copyWith(notifications: v));
          await NotificationService.instance.scheduleDailyReminder(enabled: v);
        }),
        const SizedBox(height: 24),
        _section('CONTA E BACKUP', a),
        _glassCard(
          a,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID do dispositivo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: a.textMuted(0.85))),
              const SizedBox(height: 6),
              Text(sync.deviceId ?? '...', style: TextStyle(fontSize: 11, color: a.textMuted(0.9))),
              if (sync.lastSyncAt != null) ...[
                const SizedBox(height: 4),
                Text('Último backup: ${sync.lastSyncAt!.toLocal()}', style: TextStyle(fontSize: 10, color: a.textMuted(0.75))),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportProgress(progress, sync),
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Exportar'),
                      style: OutlinedButton.styleFrom(foregroundColor: a.text, side: BorderSide(color: a.cardBorder)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _importProgress(progress, sync),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Importar'),
                      style: OutlinedButton.styleFrom(foregroundColor: a.text, side: BorderSide(color: a.cardBorder)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _section('SOBRE', a),
        _glassCard(
          a,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trilha', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: a.text)),
              const SizedBox(height: 4),
              Text('Aprenda a Bíblia em missões curtas e gamificadas.', style: TextStyle(color: a.textMuted(0.9))),
              const SizedBox(height: 8),
              Text('Versão 1.0.0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: a.textMuted(0.75))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _section('ZONA DE PERIGO', a, color: AppColors.error),
        if (!_confirmReset)
          OutlinedButton(
            onPressed: () => setState(() => _confirmReset = true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Resetar progresso', style: TextStyle(fontWeight: FontWeight.w800)),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                const Text('Tem certeza? Todo XP, streak e missões serão apagados.', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => setState(() => _confirmReset = false), child: const Text('Cancelar'))),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton(onPressed: () { progress.resetProgress(); setState(() => _confirmReset = false); }, style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Confirmar'))),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _themePicker(ProgressService progress, AppearanceStyle a) {
    final selected = progress.settings.appearanceMode;
    return _glassCard(
      a,
      child: Column(
        children: AppearanceMode.values.map((mode) {
          final isSelected = selected == mode;
          return Padding(
            padding: EdgeInsets.only(bottom: mode == AppearanceMode.automatic ? 0 : 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => progress.updateSettings(progress.settings.copyWith(appearanceMode: mode)),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent.withValues(alpha: 0.16) : a.cardFillSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : a.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? AppColors.accent.withValues(alpha: 0.22) : a.cardFillSoft,
                        ),
                        child: Icon(
                          mode.icon,
                          color: isSelected
                              ? (a.onDark ? AppColors.accent : AppColors.accentDark)
                              : a.textMuted(0.9),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? (a.onDark ? AppColors.accent : AppColors.accentDark)
                                    : a.text,
                              ),
                            ),
                            Text(mode.description, style: TextStyle(fontSize: 12, color: a.textMuted(0.85))),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: a.onDark ? AppColors.accent : AppColors.accentDark,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _exportProgress(ProgressService progress, SyncService sync) async {
    final json = sync.exportJson(
      xp: progress.xp,
      streak: progress.streak,
      lastPlayedDate: progress.lastPlayedDate,
      completedMissions: progress.completedMissions,
      missionsToday: progress.missionsToday,
      userName: progress.userName,
    );
    await Share.share(json, subject: 'Backup Trilha');
    await sync.markSynced();
  }

  Future<void> _importProgress(ProgressService progress, SyncService sync) async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cole o backup na área de transferência primeiro')));
      return;
    }
    final parsed = sync.parseImport(text);
    if (parsed == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup inválido')));
      return;
    }
    await progress.importProgress(
      xp: parsed.xp,
      streak: parsed.streak,
      lastPlayedDate: parsed.lastPlayedDate,
      completedMissions: parsed.completedMissions,
      missionsToday: parsed.missionsToday,
      userName: parsed.userName,
    );
    await sync.markSynced();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progresso restaurado!')));
  }

  Widget _section(String text, AppearanceStyle a, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: color ?? a.sectionLabel)),
    );
  }

  Widget _glassCard(AppearanceStyle a, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        color: a.cardGradient == null ? a.cardFill : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: a.cardBorder),
      ),
      child: child,
    );
  }

  Widget _toggle(AppearanceStyle a, String label, String desc, bool value, ValueChanged<bool> onChanged) {
    return _glassCard(
      a,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: a.text)),
                Text(desc, style: TextStyle(fontSize: 12, color: a.textMuted(0.85))),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.accent, activeTrackColor: AppColors.accent.withValues(alpha: 0.4)),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.accent),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.75))),
      ],
    );
  }
}
