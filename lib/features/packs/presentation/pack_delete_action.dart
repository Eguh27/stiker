import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/sticker_pack.dart';
import 'pack_providers.dart';

/// Konfirmasi lalu hapus pack. Stiker library yang dipakai tidak ikut terhapus.
Future<void> deletePack(
  BuildContext context,
  WidgetRef ref,
  StickerPack pack,
) async {
  final bool confirmed =
      await showDialog<bool>(
        context: context,
        builder: (_) => _ConfirmDeletePackDialog(name: pack.name),
      ) ??
      false;
  if (!confirmed || !context.mounted) return;

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(packRepositoryProvider).deletePack(pack.id);
    ref.invalidate(packListProvider);
    messenger.showSnackBar(
      SnackBar(content: Text('Pack "${pack.name}" dihapus')),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal menghapus pack: $error')),
    );
  }
}

class _ConfirmDeletePackDialog extends StatelessWidget {
  const _ConfirmDeletePackDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return AlertDialog(
      title: const Text('Hapus pack?'),
      content: Text(
        '"$name" akan dihapus. Stiker aslinya tetap ada di Library.',
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
