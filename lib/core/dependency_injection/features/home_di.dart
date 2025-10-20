import 'package:get_it/get_it.dart';
import 'package:wanikani_app/features/home/data/datasources/wanikani_datasource.dart';
import 'package:wanikani_app/features/home/data/repositories/home_repository.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_lesson_stats_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_review_stats_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';

/// Configuração de dependências da feature Home.
///
/// Registra a cadeia completa:
/// - Datasources (WaniKaniDataSource)
/// - Repositories (HomeRepository)
/// - Use Cases (GetCurrentLevel, GetReviewStats, GetLessonStats)
/// - Cubits (HomeCubit)
void setupHomeDependencies({required GetIt getIt}) {
  // 1. Datasources
  getIt.registerLazySingleton<WaniKaniDataSource>(
    () => WaniKaniDataSource(dio: getIt()),
  );

  // 2. Repositories
  getIt.registerLazySingleton<IHomeRepository>(
    () => HomeRepository(datasource: getIt()),
  );

  // 3. Use Cases
  getIt.registerLazySingleton<GetCurrentLevelUseCase>(
    () => GetCurrentLevelUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetReviewStatsUseCase>(
    () => GetReviewStatsUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetLessonStatsUseCase>(
    () => GetLessonStatsUseCase(repository: getIt()),
  );

  // 4. Cubits
  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(
      getCurrentLevel: getIt(),
      getReviewStats: getIt(),
      getLessonStats: getIt(),
    ),
  );
}
