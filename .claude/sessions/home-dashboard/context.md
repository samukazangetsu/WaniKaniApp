# Context: Feature Home/Dashboard - MVP

> **Feature Branch:** `feature/home-dashboard`  
> **Data de Início:** 11/10/2025  
> **Requisitos:** [specs/technical/features/001-home-dashboard.md](../../../specs/technical/features/001-home-dashboard.md)

---

## 📌 Por Que (Contexto)

### Objetivo Principal
Criar a primeira funcionalidade do aplicativo WaniKani App, estabelecendo a **fundação arquitetural** que será reutilizada em todas as features futuras.

### Motivações-Chave
1. **Implementar Arquitetura Base**: Navegação (go_router), DI (GetIt), networking (Dio + pop_network), state management (BLoC/Cubit)
2. **Validar Clean Architecture**: Testar padrões na prática antes de expandir
3. **Feedback Rápido ao Usuário**: Mostrar progresso essencial de estudo
4. **Estabelecer TDD**: Testes antes de implementação desde o início

---

## 🎯 O Que (Objetivo)

### Resultado Esperado
Uma tela **Home/Dashboard funcional** que exibe 3 métricas do progresso do usuário no WaniKani:

1. **Nível Atual** - Progressão do usuário (1-60)
2. **Reviews Disponíveis** - Contagem de assignments prontos para review
3. **Lessons Disponíveis** - Contagem de novos items para aprender

### Critérios de Aceitação
- ✅ Tela exibe as 3 métricas corretamente
- ✅ Loading state visível durante fetch de dados
- ✅ Error dialog aparece em caso de falha com botão de retry
- ✅ Mock development funcionando (lendo JSONs locais)
- ✅ Navegação configurada (go_router)
- ✅ Dependency injection configurado (GetIt)
- ✅ Testes com >80% de cobertura
- ✅ `flutter analyze` sem erros
- ✅ Código formatado (`dart format .`)

---

## 🔨 Como (Abordagem)

### Estratégia de Desenvolvimento

**1. TDD Rigoroso**
- Escrever testes **ANTES** da implementação
- Seguir ciclo Red-Green-Refactor
- Cobertura mínima: 80%

**2. Clean Architecture em 3 Camadas**
```
Domain (Pure Dart) → Data (Infra) → Presentation (UI)
```

**3. Mock Development**
- Usar `main_mock.dart` como entrypoint
- Mock interceptor lê JSONs de `assets/mock/`
- Token da API hardcoded (sem autenticação por enquanto)

**4. Simplificações Temporárias**
- ❌ SEM cache/Drift
- ❌ SEM splash screen customizada
- ❌ SEM tela de login/autenticação
- ❌ SEM validação de token via API
- ❌ SEM internacionalização

---

## 📡 APIs e Ferramentas

### Endpoints WaniKani v2

**1. GET /level_progressions**
- Propósito: Obter nível atual do usuário
- Filtro: Último registro com `started_at != null`
- Retorno: `LevelProgressionEntity` com campo `level`

**2. GET /assignments**
- Propósito: Obter todos os assignments para calcular métricas
- Cálculos necessários:
  - **Reviews**: `available_at <= DateTime.now()`
  - **Lessons**: `srs_stage == 0`
- Retorno: Lista de `AssignmentEntity`

### Bibliotecas Chave

**pop_network (^1.2.1)**
- Documentação: https://pub.dev/packages/pop_network
- Wrapper sobre Dio para networking
- Usar para configuração do API client

**go_router (^13.0.0)**
- Navegação declarativa
- Rota única inicial: `/` → HomeScreen

**GetIt (^7.6.0)**
- Service locator para DI
- Registros lazy singleton e factory

**flutter_bloc (^9.1.1)**
- State management com Cubit
- Sealed classes para states (Dart 3.0+)

**dartz (^0.10.1)**
- Functional programming
- `Either<IError, T>` para error handling

---

## 🏗️ Arquitetura da Feature

### Estrutura de Arquivos

```
lib/features/home/
├── data/
│   ├── datasources/
│   │   └── wanikani_datasource.dart           # API calls
│   ├── models/
│   │   ├── assignment_model.dart              # Extension type
│   │   └── level_progression_model.dart       # Extension type
│   └── repositories/
│       └── home_repository.dart               # Implementa IHomeRepository
│
├── domain/
│   ├── entities/
│   │   ├── assignment_entity.dart             # Pure Dart
│   │   ├── level_progression_entity.dart      # Pure Dart
│   │   └── assignment_metrics.dart            # Agregado: reviewCount + lessonCount
│   ├── repositories/
│   │   └── i_home_repository.dart             # Interface
│   └── usecases/
│       ├── get_current_level_usecase.dart     # Busca nível atual
│       └── get_assignment_metrics_usecase.dart # Busca e calcula métricas
│
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

### Infraestrutura Core

```
lib/core/
├── di/
│   └── service_locator.dart                   # Setup GetIt
├── network/
│   └── interceptors/
│       └── mock_interceptor.dart              # Mock para desenvolvimento
└── error/                                      # ✅ Já existe
    ├── ierror.dart
    ├── api_error_entity.dart
    └── internal_error_entity.dart
```

### Navegação

```
lib/routing/
└── app_router.dart                            # Configuração go_router
```

---

## 🧪 Estratégia de Testes

### Estrutura de Testes (TDD)

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
│       └── get_assignment_metrics_usecase_test.dart
└── presentation/
    └── cubits/
        └── home_cubit_test.dart
```

### Ferramentas
- **mocktail**: Mocks para testes unitários
- **bloc_test**: Testes de Cubit
- **flutter_test**: Framework de testes

