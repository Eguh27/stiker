import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/sticker.dart';
import 'sticker_card.dart';

int stickerColumnsFor(double width) {
  if (width >= AppLayout.desktopBreakpoint) {
    return AppLayout.libraryColumnsDesktop;
  }
  if (width >= AppLayout.tabletBreakpoint) {
    return AppLayout.libraryColumnsTablet;
  }
  return AppLayout.libraryColumnsPhone;
}

class StickerGrid extends StatelessWidget {
  const StickerGrid({
    super.key,
    required this.stickers,
    this.onTap,
    this.onLongPress,
    this.selectedIds = const {},
  });

  final List<Sticker> stickers;
  final ValueChanged<Sticker>? onTap;
  final ValueChanged<Sticker>? onLongPress;
  final Set<String> selectedIds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: stickerColumnsFor(constraints.maxWidth),
            crossAxisSpacing: AppSpacing.s3,
            mainAxisSpacing: AppSpacing.s3,
            childAspectRatio: AppLayout.stickerCardAspectRatio,
          ),
          itemCount: stickers.length,
          itemBuilder: (BuildContext context, int index) {
            final Sticker sticker = stickers[index];
            return StickerCard(
              sticker: sticker,
              onTap: onTap,
              onLongPress: onLongPress,
              selected: selectedIds.contains(sticker.id),
            );
          },
        );
      },
    );
  }
}
