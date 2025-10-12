# Guia de Contribuição e Desenvolvimento

> **Projeto:** WaniKani App  
> **Desenvolvedor:** Samuel (samukazangetsu)  
> **Última Atualização:** 11/10/2025

---

## 🚀 Setup do Ambiente

### Pré-requisitos

- **Flutter SDK:** 3.8.0 ou superior
- **Dart:** 3.0+ (incluído no Flutter)
- **Editor:** VS Code (recomendado) com extensões Flutter/Dart
- **Git:** Para controle de versão
- **Android Studio:** Para desenvolvimento Android (opcional)
- **Xcode:** Para desenvolvimento iOS (apenas macOS)

### Instalação

1. **Clone o repositório**

```bash
git clone https://github.com/samukazangetsu/WaniKaniApp.git
cd WaniKaniApp
```

2. **Instale dependências**

```bash
flutter pub get
```

3. **Gere código (Drift, JSON serialization)**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configure arquivo de ambiente (opcional para mock)**

```bash
# main_mock.dart já está configurado para usar mocks
# main.dart para ambiente de produção
```

5. **Rode o app**

```bash
# Modo desenvolvimento (com mocks)
flutter run lib/main_mock.dart

# Modo produção
flutter run lib/main.dart
```

---

## 📁 Estrutura do Projeto

```
wanikani_app/
├── lib/
│   ├── core/                   # Código compartilhado
│   │   ├── database/          # Configuração Drift
│   │   ├── error/             # Error entities
│   │   ├── mixins/            # Mixins reutilizáveis
│   │   └── theme/             # Design system
│   │
│   ├── features/              # Features por domínio
│   │   └── <feature>/
│   │       ├── data/          # Datasources, models, repos
│   │       ├── domain/        # Entities, interfaces, usecases
│   │       └── presentation/  # Cubits, screens, widgets
│   │
│   ├── routing/               # Configuração go_router
│   ├── main.dart              # Entrypoint produção
│   └── main_mock.dart         # Entrypoint mock
│
├── assets/
│   └── mock/                  # JSON files para mocks
│
├── test/                      # Testes unitários
├── specs/                     # Documentação técnica
└── pubspec.yaml               # Dependências
```

---

## 🏗️ Workflow de Desenvolvimento

### 1. Criar Nova Feature

**Ordem de Implementação:**

```
1. Domain (Entities) → 2. Domain (Interfaces) → 3. Domain (UseCases)
        ↓                        ↓                        ↓
4. Data (Models) → 5. Data (Datasources) → 6. Data (Repositories)
        ↓
7. Presentation (States) → 8. Presentation (Cubit) → 9. Presentation (UI)
```

**Exemplo: Feature "Dashboard"**

```bash
# 1. Criar estrutura de pastas
mkdir -p lib/features/dashboard/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{cubits,screens,widgets}}

# 2. Implementar Domain primeiro (entities, interfaces, usecases)
# 3. Implementar Data (models, datasources, repositories)
# 4. Implementar Presentation (states, cubit, screens)

# 5. Registrar dependências no GetIt
# 6. Adicionar rotas no go_router
# 7. Escrever testes
```

### 2. Adicionar Endpoint da API

```bash
# 1. Criar mock JSON em assets/mock/<endpoint>.json
# 2. Implementar datasource method
# 3. Criar model com fromJson/toJson
# 4. Implementar repository method com cache strategy
# 5. Criar use case
# 6. Adicionar método no cubit
# 7. Testar tudo
```

### 3. Build Runner (Code Generation)

```bash
# Quando adicionar/modificar:
# - Drift tables
# - JSON serializable classes
# - Freezed classes (futuro)

# Watch mode (recomendado durante desenvolvimento)
flutter pub run build_runner watch

# Build única vez
flutter pub run build_runner build

# Limpar e rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🧪 Testes

### Estrutura de Testes

```
test/
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   └── usecases/
│       └── presentation/
│           └── cubits/
└── core/
```

### Rodar Testes

```bash
# Todos os testes
flutter test

# Testes de uma feature específica
flutter test test/features/dashboard/

# Teste específico
flutter test test/features/dashboard/domain/usecases/get_assignments_usecase_test.dart

# Com coverage
flutter test --coverage

# Ver coverage HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

### Meta de Coverage

- **Mínimo:** 80% em todas as camadas
- **Ideal:** 90%+

**O que testar:**

- ✅ Use cases (100%)
- ✅ Repositories (100%)
- ✅ Cubits (100%)
- ✅ Models (fromJson/toJson)
- ❌ UI widgets (opcional - widget tests)

