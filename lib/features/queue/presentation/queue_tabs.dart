import 'package:flutter/material.dart';

import '../../../core/widgets/glass/glass_segmented.dart';

/// Tab Dalam proses / Baru Diimpor (Inbox) untuk Queue Monitor.
class QueueTabs extends StatelessWidget {
  const QueueTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.activeCount,
    required this.doneCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int activeCount;
  final int doneCount;

  @override
  Widget build(BuildContext context) {
    return GlassSegmented<int>(
      value: selectedIndex,
      onChanged: onSelected,
      options: {0: 'Dalam proses $activeCount', 1: 'Baru Diimpor $doneCount'},
    );
  }
}
