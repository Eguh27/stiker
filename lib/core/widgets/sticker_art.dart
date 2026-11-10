import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Placeholder `StickerArt` (screen-map): diganti WebP encoder nanti.
/// Bentuk dibedakan lewat radius; warna & label dari caller (token).
enum StickerArtShape { blob, cloud, flower, burst }

class StickerArt extends StatelessWidget {
  const StickerArt({
    super.key,
    required this.color,
    required this.label,
    this.shape = StickerArtShape.blob,
    this.small = false,
  });

  final Color color;
  final String label;
  final StickerArtShape shape;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final double size = small ? 58 : 116;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(size * 0.08),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: colors.surfaceSolid, width: 5),
              borderRadius: _radius(shape),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextTokens.headingFamily,
              fontSize: small ? 10 : 20,
              fontWeight: FontWeight.w800,
              color: colors.text,
              shadows: [
                Shadow(offset: const Offset(0, 1), color: colors.surfaceSolid),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  BorderRadius _radius(StickerArtShape value) => switch (value) {
    StickerArtShape.blob => BorderRadius.circular(28),
    StickerArtShape.cloud => BorderRadius.circular(32),
    StickerArtShape.flower => BorderRadius.circular(24),
    StickerArtShape.burst => BorderRadius.circular(18),
  };
}