### Exemplo de Teste

```dart
// test/features/dashboard/domain/usecases/get_assignments_usecase_test.dart
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
      when(() => mockRepository.getAssignments())
          .thenAnswer((_) async => Right(tAssignments));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(Right<IError, List<AssignmentEntity>>(tAssignments)));
      verify(() => mockRepository.getAssignments()).called(1);
    });
  });
}
```

---

## 📐 Padrões de Código

### Linting

**80+ regras ativas** - Ver `analysis_options.yaml`

**Principais regras:**

- Single quotes obrigatório (`'text'`)
- Tipos explícitos sempre
- Package imports (não relative)
- Limite 80 caracteres por linha
- Prefer expression function bodies
- Always declare return types

### Formatação

```bash
# Formatar todo o código
dart format .

# Verificar formatação
dart format --set-exit-if-changed .

# Analisar código
flutter analyze
```

### Convenções de Nomenclatura

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Classes | PascalCase | `AssignmentEntity` |
| Arquivos | snake_case | `assignment_entity.dart` |
| Variáveis | camelCase | `assignmentList` |
| Constantes | camelCase + const | `const Duration cacheTTL` |
| Privados | underscore prefix | `_repository` |
| Interfaces | "I" prefix | `IAssignmentRepository` |

### Imports

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Packages
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// 4. Projeto (SEMPRE package imports)
import 'package:wanikani_app/core/error/ierror.dart';
```

---

## 🔍 Code Review (Self-Review)

Antes de commitar, verificar:

- [ ] Código compila sem erros
- [ ] Lint passing (0 warnings)
- [ ] Testes passando (coverage > 80%)
- [ ] Documentação atualizada
- [ ] Seguiu Clean Architecture
- [ ] Nomes descritivos e claros
- [ ] Sem código comentado
- [ ] Imports organizados

---

## 🌲 Git Workflow

### Branch Strategy

```
master (main)
  ├── feature/dashboard
  ├── feature/statistics
  ├── fix/cache-bug
  └── refactor/repository-layer
```

**Convenção de branches:**

- `feature/<nome>` - Novas features
- `fix/<nome>` - Correções de bugs
- `refactor/<nome>` - Refactorings
- `docs/<nome>` - Apenas documentação

### Commit Messages

**Formato:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Tipos:**

- `feat`: Nova feature
- `fix`: Bug fix
- `refactor`: Refactoring
- `test`: Adicionar/atualizar testes
- `docs`: Documentação
- `style`: Formatação
- `chore`: Tarefas build/config

**Exemplos:**

```bash
git commit -m "feat(dashboard): add assignments list view"
git commit -m "fix(cache): resolve TTL expiration logic"
git commit -m "test(assignments): add usecase unit tests"
git commit -m "docs(adr): update ADR-003 with cache strategy"
```

---

## 🐛 Debugging

### Flutter DevTools

```bash
# Rodar app em debug mode
flutter run

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Logs

```dart
// Use debugPrint para logs de desenvolvimento
debugPrint('Assignment loaded: ${assignment.id}');

// BlocObserver para logs de estados
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }
}
```

### Breakpoints

VS Code: Clique na margem esquerda da linha

---

## 📦 Build e Deploy

### Build Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

### Build iOS

```bash
# Requer macOS + Xcode

# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

---

## 🆘 Problemas Comuns

### 1. Drift não gera código

**Solução:**

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Linting errors após pull

**Solução:**

```bash
dart format .
flutter analyze
```

### 3. Conflitos de merge

**Solução:**

```bash
git checkout master
git pull origin master
git checkout sua-branch
git rebase master
# Resolver conflitos
git rebase --continue
```

---

## 📚 Recursos Úteis

### Documentação do Projeto

- [Project Charter](project_charter.md) - Visão e escopo
- [ADRs](adr/) - Decisões arquiteturais
- [CLAUDE.meta.md](CLAUDE.meta.md) - Guia de desenvolvimento IA
- [API_SPECIFICATION.md](API_SPECIFICATION.md) - Docs da API WaniKani

### Links Externos

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [BLoC Library](https://bloclibrary.dev/)
- [Drift Docs](https://drift.simonbinder.eu/)
- [go_router](https://pub.dev/packages/go_router)
- [WaniKani API](https://docs.api.wanikani.com/)

---

## 💬 Contato

**Desenvolvedor:** Samuel (samukazangetsu)  
**GitHub:** https://github.com/samukazangetsu

---

**Última Revisão:** 11/10/2025
