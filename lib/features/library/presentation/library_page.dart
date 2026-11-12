import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../../data/import/foreground_import_runner.dart';
import '../../editor/presentation/image_editor_page.dart';
import '../../packs/domain/sticker_pack.dart';
import '../../packs/presentation/pack_card.dart';
import '../../packs/presentation/pack_delete_action.dart';
import '../../packs/presentation/pack_editor_page.dart';
import '../../packs/presentation/pack_providers.dart';
import '../domain/sticker.dart';
import 'delete_stickers_action.dart';
import 'import_sheet.dart';
import 'library_hero.dart';
import 'library_segmented.dart';
import 'sticker_grid.dart';
import 'selection_bar.dart';
import 'sticker_providers.dart';
import 'sticker_selection_provider.dart';

/// Library: hero + paket stiker + segmented stiker + FAB.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  int _segment = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref
            .read(foregroundImportRunnerProvider)
            .processAllPending(
              onStickerAdded: () {
                ref.invalidate(stickerListProvider);
                ref.invalidate(packListProvider);
              },
            );
      }
    });
  }

  void _onStickerTap(Sticker sticker) {
    final selection = ref.read(stickerSelectionProvider.notifier);
    if (ref.read(stickerSelectionProvider).isNotEmpty) {
      selection.toggle(sticker.id);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ImageEditorPage(
          stickerId: sticker.id,
          initialImagePath: sticker.filePath,
        ),
      ),
    );
  }

  void _openPackEditor({String? packId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PackEditorPage(packId: packId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Sticker>> stickers = ref.watch(stickerListProvider);
    final AsyncValue<List<StickerPack>> packs = ref.watch(packListProvider);

    final int stickerCount = stickers.value?.length ?? 0;
    final int packCount = packs.value?.length ?? 0;
    final int newCount = stickers.value != null
        ? (stickers.value!.length >= 8 ? 8 : stickers.value!.length)
        : 0;

    final packsList = packs.value ?? const <StickerPack>[];
    final Set<String> selected = ref.watch(stickerSelectionProvider);
    final bool selecting = selected.isNotEmpty;

    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(stickerSelectionProvider.notifier).clear();
      },
      child: Scaffold(
      appBar: const TopBar(title: 'Sticker Library', showThemeToggle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(foregroundImportRunnerProvider).processAllPending();
          ref.invalidate(stickerListProvider);
          ref.invalidate(packListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s5,
            AppSpacing.s2,
            AppSpacing.s5,
            88,
          ),
          children: [
            LibraryHero(stickerCount: stickerCount, packCount: packCount),
            const SizedBox(height: AppSpacing.s5),
            if (packsList.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PAKET STIKER ($packCount)',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  TextButton.icon(
                    onPressed: () => _openPackEditor(packId: null),
                    icon: const AppIcon(AppIconName.plus, size: 14),
                    label: const Text('Buat pack'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s2),
              for (final StickerPack pack in packsList)
                PackCard(
                  pack: pack,
                  onTap: () => _openPackEditor(packId: pack.id),
                  onDelete: () => deletePack(context, ref, pack),
                ),
              const SizedBox(height: AppSpacing.s4),
            ],
            LibrarySegmented(
              selectedIndex: _segment,
              onSelected: (int value) => setState(() => _segment = value),
              allCount: stickerCount,
              newCount: newCount,
            ),
            const SizedBox(height: AppSpacing.s4),
            ..._stickersBody(stickers),
          ],
        ),
      ),
      floatingActionButtonLocation: selecting
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: selecting
          ? SelectionBar(
              count: selected.length,
              onCancel: ref.read(stickerSelectionProvider.notifier).clear,
              onDelete: () => deleteSelectedStickers(context, ref),
            )
          : FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () => ImportSheet.show(context, ref),
              tooltip: 'Tambah stiker',
              child: const AppIcon(AppIconName.plus),
            ),
      ),
    );
  }

  List<Widget> _stickersBody(AsyncValue<List<Sticker>> value) {
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
            selectedIds: ref.watch(stickerSelectionProvider),
            onLongPress: (s) =>
                ref.read(stickerSelectionProvider.notifier).select(s.id),
            onTap: (s) => _onStickerTap(s),
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
