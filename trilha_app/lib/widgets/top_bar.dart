import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'user_avatar.dart';

class FrostController extends ValueNotifier<double> {
  FrostController() : super(0);

  bool _handle(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical) {
      value = n.metrics.pixels;
    }
    return false;
  }

  Widget attach(Widget child) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handle,
      child: child,
    );
  }
}

/// Fornece um [FrostController] com ciclo de vida proprio para telas sem estado.
class FrostScope extends StatefulWidget {
  final Widget Function(BuildContext context, FrostController frost) builder;

  const FrostScope({super.key, required this.builder});

  @override
  State<FrostScope> createState() => _FrostScopeState();
}

class _FrostScopeState extends State<FrostScope> {
  final _frost = FrostController();

  @override
  void dispose() {
    _frost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _frost);
}

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool immersive;
  final bool dark;
  /// Saudação em cima + nome em destaque (home).
  final bool personalGreeting;
  /// Foto do usuário (home) — toque abre o perfil.
  final String? photoUrl;
  final VoidCallback? onProfileTap;
  /// Mantido para compatibilidade com telas que ainda passam o controlador,
  /// mas a TopBar agora é sempre sólida.
  final ValueListenable<double>? frost;
  /// Mantido para compatibilidade; sem efeito com a barra sólida.
  final double frostFloor;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.immersive = false,
    this.dark = false,
    this.personalGreeting = false,
    this.photoUrl,
    this.onProfileTap,
    this.frost,
    this.frostFloor = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final appearance = Appearance.of(context);
    final onDark = immersive || dark || onBack != null;
    final showAvatar = personalGreeting && onProfileTap != null;

    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: appearance.navBarFill.withValues(alpha: 1),
      flexibleSpace: null,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      scrolledUnderElevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.xl),
        ),
        side: BorderSide(color: appearance.navBarBorder),
      ),
      leadingWidth: showAvatar ? 64 : null,
      leading: onBack != null
          ? IconButton(
              onPressed: onBack,
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            )
          : showAvatar
              ? Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Center(
                    child: UserAvatar(
                      photoUrl: photoUrl,
                      name: progress.userName,
                      radius: 20,
                      onTap: onProfileTap,
                    ),
                  ),
                )
              : immersive
                  ? null
                  : const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Center(
                        child: CinematicIcon(
                          glyph: CinematicGlyph.spark,
                          size: 40,
                          accent: AppColors.primaryLight,
                          glowing: false,
                        ),
                      ),
                    ),
      title: personalGreeting
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: onDark ? Colors.white : AppColors.text,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: onDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
      actions: [
        _StepsBadge(value: progress.steps),
        const SizedBox(width: 8),
        _WalkDaysBadge(value: progress.streak),
        const SizedBox(width: 14),
      ],
    );
  }
}

class _StepsBadge extends StatelessWidget {
  final int value;

  const _StepsBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_walk_rounded,
            size: 14,
            color: AppColors.inkOnAccent,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.inkOnAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkDaysBadge extends StatelessWidget {
  final int value;

  const _WalkDaysBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.streak.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_rounded,
            size: 14,
            color: AppColors.streak,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fundo da app bar que vai de transparente (topo) a fosco (rolagem).
class FrostedBar extends StatelessWidget {
  final ValueListenable<double> frost;
  final bool dark;
  /// Intensidade mínima do fosco (0 = totalmente transparente no topo).
  final double floor;

  const FrostedBar({
    super.key,
    required this.frost,
    this.dark = true,
    this.floor = 0,
  });

  @override
  Widget build(BuildContext context) {
    final base = dark ? AppColors.night : AppColors.card;
    final line = dark ? Colors.white : Colors.black;
    final floorT = floor.clamp(0.0, 1.0);
    return ValueListenableBuilder<double>(
      valueListenable: frost,
      builder: (context, offset, _) {
        final t = ((offset / 56).clamp(0.0, 1.0)).clamp(floorT, 1.0);
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18 * t, sigmaY: 18 * t),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: base.withValues(alpha: 0.78 * t),
                border: Border(
                  bottom: BorderSide(
                    color: line.withValues(alpha: 0.1 * t),
                    width: 0.6,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
