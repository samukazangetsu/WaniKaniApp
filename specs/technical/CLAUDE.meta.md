# CLAUDE.meta.md - Guia de Desenvolvimento com IA

> **Propósito:** Este arquivo fornece contexto completo para ferramentas de IA (GitHub Copilot, Claude, Cursor) desenvolverem código consistente com os padrões do projeto WaniKani App.

**Última Atualização:** 11/10/2025  
**Versão:** 1.0.0

---

## 🎯 Visão Geral do Projeto

**WaniKani App** é um cliente mobile Flutter para acompanhar progresso de aprendizado de japonês através da API WaniKani. Segue Clean Architecture com offline-first strategy.

**Stack Principal:**
- Flutter 3.8+ / Dart
- Clean Architecture (data/domain/presentation)
- BLoC/Cubit (state management)
- Drift/SQLite (cache offline)
- go_router (navegação)
- GetIt (DI)
- Dartz (functional programming)

---

## 📐 Arquitetura e Estrutura

### Clean Architecture por Features

```
lib/
├── core/                    # Shared code
│   ├── database/           # Drift database
│   ├── error/              # Error entities
│   ├── mixins/             # Reusable mixins
│   └── theme/              # Design system
│
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/    # API + Local datasources
│       │   ├── models/         # JSON serialization
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business entities (pure Dart)
│       │   ├── repositories/   # Repository interfaces (I prefix)
│       │   └── usecases/       # Use cases (one file = one operation)
│       └── presentation/
│           ├── cubits/         # State management
│           ├── screens/        # Full screens
│           └── widgets/        # Reusable widgets
│
├── routing/                # go_router configuration
└── main.dart
```

### Fluxo de Dados

```
UI (Screen) ← BlocBuilder ← Cubit ← UseCase ← Repository ← Datasource → API/DB
                                                    ↓
                                                 Cache (Drift)
```

---

## 💻 Padrões de Código

### 1. Entities (Domain Layer)

```dart
/// Pure Dart class - NO dependencies on Flutter/packages
class AssignmentEntity {
  final int id;
  final int subjectId;
  final String subjectType;
  final int srsStage;
  final DateTime? availableAt;

  const AssignmentEntity({
    required this.id,
    required this.subjectId,
    required this.subjectType,
    required this.srsStage,
    this.availableAt,
  });

  /// Computed properties are OK
  String get formattedType => subjectType.toUpperCase();
  
  /// CopyWith for immutability
  AssignmentEntity copyWith({
    int? id,
    int? subjectId,
    String? subjectType,
    int? srsStage,
    DateTime? availableAt,
  }) =>
      AssignmentEntity(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        subjectType: subjectType ?? this.subjectType,
        srsStage: srsStage ?? this.srsStage,
        availableAt: availableAt ?? this.availableAt,
      );
}
```

**Regras:**
- ✅ Pure Dart (no Flutter imports)
- ✅ Immutable (final fields, const constructor)
- ✅ CopyWith for updates
- ✅ Computed properties OK
- ❌ NO JSON serialization logic
- ❌ NO business logic (apenas estrutura de dados)

### 2. Models (Data Layer)

```dart
/// Extension type for zero-cost abstraction
extension type AssignmentModel(AssignmentEntity entity) 
    implements AssignmentEntity {
  
  AssignmentModel.fromJson(Map<String, dynamic> json)
      : entity = AssignmentEntity(
          id: json['id'] as int,
          subjectId: json['data']['subject_id'] as int,
          subjectType: json['data']['subject_type'] as String,
          srsStage: json['data']['srs_stage'] as int,
          availableAt: json['data']['available_at'] != null
              ? DateTime.parse(json['data']['available_at'] as String)
              : null,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': {
          'subject_id': subjectId,
          'subject_type': subjectType,
          'srs_stage': srsStage,
          'available_at': availableAt?.toIso8601String(),
        },
      };
}
```

**Regras:**
- ✅ Extension type (Dart 3.0+)
- ✅ fromJson constructor
- ✅ toJson method
- ✅ Handle nulls safely
- ❌ NO validation logic (repository handles that)

### 3. Repository Interface (Domain)

```dart
abstract class IAssignmentRepository {
  Future<Either<IError, List<AssignmentEntity>>> getAssignments({
    bool forceRefresh = false,
  });

  Future<Either<IError, AssignmentEntity>> getAssignmentById(int id);
  
  Future<Either<IError, Unit>> updateAssignment(AssignmentEntity assignment);
}
```

