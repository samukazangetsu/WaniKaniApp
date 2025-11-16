# Instruções para Agente de Desenvolvimento - WaniKani App

> **Objetivo:** Guia completo para agentes de IA desenvolverem código para o WaniKani App  
> **Última atualização:** 16 de novembro de 2025  
> **Versão:** 1.0.0

---

## 🎯 Missão do Agente

Você é um agente especializado em desenvolvimento Flutter responsável por implementar features, corrigir bugs e manter o código do **WaniKani App** seguindo rigorosamente os padrões estabelecidos neste projeto.

### Princípios Fundamentais
1. **Qualidade > Velocidade** - Código deve ser testável, manutenível e seguir padrões
2. **Clean Architecture** - Respeitar separação de camadas (data/domain/presentation)
3. **Offline-First** - Toda feature deve funcionar sem internet quando possível
4. **Type-Safe** - Evitar `dynamic`, sempre declarar tipos explicitamente
5. **Testável** - Todo código novo deve ter testes unitários (mínimo 80% coverage)

---

## 📚 Documentação Obrigatória

Antes de escrever qualquer código, você DEVE ler os seguintes documentos:

### Leitura Obrigatória (nesta ordem)
1. **[CLAUDE.meta.md](CLAUDE.meta.md)** - Padrões de código, anti-patterns, convenções
2. **[CODEBASE_GUIDE.md](CODEBASE_GUIDE.md)** - Estrutura de pastas e navegação
3. **[API_SPECIFICATION.md](API_SPECIFICATION.md)** - Integração WaniKani API v2
4. **[BUSINESS_LOGIC.md](BUSINESS_LOGIC.md)** - Lógica de domínio e conceitos SRS

### Leitura Recomendada
5. **[adr/001-clean-architecture.md](adr/001-clean-architecture.md)** - Por que Clean Architecture
6. **[adr/002-bloc-state-management.md](adr/002-bloc-state-management.md)** - Por que BLoC/Cubit
7. **[adr/003-offline-first-drift.md](adr/003-offline-first-drift.md)** - Por que Drift
8. **[DESIGN_SYSTEM.md](../design/DESIGN_SYSTEM.md)** - Cores, tipografia, componentes

### Consulta sob Demanda
9. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Quando encontrar erros
10. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Workflow de desenvolvimento

---

## 🏗️ Estrutura de Código

### Organização por Features

```
lib/features/<feature>/
├── data/              # Camada de dados (API + Cache)
│   ├── datasources/   # Chamadas API (Dio) + DAO (Drift)
│   ├── models/        # JSON ↔ Entity (extension types)
│   └── repositories/  # Implementação de interfaces do domain
├── domain/            # Camada de negócio (PURO DART)
│   ├── entities/      # Classes de dados imutáveis
│   ├── repositories/  # Interfaces (prefixo 'I')
│   └── usecases/      # Um arquivo = uma operação
└── presentation/      # Camada de UI
    ├── cubits/        # State management (BLoC)
    ├── screens/       # Telas completas
    └── widgets/       # Componentes reutilizáveis
```

### Regras de Camadas

| Camada | Pode Importar | NÃO Pode Importar |
|--------|---------------|-------------------|
| **domain** | Nada (exceto Equatable) | Flutter, Dio, Drift, qualquer package externo |
| **data** | domain, Dio, Drift, Dartz | presentation, Flutter widgets |
| **presentation** | domain, Flutter, BLoC | data (apenas via DI) |

---

## 🔧 Padrões de Implementação

### 1. Criando uma Nova Feature

**Checklist obrigatório:**
- [ ] Criar estrutura de pastas `lib/features/<feature>/data/domain/presentation`
- [ ] Começar pelo **domain** (entities → repository interface → usecases)
- [ ] Implementar **data** (model → datasource → repository impl)
- [ ] Implementar **presentation** (states → cubit → screens → widgets)
- [ ] Registrar dependências no GetIt (`lib/core/dependency_injection/`)
- [ ] Adicionar rota no go_router (`lib/routing/`)
- [ ] Escrever testes para cada camada

**Ordem de execução:**
1. Domain entities
2. Domain repository interfaces
3. Domain usecases
4. Data models (extension types)
5. Data datasources (API + DAO)
6. Data repositories
7. Presentation states (sealed classes)
8. Presentation cubits
9. Presentation screens
10. Presentation widgets
11. Dependency injection
12. Routing
13. Tests

### 2. Entity → Model Pattern

**SEMPRE use extension types** para conversão zero-cost:

