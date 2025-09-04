import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

class GetDashboardUsecase {
  final IHomeRepository _repository;

  const GetDashboardUsecase({required IHomeRepository repository})
    : _repository = repository;

  Future<Either<IError, HomeDashboardEntity>> call() =>
      _repository.getDashboard();
}
