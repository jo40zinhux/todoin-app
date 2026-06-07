import 'entitlement.dart';

/// Resultado de uma operação de compra, restauração ou sync com a loja.
class BillingResult {
  final bool success;
  final ProPlanType? planType;
  final String? errorMessage;

  /// Loja indisponível (credenciais inválidas, rede, etc.) — não revogar Pro local.
  final bool storeUnavailable;

  const BillingResult({
    required this.success,
    this.planType,
    this.errorMessage,
    this.storeUnavailable = false,
  });

  factory BillingResult.failure(String message) =>
      BillingResult(success: false, errorMessage: message);

  factory BillingResult.granted(ProPlanType planType) =>
      BillingResult(success: true, planType: planType);

  factory BillingResult.storeUnavailable() =>
      const BillingResult(success: false, storeUnavailable: true);

  /// Loja confirmou ausência de assinatura ativa (não é erro de rede).
  bool get confirmedNoSubscription =>
      !success && errorMessage == null && !storeUnavailable;

  /// Só revoga Pro local quando a loja confirmou que não há assinatura.
  bool get shouldRevokeLocalPro => confirmedNoSubscription;
}
