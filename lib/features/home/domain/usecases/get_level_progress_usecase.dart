import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/home_level_progress_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

class GetLevelProgressUsecase {
  final IHomeRepository _repository;

  const GetLevelProgressUsecase({required IHomeRepository repository})
    : _repository = repository;

  Future<Either<IError, HomeLevelProgressEntity>> call() =>
      _repository.getLevelProgress();
}
