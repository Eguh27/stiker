import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';

class ImportOption extends StatelessWidget {
  const ImportOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.onTap,
  });

  final AppIconName icon;
  final String title;
  final String subtitle;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: AppLayout.iconButtonSize,
        height: AppLayout.iconButtonSize,
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: AppRadius.control,
        ),
        child: AppIcon(icon, color: colors.accent),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(subtitle),
      trailing: AppIcon(AppIconName.chevron, color: colors.text3),
      onTap: onTap,
    );
  }
}
