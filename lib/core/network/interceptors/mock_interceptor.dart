import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

/// Interceptor Dio para retornar dados mockados de arquivos JSON
/// durante o desenvolvimento, sem necessidade de chamadas reais à API.
///
/// Utilizado em `main_mock.dart` para desenvolvimento offline.
class MockInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Determinar qual mock usar baseado no path
    final mockPath = _getMockPath(options.path);

    if (mockPath == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Mock not found for path: ${options.path}',
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    try {
      // Ler JSON do asset
      final jsonString = await rootBundle.loadString(
        'assets/mock/$mockPath.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Simular delay de rede realista
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Resolver com mock response
      handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          data: data,
          statusCode: 200,
          statusMessage: 'OK',
        ),
      );
    } on Exception catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to load mock: $mockPath - $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// Mapeia o path da requisição para o arquivo mock correspondente.
  ///
  /// Retorna `null` se não houver mock configurado para o path.
  String? _getMockPath(String path) {
    if (path.contains('level_progressions')) {
      return 'all_level_progression';
    }
    if (path.contains('assignments')) {
      return 'all_assignments';
    }
    if (path.contains('reviews')) {
      return 'all_reviews';
    }
    if (path.contains('study_materials')) {
      return 'all_study_material';
    }
    return null;
  }
}
