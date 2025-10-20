import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Interceptor Dio para logging estruturado de requisições e respostas.
///
/// Exibe logs coloridos no console apenas em modo debug.
/// Indica visualmente quando está em modo MOCK com prefixo [🔷 MOCK].
///
/// Exemplo de uso:
/// ```dart
/// final dio = Dio()
///   ..interceptors.add(LoggingInterceptor(isMockMode: true));
/// ```
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Não exibir stacktrace em logs normais
      errorMethodCount: 5, // Exibir stacktrace em erros
      lineLength: 80, // Largura das linhas
      colors: true, // Colorir logs
      printEmojis: true, // Usar emojis
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  final bool _isMockMode;

  /// Cria um [LoggingInterceptor].
  ///
  /// [isMockMode]: Se `true`, adiciona indicador visual [MOCK] nos logs.
  LoggingInterceptor({bool isMockMode = false}) : _isMockMode = isMockMode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final mockIndicator = _isMockMode ? '🔷 [MOCK] ' : '';

      final bodyLog = options.data != null
          ? _prettyPrintJson(options.data)
          : '(empty)';

      _logger.i(
        '${mockIndicator}REQUEST\n'
        'Method: ${options.method}\n'
        'URL: ${options.uri}\n'
        'Headers: ${_prettyPrintJson(options.headers)}\n'
        'Body: $bodyLog',
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final mockIndicator = _isMockMode ? '🔷 [MOCK] ' : '';

      _logger.d(
        '${mockIndicator}RESPONSE\n'
        'Status: ${response.statusCode}\n'
        'URL: ${response.requestOptions.uri}\n'
        'Body: ${_prettyPrintJson(response.data)}',
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final responseLog = err.response?.data != null
          ? _prettyPrintJson(err.response!.data)
          : '(no response)';

      _logger.e(
        'ERROR\n'
        'URL: ${err.requestOptions.uri}\n'
        'Type: ${err.type}\n'
        'Message: ${err.message}\n'
        'Response: $responseLog',
      );
    }

    super.onError(err, handler);
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
