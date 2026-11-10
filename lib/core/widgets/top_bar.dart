import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';

/// TopBar dari screen-map: eyebrow + title + back/action, tinggi 96.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.title,
    this.eyebrow = 'Workspace lokal',
    this.onBack,
    this.leading,
    this.actions,
  });

  final String title;
  final String eyebrow;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppLayout.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      height: AppLayout.topBarHeight,
      padding: const EdgeInsets.only(
        top: AppSpacing.s6,
        left: AppSpacing.s5,
        right: AppSpacing.s5,
        bottom: AppSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.line)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              tooltip: 'Kembali',
              icon: AppIcon(AppIconName.back, color: colors.text),
            ),
            const SizedBox(width: AppSpacing.s2),
          ],
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s2),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.text3,
                    letterSpacing: AppTextTokens.eyebrowLetterSpacing,
                  ),
                ),
                Text(
                  title,
                  style: textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (actions != null)
            Row(mainAxisSize: MainAxisSize.min, children: actions!),
        ],
      ),
    );
  }
}
