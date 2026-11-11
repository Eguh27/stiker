import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Tombol ikon bulat kaca (settings, tema, dll). Target sentuh 44px.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.glassFill,
        shape: CircleBorder(side: BorderSide(color: c.glassBorder)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(width: size, height: size, child: Center(child: icon)),
        ),
      ),
    );
  }
}
