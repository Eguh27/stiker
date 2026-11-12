import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/file_thumbnail.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/sticker_art.dart';
import '../domain/queue_item.dart';
import 'queue_source.dart';

/// QueueCard + progres + retry + label sumber (screen-map queue).
///
/// [onTap] membuka editor untuk riwayat yang sudah selesai; [onDelete]
/// menghapus baris riwayat tanpa menyentuh stiker di Library.
class QueueCard extends StatelessWidget {
  const QueueCard({
    super.key,
    required this.item,
    this.onRetry,
    this.onTap,
    this.onDelete,
  });

  final QueueItem item;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: GlassCard(
        blur: false,
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          children: [
            FileThumbnail(
              path: item.thumbnailPath,
              fallback: StickerArt(
                color: colors.stickerLavender,
                label: item.title,
                small: true,
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(child: _details(context, colors)),
            if (item.status == QueueStatus.failed)
              TextButton.icon(
                onPressed: onRetry,
                icon: const AppIcon(AppIconName.refresh, size: 17),
                label: const Text('Retry'),
              ),
            if (onDelete != null)
              IconButton(
                key: ValueKey<String>('queue-delete-${item.id}'),
                onPressed: onDelete,
                tooltip: 'Hapus dari riwayat',
                icon: AppIcon(
                  AppIconName.delete,
                  size: 20,
                  color: colors.danger,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _details(BuildContext context, AppColors colors) {
    return Column(
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
                color: switch (item.status) {
                  QueueStatus.failed => colors.danger,
                  QueueStatus.done => colors.success,
                  _ => colors.text2,
                },
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
        if (item.errorMessage != null && item.status == QueueStatus.failed)
          Text(item.errorMessage!, style: TextStyle(color: colors.danger)),
      ],
    );
  }
}
