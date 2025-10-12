# ADR-002: BLoC/Cubit para State Management

**Status:** Aceito  
**Data:** 11/10/2025  
**Decisores:** Samuel (samukazangetsu)  
**Tags:** #state-management #bloc #cubit #presentation

---

## Contexto e Problema

O WaniKani App precisa de uma solução de gerenciamento de estado que:

1. **Seja reativa** - UI atualiza automaticamente quando dados mudam
2. **Seja testável** - fácil escrever testes para lógica de estado
3. **Separe UI de lógica** - widgets não devem conter business logic
4. **Seja escalável** - suporte múltiplas features independentes
5. **Seja previsível** - estados bem definidos e transitions claras

**Problema específico:** Como gerenciar estado de forma que seja consistente com Clean Architecture e facilite desenvolvimento assistido por IA?

---

## Decisão

Adotaremos **flutter_bloc** usando o padrão **Cubit** (simplificação do BLoC) para gerenciar estado da camada de apresentação.

### Padrão Cubit

```dart
// State (sealed class para type safety)
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

// Cubit
class AssignmentCubit extends Cubit<AssignmentState> {
  final GetAssignmentsUseCase _getAssignmentsUseCase;
  final UpdateAssignmentUseCase _updateAssignmentUseCase;
  
  AssignmentCubit({
    required GetAssignmentsUseCase getAssignmentsUseCase,
    required UpdateAssignmentUseCase updateAssignmentUseCase,
  })  : _getAssignmentsUseCase = getAssignmentsUseCase,
        _updateAssignmentUseCase = updateAssignmentUseCase,
        super(AssignmentInitial());
  
  Future<void> loadAssignments() async {
    emit(AssignmentLoading());
    final result = await _getAssignmentsUseCase();
    result.fold(
      (error) => emit(AssignmentError(error.message)),
      (assignments) => emit(AssignmentLoaded(assignments)),
    );
  }
  
  Future<void> updateAssignment(int id) async {
    if (state is! AssignmentLoaded) return;
    
    final currentState = state as AssignmentLoaded;
    final result = await _updateAssignmentUseCase(id);
    
    result.fold(
      (error) => emit(AssignmentError(error.message)),
      (updated) {
        final newList = currentState.assignments
            .map((a) => a.id == id ? updated : a)
            .toList();
        emit(AssignmentLoaded(newList));
      },
    );
  }
}
```