```dart
// ❌ ERRADO - Não faça isso
class AssignmentModel extends AssignmentEntity {
  AssignmentModel({required int id}) : super(id: id);
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(id: json['id']);
  }
}

// ✅ CORRETO - Extension type
extension type AssignmentModel(AssignmentEntity entity) 
    implements AssignmentEntity {
  
  AssignmentModel.fromJson(Map<String, dynamic> json)
      : entity = AssignmentEntity(
          id: json['id'],
          subjectId: json['data']['subject_id'],
          // ... outros campos
        );
  
  Map<String, dynamic> toJson() => {
    'id': entity.id,
    'data': {
      'subject_id': entity.subjectId,
      // ... outros campos
    },
  };
}
```

### 3. Repository Pattern com Either

**SEMPRE retorne `Either<IError, T>`** em repositories:

```dart
// Interface (domain/repositories/i_home_repository.dart)
abstract class IHomeRepository {
  /// Obtém todos os assignments do usuário.
  Future<Either<IError, List<AssignmentEntity>>> getAssignments();
  
  /// Obtém a progressão do nível atual do usuário.
  Future<Either<IError, LevelProgressionEntity>> getCurrentLevelProgression();
}

// Implementação (data/repositories/home_repository.dart)
class HomeRepository with DecodeModelMixin implements IHomeRepository {
  final WaniKaniDataSource _datasource;

  const HomeRepository({required WaniKaniDataSource datasource})
      : _datasource = datasource;

  @override
  Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
    try {
      final response = await _datasource.getAssignments();

      // 1. Verificar se resposta foi bem-sucedida
      if (response.isSuccessful) {
        // 2. Usar tryDecode do mixin para parsing seguro
        return tryDecode<Either<IError, List<AssignmentEntity>>>(
          () {
            // 3. Extrair lista do campo 'data'
            final data =
                (response.data as Map<String, dynamic>)['data'] as List;

            // 4. Converter cada item para entity via model
            final List<AssignmentEntity> assignments = data
                .map(
                  (dynamic json) =>
                      AssignmentModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();

            return Right<IError, List<AssignmentEntity>>(assignments);
          },
          // 5. Fallback em caso de erro de parsing
          orElse: (_) => Left<IError, List<AssignmentEntity>>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      // 6. Criar erro de API quando statusCode != 2xx
      return Left<IError, List<AssignmentEntity>>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      // 7. Capturar exceções gerais
      return Left<IError, List<AssignmentEntity>>(
        InternalErrorEntity(e.toString()),
      );
    }
  }

  @override
  Future<Either<IError, LevelProgressionEntity>>
      getCurrentLevelProgression() async {
    try {
      final response = await _datasource.getLevelProgressions();

      if (response.isSuccessful) {
        return tryDecode<Either<IError, LevelProgressionEntity>>(
          () {
            final data =
                (response.data as Map<String, dynamic>)['data'] as List;

            // Validação: lista não pode ser vazia
            if (data.isEmpty) {
              return Left<IError, LevelProgressionEntity>(
                InternalErrorEntity(HomeStrings.errorNoLevelProgression),
              );
            }

            // Converter e ordenar por nível
            final List<LevelProgressionEntity> progressions =
                data
                    .map(
                      (dynamic json) => LevelProgressionModel.fromJson(
                        json as Map<String, dynamic>,
                      ),
                    )
                    .toList()
                  ..sort(
                    (LevelProgressionEntity a, LevelProgressionEntity b) =>
                        a.level.compareTo(b.level),
                  );

            // Lógica de negócio: encontrar nível atual
            LevelProgressionEntity? currentLevel;

            // Regra 1: passed_at == null E unlocked_at != null
            for (final progression in progressions) {
              if (progression.passedAt == null &&
                  progression.unlockedAt != null) {
                currentLevel = progression;
                break;
              }
            }

            // Regra 2: item anterior ao primeiro unlocked_at == null
            if (currentLevel == null) {
              for (var i = 0; i < progressions.length; i++) {
                if (progressions[i].unlockedAt == null && i > 0) {
                  currentLevel = progressions[i - 1];
                  break;
                }
              }
            }

            // Fallback: último nível desbloqueado
            currentLevel ??= progressions.last;

            return Right<IError, LevelProgressionEntity>(currentLevel);
          },
          orElse: (_) => Left<IError, LevelProgressionEntity>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      return Left<IError, LevelProgressionEntity>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, LevelProgressionEntity>(
        InternalErrorEntity(e.toString()),
      );
    }
  }
}
```

