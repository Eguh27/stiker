import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/state_panels.dart';
import 'package:sticker_studio/core/widgets/sticker_art.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart';
import 'package:sticker_studio/features/library/presentation/sticker_providers.dart';
import 'package:sticker_studio/features/library/presentation/sticker_visuals.dart';

/// Sheet pemilih stiker dari library untuk ditambahkan ke pack.
class StickerPickerSheet extends ConsumerStatefulWidget {
  const StickerPickerSheet({
    super.key,
    required this.alreadySelectedIds,
    required this.maxSelectable,
  });

  final Set<String> alreadySelectedIds;
  final int maxSelectable;

  static Future<List<Sticker>?> show({
    required BuildContext context,
    required Set<String> alreadySelectedIds,
    required int maxSelectable,
  }) {
    return showModalBottomSheet<List<Sticker>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: StickerPickerSheet(
          alreadySelectedIds: alreadySelectedIds,
          maxSelectable: maxSelectable,
        ),
      ),
    );
  }

  @override
  ConsumerState<StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends ConsumerState<StickerPickerSheet> {
  final Set<String> _selectedIds = {};
  final Map<String, Sticker> _stickerMap = {};

  void _toggle(Sticker sticker) {
    if (widget.alreadySelectedIds.contains(sticker.id)) return;
    setState(() {
      if (_selectedIds.contains(sticker.id)) {
        _selectedIds.remove(sticker.id);
      } else {
        if (_selectedIds.length < widget.maxSelectable) {
          _selectedIds.add(sticker.id);
          _stickerMap[sticker.id] = sticker;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stickersAsync = ref.watch(stickerListProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.s3),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colors.lineStrong,
            borderRadius: AppRadius.pill,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Stiker',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${_selectedIds.length}/${widget.maxSelectable}',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: colors.accent),
              ),
            ],
          ),
        ),
        Expanded(
          child: stickersAsync.when(
            data: (stickers) {
              if (stickers.isEmpty) {
                return const EmptyState(
                  title: 'Belum ada stiker',
                  message: 'Impor stiker di tab Library terlebih dahulu.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.s4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.s3,
                  crossAxisSpacing: AppSpacing.s3,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final s = stickers[index];
                  final isAlreadyInPack = widget.alreadySelectedIds.contains(
                    s.id,
                  );
                  final isChosen = _selectedIds.contains(s.id);

                  return GestureDetector(
                    onTap: () => _toggle(s),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.control,
                        border: Border.all(
                          color: isChosen ? colors.accent : colors.line,
                          width: isChosen ? 2.5 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (s.filePath != null &&
                              File(s.filePath!).existsSync())
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.s2),
                              child: Image.file(
                                File(s.filePath!),
                                fit: BoxFit.contain,
                              ),
                            )
                          else
                            StickerArt(
                              color: stickerColorFor(colors, s.colorKind),
                              label: s.label,
                              shape: shapeFor(s.shape),
                              small: true,
                            ),
                          if (isAlreadyInPack)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: AppRadius.control,
                              ),
                              child: const Center(
                                child: Text(
                                  'Sudah ada',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            )
                          else if (isChosen)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: colors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const LoadingState(title: 'Memuat stiker library'),
            error: (error, stackTrace) => const ErrorState(
              title: 'Gagal memuat stiker',
              message: 'Tidak dapat membaca stiker dari database.',
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        final chosen = _selectedIds
                            .map((id) => _stickerMap[id]!)
                            .toList();
                        Navigator.of(context).pop(chosen);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.pill,
                  ),
                ),
                child: Text('Tambahkan (${_selectedIds.length} stiker)'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
