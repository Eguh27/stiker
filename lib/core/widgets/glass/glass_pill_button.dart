import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_spacing.dart';

enum GlassPillStyle { glass, solid, accent }

/// Tombol kapsul: kaca, putih solid (teks gelap), atau gradasi oranye-merah.
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = GlassPillStyle.glass,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final GlassPillStyle style;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color textColor = switch (style) {
      GlassPillStyle.glass => c.text,
      GlassPillStyle.solid => Colors.black87,
      GlassPillStyle.accent => Colors.white,
    };
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill,
          color: switch (style) {
            GlassPillStyle.glass => c.glassFill,
            GlassPillStyle.solid => Colors.white,
            GlassPillStyle.accent => null,
          },
          gradient: style == GlassPillStyle.accent ? AppGradients.accent : null,
          border: Border.all(color: c.glassBorder),
          boxShadow: style == GlassPillStyle.accent ? AppShadows.glow : null,
        ),
        child: InkWell(
          borderRadius: AppRadius.pill,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppLayout.iconButtonSize),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.s2)],
                  Text(
                    label,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
