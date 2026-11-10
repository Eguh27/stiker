import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sticker_studio/features/editor/domain/scene_layer.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/domain/text_layer.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';

/// Merender [SceneProject] ke kanvas 512×512 dan meng-encode ke WebP WhatsApp.
class ProjectSceneRenderer {
  const ProjectSceneRenderer({
    Future<String> Function(String input, String output, int targetKb)?
    encodeWebp,
  }) : _encodeWebp = encodeWebp ?? _defaultEncode;

  final Future<String> Function(String input, String output, int targetKb)
  _encodeWebp;

  static Future<String> _defaultEncode(
    String input,
    String output,
    int targetKb,
  ) {
    return encodeWhatsappWebp(
      inputPath: input,
      outputPath: output,
      targetSizeKb: targetKb,
    );
  }

  Future<String> renderToWebp({
    required SceneProject project,
    required String outputWebpPath,
    required Directory tempDirectory,
    int targetSizeKb = 100,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 512, 512));

    for (final layer in project.layers) {
      if (!layer.visible) continue;
      canvas.save();
      canvas.translate(layer.transform.x, layer.transform.y);
      canvas.rotate(layer.transform.rotation);
      canvas.scale(layer.transform.scale);

      if (layer is TextLayer) {
        _renderTextLayer(canvas, layer);
      } else if (layer is ImageLayer) {
        _renderPlaceholderImageLayer(canvas, layer);
      }
      canvas.restore();
    }

    final ui.Picture picture = recorder.endRecording();
    final ui.Image img = await picture.toImage(512, 512);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw StateError('Gagal merender bitmap kanvas');

    final String tempPngPath =
        '${tempDirectory.path}/render_${DateTime.now().microsecondsSinceEpoch}.png';
    final File tempPng = File(tempPngPath);
    await tempPng.writeAsBytes(byteData.buffer.asUint8List());

    try {
      return await _encodeWebp(tempPngPath, outputWebpPath, targetSizeKb);
    } finally {
      if (await tempPng.exists()) {
        await tempPng.delete();
      }
    }
  }

  void _renderTextLayer(Canvas canvas, TextLayer layer) {
    final Color textColor = _parseColor(layer.color);
    final Color styleColor = _parseColor(layer.styleColor);

    if (layer.presetStyle == 'Latar') {
      final Paint bgPaint = Paint()..color = styleColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: layer.fontSize * layer.text.length * 0.6,
            height: layer.fontSize * 1.4,
          ),
          const Radius.circular(8),
        ),
        bgPaint,
      );
    }

    if (layer.presetStyle == 'Outline') {
      final textPainterOutline = TextPainter(
        text: TextSpan(
          text: layer.text,
          style: TextStyle(
            fontSize: layer.fontSize,
            fontFamily: layer.fontFamily,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = styleColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterOutline.paint(
        canvas,
        Offset(-textPainterOutline.width / 2, -textPainterOutline.height / 2),
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: layer.text,
        style: TextStyle(
          fontSize: layer.fontSize,
          fontFamily: layer.fontFamily,
          color: textColor,
          shadows: layer.presetStyle == 'Shadow'
              ? [
                  Shadow(
                    color: styleColor,
                    offset: const Offset(3, 3),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _renderPlaceholderImageLayer(Canvas canvas, ImageLayer layer) {
    final Paint paint = Paint()..color = const Color(0xFF8D7BD6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 200, height: 200),
        const Radius.circular(16),
      ),
      paint,
    );
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return const Color(0xFF282522);
  }
}
