# ADR-001: Clean Architecture por Features

**Status:** Aceito  
**Data:** 11/10/2025  
**Decisores:** Samuel (samukazangetsu)  
**Tags:** #arquitetura #clean-architecture #estrutura

---

## Contexto e Problema

O WaniKani App precisa de uma arquitetura que suporte:

1. **Separação clara de responsabilidades** entre UI, lógica de negócio e acesso a dados
2. **Testabilidade** - facilidade para escrever testes unitários em todas as camadas
3. **Manutenibilidade** - código organizado e fácil de modificar
4. **Escalabilidade** - facilidade para adicionar novas features sem impactar código existente
5. **Independência de frameworks** - lógica de negócio não deve depender de Flutter/Dart específico

**Problema específico:** Como estruturar o código de forma que seja fácil para ferramentas de IA (GitHub Copilot, Claude) entenderem e contribuírem de forma consistente?

---

## Decisão

Adotaremos **Clean Architecture** organizada **por features** com as seguintes camadas:

### Estrutura de Diretórios

```dart
lib/
├── core/                          // Shared utilities
│   ├── error/                     // Error entities e interfaces
│   ├── mixins/                    // Mixins reutilizáveis
│   ├── strings/                   // Constantes de texto
│   └── utils/                     // Utilitários gerais
│
├── features/                      // Features organizadas por domínio
│   └── <feature_name>/            // Ex: dashboard, statistics, auth
│       ├── data/                  // Camada de dados
│       │   ├── datasources/       // Comunicação com API/DB
│       │   ├── models/            // Models com serialização JSON
│       │   └── repositories/      // Implementações de repositories
│       │
│       ├── domain/                // Camada de domínio (regras de negócio)
│       │   ├── entities/          // Entidades de negócio (pure Dart)
│       │   ├── repositories/      // Interfaces de repositories (IRepository)
│       │   └── usecases/          // Use cases (1 arquivo = 1 operação)
│       │
│       └── presentation/          // Camada de apresentação
│           ├── cubits/            // State management (BLoC/Cubit)
│           ├── screens/           // Telas completas
│           └── widgets/           // Widgets reutilizáveis da feature
│
├── config/                        // Configuração de ambientes
│   ├── main_mock.dart            // Ambiente mock (desenvolvimento)
│   └── main_production.dart      // Ambiente produção
│
└── routing/                       // Configuração de rotas globais
    └── app_router.dart
```

### Regras de Dependência

```
presentation → domain ← data
     ↓            ↓        ↓
   core ←────────┴────────┘
```

**Princípios:**
1. **Domain** não depende de nada (pure Dart)
2. **Data** e **Presentation** dependem de **Domain**
3. **Core** é compartilhado por todos
4. Dependências apontam sempre para dentro (domain é o centro)

### Separação de Responsabilidades

#### Data Layer

```dart
// datasources/wanikani_datasource.dart
class WaniKaniDatasource {
  final IApiManager _apiManager;
  
  Future<Response<dynamic>> getAssignments() => _apiManager.get('/assignments');
}

// models/assignment_model.dart
extension type AssignmentModel(AssignmentEntity entity) implements AssignmentEntity {
  AssignmentModel.fromJson(Map<String, dynamic> json)
      : entity = AssignmentEntity(
          id: json['id'],
          subjectType: json['subject_type'],
          // ...
        );
}

// repositories/assignment_repository.dart
class AssignmentRepository implements IAssignmentRepository {
  final WaniKaniDatasource _datasource;
  
  @override
  Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
    // Implementação com error handling
  }
}
```

#### Domain Layer

```dart
// entities/assignment_entity.dart
class AssignmentEntity {
  final int id;
  final String subjectType;
  final int srsStage;
  // Pure Dart - sem dependências externas
}

// repositories/i_assignment_repository.dart
abstract class IAssignmentRepository {
  Future<Either<IError, List<AssignmentEntity>>> getAssignments();
}

// usecases/get_assignments_usecase.dart
class GetAssignmentsUseCase {
  final IAssignmentRepository _repository;
  
  Future<Either<IError, List<AssignmentEntity>>> call() => 
      _repository.getAssignments();
}
```

#### Presentation Layer

```dart
// cubits/assignment_cubit.dart
class AssignmentCubit extends Cubit<AssignmentState> {
  final GetAssignmentsUseCase _getAssignmentsUseCase;
  
  Future<void> loadAssignments() async {
    emit(AssignmentLoading());
    final result = await _getAssignmentsUseCase();
    result.fold(
      (error) => emit(AssignmentError(error.message)),
      (assignments) => emit(AssignmentLoaded(assignments)),
    );
  }
}

// screens/dashboard_screen.dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      builder: (context, state) {
        // UI baseada no state
      },
    );
  }
}
```

---

## Justificativa

### Por Que Clean Architecture?

1. **Testabilidade Superior**
   - Cada camada pode ser testada isoladamente
   - Mocks simples através de interfaces
   - Domain layer testável sem Flutter

2. **Separação Clara de Concerns**
   - UI não conhece detalhes de persistência
   - Lógica de negócio independente de frameworks
   - Fácil substituir implementações (ex: trocar Dio por HTTP)

