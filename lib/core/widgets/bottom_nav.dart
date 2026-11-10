import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';

/// BottomNav 4 tab dari screen-map: Library, Antrean, Pack, Setelan.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<AppIconName> _icons = [
    AppIconName.grid,
    AppIconName.queue,
    AppIconName.pack,
    AppIconName.settings,
  ];

  static const List<String> _labels = ['Library', 'Antrean', 'Pack', 'Setelan'];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SizedBox(
      height: AppLayout.bottomNavHeight,
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          for (int i = 0; i < _labels.length; i++)
            NavigationDestination(
              icon: AppIcon(_icons[i], color: colors.text3),
              selectedIcon: AppIcon(_icons[i], color: colors.accent),
              label: _labels[i],
            ),
        ],
      ),
    );
  }
}