### Uso na UI

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AssignmentCubit>()..loadAssignments(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: BlocConsumer<AssignmentCubit, AssignmentState>(
          listener: (context, state) {
            if (state is AssignmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              AssignmentInitial() => const Center(child: Text('Inicializando...')),
              AssignmentLoading() => const Center(child: CircularProgressIndicator()),
              AssignmentError() => const Center(child: Text('Erro ao carregar')),
              AssignmentLoaded(:final assignments) => ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) => AssignmentCard(assignments[index]),
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

## Justificativa

### Por Que BLoC/Cubit?

1. **Alinhamento com Clean Architecture**
   - Cubits ficam na presentation layer
   - Dependem apenas de use cases (domain layer)
   - Sem acesso direto a repositories ou datasources

2. **Testabilidade Excepcional**
   - Testes de unidade simples (emit states)
   - `bloc_test` package para testes declarativos
   - Mock de use cases trivial

3. **Reatividade Built-in**
   - Stream-based - UI rebuild automático
   - BlocBuilder, BlocListener, BlocConsumer
   - Performance otimizada (rebuild seletivo)

4. **Estados Imutáveis**
   - Estados são classes (not maps/enums)
   - Equatable para comparação eficiente
   - Time-travel debugging possível

5. **Pattern Matching com Sealed Classes**
   - Dart 3.0+ sealed classes
   - Exhaustive checking em switch
   - Compile-time safety

6. **IA-Friendly**
   - Padrão repetitivo e previsível
   - Copilot gera Cubits consistentemente
   - Estados bem tipados facilitam compreensão

### Cubit vs BLoC Completo

**Escolhemos Cubit (não BLoC) porque:**

| Aspecto | Cubit | BLoC |
|---------|-------|------|
| Complexidade | Simples (functions) | Complexo (events + states) |
| Boilerplate | Baixo | Alto (events, mappers) |
| Curva Aprendizado | Suave | Íngreme |
| Use Cases | 90% dos casos | Casos muito complexos |
| IA Assistance | Melhor (menos código) | Mais difícil |

**Quando usar BLoC completo:**
- Estados complexos com múltiplos eventos simultâneos
- Necessidade de event transformation (debounce, throttle)
- Event sourcing obrigatório

**Para WaniKani App:** Cubit é suficiente (features relativamente simples)

---

## Consequências

### Positivas ✅

1. **Testes Declarativos**

```dart
blocTest<AssignmentCubit, AssignmentState>(
  'emits [Loading, Loaded] when loadAssignments succeeds',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) async => Right([assignment1]));
    return AssignmentCubit(getAssignmentsUseCase: mockUseCase);
  },
  act: (cubit) => cubit.loadAssignments(),
  expect: () => [
    AssignmentLoading(),
    AssignmentLoaded([assignment1]),
  ],
);
```

2. **Separação UI e Lógica**
   - Widgets puramente visuais
   - Lógica isolada em Cubits
   - Fácil refactoring de UI sem quebrar lógica

3. **Debugging Facilitado**
   - BlocObserver para logging global
   - Estados nomeados e rastreáveis
   - Fácil reproduzir bugs com estados específicos

4. **Reutilização de Estados**
   - Estados podem ser compartilhados entre widgets
   - BlocProvider injeta Cubit na árvore
   - MultiBlocProvider para múltiplos Cubits

### Negativas ⚠️

1. **Curva de Aprendizado Inicial**
   - Conceito de streams pode confundir
   - BlocProvider, BlocBuilder, BlocConsumer diferentes
   - **Mitigação:** Documentação e exemplos (este ADR)

2. **Boilerplate de Estados**
   - Muitas classes de estado para features simples
   - Sealed classes exigem Dart 3.0+
   - **Mitigação:** Aceitar como investimento em type safety

3. **Overhead de Performance (Mínimo)**
   - Streams têm overhead vs setState direto
   - Rebuild toda a árvore se mal implementado
   - **Mitigação:** BlocSelector para rebuilds seletivos

---

## Alternativas Consideradas

### 1. Provider (State Management Simples)

**Prós:**
- Simples e oficial Flutter
- Pouco boilerplate
- Boa performance

**Contras:**
- ❌ Sem estrutura para estados complexos
- ❌ Dificulta separação UI/lógica
- ❌ Testes menos declarativos

**Decisão:** Rejeitado - insuficiente para features complexas

### 2. Riverpod

**Prós:**
- Evolução do Provider
- Compile-time safety
- Excelente para DI

**Contras:**
- ❌ Curva de aprendizado alta
- ❌ Ecosystem menor que BLoC
- ❌ Padrões menos estabelecidos

**Decisão:** Rejeitado - BLoC tem patterns mais claros

### 3. GetX

**Prós:**
- Tudo-em-um (state, routing, DI)
- Performance excelente
- Pouco boilerplate

**Contras:**
- ❌ "Magic" demais (implicit dependencies)
- ❌ Dificulta testes (global state)
- ❌ Não alinha com Clean Architecture
- ❌ IA tem dificuldade com patterns GetX

**Decisão:** Rejeitado - vai contra princípios de Clean Architecture

### 4. MobX

**Prós:**
- Observables automáticos
- Pouco boilerplate

**Contras:**
- ❌ Code generation obrigatório
- ❌ "Magic" dificulta debugging
- ❌ Menos popular que BLoC

**Decisão:** Rejeitado - preferência por explicitness

---

## Padrões e Convenções

### Estrutura de Arquivos

```
features/dashboard/
└── presentation/
    ├── cubits/
    │   ├── assignment_cubit.dart       # Lógica
    │   └── assignment_state.dart       # Estados
    ├── screens/
    │   └── dashboard_screen.dart       # UI principal
    └── widgets/
        └── assignment_card.dart        # Componentes
```

### Nomenclatura Padrão

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Cubit | `<Feature>Cubit` | `AssignmentCubit` |
| State Base | `<Feature>State` | `AssignmentState` |
| State Inicial | `<Feature>Initial` | `AssignmentInitial` |
| State Loading | `<Feature>Loading` | `AssignmentLoading` |
| State Erro | `<Feature>Error` | `AssignmentError` |
| State Sucesso | `<Feature>Loaded` | `AssignmentLoaded` |

### Estados Padrão para Todas Features

Toda feature deve ter **no mínimo** estes estados:

```dart
sealed class FeatureState extends Equatable {}

final class FeatureInitial extends FeatureState {}
final class FeatureLoading extends FeatureState {}
final class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);
}
final class FeatureLoaded extends FeatureState {
  final DataType data;
  const FeatureLoaded(this.data);
}
```

### Dependency Injection com GetIt

```dart
// Registrar Cubit no service locator
getIt.registerFactory(() => AssignmentCubit(
  getAssignmentsUseCase: getIt(),
  updateAssignmentUseCase: getIt(),
));

// Usar na UI
BlocProvider(
  create: (context) => getIt<AssignmentCubit>(),
  child: DashboardScreen(),
)
```

---

## Validação e Compliance

### Checklist para Novo Cubit

- [ ] Sealed class para estados (type safety)
- [ ] Equatable implementado em todos os estados
- [ ] Estados mínimos: Initial, Loading, Error, Loaded
- [ ] Cubit depende apenas de use cases (não repositories)
- [ ] Use cases injetados via construtor (DI)
- [ ] Métodos async retornam `Future<void>`
- [ ] Error handling com Either monad
- [ ] Testes unitários usando `bloc_test`

### Exemplo de Teste

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

  group('loadAssignments', () {
    final tAssignments = [AssignmentEntity(id: 1, subjectType: 'kanji')];

    blocTest<AssignmentCubit, AssignmentState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => Right(tAssignments));
        return cubit;
      },
      act: (cubit) => cubit.loadAssignments(),
      expect: () => [
        AssignmentLoading(),
        AssignmentLoaded(tAssignments),
      ],
    );

    blocTest<AssignmentCubit, AssignmentState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockUseCase()).thenAnswer(
          (_) async => Left(ApiErrorEntity('Network error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadAssignments(),
      expect: () => [
        AssignmentLoading(),
        const AssignmentError('Network error'),
      ],
    );
  });
}
```

---

## Referências

- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Flutter BLoC - Reso Coder](https://resocoder.com/flutter-bloc-clean-architecture/)
- [Equatable Package](https://pub.dev/packages/equatable)
- [bloc_test Package](https://pub.dev/packages/bloc_test)

---

## Notas de Migração

### Se Migrar para BLoC Completo no Futuro

Cubit pode ser facilmente convertido para BLoC:

```dart
// Cubit (atual)
cubit.loadAssignments();

// BLoC (futuro)
bloc.add(LoadAssignmentsEvent());
```

Migração é incremental - pode ter Cubits e BLoCs coexistindo.

---

**Última Revisão:** 11/10/2025  
**Próxima Revisão:** Após 3 features implementadas com Cubit
