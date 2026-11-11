import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/url_import_queue_store.dart';
import 'package:sticker_studio/features/data/import/url_import_runner.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';
import 'package:sticker_studio/src/rust/api/errors.dart';

import 'support/import_workspace.dart';

class FakeResolver {
  FakeResolver({this.onResolve});

  final Future<String> Function({
    required String url,
    required String outputPath,
    required String extractorsManifestPath,
  })?
  onResolve;
  final List<String> urls = [];

  Future<String> call({
    required String url,
    required String outputPath,
    required String extractorsManifestPath,
  }) async {
    urls.add(url);
    final resolver = onResolve;
    if (resolver != null) {
      return resolver(
        url: url,
        outputPath: outputPath,
        extractorsManifestPath: extractorsManifestPath,
      );
    }
    await File(outputPath).writeAsBytes([1, 2, 3]);
    return outputPath;
  }
}

void main() {
  late ImportWorkspace workspace;
  late UrlImportQueueStore urlStore;

  setUp(() async {
    workspace = await ImportWorkspace.create();
    urlStore = UrlImportQueueStore(workspace.database);
  });
  tearDown(() async => workspace.dispose());

  UrlImportRunner createRunner(FakeResolver resolver) {
    return UrlImportRunner(
      store: urlStore,
      fileSystemManager: workspace.fileSystemManager,
      extractorsManifestPath: workspace.fileSystemManager
          .registryFile(RegistryEngine.extractorsManifestFileName)
          .path,
      resolver: resolver.call,
      staleAfter: Duration.zero,
    );
  }

  test('unduhan sukses mengisi local_input_path dan PENDING', () async {
    await urlStore.insertEntry(
      id: 'download-1',
      sourceUrl: 'https://example.com/photo.jpg',
      sourceType: SourceType.directImageLink,
      autoRmbg: false,
    );
    final resolver = FakeResolver();

    expect(await createRunner(resolver).processPending(), 1);

    final row = (await workspace.fetchQueueRows()).single;
    expect(resolver.urls, ['https://example.com/photo.jpg']);
    expect(row.status, ImportStatus.pending);
    expect(row.localInputPath, endsWith('download-1.jpg'));
    expect(await File(row.localInputPath!).readAsBytes(), [1, 2, 3]);
  });

  test('error resolve dicatat FAILED dengan pesan jelas', () async {
    await urlStore.insertEntry(
      id: 'download-2',
      sourceUrl: 'https://pinterest.com/pin/2',
      sourceType: SourceType.pinterest,
      autoRmbg: false,
    );
    final resolver = FakeResolver(
      onResolve:
          ({
            required url,
            required outputPath,
            required extractorsManifestPath,
          }) async {
            await File(outputPath).writeAsBytes([9]);
            throw ResolveError.needsLogin;
          },
    );

    expect(await createRunner(resolver).processPending(), 1);

    final row = (await workspace.fetchQueueRows()).single;
    final output = workspace.fileSystemManager.originalFile('download-2.jpg');
    expect(row.status, ImportStatus.failed);
    expect(row.errorMessage, 'Butuh login ke situs sumber');
    expect(await output.exists(), isFalse);
  });

  test('situs yang memblokir dicatat FAILED dengan pesan blokir', () async {
    await urlStore.insertEntry(
      id: 'download-blocked',
      sourceUrl: 'https://pinterest.com/pin/3',
      sourceType: SourceType.pinterest,
      autoRmbg: false,
    );
    final resolver = FakeResolver(
      onResolve:
          ({
            required url,
            required outputPath,
            required extractorsManifestPath,
          }) async {
            throw ResolveError.blocked;
          },
    );

    expect(await createRunner(resolver).processPending(), 1);

    final row = (await workspace.fetchQueueRows()).single;
    expect(row.status, ImportStatus.failed);
    expect(row.errorMessage, 'Situs sumber memblokir unduhan');
  });

  test('resolver tanpa output dianggap gagal, bukan sukses palsu', () async {
    await urlStore.insertEntry(
      id: 'download-3',
      sourceUrl: 'https://example.com/empty.png',
      sourceType: SourceType.directImageLink,
      autoRmbg: false,
    );
    final resolver = FakeResolver(
      onResolve:
          ({
            required url,
            required outputPath,
            required extractorsManifestPath,
          }) async {
            return outputPath;
          },
    );

    expect(await createRunner(resolver).processPending(), 1);

    final row = (await workspace.fetchQueueRows()).single;
    expect(row.status, ImportStatus.failed);
    expect(row.errorMessage, 'Gambar tidak ditemukan di tautan');
  });

  test('baris DOWNLOADING yang terputus diproses ulang', () async {
    await urlStore.insertEntry(
      id: 'download-4',
      sourceUrl: 'https://example.com/resume.webp',
      sourceType: SourceType.directImageLink,
      autoRmbg: false,
    );
    await urlStore.markDownloading('download-4');

    expect(await createRunner(FakeResolver()).processPending(), 1);

    final row = (await workspace.fetchQueueRows()).single;
    expect(row.status, ImportStatus.pending);
    expect(row.localInputPath, endsWith('download-4.webp'));
  });
}
