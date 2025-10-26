import 'package:equatable/equatable.dart';
import 'package:wanikani_app/features/login/domain/entities/subscription_entity.dart';

/// Entidade representando o usuário autenticado do WaniKani.
///
/// Contém informações básicas do perfil:
/// - Nome de usuário
/// - Nível atual (1-60)
/// - Data de início dos estudos
/// - Informações da assinatura
class UserEntity extends Equatable {
  /// Nome de usuário único no WaniKani.
  final String username;

  /// Data em que o usuário começou a usar o WaniKani.
  final DateTime startedAt;

  /// Nível atual do usuário (1-60).
  ///
  /// O WaniKani tem 60 níveis, cada um ensinando aproximadamente
  /// 20 novos kanji e vocabulários relacionados.
  final int level;

  /// Informações sobre a assinatura do usuário.
  final SubscriptionEntity subscription;

  /// Cria uma instância de [UserEntity].
  const UserEntity({
    required this.username,
    required this.startedAt,
    required this.level,
    required this.subscription,
  });

  /// Verifica se o usuário tem acesso completo (níveis 1-60).
  ///
  /// Usuários sem assinatura ativa só têm acesso aos níveis 1-3.
  bool get hasFullAccess => subscription.active;

  /// Verifica se o usuário completou todos os níveis.
  bool get isMaxLevel => level == 60;

  @override
  List<Object> get props => [username, startedAt, level, subscription];
}
