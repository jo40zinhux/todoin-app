enum ProPlanType { none, monthly, yearly, lifetime }

class Entitlement {
  final bool isPro;
  final ProPlanType planType;
  final int tasksCompletedCount;
  final bool paywallDismissedAfterTrigger;

  const Entitlement({
    required this.isPro,
    this.planType = ProPlanType.none,
    this.tasksCompletedCount = 0,
    this.paywallDismissedAfterTrigger = false,
  });

  Entitlement copyWith({
    bool? isPro,
    ProPlanType? planType,
    int? tasksCompletedCount,
    bool? paywallDismissedAfterTrigger,
  }) {
    return Entitlement(
      isPro: isPro ?? this.isPro,
      planType: planType ?? this.planType,
      tasksCompletedCount: tasksCompletedCount ?? this.tasksCompletedCount,
      paywallDismissedAfterTrigger:
          paywallDismissedAfterTrigger ?? this.paywallDismissedAfterTrigger,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entitlement &&
          runtimeType == other.runtimeType &&
          isPro == other.isPro &&
          planType == other.planType &&
          tasksCompletedCount == other.tasksCompletedCount &&
          paywallDismissedAfterTrigger == other.paywallDismissedAfterTrigger;

  @override
  int get hashCode => Object.hash(
        isPro,
        planType,
        tasksCompletedCount,
        paywallDismissedAfterTrigger,
      );
}
