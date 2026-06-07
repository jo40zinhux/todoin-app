import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/feedback_service.dart';
import '../../../reminders/presentation/providers/reminder_provider.dart';
import 'settings_paywall_actions.dart';
import 'settings_section_header.dart';
import 'settings_tile.dart';

class SettingsRemindersSection extends ConsumerWidget {
  final bool isPro;

  const SettingsRemindersSection({super.key, required this.isPro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderState = ref.watch(reminderNotifierProvider);
    final reminderNotifier = ref.read(reminderNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader('Lembretes gentis'),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'Lembrete diário',
          subtitle: isPro
              ? 'Mensagem suave no horário escolhido'
              : 'Disponível no plano Pro',
          icon: Icons.notifications_outlined,
          value: isPro && reminderState.enabled,
          onChanged: isPro
              ? (val) async {
                  await reminderNotifier.setEnabled(val);
                  FeedbackService.click();
                }
              : (_) => showSettingsPaywall(context, ref),
        ),
        if (isPro && reminderState.enabled) ...[
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Horário do lembrete'),
            subtitle: Text(
              '${reminderState.hour.toString().padLeft(2, '0')}:${reminderState.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: reminderState.hour,
                  minute: reminderState.minute,
                ),
              );
              if (picked != null) {
                await reminderNotifier.setTime(
                  hour: picked.hour,
                  minute: picked.minute,
                );
              }
            },
          ),
        ],
      ],
    );
  }
}
