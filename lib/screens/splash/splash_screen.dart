import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/cyber_colors.dart';
import '../../widgets/grid_painter.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/auth_gate.dart';
import '../../services/account_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Auto navigate after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AccountService.configured && AccountService.auth.currentUser != null
                    ? const AuthGate()
                    : const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle grid
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(
                color: CyberColors.primary.withValues(
                  alpha: 0.04 *
                      (palette.brightness == Brightness.dark ? 2.4 : 1.0),
                ),
              ),
              size: Size.infinite,
            ),
          ),

          // Central Logo
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CyberColors.primary.withValues(alpha: 0.15),
                                CyberColors.secondary.withValues(alpha: 0.1),
                              ],
                            ),
                            border: Border.all(color: CyberColors.primary.withValues(alpha: 0.6), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.primary.withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            color: CyberColors.primaryLight,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "SecuriGo",
                          style: GoogleFonts.nunito(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Learn Security, Stay Safe",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: palette.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          Positioned(
            bottom: 80,
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      backgroundColor: palette.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(CyberColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Memuat Modul Belajar...",
                  style: GoogleFonts.nunito(
                    color: palette.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
