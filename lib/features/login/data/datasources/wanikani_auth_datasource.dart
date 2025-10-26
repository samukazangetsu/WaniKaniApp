import 'package:dio/dio.dart';

/// DataSource responsável por chamadas à API WaniKani relacionadas
/// à autenticação e dados do usuário.
///
/// Utiliza [Dio] configurado com:
/// - BaseURL: https://api.wanikani.com/v2
/// - Header Authorization: Injetado automaticamente por [AuthInterceptor]
class WaniKaniAuthDataSource {
  final Dio _dio;

  /// Cria uma instância de [WaniKaniAuthDataSource].
  ///
  /// Requer [Dio] já configurado com interceptors e base URL.
  const WaniKaniAuthDataSource(this._dio);

  /// Busca informações do usuário autenticado.
  ///
  /// **Endpoint:** `GET /user`
  ///
  /// **Headers:**
  /// - `Authorization: Bearer {token}` (injetado automaticamente)
  ///
  /// **Resposta esperada (200 OK):**
  /// ```json
  /// {
  ///   "object": "user",
  ///   "data": {
  ///     "username": "example_user",
  ///     "level": 5,
  ///     "started_at": "2012-05-11T00:52:18.958466Z",
  ///     "subscription": {...}
  ///   }
  /// }
  /// ```
  ///
  /// **Possíveis erros:**
  /// - 401 Unauthorized: Token inválido ou revogado
  /// - 500 Internal Server Error: Problema no servidor WaniKani
  /// - DioException: Erro de rede (sem internet, timeout, etc)
  Future<Response<dynamic>> getUser() => _dio.get('/user');
}
