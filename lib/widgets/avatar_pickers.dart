import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/avatar_presets.dart';

/// A lightweight picker shown in a bottom sheet to swap between the local
/// preset avatars without pulling in any native image plugins.
class PresetAvatarPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PresetAvatarPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pilih Avatar Preset',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12 style siap dipilih. Tampilan tetap konsisten di semua mode.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAvatarPresets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final preset = kAvatarPresets[index];
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    onSelected(index);
                    Navigator.of(context).maybePop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: _GradientDisc(gradient: preset.gradient),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarGradient extends StatelessWidget {
  final int presetIndex;
  final double radius;

  const AvatarGradient({
    super.key,
    required this.presetIndex,
    this.radius = 48,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: _GradientDisc(gradient: avatarGradient(presetIndex)),
    );
  }
}

class _GradientDisc extends StatelessWidget {
  final List<Color> gradient;

  const _GradientDisc({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiscPainter(gradient: gradient),
      size: const Size.square(double.infinity),
    );
  }
}

class _DiscPainter extends CustomPainter {
  final List<Color> gradient;

  _DiscPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        colors: gradient + [gradient.first],
        center: Alignment.center,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) =>
      oldDelegate.gradient != gradient;
}
