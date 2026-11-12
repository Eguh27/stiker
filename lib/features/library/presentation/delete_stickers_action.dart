import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../packs/presentation/pack_providers.dart';
import 'sticker_providers.dart';
import 'sticker_selection_provider.dart';

/// Konfirmasi lalu hapus semua stiker terpilih, dan segarkan daftar terkait.
Future<void> deleteSelectedStickers(BuildContext context, WidgetRef ref) async {
  final Set<String> ids = ref.read(stickerSelectionProvider);
  if (ids.isEmpty) return;
  final bool confirmed =
      await showDialog<bool>(
        context: context,
        builder: (_) => _ConfirmDeleteDialog(count: ids.length),
      ) ??
      false;
  if (!confirmed || !context.mounted) return;

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    final int removed = await ref
        .read(stickerRepositoryProvider)
        .deleteStickers(ids);
    ref.read(stickerSelectionProvider.notifier).clear();
    ref.invalidate(stickerListProvider);
    ref.invalidate(packListProvider);
    messenger.showSnackBar(SnackBar(content: Text('$removed stiker dihapus')));
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal menghapus stiker: $error')),
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return AlertDialog(
      title: Text('Hapus $count stiker?'),
      content: const Text(
        'Stiker juga dihapus dari pack yang memakainya. '
        'Tindakan ini tidak bisa dibatalkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
