import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/home_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

class GetStatsUsecase {
  final IHomeRepository _repository;

  const GetStatsUsecase({required IHomeRepository repository})
    : _repository = repository;

  Future<Either<IError, HomeStatsEntity>> call() => _repository.getStats();
}
