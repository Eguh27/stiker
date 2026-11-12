import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../library/domain/sticker.dart';
import 'pack_add_sticker_cell.dart';
import 'pack_sticker_cell.dart';

/// Grid susun stiker (App.tsx `pack-edit-grid`): reorder via long-press
/// drag&drop + tombol Tambah dengan garis putus-putus.
class PackEditGrid extends StatelessWidget {
  const PackEditGrid({
    super.key,
    required this.stickers,
    this.canAdd = true,
    this.onAdd,
    this.onReorder,
    this.onRemove,
  });

  final List<Sticker> stickers;
  final bool canAdd;
  final VoidCallback? onAdd;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: AppLayout.packEditorColumns,
      mainAxisSpacing: AppSpacing.s2,
      crossAxisSpacing: AppSpacing.s2,
      childAspectRatio: 1,
      children: [
        for (int index = 0; index < stickers.length; index++)
          PackStickerCell(
            key: ValueKey<String>('pack-cell-${index + 1}'),
            sticker: stickers[index],
            index: index,
            onReorder: onReorder,
            onRemove: onRemove == null ? null : () => onRemove!(index),
          ),
        PackAddStickerCell(canAdd: canAdd, onAdd: onAdd),
      ],
    );
  }
}
