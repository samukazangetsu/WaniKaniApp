import 'package:dio/dio.dart';

/// Extensão do [Response] do Dio para facilitar validação de sucesso.
extension ResponseExtension on Response<dynamic> {
  /// Verifica se a resposta foi bem-sucedida (status code 2xx).
  ///
  /// Retorna `true` se [statusCode] está entre 200 e 299 (inclusive).
  /// Retorna `false` se [statusCode] é null ou fora desse range.
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dio.get('/endpoint');
  /// if (response.isSuccessful) {
  ///   // Processar sucesso
  /// } else {
  ///   // Tratar erro
  /// }
  /// ```
  bool get isSuccessful =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
