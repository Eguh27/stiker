import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../domain/sticker.dart';
import 'gallery_providers.dart';
import 'photo_grid.dart';
import 'sticker_providers.dart';
import 'sticky_action.dart';

/// GalleryPicker (screen-map F2): grid 12 foto multi-select + Import.
class GalleryPickerPage extends ConsumerWidget {
  const GalleryPickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Sticker>> photos = ref.watch(galleryPhotosProvider);
    final Set<int> selected = ref.watch(gallerySelectionProvider);
    final bool isAllSelected = selected.length == 12;

    return Scaffold(
      appBar: TopBar(
        title: 'Pilih dari galeri',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          TextButton(
            onPressed: () {
              final GallerySelectionNotifier notifier = ref.read(
                gallerySelectionProvider.notifier,
              );
              if (isAllSelected) {
                notifier.clearAll();
              } else {
                notifier.selectAll();
              }
            },
            child: Text(isAllSelected ? 'Hapus semua' : 'Pilih semua'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s2,
          AppSpacing.s5,
          AppSpacing.s4,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terbaru', style: Theme.of(context).textTheme.bodySmall),
              Text(
                '${selected.length} terpilih',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ..._body(ref, photos, selected),
        ],
      ),
      bottomNavigationBar: StickyAction(
        selectedCount: selected.length,
        onImport: () => Navigator.of(context).pop(selected.length),
      ),
    );
  }

  List<Widget> _body(
    WidgetRef ref,
    AsyncValue<List<Sticker>> value,
    Set<int> selected,
  ) {
    return value.when(
      data: (List<Sticker> photos) {
        if (photos.isEmpty) {
          return [
            const EmptyState(
              title: 'Belum ada foto',
              message:
                  'Mulai dari galeri atau impor beberapa gambar sekaligus.',
            ),
          ];
        }
        return [
          PhotoGrid(
            photos: photos,
            selected: selected,
            onToggle: (int index) =>
                ref.read(gallerySelectionProvider.notifier).toggle(index),
          ),
        ];
      },
      loading: () => [const LoadingState(title: 'Memuat galeri')],
      error: (Object error, StackTrace stack) => [
        ErrorState(
          title: 'Gagal memuat galeri',
          message: 'Foto lokal mungkin dipindahkan. Periksa lalu coba lagi.',
          onRetry: () => ref.invalidate(stickerListProvider),
        ),
      ],
    );
  }
}
