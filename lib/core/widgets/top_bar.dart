import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';
import 'glass/glass_icon_button.dart';
import 'theme_toggle_button.dart';

/// TopBar kaca: eyebrow + judul + back/aksi. Toggle tema tampil di semua layar.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.title,
    this.eyebrow = 'Workspace lokal',
    this.onBack,
    this.leading,
    this.actions,
    this.showThemeToggle = true,
  });

  final String title;
  final String eyebrow;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showThemeToggle;

  @override
  Size get preferredSize => const Size.fromHeight(AppLayout.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: AppLayout.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s6,
          AppSpacing.s5,
          AppSpacing.s2,
        ),
        child: Row(
          children: [
            if (onBack != null) ...[
              GlassIconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                icon: AppIcon(AppIconName.back, color: colors.text),
              ),
              const SizedBox(width: AppSpacing.s3),
            ],
            if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.s2)],
            Expanded(child: _titles(textTheme, colors)),
            ...?actions,
            if (showThemeToggle) ...[
              const SizedBox(width: AppSpacing.s2),
              const ThemeToggleButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _titles(TextTheme textTheme, AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: textTheme.labelSmall),
        Text(
          title,
          style: textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
