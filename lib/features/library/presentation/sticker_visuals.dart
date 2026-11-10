import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sticker_art.dart';
import '../domain/sticker.dart';

/// Petakan enum visual `Sticker` ke token warna/temperature dan bentuk.
/// Dipakai bersama kartu library dan editor pack.
Color stickerColorFor(AppColors colors, StickerColorKind kind) =>
    switch (kind) {
      StickerColorKind.lavender => colors.stickerLavender,
      StickerColorKind.peach => colors.stickerPeach,
      StickerColorKind.mint => colors.stickerMint,
      StickerColorKind.blue => colors.stickerBlue,
      StickerColorKind.yellow => colors.stickerYellow,
      StickerColorKind.pink => colors.stickerPink,
    };

StickerArtShape shapeFor(StickerShape shape) => switch (shape) {
  StickerShape.blob => StickerArtShape.blob,
  StickerShape.cloud => StickerArtShape.cloud,
  StickerShape.flower => StickerArtShape.flower,
  StickerShape.burst => StickerArtShape.burst,
};
