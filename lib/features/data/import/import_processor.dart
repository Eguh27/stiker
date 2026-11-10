import 'package:sticker_studio/features/data/app_database.dart';

abstract interface class ImportProcessor {
  Future<void> process(ImportQueueEntry entry);
}
