# Arquitetura - Melhorias Técnicas de Infraestrutura

**Feature**: technical-improvements  
**Data**: 20 de Outubro de 2025

---

## 📐 Visão Geral da Arquitetura

### Estado Atual (ANTES)

```
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart          # ❌ Monolítico (80+ linhas)
│   ├── error/
│   │   ├── ierror.dart
│   │   ├── api_error_entity.dart         # ⚠️ String hardcoded
│   │   └── internal_error_entity.dart
│   ├── network/
│   │   └── interceptors/
│   │       └── mock_interceptor.dart     # ✅ Já existe
│   └── mixins/
│       └── decode_model_mixin.dart       # ✅ Já existe, não usado
│
├── features/home/
│   ├── data/
│   │   └── repositories/
│   │       └── home_repository.dart      # ❌ Repetição statusCode == 200
│   │                                     # ❌ Sem DecodeModelMixin
│   │                                     # ❌ Strings hardcoded
│   ├── presentation/
│   │   ├── cubits/
│   │   │   └── home_cubit.dart           # ⚠️ String hardcoded
│   │   └── screens/
│   │       └── home_screen.dart          # ⚠️ String hardcoded
│   └── utils/
│       └── home_strings.dart             # ⚠️ Incompleto
│
├── routing/
│   └── app_router.dart                   # ❌ String literal '/'
│
├── main.dart                             # ✅ Importa service_locator
└── main_mock.dart                        # ✅ Importa service_locator
```

**Problemas Identificados**:
1. ❌ **Sem logging**: Debugging requer breakpoints
2. ❌ **Repetição de código**: `if (response.statusCode == 200)` em 4 métodos
3. ❌ **Strings hardcoded**: 8+ strings espalhadas pelo código
4. ❌ **DI monolítico**: Arquivo único que vai crescer indefinidamente
5. ❌ **Sem type safety**: Rotas como strings literais
6. ❌ **DecodeModelMixin não usado**: Existe mas não aplicado
7. ❌ **README genérico**: Boilerplate padrão do Flutter

---

### Estado Futuro (DEPOIS)

```
lib/
├── core/
│   ├── dependency_injection/             # ✅ NOVO: Estrutura modular
│   │   ├── dependency_injection.dart     # Orquestrador principal
│   │   ├── core_di.dart                  # Dio + Interceptors
│   │   └── features/
│   │       └── home_di.dart              # DI da feature Home
│   │       └── [reviews_di.dart]         # [FUTURO]
│   │       └── [lessons_di.dart]         # [FUTURO]
│   │
│   ├── error/
│   │   ├── ierror.dart
│   │   ├── api_error_entity.dart         # ✅ Usando CoreStrings
│   │   └── internal_error_entity.dart
│   │
│   ├── network/
│   │   ├── interceptors/
│   │   │   ├── mock_interceptor.dart     # ✅ Mantido
│   │   │   └── logging_interceptor.dart  # ✅ NOVO: Logs request/response
│   │   └── extensions/
│   │       └── response_extension.dart   # ✅ NOVO: isSuccessful getter
│   │
│   ├── mixins/
│   │   └── decode_model_mixin.dart       # ✅ Mantido, agora usado
│   │
│   └── utils/
│       └── core_strings.dart             # ✅ NOVO: Strings compartilhadas
│
├── features/home/
│   ├── data/
│   │   └── repositories/
│   │       └── home_repository.dart      # ✅ Com DecodeModelMixin
│   │                                     # ✅ Usando response.isSuccessful
│   │                                     # ✅ Usando HomeStrings
│   ├── presentation/
│   │   ├── cubits/
│   │   │   └── home_cubit.dart           # ✅ Usando HomeStrings
│   │   └── screens/
│   │       └── home_screen.dart          # ✅ Usando HomeStrings
│   └── utils/
│       └── home_strings.dart             # ✅ Completo com todas strings
│
├── routing/
│   ├── app_routes.dart                   # ✅ NOVO: Enum type-safe
│   └── app_router.dart                   # ✅ Usando AppRoutes enum
│
├── main.dart                             # ✅ Import atualizado
├── main_mock.dart                        # ✅ Import atualizado
└── README.md                             # ✅ Conteúdo profissional
```

