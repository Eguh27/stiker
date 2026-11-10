import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/state_panels.dart';
import '../domain/pack_limits.dart';
import 'emoji_picker.dart';
import 'pack_edit_fields.dart';
import 'pack_edit_grid.dart';
import 'pack_header_card.dart';
import 'validation_card.dart';
import 'whatsapp_publish_button.dart';
import '../domain/pack_editor_state.dart';

/// Isi form editor(App.tsx `editor-form`): header tray, field, grid, emoji,
/// validasi, tombol WhatsApp.
class PackEditorForm extends StatelessWidget {
  const PackEditorForm({
    super.key,
    required this.state,
    required this.onRename,
    required this.onAuthorChanged,
    required this.nameController,
    required this.authorController,
    required this.onAdd,
    required this.onReorder,
    required this.onToggleEmoji,
    required this.onPublish,
  });

  final PackEditorState state;
  final ValueChanged<String> onRename;
  final ValueChanged<String> onAuthorChanged;
  final TextEditingController nameController;
  final TextEditingController authorController;
  final VoidCallback onAdd;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onToggleEmoji;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      PackHeaderCard(
        name: state.displayName,
        traySticker: state.stickers.firstOrNull,
        isPublishable: state.isPublishable,
      ),
      const SizedBox(height: AppSpacing.s4),
      PackEditField(
        label: 'Nama pack',
        controller: nameController,
        onChanged: onRename,
        enabled: !state.isSaving,
      ),
      const SizedBox(height: AppSpacing.s3),
      PackEditField(
        label: 'Pembuat',
        controller: authorController,
        onChanged: onAuthorChanged,
        enabled: !state.isSaving,
      ),
      const SizedBox(height: AppSpacing.s6),
      _SectionHeading(
        counter: '${state.stickers.length}/${PackLimits.maxStickers}',
      ),
      const SizedBox(height: AppSpacing.s1),
      if (state.stickers.isNotEmpty) ..._reorderHint(context),
      _gridSection(context),
      const SizedBox(height: AppSpacing.s5),
      EmojiTagPicker(selected: state.emojiTags, onToggle: onToggleEmoji),
      const SizedBox(height: AppSpacing.s5),
      PackValidationCard(stickerCount: state.stickers.length),
      const SizedBox(height: AppSpacing.s4),
      WhatsAppPublishButton(
        enabled: state.isPublishable && !state.isSaving,
        onPressed: onPublish,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s3,
        AppSpacing.s5,
        AppSpacing.s5,
      ),
      children: children,
    );
  }

  List<Widget> _reorderHint(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Text(
        'Tekan dan tahan untuk mengatur ulang.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  ];

  Widget _gridSection(BuildContext context) {
    if (state.stickers.isEmpty) {
      return EmptyState(
        title: 'Pack masih kosong',
        message: 'Tambah stiker untuk mulai menyusun pack.',
        icon: AppIconName.plus,
        actionLabel: 'Tambah stiker',
        onAction: onAdd,
      );
    }
    return PackEditGrid(
      stickers: state.stickers,
      canAdd: state.canAddSticker,
      onAdd: onAdd,
      onReorder: onReorder,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.counter});

  final String counter;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STIKER', style: Theme.of(context).textTheme.labelSmall),
              Text('Susun pack', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s1,
          ),
          decoration: BoxDecoration(
            color: colors.accentSoft,
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            counter,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.accent),
          ),
        ),
      ],
    );
  }
}
