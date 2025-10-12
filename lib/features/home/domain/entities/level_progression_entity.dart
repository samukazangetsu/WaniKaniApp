import 'package:equatable/equatable.dart';

/// Representa a progressão do usuário através de um nível do WaniKani.
///
/// WaniKani tem 60 níveis, e cada nível contém radicais, kanjis e vocabulário
/// que o usuário deve dominar antes de avançar.
class LevelProgressionEntity extends Equatable {
  /// ID único da progressão de nível.
  final int id;

  /// Número do nível (1-60).
  final int level;

  /// Data/hora em que o nível foi desbloqueado.
  final DateTime? unlockedAt;

  /// Data/hora em que o usuário iniciou o nível.
  ///
  /// `null` se o nível foi desbloqueado mas ainda não teve lições iniciadas.
  final DateTime? startedAt;

  /// Data/hora em que o usuário passou no nível.
  ///
  /// `null` se ainda não passou (não passou em 90% dos kanjis do nível).
  final DateTime? passedAt;

  /// Data/hora em que o nível foi completado.
  ///
  /// `null` se ainda não completou (não passou em todos os items do nível).
  final DateTime? completedAt;

  /// Data/hora em que o nível foi abandonado/resetado.
  ///
  /// `null` em situações normais. Só é preenchido se o usuário resetou
  /// sua conta para um nível anterior.
  final DateTime? abandonedAt;

  const LevelProgressionEntity({
    required this.id,
    required this.level,
    required this.unlockedAt,
    required this.startedAt,
    required this.passedAt,
    required this.completedAt,
    required this.abandonedAt,
  });

  /// Retorna `true` se o nível está ativo (iniciado mas não completado).
  bool get isActive =>
      startedAt != null && completedAt == null && abandonedAt == null;

  /// Retorna `true` se o nível foi completado.
  bool get isCompleted => completedAt != null;

  /// Retorna `true` se o nível foi abandonado/resetado.
  bool get isAbandoned => abandonedAt != null;

  @override
  List<Object?> get props => <Object?>[
    id,
    level,
    unlockedAt,
    startedAt,
    passedAt,
    completedAt,
    abandonedAt,
  ];
}
