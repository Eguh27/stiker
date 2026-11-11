import 'package:flutter/material.dart';

/// Gradasi vibrant yang mengalir di dalam kaca (pink -> magenta -> oranye).
class AppGradients {
  const AppGradients._();

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A2E), Color(0xFFFF3D00)],
  );

  static const LinearGradient vivid = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xEBD93F6A), Color(0xEB9E2A82), Color(0xEBE64A19)],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient sheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
  );
}
