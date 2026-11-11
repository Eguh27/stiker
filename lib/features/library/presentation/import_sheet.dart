import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sticker_providers.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import 'gallery_picker_page.dart';
import 'import_option.dart';

/// FAB bottom sheet: Dari galeri / Bulk import (screen-map library).
class ImportSheet extends StatelessWidget {
  const ImportSheet({super.key, this.onGallery, this.onBulk});

  final VoidCallback? onGallery;
  final VoidCallback? onBulk;

  static Future<void> show(BuildContext context, [WidgetRef? ref]) {
    Future<void> runImport(BuildContext sheetCtx) async {
      Navigator.of(sheetCtx).pop();
      if (ref != null) {
        final count = await ref
            .read(stickerImportServiceProvider)
            .importFromGallery();
        if (count > 0) {
          ref.invalidate(stickerListProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Berhasil mengimpor $count stiker')),
            );
          }
        }
      } else {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const GalleryPickerPage()),
        );
      }
    }

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.bg,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (BuildContext sheetContext) => ImportSheet(
        onGallery: () => runImport(sheetContext),
        onBulk: () => runImport(sheetContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.lineStrong,
                borderRadius: AppRadius.pill,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Impor stiker',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            ImportOption(
              icon: AppIconName.image,
              title: 'Dari galeri',
              subtitle: 'Pilih satu atau beberapa foto',
              colors: colors,
              onTap: onGallery,
            ),
            ImportOption(
              icon: AppIconName.folder,
              title: 'Bulk import',
              subtitle: 'Impor seluruh folder sekaligus',
              colors: colors,
              onTap: onBulk,
            ),
          ],
        ),
      ),
    );
  }
}
