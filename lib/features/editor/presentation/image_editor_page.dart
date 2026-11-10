import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';

import '../../library/presentation/sticker_providers.dart';
import '../domain/scene_layer.dart';
import '../domain/text_layer.dart';
import 'border_editor_page.dart';
import 'brush_palette.dart';
import 'editor_action_bar.dart';
import 'editor_canvas.dart';
import 'editor_layer_panel.dart';
import 'editor_providers.dart';
import 'editor_toolbar.dart';
import 'remove_background_page.dart';
import 'text_editor_page.dart';

/// Halaman utama editor stiker (App.tsx `ImageEditor`).
class ImageEditorPage extends ConsumerStatefulWidget {
  const ImageEditorPage({
    super.key,
    this.stickerId = 'stk-1',
    this.initialImagePath,
  });

  final String stickerId;
  final String? initialImagePath;

  @override
  ConsumerState<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends ConsumerState<ImageEditorPage> {
  EditorToolType _activeTool = EditorToolType.text;
  String _brushColor = '#ff6b00';

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      Future.microtask(() {
        if (mounted) {
          ref
              .read(editorProvider(widget.stickerId).notifier)
              .setInitialImagePath(widget.initialImagePath!);
        }
      });
    }
  }

  Future<void> _openTextEditor([TextLayer? initial]) async {
    final result = await Navigator.of(context).push<TextLayer>(
      MaterialPageRoute(builder: (_) => TextEditorPage(initialLayer: initial)),
    );
    if (result != null && mounted) {
      ref.read(editorProvider(widget.stickerId).notifier).addLayer(result);
    }
  }

  Future<void> _openRemoveBg() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const RemoveBackgroundPage()),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Latar belakang dihapus (${result['mode']})')),
      );
    }
  }

  Future<void> _openBorderEditor() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const BorderEditorPage()),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Border diterapkan (${result['width']}px)')),
      );
    }
  }

  Future<void> _pickStickerImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        ref
            .read(editorProvider(widget.stickerId).notifier)
            .addLayer(
              ImageLayer(
                id: 'sticker-${DateTime.now().millisecondsSinceEpoch}',
                imagePath: picked.path,
                transform: const LayerTransform(x: 256, y: 256, scale: 0.8),
              ),
            );
        return;
      }
    } catch (_) {}

    if (mounted) {
      ref
          .read(editorProvider(widget.stickerId).notifier)
          .addLayer(
            ImageLayer(
              id: 'sticker-${DateTime.now().millisecondsSinceEpoch}',
              imagePath: '/app_data/stickers/extra.webp',
              transform: const LayerTransform(x: 256, y: 256, scale: 0.8),
            ),
          );
    }
  }

  void _onSelectTool(EditorToolType tool) {
    setState(() => _activeTool = tool);
    if (tool == EditorToolType.text) {
      _openTextEditor();
    } else if (tool == EditorToolType.removeBg) {
      _openRemoveBg();
    } else if (tool == EditorToolType.border) {
      _openBorderEditor();
    } else if (tool == EditorToolType.sticker) {
      _pickStickerImage();
    }
  }

  Future<void> _onFinish() async {
    final success = await ref
        .read(editorProvider(widget.stickerId).notifier)
        .save();
    if (mounted) {
      if (success) {
        ref.invalidate(stickerListProvider);
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan project')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(editorProvider(widget.stickerId));
    final notifier = ref.read(editorProvider(widget.stickerId).notifier);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: TopBar(
        title: 'Edit stiker',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          ElevatedButton(
            onPressed: state.isSaving ? null : _onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            EditorActionBar(
              canUndo: state.canUndo,
              canRedo: state.canRedo,
              isLayersOpen: state.isLayersOpen,
              onUndo: notifier.undo,
              onRedo: notifier.redo,
              onToggleLayers: notifier.toggleLayersPanel,
            ),
            Expanded(
              child: Stack(
                children: [
                  EditorCanvas(
                    project: state.project,
                    activeLayerId: state.activeLayerId,
                    onSelectLayer: notifier.selectLayer,
                    onTransformLayer: notifier.updateTransform,
                    isBrushActive: _activeTool == EditorToolType.brush,
                    brushColor: _brushColor,
                    onAddDrawingLayer: notifier.addLayer,
                  ),
                  if (state.isLayersOpen)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: EditorLayerPanel(
                        layers: state.project.layers,
                        activeLayerId: state.activeLayerId,
                        onSelectLayer: notifier.selectLayer,
                        onToggleVisibility: notifier.toggleVisibility,
                        onDeleteLayer: notifier.removeLayer,
                        onClose: notifier.toggleLayersPanel,
                      ),
                    ),
                ],
              ),
            ),
            if (_activeTool == EditorToolType.brush)
              BrushPalette(
                selectedColor: _brushColor,
                onSelectColor: (c) => setState(() => _brushColor = c),
              ),
            EditorToolbar(activeTool: _activeTool, onSelectTool: _onSelectTool),
          ],
        ),
      ),
    );
  }
}
