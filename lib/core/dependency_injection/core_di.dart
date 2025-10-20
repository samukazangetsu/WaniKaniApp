import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wanikani_app/api_token.dart';
import 'package:wanikani_app/core/network/interceptors/logging_interceptor.dart';
import 'package:wanikani_app/core/network/interceptors/mock_interceptor.dart';

/// Configuração de dependências da camada core (network, interceptors).
///
/// Registra:
/// - [Dio] com configuração adequada para mock ou produção
/// - [LoggingInterceptor] para logs de requisições/respostas
/// - [MockInterceptor] se em modo mock
void setupCoreDependencies({required GetIt getIt, required bool useMock}) {
  // Configurar Dio
  if (useMock) {
    getIt.registerLazySingleton<Dio>(
      () =>
          Dio(
              BaseOptions(
                baseUrl: '', // Vazio em modo mock
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            )
            ..interceptors.add(MockInterceptor())
            ..interceptors.add(LoggingInterceptor(isMockMode: true)),
    );
  } else {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.wanikani.com/v2',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: <String, String>{
            // TODO(security): Mover para secure storage
            'Authorization': apiToken,
          },
        ),
      )..interceptors.add(LoggingInterceptor(isMockMode: false)),
    );
  }
}
