import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../domain/sticker_pack.dart';

/// Kartu pack list (App.tsx `pack-card`), membuka editor saat ditekan.
class PackCard extends StatelessWidget {
  const PackCard({super.key, required this.pack, this.onTap});

  final StickerPack pack;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(blur: false, margin: const EdgeInsets.only(bottom: AppSpacing.s3), padding: const EdgeInsets.all(AppSpacing.s4), child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('${pack.stickerCount} stiker'),
                  Text(
                    pack.isSynced ? 'Tersinkron WhatsApp' : 'Perlu diperbarui',
                    style: TextStyle(color: colors.success),
                  ),
                ],
              ),
            ),
            AppIcon(AppIconName.chevron, color: colors.text3),
          ],
        ),
      ),
    );
  }
}
