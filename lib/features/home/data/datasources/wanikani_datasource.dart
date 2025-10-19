import 'package:dio/dio.dart';

/// DataSource para comunicação com a API WaniKani.
///
/// Responsável por fazer requisições HTTP para os endpoints
/// relacionados à funcionalidade Home/Dashboard.
class WaniKaniDataSource {
  final Dio _dio;

  const WaniKaniDataSource({required Dio dio}) : _dio = dio;

  /// Obtém todas as progressões de níveis do usuário.
  ///
  /// Endpoint: `GET /level_progressions`
  ///
  /// Retorna uma coleção de level_progressions.
  Future<Response<dynamic>> getLevelProgressions() async =>
      await _dio.get<dynamic>('/level_progressions');

  /// Obtém todos os assignments do usuário.
  ///
  /// Endpoint: `GET /assignments`
  ///
  /// Retorna uma coleção de assignments.
  Future<Response<dynamic>> getAssignments() async =>
      _dio.get<dynamic>('/assignments');

  /// Obtém o total de reviews disponíveis.
  ///
  /// Endpoint: `GET /reviews`
  ///
  /// Retorna uma coleção com o campo `total_count` indicando
  /// quantos reviews estão disponíveis para o usuário.
  Future<Response<dynamic>> getReviews() async =>
      await _dio.get<dynamic>('/reviews');

  /// Obtém o total de lições disponíveis.
  ///
  /// Endpoint: `GET /study_materials`
  ///
  /// Retorna uma coleção com o campo `total_count` indicando
  /// quantas lições estão disponíveis para o usuário.
  Future<Response<dynamic>> getStudyMaterials() async =>
      await _dio.get<dynamic>('/study_materials');
}
