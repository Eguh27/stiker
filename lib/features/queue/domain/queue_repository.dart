import 'queue_item.dart';

/// Interface antrean. `run_rmbg_inference` (ffi.md) tidak dipanggil dari FE;
/// presentation hanya lewat interface ini.
abstract class QueueRepository {
  Future<List<QueueItem>> fetchQueue();
  Stream<List<QueueItem>> watchQueue();
  Future<void> retryItem(String id);
  Future<int> deleteItems(Iterable<String> ids);
  Future<bool> fetchAutoRmbg();
  Future<void> setAutoRmbg(bool enabled);
}
