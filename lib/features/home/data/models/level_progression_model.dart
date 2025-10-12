import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';

/// Extension type para conversão JSON ↔ [LevelProgressionEntity].
///
/// Usa extension type (Dart 3.0+) para zero-cost abstraction.
/// Implementa a entity diretamente sem overhead de wrapper class.
extension type LevelProgressionModel(LevelProgressionEntity entity)
    implements LevelProgressionEntity {
  /// Cria um model a partir de JSON da API WaniKani.
  ///
  /// Estrutura esperada:
  /// ```json
  /// {
  ///   "id": 123,
  ///   "data": {
  ///     "level": 4,
  ///     "unlocked_at": "2025-06-05T02:04:43.768478Z",
  ///     ...
  ///   }
  /// }
  /// ```
  LevelProgressionModel.fromJson(Map<String, dynamic> json)
    : entity = LevelProgressionEntity(
        id: json['id'] as int,
        level: json['data']['level'] as int,
        unlockedAt: json['data']['unlocked_at'] != null
            ? DateTime.parse(json['data']['unlocked_at'] as String)
            : null,
        startedAt: json['data']['started_at'] != null
            ? DateTime.parse(json['data']['started_at'] as String)
            : null,
        passedAt: json['data']['passed_at'] != null
            ? DateTime.parse(json['data']['passed_at'] as String)
            : null,
        completedAt: json['data']['completed_at'] != null
            ? DateTime.parse(json['data']['completed_at'] as String)
            : null,
        abandonedAt: json['data']['abandoned_at'] != null
            ? DateTime.parse(json['data']['abandoned_at'] as String)
            : null,
      );

  /// Converte a entity para JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'level': level,
    'unlocked_at': unlockedAt?.toIso8601String(),
    'started_at': startedAt?.toIso8601String(),
    'passed_at': passedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'abandoned_at': abandonedAt?.toIso8601String(),
  };
}
