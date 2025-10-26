import 'package:wanikani_app/features/login/domain/entities/subscription_entity.dart';

/// Model para conversão de dados JSON da API para [SubscriptionEntity].
///
/// Utiliza extension type (Dart 3.0+) para zero-cost abstraction.
/// O model implementa a entity, permitindo uso polimórfico.
extension type SubscriptionModel(SubscriptionEntity entity)
    implements SubscriptionEntity {
  /// Cria um [SubscriptionModel] a partir de JSON da API WaniKani.
  ///
  /// Estrutura esperada do JSON:
  /// ```json
  /// {
  ///   "active": true,
  ///   "type": "recurring",
  ///   "period_ends_at": "2018-12-11T13:32:19.485748Z"
  /// }
  /// ```
  ///
  /// Lança exceção se campos obrigatórios estiverem faltando.
  SubscriptionModel.fromJson(Map<String, dynamic> json)
    : entity = SubscriptionEntity(
        active: json['active'] as bool,
        type: json['type'] as String,
        periodEndsAt: json['period_ends_at'] != null
            ? DateTime.parse(json['period_ends_at'] as String)
            : null,
      );

  /// Converte [SubscriptionEntity] para JSON.
  ///
  /// Útil para persistência local ou debugging.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'active': active,
    'type': type,
    'period_ends_at': periodEndsAt?.toIso8601String(),
  };
}
