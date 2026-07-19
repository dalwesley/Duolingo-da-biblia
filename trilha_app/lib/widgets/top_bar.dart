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

/// Passos + dias caminhando — presente em toda app bar.
class TopBarStats extends StatelessWidget {
  final int steps;
  final int streak;

  const TopBarStats({
    super.key,
    required this.steps,
    required this.streak,
  });

  factory TopBarStats.of(BuildContext context) {
    final progress = context.watch<ProgressService>();
    return TopBarStats(steps: progress.steps, streak: progress.streak);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StepsBadge(value: steps),
        const SizedBox(width: 8),
        StreakBadge(value: streak),
      ],
    );
  }
}

class StepsBadge extends StatelessWidget {
  final int value;

  const StepsBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

class StreakBadge extends StatelessWidget {
  final int value;

  const StreakBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.streak.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

/// Altura do chrome inline (sem AppBar — evita espaço morto).
const double kTopBarInlineHeight = 48;

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool immersive;
  final bool dark;
  final bool inline;

  /// Saudação em cima + nome em destaque (home).
  final bool personalGreeting;

  /// Foto do usuário (home) — toque abre o perfil.
  final String? photoUrl;
  final VoidCallback? onProfileTap;
  final CinematicGlyph leadingGlyph;
  final IconData? leadingIcon;

  /// Mantido para compatibilidade com telas que ainda passam o controlador,
  /// mas a TopBar agora é sempre sólida.
  final ValueListenable<double>? frost;

  /// Mantido para compatibilidade; sem efeito com a barra sólida.
  final double frostFloor;

  /// Quando false, esconde passos/dias.
  final bool showStats;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.immersive = false,
    this.dark = false,
    this.inline = false,
    this.personalGreeting = false,
    this.photoUrl,
    this.onProfileTap,
    this.leadingGlyph = CinematicGlyph.spark,
    this.leadingIcon,
    this.frost,
    this.frostFloor = 0,
    this.showStats = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    inline ? kTopBarInlineHeight : 56,
  );

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final appearance = Appearance.of(context);
    final onDark = immersive || dark || onBack != null;
    final showAvatar = personalGreeting && onProfileTap != null;

    if (inline) {
      return _InlineChrome(
        appearance: appearance,
        onDark: onDark,
        title: title,
        subtitle: subtitle,
        personalGreeting: personalGreeting,
        showAvatar: showAvatar,
        photoUrl: photoUrl,
        userName: progress.userName,
        onProfileTap: onProfileTap,
        onBack: onBack,
        leadingGlyph: leadingGlyph,
        leadingIcon: leadingIcon,
        showStats: showStats,
        steps: progress.steps,
        streak: progress.streak,
      );
    }

    return AppBar(
      primary: true,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      backgroundColor: appearance.navBarFill.withValues(alpha: 1),
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
      leadingWidth: 56,
      leading: onBack != null
          ? IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              visualDensity: VisualDensity.compact,
              icon: const _BackGlyph(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Center(
                child: _MenuMark(glyph: leadingGlyph, icon: leadingIcon),
              ),
            ),
      title: _TitleBlock(
        title: title,
        subtitle: subtitle,
        personalGreeting: personalGreeting,
        onDark: onDark,
      ),
      actions: showStats
          ? [
              TopBarStats(steps: progress.steps, streak: progress.streak),
              const SizedBox(width: 8),
            ]
          : onBack != null
          ? [
              _MenuMark(glyph: leadingGlyph, icon: leadingIcon),
              const SizedBox(width: 4),
            ]
          : null,
    );
  }
}

class _InlineChrome extends StatelessWidget {
  final AppearanceStyle appearance;
  final bool onDark;
  final String title;
  final String? subtitle;
  final bool personalGreeting;
  final bool showAvatar;
  final String? photoUrl;
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBack;
  final CinematicGlyph leadingGlyph;
  final IconData? leadingIcon;
  final bool showStats;
  final int steps;
  final int streak;

  const _InlineChrome({
    required this.appearance,
    required this.onDark,
    required this.title,
    required this.subtitle,
    required this.personalGreeting,
    required this.showAvatar,
    required this.photoUrl,
    required this.userName,
    required this.onProfileTap,
    required this.onBack,
    required this.leadingGlyph,
    required this.leadingIcon,
    required this.showStats,
    required this.steps,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        height: kTopBarInlineHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: appearance.navBarFill.withValues(alpha: 1),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: appearance.navBarBorder),
        ),
        child: Row(
          children: [
            if (onBack != null) ...[
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: const _BackGlyph(),
              ),
              const SizedBox(width: 8),
            ] else if (showAvatar) ...[
              UserAvatar(
                photoUrl: photoUrl,
                name: userName,
                radius: 16,
                onTap: onProfileTap,
              ),
              const SizedBox(width: 10),
            ] else ...[
              _MenuMark(glyph: leadingGlyph, icon: leadingIcon),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: _TitleBlock(
                title: title,
                subtitle: subtitle,
                personalGreeting: personalGreeting,
                onDark: onDark,
              ),
            ),
            if (showStats) ...[
              const SizedBox(width: 8),
              TopBarStats(steps: steps, streak: streak),
            ] else if (onBack != null) ...[
              const SizedBox(width: 8),
              _MenuMark(glyph: leadingGlyph, icon: leadingIcon),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackGlyph extends StatelessWidget {
  const _BackGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

/// Ícone da seção atual — mesmo glifo e traço do menu inferior.
class _MenuMark extends StatelessWidget {
  final CinematicGlyph glyph;
  final IconData? icon;

  const _MenuMark({
    this.glyph = CinematicGlyph.spark,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    final child = icon != null
        ? Icon(icon, size: size * 0.48, color: AppColors.accent)
        : CinematicIcon(
            glyph: glyph,
            size: size * 0.55,
            accent: AppColors.accent,
            framed: false,
            glowing: false,
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.14),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Medalhão circular — mesmo visual do [CinematicIcon] framed.
class _FramedMark extends StatelessWidget {
  final double size;
  final Widget child;

  const _FramedMark({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.accent;
    final rim = Color.lerp(color, Colors.white, 0.45)!;
    final deep = Color.lerp(color, const Color(0xFF0A0E0C), 0.8)!;
    final mid = Color.lerp(color, const Color(0xFF1A221E), 0.5)!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.15,
          colors: [mid, deep],
        ),
        border: Border.all(
          color: rim.withValues(alpha: 0.65),
          width: size * 0.032,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.04),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool personalGreeting;
  final bool onDark;

  const _TitleBlock({
    required this.title,
    required this.subtitle,
    required this.personalGreeting,
    required this.onDark,
  });

  @override
  Widget build(BuildContext context) {
    if (personalGreeting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                height: 1.1,
              ),
            ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: onDark ? Colors.white : AppColors.text,
            height: 1.15,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.1,
              color: onDark
                  ? Colors.white.withValues(alpha: 0.55)
                  : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
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
