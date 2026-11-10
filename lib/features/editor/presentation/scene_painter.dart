import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';

import '../domain/drawing_layer.dart';
import '../domain/scene_layer.dart';
import '../domain/scene_project.dart';
import '../domain/text_layer.dart';

/// Painter kanvas scene editor untuk layer teks, gambar, dan coretan.
class ScenePainter extends CustomPainter {
  ScenePainter({
    required this.project,
    required this.activeLayerId,
    required this.colors,
    this.images = const {},
    this.activeStroke = const [],
    this.activeStrokeColor = '#ff6b00',
    this.activeStrokeWidth = 6.0,
    this.isExporting = false,
  });

  final SceneProject project;
  final String? activeLayerId;
  final AppColors colors;
  final Map<String, ui.Image> images;
  final List<DrawingPoint> activeStroke;
  final String activeStrokeColor;
  final double activeStrokeWidth;
  final bool isExporting;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isExporting) {
      _drawCheckerboard(canvas, size);
    }

    final double scale = size.width / project.canvasWidth;
    canvas.save();
    canvas.scale(scale);

    for (final layer in project.layers) {
      if (!layer.visible) continue;
      canvas.save();
      canvas.translate(layer.transform.x, layer.transform.y);
      canvas.rotate(layer.transform.rotation);
      canvas.scale(layer.transform.scale);

      if (layer is TextLayer) {
        _drawText(canvas, layer);
      } else if (layer is ImageLayer) {
        _drawImage(canvas, layer);
      } else if (layer is DrawingLayer) {
        _drawStroke(canvas, layer);
      }

      if (layer.id == activeLayerId) {
        _drawSelectionBox(canvas);
      }
      canvas.restore();
    }

    if (activeStroke.isNotEmpty) {
      _drawRawStroke(
        canvas,
        activeStroke,
        activeStrokeColor,
        activeStrokeWidth,
      );
    }
    canvas.restore();
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const double sq = 16.0;
    final isDark = colors.bg.computeLuminance() < 0.5;
    final lightColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFF0F0F0);
    final darkColor = isDark
        ? const Color(0xFF1C1C1C)
        : const Color(0xFFE2E2E2);
    final lightPaint = Paint()..color = lightColor;
    final darkPaint = Paint()..color = darkColor;

    final cols = (size.width / sq).ceil();
    final rows = (size.height / sq).ceil();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final p = (r + c) % 2 == 0 ? lightPaint : darkPaint;
        canvas.drawRect(Rect.fromLTWH(c * sq, r * sq, sq, sq), p);
      }
    }
  }

  void _drawText(Canvas canvas, TextLayer layer) {
    Color textColor = colors.text;
    try {
      final hex = layer.color.replaceAll('#', '');
      if (hex.length == 6) {
        textColor = Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        textColor = Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}

    final tp = TextPainter(
      text: TextSpan(
        text: layer.text,
        style: TextStyle(
          fontSize: layer.fontSize,
          fontFamily: layer.fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Color(0x66000000),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  void _drawImage(Canvas canvas, ImageLayer layer) {
    final ui.Image? image = images[layer.imagePath];
    if (image != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final double aspect =
          image.width / (image.height == 0 ? 1 : image.height);
      final double targetW = aspect >= 1.0 ? 440.0 : 440.0 * aspect;
      final double targetH = aspect >= 1.0 ? 440.0 / aspect : 440.0;
      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: targetW,
        height: targetH,
      );
      canvas.drawImageRect(
        image,
        src,
        dst,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      _drawImagePlaceholder(canvas);
    }
  }

  void _drawImagePlaceholder(Canvas canvas) {
    final Paint paint = Paint()..color = colors.accentSoft;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 220, height: 220),
        const Radius.circular(20),
      ),
      paint,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '🎨',
        style: TextStyle(fontSize: 72, color: colors.text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawStroke(Canvas canvas, DrawingLayer layer) {
    if (layer.points.isEmpty) return;
    Color strokeColor = colors.accent;
    try {
      final hex = layer.color.replaceAll('#', '');
      if (hex.length == 6) {
        strokeColor = Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        strokeColor = Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = layer.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(layer.points.first.x, layer.points.first.y);
    for (int i = 1; i < layer.points.length; i++) {
      path.lineTo(layer.points[i].x, layer.points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawRawStroke(
    Canvas canvas,
    List<DrawingPoint> points,
    String color,
    double strokeWidth,
  ) {
    if (points.isEmpty) return;
    Color strokeColor = colors.accent;
    try {
      final hex = color.replaceAll('#', '');
      if (hex.length == 6) {
        strokeColor = Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        strokeColor = Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.x, points.first.y);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawSelectionBox(Canvas canvas) {
    final Paint borderPaint = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 240, height: 240),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) => true;
}