**Pontos-chave do padrão:**
1. ✅ Use `tryDecode` do mixin `DecodeModelMixin` para parsing seguro
2. ✅ Sempre verifique `response.isSuccessful` antes de processar
3. ✅ Extraia dados do campo `data` da resposta WaniKani
4. ✅ Converta JSON → Model → Entity em um só passo
5. ✅ Use `orElse` para fallback em erros de parsing
6. ✅ Retorne `ApiErrorEntity` para erros HTTP (statusCode != 2xx)
7. ✅ Retorne `InternalErrorEntity` para exceções gerais
8. ✅ Implemente validações e lógica de negócio quando necessário

### 4. UseCase Pattern

**Um arquivo = uma operação**. NUNCA agrupe múltiplos métodos:

```dart
// ✅ CORRETO - get_assignments_usecase.dart
class GetAssignmentsUseCase {
  final IAssignmentRepository _repository;
  
  const GetAssignmentsUseCase({required IAssignmentRepository repository})
      : _repository = repository;
  
  Future<Either<IError, List<AssignmentEntity>>> call() => 
      _repository.getAssignments();
}

// ✅ CORRETO - get_assignment_usecase.dart (arquivo separado)
class GetAssignmentUseCase {
  final IAssignmentRepository _repository;
  
  const GetAssignmentUseCase({required IAssignmentRepository repository})
      : _repository = repository;
  
  Future<Either<IError, AssignmentEntity>> call(int id) => 
      _repository.getAssignment(id);
}
```

### 5. State Management com Cubit

**Estados DEVEM ser sealed classes** (Dart 3.0+):

```dart
// States (assignment_state.dart)
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

// Cubit (assignment_cubit.dart)
class AssignmentCubit extends Cubit<AssignmentState> {
  final GetAssignmentsUseCase _getAssignmentsUseCase;
  
  AssignmentCubit({
    required GetAssignmentsUseCase getAssignmentsUseCase,
  })  : _getAssignmentsUseCase = getAssignmentsUseCase,
        super(AssignmentInitial());
  
  // ✅ CORRETO - Método direto, sem wrappers desnecessários
  Future<void> loadAssignments() async {
    emit(AssignmentLoading());
    
    final result = await _getAssignmentsUseCase();
    
    // ✅ SEMPRE use fold() diretamente
    result.fold(
      (error) => emit(AssignmentError(error.message)),
      (assignments) => emit(AssignmentLoaded(assignments)),
    );
  }
  
  // ❌ ERRADO - Não crie wrappers para fold()
  // void _handleResult(Either<IError, List<AssignmentEntity>> result) {
  //   result.fold(...);
  // }
}
```

### 6. UI com Switch Expressions

**SEMPRE use pattern matching** com sealed classes:

```dart
BlocBuilder<AssignmentCubit, AssignmentState>(
  builder: (context, state) => switch (state) {
    AssignmentInitial() => const SizedBox.shrink(),
    AssignmentLoading() => const CircularProgressIndicator(),
    AssignmentError(:final message) => Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    AssignmentLoaded(:final assignments) => ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(assignments[index].subjectType),
        ),
      ),
  },
)
```

---

## ⚠️ Anti-Patterns Proibidos

### 1. NÃO Misture Camadas

```dart
// ❌ ERRADO - Flutter no domain
import 'package:flutter/material.dart';
class UserEntity {
  final Color favoriteColor; // NUNCA!
}

// ✅ CORRETO - Domain puro
class UserEntity {
  final String favoriteColorHex; // Primitive types apenas
}
```

### 2. NÃO Use dynamic

```dart
// ❌ ERRADO
dynamic getData() => repository.fetch();

// ✅ CORRETO
Future<Either<IError, List<AssignmentEntity>>> getData() => 
    repository.fetch();
```

### 3. NÃO Agrupe Entidades

```dart
// ❌ ERRADO - entities.dart
class AssignmentEntity { }
class ReviewEntity { }
class SubjectEntity { }

// ✅ CORRETO - Um arquivo por entidade
// assignment_entity.dart
class AssignmentEntity { }

// review_entity.dart
class ReviewEntity { }

// subject_entity.dart
class SubjectEntity { }
```

### 4. NÃO Use Imports Relativos

```dart
// ❌ ERRADO
import '../../domain/entities/assignment_entity.dart';

// ✅ CORRETO
import 'package:wanikani_app/features/dashboard/domain/entities/assignment_entity.dart';
```

