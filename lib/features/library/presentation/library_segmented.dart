import 'package:flutter/material.dart';

import '../../../core/widgets/glass/glass_segmented.dart';

/// Toggle Semua / Inbox. Jumlah wajib datang dari data nyata.
class LibrarySegmented extends StatelessWidget {
  const LibrarySegmented({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.allCount = 0,
    this.newCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int allCount;
  final int newCount;

  @override
  Widget build(BuildContext context) {
    return GlassSegmented<int>(
      value: selectedIndex,
      onChanged: onSelected,
      options: {0: 'Semua $allCount', 1: 'Inbox / Baru $newCount'},
    );
  }
}
