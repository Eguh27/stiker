import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sticker_art.dart';

/// HeroCard Library dari App.tsx (OFFLINE-FIRST).
class LibraryHero extends StatelessWidget {
  const LibraryHero({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.line),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OFFLINE-FIRST',
                  style: TextStyle(
                    fontSize: AppTextTokens.eyebrowSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: AppTextTokens.eyebrowLetterSpacing,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'Koleksimu,\nSelalu siap.',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 26, height: 1.04),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  '48 stiker tersimpan lokal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
                  child: StickerArt(
                    color: colors.stickerPeach,
                    label: 'YAY',
                    small: true,
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: StickerArt(
                    color: colors.stickerLavender,
                    label: 'YES',
                    small: true,
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
