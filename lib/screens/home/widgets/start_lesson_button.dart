import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/cyber_colors.dart';

class StartLessonButton extends StatefulWidget {
  final VoidCallback onPressed;

  const StartLessonButton({super.key, required this.onPressed});

  @override
  State<StartLessonButton> createState() => _StartLessonButtonState();
}

class _StartLessonButtonState extends State<StartLessonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowController = AnimationController(
      vsync: this,
      duration: AppMotion.breathingGlow,
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.45).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceAnimations(context)) {
      _glowController.stop();
      _glowController.value = 0.35;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;
    final reduce = AppMotion.reduceAnimations(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnim, _glowAnim]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    CyberColors.ctaStart,
                    CyberColors.ctaEnd,
                    CyberColors.ctaStart,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF2ECC71,
                    ).withValues(alpha: reduce ? 0.35 : _glowAnim.value),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: palette.onAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Mulai Belajar",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: palette.onAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
