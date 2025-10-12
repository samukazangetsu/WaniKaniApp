# Guia de Navegação do Codebase

> **Projeto:** WaniKani App  
> **Última Atualização:** 11/10/2025

---

## 📂 Visão Geral da Estrutura

```text
wanikani_app/
├── lib/                           # Código-fonte principal
│   ├── config/                    # Configuração de ambiente
│   ├── core/                      # Código compartilhado entre features
│   ├── features/                  # Features organizadas por domínio
│   ├── routing/                   # Configuração de navegação (go_router)
│   ├── main.dart                  # Entrypoint produção
│   └── main_mock.dart             # Entrypoint desenvolvimento (mocks)
│
├── assets/                        # Recursos estáticos
│   └── mock/                      # JSON files para mock de API
│
├── test/                          # Testes unitários e de integração
│   ├── core/                      # Tests do core
│   └── features/                  # Tests por feature
│
├── specs/                         # Documentação técnica
│   └── technical/                 # Docs arquiteturais
│       ├── adr/                   # Architectural Decision Records
│       ├── index.md               # Índice principal
│       ├── CLAUDE.meta.md         # Guia de desenvolvimento IA
│       ├── API_SPECIFICATION.md   # Docs da WaniKani API
│       ├── CONTRIBUTING.md        # Workflow de desenvolvimento
│       ├── TROUBLESHOOTING.md     # Solução de problemas
│       └── ARCHITECTURE_CHALLENGES.md  # Desafios e roadmap
│
├── android/                       # Código nativo Android
├── ios/                           # Código nativo iOS
├── pubspec.yaml                   # Dependências e assets
└── analysis_options.yaml          # Configuração de linting
```

---

## 🏗️ Estrutura Detalhada de `lib/`

### `lib/config/` - Configuração de Ambiente

**Propósito:** Configurar variáveis de ambiente, API keys, feature flags

```text
config/
└── (vazio - a ser implementado)

# Estrutura futura:
config/
├── app_config.dart           # Configurações globais
├── environment.dart          # Enum de ambientes (dev, staging, prod)
└── feature_flags.dart        # Feature toggles
```

**Quando usar:**

- Adicionar nova configuração de ambiente
- Gerenciar API base URLs
- Feature flags para A/B testing

---

### `lib/core/` - Código Compartilhado

**Propósito:** Código reutilizado por múltiplas features

```text
core/
├── database/                 # Configuração Drift (a implementar)
│   ├── app_database.dart     # Classe principal do banco
│   ├── tables/               # Definições de tabelas
│   └── daos/                 # Data Access Objects
│
├── error/                    # ✅ Error handling
│   ├── ierror.dart           # Interface base de erros
│   ├── api_error_entity.dart # Erros de API
│   └── internal_error_entity.dart  # Erros internos
│
├── mixins/                   # ✅ Mixins reutilizáveis
│   └── decode_model_mixin.dart  # Safe JSON parsing
│
├── network/                  # Configuração de rede (a implementar)
│   ├── dio_client.dart       # Dio configurado
│   ├── interceptors/         # Auth, logging, retry
│   └── api_endpoints.dart    # URLs da API
│
├── theme/                    # Design system (a implementar)
│   ├── app_colors.dart       # Paleta de cores
│   ├── app_text_styles.dart  # Tipografia
│   └── app_theme.dart        # ThemeData
│
└── strings/                  # Strings compartilhadas (a implementar)
    └── common_strings.dart
```

**Arquivos-Chave:**

#### `core/error/ierror.dart`

```dart
/// Interface base para todos os erros no app
abstract class IError {
  /// Mensagem do erro para exibir ao usuário
  String get message;
}
```

**Uso:**

```dart
// Em repositories, use cases, cubits
Future<Either<IError, AssignmentEntity>> getAssignment(int id) async {
  // Retorna Left(IError) em caso de erro
  // Retorna Right(AssignmentEntity) em sucesso
}
```

#### `core/mixins/decode_model_mixin.dart`

```dart
/// Mixin para decodificação segura de JSON com logging de erros
mixin DecodeModelMixin {
  T tryDecode<T>(
    T Function() decodeFunction, {
    required T Function(Object exception) orElse,
  }) {
    try {
      return decodeFunction();
    } catch (exception) {
      FlutterError.reportError(FlutterErrorDetails(exception: exception));
      return orElse(exception);
    }
  }
}
```