**Melhorias Implementadas**:
1. ✅ **Logging completo**: Request/Response no console
2. ✅ **DRY**: Extension `isSuccessful` elimina repetição
3. ✅ **Strings centralizadas**: 2 camadas (Core + Feature)
4. ✅ **DI modular**: Separado por feature, preparado para escala
5. ✅ **Type safety**: Rotas via enum
6. ✅ **Error handling robusto**: DecodeModelMixin aplicado
7. ✅ **Documentação profissional**: README customizado

---

## 🏗️ Componentes Detalhados

### 1. LoggingInterceptor

**Localização**: `lib/core/network/interceptors/logging_interceptor.dart`

**Responsabilidades**:
- Interceptar todas as requisições Dio (antes de enviar)
- Interceptar todas as respostas Dio (após receber)
- Interceptar todos os erros Dio
- Formatar e exibir logs estruturados no console
- Indicar visualmente quando em modo MOCK

**Dependências**:
- `package:dio` - Classe `Interceptor`
- `package:logger` - Formatação e colorização de logs
- `package:flutter/foundation.dart` - `kDebugMode` para logs condicionais

**Padrões de Design**:
- **Interceptor Pattern**: Implementa `Interceptor` do Dio
- **Conditional Logging**: Logs apenas em debug mode
- **Pretty Printing**: JSON formatado com indentação

**Implementação**:

```dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Interceptor Dio para logging estruturado de requisições e respostas.
///
/// Exibe logs coloridos no console apenas em modo debug.
/// Indica visualmente quando está em modo MOCK.
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Não exibir stacktrace
      errorMethodCount: 5, // Stacktrace em erros
      lineLength: 80, // Largura das linhas
      colors: true, // Colorir logs
      printEmojis: true, // Usar emojis
      printTime: true, // Exibir timestamp
    ),
  );

  final bool _isMockMode;

  LoggingInterceptor({bool isMockMode = false}) : _isMockMode = isMockMode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final mockIndicator = _isMockMode ? '🔷 [MOCK] ' : '';
      
      _logger.i(
        '${mockIndicator}REQUEST\n'
        'Method: ${options.method}\n'
        'URL: ${options.uri}\n'
        'Headers: ${_prettyPrintJson(options.headers)}\n'
        '${options.data != null ? 'Body: ${_prettyPrintJson(options.data)}' : 'Body: (empty)'}',
      );
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final mockIndicator = _isMockMode ? '🔷 [MOCK] ' : '';
      
      _logger.d(
        '${mockIndicator}RESPONSE\n'
        'Status: ${response.statusCode}\n'
        'URL: ${response.requestOptions.uri}\n'
        'Body: ${_prettyPrintJson(response.data)}',
      );
    }
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.e(
        'ERROR\n'
        'URL: ${err.requestOptions.uri}\n'
        'Type: ${err.type}\n'
        'Message: ${err.message}\n'
        '${err.response?.data != null ? 'Response: ${_prettyPrintJson(err.response!.data)}' : ''}',
      );
    }
    
    super.onError(err, handler);
  }

  /// Formata JSON com indentação para legibilidade.
  String _prettyPrintJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        final encoder = JsonEncoder.withIndent('  ');
        return '\n${encoder.convert(data)}';
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
```

**Integração**:
- Adicionado ao Dio em `core_di.dart`
- Ordem: `LoggingInterceptor` → `MockInterceptor` (se mock)
- Passa flag `isMockMode` baseado no parâmetro `useMock`

---

### 2. ResponseExtension

**Localização**: `lib/core/network/extensions/response_extension.dart`

**Responsabilidades**:
- Estender `Response<dynamic>` do Dio
- Fornecer getter `isSuccessful` para validação de status HTTP

**Padrões de Design**:
- **Extension Methods**: Adiciona funcionalidade sem herança
- **Null Safety**: Validação segura de `statusCode`

**Implementação**:

