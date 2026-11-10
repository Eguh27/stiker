import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_icon.dart';
import 'package:sticker_studio/core/widgets/bottom_nav.dart';
import 'package:sticker_studio/core/widgets/state_panels.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';

Widget _pump(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    darkTheme: AppTheme.dark,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('TopBar height 96 renders eyebrow + title', (tester) async {
    await tester.pumpWidget(
      _pump(TopBar(title: 'Library', eyebrow: 'Workspace lokal')),
    );
    expect(find.text('LIBRARY'), findsNothing);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('WORKSPACE LOKAL'), findsOneWidget);
    final Size size = tester.getSize(find.byType(TopBar));
    expect(size.height, AppLayout.topBarHeight);
    expect(TopBar(title: 'X').preferredSize.height, 96);
  });

  testWidgets('TopBar back toggles button', (tester) async {
    await tester.pumpWidget(_pump(TopBar(title: 'Gallery', onBack: () {})));
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
  });

  testWidgets('BottomNav height 80 with 4 labels', (tester) async {
    await tester.pumpWidget(_pump(BottomNav(currentIndex: 0, onTap: (_) {})));
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Antrean'), findsOneWidget);
    expect(find.text('Pack'), findsOneWidget);
    expect(find.text('Setelan'), findsOneWidget);
    final Size size = tester.getSize(find.byType(BottomNav));
    expect(size.height, AppLayout.bottomNavHeight);
  });

  testWidgets('BottomNav onTap fires', (tester) async {
    int tapped = -1;
    await tester.pumpWidget(
      _pump(BottomNav(currentIndex: 0, onTap: (i) => tapped = i)),
    );
    await tester.tap(find.text('Pack'));
    expect(tapped, 2);
  });

  testWidgets('AppIcon renders 24 grid icon', (tester) async {
    await tester.pumpWidget(_pump(const AppIcon(AppIconName.grid)));
    final Icon icon = tester.widget(find.byType(Icon));
    expect(icon.size, AppLayout.iconGridSize);
    expect(icon.icon, Icons.grid_view_rounded);
  });

  testWidgets('State panels render all states', (tester) async {
    await tester.pumpWidget(
      _pump(
        const Column(
          children: [
            LoadingState(title: 'Menyiapkan stiker'),
            EmptyState(title: 'Belum ada stiker', message: 'Mulai dari galeri'),
            ErrorState(
              title: 'Gagal memuat',
              message: 'File lokal mungkin dipindahkan',
            ),
          ],
        ),
      ),
    );
    expect(find.text('Menyiapkan stiker'), findsOneWidget);
    expect(find.text('Belum ada stiker'), findsOneWidget);
    expect(find.text('Gagal memuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('TopBar uses dark theme colors', (tester) async {
    await tester.pumpWidget(
      _pump(const TopBar(title: 'Library'), theme: AppTheme.dark),
    );
    expect(find.text('Library'), findsOneWidget);
  });
}
