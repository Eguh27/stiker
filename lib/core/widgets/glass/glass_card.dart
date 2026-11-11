import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_spacing.dart';

/// Kartu kaca: blur kuat, border tipis semi-transparan, bayangan lembut.
/// `vivid` mengisi kaca dengan gradasi pink-magenta-oranye (teks otomatis putih).
/// Matikan `blur` untuk item di grid/list panjang agar scroll tetap ringan.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s5),
    this.margin,
    this.radius = AppRadius.card,
    this.blur = true,
    this.vivid = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius radius;
  final bool blur;
  final bool vivid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    Widget body = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: vivid ? null : c.glassFill,
        gradient: vivid ? AppGradients.vivid : null,
        border: Border.all(color: c.glassBorder),
      ),
      foregroundDecoration: vivid
          ? BoxDecoration(borderRadius: radius, gradient: AppGradients.sheen)
          : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: _tinted(child)),
        ),
      ),
    );
    if (blur) {
      body = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: body,
      );
    }
    final Widget card = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.glass),
      child: ClipRRect(borderRadius: radius, child: body),
    );
    return margin == null ? card : Padding(padding: margin!, child: card);
  }

  Widget _tinted(Widget content) {
    if (!vivid) return content;
    return IconTheme.merge(
      data: const IconThemeData(color: Colors.white),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: content,
      ),
    );
  }
}
