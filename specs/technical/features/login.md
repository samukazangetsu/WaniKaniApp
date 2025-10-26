# Sistema de Login com Token API WaniKani

## POR QUE

- Permitir que usuários autentiquem no aplicativo usando seu token API do WaniKani
- Armazenar de forma segura as credenciais do usuário para uso em requisições futuras
- Validar a autenticidade do token através da API do WaniKani antes de dar acesso
- Fornecer uma experiência guiada para usuários que ainda não possuem token
- Substituir o token hardcoded no código (segurança e flexibilidade)
- Preparar a base para features futuras que necessitam de dados do usuário autenticado

## O QUE

### Novas Telas

#### 1. Tela de Login (LoginScreen)
**Componentes:**
- Título destacado: "おかえり" (Okaeri - "Bem-vindo de volta")
  - Seguir padrão de títulos principais do design system
- Texto informativo: "Por favor, insira seu token de API do WaniKani"
- Input customizado para token de API:
  - Componente específico: `TokenTextField`
  - Máscara automática: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
  - Validação regex: `^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$`
  - Estado inicial: texto oculto (password field)
  - Ícone de olho para toggle mostrar/ocultar caracteres
- Link clicável: "Como consigo um token do WaniKani?"
  - Cor diferenciada indicando interatividade
  - Ao clicar: abre bottom sheet de tutorial
- Botão primário "Fazer login"
  - Habilitado apenas quando formato do token é válido (estado LoginValidating)
  - Ao clicar: dispara autenticação via API
- Rodapé: Versão do aplicativo
  - Formato: versão do `pubspec.yaml` usando `package_info_plus`

#### 2. Bottom Sheet de Tutorial (TutorialBottomSheet)
**Componentes:**
- Barrinha de arraste no topo (permite fechar arrastando para baixo)
- Título e conteúdo explicativo:
  - Texto: "Para conseguir um token de API do WaniKani, você deverá primeiro criar uma conta no site WaniKani, caso não tenha."
  - Passo a passo: "Após o login, entre no seu perfil pelo seu ícone de usuário, clique em API Tokens, caso não possua nenhum token ativo, gere um novo token com todas as permissões e copie o token"
- Botão primário: "Fazer login no WaniKani"
  - Abre URL externa: `https://www.wanikani.com` via `url_launcher`
- Botão secundário: "Voltar para a tela de login"
  - Fecha o modal e retorna para LoginScreen

#### 3. Tela de Loading (LoginLoadingScreen)
**Componentes:**
- Texto centralizado: "Estamos conectando você ao WaniKani"
- Barra de progresso animada com porcentagem
  - Progressão: 100% em 30 segundos (simulando timeout)
  - Taxa: 100/30 = ~3.33% por segundo
  - Ao receber sucesso da API: preenche completamente (100%)
  - Componente reutilizável para outras features futuras

#### 4. Tela de Erro (LoginErrorScreen - Full-screen)
**Componentes:**
- Mensagem de erro: "A consulta falhou. Aconselhamos verificar se o token de API está correto."
- Botão "Tentar novamente" na parte inferior
  - Ao clicar: fecha a tela e retorna para LoginScreen
  - Token digitado anteriormente é mantido no input

### Novas Entidades

#### UserEntity (domain/entities/user_entity.dart)
```dart
class UserEntity {
  final String username;
  final DateTime startedAt;
  final int level;
  final SubscriptionEntity subscription;
}
```

#### SubscriptionEntity (domain/entities/subscription_entity.dart)
```dart
class SubscriptionEntity {
  final bool active;
  final String type;
  final DateTime? periodEndsAt;
}
```

### Novos Models

#### UserModel (data/models/user_model.dart)
- Extension type sobre `UserEntity`
- Método `fromJson()` parseando estrutura da API WaniKani v2
- Estrutura: `response.data['data']` contém os campos do usuário

### Novos DataSources

