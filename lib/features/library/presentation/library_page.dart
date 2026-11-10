import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../../editor/presentation/image_editor_page.dart';
import '../domain/sticker.dart';
import 'import_sheet.dart';
import 'library_hero.dart';
import 'library_segmented.dart';
import 'sticker_grid.dart';
import 'sticker_providers.dart';

/// Library: hero + segmented + grid 8 + FAB sheet. State via AsyncValue.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Sticker>> stickers = ref.watch(stickerListProvider);
    return Scaffold(
      appBar: const TopBar(title: 'Sticker Library'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s2,
                AppSpacing.s5,
                AppSpacing.s5,
              ),
              children: [
                const LibraryHero(),
                const SizedBox(height: AppSpacing.s5),
                LibrarySegmented(
                  selectedIndex: _segment,
                  onSelected: (int value) => setState(() => _segment = value),
                ),
                const SizedBox(height: AppSpacing.s4),
                ..._body(stickers),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => ImportSheet.show(context, ref),
        tooltip: 'Tambah stiker',
        child: const AppIcon(AppIconName.plus),
      ),
    );
  }

  List<Widget> _body(AsyncValue<List<Sticker>> value) {
    return value.when(
      data: (List<Sticker> stickers) {
        if (stickers.isEmpty) {
          return [
            EmptyState(
              title: 'Belum ada stiker',
              message:
                  'Mulai dari galeri atau impor beberapa gambar sekaligus.',
              actionLabel: 'Mulai sekarang',
              onAction: () => ImportSheet.show(context, ref),
            ),
          ];
        }
        final List<Sticker> visible = _segment == 0
            ? stickers
            : stickers.take(4).toList();
        return [
          StickerGrid(
            stickers: visible,
            onTap: (s) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ImageEditorPage(
                  stickerId: s.id,
                  initialImagePath: s.filePath,
                ),
              ),
            ),
          ),
        ];
      },
      loading: () => [const LoadingState(title: 'Menyiapkan stiker')],
      error: (Object error, StackTrace stack) => [
        ErrorState(
          title: 'Gagal memuat stiker',
          message: 'File lokal mungkin dipindahkan. Periksa lalu coba lagi.',
          onRetry: () => ref.invalidate(stickerListProvider),
        ),
      ],
    );
  }
}
