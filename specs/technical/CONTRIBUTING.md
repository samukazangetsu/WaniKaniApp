# Guia de Contribuição - WaniKani App# Guia de Contribuição - WaniKani App



> **Última Atualização:** 02/11/2025  > **Última Atualização:** 02/11/2025  

> **Versão:** 1.0.0> **Versão:** 1.0.0



------



## 🎯 Bem-vindo!## 🎯 Bem-vindo!



Este guia descreve o workflow de desenvolvimento do WaniKani App, desde setup inicial até deploy. Siga estas diretrizes para manter a qualidade e consistência do código.Este guia descreve o workflow de desenvolvimento do WaniKani App, desde setup inicial até deploy. Siga estas diretrizes para manter a qualidade e consistência do código.



------



## 🚀 Setup Inicial## 🚀 Setup Inicial



### Pré-requisitos### Pré-requisitos



**Obrigatório:****Obrigatório:**

- **Flutter SDK:** Versão mais recente (stable channel)- **Flutter SDK:** Versão mais recente (stable channel)

- **Dart SDK:** ^3.8.0 (incluído no Flutter)- **Dart SDK:** ^3.8.0 (incluído no Flutter)

- **Git:** Para controle de versão- **Git:** Para controle de versão

- **VS Code** (recomendado) ou Android Studio- **VS Code** (recomendado) ou Android Studio



**Opcional mas Recomendado:****Opcional mas Recomendado:**

- **GitHub Copilot:** Para assistência de IA no desenvolvimento- **GitHub Copilot:** Para assistência de IA no desenvolvimento

- **Flutter/Dart Extensions** para VS Code- **Flutter/Dart Extensions** para VS Code



### Instalação do Flutter### Instalação do Flutter



Siga a documentação oficial para seu sistema operacional:Siga a documentação oficial para seu sistema operacional:



**Windows:****Windows:**

1. Baixar Flutter SDK: https://docs.flutter.dev/get-started/install/windows1. Baixar Flutter SDK: https://docs.flutter.dev/get-started/install/windows

2. Extrair para `C:\src\flutter`2. Extrair para `C:\src\flutter`

3. Adicionar ao PATH: `C:\src\flutter\bin`3. Adicionar ao PATH: `C:\src\flutter\bin`

4. Executar `flutter doctor` para verificar instalação4. Executar `flutter doctor` para verificar instalação



**Verificação:****Verificação:**

```bash```bash

flutter --versionflutter --version

# Flutter 3.x.x • channel stable# Flutter 3.x.x • channel stable

# Dart 3.8.0 ou superior# Dart 3.8.0 ou superior

``````



### Configuração do Ambiente Flutter### Configuração do Ambiente Flutter



```bash```bash

# Aceitar licenças Android# Aceitar licenças Android

flutter doctor --android-licensesflutter doctor --android-licenses



# Verificar todas as dependências# Verificar todas as dependências

flutter doctor -vflutter doctor -v



# Listar dispositivos disponíveis# Listar dispositivos disponíveis

flutter devicesflutter devices

``````



### Clone do Repositório### Clone do Repositório



```bash```bash

# Clone via HTTPS# Clone via HTTPS

git clone https://github.com/samukazangetsu/WaniKaniApp.git clone https://github.com/samukazangetsu/WaniKaniApp.git



# Ou via SSH (recomendado se configurado)# Ou via SSH (recomendado se configurado)

git clone git@github.com:samukazangetsu/WaniKaniApp.gitgit clone git@github.com:samukazangetsu/WaniKaniApp.git



# Entrar no diretório# Entrar no diretório

cd WaniKaniAppcd WaniKaniApp

``````



### Instalação de Dependências### Instalação de Dependências



```bash```bash

# Instalar todas as dependências do pubspec.yaml# Instalar todas as dependências do pubspec.yaml

flutter pub getflutter pub get



# Verificar se há warnings# Verificar se há warnings

flutter pub outdatedflutter pub outdated

``````



### Configuração do VS Code### Configuração do VS Code



Crie `.vscode/launch.json` (já incluído no repositório):Crie `.vscode/launch.json` (já incluído no repositório):



```json```json

