# Feature: Home/Dashboard - MVP

## POR QUE

### Objetivo Principal
Criar a primeira funcionalidade do aplicativo WaniKani App, estabelecendo a fundação arquitetural que será reutilizada em todas as features futuras.

### Razões para Construir
1. **Implementar Arquitetura Base**: Estabelecer navegação (go_router), injeção de dependências (GetIt), networking (Dio + pop_network) e padrões de state management (BLoC/Cubit)
2. **Validar Padrões**: Testar a aplicação prática de Clean Architecture por features antes de expandir para funcionalidades mais complexas
3. **Feedback Rápido**: Fornecer valor imediato ao usuário mostrando informações essenciais do progresso de estudo
4. **Base para TDD**: Estabelecer práticas de Test-Driven Development desde o início do projeto

---

## O QUE

### Funcionalidade a Ser Construída

#### 1. Tela Home/Dashboard
Uma tela única que exibe três métricas principais do progresso do usuário no WaniKani:

**Dados Exibidos:**
- **Nível Atual**: Nível de progressão do usuário (1-60)
- **Itens para Revisar**: Contagem de assignments disponíveis para review hoje
- **Novos Itens para Aprender**: Contagem de assignments ainda não iniciados (lessons)

**UI/UX:**
- Layout simples com cards para cada métrica
- Loading state (CircularProgressIndicator) durante fetch de dados
- Error state com Dialog e botão de retry manual
- SEM pull-to-refresh
- SEM navegação para outras telas (por enquanto)

#### 2. Integração com API WaniKani

**Endpoints Utilizados:**
- `GET /level_progressions` - Obter nível atual (último registro com `started_at != null`)
- `GET /assignments` - Obter assignments para calcular:
  - Reviews: `available_at <= DateTime.now()`
  - Lessons: `srs_stage == 0`

**Autenticação:**
- Token da API **hardcoded** no código (simplificação temporária)
- Header: `Authorization: Bearer <token>`

**Ambiente:**
- Desenvolvimento usando `main_mock.dart` com JSONs em `assets/mock/`
- Mocks já existentes: `all_assignments.json`, `all_level_progression.json`

#### 3. Arquitetura a Implementar

**Navegação (go_router):**
```
lib/routing/
└── app_router.dart          # Configuração do GoRouter
    └── Rota única: '/' → HomeScreen
```

**Dependency Injection (GetIt):**
```
lib/core/di/
└── service_locator.dart     # Setup completo de DI
    ├── Dio + pop_network configuration
    ├── Mock interceptor para desenvolvimento
    ├── Datasources (WaniKani API)
    ├── Repositories (implementações)
    ├── UseCases
    └── Cubits (factories)
```

**Feature Home:**
```
lib/features/home/
├── data/
│   ├── datasources/
│   │   └── wanikani_datasource.dart           # Chamadas à API
│   ├── models/
│   │   ├── assignment_model.dart              # Extension type
│   │   └── level_progression_model.dart       # Extension type
│   └── repositories/
│       └── home_repository.dart               # Implementa IHomeRepository
├── domain/
│   ├── entities/
│   │   ├── assignment_entity.dart             # Pure Dart class
│   │   ├── level_progression_entity.dart      # Pure Dart class
│   │   └── dashboard_data_entity.dart         # Agregado com métricas
│   ├── repositories/
│   │   └── i_home_repository.dart             # Interface
│   └── usecases/
│       ├── get_current_level_usecase.dart     # Obtém nível atual
│       ├── get_review_count_usecase.dart      # Conta reviews disponíveis
│       └── get_lesson_count_usecase.dart      # Conta lessons disponíveis
└── presentation/
    ├── cubits/
    │   ├── home_cubit.dart                    # State management
    │   └── home_state.dart                    # Sealed states
    ├── screens/
    │   └── home_screen.dart                   # Tela principal
    └── widgets/
        ├── dashboard_metric_card.dart         # Card reutilizável
        └── error_dialog.dart                  # Dialog de erro
```

#### 4. Estados do Cubit

```dart
sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {}
final class HomeLoading extends HomeState {}
final class HomeError extends HomeState {
  final String message;
}
final class HomeLoaded extends HomeState {
  final int currentLevel;
  final int reviewCount;
  final int lessonCount;
}
```

#### 5. Testing (TDD)

**Testes a Serem Escritos ANTES da Implementação:**

