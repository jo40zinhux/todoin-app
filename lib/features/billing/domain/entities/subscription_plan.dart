class SubscriptionPlan {
  final String id;
  final String title;
  final String priceLabel;
  final String periodLabel;
  final String? subtitle;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.periodLabel,
    this.subtitle,
    this.isPopular = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
