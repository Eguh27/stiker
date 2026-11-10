import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/sticker_art.dart';
import '../../library/domain/sticker.dart';
import '../../library/presentation/sticker_visuals.dart';
import '../domain/pack_limits.dart';

/// Header editor: tray icon 96×96 + badge edit (App.tsx `pack-header-card`).
class PackHeaderCard extends StatelessWidget {
  const PackHeaderCard({
    super.key,
    required this.name,
    required this.traySticker,
    required this.isPublishable,
  });

  final String name;
  final Sticker? traySticker;
  final bool isPublishable;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accentSoft, colors.surface],
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          _TrayIcon(traySticker: traySticker),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Tanpa nama' : name,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  'Tray icon · ${AppLayout.trayIconPx.round()} × '
                  '${AppLayout.trayIconPx.round()} px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.s2),
                _StatusLabel(colors: colors, isPublishable: isPublishable),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrayIcon extends StatelessWidget {
  const _TrayIcon({required this.traySticker});

  final Sticker? traySticker;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: AppLayout.trayIconPx,
          height: AppLayout.trayIconPx,
          decoration: BoxDecoration(
            color: colors.surfaceSolid,
            borderRadius: AppRadius.control,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: traySticker == null
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.s5),
                    child: AppIcon(
                      AppIconName.sticker,
                      size: AppLayout.iconGridSize,
                      color: colors.text3,
                    ),
                  )
                : (traySticker!.filePath != null &&
                          File(traySticker!.filePath!).existsSync()
                      ? Image.file(
                          File(traySticker!.filePath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              StickerArt(
                                color: stickerColorFor(
                                  colors,
                                  traySticker!.colorKind,
                                ),
                                label: traySticker!.label,
                                shape: shapeFor(traySticker!.shape),
                              ),
                        )
                      : StickerArt(
                          color: stickerColorFor(
                            colors,
                            traySticker!.colorKind,
                          ),
                          label: traySticker!.label,
                          shape: shapeFor(traySticker!.shape),
                        )),
          ),
        ),
        Positioned(
          right: -AppSpacing.s1,
          bottom: -AppSpacing.s1,
          child: Container(
            width: AppLayout.trayBadgeSize,
            height: AppLayout.trayBadgeSize,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                AppIconName.edit,
                size: AppLayout.smallBadgeIconSize,
                color: colors.accentText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.colors, required this.isPublishable});

  final AppColors colors;
  final bool isPublishable;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.labelSmall!
        .copyWith(color: isPublishable ? colors.success : colors.danger);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          isPublishable ? AppIconName.check : AppIconName.close,
          size: AppLayout.smallBadgeIconSize,
          color: style.color,
        ),
        const SizedBox(width: AppSpacing.s1),
        Text(
          isPublishable
              ? 'Siap diterbitkan'
              : 'Butuh ${PackLimits.minStickers} stiker',
          style: style,
        ),
      ],
    );
  }
}
