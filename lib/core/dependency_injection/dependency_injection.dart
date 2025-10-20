import 'package:get_it/get_it.dart';
import 'package:wanikani_app/core/dependency_injection/core_di.dart';
import 'package:wanikani_app/core/dependency_injection/features/home_di.dart';

/// Instância global do GetIt para dependency injection.
final GetIt getIt = GetIt.instance;

/// Configuração de todas as dependências da aplicação.
///
/// Deve ser chamado em `main()` antes de `runApp()`.
///
/// Orquestra a inicialização de:
/// 1. Core dependencies (Dio, Interceptors)
/// 2. Feature dependencies (Home, Reviews, Lessons, etc.)
///
/// Parâmetros:
/// - [useMock]: Se `true`, configura Dio com MockInterceptor.
///              Se `false`, configura Dio com API real.
///
/// Exemplo:
/// ```dart
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///   setupDependencies(useMock: false);
///   runApp(MyApp());
/// }
/// ```
void setupDependencies({required bool useMock}) {
  // 1. Core (Dio, Interceptors)
  setupCoreDependencies(getIt: getIt, useMock: useMock);

  // 2. Features
  setupHomeDependencies(getIt: getIt);

  // [FUTURO] Adicionar outras features aqui:
  // setupReviewsDependencies(getIt: getIt);
  // setupLessonsDependencies(getIt: getIt);
  // setupSettingsDependencies(getIt: getIt);
}

/// Limpa todas as dependências registradas.
///
/// Útil para testes e hot restart.
void resetDependencies() {
  getIt.reset();
}
