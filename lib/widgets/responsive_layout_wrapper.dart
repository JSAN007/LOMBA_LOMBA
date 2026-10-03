import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';
import '../core/theme/cyber_colors.dart';

/// Responsive wrapper that constrains the app to a mobile frame.
class ResponsiveLayoutWrapper extends StatelessWidget {
  const ResponsiveLayoutWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // Determine if we're on desktop/tablet
    final isDesktop = screenWidth > AppTokens.desktopBreakpoint;

    if (!isDesktop) {
      // Mobile: frame fits to screen, max width 430
      final frameWidth = math.min(screenWidth, AppTokens.frameMaxWidth);
      final frameHeight = screenHeight;
      final frameSize = Size(frameWidth, frameHeight);

      return MediaQuery(
        data: media.copyWith(
          size: frameSize,
          textScaler: TextScaler.linear(
            media.textScaler.scale(1.0).clamp(0.9, 1.15).toDouble(),
          ),
        ),
        child: Container(
          width: frameWidth,
          height: frameHeight,
          color: palette.background,
          child: child,
        ),
      );
    }

    // Desktop: center frame with margins, outer background with blobs
    final availableWidth = screenWidth - (AppTokens.frameMargin * 2);
    final availableHeight = screenHeight - (AppTokens.frameMargin * 2);
    final frameWidth = math.min(availableWidth, AppTokens.frameMaxWidth);
    final frameHeight = math.min(availableHeight, AppTokens.frameMaxHeight);
    final frameSize = Size(frameWidth, frameHeight);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1026),
      body: Stack(
        children: [
          // Outer background radial gradient + decorative blobs
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [Color(0xFF0F1633), Color(0xFF0B1026)],
              ),
            ),
          ),
          // Blob 1
          Positioned(
            top: -AppTokens.blobSize1 * 0.25,
            left: -AppTokens.blobSize1 * 0.5,
            child: _Blob(
              size: AppTokens.blobSize1,
              color: CyberColors.primary.withValues(alpha: 0.08),
            ),
          ),
          // Blob 2
          Positioned(
            bottom: -AppTokens.blobSize2 * 0.25,
            right: -AppTokens.blobSize2 * 0.4,
            child: _Blob(
              size: AppTokens.blobSize2,
              color: CyberColors.accentGreen.withValues(alpha: 0.08),
            ),
          ),
          // Centered frame
          Center(
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(AppTokens.radiusFrame),
                border: Border.all(
                  color: palette.border.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow.withValues(alpha: 0.25),
                    blurRadius: AppTokens.frameShadowBlur,
                    offset: AppTokens.frameShadowOffset,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(
                data: media.copyWith(
                  size: frameSize,
                  textScaler: TextScaler.linear(
                    media.textScaler.scale(1.0).clamp(0.9, 1.15).toDouble(),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTokens.blobBlur,
          sigmaY: AppTokens.blobBlur,
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
