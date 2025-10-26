# Contexto: Feature de Login com Token API WaniKani

> **Data:** 26 de Outubro de 2025  
> **Branch:** feature/login  
> **Status:** Análise Inicial Completa

---

## 🎯 POR QUE (Contexto e Motivação)

### Problema Atual
- Token API está **hardcoded** no arquivo `lib/api_token.dart` (segurança)
- Aplicativo só funciona para um único usuário (desenvolvedor)
- Não há autenticação ou validação de token
- Impossível distribuir o app para múltiplos usuários

### Objetivos da Feature
1. **Segurança:** Remover token hardcoded e armazenar de forma criptografada
2. **Flexibilidade:** Permitir que diferentes usuários usem suas próprias contas WaniKani
3. **Validação:** Garantir que apenas tokens válidos permitam acesso ao app
4. **Experiência:** Fornecer fluxo guiado para usuários sem token
5. **Fundação:** Preparar base para features futuras (logout, refresh, multi-conta)

---

## 🎯 O QUE (Resultado Esperado)

### Entregáveis Principais

#### 1. Sistema de Autenticação Completo
- ✅ Validação de formato do token (regex)
- ✅ Validação de autenticidade do token (chamada à API `/user`)
- ✅ Armazenamento seguro com `flutter_secure_storage`
- ✅ Injeção automática do token em todas as requisições (via interceptor)

#### 2. Quatro Telas Implementadas

**A. LoginScreen (Tela Principal)**
- Título japonês: "おかえり" (Okaeri - Bem-vindo de volta)
- Input customizado com máscara: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
- Validação em tempo real (habilita/desabilita botão)
- Link para tutorial
- Botão "Fazer login" (só habilitado se formato válido)
- Rodapé com versão do app (via `package_info_plus`)

**B. TutorialBottomSheet (Modal)**
- Barrinha de arraste (drag handle)
- Instruções para conseguir token
- Botão para abrir WaniKani no browser (`url_launcher`)
- Botão para voltar

**C. LoginLoadingScreen**
- Mensagem: "Estamos conectando você ao WaniKani"
- Barra de progresso animada (0-100% em 30 segundos)
- Completa imediatamente ao receber resposta da API

**D. LoginErrorScreen**
- Mensagem de erro com sugestão de verificar token
- Botão "Tentar novamente" (mantém token digitado)

#### 3. Infraestrutura Compartilhada

**LocalDataManager** (`lib/core/storage/`)
- Salvar token: `saveToken(String token)`
- Recuperar token: `getToken()` → `String?`
- Deletar token: `deleteToken()` (logout futuro)
- Usa `flutter_secure_storage` com criptografia

**AuthInterceptor** (`lib/core/network/interceptors/`)
- Injeta header `Authorization: Bearer {token}` automaticamente
- Consulta `LocalDataManager` antes de cada request
- Redireciona para `/login` em caso de 401 (token inválido/expirado)

#### 4. Feature Login (Clean Architecture)

**Domain Layer:**
- `UserEntity` - dados do usuário (username, level, started_at, subscription)
- `SubscriptionEntity` - dados de assinatura
- `IUserRepository` - interface do repository
- `GetUserUseCase` - busca dados do usuário da API

**Data Layer:**
- `UserModel` / `SubscriptionModel` - serialização JSON
- `UserRepository` - implementação da interface
- `WaniKaniAuthDataSource` - chamada ao endpoint `/user`

**Presentation Layer:**
- `LoginCubit` com 5 estados (Initial, Validating, Loading, Success, Error)
- 4 screens + 2 widgets (TokenTextField, TutorialBottomSheet)

#### 5. Navegação Inteligente

**Lógica de Rota Inicial:**
```
App inicia → Verifica token no storage
  ├─ Token existe → Navega para /home
  └─ Token NÃO existe → Navega para /login
```

**Fluxo de Login:**
```
/login → Usuário digita token → Clica "Fazer login"
  ├─ Formato inválido → Botão desabilitado
  └─ Formato válido → Chama API
      ├─ Sucesso → Salva token → /home
      └─ Erro → LoginErrorScreen → Tentar novamente
```

---

## 🛠️ COMO (Abordagem Técnica)

### Arquitetura e Padrões