#### WaniKaniAuthDataSource (data/datasources/wanikani_auth_datasource.dart)
- Método: `Future<Response<dynamic>> validateToken(String token)`
- Endpoint: `GET https://api.wanikani.com/v2/user`
- Header: `Authorization: Bearer {token}`
- Timeout: 30 segundos (configurado no Dio)

#### LocalDataManager (data/datasources/local_data_manager.dart)
- Wrapper sobre `flutter_secure_storage`
- Métodos:
  - `Future<void> saveToken(String token)` - salva token com criptografia
  - `Future<String?> getToken()` - recupera token salvo
  - `Future<void> deleteToken()` - remove token (logout futuro)
- Key para storage: `'wanikani_api_token'`

### Novos Repositories

#### IUserRepository (domain/repositories/iuser_repository.dart)
```dart
abstract class IUserRepository {
  Future<Either<IError, UserEntity>> getUser();
}
```

#### UserRepository (data/repositories/user_repository.dart)
- Implementa `IUserRepository`
- Usa `WaniKaniAuthDataSource`
- Método `getUser`:
  1. Chama API `/user` (usando token do header configurado no Dio)
  2. Se sucesso: parseia e retorna `UserEntity`
  3. Se erro: retorna `ApiErrorEntity`

### Novos UseCases

#### GetUserUseCase (domain/usecases/get_user_usecase.dart)
- Chama `repository.getUser()`
- Retorna `Either<IError, UserEntity>`
- **Responsabilidade única**: apenas buscar informações do usuário da API

### Novos Cubits e Estados

#### LoginCubit (presentation/cubits/login_cubit.dart)

**Estados:**
```dart
sealed class LoginState extends Equatable {
  const LoginState();
}

final class LoginInitial extends LoginState {}

final class LoginValidating extends LoginState {
  final bool isValid;
  const LoginValidating({required this.isValid});
}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess({required this.user});
}

final class LoginError extends LoginState {
  final String message;
  const LoginError({required this.message});
}
```

**Dependências:**
- `GetUserUseCase` - para buscar dados do usuário
- `LocalDataManager` - para salvar o token localmente

**Métodos:**
- `void validateTokenFormat(String token)` - valida regex e emite `LoginValidating`
- `Future<void> login(String token)` - orquestra o login:
  1. Salva token via `LocalDataManager.saveToken(token)`
  2. Chama `GetUserUseCase()` para validar e buscar dados
  3. Emite Loading → Success/Error

### Modificações em Arquivos Existentes

#### core/dependency_injection/core_di.dart
- Adicionar `AuthInterceptor` aos interceptors do Dio
- O `AuthInterceptor` consulta `LocalDataManager` e injeta o header `Authorization` dinamicamente
- Remover token hardcoded do `BaseOptions.headers`
- Se não houver token salvo, requisições seguem sem o header (será tratado pela API com 401)

#### routing/app_router.dart (ou equivalente)
- Adicionar rota `/login` para `LoginScreen`
- Adicionar lógica de rota inicial:
  - Se token existe no storage → navegar para `/home`
  - Se não existe token → navegar para `/login`

### Novas Dependências

Adicionar ao `pubspec.yaml`:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  url_launcher: ^6.2.0
  package_info_plus: ^5.0.0
```

### Estrutura de Arquivos da Feature

```
lib/
├── core/ (compartilhado)
│   ├── storage/
│   │   └── local_data_manager.dart ← NOVO (compartilhado entre features)
│   └── network/
│       └── interceptors/
│           └── auth_interceptor.dart ← NOVO (compartilhado)
│
└── features/
    └── login/
        ├── data/
        │   ├── datasources/
        │   │   └── wanikani_auth_datasource.dart
        │   ├── models/
        │   │   ├── subscription_model.dart
        │   │   └── user_model.dart
        │   └── repositories/
        │       └── user_repository.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── subscription_entity.dart
        │   │   └── user_entity.dart
        │   ├── repositories/
        │   │   └── iuser_repository.dart
        │   └── usecases/
        │       └── get_user_usecase.dart
        └── presentation/
            ├── cubits/
            │   ├── login_cubit.dart
            │   └── login_state.dart
            ├── screens/
            │   ├── login_error_screen.dart
            │   ├── login_loading_screen.dart
            │   └── login_screen.dart
            └── widgets/
                ├── token_text_field.dart
                └── tutorial_bottom_sheet.dart
