import '../../features/billing/domain/entities/subscription_plan.dart';

/// Catálogo de produtos para exibição no paywall.
/// IDs devem corresponder aos produtos configurados na App Store / Play Console.
abstract class ProductCatalog {
  static const plans = [
    SubscriptionPlan(
      id: 'todoin_pro_monthly',
      title: 'Mensal',
      priceLabel: 'R\$ 12,90',
      periodLabel: '/mês',
      isPopular: false,
    ),
    SubscriptionPlan(
      id: 'todoin_pro_yearly',
      title: 'Anual',
      priceLabel: 'R\$ 59,90',
      periodLabel: '/ano',
      subtitle: '~R\$ 4,99/mês',
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'todoin_pro_lifetime',
      title: 'Vitalício',
      priceLabel: 'R\$ 89,90',
      periodLabel: 'pagamento único',
      isPopular: false,
    ),
  ];
}