### 5. NÃO Ignore Offline-First

```dart
// ❌ ERRADO - Sem cache
Future<Either<IError, List<Entity>>> getData() async {
  final response = await api.fetch();
  return Right(response);
}

// ✅ CORRETO - Cache-first
Future<Either<IError, List<Entity>>> getData() async {
  // 1. Verificar cache
  final cached = await dao.getAll();
  if (cached.isNotEmpty && !_isExpired(cached)) {
    return Right(cached);
  }
  
  // 2. Buscar API
  try {
    final response = await api.fetch();
    await dao.upsertAll(response);
    return Right(response);
  } catch (e) {
    // 3. Fallback para cache expirado
    if (cached.isNotEmpty) {
      return Right(cached);
    }
    return Left(error);
  }
}
```

---

## 🧪 Testes Obrigatórios

### Estrutura de Testes

```
test/features/<feature>/
├── data/
│   ├── models/<feature>_model_test.dart
│   └── repositories/<feature>_repository_test.dart
├── domain/
│   └── usecases/<usecase>_test.dart
└── presentation/
    └── cubits/<feature>_cubit_test.dart
```

### Template de Teste para Repository

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatasource extends Mock implements WaniKaniDatasource {}
class MockDao extends Mock implements AssignmentDao {}

void main() {
  late AssignmentRepository repository;
  late MockDatasource mockDatasource;
  late MockDao mockDao;
  
  setUp(() {
    mockDatasource = MockDatasource();
    mockDao = MockDao();
    repository = AssignmentRepository(
      datasource: mockDatasource,
      dao: mockDao,
    );
  });
  
  group('getAssignments', () {
    test('should return cached data when cache is valid', () async {
      // Arrange
      final tEntities = [AssignmentEntity(id: 1)];
      when(() => mockDao.getAll()).thenAnswer((_) async => tEntities);
      
      // Act
      final result = await repository.getAssignments();
      
      // Assert
      expect(result, Right(tEntities));
      verify(() => mockDao.getAll()).called(1);
      verifyNever(() => mockDatasource.getAssignments());
    });
    
    test('should fetch from API when cache is empty', () async {
      // Arrange
      when(() => mockDao.getAll()).thenAnswer((_) async => []);
      when(() => mockDatasource.getAssignments()).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          data: {'data': [{'id': 1}]},
        ),
      );
      
      // Act
      final result = await repository.getAssignments();
      
      // Assert
      expect(result.isRight(), true);
      verify(() => mockDatasource.getAssignments()).called(1);
    });
    
    test('should return ApiErrorEntity on DioException', () async {
      // Arrange
      when(() => mockDao.getAll()).thenAnswer((_) async => []);
      when(() => mockDatasource.getAssignments()).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );
      
      // Act
      final result = await repository.getAssignments();
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<ApiErrorEntity>()),
        (_) => fail('Should return error'),
      );
    });
  });
}
```

### Template de Teste para Cubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUseCase extends Mock implements GetAssignmentsUseCase {}

void main() {
  late AssignmentCubit cubit;
  late MockUseCase mockUseCase;
  
  setUp(() {
    mockUseCase = MockUseCase();
    cubit = AssignmentCubit(getAssignmentsUseCase: mockUseCase);
  });
  
  tearDown(() => cubit.close());
  
  group('loadAssignments', () {
    final tEntities = [AssignmentEntity(id: 1)];
    
    blocTest<AssignmentCubit, AssignmentState>(
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => Right(tEntities));
        return cubit;
      },
      act: (cubit) => cubit.loadAssignments(),
      expect: () => [
        AssignmentLoading(),
        AssignmentLoaded(tEntities),
      ],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
      },
    );
    
    blocTest<AssignmentCubit, AssignmentState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockUseCase()).thenAnswer(
          (_) async => Left(InternalErrorEntity('Error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadAssignments(),
      expect: () => [
        AssignmentLoading(),
        const AssignmentError('Error'),
      ],
    );
  });
}
```

---

## 🎨 Design System

### Cores Principais

```dart
// Theme colors (já definidas em lib/core/theme/)
AppColors.primary      // #DD0093 (Rosa WaniKani)
AppColors.secondary    // #00AAFF (Azul)
AppColors.background   // #1A1A2E (Escuro)
AppColors.surface      // #2D2D44 (Cards)
AppColors.error        // #FF4444 (Erro)
AppColors.success      // #00D9A3 (Sucesso)
AppColors.warning      // #FFB800 (Aviso)
```

