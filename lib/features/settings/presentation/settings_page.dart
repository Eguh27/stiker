import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/top_bar.dart';
import '../domain/settings_profile.dart';
import 'settings_providers.dart';
import 'settings_widgets.dart';

/// Settings: profil + toggle dark mode + penyimpanan (screen-map F8).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SettingsProfile> profile = ref.watch(
      settingsProfileProvider,
    );
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final bool isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: const TopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s2,
          AppSpacing.s5,
          AppSpacing.s5,
        ),
        children: [
          ..._body(context, ref, profile),
          const SizedBox(height: AppSpacing.s4),
          Text('TAMPILAN', style: Theme.of(context).textTheme.labelSmall),
          DarkModeRow(
            isDark: isDark,
            onChanged: (bool value) =>
                ref.read(themeModeProvider.notifier).setDark(value),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text('DATA LOKAL', style: Theme.of(context).textTheme.labelSmall),
          const StorageRow(),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Semua data disimpan offline pada perangkat ini.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<SettingsProfile> value,
  ) {
    return value.when(
      data: (SettingsProfile profile) {
        final AppColors colors = context.colors;
        return [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.line),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                AppIcon(AppIconName.sticker, color: colors.accent),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.appName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(profile.tagline),
                    ],
                  ),
                ),
                Text(profile.version),
              ],
            ),
          ),
        ];
      },
      loading: () => [const LoadingState(title: 'Menyiapkan setelan')],
      error: (Object error, StackTrace stack) => [
        ErrorState(
          title: 'Gagal memuat setelan',
          message: 'File lokal mungkin dipindahkan. Periksa lalu coba lagi.',
          onRetry: () => ref.invalidate(settingsProfileProvider),
        ),
      ],
    );
  }
}
