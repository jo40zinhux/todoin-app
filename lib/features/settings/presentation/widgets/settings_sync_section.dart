import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/sync_config.dart';
import '../../../../core/providers/app_state_reload_provider.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import 'settings_paywall_actions.dart';
import 'settings_section_header.dart';
import 'settings_tile.dart';

class SettingsSyncSection extends ConsumerWidget {
  final bool isPro;

  const SettingsSyncSection({super.key, required this.isPro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(cloudSyncNotifierProvider);
    final syncNotifier = ref.read(cloudSyncNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader('Sincronização na nuvem (Pro)'),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'Sync automático',
          subtitle: SyncConfig.isConfigured
              ? (isPro
                  ? 'Mantém tarefas e progresso entre dispositivos'
                  : 'Disponível no plano Pro')
              : 'Configure SUPABASE_URL e SUPABASE_ANON_KEY',
          icon: Icons.cloud_sync_outlined,
          value: isPro && syncState.enabled,
          onChanged: (val) async {
            if (!SyncConfig.isConfigured) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sync não configurado. Adicione SUPABASE_URL e SUPABASE_ANON_KEY.',
                    ),
                  ),
                );
              }
              return;
            }
            if (!isPro) {
              await showSettingsPaywall(context, ref);
              return;
            }
            await syncNotifier.setEnabled(val, isPro: isPro);
            FeedbackService.click();
          },
        ),
        if (isPro && SyncConfig.isConfigured) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: syncState.isSyncing
                ? null
                : () async {
                    final result = await syncNotifier.syncNow(isPro: isPro);
                    if (!context.mounted) return;
                    if (result == SyncResult.pulled) {
                      await ref
                          .read(appStateReloadProvider)
                          .afterBackupOrCloudPull();
                    }
                    final message =
                        ref.read(cloudSyncNotifierProvider).lastMessage;
                    if (message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  },
            icon: syncState.isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(
              syncState.isSyncing ? 'Sincronizando...' : 'Sincronizar agora',
            ),
          ),
        ],
      ],
    );
  }
}
