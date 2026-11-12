import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../../library/domain/sticker.dart';
import '../domain/pack_editor_state.dart';
import '../domain/pack_limits.dart';
import 'pack_editor_form.dart';
import 'pack_editor_providers.dart';
import 'sticker_picker_sheet.dart';
import 'whatsapp_publisher.dart';

typedef StickerPickerLauncher = Future<List<Sticker>?> Function({
  required BuildContext context,
  required Set<String> alreadySelectedIds,
  required int maxSelectable,
});

final stickerPickerLauncherProvider = Provider<StickerPickerLauncher>((ref) {
  return StickerPickerSheet.show;
});

/// Editor pack (App.tsx `PackEditor`). [packId] null saat buat pack baru.
class PackEditorPage extends ConsumerStatefulWidget {
  const PackEditorPage({super.key, this.packId});

  final String? packId;

  @override
  ConsumerState<PackEditorPage> createState() => _PackEditorPageState();
}

class _PackEditorPageState extends ConsumerState<PackEditorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  bool _controllersSeeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _seedControllers(PackEditorState state) {
    if (!state.isReady || _controllersSeeded) return;
    _controllersSeeded = true;
    _nameController.text = state.pack!.name;
    _authorController.text = state.pack!.author;
  }

  void _openPacksPage() => Navigator.of(context).maybePop();

  Future<void> _publish() async {
    PackEditorState state = ref.read(packEditorProvider(widget.packId));
    if (!state.isReady || !state.isPublishable) return;

    // Pack baru belum punya id; simpan dulu agar identifier staging valid dan
    // publish tidak pernah memakai id kosong.
    if (state.pack!.id.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      final bool saved = await ref
          .read(packEditorProvider(widget.packId).notifier)
          .save();
      if (!saved) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan pack sebelum mengirim ke WhatsApp'),
          ),
        );
        return;
      }
      if (!mounted) return;
      state = ref.read(packEditorProvider(widget.packId));
    }

    await WhatsAppPublisher.publish(context: context, ref: ref, state: state);
  }

  Future<void> _save() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final PackEditorNotifier notifier = ref.read(
      packEditorProvider(widget.packId).notifier,
    );
    final bool saved = await notifier.save();
    if (saved) {
      navigator.maybePop();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan pack')),
      );
    }
  }

  Future<void> _openStickerPicker() async {
    final state = ref.read(packEditorProvider(widget.packId));
    final currentIds = state.stickers.map((s) => s.id).toSet();
    final remaining = PackLimits.maxStickers - state.stickers.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pack sudah penuh (maksimal 30 stiker)')),
      );
      return;
    }

    final launcher = ref.read(stickerPickerLauncherProvider);
    final selected = await launcher(
      context: context,
      alreadySelectedIds: currentIds,
      maxSelectable: remaining,
    );

    if (selected != null && selected.isNotEmpty && mounted) {
      ref
          .read(packEditorProvider(widget.packId).notifier)
          .addStickers(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PackEditorState state = ref.watch(packEditorProvider(widget.packId));
    _seedControllers(state);
    final PackEditorNotifier notifier = ref.read(
      packEditorProvider(widget.packId).notifier,
    );
    final bool canSave = state.isReady && !state.isSaving;

    return Scaffold(
      appBar: TopBar(
        title: 'Editor Pack',
        onBack: _openPacksPage,
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: switch (state.status) {
        PackEditorStatus.loading => const LoadingState(
          title: 'Menyiapkan pack',
        ),
        PackEditorStatus.error => ErrorState(
          title: 'Gagal memuat pack',
          message: 'Pack mungkin sudah dihapus.',
          onRetry: notifier.reload,
        ),
        PackEditorStatus.ready => PackEditorForm(
          state: state,
          onRename: notifier.rename,
          onAuthorChanged: notifier.setAuthor,
          nameController: _nameController,
          authorController: _authorController,
          onAdd: _openStickerPicker,
          onReorder: notifier.moveSticker,
          onRemove: notifier.removeSticker,
          onToggleEmoji: notifier.toggleEmojiTag,
          onPublish: _publish,
        ),
      },
    );
  }
}
