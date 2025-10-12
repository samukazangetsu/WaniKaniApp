# GitHub Copilot Instructions - WaniKani App

> **Project Type:** Flutter mobile app for WaniKani Japanese learning  
> **Architecture:** Clean Architecture + Offline-First  
> **Last Updated:** October 11, 2025

## Core Architecture

This is a **Clean Architecture** Flutter app organized by **features**, not layers. Each feature in `lib/features/` has three layers:

```
features/<feature>/
├── data/          # API calls, caching, serialization
│   ├── datasources/   # API + Drift DAO
│   ├── models/        # JSON ↔ Entity conversion
│   └── repositories/  # Implements domain interfaces
├── domain/        # Pure business logic (NO Flutter imports)
│   ├── entities/      # Immutable data classes
│   ├── repositories/  # Interfaces prefixed with 'I'
│   └── usecases/      # One file = one operation
└── presentation/  # UI + State management
    ├── cubits/        # BLoC/Cubit for state
    ├── screens/       # Full-screen widgets
    └── widgets/       # Reusable components
```

**Critical Rule:** Domain layer NEVER imports Flutter or external packages (except Equatable). Use `dartz` for functional error handling.

## Data Flow Pattern

All repository methods return `Either<IError, T>` from dartz:

```dart
// Repository implementation (data layer)
Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
  try {
    // 1. Check cache (Drift)
    final cached = await _dao.getAll();
    if (cached.isNotEmpty && !_isExpired(cached)) {
      return Right(cached);
    }
    
    // 2. Fetch from API
    final response = await _datasource.getAssignments();
    if (response.isSuccessful) {
      final entities = (response.data['data'] as List)
          .map((json) => AssignmentModel.fromJson(json))
          .toList();
      
      // 3. Cache for offline
      await _dao.upsertAll(entities);
      return Right(entities);
    }
    
    return Left(ApiErrorEntity.fromResponse(response));
  } catch (e) {
    // Fallback to expired cache on network error
    final cached = await _dao.getAll();
    return cached.isNotEmpty 
        ? Right(cached) 
        : Left(InternalErrorEntity(e.toString()));
  }
}

// Use case (domain layer)
class GetAssignmentsUseCase {
  final IAssignmentRepository _repository;
  
  Future<Either<IError, List<AssignmentEntity>>> call() => 
      _repository.getAssignments();
}

// Cubit (presentation layer)
Future<void> loadAssignments() async {
  emit(AssignmentLoading());
  final result = await _loadAssignmentsData();
  result.fold(
    (error) => emit(AssignmentError(error.message)),
    (assignments) => emit(AssignmentLoaded(assignments)),
  );
}
```

**SOLID Principles in Cubits:**
- **Single Responsibility:** Each method handles one specific task
- **Separation of Concerns:** Public methods orchestrate, private methods execute
- **Direct fold() usage:** Always use fold() to handle Either results, never check isLeft() then fold()
- **No nested conditionals:** Use fold() chaining for multiple Either results

## Entity ↔ Model Pattern

Use **extension types** (Dart 3.0+) for zero-cost JSON conversion:

```dart
// Entity (domain/entities/assignment_entity.dart)
class AssignmentEntity {
  final int id;
  final int subjectId;
  final String subjectType;
  final int srsStage;
  final DateTime? availableAt;
  
  const AssignmentEntity({/* ... */});
  
  // NO fromJson/toJson here
}

// Model (data/models/assignment_model.dart)
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
  
  Map<String, dynamic> toJson() => {/* ... */};
}
```

## State Management with Cubit

**States must be sealed classes** (Dart 3.0+) with exhaustive pattern matching:

```dart
// States file
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

// UI uses switch expressions
BlocBuilder<AssignmentCubit, AssignmentState>(
  builder: (context, state) => switch (state) {
    AssignmentInitial() => SizedBox.shrink(),
    AssignmentLoading() => CircularProgressIndicator(),
    AssignmentError(:final message) => Text(message),
    AssignmentLoaded(:final assignments) => ListView(...),
  },
)
```

## Critical Conventions

### Linting Rules (80+ enforced)

- **Line length:** Max 80 characters (hard limit)
- **Quotes:** Single quotes only (`'string'` not `"string"`)
- **Types:** Always declare return types and variable types
- **Imports:** Package imports only, never relative (`import 'package:wanikani_app/...'`)
- **Functions:** Prefer expression bodies where applicable (`=> value`)
- **Immutability:** Prefer `final` for local variables, `const` for constructors

### Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Files | snake_case | `assignment_repository.dart` |
| Classes | PascalCase | `AssignmentEntity` |
| Variables | camelCase | `assignmentList` |
| Repository interfaces | I prefix | `IAssignmentRepository` |
| Private fields | _ prefix | `_repository` |

### File Organization Rules

1. **One entity per file** - Never group multiple entities
2. **One use case per file** - Each repository method gets its own use case file
3. **Import ordering:**
   ```dart
   // 1. Dart/Flutter core
   import 'dart:async';
   import 'package:flutter/material.dart';
   
   // 2. External packages
   import 'package:dartz/dartz.dart';
   import 'package:equatable/equatable.dart';
   
   // 3. Project imports (package imports only)
   import 'package:wanikani_app/core/error/ierror.dart';
   import 'package:wanikani_app/features/dashboard/domain/entities/assignment_entity.dart';
   ```

