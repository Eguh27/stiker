import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/data/whatsapp/whatsapp_providers.dart';

import '../domain/pack_editor_state.dart';

class WhatsAppPublisher {
  const WhatsAppPublisher._();

  static Future<void> publish({
    required BuildContext context,
    required WidgetRef ref,
    required PackEditorState state,
  }) async {
    if (!state.isReady || !state.isPublishable) return;

    final messenger = ScaffoldMessenger.of(context);
    final channel = ref.read(whatsAppChannelProvider);
    final exporter = ref.read(whatsAppStagingExporterProvider);

    final isWa = await channel.isWhatsAppInstalled();
    final isWaBusiness = await channel.isWhatsAppInstalled(business: true);

    if (!isWa && !isWaBusiness) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('WhatsApp tidak terpasang di perangkat ini.'),
        ),
      );
      return;
    }

    try {
      final stagingDir = await channel.getStagingDirectory();
      await exporter.exportPack(
        stagingBaseDir: stagingDir,
        identifier: state.pack!.id,
        name: state.pack!.name,
        author: state.pack!.author,
        stickerPaths: [for (final s in state.stickers) s.filePath ?? ''],
        emojis: state.emojiTags,
        trayIconPath: state.stickers.firstOrNull?.filePath,
      );

      final added = await channel.addStickerPack(
        identifier: state.pack!.id,
        name: state.pack!.name,
        isBusiness: !isWa && isWaBusiness,
      );

      if (added) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Membuka WhatsApp...')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan ke WhatsApp')),
        );
      }
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke WhatsApp: ${_reason(e)}')),
      );
    }
  }

  static String _reason(Object error) =>
      error is StateError ? error.message : error.toString();
}
