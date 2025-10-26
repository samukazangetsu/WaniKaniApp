import 'package:dio/dio.dart';
import 'package:wanikani_app/core/storage/local_data_manager.dart';

/// Interceptor responsável por injetar o header de autenticação em todas as
/// requisições e tratar erros de autenticação (401).
///
/// - **onRequest:** Adiciona o header `Authorization: Bearer {token}`
/// - **onError:** Redireciona para `/login` em caso de erro 401 (Unauthorized)
class AuthInterceptor extends Interceptor {
  final LocalDataManager _localDataManager;

  /// Cria uma instância de [AuthInterceptor].
  ///
  /// Requer [LocalDataManager] para recuperar o token armazenado.
  AuthInterceptor(this._localDataManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Recupera o token armazenado de forma segura
    final token = await _localDataManager.getToken();

    // Se existe token, adiciona ao header Authorization
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continua com a requisição
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Se o erro for 401 (Unauthorized), o token é inválido ou expirou
    if (err.response?.statusCode == 401) {
      // Remove o token inválido do armazenamento
      _localDataManager.deleteToken();

      // TODO: Implementar navegação para /login usando navigation key
      // Atualmente não é possível navegar aqui pois não temos acesso ao
      // BuildContext. Isso será tratado na camada de apresentação quando
      // o erro for propagado.
      //
      // Possível solução futura:
      // - Injetar GlobalKey<NavigatorState> no interceptor
      // - Usar go_router.go('/login')
    }

    // Propaga o erro para ser tratado pelos repositórios
    super.onError(err, handler);
  }
}
