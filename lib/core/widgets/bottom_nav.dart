import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';

/// BottomNav kaca melayang: 4 tab, tab aktif berupa lingkaran gradasi oranye.
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s5, 0, AppSpacing.s5, AppSpacing.s3),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: AppRadius.pill, boxShadow: AppShadows.glass),
          child: ClipRRect(
            borderRadius: AppRadius.pill,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: AppLayout.bottomNavHeight - AppSpacing.s3,
                decoration: BoxDecoration(
                  color: colors.glassFill,
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < _labels.length; i++)
                      Expanded(child: _item(i, colors)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, AppColors colors) {
    final bool selected = index == currentIndex;
    return InkWell(
      borderRadius: AppRadius.pill,
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: selected ? AppGradients.accent : null,
              boxShadow: selected ? AppShadows.glow : null,
            ),
            child: Center(
              child: AppIcon(_icons[index], color: selected ? Colors.white : colors.text2),
            ),
          ),
          Text(
            _labels[index],
            style: TextStyle(
              fontSize: AppTextTokens.navLabelSize,
              fontWeight: FontWeight.w700,
              color: selected ? colors.accent : colors.text2,
            ),
          ),
        ],
      ),
    );
  }
}
