import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/features/data/whatsapp/whatsapp_channel.dart';
import 'package:sticker_studio/features/data/whatsapp/whatsapp_providers.dart';
import 'package:sticker_studio/features/data/whatsapp/whatsapp_staging_exporter.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart';
import 'package:sticker_studio/features/packs/domain/fake_pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';
import 'package:sticker_studio/features/packs/presentation/pack_editor_page.dart';
import 'package:sticker_studio/features/packs/presentation/pack_providers.dart';

import 'support/editor_pump.dart';

class _MockWhatsAppChannel implements WhatsAppChannel {
  _MockWhatsAppChannel({this.installed = true, this.addSuccess = true});

  final bool installed;
  final bool addSuccess;
  String? lastPackId;
  String? lastName;

  @override
  Future<bool> isWhatsAppInstalled({bool business = false}) async => installed;

  @override
  Future<bool> addStickerPack({
    required String identifier,
    required String name,
    bool isBusiness = false,
  }) async {
    lastPackId = identifier;
    lastName = name;
    return addSuccess;
  }

  @override
  Future<String> getStagingDirectory() async => '/mock/staging';
}

class _MockExporter extends WhatsAppStagingExporter {
  _MockExporter();
  bool exported = false;
  String? lastIdentifier;

  @override
  Future<WhatsAppExportResult> exportPack({
    required String stagingBaseDir,
    required String identifier,
    required String name,
    required String author,
    required List<String> stickerPaths,
    List<String> emojis = const [],
    String? trayIconPath,
  }) async {
    exported = true;
    lastIdentifier = identifier;
    return WhatsAppExportResult(
      stagingPath: '$stagingBaseDir/$identifier',
      stickerCount: stickerPaths.length,
      identifier: identifier,
    );
  }
}

void main() {
  testWidgets('WhatsApp export flow: tampilkan pesan saat WA tidak terpasang', (
    tester,
  ) async {
    pumpTallViewport(tester);
    final mockChannel = _MockWhatsAppChannel(installed: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packRepositoryProvider.overrideWithValue(FakePackRepository()),
          whatsAppChannelProvider.overrideWithValue(mockChannel),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const PackEditorPage(packId: 'p1'),
        ),
      ),
    );
    await pumpSettled(tester);

    // Tekan Tambah ke WhatsApp
    await tester.tap(find.text('Tambah ke WhatsApp'));
    await tester.pumpAndSettle();

    expect(
      find.text('WhatsApp tidak terpasang di perangkat ini.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'WhatsApp export flow: ekspor sukses dan trigger intent channel',
    (tester) async {
      pumpTallViewport(tester);
      final mockChannel = _MockWhatsAppChannel(
        installed: true,
        addSuccess: true,
      );
      final mockExporter = _MockExporter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packRepositoryProvider.overrideWithValue(FakePackRepository()),
            whatsAppChannelProvider.overrideWithValue(mockChannel),
            whatsAppStagingExporterProvider.overrideWithValue(mockExporter),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const PackEditorPage(packId: 'p1'),
          ),
        ),
      );
      await pumpSettled(tester);

      // Tekan Tambah ke WhatsApp
      await tester.tap(find.text('Tambah ke WhatsApp'));
      await tester.pumpAndSettle();

      expect(mockExporter.exported, isTrue);
      expect(mockChannel.lastPackId, 'p1');
      expect(mockChannel.lastName, 'Daily Mood');
      expect(find.text('Membuka WhatsApp...'), findsOneWidget);
    },
  );

  testWidgets('pack baru disimpan dulu agar identifier publish tidak kosong', (
    tester,
  ) async {
    pumpTallViewport(tester);
    final FakePackRepository fake = FakePackRepository();
    final _MockWhatsAppChannel mockChannel = _MockWhatsAppChannel();
    final _MockExporter mockExporter = _MockExporter();
    int picks = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packRepositoryProvider.overrideWithValue(fake),
          whatsAppChannelProvider.overrideWithValue(mockChannel),
          whatsAppStagingExporterProvider.overrideWithValue(mockExporter),
          stickerPickerLauncherProvider.overrideWithValue(({
            required context,
            required alreadySelectedIds,
            required maxSelectable,
          }) async {
            picks++;
            return [
              Sticker(
                id: 'baru-$picks',
                label: 'Baru $picks',
                colorKind: StickerColorKind.lavender,
                shape: StickerShape.blob,
              ),
            ];
          }),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const PackEditorPage()),
      ),
    );
    await pumpSettled(tester);

    await tester.tap(find.text('Tambah stiker'));
    await tester.pump();
    for (int i = 0; i < 2; i++) {
      await tester.tap(find.text('Tambah'));
      await tester.pump();
    }

    await tester.tap(find.text('Tambah ke WhatsApp'));
    await pumpSettled(tester);

    expect(fake.packs, hasLength(4));
    final StickerPack saved = fake.packs.last;
    expect(saved.id, isNotEmpty);
    expect(mockExporter.lastIdentifier, saved.id);
    expect(mockChannel.lastPackId, saved.id);
    expect(find.text('Membuka WhatsApp...'), findsOneWidget);

    // Simpan lagi setelah publish tidak boleh membuat pack duplikat.
    await tester.tap(find.text('Simpan'));
    await pumpSettled(tester);
    expect(fake.packs, hasLength(4));
  });
}
