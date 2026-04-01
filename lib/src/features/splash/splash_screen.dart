import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    _barAnim = CurvedAnimation(parent: _barController, curve: Curves.easeInOut);

    _navTimer = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inTest = const bool.fromEnvironment('FLUTTER_TEST');

    Widget maybeAnimate(Widget w, Widget Function(Widget w) chain) {
      if (inTest) return w;
      return chain(w);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const MeshBackground(
            orb1Color: Color(0x8C7B5BFF),
            orb2Color: Color(0x5900C896),
            orb1Pos: Alignment(0.6, -0.5),
            orb2Pos: Alignment(-0.6, 0.8),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                maybeAnimate(
                  Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppGradients.brandDiagonal,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                  (w) => w
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),
                ),

                const SizedBox(height: 28),

                maybeAnimate(
                  const AppWordmark(size: 36),
                  (w) => w
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 300.ms,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                ),

                const SizedBox(height: 8),

                maybeAnimate(
                  Text(
                  'CMU-AFRICA · BRIDGE PROGRAM',
                  style: AppTextStyles.outfit(
                    11,
                    AppColors.textMuted,
                    weight: FontWeight.w500,
                  ).copyWith(letterSpacing: 1.5),
                ),
                  (w) => w.animate().fadeIn(delay: 500.ms, duration: 500.ms),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: maybeAnimate(
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _barAnim,
                    builder: (_, __) => Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _barAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.brand,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              (w) => w.animate().fadeIn(delay: 600.ms),
            ),
          ),

          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: maybeAnimate(
              Text(
                'Powered by CMU-Africa',
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(10, AppColors.textHint),
              ),
              (w) => w.animate().fadeIn(delay: 700.ms),
            ),
          ),
        ],
      ),
    );
  }
}
