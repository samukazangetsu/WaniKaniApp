import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

/// Use case para obter a progressão do nível atual do usuário.
///
/// Busca a progressão do nível atual via [IHomeRepository].
/// A extração do campo `level` será feita no Cubit.
class GetCurrentLevelUseCase {
  final IHomeRepository _repository;

  const GetCurrentLevelUseCase({required IHomeRepository repository})
    : _repository = repository;

  /// Executa o use case.
  ///
  /// Retorna:
  /// - [Right] com [LevelProgressionEntity] do nível atual
  /// - [Left] com [IError] se falhar
  Future<Either<IError, LevelProgressionEntity>> call() async =>
      _repository.getCurrentLevelProgression();
}
