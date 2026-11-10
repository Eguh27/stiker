import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pack/drift_pack_editor_adapter.dart';
import '../../queue/data/app_database_provider.dart';
import '../domain/pack_repository.dart';
import '../domain/sticker_pack.dart';

/// Repository pack editor yang terhubung ke SQLite (Drift).
/// Untuk testing, provider ini dapat di-override dengan [FakePackRepository].
final packRepositoryProvider = Provider<PackEditorRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftPackEditorAdapter(database);
});

final packListProvider = FutureProvider<List<StickerPack>>((ref) async {
  return ref.watch(packRepositoryProvider).fetchPacks();
});
