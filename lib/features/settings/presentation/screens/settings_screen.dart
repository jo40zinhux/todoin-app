import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/legal_urls.dart';
import '../../../../core/providers/app_state_reload_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../backup/domain/usecases/import_backup.dart';
import '../../../backup/presentation/providers/backup_provider.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_backup_section.dart';
import '../widgets/settings_legal_footer.dart';
import '../widgets/settings_paywall_actions.dart';
import '../widgets/settings_plan_card.dart';
import '../widgets/settings_reminders_section.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_sync_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    AnalyticsService.instance.screen('settings');
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final json = await ref.read(exportBackupProvider)(NoParams());
    AnalyticsService.instance.backupExported();
    await Share.share(json, subject: 'toDoin backup');
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path;
    if (path == null || !context.mounted) return;

    final content = await File(path).readAsString();
    await ref.read(importBackupProvider)(
      ImportBackupParams(jsonContent: content),
    );
    AnalyticsService.instance.backupImported();

    await ref.read(appStateReloadProvider).afterBackupOrCloudPull();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restaurado com sucesso!')),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final isPro = ref.watch(entitlementNotifierProvider).value?.isPro ?? false;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Fechar',
            onPressed: () {
              FeedbackService.click();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsPlanCard(
                isPro: isPro,
                onUpgradeTap: () => showSettingsPaywall(context, ref),
              ),
              const SizedBox(height: 24),
              const SettingsSectionHeader('Geral'),
              const SizedBox(height: 8),
              SettingsTile(
                title: 'Modo dia difícil',
                subtitle: 'Mostra só 1 tarefa por vez — menos sobrecarga',
                icon: Icons.self_improvement_outlined,
                value: settingsState.badDayMode,
                onChanged: (_) async {
                  await settingsNotifier.toggleBadDayMode();
                  FeedbackService.click();
                },
              ),
              const SizedBox(height: 12),
              SettingsTile(
                title: 'Efeitos Sonoros',
                subtitle: 'Sons de cliques e celebrações',
                icon: Icons.volume_up_rounded,
                value: settingsState.soundEnabled,
                onChanged: (val) async {
                  await settingsNotifier.toggleSound();
                  if (val) FeedbackService.click();
                },
              ),
              const SizedBox(height: 12),
              SettingsTile(
                title: 'Vibração (Haptics)',
                subtitle: 'Feedback tátil em botões e ações',
                icon: Icons.vibration_rounded,
                value: settingsState.hapticEnabled,
                onChanged: (val) async {
                  await settingsNotifier.toggleHaptic();
                  if (val) FeedbackService.click();
                },
              ),
              const SizedBox(height: 24),
              SettingsRemindersSection(isPro: isPro),
              const SizedBox(height: 24),
              SettingsSyncSection(isPro: isPro),
              const SizedBox(height: 24),
              SettingsBackupSection(
                isPro: isPro,
                onExport: isPro
                    ? () => _exportBackup(context, ref)
                    : () => showSettingsPaywall(context, ref),
                onImport: isPro
                    ? () => _importBackup(context, ref)
                    : () => showSettingsPaywall(context, ref),
              ),
              const SizedBox(height: 24),
              SettingsLegalFooter(
                onPrivacyTap: () => _openUrl(LegalUrls.privacyPolicy),
                onTermsTap: () => _openUrl(LegalUrls.termsOfUse),
                onRestoreTap: () async {
                  final restored = await ref
                      .read(entitlementNotifierProvider.notifier)
                      .restore();
                  if (context.mounted && restored) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compras restauradas!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
