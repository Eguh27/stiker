import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/pack_limits.dart';

/// Field label editor (App.tsx `field-label`): label + input + counter.
class PackEditField extends StatelessWidget {
  const PackEditField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle? inputStyle = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: colors.text);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: colors.text2),
        ),
        const SizedBox(height: AppSpacing.s1),
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          maxLength: PackLimits.textMaxLength,
          style: inputStyle,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? colors.surface : colors.surfaceMuted,
            counterText: '',
            suffixText: '${controller.text.length}/${PackLimits.textMaxLength}',
            suffixStyle: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.text3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.control,
              borderSide: BorderSide(color: colors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.control,
              borderSide: BorderSide(color: colors.accent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.control,
              borderSide: BorderSide(color: colors.line),
            ),
          ),
        ),
      ],
    );
  }
}