```dart
import 'package:dio/dio.dart';

/// Extensão do [Response] do Dio para facilitar validação de sucesso.
extension ResponseExtension on Response<dynamic> {
  /// Verifica se a resposta foi bem-sucedida (status code 2xx).
  ///
  /// Retorna `true` se [statusCode] está entre 200 e 299 (inclusive).
  /// Retorna `false` se [statusCode] é null ou fora desse range.
  bool get isSuccessful =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
```

**Uso no HomeRepository**:

```dart
// ANTES
if (response.statusCode == 200) {
  // processar sucesso
}

// DEPOIS
if (response.isSuccessful) {
  // processar sucesso
}
```

**Benefícios**:
- ✅ Aceita qualquer 2xx (200, 201, 204, etc.)
- ✅ Código mais legível e expressivo
- ✅ Centralizado: mudanças futuras em um só lugar

---

### 3. Centralização de Strings (2 Camadas)

#### Camada Core: CoreStrings

**Localização**: `lib/core/utils/core_strings.dart`

**Responsabilidades**:
- Armazenar strings genéricas compartilhadas
- Mensagens de erro padrão
- Labels de ações comuns

**Implementação**:

```dart
/// Strings centralizadas da camada core.
///
/// Contém textos genéricos compartilhados entre features.
/// Preparado para internacionalização (i18n) futura.
class CoreStrings {
  // Mensagens de Erro Genéricas
  /// Mensagem de erro desconhecido/genérico.
  static const String errorUnknown = 'Erro desconhecido';

  /// Mensagem quando não há dados disponíveis.
  static const String errorNoData = 'Nenhum dado disponível';

  /// Mensagem quando falha comunicação com API.
  static const String errorApiFailure = 'Falha na comunicação com o servidor';

  /// Mensagem quando não há conexão com internet.
  static const String errorNoConnection = 'Sem conexão com a internet';

  // Labels de Ações Comuns
  /// Botão para tentar novamente após erro.
  static const String actionRetry = 'Tentar Novamente';

  /// Botão para confirmar ação.
  static const String actionConfirm = 'Confirmar';

  /// Botão para cancelar ação.
  static const String actionCancel = 'Cancelar';

  /// Botão para fechar.
  static const String actionClose = 'Fechar';

  // Estados
  /// Texto exibido durante carregamento.
  static const String stateLoading = 'Carregando...';

  /// Texto quando não há itens.
  static const String stateEmpty = 'Nenhum item encontrado';
}
```

#### Camada Feature: HomeStrings (Expandido)

**Localização**: `lib/features/home/utils/home_strings.dart`

**Strings a Adicionar**:

```dart
class HomeStrings {
  // [EXISTENTES - Mantidos]
  static const String appBarTitle = 'WaniKani';
  static const String levelLabel = 'Nível';
  static const String reviewsLabel = 'Reviews';
  static const String lessonsLabel = 'Lições';
  static const String errorTitle = 'Erro';
  static const String errorMessage = 'Não foi possível carregar os dados';
  static const String retryButton = 'Tentar Novamente';
  static const String loadingMessage = 'Carregando...';
  static const String unknownError = 'Erro desconhecido';

  // [NOVOS - A serem adicionados]
  
  /// Saudação na AppBar (japonês: "Bem-vindo de volta").
  static const String greetingWelcomeBack = 'おかえり';

  /// Mensagem de erro quando dashboard não carrega.
  static const String errorDashboardLoad = 
      'Não foi possível carregar os dados do dashboard';

  /// Mensagem quando nenhuma progressão de nível foi encontrada.
  static const String errorNoLevelProgression = 
      'Nenhuma progressão de nível encontrada';

  /// Tooltip do botão de configurações.
  static const String settingsTooltip = 'Configurações';
}
```

**Strings a Remover do Código**:
- `home_cubit.dart`: `'Não foi possível carregar os dados do dashboard'`
- `home_screen.dart`: `'おかえり'`
- `home_repository.dart`: `'Nenhuma progressão de nível encontrada'`
- `home_repository.dart`: `'Erro desconhecido'` (4 ocorrências)
- `api_error_entity.dart`: `'Erro desconhecido'`

