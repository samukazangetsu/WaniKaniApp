import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/home_actions_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

class GetActionsUsecase {
  final IHomeRepository _repository;

  const GetActionsUsecase({required IHomeRepository repository})
    : _repository = repository;

  Future<Either<IError, HomeActionsEntity>> call() => _repository.getActions();
}