## Dependency Injection (GetIt)

Register dependencies in `lib/core/di/service_locator.dart`:

```dart
void setupDependencies() {
  // Datasources
  getIt.registerLazySingleton(() => WaniKaniDatasource(getIt()));
  
  // DAOs (Drift)
  getIt.registerLazySingleton(() => AssignmentDao(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<IAssignmentRepository>(
    () => AssignmentRepository(
      datasource: getIt(),
      dao: getIt(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton(() => GetAssignmentsUseCase(repository: getIt()));
  
  // Cubits (factory for new instances)
  getIt.registerFactory(() => AssignmentCubit(useCase: getIt()));
}
```

## Offline-First Caching Strategy

**Cache TTL per endpoint:**
- Assignments: 24 hours
- Level Progressions: 24 hours
- Review Statistics: 1 hour (changes frequently)

**Implementation pattern:**
1. Check cache first (if not force refresh)
2. Return cached data if valid
3. Fetch from API on cache miss/expiry
4. Update cache with fresh data
5. On network error, fallback to expired cache (better than nothing)

Use Drift for local storage with automatic expiry:

```dart
@DriftDatabase(tables: [Assignments])
class AppDatabase extends _$AppDatabase {
  // ...
}

// DAO method to clean expired cache
Future<void> deleteExpired(Duration ttl) async {
  final cutoff = DateTime.now().subtract(ttl);
  await (delete(assignments)
    ..where((tbl) => tbl.cachedAt.isSmallerThanValue(cutoff))
  ).go();
}
```

## Testing Requirements

**Minimum 80% code coverage** with this structure:

```
test/
├── core/
│   └── mixins/
│       └── decode_model_mixin_test.dart
└── features/<feature>/
    ├── data/
    │   ├── models/<feature>_model_test.dart
    │   └── repositories/<feature>_repository_test.dart
    ├── domain/
    │   └── usecases/get_<feature>_test.dart
    └── presentation/
        └── cubits/<feature>_cubit_test.dart
```

Use **mocktail** (not mockito) with bloc_test for Cubits:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUseCase extends Mock implements GetAssignmentsUseCase {}

blocTest<AssignmentCubit, AssignmentState>(
  'emits [Loading, Loaded] when successful',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) async => Right(tData));
    return cubit;
  },
  act: (cubit) => cubit.loadAssignments(),
  expect: () => [AssignmentLoading(), AssignmentLoaded(tData)],
);
```

## API Integration (WaniKani v2)

**Base URL:** `https://api.wanikani.com/v2`  
**Authentication:** Bearer token in header  

**Key endpoints:**
- `GET /assignments` - User's study items (SRS stages 0-9)
- `GET /level_progressions` - Progress through levels 1-60
- `GET /review_statistics` - Accuracy stats per subject

**Rate limit:** 60 requests/minute - implement exponential backoff on 429 errors

**Response structure:**
```json
{
  "object": "collection",
  "total_count": 123,
  "data": [
    {
      "id": 1,
      "object": "assignment",
      "data": { /* actual data */ }
    }
  ]
}
```

Always parse from `response.data['data']` array, not top level.

## Common Commands

```bash
# Development (with mocks)
flutter run lib/main_mock.dart

# Production (real API)
flutter run lib/main.dart

# Code generation (Drift, JSON)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (during development)
dart run build_runner watch

# Format + analyze (pre-commit)
dart format . --set-exit-if-changed && flutter analyze

# Tests with coverage
flutter test --coverage
```

## Anti-Patterns to Avoid

❌ **Don't** put business logic in widgets - use Cubits/UseCases  
❌ **Don't** import Flutter in domain layer - keep it pure Dart  
❌ **Don't** use `dynamic` types (except JSON parsing edge cases)  
❌ **Don't** group multiple entities in one file - one entity per file  
❌ **Don't** create "god" use cases - one use case = one operation  
❌ **Don't** skip cache layer - always implement offline support  
❌ **Don't** expose error details to UI - use user-friendly messages via `IError.message`  
❌ **Don't** check isLeft() then fold() - use fold() directly to handle both cases  
❌ **Don't** create large methods in Cubits - extract private methods for each operation (SOLID)  
❌ **Don't** mix orchestration and execution in the same method - separate concerns

## Project-Specific Context

**Current Status:** Early development - most features are skeleton/empty  
**Priority:** Implement data layer (repositories, datasources) before presentation  
**Mock Data:** Use JSON files in `assets/mock/` for development without API  
**Theme:** Japanese-focused design with Noto Sans JP fonts and culturally appropriate colors

**Key Documentation:**
- Architecture details: `specs/technical/CODEBASE_GUIDE.md`
- API spec: `specs/technical/API_SPECIFICATION.md`
- Full patterns: `specs/technical/CLAUDE.meta.md`
- Decisions: `specs/technical/adr/` (5 ADRs)

## Quick Reference

**Need to add a new feature?**  
1. Create domain (entities → repository interface → use cases)
2. Create data (model → datasource → repository impl)
3. Create presentation (states → cubit → screens)
4. Register in GetIt
5. Add route in go_router
6. Write tests

**Need to call an API?**  
Repository → UseCase → Cubit → UI  
Never skip layers, always use Either<IError, T> for error handling.

**Need offline support?**  
Implement Drift DAO, check cache in repository before API call, always cache responses.