---

### 4. README Atualizado

**Localização**: `README.md` (raiz)

**Conteúdo**:

```markdown
# WaniKani App

Um cliente alternativo para o [WaniKani](https://www.wanikani.com/), plataforma de aprendizado de japonês baseada em Spaced Repetition System (SRS).

## 🤖 Desenvolvido com IA

Este projeto é desenvolvido 100% com auxílio de Inteligência Artificial, utilizando:
- **GitHub Copilot** para sugestões de código
- **Claude** (Anthropic) para arquitetura e refatorações
- **Cursor/Windsurf** para desenvolvimento assistido

## 🎯 Objetivo

Criar um cliente mobile moderno e eficiente para acompanhamento de progresso no WaniKani, com foco em:
- ✅ **Offline-first**: Funciona sem internet usando cache local
- ✅ **Performance**: Interface fluida e responsiva
- ✅ **Design japonês**: Tipografia e cores culturalmente apropriadas
- ✅ **Clean Architecture**: Código manutenível e testável

## 📚 Documentação

Para informações técnicas completas, consulte:
- 📘 [Documentação Técnica](specs/technical/index.md) - Índice completo
- 🏛️ [Decisões Arquiteturais](specs/technical/adr/) - ADRs 001-005
- 🤖 [Guia de Desenvolvimento IA](specs/technical/CLAUDE.meta.md) - Padrões de código
- 🗺️ [Guia da Base de Código](specs/technical/CODEBASE_GUIDE.md) - Navegação
- 🎨 [Design System](specs/design/DESIGN_SYSTEM.md) - UI/UX Guidelines

## 🚀 Stack Tecnológica

- **Framework**: Flutter 3.x (Dart 3.8.0+)
- **Arquitetura**: Clean Architecture + BLoC (Cubit)
- **State Management**: flutter_bloc
- **Offline Cache**: Drift (SQLite type-safe)
- **Networking**: Dio + pop_network
- **Navegação**: go_router
- **Dependency Injection**: GetIt
- **Functional Programming**: Dartz (Either monad)

## 🛠️ Setup e Execução

### Pré-requisitos
- Flutter SDK 3.8.0+
- Dart SDK 3.8.0+

### Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Rodar em modo MOCK (sem API real)
flutter run -t lib/main_mock.dart

# Rodar em modo PRODUÇÃO (API real - requer token)
flutter run

# Executar testes
flutter test

# Gerar código (Drift, JSON)
dart run build_runner build --delete-conflicting-outputs

# Verificar qualidade do código
flutter analyze
```

## 📱 Funcionalidades Implementadas

- ✅ Dashboard com nível atual, reviews e lessons
- 🚧 Sistema de reviews (em desenvolvimento)
- 🚧 Sistema de lessons (em desenvolvimento)
- 🚧 Estatísticas detalhadas (planejado)
- 🚧 Modo offline completo (planejado)

## 📄 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

---

**Nota**: Este é um cliente não oficial. WaniKani é marca registrada da Tofugu LLC.
```

---

### 5. AppRoutes Enum

**Localização**: `lib/routing/app_routes.dart`

**Implementação**:

```dart
/// Rotas da aplicação.
///
/// Enum type-safe para centralizar todas as rotas e evitar strings mágicas.
/// Facilita refatoração e fornece autocomplete no IDE.
enum AppRoutes {
  /// Rota inicial - Home/Dashboard.
  home('/'),

  // [FUTURAS - Preparadas para expansão]
  // reviews('/reviews'),
  // lessons('/lessons'),
  // settings('/settings'),
  // levelDetails('/level/:id'),
  ;

  const AppRoutes(this.path);

  /// Caminho da rota usado pelo go_router.
  final String path;
}
```

**Uso no AppRouter**:

```dart
// ANTES
GoRoute(
  path: '/',
  name: 'home',
  ...
)

