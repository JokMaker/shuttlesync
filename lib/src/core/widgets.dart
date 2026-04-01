import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme.dart';

/// ── Background mesh (reused on every screen) ────────────────────────────────
class MeshBackground extends StatelessWidget {
  final Color orb1Color;
  final Color orb2Color;
  final Alignment orb1Pos;
  final Alignment orb2Pos;

  const MeshBackground({
    super.key,
    this.orb1Color = const Color(0x8C7B5BFF),
    this.orb2Color = const Color(0x5900C896),
    this.orb1Pos = const Alignment(0.7, -0.7),
    this.orb2Pos = const Alignment(-0.8, 0.9),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.bg),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: orb1Pos,
                radius: 1.1,
                colors: [orb1Color, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: orb2Pos,
                radius: 1.0,
                colors: [orb2Color, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ── Glass card ─────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.gradient,
    this.borderColor = AppColors.glassBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.glassWhite : null,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// ── Gradient text ──────────────────────────────────────────────────────────
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppGradients.brand,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

/// ── Live badge ─────────────────────────────────────────────────────────────
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusOnTimeBg,
        border: Border.all(color: AppColors.statusOnTimeBorder),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeOut(duration: 800.ms),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: AppTextStyles.outfit(10, AppColors.teal, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// ── Wordmark ───────────────────────────────────────────────────────────────
class AppWordmark extends StatelessWidget {
  final double size;
  const AppWordmark({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Shuttle', style: AppTextStyles.outfitBlack(size, Colors.white)),
        GradientText(
          'Sync',
          style: AppTextStyles.outfitBlack(size, Colors.white),
          gradient: AppGradients.brand,
        ),
      ],
    );
  }
}

/// ── Bottom nav ─────────────────────────────────────────────────────────────
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.bar_chart_rounded, 'Home'),
      (Icons.my_location_rounded, 'Track'),
      (Icons.place_rounded, 'Stops'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i].$1,
                  size: 22,
                  color: active ? AppColors.teal : AppColors.textMuted,
                ),
                const SizedBox(height: 3),
                Text(
                  items[i].$2,
                  style: AppTextStyles.outfit(
                    9,
                    active ? AppColors.teal : AppColors.textMuted,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ── Glass icon button ──────────────────────────────────────────────────────
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          border: Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(size / 2.5),
        ),
        child: Icon(icon, size: size * 0.44, color: AppColors.textSecondary),
      ),
    );
  }
}
