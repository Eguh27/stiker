import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sticker_art.dart';
import '../../library/domain/sticker.dart';
import '../../library/presentation/sticker_visuals.dart';

/// Sel stiker di grid editor: menampilkan stiker, nomor urut,
/// dan mendukung drag-and-drop reorder via long-press.
class PackStickerCell extends StatelessWidget {
  const PackStickerCell({
    super.key,
    required this.sticker,
    required this.index,
    this.onReorder,
    this.onRemove,
  });

  final Sticker sticker;
  final int index;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    Widget buildCard({bool isDragging = false}) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.control,
          border: Border.all(color: colors.line),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (sticker.filePath != null &&
                File(sticker.filePath!).existsSync())
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s1),
                child: Image.file(
                  File(sticker.filePath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => StickerArt(
                    color: stickerColorFor(colors, sticker.colorKind),
                    label: sticker.label,
                    shape: shapeFor(sticker.shape),
                    small: true,
                  ),
                ),
              )
            else
              StickerArt(
                color: stickerColorFor(colors, sticker.colorKind),
                label: sticker.label,
                shape: shapeFor(sticker.shape),
                small: true,
              ),
            Positioned(
              right: AppSpacing.s1,
              bottom: AppSpacing.s1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s1,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSolid.withValues(alpha: 0.8),
                  borderRadius: AppRadius.control,
                ),
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.text2, fontSize: 10),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  key: ValueKey<String>('pack-remove-${sticker.id}'),
                  onPressed: onRemove,
                  tooltip: 'Hapus dari pack',
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.text2,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        if (details.data != index) {
          onReorder?.call(details.data, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          feedback: SizedBox(
            width: 72,
            height: 72,
            child: Material(
              elevation: 4,
              borderRadius: AppRadius.control,
              child: buildCard(isDragging: true),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: buildCard()),
          child: buildCard(),
        );
      },
    );
  }
}
