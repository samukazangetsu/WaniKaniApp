import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/api_error_entity.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/core/mixins/decode_model_mixin.dart';
import 'package:wanikani_app/core/network/extensions/response_extension.dart';
import 'package:wanikani_app/core/utils/core_strings.dart';
import 'package:wanikani_app/features/login/data/datasources/wanikani_auth_datasource.dart';
import 'package:wanikani_app/features/login/data/models/user_model.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';
import 'package:wanikani_app/features/login/domain/repositories/iuser_repository.dart';

/// Implementação do repositório de usuário.
///
/// Responsável por:
/// - Fazer chamadas ao [WaniKaniAuthDataSource]
/// - Converter [Response] em [UserEntity] usando [UserModel]
/// - Tratar erros e retornar [Either<IError, UserEntity>]
///
/// Utiliza [DecodeModelMixin] para parsing seguro de JSON.
class UserRepository with DecodeModelMixin implements IUserRepository {
  final WaniKaniAuthDataSource _datasource;

  /// Cria uma instância de [UserRepository].
  ///
  /// Requer [WaniKaniAuthDataSource] para acessar a API.
  const UserRepository({required WaniKaniAuthDataSource datasource})
    : _datasource = datasource;

  @override
  Future<Either<IError, UserEntity>> getUser() async {
    try {
      final response = await _datasource.getUser();

      if (response.isSuccessful) {
        return tryDecode<Either<IError, UserEntity>>(
          () {
            final user = UserModel.fromJson(
              response.data as Map<String, dynamic>,
            );
            return Right<IError, UserEntity>(user);
          },
          orElse: (_) => Left<IError, UserEntity>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      return Left<IError, UserEntity>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, UserEntity>(InternalErrorEntity(e.toString()));
    }
  }
}