**Regras:**
- ✅ Prefix with "I" (IAssignmentRepository)
- ✅ Return Either<IError, T> (dartz)
- ✅ Use Unit for void operations
- ✅ Pure interface (no implementation)
- ❌ NO concrete dependencies

### 4. Repository Implementation (Data)

```dart
class AssignmentRepository implements IAssignmentRepository {
  final WaniKaniDatasource _remoteDatasource;
  final AssignmentDao _localDatasource;

  AssignmentRepository({
    required WaniKaniDatasource remoteDatasource,
    required AssignmentDao localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Either<IError, List<AssignmentEntity>>> getAssignments({
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Clear expired cache
      await _localDatasource.deleteExpired(const Duration(hours: 24));

      // 2. Try cache first (if not forcing refresh)
      if (!forceRefresh) {
        final List<AssignmentDB> cached = await _localDatasource.getAll();
        if (cached.isNotEmpty) {
          return Right(cached.map(_dbToEntity).toList());
        }
      }

      // 3. Fetch from API
      final Response<dynamic> response = await _remoteDatasource.getAssignments();

      if (response.isSuccessful) {
        final List<AssignmentEntity> assignments =
            (response.data['data'] as List<dynamic>)
                .map((dynamic json) => AssignmentModel.fromJson(json).entity)
                .toList();

        // 4. Cache locally
        await _localDatasource.upsertAll(
          assignments.map(_entityToDb).toList(),
        );

        return Right(assignments);
      }

      return Left(ApiErrorEntity.fromResponse(response));
    } catch (e, stackTrace) {
      // Fallback to cache on error (offline mode)
      final List<AssignmentDB> cached = await _localDatasource.getAll();
      if (cached.isNotEmpty) {
        return Right(cached.map(_dbToEntity).toList());
      }

      return Left(InternalErrorEntity('Failed to get assignments: $e'));
    }
  }

  AssignmentEntity _dbToEntity(AssignmentDB db) => AssignmentEntity(
        id: db.id,
        subjectId: db.subjectId,
        subjectType: db.subjectType,
        srsStage: db.srsStage,
        availableAt: db.availableAt,
      );

  AssignmentDB _entityToDb(AssignmentEntity entity) => AssignmentDB(
        id: entity.id,
        subjectId: entity.subjectId,
        subjectType: entity.subjectType,
        srsStage: entity.srsStage,
        availableAt: entity.availableAt,
        cachedAt: DateTime.now(),
      );
}
```

**Regras:**
- ✅ Try-catch with error handling
- ✅ Cache-first strategy (offline support)
- ✅ Either monad for all returns
- ✅ Private converter methods (_dbToEntity, _entityToDb)
- ✅ Dependency injection via constructor
- ❌ NO direct API calls in repository (use datasource)

### 5. Use Cases

```dart
class GetAssignmentsUseCase {
  final IAssignmentRepository _repository;

  GetAssignmentsUseCase({required IAssignmentRepository repository})
      : _repository = repository;

  Future<Either<IError, List<AssignmentEntity>>> call({
    bool forceRefresh = false,
  }) async =>
      await _repository.getAssignments(forceRefresh: forceRefresh);
}
```

**Regras:**
- ✅ ONE usecase = ONE repository method
- ✅ call() method (callable class)
- ✅ Depend on repository interface (I prefix)
- ✅ Can add business logic if needed
- ❌ NO direct datasource access

### 6. Cubit States (Presentation)

```dart
sealed class AssignmentState extends Equatable {
  const AssignmentState();
  
  @override
  List<Object?> get props => [];
}

final class AssignmentInitial extends AssignmentState {}

final class AssignmentLoading extends AssignmentState {}

final class AssignmentError extends AssignmentState {
  final String message;
  
  const AssignmentError(this.message);
  
  @override
  List<Object> get props => [message];
}

final class AssignmentLoaded extends AssignmentState {
  final List<AssignmentEntity> assignments;
  
  const AssignmentLoaded(this.assignments);
  
  @override
  List<Object> get props => [assignments];
}
```

**Regras:**
- ✅ Sealed class (Dart 3.0+)
- ✅ Extend Equatable
- ✅ Minimum states: Initial, Loading, Error, Loaded
- ✅ Immutable (final fields, const constructors)
- ✅ Override props for Equatable

### 7. Cubit Implementation