**Uso:**

```dart
class AssignmentRepository with DecodeModelMixin {
  Future<Either<IError, List<AssignmentEntity>>> getAll() async {
    final response = await _datasource.getAssignments();
    
    return tryDecode(
      () {
        if (response.isSuccessful) {
          final list = (response.data['data'] as List)
              .map((e) => AssignmentModel.fromJson(e))
              .toList();
          return Right(list);
        }
        return Left(ApiErrorEntity.fromResponse(response));
      },
      orElse: (e) => Left(InternalErrorEntity(message: 'Parse error')),
    );
  }
}
```

---

### `lib/features/` - Features por Domínio

**Propósito:** Cada feature é um módulo isolado seguindo Clean Architecture

```text
features/
├── home/                     # ✅ Estrutura criada (vazia)
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/    # Interfaces
│   │   └── usecases/
│   └── presentation/
│       ├── cubits/
│       └── screens/
│
└── (futuras features a implementar)
    ├── dashboard/
    ├── assignments/
    ├── statistics/
    └── settings/
```

**Anatomia de uma Feature Completa:**

```text
<feature>/
├── data/                          # Camada de dados (infra)
│   ├── datasources/
│   │   └── <feature>_datasource.dart      # Chamadas à API/DB
│   ├── models/
│   │   └── <feature>_model.dart           # Serialização JSON
│   └── repositories/
│       └── <feature>_repository.dart      # Implementação de interfaces
│
├── domain/                        # Camada de domínio (regras de negócio)
│   ├── entities/
│   │   └── <feature>_entity.dart          # Objetos de negócio puros
│   ├── repositories/
│   │   └── i_<feature>_repository.dart    # Contratos/interfaces
│   └── usecases/
│       ├── get_<feature>.dart             # Casos de uso (ações)
│       └── update_<feature>.dart
│
└── presentation/                  # Camada de apresentação (UI)
    ├── cubits/
    │   ├── <feature>_cubit.dart           # Gerenciamento de estado
    │   └── <feature>_state.dart           # Estados da UI
    ├── screens/
    │   └── <feature>_screen.dart          # Telas principais
    └── widgets/
        └── <feature>_widget.dart          # Widgets reutilizáveis
```

**Fluxo de Dados (Bottom-Up):**

```text
1. Entity (domain/)           ← Regra de negócio pura
        ↓
2. Repository Interface       ← Contrato abstrato
        ↓
3. UseCase                    ← Orquestração
        ↓
4. Model (data/)              ← Serialização
        ↓
5. DataSource                 ← Acesso à API/DB
        ↓
6. Repository Implementation  ← Implementa contrato
        ↓
7. Cubit (presentation/)      ← Gerencia estado
        ↓
8. Screen/Widget              ← Renderiza UI
```

**Exemplo Completo: Feature "Assignment"**

