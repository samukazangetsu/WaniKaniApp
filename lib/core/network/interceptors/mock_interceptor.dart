import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Interceptor Dio para retornar dados mockados de arquivos JSON
/// durante o desenvolvimento, sem necessidade de chamadas reais à API.
///
/// Utilizado em `main_mock.dart` para desenvolvimento offline.
class MockInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Log da requisição
    if (kDebugMode) {
      final bodyLog = options.data != null
          ? _prettyPrintJson(options.data)
          : '(empty)';

      _logger.i(
        '🔷 [MOCK] REQUEST\n'
        'Method: ${options.method}\n'
        'URL: ${options.uri}\n'
        'Headers: ${_prettyPrintJson(options.headers)}\n'
        'Body: $bodyLog',
      );
    }

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

      // Criar resposta mock
      final mockResponse = Response<Map<String, dynamic>>(
        requestOptions: options,
        data: data,
        statusCode: 200,
        statusMessage: 'OK (MOCK)',
      );

      // Log da resposta
      if (kDebugMode) {
        _logger.d(
          '🔷 [MOCK] RESPONSE\n'
          'Status: ${mockResponse.statusCode}\n'
          'URL: ${mockResponse.requestOptions.uri}\n'
          'Body: ${_prettyPrintJson(mockResponse.data)}',
        );
      }

      // Resolver com mock response
      handler.resolve(mockResponse);
    } on Exception catch (e) {
      if (kDebugMode) {
        _logger.e(
          '🔷 [MOCK] ERROR\n'
          'URL: ${options.uri}\n'
          'Message: Failed to load mock: $mockPath\n'
          'Error: $e',
        );
      }

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
    if (path.contains('user')) {
      return 'user';
    }
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

  /// Formata JSON com indentação para legibilidade.
  ///
  /// Tenta converter [data] para JSON formatado.
  /// Se falhar, retorna toString() do objeto.
  String _prettyPrintJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return '\n${encoder.convert(data)}';
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
