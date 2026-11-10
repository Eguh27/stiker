import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_icon.dart';

import '../domain/scene_layer.dart';
import '../domain/text_layer.dart';

/// Panel daftar layer (App.tsx `layer-panel`): memilih, melihat status, & hapus.
class EditorLayerPanel extends StatelessWidget {
  const EditorLayerPanel({
    super.key,
    required this.layers,
    required this.activeLayerId,
    required this.onSelectLayer,
    required this.onToggleVisibility,
    required this.onDeleteLayer,
    required this.onClose,
  });

  final List<SceneLayer> layers;
  final String? activeLayerId;
  final ValueChanged<String> onSelectLayer;
  final ValueChanged<String> onToggleVisibility;
  final ValueChanged<String> onDeleteLayer;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.s4),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Layer', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                onPressed: onClose,
                icon: AppIcon(AppIconName.close, color: colors.text2),
              ),
            ],
          ),
          const Divider(),
          for (final layer in layers.reversed)
            Material(
              color: Colors.transparent,
              child: ListTile(
                dense: true,
                selected: layer.id == activeLayerId,
                selectedTileColor: colors.accentSoft,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.control,
                ),
                leading: Icon(
                  layer is TextLayer
                      ? Icons.text_fields_rounded
                      : Icons.image_rounded,
                  color: layer.visible ? colors.text : colors.text3,
                ),
                title: Text(
                  layer is TextLayer ? layer.text : 'Stiker utama',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        layer.visible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 18,
                      ),
                      onPressed: () => onToggleVisibility(layer.id),
                    ),
                    if (layers.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        onPressed: () => onDeleteLayer(layer.id),
                      ),
                  ],
                ),
                onTap: () => onSelectLayer(layer.id),
              ),
            ),
        ],
      ),
    );
  }
}
