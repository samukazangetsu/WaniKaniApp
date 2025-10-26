import 'package:wanikani_app/features/login/data/models/subscription_model.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';

/// Model para conversão de dados JSON da API para [UserEntity].
///
/// Utiliza extension type (Dart 3.0+) para zero-cost abstraction.
/// O model implementa a entity, permitindo uso polimórfico.
extension type UserModel(UserEntity entity) implements UserEntity {
  /// Cria um [UserModel] a partir da resposta JSON da API WaniKani.
  ///
  /// Estrutura esperada do JSON (envelope WaniKani):
  /// ```json
  /// {
  ///   "object": "user",
  ///   "data": {
  ///     "username": "example_user",
  ///     "level": 5,
  ///     "started_at": "2012-05-11T00:52:18.958466Z",
  ///     "subscription": {
  ///       "active": true,
  ///       "type": "recurring",
  ///       "period_ends_at": "2018-12-11T13:32:19.485748Z"
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Lança exceção se campos obrigatórios estiverem faltando.
  UserModel.fromJson(Map<String, dynamic> json)
    : entity = UserEntity(
        username: json['data']['username'] as String,
        level: json['data']['level'] as int,
        startedAt: DateTime.parse(json['data']['started_at'] as String),
        subscription: SubscriptionModel.fromJson(
          json['data']['subscription'] as Map<String, dynamic>,
        ),
      );

  /// Converte [UserEntity] para JSON.
  ///
  /// Útil para persistência local ou debugging.
  /// Retorna no formato do envelope WaniKani.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'object': 'user',
    'data': <String, dynamic>{
      'username': username,
      'level': level,
      'started_at': startedAt.toIso8601String(),
      'subscription': SubscriptionModel(subscription).toJson(),
    },
  };
}
