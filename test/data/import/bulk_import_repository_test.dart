import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

import 'support/import_workspace.dart';

void main() {
  late ImportWorkspace workspace;

  setUp(() async => workspace = await ImportWorkspace.create());
  tearDown(() async => workspace.dispose());

  test('menyalin input ke originals dan membuat antrean PENDING', () async {
    final source = await workspace.createInput('photo.jpg', bytes: [9, 8, 7]);

    final ids = await workspace.repository.enqueueFiles(
      inputPaths: [source.path],
      sourceType: SourceType.galleryPicker,
    );

    final rows = await workspace.fetchQueueRows();
    expect(ids, hasLength(1));
    expect(ids.single, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(rows, hasLength(1));
    expect(rows.single.id, ids.single);
    expect(rows.single.status, ImportStatus.pending);
    expect(rows.single.sourceType, SourceType.galleryPicker);
    expect(rows.single.progress, 0);
    expect(rows.single.autoRmbg, isFalse);

    final original = File(rows.single.localInputPath!);
    expect(original.existsSync(), isTrue);
    expect(
      original.parent.path,
      workspace.fileSystemManager.originalsDirectory.path,
    );
    expect(original.path, endsWith('${ids.single}.jpg'));
    expect(await original.readAsBytes(), [9, 8, 7]);
  });

  test('file gagal disalin menjadi FAILED tanpa menghentikan batch', () async {
    final valid = await workspace.createInput('valid.png');

    final ids = await workspace.repository.enqueueFiles(
      inputPaths: ['/missing/input.png', valid.path],
      sourceType: SourceType.manualFile,
    );

    final rows = await workspace.fetchQueueRows();
    final failed = rows.singleWhere((row) => row.id == ids.first);
    final pending = rows.singleWhere((row) => row.id == ids.last);
    expect(rows, hasLength(2));
    expect(failed.status, ImportStatus.failed);
    expect(failed.localInputPath, isNull);
    expect(failed.errorMessage, contains('Gagal menyalin file'));
    expect(pending.status, ImportStatus.pending);
  });

  test('bulk 30 file memberi giliran ke event loop', () async {
    final inputs = await Future.wait([
      for (var index = 0; index < 30; index++)
        workspace.createInput('bulk_$index.png'),
    ]);
    var timerFired = false;

    final enqueue = workspace.repository.enqueueFiles(
      inputPaths: inputs.map((file) => file.path),
      sourceType: SourceType.galleryPicker,
    );
    Timer.run(() => timerFired = true);
    await enqueue;

    final rows = await workspace.fetchQueueRows();
    expect(timerFired, isTrue);
    expect(rows, hasLength(30));
    expect(rows.every((row) => row.status == ImportStatus.pending), isTrue);
  });
}
