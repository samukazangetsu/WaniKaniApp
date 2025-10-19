import 'package:wanikani_app/features/home/domain/entities/review_stats_entity.dart';

/// Extension type que implementa conversão JSON para ReviewStatsEntity.
///
/// Usa o padrão extension type (Dart 3.0+) para zero-cost abstraction.
extension type ReviewStatsModel(ReviewStatsEntity entity)
    implements ReviewStatsEntity {
  /// Cria um [ReviewStatsModel] a partir de um JSON da API WaniKani.
  ///
  /// Formato esperado:
  /// ```json
  /// {
  ///   "object": "collection",
  ///   "total_count": 42,
  ///   "data": [...]
  /// }
  /// ```
  ReviewStatsModel.fromJson(Map<String, dynamic> json)
    : entity = ReviewStatsEntity(totalCount: json['total_count'] as int? ?? 0);

  /// Converte a entidade para JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'total_count': entity.totalCount,
  };
}
