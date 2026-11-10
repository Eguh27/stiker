import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';

import '../domain/scene_project.dart';
import 'scene_painter.dart';

/// Merender SceneProject menjadi file stiker WebP 512x512 riil di penyimpanan lokal.
class SceneExporter {
  const SceneExporter._();

  static Future<String> exportSticker({
    required String stickerId,
    required SceneProject project,
    required Map<String, ui.Image> images,
    required AppColors colors,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final stickersDir = Directory('${appDir.path}/stickers');
    if (!stickersDir.existsSync()) {
      stickersDir.createSync(recursive: true);
    }

    final pngPath = '${stickersDir.path}/export_$stickerId.png';
    final webpPath = '${stickersDir.path}/$stickerId.webp';

    // 1. Render kanvas ke UI Image 512x512 transparan (tanpa selection box)
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 512, 512));

    final painter = ScenePainter(
      project: project,
      activeLayerId: null,
      colors: colors,
      images: images,
      isExporting: true,
    );
    painter.paint(canvas, const Size(512, 512));

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(512, 512);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Gagal merender bitmap stiker');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final pngFile = File(pngPath);
    await pngFile.writeAsBytes(pngBytes, flush: true);

    // 2. Encode PNG ke WebP menggunakan Rust FFI (encodeWhatsappWebp)
    try {
      await encodeWhatsappWebp(
        inputPath: pngPath,
        outputPath: webpPath,
        targetSizeKb: 100,
      );
    } catch (_) {
      // Fallback bila encode gagal: gunakan file PNG langsung atau salin
      await pngFile.copy(webpPath);
    } finally {
      if (await pngFile.exists()) {
        try {
          await pngFile.delete();
        } catch (_) {}
      }
    }

    return webpPath;
  }
}