{{

  "version": "0.2.0",  "version": "0.2.0",

  "configurations": [  "configurations": [

    {    {

      "name": "wanikani_app",      "name": "wanikani_app",

      "request": "launch",      "request": "launch",

      "type": "dart"      "type": "dart"

    },    },

    {    {

      "name": "wanikani_app (mock)",      "name": "wanikani_app (mock)",

      "request": "launch",      "request": "launch",

      "type": "dart",      "type": "dart",

      "flutterMode": "debug",      "flutterMode": "debug",

      "args": ["-t", "lib/main_mock.dart"]      "args": ["-t", "lib/main_mock.dart"]

    }    }

  ]  ]

}}

``````



### Primeiro Run### Primeiro Run



```bash```bash

# Modo MOCK (desenvolvimento sem API real)# Modo MOCK (desenvolvimento sem API real)

flutter run -t lib/main_mock.dartflutter run -t lib/main_mock.dart



# Ou via VS Code: F5 → Selecionar "wanikani_app (mock)"# Ou via VS Code: F5 → Selecionar "wanikani_app (mock)

```flutter run lib/main_mock.dart



**Esperado:**# Modo produção

- App compila sem errosflutter run lib/main.dart

- Abre no emulador/dispositivo```

- Tela de login aparece

- Pode navegar sem inserir API key (usa mocks)---



---## 📁 Estrutura do Projeto



## 🌿 Git Workflow```

wanikani_app/

### Estratégia de Branches├── lib/

│   ├── core/                   # Código compartilhado

**Atualmente (v1.0 - Pré-loja):**│   │   ├── database/          # Configuração Drift

```│   │   ├── error/             # Error entities

master (main)│   │   ├── mixins/            # Mixins reutilizáveis

  └─ feature/nome-da-feature│   │   └── theme/             # Design system

```│   │

│   ├── features/              # Features por domínio

**Futuro (Pós-primeira versão na loja):**│   │   └── <feature>/

```│   │       ├── data/          # Datasources, models, repos

master (production)│   │       ├── domain/        # Entities, interfaces, usecases

  └─ develop (staging)│   │       └── presentation/  # Cubits, screens, widgets

      └─ feature/nome-da-feature│   │

```│   ├── routing/               # Configuração go_router

│   ├── main.dart              # Entrypoint produção

### Convenção de Nomes de Branches│   └── main_mock.dart         # Entrypoint mock

│

**Features:**├── assets/

```bash│   └── mock/                  # JSON files para mocks

feature/login│

feature/dashboard├── test/                      # Testes unitários

feature/reviews-list├── specs/                     # Documentação técnica

```└── pubspec.yaml               # Dependências

```

**Bugfixes:**

```bash---

fix/cubit-hot-reload-error

fix/dio-exception-handling## 🏗️ Workflow de Desenvolvimento

```

### 1. Criar Nova Feature

**Refactoring:**

```bash**Ordem de Implementação:**

refactor/repository-error-handling

refactor/theme-structure```

```1. Domain (Entities) → 2. Domain (Interfaces) → 3. Domain (UseCases)

        ↓                        ↓                        ↓

**Documentation:**4. Data (Models) → 5. Data (Datasources) → 6. Data (Repositories)

```bash        ↓

docs/update-readme7. Presentation (States) → 8. Presentation (Cubit) → 9. Presentation (UI)

docs/add-troubleshooting```

```

**Exemplo: Feature "Dashboard"**

### Criando uma Nova Feature

```bash

```bash# 1. Criar estrutura de pastas

# Sempre partir da master atualizadamkdir -p lib/features/dashboard/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{cubits,screens,widgets}}

git checkout master

git pull origin master# 2. Implementar Domain primeiro (entities, interfaces, usecases)

# 3. Implementar Data (models, datasources, repositories)

# Criar nova branch# 4. Implementar Presentation (states, cubit, screens)

git checkout -b feature/nome-da-feature

# 5. Registrar dependências no GetIt

# Trabalhar na feature...# 6. Adicionar rotas no go_router

# 7. Escrever testes

# Commit frequente```

git add .

git commit -m "feat: descrição da feature"### 2. Adicionar Endpoint da API



# Push para remote```bash

git push origin feature/nome-da-feature# 1. Criar mock JSON em assets/mock/<endpoint>.json

