import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';

/// Extension type para conversão JSON ↔ [AssignmentEntity].
///
/// Usa extension type (Dart 3.0+) para zero-cost abstraction.
/// Implementa a entity diretamente sem overhead de wrapper class.
extension type AssignmentModel(AssignmentEntity entity)
    implements AssignmentEntity {
  /// Cria um model a partir de JSON da API WaniKani.
  ///
  /// Estrutura esperada:
  /// ```json
  /// {
  ///   "id": 123,
  ///   "data": {
  ///     "subject_id": 16,
  ///     "subject_type": "radical",
  ///     "srs_stage": 8,
  ///     "unlocked_at": "2025-03-09T10:11:11.835272Z",
  ///     ...
  ///   }
  /// }
  /// ```
  AssignmentModel.fromJson(Map<String, dynamic> json)
    : entity = AssignmentEntity(
        id: json['id'] as int,
        subjectId: json['data']['subject_id'] as int,
        subjectType: json['data']['subject_type'] as String,
        srsStage: json['data']['srs_stage'] as int,
        availableAt: json['data']['available_at'] != null
            ? DateTime.parse(json['data']['available_at'] as String)
            : null,
        unlockedAt: json['data']['unlocked_at'] != null,
        startedAt: json['data']['started_at'] != null
            ? DateTime.parse(json['data']['started_at'] as String)
            : null,
        passedAt: json['data']['passed_at'] != null
            ? DateTime.parse(json['data']['passed_at'] as String)
            : null,
        burnedAt: json['data']['burned_at'] != null
            ? DateTime.parse(json['data']['burned_at'] as String)
            : null,
      );

  /// Converte a entity para JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'subject_id': subjectId,
    'subject_type': subjectType,
    'srs_stage': srsStage,
    'available_at': availableAt?.toIso8601String(),
    'unlocked_at': unlockedAt ? startedAt?.toIso8601String() : null,
    'started_at': startedAt?.toIso8601String(),
    'passed_at': passedAt?.toIso8601String(),
    'burned_at': burnedAt?.toIso8601String(),
  };
}
