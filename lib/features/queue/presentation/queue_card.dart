import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/sticker_art.dart';
import '../domain/queue_item.dart';
import 'queue_source.dart';

/// QueueCard + progres + retry + label sumber (screen-map queue).
class QueueCard extends StatelessWidget {
  const QueueCard({super.key, required this.item, this.onRetry});

  final QueueItem item;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return GlassCard(blur: false, margin: const EdgeInsets.only(bottom: AppSpacing.s3), padding: const EdgeInsets.all(AppSpacing.s4), child: Row(
        children: [
          StickerArt(
            color: colors.stickerLavender,
            label: item.title,
            small: true,
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.bodyMedium),
                Row(
                  children: [
                    AppIcon(
                      queueSourceIcon(item.sourceType),
                      size: 14,
                      color: colors.text2,
                    ),
                    const SizedBox(width: AppSpacing.s1),
                    Text(
                      item.sourceType.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      item.status.label,
                      style: TextStyle(
                        color: item.status == QueueStatus.failed
                            ? colors.danger
                            : item.status == QueueStatus.done
                            ? colors.success
                            : colors.text2,
                      ),
                    ),
                  ],
                ),
                if (item.status == QueueStatus.pending)
                  Text(
                    'Menunggu proses sebelumnya',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s1),
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: item.progress / 100,
                            backgroundColor: colors.surfaceMuted,
                            color: item.status == QueueStatus.done
                                ? colors.success
                                : colors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        Text('${item.progress}%'),
                      ],
                    ),
                  ),
                if (item.errorMessage != null &&
                    item.status == QueueStatus.failed)
                  Text(
                    item.errorMessage!,
                    style: TextStyle(color: colors.danger),
                  ),
              ],
            ),
          ),
          if (item.status == QueueStatus.failed)
            TextButton.icon(
              onPressed: onRetry,
              icon: const AppIcon(AppIconName.refresh, size: 17),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
