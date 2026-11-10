import 'package:flutter/material.dart';

/// Spasi & ukuran dari tokens.json (`spacing`, `radius`, `constraints`)
/// dan index.css (`.top-bar 96px`, `.bottom-nav 80px`).
class AppSpacing {
  const AppSpacing._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
}

class AppRadius {
  const AppRadius._();
  static const double cardValue = 20;
  static const double controlValue = 14;
  static const double pillValue = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(cardValue));
  static const BorderRadius control = BorderRadius.all(
    Radius.circular(controlValue),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(pillValue));
}

class AppLayout {
  const AppLayout._();
  static const double topBarHeight = 96;
  static const double bottomNavHeight = 80;
  static const double iconButtonSize = 48;
  static const double stateChipMinHeight = 36;
  static const double primaryButtonMinHeight = 48;
  static const double segmentedMinHeight = 42;
  static const double phoneFrameWidth = 412;
  static const double phoneFrameHeight = 915;
  static const double iconGridSize = 24;
  static const double stickerCardAspectRatio = 0.85;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1000;
  // Pack editor (tokens.json constraints.whatsapp: tray 96×96, 3..30).
  static const double trayIconPx = 96;
  static const double trayBadgeSize = 28;
  static const double editBadgeSize = 17;
  static const double smallBadgeIconSize = 14;
  static const double validationIconSize = 16;
  static const double whatsappMarkSize = 22;
  static const double dashedSegmentLength = 6;
  static const double dashedGapLength = 4;
  static const double dragFeedbackIcon = 48;
  static const int packEditorColumns = 4;
  static const int libraryColumnsPhone = 2;
  static const int libraryColumnsTablet = 3;
  static const int libraryColumnsDesktop = 4;
  static const int galleryColumnsPhone = 3;
  static const int galleryColumnsTablet = 4;
  static const int galleryColumnsDesktop = 6;
}

class AppShadows {
  const AppShadows._();
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A423730), blurRadius: 40, offset: Offset(0, 18)),
    BoxShadow(color: Color(0x0A423730), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> float = [
    BoxShadow(color: Color(0x3329221F), blurRadius: 64, offset: Offset(0, 24)),
  ];
}

/// Tipografi semantik dari tokens.json (`typography` + index.css).
class AppTextTokens {
  const AppTextTokens._();
  static const String bodyFamily = 'Inter';
  static const String headingFamily = 'Montserrat';
  static const double eyebrowSize = 9;
  static const FontWeight eyebrowWeight = FontWeight.w700;
  static const double eyebrowLetterSpacing = 0.99;
  static const double headingLetterSpacing = -0.77;
  static const double titleSize = 22;
  static const double bodySize = 12;
  static const double navLabelSize = 9;
}
