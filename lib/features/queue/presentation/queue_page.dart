import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../../library/presentation/sticker_providers.dart';
import '../domain/queue_item.dart';
import 'auto_rmbg_toggle.dart';
import 'privacy_note.dart';
import 'queue_actions.dart';
import 'queue_card.dart';
import 'queue_providers.dart';
import 'queue_tabs.dart';

/// Queue Monitor nyata: Drift import_queue via stream, Retry per item.
class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_processQueue);
  }

  void _processQueue() {
    ref
        .read(foregroundImportRunnerProvider)
        .processAllPending(
          onStickerAdded: () => ref.invalidate(stickerListProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(queueStreamProvider, (prev, next) {
      final hasPending =
          next.value?.any((item) => item.status == QueueStatus.pending) ??
          false;
      if (hasPending) {
        _processQueue();
      }
    });

    final AsyncValue<List<QueueItem>> items = ref.watch(queueStreamProvider);
    final bool autoRmbg = ref.watch(autoRmbgProvider);
    return Scaffold(
      appBar: const TopBar(title: 'Queue Monitor'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s2,
          AppSpacing.s5,
          AppSpacing.s5,
        ),
        children: [
          AutoRmbgToggleCard(
            enabled: autoRmbg,
            onChanged: (bool value) =>
                ref.read(autoRmbgProvider.notifier).setEnabled(value),
          ),
          const SizedBox(height: AppSpacing.s5),
          ..._tabs(items),
          const SizedBox(height: AppSpacing.s3),
          ..._body(ref, items),
          const PrivacyNote(),
        ],
      ),
    );
  }

  List<Widget> _tabs(AsyncValue<List<QueueItem>> items) {
    final List<QueueItem> list = items.maybeWhen(
      data: (List<QueueItem> v) => v,
      orElse: () => const [],
    );
    final int active = list.where(isActiveItem).length;
    final int done = list.where(isDoneItem).length;
    return [
      QueueTabs(
        selectedIndex: _tab,
        onSelected: (int value) => setState(() => _tab = value),
        activeCount: active,
        doneCount: done,
      ),
    ];
  }

  List<Widget> _body(WidgetRef ref, AsyncValue<List<QueueItem>> value) {
    return value.when(
      data: (List<QueueItem> all) {
        final List<QueueItem> items = _tab == 0
            ? all.where(isActiveItem).toList()
            : all.where(isDoneItem).toList();
        if (items.isEmpty) {
          return [
            EmptyState(
              title: _tab == 0 ? 'Belum ada antrean' : 'Belum ada yang baru',
              message:
                  'Mulai dari galeri atau impor beberapa gambar sekaligus.',
            ),
          ];
        }
        return [
          for (final QueueItem item in items)
            QueueCard(
              item: item,
              onRetry: () async {
                await ref.read(queueRepositoryProvider).retryItem(item.id);
                ref.invalidate(queueStreamProvider);
                _processQueue();
              },
              onTap: isDoneItem(item)
                  ? () => openQueueItemEditor(context, item)
                  : null,
              onDelete: isDoneItem(item)
                  ? () => deleteQueueHistory(context, ref, item)
                  : null,
            ),
        ];
      },
      loading: () => [const LoadingState(title: 'Menyiapkan antrean')],
      error: (Object error, StackTrace stack) => [
        ErrorState(
          title: 'Gagal memuat antrean',
          message: 'File lokal mungkin dipindahkan. Periksa lalu coba lagi.',
          onRetry: () => ref.invalidate(queueStreamProvider),
        ),
      ],
    );
  }
}