```
test/features/home/
├── data/
│   ├── models/
│   │   ├── assignment_model_test.dart
│   │   └── level_progression_model_test.dart
│   └── repositories/
│       └── home_repository_test.dart
├── domain/
│   └── usecases/
│       ├── get_current_level_usecase_test.dart
│       ├── get_review_count_usecase_test.dart
│       └── get_lesson_count_usecase_test.dart
└── presentation/
    └── cubits/
        └── home_cubit_test.dart
```

**Cobertura mínima:** 80%

### Funcionalidades Existentes Afetadas

**pubspec.yaml:**
- Adicionar `assets/mock/` em `flutter.assets`

**main.dart vs main_mock.dart:**
- Configurar `main_mock.dart` como entrypoint padrão durante desenvolvimento
- Usar mock interceptor para ler JSONs locais

---

## COMO

### Implementação Passo a Passo (TDD)

#### Fase 1: Setup de Infraestrutura
1. **Atualizar pubspec.yaml** para incluir `assets/mock/`
2. **Criar routing/app_router.dart** com go_router
3. **Criar core/di/service_locator.dart** com GetIt
4. **Configurar Dio + pop_network** com mock interceptor

#### Fase 2: Domain Layer (Test First)
1. **Escrever testes** para entities (validação de dados)
2. **Criar entities**: `AssignmentEntity`, `LevelProgressionEntity`, `DashboardDataEntity`
3. **Escrever testes** para repository interface (contratos)
4. **Criar interface** `IHomeRepository` com métodos:
   - `Future<Either<IError, List<LevelProgressionEntity>>> getLevelProgressions()`
   - `Future<Either<IError, List<AssignmentEntity>>> getAssignments()`
5. **Escrever testes** para use cases (mockar repository)
6. **Criar use cases**:
   - `GetCurrentLevelUseCase` - filtra último level com `started_at != null`
   - `GetReviewCountUseCase` - conta assignments com `available_at <= now`
   - `GetLessonCountUseCase` - conta assignments com `srs_stage == 0`

#### Fase 3: Data Layer (Test First)
1. **Escrever testes** para models (JSON serialization)
2. **Criar models** como extension types:
   - `AssignmentModel.fromJson()` / `toJson()`
   - `LevelProgressionModel.fromJson()` / `toJson()`
3. **Escrever testes** para datasource (mockar Dio)
4. **Criar datasource** `WaniKaniDataSource`:
   - `Future<Response> getLevelProgressions()`
   - `Future<Response> getAssignments()`
5. **Escrever testes** para repository (mockar datasource)
6. **Implementar repository** `HomeRepository`:
   - Chamar datasource
   - Converter Response → Models → Entities
   - Retornar `Either<IError, T>`
   - Tratar erros (network, parsing, API errors)

#### Fase 4: Presentation Layer (Test First)
1. **Escrever testes** para cubit com bloc_test:
   - `loadDashboardData()` → success path
   - `loadDashboardData()` → error path
   - `retry()` → reload data
2. **Criar states** `HomeState` (sealed class)
3. **Criar cubit** `HomeCubit`:
   - Injetar use cases
   - Método `loadDashboardData()` que chama os 3 use cases
   - Emitir states apropriados (Loading, Loaded, Error)
4. **Criar widgets**:
   - `DashboardMetricCard` (recebe título, valor, ícone)
   - `ErrorDialog` (recebe mensagem, callback de retry)
5. **Criar screen** `HomeScreen`:
   - BlocProvider com GetIt
   - BlocConsumer para states + side effects (dialog)
   - Switch expression para renderizar estados

#### Fase 5: Dependency Injection
1. **Registrar todas as dependências** em `service_locator.dart`:
```dart
void setupDependencies() {
  // Dio
  getIt.registerLazySingleton(() => Dio(BaseOptions(
    baseUrl: 'https://api.wanikani.com/v2',
  ))..interceptors.add(MockInterceptor())); // Mock em dev
  
  // Datasources
  getIt.registerLazySingleton(() => WaniKaniDataSource(dio: getIt()));
  
  // Repositories
  getIt.registerLazySingleton<IHomeRepository>(
    () => HomeRepository(datasource: getIt()),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => GetCurrentLevelUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => GetReviewCountUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => GetLessonCountUseCase(repository: getIt()));
  
  // Cubits (factory)
  getIt.registerFactory(() => HomeCubit(
    getCurrentLevel: getIt(),
    getReviewCount: getIt(),
    getLessonCount: getIt(),
  ));
}
```

#### Fase 6: Navegação
1. **Configurar AppRouter**:
```dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
```
2. **Usar no MaterialApp**:
```dart
MaterialApp.router(
  routerConfig: appRouter,
  // ...
)
```