// DEPOIS
GoRoute(
  path: AppRoutes.home.path,
  name: AppRoutes.home.name,
  ...
)
```

**Benefícios**:
- ✅ Autocomplete no IDE
- ✅ Compile-time safety (erro se rota não existe)
- ✅ Refatoração fácil (rename refactoring funciona)
- ✅ Documentação inline com JSDoc

---

### 6. DI Modular

**Estrutura de Arquivos**:

```
lib/core/dependency_injection/
├── dependency_injection.dart      # Orquestrador (40 linhas)
├── core_di.dart                   # Dio + Interceptors (50 linhas)
└── features/
    └── home_di.dart               # Feature Home (60 linhas)
```

#### 6.1. core_di.dart

**Responsabilidades**:
- Registrar Dio com configuração correta
- Adicionar interceptors (Logging + Mock)
- Configurar BaseOptions (baseUrl, timeouts, headers)

**Implementação**:

```dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wanikani_app/core/network/interceptors/logging_interceptor.dart';
import 'package:wanikani_app/core/network/interceptors/mock_interceptor.dart';

/// Configuração de dependências da camada core (network, interceptors).
void setupCoreDependencies({
  required GetIt getIt,
  required bool useMock,
}) {
  // Configurar Dio
  if (useMock) {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: '', // Vazio em modo mock
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      )
        ..interceptors.add(LoggingInterceptor(isMockMode: true))
        ..interceptors.add(MockInterceptor()),
    );
  } else {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.wanikani.com/v2',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: <String, String>{
            // TODO: Mover para secure storage
            'Authorization': 'Bearer db3c122d-3a49-4975-8e39-b44eb0ab5ebc',
          },
        ),
      )..interceptors.add(LoggingInterceptor(isMockMode: false)),
    );
  }
}
```

#### 6.2. features/home_di.dart

**Responsabilidades**:
- Registrar datasources da feature Home
- Registrar repositories da feature Home
- Registrar use cases da feature Home
- Registrar cubits da feature Home

**Implementação**:

```dart
import 'package:get_it/get_it.dart';
import 'package:wanikani_app/features/home/data/datasources/wanikani_datasource.dart';
import 'package:wanikani_app/features/home/data/repositories/home_repository.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_lesson_stats_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_review_stats_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';