#### Clean Architecture por Feature
```
lib/
├── core/ (compartilhado entre features)
│   ├── storage/
│   │   └── local_data_manager.dart ← NOVO (armazenamento seguro de token)
│   ├── network/
│   │   └── interceptors/
│   │       └── auth_interceptor.dart ← NOVO (injeção automática de token)
│   ├── dependency_injection/
│   │   └── core_di.dart ← MODIFICAR (registrar LocalDataManager e AuthInterceptor)
│   ├── theme/
│   └── widgets/
│
├── features/
│   └── login/ ← NOVA FEATURE
│       ├── data/
│       │   ├── datasources/
│       │   │   └── wanikani_auth_datasource.dart
│       │   ├── models/
│       │   │   ├── user_model.dart
│       │   │   └── subscription_model.dart
│       │   └── repositories/
│       │       └── user_repository.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── user_entity.dart
│       │   │   └── subscription_entity.dart
│       │   ├── repositories/
│       │   │   └── iuser_repository.dart
│       │   └── usecases/
│       │       └── get_user_usecase.dart
│       ├── presentation/
│       │   ├── cubits/
│       │   │   ├── login_cubit.dart
│       │   │   └── login_state.dart
│       │   ├── screens/
│       │   │   ├── login_screen.dart
│       │   │   ├── login_loading_screen.dart
│       │   │   └── login_error_screen.dart
│       │   └── widgets/
│       │       ├── token_text_field.dart
│       │       └── tutorial_bottom_sheet.dart
│       └── login_di.dart ← NOVO (injeção de dependências da feature)
│
└── routing/
    ├── app_routes.dart ← MODIFICAR (adicionar /login)
    └── app_router.dart ← MODIFICAR (lógica de rota inicial)
```

### Fluxo de Dados

#### 1. Validação de Formato (Local)
```
TokenTextField.onChanged()
  → LoginCubit.validateTokenFormat(token)
  → Regex: ^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$
  → emit(LoginValidating(isValid: true/false))
  → UI: Botão habilitado/desabilitado
```

#### 2. Login (Salvar + Validar na API)
```
LoginScreen → Clique em "Fazer login"
  → LoginCubit.login(token)
  → emit(LoginLoading) → Mostra LoginLoadingScreen
  → 1. localDataManager.saveToken(token) ✅ Salva localmente
  → 2. GetUserUseCase.call()
      → UserRepository.getUser()
      → WaniKaniAuthDataSource.getUser()
      → GET /user (Dio com AuthInterceptor injeta token automaticamente)
      → Response 200 ✅
          → UserModel.fromJson(response.data)
          → emit(LoginSuccess(user))
          → Navega para /home
      → Response 401/404/500 ❌
          → emit(LoginError(message))
          → Mostra LoginErrorScreen
```

#### 3. AuthInterceptor (Automático)
```
Qualquer request do Dio
  → AuthInterceptor.onRequest()
  → token = await LocalDataManager.getToken()
  → token != null?
      ├─ Sim → options.headers['Authorization'] = 'Bearer $token'
      └─ Não → Segue sem header
  → handler.next(options)

Response 401 (Unauthorized)
  → AuthInterceptor.onError()
  → LocalDataManager.deleteToken() (limpa token inválido)
  → Navega para /login
```

### Componentes Customizados

#### TokenTextField (Implementação Manual)
**Características:**
- Máscara: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
- Lógica: Inserir traços automaticamente nas posições 8, 13, 18, 23
- ObscureText inicial: `true` (oculto)
- Suffix icon: Ícone de olho para toggle show/hide
- Validação: Chama `cubit.validateTokenFormat()` no `onChanged`

**Implementação:**
```dart
class TokenTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  
  @override
  _TokenTextFieldState createState() => _TokenTextFieldState();
}

class _TokenTextFieldState extends State<TokenTextField> {
  bool _obscureText = true;
  
  String _applyMask(String text) {
    // Remove traços existentes
    final clean = text.replaceAll('-', '');
    
    // Limita a 36 caracteres (sem traços)
    if (clean.length > 36) return text;
    
    // Adiciona traços nas posições corretas
    String masked = '';
    for (int i = 0; i < clean.length; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        masked += '-';
      }
      masked += clean[i];
    }
    
    return masked;
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: (value) {
        final masked = _applyMask(value);
        if (masked != value) {
          widget.controller.value = TextEditingValue(
            text: masked,
            selection: TextSelection.collapsed(offset: masked.length),
          );
        }
        widget.onChanged(masked);
      },
      decoration: InputDecoration(
        labelText: 'Token de API',
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}
```

#### Barra de Progresso Animada
**Lógica:**
- AnimationController: `duration = 30 segundos`
- LinearProgressIndicator: `value = animation.value`
- Text: `${(animation.value * 100).toFixed(0)}%`
- Ao receber `LoginSuccess`: `controller.animateTo(1.0, duration: 300ms)`
- Ao receber `LoginError`: `controller.stop()`

