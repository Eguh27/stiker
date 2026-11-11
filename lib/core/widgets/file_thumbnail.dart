import 'dart:io';

import 'package:flutter/material.dart';

/// Pratinjau gambar dari file lokal; [fallback] tampil bila file tidak ada
/// atau gagal didecode. Decode dikecilkan lewat [cacheSize] agar hemat memori.
class FileThumbnail extends StatelessWidget {
  const FileThumbnail({
    super.key,
    required this.path,
    required this.fallback,
    this.size = 56,
    this.cacheSize = 256,
  });

  final String? path;
  final Widget fallback;
  final double size;
  final int cacheSize;

  @override
  Widget build(BuildContext context) {
    final String? filePath = path;
    final bool hasFile = filePath != null && File(filePath).existsSync();
    return SizedBox(
      width: size,
      height: size,
      child: hasFile
          ? Image.file(
              File(filePath),
              fit: BoxFit.contain,
              cacheWidth: cacheSize,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}