/// Configuração de dependências da feature Home.
void setupHomeDependencies({required GetIt getIt}) {
  // 1. Datasources
  getIt.registerLazySingleton<WaniKaniDataSource>(
    () => WaniKaniDataSource(dio: getIt()),
  );

  // 2. Repositories
  getIt.registerLazySingleton<IHomeRepository>(
    () => HomeRepository(datasource: getIt()),
  );

  // 3. Use Cases
  getIt.registerLazySingleton<GetCurrentLevelUseCase>(
    () => GetCurrentLevelUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetReviewStatsUseCase>(
    () => GetReviewStatsUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetLessonStatsUseCase>(
    () => GetLessonStatsUseCase(repository: getIt()),
  );

  // 4. Cubits
  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(
      getCurrentLevel: getIt(),
      getReviewStats: getIt(),
      getLessonStats: getIt(),
    ),
  );
}
```

#### 6.3. dependency_injection.dart (Orquestrador)

**Responsabilidades**:
- Expor função pública `setupDependencies()`
- Orquestrar chamadas para `setupCoreDependencies()` e features
- Manter função `resetDependencies()` para testes

**Implementação**:

```dart
import 'package:get_it/get_it.dart';
import 'package:wanikani_app/core/dependency_injection/core_di.dart';
import 'package:wanikani_app/core/dependency_injection/features/home_di.dart';

/// Instância global do GetIt para dependency injection.
final GetIt getIt = GetIt.instance;

/// Configuração de todas as dependências da aplicação.
///
/// Deve ser chamado em `main()` antes de `runApp()`.
///
/// Parâmetros:
/// - [useMock]: Se `true`, configura Dio com MockInterceptor.
///              Se `false`, configura Dio com API real.
void setupDependencies({required bool useMock}) {
  // 1. Core (Dio, Interceptors)
  setupCoreDependencies(getIt: getIt, useMock: useMock);

  // 2. Features
  setupHomeDependencies(getIt: getIt);

  // [FUTURO]
  // setupReviewsDependencies(getIt: getIt);
  // setupLessonsDependencies(getIt: getIt);
}

/// Limpa todas as dependências registradas.
///
/// Útil para testes e hot restart.
void resetDependencies() {
  getIt.reset();
}
```

**Vantagens da Modularização**:
- ✅ Arquivos menores (40-60 linhas cada)
- ✅ Responsabilidade única por arquivo
- ✅ Fácil adicionar novas features (só criar novo arquivo em `features/`)
- ✅ Navegação melhorada (jump to definition leva ao arquivo correto)
- ✅ Preparado para escala (10+ features no futuro)

---

### 7. DecodeModelMixin em HomeRepository

**Mudanças no HomeRepository**:

1. **Adicionar mixin**:
```dart
class HomeRepository with DecodeModelMixin implements IHomeRepository {
  // ...
}
```

2. **Wrappear parsing com tryDecode**:

**ANTES**:
```dart
Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
  try {
    final response = await _datasource.getAssignments();

    if (response.statusCode == 200) {
      final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      final assignments = data
          .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(assignments);
    }

    return Left(ApiErrorEntity(
      response.data?['error']?.toString() ?? 'Erro desconhecido',
      statusCode: response.statusCode,
    ));
  } on Exception catch (e) {
    return Left(InternalErrorEntity(e.toString()));
  }
}
```

**DEPOIS**:
```dart
Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
  try {
    final response = await _datasource.getAssignments();

    if (response.isSuccessful) {
      return tryDecode<Either<IError, List<AssignmentEntity>>>(
        () {
          final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
          final assignments = data
              .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return Right(assignments);
        },
        orElse: (_) => Left(InternalErrorEntity(HomeStrings.errorUnknown)),
      );
    }

    return Left(ApiErrorEntity(
      response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
      statusCode: response.statusCode,
    ));
  } on Exception catch (e) {
    return Left(InternalErrorEntity(e.toString()));
  }
}
```

**Escopo do tryDecode**:
- ✅ Wrappear apenas: cast de data + fromJson
- ❌ NÃO wrappear: validações de negócio (ex: `if (data.isEmpty)`)
- ✅ Benefício: Log automático de erros de parsing via FlutterError

**Aplicar em 4 métodos**:
1. `getCurrentLevelProgression()` - Parsing complexo com ordenação
2. `getAssignments()` - Map de lista
3. `getReviewStats()` - Parsing direto
4. `getLessonStats()` - Parsing direto

---

## 🔄 Fluxo de Dados

### Request Flow (COM Logging)

```
[UI Action]
    ↓
[Cubit.method()]
    ↓
[UseCase.call()]
    ↓
[Repository.method()]
    ↓
[DataSource.method()]
    ↓
[Dio Request] ──→ [LoggingInterceptor.onRequest()] ──→ CONSOLE LOG
    ↓                    ↓
    ↓              Log: Method, URL, Headers, Body
    ↓
[MockInterceptor (se mock)] ou [API Real]
    ↓
[Dio Response] ──→ [LoggingInterceptor.onResponse()] ──→ CONSOLE LOG
    ↓                    ↓
    ↓              Log: Status, URL, Body
    ↓
[Repository: tryDecode parsing]
    ↓
    ├─ Success ──→ Right(Entity)
    │
    └─ Error ──→ Left(ErrorEntity) + FlutterError.reportError
    ↓
[UseCase retorna Either]
    ↓
[Cubit.fold() + emit state]
    ↓
