import 'package:flutter/material.dart';

import 'settings_section_header.dart';

class SettingsBackupSection extends StatelessWidget {
  final bool isPro;
  final VoidCallback onExport;
  final VoidCallback onImport;

  const SettingsBackupSection({
    super.key,
    required this.isPro,
    required this.onExport,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader('Backup (Pro)'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Exportar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Importar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
