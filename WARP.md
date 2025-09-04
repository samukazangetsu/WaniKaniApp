# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Flutter application for WaniKani that follows Clean Architecture principles. The project is built with a focus on functional programming using `dartz`, strict linting rules, and comprehensive testing practices.

## Architecture

### Clean Architecture Structure

The project follows a strict Clean Architecture pattern organized by features:

```text
lib/
├── core/                    # Shared utilities and base classes
│   ├── comum_strings.dart   # Common string constants
│   ├── enuns/              # Enums (e.g., TipoAmbienteEnum for environment types)
│   └── exceptions/         # Error handling classes (IError, ApiError, InternalError)
├── [feature]/              # Feature-based modules (e.g., exemplo/)
│   ├── data/
│   │   ├── datasources/    # External data sources (API calls)
│   │   ├── models/         # Data models with JSON serialization
│   │   └── repositories/   # Repository implementations
│   ├── domain/
│   │   ├── entities/       # Business entities (pure Dart classes)
│   │   ├── repositories/   # Repository interfaces (prefixed with 'I')
│   │   └── usecases/       # Business logic use cases
│   ├── injection/          # Dependency injection setup
│   ├── presentation/       # UI components and screens
│   └── router/            # Feature-specific routing
├── router/                 # Global routing configuration
└── utils/                  # Shared utilities and mixins
```

### Key Architectural Patterns

1. **Repository Pattern**: All data access goes through repository interfaces
2. **Dependency Injection**: Uses `injector` package with feature-based injection classes
3. **Error Handling**: Uses `dartz` Either monad for error handling
4. **State Management**: Cubit pattern via `flutter_bloc`
5. **Networking**: `pop_network` package with interceptors for logging and error handling
6. **Functional Programming**: Leverages `dartz` for functional constructs

### Error Handling Pattern

All repository methods return `Either<IError, T>` where:

- `IError` is the base error interface
- `ApiError` handles API-specific errors
- `InternalError` handles unexpected errors
- `DecodeModelMixin` provides safe JSON decoding with automatic error reporting

## Common Development Commands

### Setup and Dependencies

```bash
# Install dependencies
flutter pub get

# Clean and reinstall dependencies (if needed)
flutter clean && flutter pub get
```

### Code Quality and Analysis

```bash
# Format code (follows project's strict formatting rules)
dart format .

# Run static analysis
flutter analyze

# Run both format and analyze (pre-commit hook behavior)
dart format . --set-exit-if-changed && flutter analyze
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Building and Running

```bash
# Run app in debug mode
flutter run

# Run app in release mode
flutter run --release

# Build APK for Android
flutter build apk

# Build iOS app
flutter build ios
```

## Development Workflow

### Pre-commit Setup

The project includes a `pre-commit` script that automatically:

1. Formats code using `dart format`
2. Runs static analysis with `flutter analyze`
3. Prevents commits if either step fails

### Adding New Features

When adding new features, follow this structure:

1. **Create feature directory** under `lib/` with Clean Architecture layers
2. **Define entities** in `domain/entities/` (pure Dart classes)
3. **Create repository interface** in `domain/repositories/` (prefixed with 'I')
4. **Implement use cases** in `domain/usecases/`
5. **Create data models** in `data/models/` with JSON serialization
6. **Implement datasource** in `data/datasources/` using `pop_network`
7. **Implement repository** in `data/repositories/` using `Either<IError, T>` pattern
8. **Setup dependency injection** in `injection/` directory
9. **Create presentation layer** with Cubit for state management
10. **Add routing** in feature's `router/` directory

### Dependency Injection Pattern

Each feature has its own injection class following this pattern:

```dart
class FeatureInjection {
  final Injector injector;
  
  FeatureInjection(this.injector) {
    _registerDependencies();
  }
  
  void _registerDependencies() {
    injector.registerSingleton<FeatureDatasource>(() => FeatureDatasource(...));
    injector.registerDependency<IFeatureRepository>(() => FeatureRepository(...));
    injector.registerDependency(() => FeatureUsecase(...));
  }
}
```

### Error Handling Implementation

Always use the `DecodeModelMixin` for safe data processing:

```dart
return tryDecode<Either<IError, EntityType>>(
  () {
    if (result.isSuccessful) {
      return Right(ModelType.fromJson(result.data));
    }
    return Left(ApiError.fromJson(result.data));
  },
  orElse: (error) => Left(InternalError('Custom error message')),
);
```

## Key Technologies and Packages

- **Flutter Bloc**: State management with Cubit pattern
- **Go Router**: Declarative navigation
- **Injector**: Simple dependency injection
- **Pop Network**: HTTP client with interceptors
- **Dartz**: Functional programming utilities (Either, Option, etc.)
- **Flutter Lints**: Code quality enforcement

## Code Standards

- Use single quotes for strings
- Prefer expression function bodies where appropriate
- Always declare return types
- Use package imports (not relative imports)
- Line length limit: 80 characters
- Prefer final for local variables
- Use meaningful, descriptive names without comments
- **Each entity must be in its own separate file** (never group multiple entities in one file)
- **Each repository method must have its own corresponding usecase** (1:1 relationship)
