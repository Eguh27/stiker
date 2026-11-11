import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/sticker_art.dart';

/// HeroCard Library: kaca vibrant dengan teks putih.
class LibraryHero extends StatelessWidget {
  const LibraryHero({super.key, this.stickerCount = 0, this.packCount = 0});

  final int stickerCount;
  final int packCount;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextTheme text = Theme.of(context).textTheme;
    final String summary =
        '$stickerCount stiker tersimpan lokal${packCount > 0 ? ' • $packCount paket' : ''}';
    return GlassCard(
      vivid: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OFFLINE-FIRST', style: text.labelSmall?.copyWith(color: Colors.white70)),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'Koleksimu,\nSelalu siap.',
                  style: text.headlineMedium?.copyWith(color: Colors.white, height: 1.05),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(summary, style: text.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          SizedBox(
            width: 126,
            height: 84,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: StickerArt(color: colors.stickerPeach, label: 'YAY', small: true),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: StickerArt(color: colors.stickerLavender, label: 'YES', small: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