3. **Escalabilidade**
   - Adicionar features não impacta código existente
   - Organização por domínio facilita navegação
   - Equipes podem trabalhar em features isoladas

4. **IA-Friendly**
   - Estrutura previsível facilita compreensão por IA
   - Padrões repetitivos (Entity → Model → Repository → UseCase → Cubit)
   - Ferramentas como Copilot geram código consistente

5. **Manutenibilidade**
   - Mudanças em uma camada não afetam outras
   - Código fácil de localizar (convenção de nomes)
   - Refactoring seguro com interfaces bem definidas

### Por Que Organização por Features?

**Alternativa Considerada:** Organização por camadas (data/, domain/, presentation/ globais)

**Rejeitada porque:**
- ❌ Dificulta encontrar código relacionado a uma feature
- ❌ Arquivos de uma feature espalhados em pastas diferentes
- ❌ Dificulta desenvolvimento paralelo de features
- ❌ Features crescem e ficam misturadas

**Features-first vence porque:**
- ✅ Todo código de uma feature em um lugar
- ✅ Fácil adicionar/remover features completas
- ✅ Melhor para desenvolvimento incremental
- ✅ IA entende contexto de feature facilmente

---

## Consequências

### Positivas ✅

1. **Alta Cobertura de Testes**
   - Domain layer 100% testável (pure Dart)
   - Data layer testável com mocks
   - Presentation testável com BLoC

2. **Onboarding Rápido**
   - Estrutura previsível
   - Padrões claros e repetitivos
   - Documentação autoexplicativa

3. **IA Produtiva**
   - Copilot gera código seguindo padrões
   - Claude entende arquitetura facilmente
   - Refactoring assistido por IA é seguro

4. **Manutenção de Longo Prazo**
   - Código não envelhece mal
   - Fácil adicionar features sem quebrar existentes
   - Technical debt controlado

### Negativas ⚠️

1. **Boilerplate Inicial**
   - Muitos arquivos para features simples
   - Setup inicial mais lento
   - **Mitigação:** Templates e generators (build_runner)

2. **Curva de Aprendizado**
   - Desenvolvedores júnior podem se confundir
   - Exige disciplina para seguir padrões
   - **Mitigação:** Documentação detalhada (este ADR) e exemplos

3. **Over-Engineering para Features Simples**
   - Algumas features não precisam de 3 camadas
   - Pode parecer excessivo no início
   - **Mitigação:** Aceitar como investimento para escalabilidade

---

## Alternativas Consideradas

### 1. MVC Tradicional

**Prós:**
- Simples e conhecida
- Menos arquivos

**Contras:**
- ❌ Difícil de testar (Controllers acoplados)
- ❌ Lógica de negócio misturada com UI
- ❌ Não escala bem

**Decisão:** Rejeitada - não atende requisitos de testabilidade

### 2. MVVM sem Clean Architecture

**Prós:**
- Separação UI e lógica
- Testabilidade razoável

**Contras:**
- ❌ Ainda acopla lógica de negócio com dados
- ❌ Sem isolamento claro de camadas
- ❌ Dificulta substituição de implementações

**Decisão:** Rejeitada - Clean Architecture oferece mais benefícios

### 3. Modular Monolith (Packages Separados)

**Prós:**
- Isolamento total entre features
- Reutilização via packages

**Contras:**
- ❌ Complexidade de setup muito alta
- ❌ Overhead para projeto solo
- ❌ Dificuldade em compartilhar código

**Decisão:** Rejeitada - excessivo para escopo atual (pode ser futuro)

---

## Validação e Compliance

### Checklist de Implementação

Para cada feature nova, validar:

- [ ] Domain layer criada primeiro (entities, interfaces, usecases)
- [ ] Data layer implementa interfaces do domain
- [ ] Presentation layer depende apenas de domain
- [ ] Nenhuma importação de camada externa em domain
- [ ] Testes unitários para cada camada
- [ ] Um arquivo por classe/interface
- [ ] Convenções de nomenclatura seguidas

### Convenções de Nomenclatura

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Entity | `<Nome>Entity` | `AssignmentEntity` |
| Model | `<Nome>Model` | `AssignmentModel` |
| Repository Interface | `I<Nome>Repository` | `IAssignmentRepository` |
| Repository Impl | `<Nome>Repository` | `AssignmentRepository` |
| UseCase | `<Ação><Nome>UseCase` | `GetAssignmentsUseCase` |
| Datasource | `<Nome>Datasource` | `WaniKaniDatasource` |
| Cubit | `<Nome>Cubit` | `AssignmentCubit` |
| State | `<Nome>State` | `AssignmentState` |

---

## Referências

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Example - Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Feature-First vs Layer-First](https://codewithandrea.com/articles/flutter-project-structure/)

---

## Notas de Implementação

### Setup Inicial Recomendado

1. Criar feature skeleton com todas as pastas
2. Começar pelo domain (entities, interfaces)
3. Implementar data layer com testes
4. Por último, presentation com BLoC
5. Refatorar conforme necessário

### Exemplo de Feature Completa

Ver `lib/features/dashboard/` como referência de implementação seguindo este ADR.

---

**Última Revisão:** 11/10/2025  
**Próxima Revisão:** Após implementação de 3 features