### Ordem de Execução (TDD)
1. Escrever teste → Red
2. Implementar código mínimo → Green
3. Refatorar → Refactor
4. Repetir

---

## 🎨 Design e UI/UX

### Layout Simplificado
- AppBar com título "WaniKani"
- 3 Cards verticais (Column):
  - Card 1: Nível Atual (ex: "Nível 5")
  - Card 2: Reviews Disponíveis (ex: "42 Reviews")
  - Card 3: Lessons Disponíveis (ex: "12 Lessons")

### Estados Visuais
- **Initial**: Vazio/placeholder
- **Loading**: CircularProgressIndicator centralizado
- **Loaded**: Exibe os 3 cards com dados
- **Error**: Dialog com mensagem + botão "Tentar Novamente"

### Componentes Reutilizáveis
- `DashboardMetricCard`: Widget que recebe título, valor e ícone
- `ErrorDialog`: Dialog com mensagem e callback de retry

---

## 🔧 Detalhes de Implementação

### Use Cases - Regra de Criação

**Princípio:** Um use case por requisição HTTP diferente

Como temos 2 endpoints:
1. `GET /level_progressions`
2. `GET /assignments`

Teremos 2 use cases:
1. **GetCurrentLevelUseCase**
   - Chama `repository.getLevelProgressions()`
   - Filtra último level com `started_at != null`
   - Retorna `Either<IError, int>` (apenas o número do nível)

2. **GetAssignmentMetricsUseCase**
   - Chama `repository.getAssignments()`
   - Calcula reviewCount (available_at <= now)
   - Calcula lessonCount (srs_stage == 0)
   - Retorna `Either<IError, AssignmentMetrics>`

### Entities - Convenções

**❌ NÃO usar "Data" no nome:**
```dart
// ERRADO
class UserData { ... }
class DashboardData { ... }

// CORRETO
class User { ... }
class Dashboard { ... }
```

**✅ Entity Agregada:**
```dart
class AssignmentMetrics {
  final int reviewCount;
  final int lessonCount;
  
  const AssignmentMetrics({
    required this.reviewCount,
    required this.lessonCount,
  });
}
```

### Cubit State

```dart
sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}

final class HomeLoaded extends HomeState {
  final int currentLevel;
  final AssignmentMetrics metrics;
  
  const HomeLoaded({
    required this.currentLevel,
    required this.metrics,
  });
  
  @override
  List<Object> get props => [currentLevel, metrics];
}
```

### Mock Interceptor

**Localização:** `lib/core/network/interceptors/mock_interceptor.dart`

**Registro:** Apenas no `main_mock.dart`

**Comportamento:**
- Base URL: vazia ("")
- Intercepta requisições
- Lê JSON correspondente de `assets/mock/`
- Retorna Response mockado com status 200

**Flag de Ambiente:**
```dart
enum Environment {
  mock,
  development,
  production,
}
```

### Repository Interface

```dart
abstract class IHomeRepository {
  Future<Either<IError, List<LevelProgressionEntity>>> getLevelProgressions();
  Future<Either<IError, List<AssignmentEntity>>> getAssignments();
}
```

**Observação:** Repository retorna listas completas, use cases fazem os cálculos/filtros.

---

## 🚧 Dependências e Restrições

### Dependências Existentes
- ✅ Mock JSONs prontos em `assets/mock/`
- ✅ Error entities implementados (`IError`, `ApiErrorEntity`, `InternalErrorEntity`)
- ✅ Todas as libs necessárias no `pubspec.yaml`
- ✅ Mixins de decode (`DecodeModelMixin`) disponíveis

### Restrições
- Token da API **hardcoded** (sem `flutter_secure_storage` ainda)
- SEM cache/persistência (Drift não será usado)
- SEM tratamento de paginação da API (assumir 500 items por página)
- Desenvolvimento 100% em modo mock

### Configuração Necessária
- Adicionar `assets/mock/` ao `pubspec.yaml` em `flutter.assets`

---

## 📋 Checklist de Validação

### Funcional
- [ ] Home screen carrega e exibe loading state
- [ ] Após load, exibe 3 métricas corretas
- [ ] Nível atual corresponde ao último level progression
- [ ] Review count corresponde a assignments disponíveis
- [ ] Lesson count corresponde a assignments com srs_stage=0
- [ ] Error dialog aparece em caso de falha
- [ ] Retry recarrega os dados

### Técnico
- [ ] Testes unitários passando (>80% coverage)
- [ ] `flutter analyze` sem warnings/erros
- [ ] `dart format .` aplicado
- [ ] go_router configurado
- [ ] GetIt registrando dependências
- [ ] Mock interceptor funcionando
- [ ] Clean Architecture respeitada
- [ ] Código segue convenções documentadas

### Arquitetural
- [ ] Domain layer sem imports Flutter
- [ ] Extension types nos models
- [ ] Sealed classes nos states
- [ ] Either<IError, T> em todos os retornos
- [ ] Package imports (nunca relative)
- [ ] Um use case por endpoint HTTP
- [ ] Entities sem sufixo "Data"

---

## 📚 Documentos Relacionados

- [Requisitos](../../../specs/technical/features/001-home-dashboard.md)
- [CLAUDE.meta.md](../../../specs/technical/CLAUDE.meta.md) - Padrões de código
- [CODEBASE_GUIDE.md](../../../specs/technical/CODEBASE_GUIDE.md) - Navegação
- [API_SPECIFICATION.md](../../../specs/technical/API_SPECIFICATION.md) - API WaniKani

---

**Status:** ✅ Context aprovado - Pronto para arquitetura  
**Próximo Passo:** Criar `architecture.md` com design detalhado