```dart
// 1. Entity (domain/entities/assignment_entity.dart)
class AssignmentEntity {
  final int id;
  final int subjectId;
  final String subjectType; // kanji, radical, vocabulary
  final int srsStage;       // 0-9
  final DateTime? availableAt;

  AssignmentEntity({/* ... */});
}

// 2. Repository Interface (domain/repositories/i_assignment_repository.dart)
abstract class IAssignmentRepository {
  Future<Either<IError, List<AssignmentEntity>>> getAll();
  Future<Either<IError, AssignmentEntity>> getById(int id);
}

// 3. UseCase (domain/usecases/get_assignments.dart)
class GetAssignmentsUseCase {
  final IAssignmentRepository _repository;
  
  GetAssignmentsUseCase({required IAssignmentRepository repository})
      : _repository = repository;
  
  Future<Either<IError, List<AssignmentEntity>>> call() => 
      _repository.getAll();
}

// 4. Model (data/models/assignment_model.dart)
extension type AssignmentModel(AssignmentEntity entity) 
    implements AssignmentEntity {
  AssignmentModel.fromJson(Map<String, dynamic> json)
      : entity = AssignmentEntity(
          id: json['id'],
          subjectId: json['data']['subject_id'],
          subjectType: json['data']['subject_type'],
          srsStage: json['data']['srs_stage'],
          availableAt: json['data']['available_at'] != null
              ? DateTime.parse(json['data']['available_at'])
              : null,
        );
}

// 5. DataSource (data/datasources/assignment_datasource.dart)
class AssignmentDataSource {
  final Dio _dio;
  
  Future<Response> getAssignments() => _dio.get('/assignments');
}

// 6. Repository Implementation (data/repositories/assignment_repository.dart)
class AssignmentRepository 
    with DecodeModelMixin 
    implements IAssignmentRepository {
  
  final AssignmentDataSource _datasource;
  final AssignmentDao _dao; // Drift DAO
  
  @override
  Future<Either<IError, List<AssignmentEntity>>> getAll() async {
    // 1. Verificar cache
    final cached = await _dao.getAll();
    if (cached.isNotEmpty && !_isExpired(cached.first)) {
      return Right(cached);
    }
    
    // 2. Fetch da API
    final response = await _datasource.getAssignments();
    
    return tryDecode(
      () {
        if (response.statusCode == 200) {
          final list = (response.data['data'] as List)
              .map((e) => AssignmentModel.fromJson(e))
              .toList();
          
          // 3. Salvar no cache
          _dao.upsertAll(list);
          
          return Right(list);
        }
        return Left(ApiErrorEntity.fromResponse(response));
      },
      orElse: (e) => Left(InternalErrorEntity(message: e.toString())),
    );
  }
}

// 7. State (presentation/cubits/assignments_state.dart)
sealed class AssignmentsState extends Equatable {
  const AssignmentsState();
  @override
  List<Object?> get props => [];
}

final class AssignmentsInitial extends AssignmentsState {}
final class AssignmentsLoading extends AssignmentsState {}

final class AssignmentsLoaded extends AssignmentsState {
  final List<AssignmentEntity> assignments;
  const AssignmentsLoaded({required this.assignments});
  @override
  List<Object> get props => [assignments];
}

final class AssignmentsError extends AssignmentsState {
  final String message;
  const AssignmentsError({required this.message});
  @override
  List<Object> get props => [message];
}

// 8. Cubit (presentation/cubits/assignments_cubit.dart)
class AssignmentsCubit extends Cubit<AssignmentsState> {
  final GetAssignmentsUseCase _getAssignments;
  
  AssignmentsCubit({required GetAssignmentsUseCase getAssignments})
      : _getAssignments = getAssignments,
        super(AssignmentsInitial());
  
  Future<void> loadAssignments() async {
    emit(AssignmentsLoading());
    
    final result = await _getAssignments();
    
    result.fold(
      (error) => emit(AssignmentsError(message: error.message)),
      (assignments) => emit(AssignmentsLoaded(assignments: assignments)),
    );
  }
}

// 9. Screen (presentation/screens/assignments_screen.dart)
class AssignmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AssignmentsCubit>()..loadAssignments(),
      child: Scaffold(
        appBar: AppBar(title: Text('Assignments')),
        body: BlocBuilder<AssignmentsCubit, AssignmentsState>(
          builder: (context, state) {
            return switch (state) {
              AssignmentsInitial() => SizedBox.shrink(),
              AssignmentsLoading() => Center(child: CircularProgressIndicator()),
              AssignmentsLoaded(:final assignments) => ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return ListTile(
                    title: Text('Subject ${assignment.subjectId}'),
                    subtitle: Text('SRS Stage: ${assignment.srsStage}'),
                  );
                },
              ),
              AssignmentsError(:final message) => Center(
                child: Text(message, style: TextStyle(color: Colors.red)),
              ),
            };
          },
        ),
      ),
    );
  }
}
```

---

### `lib/routing/` - Navegação

**Propósito:** Configuração centralizada de rotas (go_router)

```text
routing/
└── (a implementar)
    ├── app_router.dart        # Configuração do GoRouter
    ├── route_names.dart       # Enum de rotas
    └── route_guards.dart      # Guards de autenticação
```

**Exemplo (futuro):**