```# 2. Implementar datasource method

# 3. Criar model com fromJson/toJson

### Commits Semânticos# 4. Implementar repository method com cache strategy

# 5. Criar use case

Siga o padrão [Conventional Commits](https://www.conventionalcommits.org/):# 6. Adicionar método no cubit

# 7. Testar tudo

```bash```

# Features

git commit -m "feat: adicionar tela de reviews"### 3. Build Runner (Code Generation)

git commit -m "feat(home): exibir próximo review disponível"

```bash

# Bugfixes# Quando adicionar/modificar:

git commit -m "fix: corrigir erro 401 em áreas logadas"# - Drift tables

git commit -m "fix(cubit): prevenir emit após close no hot reload"# - JSON serializable classes

# - Freezed classes (futuro)

# Refactoring

git commit -m "refactor: padronizar error handling em repositories"# Watch mode (recomendado durante desenvolvimento)

flutter pub run build_runner watch

# Documentação

git commit -m "docs: atualizar CONTRIBUTING.md"# Build única vez

flutter pub run build_runner build

# Testes

git commit -m "test: adicionar testes para LoginCubit"# Limpar e rebuild

flutter pub run build_runner build --delete-conflicting-outputs

# Chore (config, dependências)```

git commit -m "chore: atualizar dependência flutter_bloc"

git commit -m "chore: configurar GitHub Actions"---

```

## 🧪 Testes

### Pull Requests (Planejado)

### Estrutura de Testes

**Atualmente:** Desenvolvimento solo, sem PRs obrigatórias

```

**Futuro (com CI/CD):**test/

1. Criar PR da feature para develop/master├── features/

2. **GitHub Actions** executa automaticamente:│   └── <feature>/

   - ✅ `flutter format --dry-run`│       ├── data/

   - ✅ `flutter analyze`│       │   ├── datasources/

   - ✅ `flutter test`│       │   ├── models/

   - ✅ Code coverage check (> 80%)│       │   └── repositories/

3. **GitHub Copilot Pro** revisa código automaticamente│       ├── domain/

4. Desenvolvedor revisa output da IA│       │   └── usecases/

5. Merge após aprovação│       └── presentation/

│           └── cubits/

---└── core/

```

## 🧪 Testes

### Rodar Testes

### Estrutura de Testes

```bash

```# Todos os testes

test/flutter test

├── core/

│   ├── mixins/# Testes de uma feature específica

│   │   └── decode_model_mixin_test.dartflutter test test/features/dashboard/

│   └── network/

│       └── interceptors/# Teste específico

│           └── mock_interceptor_test.dartflutter test test/features/dashboard/domain/usecases/get_assignments_usecase_test.dart

│

└── features/# Com coverage

    └── <feature>/flutter test --coverage

        ├── data/

        │   ├── models/# Ver coverage HTML

        │   │   └── <model>_test.dartgenhtml coverage/lcov.info -o coverage/html

        │   └── repositories/open coverage/html/index.html  # macOS

        │       └── <repository>_test.dart```

        ├── domain/

        │   └── usecases/### Meta de Coverage

        │       └── <usecase>_test.dart

        └── presentation/- **Mínimo:** 80% em todas as camadas

            └── cubits/- **Ideal:** 90%+

                └── <cubit>_test.dart

```**O que testar:**



### Executando Testes- ✅ Use cases (100%)

- ✅ Repositories (100%)

```bash- ✅ Cubits (100%)

# Todos os testes- ✅ Models (fromJson/toJson)

flutter test- ❌ UI widgets (opcional - widget tests)



# Teste específico### Exemplo de Teste

flutter test test/features/login/presentation/cubits/login_cubit_test.dart

