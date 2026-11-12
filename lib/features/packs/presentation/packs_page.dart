import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../domain/sticker_pack.dart';
import 'pack_card.dart';
import 'pack_delete_action.dart';
import 'pack_editor_page.dart';
import 'pack_providers.dart';

/// Packs: list 3 pack + sync label + akses editor pack (screen-map F4).
class PacksPage extends ConsumerWidget {
  const PacksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StickerPack>> packs = ref.watch(packListProvider);
    return Scaffold(
      appBar: const TopBar(title: 'Sticker Packs', showThemeToggle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s2,
          AppSpacing.s5,
          AppSpacing.s5,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KOLEKSI',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Pack milikmu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () => _openEditor(context, packId: null),
                tooltip: 'Tambah pack',
                icon: const AppIcon(AppIconName.plus),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ..._body(context, ref, packs),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, {required String? packId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PackEditorPage(packId: packId)),
    );
  }

  List<Widget> _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<StickerPack>> value,
  ) {
    return value.when(
      data: (List<StickerPack> packs) {
        if (packs.isEmpty) {
          return [
            const EmptyState(
              title: 'Belum ada pack',
              message:
                  'Mulai dari galeri atau impor beberapa gambar sekaligus.',
            ),
          ];
        }
        return [
          for (final StickerPack pack in packs)
            PackCard(
              pack: pack,
              onTap: () => _openEditor(context, packId: pack.id),
              onDelete: () => deletePack(context, ref, pack),
            ),
        ];
      },
      loading: () => [const LoadingState(title: 'Menyiapkan pack')],
      error: (Object error, StackTrace stack) => [
        ErrorState(
          title: 'Gagal memuat pack',
          message: 'File lokal mungkin dipindahkan. Periksa lalu coba lagi.',
          onRetry: () => ref.invalidate(packListProvider),
        ),
      ],
    );
  }
}
