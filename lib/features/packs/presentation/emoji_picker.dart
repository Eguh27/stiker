import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/pack_limits.dart';

/// Pemilih tag emoji tray (App.tsx `emoji-picker`): maks 3 aktif.
class EmojiTagPicker extends StatelessWidget {
  const EmojiTagPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tag emoji',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              'Maks. ${PackLimits.maxEmojiTags}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.text3),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        ChipTheme(
          data: ChipThemeData(
            shape: const StadiumBorder(),
            side: BorderSide(color: colors.line),
            backgroundColor: colors.surface,
            selectedColor: colors.accentSoft,
            checkmarkColor: colors.accent,
            labelStyle: TextStyle(
              fontFamily: AppTextTokens.bodyFamily,
              fontSize: AppTextTokens.bodySize,
              fontWeight: FontWeight.w700,
              color: colors.text2,
            ),
          ),
          child: Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final String option in PackLimits.emojiTagOptions)
                ChoiceChip(
                  label: Text(option),
                  selected: selected.contains(option),
                  onSelected: (bool _) => onToggle(option),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
