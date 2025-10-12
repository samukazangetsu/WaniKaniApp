import 'package:dio/dio.dart';

/// DataSource para comunicação com a API WaniKani.
///
/// Responsável por fazer requisições HTTP para os endpoints
/// relacionados à funcionalidade Home/Dashboard.
class WaniKaniDataSource {
  final Dio _dio;

  const WaniKaniDataSource({required Dio dio}) : _dio = dio;

  /// Obtém a progressão do nível atual do usuário.
  ///
  /// Endpoint: `GET /level_progression`
  ///
  /// Retorna um único objeto de level_progression (não uma coleção).
  Future<Response<dynamic>> getCurrentLevelProgression() async =>
      _dio.get<dynamic>('/level_progression');

  /// Obtém todos os assignments do usuário.
  ///
  /// Endpoint: `GET /assignments`
  ///
  /// Retorna uma coleção de assignments.
  Future<Response<dynamic>> getAssignments() async =>
      _dio.get<dynamic>('/assignments');
}