```dart

# Com coverage// test/features/dashboard/domain/usecases/get_assignments_usecase_test.dart

flutter test --coverageimport 'package:dartz/dartz.dart';

import 'package:flutter_test/flutter_test.dart';

# Ver coverage em HTML (Windows)import 'package:mocktail/mocktail.dart';

pip install lcov_cobertura

genhtml coverage/lcov.info -o coverage/htmlclass MockAssignmentRepository extends Mock implements IAssignmentRepository {}

start coverage/html/index.html

```void main() {

  late GetAssignmentsUseCase useCase;

### Padrão de Testes  late MockAssignmentRepository mockRepository;



**Mocktail (não Mockito):**  setUp(() {

```dart    mockRepository = MockAssignmentRepository();

import 'package:mocktail/mocktail.dart';    useCase = GetAssignmentsUseCase(repository: mockRepository);

import 'package:bloc_test/bloc_test.dart';  });



// Mock  group('GetAssignmentsUseCase', () {

class MockGetUserUseCase extends Mock implements GetUserUseCase {}    final tAssignments = [

      AssignmentEntity(id: 1, subjectId: 100, subjectType: 'kanji', srsStage: 5),

void main() {    ];

  late MockGetUserUseCase mockUseCase;

  late LoginCubit cubit;    test('should get assignments from repository', () async {

        // Arrange

  setUp(() {      when(() => mockRepository.getAssignments())

    mockUseCase = MockGetUserUseCase();          .thenAnswer((_) async => Right(tAssignments));

    cubit = LoginCubit(getUserUseCase: mockUseCase);

  });      // Act

        final result = await useCase();

  tearDown(() {

    cubit.close();      // Assert

  });      expect(result, equals(Right<IError, List<AssignmentEntity>>(tAssignments)));

        verify(() => mockRepository.getAssignments()).called(1);

  group('LoginCubit', () {    });

    blocTest<LoginCubit, LoginState>(  });

      'emits [Loading, Success] when login succeeds',}

      build: () {```

        when(() => mockUseCase(any()))

          .thenAnswer((_) async => Right(tUserEntity));---

        return cubit;

      },## 📐 Padrões de Código

      act: (cubit) => cubit.login('valid-api-key'),

      expect: () => [### Linting

        LoginLoading(),

        LoginSuccess(user: tUserEntity),**80+ regras ativas** - Ver `analysis_options.yaml`

      ],

    );**Principais regras:**

  });

}- Single quotes obrigatório (`'text'`)

```- Tipos explícitos sempre

- Package imports (não relative)

### Cobertura Mínima- Limite 80 caracteres por linha

- Prefer expression function bodies

**Target:** > 80% de code coverage- Always declare return types



**Obrigatório testar:**### Formatação

- ✅ Todos os UseCases

- ✅ Todos os Repositories```bash

- ✅ Todos os Cubits# Formatar todo o código

- ✅ Models (fromJson/toJson)dart format .



**Opcional (mas recomendado):**# Verificar formatação

- Widgets complexosdart format --set-exit-if-changed .

- Utilities e helpers

- Extensions# Analisar código

flutter analyze

---```



## 🔍 Quality Assurance### Convenções de Nomenclatura



### Linting| Tipo | Convenção | Exemplo |

|------|-----------|---------|

**Configuração:** `analysis_options.yaml` (80+ regras ativas)| Classes | PascalCase | `AssignmentEntity` |

| Arquivos | snake_case | `assignment_entity.dart` |

```bash| Variáveis | camelCase | `assignmentList` |

# Analisar todo o projeto| Constantes | camelCase + const | `const Duration cacheTTL` |

flutter analyze| Privados | underscore prefix | `_repository` |

| Interfaces | "I" prefix | `IAssignmentRepository` |

# Zero warnings/errors são permitidos

# Se houver, corrija antes de commit### Imports

```

```dart

**Regras Críticas:**// 1. Dart SDK

- `lines_longer_than_80_chars` — Máximo 80 caracteresimport 'dart:async';

- `prefer_single_quotes` — Usar aspas simples

- `always_declare_return_types` — Tipos explícitos// 2. Flutter

- `always_use_package_imports` — Nunca usar imports relativosimport 'package:flutter/material.dart';

- `prefer_final_locals` — Preferir final para variáveis locais

// 3. Packages

### Formataçãoimport 'package:dartz/dartz.dart';

import 'package:equatable/equatable.dart';

```bash

# Formatar todo o código// 4. Projeto (SEMPRE package imports)

flutter format .import 'package:wanikani_app/core/error/ierror.dart';

```

# Verificar sem modificar (para CI)

flutter format --dry-run --set-exit-if-changed .---



# Se retornar exit code != 0, há arquivos não formatados## 🔍 Code Review (Self-Review)

```

Antes de commitar, verificar:

### Pre-commit Checklist

- [ ] Código compila sem erros

Antes de cada commit, execute:- [ ] Lint passing (0 warnings)

- [ ] Testes passando (coverage > 80%)

```bash- [ ] Documentação atualizada