#### Fase 7: Mock Interceptor
1. **Criar interceptor** para ler JSONs locais:
```dart
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String mockPath;
    if (options.path.contains('level_progressions')) {
      mockPath = 'assets/mock/all_level_progression.json';
    } else if (options.path.contains('assignments')) {
      mockPath = 'assets/mock/all_assignments.json';
    }
    
    final jsonString = await rootBundle.loadString(mockPath);
    final data = jsonDecode(jsonString);
    
    handler.resolve(Response(
      requestOptions: options,
      data: data,
      statusCode: 200,
    ));
  }
}
```

### Detalhes de Implementação

#### Cálculo das Métricas

**Nível Atual:**
```dart
// Pegar último level progression com started_at != null
final progressions = await repository.getLevelProgressions();
progressions.fold(
  (error) => /* handle error */,
  (levels) {
    final currentLevel = levels
        .where((l) => l.startedAt != null)
        .reduce((a, b) => a.level > b.level ? a : b)
        .level;
  },
);
```

**Review Count:**
```dart
// Contar assignments com available_at <= agora
final assignments = await repository.getAssignments();
assignments.fold(
  (error) => /* handle error */,
  (items) {
    final now = DateTime.now();
    final reviewCount = items
        .where((a) => a.availableAt != null && 
                      a.availableAt!.isBefore(now))
        .length;
  },
);
```

**Lesson Count:**
```dart
// Contar assignments com srs_stage == 0
final lessonCount = items.where((a) => a.srsStage == 0).length;
```

#### Error Handling

**No Repository:**
```dart
try {
  final response = await _datasource.getAssignments();
  if (response.statusCode == 200) {
    final list = (response.data['data'] as List)
        .map((e) => AssignmentModel.fromJson(e))
        .toList();
    return Right(list);
  }
  return Left(ApiErrorEntity.fromResponse(response));
} catch (e) {
  return Left(InternalErrorEntity('Failed to fetch: $e'));
}
```

**Na UI:**
```dart
BlocConsumer<HomeCubit, HomeState>(
  listener: (context, state) {
    if (state is HomeError) {
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(
          message: state.message,
          onRetry: () {
            context.read<HomeCubit>().loadDashboardData();
          },
        ),
      );
    }
  },
  builder: (context, state) => switch (state) {
    HomeInitial() => SizedBox.shrink(),
    HomeLoading() => Center(child: CircularProgressIndicator()),
    HomeError() => Center(child: Text('Erro ao carregar')),
    HomeLoaded(:final currentLevel, :final reviewCount, :final lessonCount) =>
      Column(
        children: [
          DashboardMetricCard(title: 'Nível', value: currentLevel),
          DashboardMetricCard(title: 'Reviews', value: reviewCount),
          DashboardMetricCard(title: 'Lessons', value: lessonCount),
        ],
      ),
  },
)
```

### Padrões e Convenções

**Seguir rigorosamente:**
- ✅ Clean Architecture (data/domain/presentation)
- ✅ Either<IError, T> para error handling
- ✅ Extension types para models
- ✅ Sealed classes para states
- ✅ Switch expressions para state matching
- ✅ Dependency injection via GetIt
- ✅ TDD: testes antes da implementação
- ✅ Package imports (nunca relative)
- ✅ 80 caracteres por linha
- ✅ Single quotes para strings
- ✅ Tipos explícitos sempre

**Evitar:**
- ❌ Business logic em widgets
- ❌ Flutter imports no domain layer
- ❌ Dynamic types
- ❌ Múltiplas entities por arquivo
- ❌ Cache/Drift (deixar para depois)

### Validação de Conclusão

**Checklist de Done:**
- [ ] Todos os testes passando (> 80% coverage)
- [ ] `flutter analyze` sem erros
- [ ] `dart format .` aplicado
- [ ] Home screen exibe 3 métricas corretamente
- [ ] Loading state visível durante fetch
- [ ] Error dialog aparece em caso de falha
- [ ] Retry funciona corretamente
- [ ] Mock interceptor lendo JSONs locais
- [ ] Service locator configurado
- [ ] go_router funcionando
- [ ] Código segue todos os padrões documentados

---

**Documentos Relacionados:**
- [CLAUDE.meta.md](../CLAUDE.meta.md) - Padrões de código
- [CODEBASE_GUIDE.md](../CODEBASE_GUIDE.md) - Navegação do código
- [API_SPECIFICATION.md](../API_SPECIFICATION.md) - Especificação da API WaniKani

**Última Atualização:** 11/10/2025
