import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Ikon grid 24 dari `design/figma-export/src/App.tsx` (stroke 1.8).
enum AppIconName {
  grid,
  queue,
  pack,
  settings,
  back,
  plus,
  refresh,
  sticker,
  more,
  close,
  check,
  image,
  folder,
  sun,
  moon,
  layers,
  cloud,
  edit,
  text,
  brush,
  undo,
  redo,
  download,
  chevron,
  link,
  delete,
}

extension AppIconNameData on AppIconName {
  IconData get data {
    return switch (this) {
      AppIconName.grid => Icons.grid_view_rounded,
      AppIconName.queue => Icons.format_list_bulleted_rounded,
      AppIconName.pack => Icons.layers_rounded,
      AppIconName.settings => Icons.settings_rounded,
      AppIconName.back => Icons.chevron_left_rounded,
      AppIconName.plus => Icons.add_rounded,
      AppIconName.refresh => Icons.refresh_rounded,
      AppIconName.sticker => Icons.emoji_emotions_rounded,
      AppIconName.more => Icons.more_horiz_rounded,
      AppIconName.close => Icons.close_rounded,
      AppIconName.check => Icons.check_rounded,
      AppIconName.image => Icons.image_rounded,
      AppIconName.folder => Icons.folder_rounded,
      AppIconName.sun => Icons.wb_sunny_rounded,
      AppIconName.moon => Icons.nightlight_round_rounded,
      AppIconName.layers => Icons.layers_rounded,
      AppIconName.cloud => Icons.cloud_upload_rounded,
      AppIconName.edit => Icons.edit_rounded,
      AppIconName.text => Icons.text_fields_rounded,
      AppIconName.brush => Icons.brush_rounded,
      AppIconName.undo => Icons.undo_rounded,
      AppIconName.redo => Icons.redo_rounded,
      AppIconName.download => Icons.download_rounded,
      AppIconName.chevron => Icons.chevron_right_rounded,
      AppIconName.link => Icons.link_rounded,
      AppIconName.delete => Icons.delete_outline_rounded,
    };
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = AppLayout.iconGridSize,
    this.color,
    this.semanticsLabel,
  });

  final AppIconName name;
  final double size;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      name.data,
      size: size,
      color: color,
      semanticLabel: semanticsLabel,
    );
  }
}
