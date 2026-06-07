import 'package:flutter/material.dart';

import '../../../../core/constants/free_tier_limits.dart';
import '../../../../core/services/feedback_service.dart';

class TimerDurationPicker extends StatelessWidget {
  final List<int> durations;
  final int selectedSeconds;
  final ValueChanged<int> onSelected;

  const TimerDurationPicker({
    super.key,
    required this.durations,
    required this.selectedSeconds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: durations.map((seconds) {
        final selected = seconds == selectedSeconds;
        return ChoiceChip(
          label: Text(ProTimerDurations.label(seconds)),
          selected: selected,
          onSelected: (_) {
            FeedbackService.click();
            onSelected(seconds);
          },
          selectedColor: colorScheme.primaryContainer,
        );
      }).toList(),
    );
  }
}
