import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_icon.dart';

/// Action bar di bawah TopBar editor: Undo, Redo, Layers (App.tsx `editor-actionbar`).
class EditorActionBar extends StatelessWidget {
  const EditorActionBar({
    super.key,
    required this.canUndo,
    required this.canRedo,
    required this.isLayersOpen,
    required this.onUndo,
    required this.onRedo,
    required this.onToggleLayers,
  });

  final bool canUndo;
  final bool canRedo;
  final bool isLayersOpen;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onToggleLayers;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget actionButton({
      required AppIconName icon,
      required VoidCallback? onTap,
      bool selected = false,
      String? tooltip,
    }) {
      final Color iconColor = onTap == null
          ? colors.text3
          : (selected ? colors.accent : colors.text);
      return IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: AppIcon(icon, color: iconColor),
        style: IconButton.styleFrom(
          backgroundColor: selected ? colors.accentSoft : colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          side: BorderSide(color: selected ? colors.accent : colors.line),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s2,
      ),
      child: Row(
        children: [
          actionButton(
            icon: AppIconName.undo,
            onTap: canUndo ? onUndo : null,
            tooltip: 'Undo',
          ),
          const SizedBox(width: AppSpacing.s2),
          actionButton(
            icon: AppIconName.redo,
            onTap: canRedo ? onRedo : null,
            tooltip: 'Redo',
          ),
          const Spacer(),
          actionButton(
            icon: AppIconName.layers,
            onTap: onToggleLayers,
            selected: isLayersOpen,
            tooltip: 'Layer',
          ),
        ],
      ),
    );
  }
}