```dart
class AssignmentCubit extends Cubit<AssignmentState> {
  final GetAssignmentsUseCase _getAssignmentsUseCase;
  final UpdateAssignmentUseCase _updateAssignmentUseCase;

  AssignmentCubit({
    required GetAssignmentsUseCase getAssignmentsUseCase,
    required UpdateAssignmentUseCase updateAssignmentUseCase,
  })  : _getAssignmentsUseCase = getAssignmentsUseCase,
        _updateAssignmentUseCase = updateAssignmentUseCase,
        super(AssignmentInitial());

  Future<void> loadAssignments({bool forceRefresh = false}) async {
    emit(AssignmentLoading());
    
    final Either<IError, List<AssignmentEntity>> result =
        await _getAssignmentsUseCase(forceRefresh: forceRefresh);

    result.fold(
      (IError error) => emit(AssignmentError(error.message)),
      (List<AssignmentEntity> assignments) => emit(AssignmentLoaded(assignments)),
    );
  }

  Future<void> updateAssignment(AssignmentEntity assignment) async {
    final AssignmentState currentState = state;
    if (currentState is! AssignmentLoaded) return;

    final Either<IError, Unit> result =
        await _updateAssignmentUseCase(assignment);

    result.fold(
      (IError error) => emit(AssignmentError(error.message)),
      (_) => loadAssignments(), // Reload after update
    );
  }
}
```

**Regras:**
- ✅ Depend ONLY on use cases (not repositories)
- ✅ Emit Loading before async operations
- ✅ Use fold() for Either handling
- ✅ Return Future<void> (not Future<Either>)
- ❌ NO business logic (delegate to use cases)

### 8. UI/Screens

```dart
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (BuildContext context) =>
            getIt<AssignmentCubit>()..loadAssignments(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: BlocConsumer<AssignmentCubit, AssignmentState>(
            listener: (BuildContext context, AssignmentState state) {
              if (state is AssignmentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (BuildContext context, AssignmentState state) {
              return switch (state) {
                AssignmentInitial() => const Center(
                    child: Text('Inicializando...'),
                  ),
                AssignmentLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                AssignmentError() => const Center(
                    child: Text('Erro ao carregar dados'),
                  ),
                AssignmentLoaded(:final List<AssignmentEntity> assignments) =>
                  ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (BuildContext context, int index) =>
                        AssignmentCard(assignments[index]),
                  ),
              };
            },
          ),
        ),
      );
}
```

**Regras:**
- ✅ StatelessWidget preferred
- ✅ BlocProvider with getIt
- ✅ BlocConsumer for state + side effects
- ✅ Switch pattern matching (Dart 3.0+)
- ✅ Handle ALL states exhaustively
- ❌ NO business logic in widgets

---

## 🧪 Abordagem de Testes

### Unit Test - Use Case

```dart
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
    final List<AssignmentEntity> tAssignments = <AssignmentEntity>[
      AssignmentEntity(
        id: 1,
        subjectId: 100,
        subjectType: 'kanji',
        srsStage: 5,
      ),
    ];

    test('should return assignments from repository', () async {
      // Arrange
      when(() => mockRepository.getAssignments())
          .thenAnswer((_) async => Right(tAssignments));

      // Act
      final Either<IError, List<AssignmentEntity>> result = await useCase();

      // Assert
      expect(result, equals(Right<IError, List<AssignmentEntity>>(tAssignments)));
      verify(() => mockRepository.getAssignments()).called(1);
    });

    test('should return error when repository fails', () async {
      // Arrange
      final IError tError = ApiErrorEntity('Network error');
      when(() => mockRepository.getAssignments())
          .thenAnswer((_) async => Left(tError));

      // Act
      final Either<IError, List<AssignmentEntity>> result = await useCase();

      // Assert
      expect(result.isLeft(), true);
      verify(() => mockRepository.getAssignments()).called(1);
    });
  });
}
```

### Bloc Test - Cubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAssignmentsUseCase extends Mock implements GetAssignmentsUseCase {}

void main() {
  late AssignmentCubit cubit;
  late MockGetAssignmentsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetAssignmentsUseCase();
    cubit = AssignmentCubit(getAssignmentsUseCase: mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('loadAssignments', () {
    final List<AssignmentEntity> tAssignments = <AssignmentEntity>[
      AssignmentEntity(id: 1, subjectId: 100, subjectType: 'kanji', srsStage: 5),
    ];

    blocTest<AssignmentCubit, AssignmentState>(
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => Right(tAssignments));
        return cubit;
      },
      act: (AssignmentCubit cubit) => cubit.loadAssignments(),
      expect: () => <AssignmentState>[
        AssignmentLoading(),
        AssignmentLoaded(tAssignments),
      ],
    );

    blocTest<AssignmentCubit, AssignmentState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockUseCase()).thenAnswer(
          (_) async => Left(ApiErrorEntity('Error')),
        );
        return cubit;
      },
      act: (AssignmentCubit cubit) => cubit.loadAssignments(),
      expect: () => <AssignmentState>[
        AssignmentLoading(),
        const AssignmentError('Error'),
      ],
    );
  });
}
```

**Regras de Teste:**
- ✅ Use mocktail (not mockito)
- ✅ AAA pattern (Arrange-Act-Assert)
- ✅ Test BOTH success and failure cases
- ✅ Verify method calls
- ✅ Use bloc_test for Cubits
- ✅ Aim for > 80% coverage

---

## ⚠️ Pegadinhas e Anti-Padrões

### ❌ NÃO FAZER

```dart
// ❌ NO business logic in widgets
class BadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final assignments = repository.getAssignments(); // WRONG
    return ListView(children: ...);
  }
}

