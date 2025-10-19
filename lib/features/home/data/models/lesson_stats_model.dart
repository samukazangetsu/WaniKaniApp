import 'package:wanikani_app/features/home/domain/entities/lesson_stats_entity.dart';

/// Extension type que implementa conversão JSON para LessonStatsEntity.
///
/// Usa o padrão extension type (Dart 3.0+) para zero-cost abstraction.
extension type LessonStatsModel(LessonStatsEntity entity)
    implements LessonStatsEntity {
  /// Cria um [LessonStatsModel] a partir de um JSON da API WaniKani.
  ///
  /// Formato esperado:
  /// ```json
  /// {
  ///   "object": "collection",
  ///   "total_count": 88,
  ///   "data": [...]
  /// }
  /// ```
  LessonStatsModel.fromJson(Map<String, dynamic> json)
    : entity = LessonStatsEntity(totalCount: json['total_count'] as int? ?? 0);

  /// Converte a entidade para JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'total_count': entity.totalCount,
  };
}