```dart
// routing/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardScreen(),
    ),
    GoRoute(
      path: '/assignments/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AssignmentDetailScreen(id: id);
      },
    ),
  ],
  redirect: (context, state) {
    // Auth guard
    final isAuthenticated = GetIt.I<AuthService>().isAuthenticated;
    if (!isAuthenticated && state.location != '/login') {
      return '/login';
    }
    return null;
  },
);

// Navegação:
context.go('/dashboard');
context.push('/assignments/123');
context.pop();
```

---

### `lib/main.dart` vs `lib/main_mock.dart`

**`main.dart` - Produção:**

```dart
void main() {
  // Setup dependencies
  setupDependencies(
    apiBaseUrl: 'https://api.wanikani.com/v2',
    useMocks: false,
  );
  
  runApp(MyApp());
}
```

**`main_mock.dart` - Desenvolvimento:**

```dart
void main() {
  // Setup com mocks
  setupDependencies(
    apiBaseUrl: '', // Não usado
    useMocks: true, // Interceptor lê de assets/mock/
  );
  
  runApp(MyApp());
}
```

**Rodar:**

```bash
# Desenvolvimento (mocks)
flutter run lib/main_mock.dart

# Produção (API real)
flutter run lib/main.dart
```

---

## 🗂️ Assets

### `assets/mock/` - Mock Data

**Propósito:** JSON files para desenvolvimento sem depender da API

```text
assets/mock/
├── all_assignments.json         # Lista de assignments
├── assignment.json              # Assignment individual
├── all_level_progression.json   # Progressões de nível
├── level_progression.json       # Progressão individual
├── all_review_statistics.json   # Estatísticas de review
└── review_statistics.json       # Estatística individual
```

**Estrutura de um Mock (exemplo):**

```json
// assets/mock/assignment.json
{
  "id": 80463006,
  "object": "assignment",
  "url": "https://api.wanikani.com/v2/assignments/80463006",
  "data_updated_at": "2017-10-30T01:51:10.438432Z",
  "data": {
    "created_at": "2017-09-05T23:38:10.695133Z",
    "subject_id": 8761,
    "subject_type": "kanji",
    "srs_stage": 8,
    "unlocked_at": "2017-09-05T23:38:10.695133Z",
    "started_at": "2017-09-05T23:41:28.980679Z",
    "passed_at": "2017-09-07T17:14:14.491889Z",
    "burned_at": null,
    "available_at": "2018-02-27T00:00:00.000000Z",
    "resurrected_at": null,
    "hidden": false
  }
}
```

**Uso:**

```dart
// Interceptor lê JSON baseado no endpoint
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('assignments')) {
      final json = await rootBundle.loadString('assets/mock/all_assignments.json');
      final data = jsonDecode(json);
      return handler.resolve(Response(
        requestOptions: options,
        data: data,
        statusCode: 200,
      ));
    }
    super.onRequest(options, handler);
  }
}
```

---

## 🧪 Testes

### `test/` - Estrutura de Testes

```text
test/
├── core/                      # Tests de código compartilhado
│   ├── error/
│   │   └── ierror_test.dart
│   └── mixins/
│       └── decode_model_mixin_test.dart
│
└── features/                  # Tests por feature (espelha lib/)
    └── <feature>/
        ├── data/
        │   ├── datasources/
        │   │   └── <feature>_datasource_test.dart
        │   ├── models/
        │   │   └── <feature>_model_test.dart
        │   └── repositories/
        │       └── <feature>_repository_test.dart
        ├── domain/
        │   └── usecases/
        │       └── get_<feature>_test.dart
        └── presentation/
            └── cubits/
                └── <feature>_cubit_test.dart
```

**Exemplo de Teste:**

```dart
// test/features/assignments/domain/usecases/get_assignments_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssignmentRepository extends Mock implements IAssignmentRepository {}

void main() {
  late GetAssignmentsUseCase useCase;
  late MockAssignmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssignmentRepository();
    useCase = GetAssignmentsUseCase(repository: mockRepository);
  });

  group('GetAssignmentsUseCase', () {
    final tAssignments = [
      AssignmentEntity(id: 1, subjectId: 100, subjectType: 'kanji', srsStage: 5),
    ];

    test('should get assignments from repository', () async {
      // Arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(tAssignments));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(Right<IError, List<AssignmentEntity>>(tAssignments)));
      verify(() => mockRepository.getAll()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return error when repository fails', () async {
      // Arrange
      final tError = ApiErrorEntity(message: 'Network error', statusCode: 500);
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Left(tError));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(Left<IError, List<AssignmentEntity>>(tError)));
    });
  });
}
```