[UI rebuilds]
```

**Pontos de Observabilidade**:
1. 🔷 Request: URL, headers, body
2. 🔷 Response: Status, body
3. 🔷 Parsing Error: Stacktrace via FlutterError
4. 🔷 Mock Indicator: Prefixo visual quando `useMock: true`

---

## 📊 Diagrama de Dependências

```mermaid
graph TD
    A[main.dart / main_mock.dart] -->|setupDependencies| B[dependency_injection.dart]
    
    B -->|setupCoreDependencies| C[core_di.dart]
    B -->|setupHomeDependencies| D[home_di.dart]
    
    C -->|registra| E[Dio]
    C -->|registra| F[LoggingInterceptor]
    C -->|registra| G[MockInterceptor]
    
    D -->|registra| H[WaniKaniDataSource]
    D -->|registra| I[HomeRepository]
    D -->|registra| J[UseCases]
    D -->|registra| K[HomeCubit]
    
    E -->|usa| F
    E -->|usa se mock| G
    
    H -->|depende| E
    I -->|depende| H
    I -->|with| L[DecodeModelMixin]
    I -->|usa| M[ResponseExtension]
    I -->|usa| N[HomeStrings]
    I -->|usa| O[CoreStrings]
    
    J -->|depende| I
    K -->|depende| J
    
    P[AppRouter] -->|usa| Q[AppRoutes enum]
    
    style F fill:#90EE90
    style G fill:#87CEEB
    style L fill:#FFD700
    style M fill:#FFD700
    style N fill:#FFA500
    style O fill:#FFA500
    style Q fill:#FF69B4
```

---

## 🧪 Estratégia de Testes

### Testes Existentes (Manter Funcionando)

**Localização**: `test/features/home/`

**Arquivos**:
- `home_repository_test.dart` - Testa repository
- `home_cubit_test.dart` - Testa cubit states

**Impacto das Mudanças**:
- ✅ **Sem quebra**: `isSuccessful` ainda retorna true para 200
- ✅ **Sem quebra**: Strings movidas mas funcionalidade igual
- ✅ **Sem quebra**: DI modular tem mesma API pública
- ⚠️ **Possível ajuste**: Imports de `service_locator` → `dependency_injection`

**Ação**: Rodar `flutter test` após cada fase e corrigir imports se necessário.

---

### Novos Testes (Opcional - Não Obrigatório)

Se tempo permitir, criar testes para novos componentes:

#### LoggingInterceptor Test
```dart
test('deve logar request com indicador MOCK', () {
  final interceptor = LoggingInterceptor(isMockMode: true);
  // Verificar que log contém '[MOCK]'
});
```

#### ResponseExtension Test
```dart
test('isSuccessful retorna true para status 200-299', () {
  expect(Response(statusCode: 200).isSuccessful, true);
  expect(Response(statusCode: 201).isSuccessful, true);
  expect(Response(statusCode: 299).isSuccessful, true);
  expect(Response(statusCode: 404).isSuccessful, false);
});
```

---

## ⚙️ Configurações e Dependências Externas

### Nova Dependência: logger

**Adicionar ao `pubspec.yaml`**:

```yaml
dependencies:
  # [... existentes]
  logger: ^2.0.0  # ✅ NOVO: Logging estruturado