### Tipografia

```dart
// SEMPRE use Noto Sans JP
TextStyle(
  fontFamily: 'Noto Sans JP',
  fontWeight: FontWeight.w400, // Regular
  fontSize: 16,
)

// Hierarquia de tamanhos
headlineLarge: 32px, bold
headlineMedium: 24px, semibold
titleLarge: 20px, semibold
bodyLarge: 16px, regular
bodyMedium: 14px, regular
labelSmall: 12px, medium
```

### Espaçamento

```dart
// Use múltiplos de 8
const spacing4 = 4.0;
const spacing8 = 8.0;
const spacing16 = 16.0;
const spacing24 = 24.0;
const spacing32 = 32.0;
```

---

## 📋 Checklist de Pull Request

Antes de considerar uma tarefa completa, verifique:

### Código
- [ ] Segue Clean Architecture (camadas corretas)
- [ ] Usa `Either<IError, T>` em repositories
- [ ] Usa extension types para models
- [ ] Usa sealed classes para states
- [ ] Usa switch expressions na UI
- [ ] Sem imports relativos
- [ ] Sem `dynamic` types
- [ ] Sem Flutter no domain
- [ ] Line length ≤ 80 caracteres
- [ ] Single quotes apenas

### Funcionalidade
- [ ] Implementa offline-first (quando aplicável)
- [ ] Trata todos os casos de erro
- [ ] Usa DioException pattern obrigatório
- [ ] Cache com TTL apropriado (24h padrão)
- [ ] Fallback para cache expirado em erro de rede

### Testes
- [ ] Testes unitários para repository
- [ ] Testes unitários para usecase
- [ ] Testes de cubit com bloc_test
- [ ] Coverage ≥ 80%
- [ ] Todos os testes passando

### Documentação
- [ ] Comentários em código complexo
- [ ] JSDoc em métodos públicos (quando necessário)
- [ ] README atualizado (se necessário)

### Quality Assurance
- [ ] `flutter analyze` sem erros
- [ ] `dart format .` aplicado
- [ ] `flutter test` 100% passed
- [ ] Build rodando sem erros

---

## 🚀 Comandos Essenciais

```bash
# Gerar código (Drift, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch mode durante desenvolvimento
dart run build_runner watch

# Rodar testes com coverage
flutter test --coverage

# Analisar código
flutter analyze

# Formatar código
dart format . --set-exit-if-changed

# Rodar app em modo MOCK
flutter run -t lib/main_mock.dart

# Rodar app em modo PRODUÇÃO
flutter run
```

---

## 🎯 Workflow de Desenvolvimento

### Para Implementar uma Nova Feature

1. **Planejamento**
   - Ler BUSINESS_LOGIC.md para entender o domínio
   - Ler API_SPECIFICATION.md para endpoints necessários
   - Identificar entidades, usecases e estados necessários

2. **Domain Layer** (começar SEMPRE aqui)
   ```bash
   # Criar estrutura
   mkdir -p lib/features/<feature>/domain/{entities,repositories,usecases}
   
   # Implementar nesta ordem:
   # 1. entities/<entity>_entity.dart
   # 2. repositories/i_<entity>_repository.dart
   # 3. usecases/get_<entity>_usecase.dart
   # 4. usecases/<action>_<entity>_usecase.dart (outras operações)
   ```

3. **Data Layer**
   ```bash
   # Criar estrutura
   mkdir -p lib/features/<feature>/data/{models,datasources,repositories}
   
   # Implementar nesta ordem:
   # 1. models/<entity>_model.dart (extension type)
   # 2. datasources/<api>_datasource.dart (Dio)
   # 3. datasources/<entity>_dao.dart (Drift)
   # 4. repositories/<entity>_repository.dart (implementa interface)
   ```

4. **Presentation Layer**
   ```bash
   # Criar estrutura
   mkdir -p lib/features/<feature>/presentation/{cubits,screens,widgets}
   
   # Implementar nesta ordem:
   # 1. cubits/<feature>_state.dart (sealed classes)
   # 2. cubits/<feature>_cubit.dart
   # 3. screens/<feature>_screen.dart
   # 4. widgets/<component>_widget.dart
   ```