---

## 🎯 Pontos de Integração

### 1. Dependency Injection (GetIt)

**Arquivo (futuro):** `lib/core/di/service_locator.dart`

```dart
final getIt = GetIt.instance;

void setupDependencies({
  required String apiBaseUrl,
  required bool useMocks,
}) {
  // 1. Core
  getIt.registerLazySingleton(() => Dio(BaseOptions(baseUrl: apiBaseUrl)));
  
  if (useMocks) {
    getIt<Dio>().interceptors.add(MockInterceptor());
  }
  
  // 2. Database
  getIt.registerLazySingleton(() => AppDatabase());
  
  // 3. Feature: Assignments
  getIt.registerLazySingleton(() => AssignmentDataSource(dio: getIt()));
  getIt.registerLazySingleton(() => AssignmentDao(database: getIt()));
  getIt.registerLazySingleton<IAssignmentRepository>(
    () => AssignmentRepository(
      datasource: getIt(),
      dao: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetAssignmentsUseCase(repository: getIt()));
  getIt.registerFactory(() => AssignmentsCubit(getAssignments: getIt()));
}
```

### 2. WaniKani API Integration

**Base URL:** `https://api.wanikani.com/v2`

**Headers:**

```dart
{
  'Authorization': 'Bearer <api_token>',
  'Wanikani-Revision': '20170710',
}
```

**Endpoints Principais:**

- `GET /assignments` - Lista de assignments
- `GET /level_progressions` - Progressão de níveis
- `GET /review_statistics` - Estatísticas de reviews
- `GET /subjects/:id` - Detalhes de um subject (kanji, radical, vocab)

**Ver:** [API_SPECIFICATION.md](API_SPECIFICATION.md) para detalhes completos

### 3. Database (Drift)

**Arquivo (futuro):** `lib/core/database/app_database.dart`

```dart
@DriftDatabase(
  tables: [Assignments, LevelProgressions, ReviewStatistics],
  daos: [AssignmentDao, LevelProgressionDao, ReviewStatisticsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'wanikani.sqlite'));
      return NativeDatabase(file);
    });
  }
}
```

---

## 🔍 Como Encontrar...

### "Onde adicionar uma nova feature?"

```text
1. Criar estrutura em lib/features/<nome>/
2. Seguir template: data/domain/presentation
3. Registrar DI em service_locator.dart
4. Adicionar rota em routing/app_router.dart
5. Adicionar mock em assets/mock/ (se aplicável)
```

### "Onde adicionar um novo endpoint da API?"

```text
1. Adicionar método em data/datasources/<feature>_datasource.dart
2. Criar model em data/models/<feature>_model.dart
3. Implementar em repository
4. Criar use case em domain/usecases/
5. Adicionar mock JSON em assets/mock/
```

### "Onde adicionar uma nova tela?"

```text
1. Criar screen em features/<feature>/presentation/screens/
2. Criar cubit em features/<feature>/presentation/cubits/
3. Adicionar rota em routing/app_router.dart
4. Registrar cubit no DI (GetIt)
```

### "Onde adicionar um tema/cor?"

```text
1. core/theme/app_colors.dart - adicionar cor
2. core/theme/app_theme.dart - atualizar ThemeData
3. Usar em widgets: Theme.of(context).colorScheme.primary
```

### "Onde adicionar uma string compartilhada?"

```text
1. core/strings/common_strings.dart
2. Evitar hardcoded strings - sempre centralizar
```

---

## 📖 Referências

- [Project Charter](project_charter.md) - Visão e escopo do projeto
- [ADRs](adr/) - Decisões arquiteturais documentadas
- [CLAUDE.meta.md](CLAUDE.meta.md) - Padrões de código para desenvolvimento IA
- [API_SPECIFICATION.md](API_SPECIFICATION.md) - Documentação da WaniKani API
- [CONTRIBUTING.md](CONTRIBUTING.md) - Workflow de desenvolvimento
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Solução de problemas

---

**Última Revisão:** 11/10/2025
