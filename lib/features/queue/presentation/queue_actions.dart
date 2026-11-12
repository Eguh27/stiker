import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../editor/presentation/image_editor_page.dart';
import '../domain/queue_item.dart';
import 'queue_providers.dart';

/// Buka editor untuk file yang tertaut pada satu baris riwayat impor.
void openQueueItemEditor(BuildContext context, QueueItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ImageEditorPage(
        stickerId: item.id,
        initialImagePath: item.thumbnailPath,
      ),
    ),
  );
}

/// Konfirmasi lalu hapus satu baris riwayat. Hanya baris `import_queue`
/// yang dihapus; stiker hasil impor tetap tersedia di Library.
Future<void> deleteQueueHistory(
  BuildContext context,
  WidgetRef ref,
  QueueItem item,
) async {
  final bool confirmed =
      await showDialog<bool>(
        context: context,
        builder: (_) => _ConfirmDeleteHistoryDialog(title: item.title),
      ) ??
      false;
  if (!confirmed || !context.mounted) return;

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(queueRepositoryProvider).deleteItems([item.id]);
    ref.invalidate(queueStreamProvider);
    messenger.showSnackBar(
      SnackBar(content: Text('Riwayat "${item.title}" dihapus')),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal menghapus riwayat: $error')),
    );
  }
}

class _ConfirmDeleteHistoryDialog extends StatelessWidget {
  const _ConfirmDeleteHistoryDialog({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus riwayat?'),
      content: Text(
        '"$title" akan dihapus dari Queue Monitor. '
        'Stiker hasil impor tetap ada di Library.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