// ❌ NO Flutter imports in domain layer
import 'package:flutter/material.dart'; // WRONG in domain/

// ❌ NO mutable state in Entities
class BadEntity {
  int id; // WRONG - should be final
  void updateId(int newId) => id = newId; // WRONG
}

// ❌ NO string-based navigation
Navigator.pushNamed(context, '/dashboard'); // WRONG - use go_router

// ❌ NO dynamic types (except JSON parsing)
dynamic fetchData() => ...; // WRONG - always specify types

// ❌ NO multiple use cases in one file
// One file = one use case ONLY
```

### ✅ FAZER

```dart
// ✅ Business logic in use cases/cubits
class GoodCubit extends Cubit<State> {
  Future<void> loadData() async {
    final result = await useCase();
    // Handle result
  }
}

// ✅ Type-safe navigation
context.go(AppRoutes.dashboard);

// ✅ Explicit types
Future<Either<IError, List<AssignmentEntity>>> fetchData() => ...;

// ✅ Immutable entities
class GoodEntity {
  final int id;
  const GoodEntity({required this.id});
  GoodEntity copyWith({int? id}) => GoodEntity(id: id ?? this.id);
}
```

---

## 🎨 Convenções de Estilo

### Nomenclatura

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Classes | PascalCase | `AssignmentEntity` |
| Arquivos | snake_case | `assignment_entity.dart` |
| Variáveis | camelCase | `assignmentList` |
| Constantes | camelCase com const | `const Duration cacheTTL` |
| Privados | _ prefix | `_repository` |

### Imports

```dart
// 1. Dart/Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Packages externos
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// 3. Projeto (SEMPRE package imports)
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/dashboard/domain/entities/assignment_entity.dart';
```

### Documentação

```dart
/// Brief description of the class/method.
///
/// Longer description if needed with usage examples.
///
/// Example:
/// ```dart
/// final entity = AssignmentEntity(id: 1, ...);
/// ```
class AssignmentEntity {
  /// The unique identifier for this assignment.
  final int id;
}
```

---

## 📝 Checklist para Novas Features

Ao criar uma nova feature, seguir esta ordem:

1. [ ] Criar entities em `domain/entities/`
2. [ ] Criar repository interface em `domain/repositories/`
3. [ ] Criar use cases em `domain/usecases/` (um arquivo por operação)
4. [ ] Criar models em `data/models/`
5. [ ] Criar datasources em `data/datasources/`
6. [ ] Implementar repository em `data/repositories/`
7. [ ] Criar states em `presentation/cubits/<feature>_state.dart`
8. [ ] Criar cubit em `presentation/cubits/<feature>_cubit.dart`
9. [ ] Criar screens em `presentation/screens/`
10. [ ] Criar widgets reutilizáveis em `presentation/widgets/`
11. [ ] Registrar dependências no GetIt
12. [ ] Adicionar rotas no go_router
13. [ ] Escrever testes unitários (domain, data)
14. [ ] Escrever testes de cubit (bloc_test)
15. [ ] Escrever testes de widgets

---

## 🚀 Performance Considerations

- ✅ Use `const` constructors where possible
- ✅ Avoid rebuilding entire widget tree (use BlocSelector)
- ✅ Cache expensive computations
- ✅ Use `flutter pub run build_runner watch` during development
- ✅ Profile with DevTools before optimizing

---

## 🔒 Security Best Practices

- ✅ Never log API keys or tokens
- ✅ Use flutter_secure_storage for credentials
- ✅ Validate all user inputs
- ✅ Handle errors gracefully (don't expose internals)
- ✅ Use HTTPS only

---

**FIM DO GUIA**

> Este documento deve ser consultado antes de gerar qualquer código. Mantenha-o atualizado conforme padrões evoluem.