### Dependências e Injeção

#### Novas Dependências (`pubspec.yaml`)
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0  # Armazenamento seguro
  url_launcher: ^6.2.0            # Abrir URL externa
  package_info_plus: ^5.0.0       # Versão do app
```

#### Dependency Injection (GetIt)

**Core DI** (`lib/core/dependency_injection/core_di.dart`):
```dart
void setupCoreDependencies({required GetIt getIt, required bool useMock}) {
  // LocalDataManager (compartilhado)
  getIt.registerLazySingleton(() => LocalDataManager());
  
  if (useMock) {
    // ... modo mock
  } else {
    getIt.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(baseUrl: 'https://api.wanikani.com/v2'))
        ..interceptors.add(AuthInterceptor(getIt())) // NOVO
        ..interceptors.add(LoggingInterceptor(isMockMode: false)),
    );
  }
}
```

**Login DI** (`lib/features/login/login_di.dart`):
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
    localDataManager: getIt(), // Obtém do core (já registrado em core_di)
  ));
}
```

**Chamada no main:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup core dependencies
  setupCoreDependencies(getIt: getIt, useMock: false);
  
  // Verificar se tem token para decidir rota inicial
  final localDataManager = getIt<LocalDataManager>();
  final token = await localDataManager.getToken();
  final initialRoute = token != null ? AppRoutes.home.path : AppRoutes.login.path;
  
  runApp(MyApp(initialRoute: initialRoute));
}
```

### Navegação e Rotas

#### Modificações em `app_routes.dart`
```dart
enum AppRoutes {
  /// Rota de login
  login('/login'),
  
  /// Rota inicial - Home/Dashboard
  home('/'),
}
```

#### Modificações em `app_router.dart`
```dart
static GoRouter router({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation ?? AppRoutes.home.path,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.login.path,
      name: AppRoutes.login.name,
      builder: (context, state) => BlocProvider<LoginCubit>.value(
        value: getIt<LoginCubit>(),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home.path,
      name: AppRoutes.home.name,
      builder: (context, state) => BlocProvider<HomeCubit>.value(
        value: getIt<HomeCubit>(),
        child: const HomeScreen(),
      ),
    ),
  ],
  // ...
);
```

### Design System e Componentes Visuais

#### Uso do Design System Existente
- **Cores:** `WaniKaniColors` (já implementado)
- **Tipografia:** `WaniKaniTextStyles` (já implementado)
- **Tokens:** `WaniKaniDesign` (spacing, radius, elevation)

**Exemplo de uso na LoginScreen:**
```dart
Text(
  'おかえり',
  style: WaniKaniTextStyles.h1, // Título principal
),
Text(
  'Por favor, insira seu token de API do WaniKani',
  style: WaniKaniTextStyles.body,
),
ElevatedButton(
  onPressed: isValid ? () => cubit.login(token) : null,
  child: Text('Fazer login'),
), // Usa tema do WaniKaniTheme automaticamente
```

### Testes

#### Cobertura Mínima (80%)

**Unit Tests:**
- `login_cubit_test.dart` - Todos os 5 estados e transições
- `user_repository_test.dart` - Sucesso e erro na API
- `get_user_usecase_test.dart` - Chamada ao repository
- `user_model_test.dart` - Parsing JSON
- `subscription_model_test.dart` - Parsing JSON
- `local_data_manager_test.dart` - Save/get/delete token (com mock)
- `auth_interceptor_test.dart` - Injeção de header e redirect 401

**Widget Tests:**
- `login_screen_test.dart` - Interações e estados
- `token_text_field_test.dart` - Máscara e validação
- `tutorial_bottom_sheet_test.dart` - Navegação

---

## 🔍 APIs e Integrações Externas

### WaniKani API v2

#### Endpoint: GET /user
**URL:** `https://api.wanikani.com/v2/user`  
**Header:** `Authorization: Bearer {token}`  
**Timeout:** 30 segundos

**Response Success (200):**
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

**Response Error (401):**
```json
{
  "error": "Unauthorized",
  "code": 401
}
```

#### Mock para Desenvolvimento
Arquivo: `assets/mock/user.json` (já existe)

Modificação necessária em `MockInterceptor`:
```dart
if (options.path.contains('/user')) {
  return _mockResponse('user', options);
}
```

---

## 📋 Dependências

