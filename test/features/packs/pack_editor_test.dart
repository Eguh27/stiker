import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/widgets/state_panels.dart';
import 'package:sticker_studio/features/packs/domain/fake_pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/pack_editor_state.dart';
import 'package:sticker_studio/features/packs/domain/pack_limits.dart';
import 'package:sticker_studio/features/packs/domain/pack_repository.dart';
import 'package:sticker_studio/features/packs/presentation/pack_editor_providers.dart';
import 'package:sticker_studio/features/packs/presentation/pack_header_card.dart';
import 'package:sticker_studio/features/packs/presentation/validation_card.dart';
import 'package:sticker_studio/features/packs/presentation/whatsapp_publish_button.dart';

import 'support/editor_pump.dart';

class _FlakyDetailFake extends FakePackRepository {
  bool _failed = false;

  @override
  Future<PackDetail> fetchPackDetail(String packId) async {
    if (!_failed) {
      _failed = true;
      throw StateError('offline');
    }
    return super.fetchPackDetail(packId);
  }
}

void main() {
  testWidgets('edit memuat detail pack via loading', (tester) async {
    await pumpEditor(tester, packId: 'p1', repository: FakePackRepository());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    final Finder headerName = find.descendant(
      of: find.byType(PackHeaderCard),
      matching: find.text('Daily Mood'),
    );
    expect(headerName, findsOneWidget);
    expect(find.text('Tray icon · 96 × 96 px'), findsOneWidget);
    expect(find.text('10/28'), findsOneWidget);
    expect(find.text('18/30'), findsOneWidget);
    expect(find.text('Tekan dan tahan untuk mengatur ulang.'), findsOneWidget);

    final PackEditorState state = editorContainerOf(tester)
        .read(packEditorProvider('p1'));
    expect(state.pack!.name, 'Daily Mood');
    expect(state.stickers, hasLength(18));

    final TextField nameField = tester.widget<TextField>(
      find.byType(TextField).first,
    );
    expect(nameField.controller!.text, 'Daily Mood');

    final Finder buttonLabel = find.descendant(
      of: find.byType(WhatsAppPublishButton),
      matching: find.text('Tambah ke WhatsApp'),
    );
    expect(buttonLabel, findsOneWidget);
    expect(
      tester
          .widget<WhatsAppPublishButton>(find.byType(WhatsAppPublishButton))
          .enabled,
      isTrue,
    );
    expect(
      find.descendant(
        of: find.byType(PackValidationCard),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('pack baru tampil kosong tanpa memuat repository', (
    tester,
  ) async {
    await pumpEditor(tester, repository: FakePackRepository());
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(PackHeaderCard), findsOneWidget);
    expect(find.text('Tanpa nama'), findsOneWidget);
    expect(find.text('0/30'), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Pack masih kosong'), findsOneWidget);
    expect(
      tester
          .widget<WhatsAppPublishButton>(find.byType(WhatsAppPublishButton))
          .enabled,
      isFalse,
    );
    expect(
      find.descendant(
        of: find.byType(PackValidationCard),
        matching: find.byIcon(Icons.close_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('3 stiker memenuhi validasi & tombol WhatsApp', (tester) async {
    await pumpEditor(tester, repository: FakePackRepository());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Tambah stiker'));
    await tester.pump();
    for (int step = 0; step < 2; step++) {
      await tester.tap(find.text('Tambah'));
      await tester.pump();
    }

    expect(find.text('3/30'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
    expect(
      tester
          .widget<WhatsAppPublishButton>(find.byType(WhatsAppPublishButton))
          .enabled,
      isTrue,
    );
    expect(
      find.descendant(
        of: find.byType(PackValidationCard),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('Tambah berhenti di 30 stiker', (tester) async {
    await pumpEditor(tester, packId: 'p1', repository: FakePackRepository());
    await tester.pumpAndSettle();

    // p1 sudah berisi 18 draft; tap lanjut sampai batas 30.
    for (int index = 18; index < PackLimits.maxStickers; index++) {
      await tester.tap(find.text('Tambah'));
      await tester.pump();
    }
    expect(find.text('30/30'), findsOneWidget);
    await tester.tap(find.text('Tambah'));
    await tester.pump();
    expect(find.text('30/30'), findsOneWidget);
    final InkWell addInkWell = tester.widget<InkWell>(
      find
          .ancestor(of: find.text('Tambah'), matching: find.byType(InkWell))
          .first,
    );
    expect(addInkWell.onTap, isNull);
  });

  testWidgets('tag emoji maks 3 lalu bisa dilepas', (tester) async {
    await pumpEditor(tester, repository: FakePackRepository());
    await tester.pump();
    await tester.pump();

    bool isSelected(String label) => tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label))
        .selected;

    for (final String tag in PackLimits.emojiTagOptions) {
      await tester.tap(find.text(tag));
      await tester.pump();
    }
    expect(isSelected('Smile'), isTrue);
    expect(isSelected('Love'), isTrue);
    expect(isSelected('Party'), isTrue);
    // Tag ke-4 ditolak (maks 3).
    expect(isSelected('Work'), isFalse);

    await tester.tap(find.text('Smile'));
    await tester.pump();
    expect(isSelected('Smile'), isFalse);
    expect(isSelected('Love'), isTrue);
    expect(editorContainerOf(tester).read(packEditorProvider(null)).emojiTags, [
      'Love',
      'Party',
    ]);
  });

  testWidgets('nama/pembuat terpotong pada 28 karakter', (tester) async {
    await pumpEditor(tester, repository: FakePackRepository());
    await tester.pump();
    await tester.pump();

    await fillAndUnfocus(tester, find.byType(TextField).first, 'X' * 40);
    expect(find.text('28/28'), findsOneWidget);

    final PackEditorState state = editorContainerOf(tester)
        .read(packEditorProvider(null));
    expect(state.pack!.name, 'X' * PackLimits.textMaxLength);
  });

  testWidgets('gagal memuat pack lalu retry berhasil', (tester) async {
    await pumpEditor(tester, packId: 'p1', repository: _FlakyDetailFake());
    await tester.pumpAndSettle();

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Gagal memuat pack'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.byType(PackHeaderCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PackHeaderCard),
        matching: find.text('Daily Mood'),
      ),
      findsOneWidget,
    );
  });
}
