import 'package:flutter/material.dart';

class SettingsLegalFooter extends StatelessWidget {
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onRestoreTap;

  const SettingsLegalFooter({
    super.key,
    required this.onPrivacyTap,
    required this.onTermsTap,
    required this.onRestoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(onPressed: onPrivacyTap, child: const Text('Privacidade')),
        TextButton(onPressed: onTermsTap, child: const Text('Termos')),
        TextButton(onPressed: onRestoreTap, child: const Text('Restaurar')),
      ],
    );
  }
}