### Existentes (Já no Projeto)
- ✅ `flutter_bloc` - State management
- ✅ `dartz` - Either monad
- ✅ `dio` - HTTP client
- ✅ `go_router` - Navegação
- ✅ `get_it` - Dependency injection
- ✅ `equatable` - Value equality

### Novas (A Adicionar)
- ⚠️ `flutter_secure_storage: ^9.0.0`
- ⚠️ `url_launcher: ^6.2.0`
- ⚠️ `package_info_plus: ^5.0.0`

---

## 🚨 Restrições e Considerações

### Restrições Técnicas
1. **Formato do Token:** Regex específico (36 chars com traços)
2. **Timeout:** Máximo 30 segundos para chamada da API
3. **Armazenamento:** Apenas token (dados do usuário NÃO são salvos agora)
4. **Offline:** Não funciona sem internet (validação requer API)

### Suposições
1. Token do WaniKani não expira automaticamente
2. Usuário tem acesso ao site do WaniKani para gerar token
3. Dispositivo tem conexão com internet para login inicial
4. `flutter_secure_storage` funciona corretamente em Android/iOS

### Trade-offs
1. **Segurança vs UX:** Validar sempre na API (mais lento, mas mais seguro)
2. **Barra de Progresso:** Simulada vs real (melhor UX, mas não precisa)
3. **Máscara Manual:** Mais código, mas sem dependência extra

### Consequências
- ✅ Positivas:
  - Múltiplos usuários podem usar o app
  - Token não fica exposto no código
  - Base sólida para logout e refresh
  
- ⚠️ Negativas:
  - Requer internet para primeiro login
  - Mais complexidade (4 telas vs 1)
  - Usuário precisa saber onde conseguir token

---

## ✅ Checklist de Implementação

### Fase 1: Infraestrutura Core
- [ ] Adicionar dependências ao `pubspec.yaml`
- [ ] Criar `LocalDataManager` em `lib/core/storage/`
- [ ] Criar `AuthInterceptor` em `lib/core/network/interceptors/`
- [ ] Atualizar `core_di.dart` para registrar ambos
- [ ] Adicionar mock de `/user` ao `MockInterceptor`

### Fase 2: Domain Layer (Login Feature)
- [ ] Criar `UserEntity`
- [ ] Criar `SubscriptionEntity`
- [ ] Criar `IUserRepository` (interface)
- [ ] Criar `GetUserUseCase`

### Fase 3: Data Layer (Login Feature)
- [ ] Criar `UserModel` (extension type)
- [ ] Criar `SubscriptionModel` (extension type)
- [ ] Criar `WaniKaniAuthDataSource`
- [ ] Criar `UserRepository` (implementação)

### Fase 4: Presentation Layer (Login Feature)
- [ ] Criar `LoginState` (5 estados sealed)
- [ ] Criar `LoginCubit`
- [ ] Criar `TokenTextField` widget
- [ ] Criar `LoginScreen`
- [ ] Criar `TutorialBottomSheet`
- [ ] Criar `LoginLoadingScreen`
- [ ] Criar `LoginErrorScreen`

### Fase 5: Integração
- [ ] Criar `login_di.dart`
- [ ] Atualizar `app_routes.dart` (adicionar /login)
- [ ] Atualizar `app_router.dart` (adicionar rota + lógica inicial)
- [ ] Modificar `main.dart` para verificar token ao iniciar

### Fase 6: Testes
- [ ] Testes unitários (7 arquivos)
- [ ] Testes de widget (3 arquivos)
- [ ] Validar cobertura mínima 80%

### Fase 7: Validação
- [ ] Testar fluxo completo em modo mock
- [ ] Testar fluxo completo com API real
- [ ] Validar UX e acessibilidade
- [ ] Code review

---

## 🎯 Definição de Pronto (DoD)

Feature estará completa quando:
1. ✅ Todas as 4 telas estiverem funcionando
2. ✅ Token for salvo com segurança após login bem-sucedido
3. ✅ AuthInterceptor injetar token automaticamente
4. ✅ Redirect para /login em caso de 401
5. ✅ Validação de formato e API funcionando
6. ✅ Cobertura de testes ≥ 80%
7. ✅ Código seguir padrões do projeto (linting 80+ rules)
8. ✅ Documentação inline (/// comments) em todas as classes
9. ✅ Funcionar em modo mock e produção
10. ✅ Aprovação em code review

---

> **Próximo passo:** Aguardar aprovação deste contexto para prosseguir com o documento de arquitetura detalhada.