# 1. Formatar- [ ] Seguiu Clean Architecture

flutter format .- [ ] Nomes descritivos e claros

- [ ] Sem código comentado

# 2. Analisar- [ ] Imports organizados

flutter analyze

---

# 3. Testar

flutter test## 🌲 Git Workflow



# 4. Se tudo OK, commitar### Branch Strategy

git add .

git commit -m "feat: sua mensagem"```

```master (main)

  ├── feature/dashboard

**Futuro (com Git Hooks):**  ├── feature/statistics

- Pre-commit hook automático  ├── fix/cache-bug

- Roda format + analyze antes de permitir commit  └── refactor/repository-layer

```

---

**Convenção de branches:**

## 🏗️ Padrões de Código

- `feature/<nome>` - Novas features

### Estrutura de uma Nova Feature- `fix/<nome>` - Correções de bugs

- `refactor/<nome>` - Refactorings

```bash- `docs/<nome>` - Apenas documentação

# Exemplo: feature de "Reviews"

### Commit Messages

lib/features/reviews/

├── data/**Formato:**

│   ├── datasources/

│   │   └── review_datasource.dart        # Chamadas à API```

│   ├── models/<type>(<scope>): <subject>

│   │   └── review_model.dart             # JSON ↔ Entity

│   └── repositories/<body>

│       └── review_repository.dart        # Implementação

│<footer>

├── domain/```

│   ├── entities/

│   │   └── review_entity.dart            # Entidade pura**Tipos:**

│   ├── repositories/

│   │   └── i_review_repository.dart      # Interface- `feat`: Nova feature

│   └── usecases/- `fix`: Bug fix

│       ├── get_reviews_usecase.dart      # Um arquivo por operação- `refactor`: Refactoring

│       └── submit_review_usecase.dart- `test`: Adicionar/atualizar testes

│- `docs`: Documentação

└── presentation/- `style`: Formatação

    ├── cubits/- `chore`: Tarefas build/config

    │   ├── review_cubit.dart

    │   └── review_state.dart             # Sealed classes**Exemplos:**

    ├── screens/

    │   └── review_screen.dart```bash

    └── widgets/git commit -m "feat(dashboard): add assignments list view"

        ├── review_card.dartgit commit -m "fix(cache): resolve TTL expiration logic"

        └── review_button.dartgit commit -m "test(assignments): add usecase unit tests"

```git commit -m "docs(adr): update ADR-003 with cache strategy"

```

### Checklist de Nova Feature

---

**1. Domain Layer:**

- [ ] Criar entity em `domain/entities/`## 🐛 Debugging

- [ ] Criar interface do repository `I<Feature>Repository`

- [ ] Criar use cases (um arquivo por operação)### Flutter DevTools



**2. Data Layer:**```bash

- [ ] Criar model com extension type# Rodar app em debug mode

- [ ] Criar datasource para API callsflutter run

- [ ] Implementar repository (com padrão de error handling)

# Abrir DevTools

**3. Presentation Layer:**flutter pub global activate devtools

- [ ] Criar sealed statesflutter pub global run devtools

- [ ] Criar cubit com métodos públicos e privados```

- [ ] Criar screens e widgets

### Logs

**4. Dependency Injection:**

- [ ] Registrar no GetIt (`lib/core/dependency_injection/`)```dart

// Use debugPrint para logs de desenvolvimento

**5. Routing:**debugPrint('Assignment loaded: ${assignment.id}');

- [ ] Adicionar rota em `lib/routing/app_routes.dart`

// BlocObserver para logs de estados

**6. Testes:**class AppBlocObserver extends BlocObserver {

- [ ] Model test  @override

- [ ] Repository test  void onChange(BlocBase bloc, Change change) {

- [ ] UseCase test    super.onChange(bloc, change);

- [ ] Cubit test    debugPrint('${bloc.runtimeType} $change');

  }

---}

```

## 🔧 Comandos Úteis

### Breakpoints

### Desenvolvimento

VS Code: Clique na margem esquerda da linha

```bash

# Run em modo mock (sem API)---

flutter run -t lib/main_mock.dart

## 📦 Build e Deploy

# Run em modo produção (com API)

flutter run### Build Android



# Hot reload (durante desenvolvimento)```bash

# Pressione 'r' no terminal# Debug APK

flutter build apk --debug

# Hot restart (reinicia app mantendo conexão)

# Pressione 'R' no terminal# Release APK

flutter build apk --release

# Limpar build cache (se houver problemas)

flutter clean# App Bundle (Google Play)

flutter pub getflutter build appbundle --release

``````



### Code Generation### Build iOS



```bash```bash

# Gerar código uma vez (Drift, JSON)# Requer macOS + Xcode

dart run build_runner build --delete-conflicting-outputs

# Debug

# Watch mode (gera automaticamente ao salvar)flutter build ios --debug

dart run build_runner watch --delete-conflicting-outputs

# Release

# Limpar arquivos geradosflutter build ios --release

dart run build_runner clean```

```

---

### Build

## 🆘 Problemas Comuns

```bash

# Build APK de debug (Android)### 1. Drift não gera código

flutter build apk --debug

**Solução:**

# Build APK de release

flutter build apk --release```bash

flutter clean

# Build App Bundle (para Play Store)flutter pub get

flutter build appbundle --releaseflutter pub run build_runner build --delete-conflicting-outputs

```

# Build iOS (apenas em macOS)

flutter build ios --release### 2. Linting errors após pull

```

**Solução:**

### Diagnóstico

```bash

```bashdart format .

# Ver informações do dispositivoflutter analyze

flutter devices```



# Logs do dispositivo conectado### 3. Conflitos de merge

flutter logs

**Solução:**

# Analisar tamanho do app

flutter build apk --analyze-size```bash

git checkout master

# Performance overlay (durante desenvolvimento)git pull origin master

# Pressione 'p' no terminal após flutter rungit checkout sua-branch

```git rebase master

# Resolver conflitos

---git rebase --continue

```

## 🐛 Debug

---

### Modo Debug

## 📚 Recursos Úteis

```bash

# Run com DevTools### Documentação do Projeto

flutter run --observatory-port=9200

# Abrir DevTools em: http://localhost:9200- [Project Charter](project_charter.md) - Visão e escopo

- [ADRs](adr/) - Decisões arquiteturais

# Ou usar VS Code Debugger (F5)- [CLAUDE.meta.md](CLAUDE.meta.md) - Guia de desenvolvimento IA

```- [API_SPECIFICATION.md](API_SPECIFICATION.md) - Docs da API WaniKani



### Logs### Links Externos



```dart- [Flutter Docs](https://docs.flutter.dev/)

// Usar package logger (já configurado)- [Dart Docs](https://dart.dev/guides)

import 'package:logger/logger.dart';- [BLoC Library](https://bloclibrary.dev/)

- [Drift Docs](https://drift.simonbinder.eu/)

final logger = Logger();- [go_router](https://pub.dev/packages/go_router)

- [WaniKani API](https://docs.api.wanikani.com/)

logger.d('Debug message');

logger.i('Info message');---

logger.w('Warning message');

logger.e('Error message');## 💬 Contato

```

**Desenvolvedor:** Samuel (samukazangetsu)  

### Breakpoints (VS Code)**GitHub:** https://github.com/samukazangetsu



1. Clicar na margem esquerda do editor (círculo vermelho aparece)---

2. F5 para iniciar debug mode

3. App pausa no breakpoint**Última Revisão:** 11/10/2025

4. Inspecionar variáveis no painel de debug

---

## 📦 Gerenciamento de Dependências

### Adicionar Nova Dependência

```bash
# Dependência de produção
flutter pub add nome_do_package

# Dependência de desenvolvimento
flutter pub add --dev nome_do_package

# Atualizar pubspec.yaml
flutter pub get
```

### Atualizar Dependências

```bash
# Ver dependências desatualizadas
flutter pub outdated

# Atualizar respeitando constraints do pubspec.yaml
flutter pub upgrade

# Atualizar para latest (pode quebrar)
flutter pub upgrade --major-versions
```

### Dependências Críticas

**NÃO atualizar sem teste completo:**
- `flutter_bloc` (quebra API frequentemente)
- `drift` (migrações de DB necessárias)
- `dio` (pode quebrar interceptors)

**Sempre testar após atualização:**
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. Testar app manualmente

---

## 🚀 Deploy (Futuro)

### Android - Google Play Store

**Preparação:**
1. Configurar signing key
2. Atualizar versão em `pubspec.yaml`
3. Build release: `flutter build appbundle --release`
4. Testar bundle localmente
5. Upload para Play Console
6. Aguardar revisão do Google

### iOS - Apple App Store

**Preparação:**
1. Configurar certificados e provisioning profiles
2. Configurar em Xcode
3. Build release: `flutter build ios --release`
4. Archive via Xcode
5. Upload para TestFlight
6. Submeter para App Store Review

---

## 🤝 Code Review (Planejado)

### Processo de PR Review

**Manual (desenvolvedor):**
1. Ler todas as mudanças
2. Verificar padrões de código
3. Testar localmente se necessário
4. Aprovar ou solicitar mudanças

**Automático (GitHub Copilot Pro):**
1. Análise estática do código
2. Sugestões de melhorias
3. Detecção de anti-patterns
4. Comentários automáticos na PR

### Checklist de Review

**Código:**
- [ ] Segue Clean Architecture
- [ ] Error handling correto (Either + DioException)
- [ ] Testes unitários incluídos
- [ ] Sem warnings do linter
- [ ] Código formatado corretamente

**Performance:**
- [ ] Sem operações síncronas pesadas na UI thread
- [ ] Uso eficiente de widgets (const quando possível)
- [ ] Sem rebuilds desnecessários

**Segurança:**
- [ ] Sem API keys hardcoded
- [ ] Dados sensíveis armazenados com flutter_secure_storage
- [ ] Sem logs de informações sensíveis

---

## 📚 Recursos e Referências

### Documentação Interna

- [Guia de Navegação do Código](CODEBASE_GUIDE.md)
- [Guia de Desenvolvimento com IA](CLAUDE.meta.md)
- [Lógica de Negócio](BUSINESS_LOGIC.md)
- [Especificação da API](API_SPECIFICATION.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [ADRs](adr/)

### Documentação Externa

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [WaniKani API](https://docs.api.wanikani.com/)

### Comunidade

- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## 💡 Dicas para Novos Contribuidores

### Primeiros Passos

1. **Leia a documentação técnica completa**
2. **Rode o projeto em modo mock** para entender o fluxo
3. **Explore o código** seguindo o CODEBASE_GUIDE.md
4. **Faça pequenas mudanças** antes de grandes features
5. **Pergunte quando tiver dúvidas** (issues no GitHub)

### Boas Práticas

- ✅ Commits pequenos e frequentes
- ✅ Mensagens de commit descritivas
- ✅ Testes antes de push
- ✅ Ler código existente antes de criar novo
- ✅ Seguir padrões estabelecidos

### Anti-Patterns

- ❌ Commits gigantes com muitas mudanças
- ❌ Código sem testes
- ❌ Ignorar warnings do linter
- ❌ Criar novos padrões sem discutir
- ❌ Hardcoded values (usar constantes)

---

## 🎓 Aprendizado Contínuo

### Para Dominar o Projeto

**Semana 1:**
- Setup ambiente e primeiro run
- Ler toda documentação técnica
- Explorar código existente

**Semana 2:**
- Fazer bugfix simples
- Adicionar testes a código existente
- Melhorar documentação

**Semana 3:**
- Implementar feature pequena
- Refatorar código legado
- Contribuir com tooling

**Semana 4+:**
- Features complexas
- Decisões arquiteturais
- Mentoring de novos devs

---

## 📞 Suporte

**Problemas Técnicos:**
1. Consultar [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Verificar issues abertas no GitHub
3. Abrir nova issue se necessário

**Dúvidas sobre Arquitetura:**
1. Ler [ADRs](adr/) relevantes
2. Consultar [CLAUDE.meta.md](CLAUDE.meta.md)
3. Discutir em issue antes de grandes mudanças

**Dúvidas sobre WaniKani:**
1. Consultar [BUSINESS_LOGIC.md](BUSINESS_LOGIC.md)
2. Ler [API_SPECIFICATION.md](API_SPECIFICATION.md)
3. Verificar documentação oficial WaniKani

---

> **Lembre-se:** A documentação é viva! Se encontrar algo desatualizado ou confuso, abra uma PR para melhorar. 🚀
