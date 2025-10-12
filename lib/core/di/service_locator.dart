import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wanikani_app/core/network/interceptors/mock_interceptor.dart';
import 'package:wanikani_app/features/home/data/datasources/wanikani_datasource.dart';
import 'package:wanikani_app/features/home/data/repositories/home_repository.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_assignment_metrics_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';

/// Instância global do GetIt para dependency injection.
final GetIt getIt = GetIt.instance;

/// Configuração de todas as dependências da aplicação.
///
/// Deve ser chamado em `main()` antes de `runApp()`.
///
/// Parâmetros:
/// - [useMock]: Se `true`, configura Dio com MockInterceptor.
///              Se `false`, configura Dio com API real.
void setupDependencies({required bool useMock}) {
  // 1. External - Dio
  if (useMock) {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: '', // Vazio em modo mock
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      )..interceptors.add(MockInterceptor()),
    );
  } else {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.wanikani.com/v2',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: <String, String>{
            'Authorization':
                'Bearer 9b7c4629-4cc5-4ebb-98ad-8c33608cb455', // TODO: Mover para secure storage
          },
        ),
      ),
    );
  }

  // 2. Datasources
  getIt.registerLazySingleton<WaniKaniDataSource>(
    () => WaniKaniDataSource(dio: getIt<Dio>()),
  );

  // 3. Repositories
  getIt.registerLazySingleton<IHomeRepository>(
    () => HomeRepository(datasource: getIt<WaniKaniDataSource>()),
  );

  // 4. Use Cases
  getIt.registerLazySingleton<GetCurrentLevelUseCase>(
    () => GetCurrentLevelUseCase(repository: getIt<IHomeRepository>()),
  );
  getIt.registerLazySingleton<GetAssignmentMetricsUseCase>(
    () => GetAssignmentMetricsUseCase(repository: getIt<IHomeRepository>()),
  );

  // 5. Cubits (factory para criar nova instância cada vez)
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getCurrentLevel: getIt<GetCurrentLevelUseCase>(),
      getAssignmentMetrics: getIt<GetAssignmentMetricsUseCase>(),
    ),
  );
}

/// Limpa todas as dependências registradas.
///
/// Útil para testes e hot restart.
void resetDependencies() {
  getIt.reset();
}
