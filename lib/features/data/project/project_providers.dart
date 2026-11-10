import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';

import 'project_repository.dart';
import 'project_repository_impl.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ProjectRepositoryImpl(database);
});
