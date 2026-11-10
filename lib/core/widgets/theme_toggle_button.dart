import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/settings_providers.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Tombol toggle tema terang/gelap (Bug 3: Theme button).
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return IconButton(
      tooltip: isDark ? 'Mode terang' : 'Mode gelap',
      icon: AppIcon(
        isDark ? AppIconName.sun : AppIconName.moon,
        color: colors.text,
      ),
      onPressed: () {
        ref.read(themeModeProvider.notifier).setDark(!isDark);
      },
    );
  }
}
