import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/cyber_colors.dart';

/// Glowing Action Button
class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;
  final bool isOutline;
  final IconData? icon;

  const CyberButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.glowColor = CyberColors.primary,
    this.isOutline = false,
    this.icon,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isOutline
                ? null
                : LinearGradient(
                    colors: [
                      widget.glowColor,
                       widget.glowColor.withValues(alpha: 1, red: widget.glowColor.r, green: widget.glowColor.g, blue: (widget.glowColor.b + 40.0 / 255.0).clamp(0.0, 1.0)),
                    ],
                  ),
            border: widget.isOutline
                ? Border.all(color: widget.glowColor, width: 2)
                : null,
            boxShadow: widget.isOutline
                ? []
                : [
                    BoxShadow(
                       color: widget.glowColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isOutline ? widget.glowColor : Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: widget.isOutline ? widget.glowColor : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
