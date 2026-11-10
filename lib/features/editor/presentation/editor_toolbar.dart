import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_icon.dart';

enum EditorToolType { text, brush, removeBg, border, sticker }

/// Toolbar bawah editor (App.tsx `editor-toolbar`): Teks, Kuas, Hapus BG, Border, Stiker.
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.activeTool,
    required this.onSelectTool,
  });

  final EditorToolType activeTool;
  final ValueChanged<EditorToolType> onSelectTool;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final tools = [
      (EditorToolType.text, 'Teks', AppIconName.text),
      (EditorToolType.brush, 'Kuas', AppIconName.brush),
      (EditorToolType.removeBg, 'Hapus BG', AppIconName.image),
      (EditorToolType.border, 'Border', AppIconName.layers),
      (EditorToolType.sticker, 'Stiker', AppIconName.sticker),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (type, label, icon) in tools)
            InkWell(
              onTap: () => onSelectTool(type),
              borderRadius: AppRadius.control,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      icon,
                      color: activeTool == type ? colors.accent : colors.text2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: activeTool == type
                            ? colors.accent
                            : colors.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
