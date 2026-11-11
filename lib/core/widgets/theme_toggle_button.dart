import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/settings_providers.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';
import 'glass/glass_icon_button.dart';

/// Tombol bulat kaca untuk ganti tema terang/gelap.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors colors = context.colors;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassIconButton(
      tooltip: isDark ? 'Mode terang' : 'Mode gelap',
      icon: AppIcon(isDark ? AppIconName.sun : AppIconName.moon, color: colors.text),
      onPressed: () => ref.read(themeModeProvider.notifier).setDark(!isDark),
    );
  }
}
