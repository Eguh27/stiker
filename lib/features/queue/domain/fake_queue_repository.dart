import 'queue_item.dart';
import 'queue_repository.dart';

/// Fake antrean untuk shell mock & test; BE mengganti dengan Drift.
class FakeQueueRepository implements QueueRepository {
  FakeQueueRepository({
    List<QueueItem>? items,
    this.autoRmbg = true,
    this.errorToThrow,
  }) : _items = items ?? FakeQueueRepository.localItems;

  FakeQueueRepository.empty() : this(items: const []);

  FakeQueueRepository.failing() : this(errorToThrow: StateError('offline'));

  List<QueueItem> _items;
  final Object? errorToThrow;
  bool autoRmbg;

  static const List<QueueItem> localItems = [
    QueueItem(
      id: 'q1',
      title: 'IMG_2841.webp',
      status: QueueStatus.downloading,
      progress: 68,
      sourceType: QueueSource.galleryPicker,
    ),
    QueueItem(
      id: 'q2',
      title: 'pinterest-pin-42',
      status: QueueStatus.pending,
      progress: 0,
      sourceType: QueueSource.pinterest,
      sourceUrl: 'https://pinterest.com/pin/42',
    ),
    QueueItem(
      id: 'q3',
      title: 'IMG_2838.png',
      status: QueueStatus.failed,
      progress: 36,
      sourceType: QueueSource.directImageLink,
      sourceUrl: 'https://example.com/a.png',
      errorMessage: 'File sumber tidak ditemukan',
    ),
    QueueItem(
      id: 'q4',
      title: 'weekend-pack.zip',
      status: QueueStatus.done,
      progress: 100,
      sourceType: QueueSource.galleryShare,
    ),
  ];

  @override
  Future<List<QueueItem>> fetchQueue() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final Object? error = errorToThrow;
    if (error != null) throw error;
    return List<QueueItem>.of(_items);
  }

  @override
  Stream<List<QueueItem>> watchQueue() async* {
    yield await fetchQueue();
    yield List<QueueItem>.of(_items);
  }

  @override
  Future<void> retryItem(String id) async {
    _items = [
      for (final QueueItem item in _items)
        if (item.id == id)
          item.copyWith(status: QueueStatus.pending, progress: 0)
        else
          item,
    ];
  }

  @override
  Future<bool> fetchAutoRmbg() async => autoRmbg;

  @override
  Future<void> setAutoRmbg(bool enabled) async => autoRmbg = enabled;
}
