import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/review_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

/// Use case para obter estatísticas de reviews disponíveis.
///
/// Busca o total de reviews disponíveis via [IHomeRepository],
/// utilizando o campo `total_count` do endpoint `/reviews`.
class GetReviewStatsUseCase {
  final IHomeRepository _repository;

  const GetReviewStatsUseCase({required IHomeRepository repository})
    : _repository = repository;

  /// Executa o use case.
  ///
  /// Retorna:
  /// - [Right] com [ReviewStatsEntity] contendo o total_count
  /// - [Left] com [IError] se falhar
  Future<Either<IError, ReviewStatsEntity>> call() async =>
      await _repository.getReviewStats();
}
