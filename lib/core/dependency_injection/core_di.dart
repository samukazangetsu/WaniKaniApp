import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wanikani_app/core/network/interceptors/auth_interceptor.dart';
import 'package:wanikani_app/core/network/interceptors/logging_interceptor.dart';
import 'package:wanikani_app/core/network/interceptors/mock_interceptor.dart';
import 'package:wanikani_app/core/storage/local_data_manager.dart';

/// Configuração de dependências da camada core
/// (network, storage, interceptors).
///
/// Registra:
/// - [LocalDataManager] para armazenamento seguro
/// - [Dio] com configuração adequada para mock ou produção
/// - [AuthInterceptor] para injetar token automaticamente (somente produção)
/// - [LoggingInterceptor] para logs de requisições/respostas
/// - [MockInterceptor] se em modo mock
void setupCoreDependencies({required GetIt getIt, required bool useMock}) {
  // Registrar LocalDataManager como singleton (compartilhado)
  getIt.registerLazySingleton<LocalDataManager>(LocalDataManager.new);

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
      () =>
          Dio(
              BaseOptions(
                baseUrl: 'https://api.wanikani.com/v2',
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                // ✅ Header Authorization agora é injetado por AuthInterceptor
              ),
            )
            ..interceptors.add(AuthInterceptor(getIt<LocalDataManager>()))
            ..interceptors.add(LoggingInterceptor(isMockMode: false)),
    );
  }
}
