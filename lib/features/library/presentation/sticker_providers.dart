import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/data/sticker/drift_sticker_repository.dart';
import 'package:sticker_studio/features/data/sticker/sticker_import_service.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';

import '../domain/sticker.dart';
import '../domain/sticker_repository.dart';

final driftStickerRepositoryProvider = Provider<DriftStickerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftStickerRepository(db);
});

final stickerRepositoryProvider = Provider<StickerRepository>((ref) {
  return ref.watch(driftStickerRepositoryProvider);
});

final stickerImportServiceProvider = Provider<StickerImportService>((ref) {
  final repo = ref.watch(driftStickerRepositoryProvider);
  return StickerImportService(repo);
});

final stickerListProvider = FutureProvider<List<Sticker>>((ref) async {
  final StickerRepository repository = ref.watch(stickerRepositoryProvider);
  return repository.fetchStickers();
});
