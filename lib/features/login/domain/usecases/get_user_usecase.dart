import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';
import 'package:wanikani_app/features/login/domain/repositories/iuser_repository.dart';

/// Caso de uso para buscar informações do usuário autenticado.
///
/// Este use case encapsula a lógica de negócio para validar o token
/// do usuário fazendo uma chamada à API WaniKani.
///
/// É utilizado durante o processo de login para:
/// 1. Verificar se o token é válido
/// 2. Obter dados básicos do usuário (nome, nível, assinatura)
/// 3. Confirmar que a autenticação foi bem-sucedida
class GetUserUseCase {
  final IUserRepository _repository;

  /// Cria uma instância de [GetUserUseCase].
  ///
  /// Requer [IUserRepository] para acessar a camada de dados.
  const GetUserUseCase({required IUserRepository repository})
    : _repository = repository;

  /// Busca dados do usuário autenticado.
  ///
  /// Delega a chamada para o repositório, que:
  /// - Adiciona header Authorization automaticamente (via [AuthInterceptor])
  /// - Faz GET /user na API WaniKani
  /// - Retorna [UserEntity] em caso de sucesso
  /// - Retorna [IError] em caso de falha (401, network error, etc)
  ///
  /// Exemplo de uso no [LoginCubit]:
  /// ```dart
  /// final result = await _getUserUseCase();
  /// result.fold(
  ///   (error) => emit(LoginError(error.message)),
  ///   (user) => emit(LoginSuccess(user)),
  /// );
  /// ```
  Future<Either<IError, UserEntity>> call() => _repository.getUser();
}