```

**Comandos após adicionar**:
```bash
flutter pub get
```

**Alternativas Consideradas**:
- ❌ `talker`: Mais pesado, features desnecessárias (monitoring, analytics)
- ❌ Implementação nativa: Reinventar a roda, sem colorização
- ✅ `logger`: Leve, focado, amplamente usado

---

## 🚧 Restrições e Trade-offs

### Restrições Técnicas

1. **Manter compatibilidade com Dart 3.8.0+**
   - Extension types funcionam ✅
   - Sealed classes funcionam ✅
   - Records funcionam ✅

2. **Não quebrar hot reload**
   - DI usa `registerLazySingleton` (mantido)
   - Cubits sobrevivem a hot restart

3. **Manter performance**
   - Logs apenas em `kDebugMode` (zero overhead em release)
   - Extension methods sem custo de runtime

### Trade-offs

#### LoggingInterceptor
**Pro**:
- ✅ Observabilidade total
- ✅ Debug facilitado

**Con**:
- ⚠️ Logs verbosos podem poluir console
- **Mitigação**: Usar filtros do logger, desabilitar em testes

#### DI Modular
**Pro**:
- ✅ Escalabilidade
- ✅ Organização

**Con**:
- ⚠️ Mais arquivos para navegar
- **Mitigação**: Estrutura clara, naming conventions

#### Strings Centralizadas
**Pro**:
- ✅ Preparado para i18n
- ✅ Manutenção facilitada

**Con**:
- ⚠️ Pode ficar grande (100+ strings no futuro)
- **Mitigação**: Separação em 2 camadas (Core + Feature)

---

## 📝 Checklist de Implementação

### Fase 1: Fundação
- [ ] Adicionar `logger: ^2.0.0` ao pubspec.yaml
- [ ] Rodar `flutter pub get`
- [ ] Criar `lib/core/network/extensions/response_extension.dart`
- [ ] Criar `lib/core/network/interceptors/logging_interceptor.dart`
- [ ] Criar `lib/routing/app_routes.dart`
- [ ] Criar `lib/core/utils/core_strings.dart`
- [ ] Atualizar `README.md`
- [ ] Testar: Compilar sem erros

### Fase 2: Reorganização DI
- [ ] Criar pasta `lib/core/dependency_injection/features/`
- [ ] Criar `lib/core/dependency_injection/core_di.dart`
- [ ] Criar `lib/core/dependency_injection/features/home_di.dart`
- [ ] Criar `lib/core/dependency_injection/dependency_injection.dart`
- [ ] Atualizar import em `main.dart`
- [ ] Atualizar import em `main_mock.dart`
- [ ] Atualizar import em `app_router.dart`
- [ ] Testar: App roda em mock e produção
- [ ] Deletar `lib/core/di/service_locator.dart`
- [ ] Deletar pasta `lib/core/di/` (se vazia)

### Fase 3: Refatoração
- [ ] Expandir `lib/features/home/utils/home_strings.dart`
- [ ] Adicionar `with DecodeModelMixin` em `HomeRepository`
- [ ] Substituir `statusCode == 200` por `isSuccessful` (4 métodos)
- [ ] Wrappear parsing com `tryDecode()` (4 métodos)
- [ ] Substituir strings hardcoded em `home_repository.dart`
- [ ] Substituir strings hardcoded em `home_cubit.dart`
- [ ] Substituir strings hardcoded em `home_screen.dart`
- [ ] Substituir strings hardcoded em `api_error_entity.dart`
- [ ] Atualizar `AppRouter` para usar `AppRoutes.home.path`
- [ ] Testar: `flutter test` (todos passam)
- [ ] Testar: Rodar app e verificar logs no console

---

## 📚 Referências e Recursos

### Documentação Oficial
- [Dio Interceptors](https://pub.dev/documentation/dio/latest/dio/Interceptor-class.html)
- [Logger Package](https://pub.dev/packages/logger)
- [Extension Methods](https://dart.dev/guides/language/extension-methods)
- [GetIt](https://pub.dev/packages/get_it)

### Padrões do Projeto
- [ADR-001: Clean Architecture](../../specs/technical/adr/001-clean-architecture.md)
- [ADR-002: BLoC State Management](../../specs/technical/adr/002-bloc-state-management.md)
- [CLAUDE.meta.md](../../specs/technical/CLAUDE.meta.md) - Padrões de código

### Contexto
- [Requisitos](../../specs/technical/features/technical-improvements.md)
- [Contexto da Sessão](./context.md)

---

## ✅ Critérios de Sucesso

### Funcionalidade
- ✅ App compila sem erros
- ✅ App roda em modo mock
- ✅ App roda em modo produção
- ✅ Logs aparecem no console formatados
- ✅ Indicador [MOCK] visível quando `useMock: true`
- ✅ Navegação funciona (home screen carrega)

### Qualidade
- ✅ Todos os testes existentes passam
- ✅ Nenhuma string hardcoded em UI/logic (verificar com grep)
- ✅ Imports corretos (sem erros de referência)
- ✅ Análise estática passa: `flutter analyze`

### Arquitetura
- ✅ DI modular com separação clara
- ✅ Extensions funcionando (isSuccessful)
- ✅ Mixin aplicado (DecodeModelMixin)
- ✅ Enums para rotas (type-safe)

---

**Documento criado em**: 20 de Outubro de 2025  
**Aprovação pendente**: Aguardando revisão do usuário
