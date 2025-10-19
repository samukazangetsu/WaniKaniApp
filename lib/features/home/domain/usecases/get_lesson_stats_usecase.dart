import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/lesson_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

/// Use case para obter estatísticas de lições disponíveis.
///
/// Busca o total de lições disponíveis via [IHomeRepository],
/// utilizando o campo `total_count` do endpoint `/study_materials`.
class GetLessonStatsUseCase {
  final IHomeRepository _repository;

  const GetLessonStatsUseCase({required IHomeRepository repository})
    : _repository = repository;

  /// Executa o use case.
  ///
  /// Retorna:
  /// - [Right] com [LessonStatsEntity] contendo o total_count
  /// - [Left] com [IError] se falhar
  Future<Either<IError, LessonStatsEntity>> call() async =>
      await _repository.getLessonStats();
}