```

### Componentes Compartilhados (Core)

#### LocalDataManager (core/storage/local_data_manager.dart)
- Wrapper sobre `flutter_secure_storage`
- **Compartilhado entre todas as features** (não é específico do login)
- Métodos:
  - `Future<void> saveToken(String token)` - salva token com criptografia
  - `Future<String?> getToken()` - recupera token salvo
  - `Future<void> deleteToken()` - remove token (logout futuro)
- Key para storage: `'wanikani_api_token'`

#### AuthInterceptor (core/network/interceptors/auth_interceptor.dart)
- Interceptor do Dio que injeta token dinamicamente em todas as requisições
- Consulta `LocalDataManager.getToken()` antes de cada request
- Se token existe: adiciona header `Authorization: Bearer {token}`
- Se não existe: request segue sem o header
- Redireciona para `/login` em caso de 401 (Unauthorized)

### Dependency Injection (GetIt)

#### Core DI (lib/core/dependency_injection/core_di.dart)
```dart
void setupCoreDependencies({required GetIt getIt, required bool useMock}) {
  // LocalDataManager (compartilhado - registrado no core)
  getIt.registerLazySingleton(() => LocalDataManager());
  
  // Configurar Dio
  if (useMock) {
    getIt.registerLazySingleton<Dio>(
      () => Dio(...)
        ..interceptors.add(MockInterceptor())
        ..interceptors.add(LoggingInterceptor(isMockMode: true)),
    );
  } else {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.wanikani.com/v2',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      )
        ..interceptors.add(AuthInterceptor(getIt())) // Injeta token automaticamente
        ..interceptors.add(LoggingInterceptor(isMockMode: false)),
    );
  }
}
```

#### Login DI (lib/features/login/login_di.dart)
```dart
void setupLoginDependencies(GetIt getIt) {
  // DataSources
  getIt.registerLazySingleton(() => WaniKaniAuthDataSource(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepository(datasource: getIt()),
  );
  
  // UseCases
  getIt.registerLazySingleton(() => GetUserUseCase(repository: getIt()));
  
  // Cubits (factory para novas instâncias)
  getIt.registerFactory(() => LoginCubit(
    getUserUseCase: getIt(),
    localDataManager: getIt(), // Obtém do core (já registrado)
  ));
}
```

## COMO

### Fluxo de Autenticação

1. **Inicialização do App:**
   - App verifica se existe token no `LocalDataManager`
   - Token existe → navega para `/home` (injeção de dependências da home)
   - Token não existe → navega para `/login` (injeção de dependências do login)

2. **Tela de Login:**
   - Usuário digita token no `TokenTextField`
   - A cada mudança: `LoginCubit.validateTokenFormat(token)` é chamado
   - Se formato inválido: botão "Fazer login" desabilitado
   - Se formato válido: botão "Fazer login" habilitado (estado `LoginValidating(isValid: true)`)

3. **Clique em "Como consigo um token?":**
   - Abre `TutorialBottomSheet` como modal
   - Bottom sheet tem drag handle para fechar
   - Botão "Fazer login no WaniKani" abre browser externo
   - Botão "Voltar" fecha o modal

4. **Clique em "Fazer login":**
   - `LoginCubit.login(token)` é chamado
   - Estado: `LoginLoading` → mostra `LoginLoadingScreen`
   - Barra de progresso inicia animação (0% → 100% em 30s)
   - Cubit executa:
     1. Salva token: `await localDataManager.saveToken(token)`
     2. Chama `GetUserUseCase()` que:
        - Faz request para `/user` (Dio já usa token via `AuthInterceptor`)
        - Se sucesso (200): parseia `UserModel`, retorna `Right(UserEntity)`
        - Se erro (401/404/500): retorna `Left(ApiErrorEntity)`

5. **Sucesso da API:**
   - Barra de progresso completa instantaneamente (100%)
   - Estado: `LoginSuccess(user)`
   - Navegação: `/home` (carrega injeção de dependências da home)
   - Token agora é usado automaticamente no header de todas as requisições

6. **Erro da API:**
   - Estado: `LoginError(message)`
   - Mostra `LoginErrorScreen` (full-screen)
   - Usuário clica "Tentar novamente"
   - Volta para `LoginScreen` mantendo token no input
   - Cubit volta para estado `LoginValidating`

### Validação de Formato do Token

**Regex:** `^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$`

**Exemplo válido:** `a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6`

**Implementação no Cubit:**
```dart
final _tokenRegex = RegExp(r'^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$');

void validateTokenFormat(String token) {
  final isValid = _tokenRegex.hasMatch(token);
  emit(LoginValidating(isValid: isValid));
}
```

### Componente TokenTextField

**Características:**
- Extends `StatefulWidget` ou usar `TextFormField` customizado
- Controller: `TextEditingController` com máscara automática
- Máscara: adicionar traços nas posições 8, 13, 18, 23
- Pacote sugerido: `mask_text_input_formatter` ou implementação manual
- Obscure text: `bool _obscureText = true` (inicialmente oculto)
- Suffix icon: `IconButton` com ícone de olho (toggle `_obscureText`)
- Validação: chama `context.read<LoginCubit>().validateTokenFormat()` no `onChanged`

### Barra de Progresso Animada

**Implementação:**
- Use `AnimationController` com duração de 30 segundos
- `LinearProgressIndicator` com `value` atrelado à animação
- `Text` mostrando porcentagem: `'${(animation.value * 100).toStringAsFixed(0)}%'`
- Ao receber `LoginSuccess`: `controller.animateTo(1.0, duration: Duration(milliseconds: 300))`
- Ao receber `LoginError`: parar animação

### Armazenamento Seguro do Token

**LocalDataManager usando flutter_secure_storage:**
```dart
class LocalDataManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  static const _tokenKey = 'wanikani_api_token';
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

### Parsing do Response da API

**Estrutura do JSON (mock em `assets/mock/user.json`):**
```json
{
  "object": "user",
  "data": {
    "username": "example_user",
    "level": 5,
    "started_at": "2012-05-11T00:52:18.958466Z",
    "subscription": {
      "active": true,
      "type": "recurring",
      "period_ends_at": "2018-12-11T13:32:19.485748Z"
    }
  }
}
```

**UserModel.fromJson:**
```dart
extension type UserModel(UserEntity entity) implements UserEntity {
  UserModel.fromJson(Map<String, dynamic> json)
      : entity = UserEntity(
          username: json['data']['username'],
          level: json['data']['level'],
          startedAt: DateTime.parse(json['data']['started_at']),
          subscription: SubscriptionModel.fromJson(json['data']['subscription']),
        );
}
```

### AuthInterceptor - Injeção Automática do Token

**Implementação em `core/network/interceptors/auth_interceptor.dart`:**

```dart
class AuthInterceptor extends Interceptor {
  final LocalDataManager _localDataManager;
  
  AuthInterceptor(this._localDataManager);
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _localDataManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

**Integração em `core_di.dart`:**
- Registrar `LocalDataManager` no core (não apenas no login)
- Adicionar `AuthInterceptor` aos interceptors do Dio (antes do `LoggingInterceptor`)
- Remover header `Authorization` hardcoded do `BaseOptions`

```dart
void setupCoreDependencies({required GetIt getIt, required bool useMock}) {
  // Registrar LocalDataManager (usado por AuthInterceptor)
  getIt.registerLazySingleton(() => LocalDataManager());
  
  if (useMock) {
    getIt.registerLazySingleton<Dio>(
      () => Dio(...)
        ..interceptors.add(MockInterceptor())
        ..interceptors.add(LoggingInterceptor(isMockMode: true)),
    );
  } else {
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.wanikani.com/v2',
          // Remover header Authorization daqui
        ),
      )
        ..interceptors.add(AuthInterceptor(getIt())) // NOVO
        ..interceptors.add(LoggingInterceptor(isMockMode: false)),
    );
  }
}
```

### Mock para Desenvolvimento

**Criar `assets/mock/user.json`** (já existe) para uso com `MockInterceptor`

**MockInterceptor deve reconhecer rota `/user`:**
```dart
if (options.path.contains('/user')) {
  return _mockResponse('user', options);
}
```

### Testes Necessários

#### Unit Tests:
- `login_cubit_test.dart` - testar todos os estados, transições e salvamento do token
- `user_repository_test.dart` - testar busca de dados do usuário
- `get_user_usecase_test.dart` - testar chamada ao repository
- `user_model_test.dart` - testar parsing do JSON
- `local_data_manager_test.dart` - testar operações de storage (com mock)
- `auth_interceptor_test.dart` - testar injeção do header

#### Widget Tests:
- `login_screen_test.dart` - testar interações da UI
- `token_text_field_test.dart` - testar máscara e validação
- `tutorial_bottom_sheet_test.dart` - testar navegação

### Considerações Futuras

**Features relacionadas para implementação posterior:**
- Logout: limpar token do storage e navegar para `/login`
- Verificação de token expirado: após N falhas de API consecutivas, perguntar ao usuário se token ainda é válido
- Salvamento de dados do usuário: cache local com Drift (já preparado com `UserEntity`)
- Refresh automático dos dados do usuário
- Onboarding para novos usuários (primeira vez abrindo o app)

### Anti-Patterns a Evitar

❌ **Não** salvar o token em `SharedPreferences` sem criptografia
❌ **Não** validar apenas no frontend (sempre validar com API)
❌ **Não** bloquear UI durante timeout (usar barra de progresso)
❌ **Não** expor token em logs (cuidado com `LoggingInterceptor`)
❌ **Não** hardcoded strings - usar arquivos de strings/i18n
❌ **Não** acoplar lógica de negócio na UI - manter no Cubit/UseCase
❌ **Não** esquecer de limpar recursos (`dispose` de controllers de animação)

### Checklist de Implementação

- [ ] Adicionar dependências ao `pubspec.yaml`
- [ ] Criar estrutura de pastas da feature `login`
- [ ] Implementar entities e models
- [ ] Implementar `LocalDataManager` em `core/` (compartilhado)
- [ ] Implementar `AuthInterceptor` em `core/network/interceptors/`
- [ ] Atualizar `core_di.dart` para registrar `LocalDataManager` e `AuthInterceptor`
- [ ] Implementar `WaniKaniAuthDataSource` em `features/login/data/`
- [ ] Implementar `IUserRepository` e `UserRepository`
- [ ] Implementar `GetUserUseCase`
- [ ] Implementar estados e cubit (com dependências `GetUserUseCase` e `LocalDataManager`)
- [ ] Criar componente `TokenTextField` com máscara
- [ ] Criar `LoginScreen`
- [ ] Criar `TutorialBottomSheet`
- [ ] Criar `LoginLoadingScreen` com barra de progresso
- [ ] Criar `LoginErrorScreen`
- [ ] Configurar injeção de dependências (`login_di.dart`)
- [ ] Atualizar rotas no `app_router.dart`
- [ ] Implementar lógica de rota inicial (token check)
- [ ] Adicionar mock de `/user` ao `MockInterceptor`
- [ ] Escrever testes unitários (mínimo 80% coverage)
- [ ] Escrever testes de widget
- [ ] Testar fluxo completo em modo mock
- [ ] Testar fluxo completo com API real
- [ ] Validar acessibilidade e UX
- [ ] Code review e refatoração
