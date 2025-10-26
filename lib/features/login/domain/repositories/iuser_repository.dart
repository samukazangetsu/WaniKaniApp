import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';

/// Interface do repositório de usuário.
///
/// Define o contrato para buscar informações do usuário autenticado
/// da API WaniKani.
///
/// Esta interface é implementada pela camada de dados ([UserRepository])
/// e utilizada pela camada de domínio ([GetUserUseCase]).
abstract class IUserRepository {
  /// Busca informações do usuário autenticado.
  ///
  /// Realiza uma chamada ao endpoint `GET /user` da API WaniKani.
  /// O token de autenticação é injetado automaticamente pelo [AuthInterceptor].
  ///
  /// Retorna:
  /// - [Right(UserEntity)]: Sucesso com dados do usuário
  /// - [Left(IError)]: Falha (erro de rede, 401 Unauthorized, etc)
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final result = await repository.getUser();
  /// result.fold(
  ///   (error) => print('Erro: ${error.message}'),
  ///   (user) => print('Olá, ${user.username}!'),
  /// );
  /// ```
  Future<Either<IError, UserEntity>> getUser();
}
