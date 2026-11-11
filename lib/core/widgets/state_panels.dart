import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';
import 'glass/glass_card.dart';

/// Panel loading/empty/error dari `App.tsx::StatePanel` (screen-map).
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    required this.title,
    this.message = 'Semuanya diproses langsung di perangkatmu.',
  });
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => _StatePanel(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.s4),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.s1),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = AppIconName.sticker,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String message;
  final AppIconName icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => _StatePanel(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 32, color: context.colors.accent),
        const SizedBox(height: AppSpacing.s3),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.s1),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: AppSpacing.s4),
          FilledButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => _StatePanel(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(AppIconName.refresh, size: 32, color: context.colors.danger),
        const SizedBox(height: AppSpacing.s3),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.s1),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s4),
        FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => GlassCard(child: child);
}
