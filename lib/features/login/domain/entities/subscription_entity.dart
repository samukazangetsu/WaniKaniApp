import 'package:equatable/equatable.dart';

/// Entidade representando a assinatura (subscription) do usuário no WaniKani.
///
/// Contém informações sobre:
/// - Se a assinatura está ativa
/// - Tipo da assinatura (recurring, lifetime, etc)
/// - Data de expiração (se aplicável)
class SubscriptionEntity extends Equatable {
  /// Indica se a assinatura está ativa.
  final bool active;

  /// Tipo da assinatura.
  ///
  /// Valores possíveis:
  /// - `recurring`: Assinatura recorrente (mensal/anual)
  /// - `lifetime`: Assinatura vitalícia
  /// - `free`: Usuário sem assinatura (apenas níveis 1-3)
  final String type;

  /// Data de término do período atual da assinatura.
  ///
  /// Pode ser `null` se:
  /// - Assinatura é vitalícia (`lifetime`)
  /// - Usuário está no plano gratuito
  final DateTime? periodEndsAt;

  /// Cria uma instância de [SubscriptionEntity].
  const SubscriptionEntity({
    required this.active,
    required this.type,
    this.periodEndsAt,
  });

  /// Verifica se a assinatura é recorrente (paga mensalmente/anualmente).
  bool get isRecurring => type == 'recurring';

  /// Verifica se a assinatura é vitalícia.
  bool get isLifetime => type == 'lifetime';

  /// Verifica se o usuário está no plano gratuito.
  bool get isFree => type == 'free' || !active;

  @override
  List<Object?> get props => [active, type, periodEndsAt];
}
