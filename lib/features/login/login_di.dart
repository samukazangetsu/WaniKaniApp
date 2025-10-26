import 'package:get_it/get_it.dart';
import 'package:wanikani_app/features/login/data/datasources/wanikani_auth_datasource.dart';
import 'package:wanikani_app/features/login/data/repositories/user_repository.dart';
import 'package:wanikani_app/features/login/domain/repositories/iuser_repository.dart';
import 'package:wanikani_app/features/login/domain/usecases/get_user_usecase.dart';
import 'package:wanikani_app/features/login/presentation/cubits/login_cubit.dart';
import 'package:wanikani_app/features/login/presentation/cubits/splash_cubit.dart';

/// Configuração de dependências da feature de login.
///
/// Registra todas as dependências específicas do login:
/// - DataSources
/// - Repositories
/// - UseCases
/// - Cubits
///
/// Depende de [setupCoreDependencies] para Dio e LocalDataManager.
void setupLoginDependencies({required GetIt getIt}) {
  // DataSource
  getIt.registerLazySingleton<WaniKaniAuthDataSource>(
    () => WaniKaniAuthDataSource(getIt()),
  );

  // Repository (implementação da interface)
  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepository(datasource: getIt()),
  );

  // Use Case
  getIt.registerLazySingleton<GetUserUseCase>(
    () => GetUserUseCase(repository: getIt()),
  );

  // Cubits (factory para nova instância em cada uso)
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(getUserUseCase: getIt(), localDataManager: getIt()),
  );

  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(getUserUseCase: getIt(), localDataManager: getIt()),
  );
}
