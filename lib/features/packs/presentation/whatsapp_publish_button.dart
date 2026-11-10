import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tombol `Tambah ke WhatsApp` (App.tsx `whatsapp-button`) memakai token
/// `whatsapp`; dinonaktifkan saat pack belum memenuhi 3–30 stiker.
class WhatsAppPublishButton extends StatelessWidget {
  const WhatsAppPublishButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style:
          FilledButton.styleFrom(
            backgroundColor: colors.whatsapp,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                  ? colors.text3
                  : colors.onWhatsapp,
            ),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppLayout.whatsappMarkSize,
            height: AppLayout.whatsappMarkSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.onWhatsapp),
            ),
            alignment: Alignment.center,
            child: Text(
              'W',
              style: TextStyle(
                fontFamily: AppTextTokens.headingFamily,
                fontSize: AppTextTokens.bodySize,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          const Text('Tambah ke WhatsApp'),
        ],
      ),
    );
  }
}
