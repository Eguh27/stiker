import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/sticker.dart';
import 'photo_tile.dart';

int galleryColumnsFor(double width) {
  if (width >= AppLayout.desktopBreakpoint) {
    return AppLayout.galleryColumnsDesktop;
  }
  if (width >= AppLayout.tabletBreakpoint) {
    return AppLayout.galleryColumnsTablet;
  }
  return AppLayout.galleryColumnsPhone;
}

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.selected,
    required this.onToggle,
  });

  final List<Sticker> photos;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: galleryColumnsFor(constraints.maxWidth),
            crossAxisSpacing: AppSpacing.s1,
            mainAxisSpacing: AppSpacing.s1,
            childAspectRatio: 1,
          ),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, int index) {
            return PhotoTile(
              photo: photos[index],
              isSelected: selected.contains(index),
              onTap: () => onToggle(index),
            );
          },
        );
      },
    );
  }
}
