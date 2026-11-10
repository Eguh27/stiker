import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Wajib diimpor agar entrypoint WorkManager ikut tertaut di build AOT.
// ignore: unused_import
import 'background_import.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/bottom_nav.dart';
import 'features/data/app_database.dart';
import 'features/data/file_system_manager.dart';
import 'features/data/registry/registry_bootstrap.dart';
import 'features/library/presentation/library_page.dart';
import 'features/packs/presentation/packs_page.dart';
import 'features/queue/data/app_database_provider.dart';
import 'features/queue/presentation/queue_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'features/settings/presentation/settings_providers.dart';
import 'src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await RustLib.init();
  } catch (e) {
    debugPrint('RustLib.init error: $e');
  }

  AppDatabase? db;
  try {
    final fs = await FileSystemManager.initialize();
    await RegistryBootstrap.ensureExtractorsManifest(fileSystemManager: fs);
    db = AppDatabase(openAppDatabase(fs.databaseFile));
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [if (db != null) appDatabaseProvider.overrideWithValue(db)],
      child: const StickerStudioApp(),
    ),
  );
}

class StickerStudioApp extends ConsumerWidget {
  const StickerStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Sticker Studio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: const AppShell(),
    );
  }
}

/// Alias kompatibilitas untuk `integration_test/simple_test.dart` lama.
class MyApp extends StickerStudioApp {
  const MyApp({super.key});
}

/// Shell 4 tab: Library, Antrean, Pack, Setelan (screen-map BottomNav).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    LibraryPage(),
    QueuePage(),
    PacksPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