5. **Dependency Injection**
   ```dart
   // Em lib/core/dependency_injection/service_locator.dart
   
   // Datasources
   getIt.registerLazySingleton(() => EntityDatasource(getIt()));
   getIt.registerLazySingleton(() => EntityDao(getIt()));
   
   // Repositories
   getIt.registerLazySingleton<IEntityRepository>(
     () => EntityRepository(datasource: getIt(), dao: getIt()),
   );
   
   // UseCases
   getIt.registerLazySingleton(() => GetEntityUseCase(repository: getIt()));
   
   // Cubits (factory para novas instâncias)
   getIt.registerFactory(() => EntityCubit(useCase: getIt()));
   ```

6. **Routing**
   ```dart
   // Em lib/routing/app_routes.dart
   static const String entityScreen = '/entity';
   
   // Em lib/routing/app_router.dart
   GoRoute(
     path: AppRoutes.entityScreen,
     builder: (context, state) => BlocProvider(
       create: (context) => getIt<EntityCubit>(),
       child: const EntityScreen(),
     ),
   ),
   ```

7. **Testes**
   ```bash
   # Criar estrutura de testes espelhando lib/
   mkdir -p test/features/<feature>/{data,domain,presentation}
   
   # Escrever testes (ordem não importa, mas comece por repository)
   # 1. data/repositories/<entity>_repository_test.dart
   # 2. domain/usecases/<usecase>_test.dart
   # 3. presentation/cubits/<feature>_cubit_test.dart
   ```

8. **Validação Final**
   ```bash
   # Rodar validações
   flutter analyze
   flutter test --coverage
   dart format . --set-exit-if-changed
   
   # Se tudo OK, commitar
   git add .
   git commit -m "feat: implement <feature> with offline support"
   ```

---

## 🔥 Prioridades Técnicas Atuais

### HIGH Priority
1. **AuthInterceptor global** - Interceptar 401 e redirecionar para login
2. **Standardize DioException** - Aplicar pattern em todos os repositories
3. **Drift cache implementation** - Implementar DAOs para todas as entities
4. **Fix SplashCubit** - Resolver emit after close (linha 48)

### MEDIUM Priority
1. **Reviews feature** - Sistema interativo de revisão
2. **Lessons feature** - Sistema de aprendizado progressivo
3. **Statistics feature** - Gráficos de desempenho
4. **Sync service** - Sincronização em background

### LOW Priority
1. **Settings feature** - Configurações do app
2. **Notifications** - Push notifications para reviews
3. **Dark theme toggle** - Alternar entre temas
4. **Language toggle** - Alternar idioma da UI

---

## 📞 Suporte e Referências

### Quando Tiver Dúvidas

1. **Padrões de código** → Consulte CLAUDE.meta.md
2. **Estrutura de pastas** → Consulte CODEBASE_GUIDE.md
3. **Erros conhecidos** → Consulte TROUBLESHOOTING.md
4. **Integrações API** → Consulte API_SPECIFICATION.md
5. **Lógica de negócio** → Consulte BUSINESS_LOGIC.md
6. **Design/UI** → Consulte DESIGN_SYSTEM.md

### Recursos Externos

- **Flutter Docs**: https://docs.flutter.dev
- **Drift Docs**: https://drift.simonbinder.eu
- **BLoC Docs**: https://bloclibrary.dev
- **WaniKani API**: https://docs.api.wanikani.com
- **Dartz (Either)**: https://pub.dev/packages/dartz
- **GetIt**: https://pub.dev/packages/get_it

---

## ✅ Resumo Executivo

### O Que Você DEVE Fazer
✅ Seguir Clean Architecture rigorosamente  
✅ Usar `Either<IError, T>` em todos os repositories  
✅ Implementar offline-first com Drift  
✅ Usar extension types para models  
✅ Usar sealed classes para states  
✅ Escrever testes para tudo (≥80% coverage)  
✅ Consultar documentação antes de implementar  
✅ Aplicar DioException pattern obrigatório  
✅ Manter line length ≤80 caracteres  
✅ Usar package imports (nunca relativos)  

### O Que Você NÃO DEVE Fazer
❌ Misturar Flutter no domain layer  
❌ Usar `dynamic` types  
❌ Ignorar cache/offline-first  
❌ Agrupar múltiplas entidades em um arquivo  
❌ Criar "god classes" ou usecases multipropósito  
❌ Usar imports relativos  
❌ Pular testes  
❌ Fazer commit sem rodar `flutter analyze`  
❌ Criar código sem consultar documentação  
❌ Usar double quotes (sempre single quotes)  

---

**Lembre-se:** Este projeto valoriza qualidade e manutenibilidade. Se você seguir este guia, o código será consistente, testável e fácil de evoluir. Boa sorte! 🚀
