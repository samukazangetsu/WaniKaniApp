import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/home_user_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

class GetUserInfoUsecase {
  final IHomeRepository repository;

  const GetUserInfoUsecase({required this.repository});

  Future<Either<IError, HomeUserEntity>> call() => repository.getUserInfo();
}
