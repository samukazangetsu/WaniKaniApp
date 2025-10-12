# Guia de Troubleshooting

> **Projeto:** WaniKani App  
> **Última Atualização:** 11/10/2025

---

## 📋 Índice Rápido

1. [Build Issues](#-build-issues)
2. [Drift/Code Generation](#-driftcode-generation)
3. [Networking/API](#-networkingapi)
4. [State Management](#-state-management)
5. [Navigation](#-navigation)
6. [Database/Cache](#-databasecache)
7. [Platform Specific](#-platform-specific)
8. [Performance](#-performance)
9. [Testing](#-testing)
10. [DevTools](#-devtools)

---

## 🔨 Build Issues

### ❌ "Gradle build failed"

**Sintomas:**

```text
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:processDebugResources'.
```

**Soluções:**

```bash
# 1. Limpar cache do Flutter
flutter clean
flutter pub get

# 2. Limpar build Android
cd android
./gradlew clean
cd ..

# 3. Invalidar cache Gradle
rm -rf ~/.gradle/caches/
flutter clean && flutter pub get

# 4. Verificar versões no build.gradle.kts
# android/app/build.gradle.kts
# compileSdk = 34
# minSdk = 21
# targetSdk = 34
```

### ❌ "Pod install failed" (iOS)

**Sintomas:**

```text
Error running pod install
CocoaPods not installed or not in valid state
```

**Soluções:**

```bash
# 1. Reinstalar CocoaPods
sudo gem install cocoapods

# 2. Limpar pods
cd ios
rm -rf Pods/ Podfile.lock
pod install --repo-update
cd ..

# 3. Se falhar, atualizar CocoaPods
sudo gem install cocoapods --pre
cd ios && pod install
```

### ❌ "Xcode build failed"

**Sintomas:**

```text
error: Signing for "Runner" requires a development team.
```

**Soluções:**

```text
1. Abrir ios/Runner.xcworkspace no Xcode
2. Selecionar Runner no Project Navigator
3. Ir em Signing & Capabilities
4. Selecionar seu Team (ou usar "Automatically manage signing")
5. Rebuild
```

---

## 🏗️ Drift/Code Generation

### ❌ "Part directive não encontrado"

**Sintomas:**

```dart
// assignment_dao.dart
part 'assignment_dao.g.dart'; // ❌ Arquivo não existe
```

**Soluções:**

```bash
# 1. Rodar build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# 2. Se não gerar, verificar sintaxe
# - Tabela deve extender Table
# - DAO deve ter @DriftAccessor
# - Database deve ter @DriftDatabase

# 3. Watch mode para auto-regenerar
flutter pub run build_runner watch
```

### ❌ "Conflicting outputs"

**Sintomas:**

```text
[SEVERE] Conflicting outputs were detected
```

**Soluções:**

```bash
# Deletar arquivos gerados manualmente
find lib -name "*.g.dart" -delete
find lib -name "*.freezed.dart" -delete

# Rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ "Drift migration error"

**Sintomas:**

```dart
DatabaseConnectionUser.createMigrator: Expected database version 1, but got 2
```

**Soluções:**

```dart
// lib/core/database/app_database.dart
@DriftDatabase(/* ... */)
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 2; // ✅ Incrementar versão

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Migração de v1 para v2
        await migrator.addColumn(assignments, assignments.someNewColumn);
      }
    },
    beforeOpen: (details) async {
      // Desenvolvimento: resetar DB em cada mudança
      if (details.wasCreated || details.hadUpgrade) {
        await customStatement('PRAGMA foreign_keys = ON');
      }
    },
  );
}
```

---

## 🌐 Networking/API

### ❌ "401 Unauthorized"

**Sintomas:**

```json
{
  "error": "Unauthorized",
  "code": 401
}
```

**Soluções:**

```dart
// 1. Verificar se token está salvo
final token = await FlutterSecureStorage().read(key: 'api_token');
debugPrint('Token: $token'); // Deve ter valor

// 2. Verificar header Authorization
headers: {
  'Authorization': 'Bearer $token', // ✅ Prefixo "Bearer" obrigatório
}

// 3. Gerar novo token
// https://www.wanikani.com/settings/personal_access_tokens

// 4. Verificar validade do token
// Token pode ter expirado ou sido revogado
```

### ❌ "429 Too Many Requests"

**Sintomas:**

```json
{
  "error": "Rate limit exceeded",
  "code": 429
}
```

**Soluções:**

```dart
// 1. Implementar rate limit checker
class RateLimitInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final limit = response.headers.value('RateLimit-Limit');
    final remaining = response.headers.value('RateLimit-Remaining');
    final reset = response.headers.value('RateLimit-Reset');
    
    debugPrint('Rate Limit: $remaining/$limit (reset: $reset)');
    
    if (int.tryParse(remaining ?? '0')! < 5) {
      debugPrint('⚠️ AVISO: Próximo do rate limit!');
    }
    
    super.onResponse(response, handler);
  }
}

// 2. Adicionar delay entre requests
await Future.delayed(Duration(seconds: 1));

// 3. Usar cache agressivamente
// Verificar If-Modified-Since
```

### ❌ "Network timeout"

**Sintomas:**

```text
DioException [connection timeout]: The connection has timed out
```

**Soluções:**

```dart
// Aumentar timeout no Dio
final dio = Dio(
  BaseOptions(
    connectTimeout: Duration(seconds: 30), // ✅ Aumentar de 10 para 30
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  ),
);

// Implementar retry logic
class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionTimeout && retries < 3) {
      await Future.delayed(Duration(seconds: 2));
      // Retry request
      return handler.resolve(await _retry(err.requestOptions));
    }
    super.onError(err, handler);
  }
}
```

### ❌ "SSL Handshake error"

**Sintomas:**

```text
HandshakeException: Handshake error in client
```

**Soluções:**

```dart
// APENAS PARA DESENVOLVIMENTO - NUNCA EM PRODUÇÃO
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true; // ⚠️ INSEGURO
  }
}

void main() {
  if (kDebugMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }
  runApp(MyApp());
}
```

---

## 🧩 State Management

### ❌ "BlocProvider not found"

**Sintomas:**

```text
BlocProvider.of() called with a context that does not contain a Bloc
```

**Soluções:**

```dart
// ❌ ERRADO - BlocProvider fora da árvore
Widget build(BuildContext context) {
  return Scaffold(
    body: BlocProvider(
      create: (_) => DashboardCubit(),
      child: Container(), // ❌ BlocBuilder está DENTRO
    ),
  );
}

// ✅ CORRETO - BlocProvider acima
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => DashboardCubit(),
    child: Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => Container(), // ✅ Acessa cubit
      ),
    ),
  );
}

// ✅ ALTERNATIVA - Passar cubit explicitamente
BlocBuilder<DashboardCubit, DashboardState>(
  bloc: _cubit, // ✅ Instância injetada
  builder: (context, state) => Container(),
)
```

### ❌ "Cubit/Bloc closed exception"

**Sintomas:**

```text
Bad state: Cannot emit new states after calling close
```

**Soluções:**

```dart
// ❌ ERRADO - emit após close
class DashboardCubit extends Cubit<DashboardState> {
  void loadData() async {
    emit(DashboardLoading());
    final data = await repository.fetch();
    close(); // ❌ Fecha cedo
    emit(DashboardLoaded(data)); // ❌ Erro aqui
  }
}

// ✅ CORRETO - Verificar isClosed
class DashboardCubit extends Cubit<DashboardState> {
  void loadData() async {
    emit(DashboardLoading());
    final data = await repository.fetch();
    if (!isClosed) { // ✅ Verifica antes de emitir
      emit(DashboardLoaded(data));
    }
  }
}
```

### ❌ "setState() called after dispose()"

**Sintomas:**

```text
setState() called after dispose()
```

**Soluções:**

```dart
// ❌ ERRADO - setState sem verificar mounted
void _loadData() async {
  final data = await fetchData();
  setState(() { // ❌ Widget pode estar disposed
    _data = data;
  });
}

// ✅ CORRETO - Verificar mounted
void _loadData() async {
  final data = await fetchData();
  if (mounted) { // ✅ Verifica antes de setState
    setState(() => _data = data);
  }
}
```

---

## 🧭 Navigation

### ❌ "Navigator operation requested with a context that does not include a Navigator"

**Sintomas:**

```text
Navigator.of(context) called with a context that does not contain a Navigator
```

**Soluções:**

```dart
// ❌ ERRADO - context do MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ElevatedButton(
        onPressed: () => Navigator.push(...), // ❌ Sem Navigator acima
      ),
    );
  }
}

// ✅ CORRETO - Usar Builder ou GlobalKey
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder( // ✅ Novo context com Navigator
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(...), // ✅ Funciona
        ),
      ),
    );
  }
}

// ✅ MELHOR - go_router (usado neste projeto)
context.go('/dashboard');
```

### ❌ "GoRouter: no RouteMatch found"

**Sintomas:**

```text
GoException: no routes matched location: /wrong-route
```

**Soluções:**

```dart
// 1. Verificar rota registrada
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    GoRoute(path: '/dashboard', builder: (_, __) => DashboardPage()), // ✅
  ],
);

// 2. Usar rotas corretas
context.go('/dashboard'); // ✅ Rota existe
context.go('/dasboard'); // ❌ Typo

// 3. Verificar redirecionamento
redirect: (context, state) {
  debugPrint('Navigating to: ${state.location}'); // Debug
  return state.location;
}
```

---

## 💾 Database/Cache

### ❌ "Database locked"

**Sintomas:**

```text
SqliteException: database is locked (5)
```

**Soluções:**

```dart
// Configurar WAL mode no Drift
@DriftDatabase(/* ... */)
class AppDatabase extends _$AppDatabase {
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode = WAL'); // ✅ Write-Ahead Logging
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

### ❌ "Cache não expira"

**Sintomas:**

```dart
// Cache deveria expirar após 24h, mas não expira
```

**Soluções:**

```dart
// ✅ Implementar TTL check corretamente
class AssignmentRepository implements IAssignmentRepository {
  Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
    // 1. Verificar cache
    final cached = await _dao.getAll();
    
    if (cached.isNotEmpty) {
      final firstItem = cached.first;
      final now = DateTime.now();
      final cacheAge = now.difference(firstItem.fetchedAt);
      
      // ✅ TTL de 24 horas
      if (cacheAge.inHours < 24) {
        return Right(cached.map((e) => e.toEntity()).toList());
      }
    }
    
    // 2. Cache expirado ou vazio - fetch da API
    final response = await _datasource.getAssignments();
    // ...
  }
}
```

### ❌ "Cache inconsistente após update"

**Sintomas:**

```dart
// Update na API, mas cache não atualiza
```

**Soluções:**

```dart
// ✅ Invalidar cache após mutations
class AssignmentRepository implements IAssignmentRepository {
  Future<Either<IError, Unit>> updateAssignment(int id, Map data) async {
    // 1. Update na API
    final response = await _datasource.updateAssignment(id, data);
    
    if (response.isSuccessful) {
      // 2. ✅ Invalidar cache
      await _dao.deleteById(id);
      
      // OU atualizar localmente
      await _dao.upsert(AssignmentModel.fromJson(response.data));
      
      return Right(unit);
    }
    
    return Left(ApiErrorEntity.fromResponse(response));
  }
}
```

---

## 📱 Platform Specific

### ❌ Android: "MinSdkVersion too low"

**Sintomas:**

```text
Manifest merger failed : uses-sdk:minSdkVersion 16 cannot be smaller than version 21
```

**Soluções:**

```kotlin
// android/app/build.gradle.kts
android {
    defaultConfig {
        minSdk = 21 // ✅ Mínimo para packages modernos
        targetSdk = 34
    }
}
```

### ❌ iOS: "Info.plist missing key"

**Sintomas:**

```text
This app has crashed because it attempted to access privacy-sensitive data
```

**Soluções:**

```xml
<!-- ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos</string>

<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos acessar sua localização</string>
```

---

## ⚡ Performance

### ❌ "UI Jank / Frame drops"

**Soluções:**

```dart
// 1. Usar const constructors sempre que possível
const Text('Hello'); // ✅
Text('Hello'); // ❌

// 2. Evitar rebuild desnecessários
class MyWidget extends StatelessWidget {
  final String title;
  const MyWidget({required this.title}); // ✅ const

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      buildWhen: (prev, curr) => prev.data != curr.data, // ✅ Selective rebuild
      builder: (context, state) => Text(state.data),
    );
  }
}

// 3. Usar ListView.builder para listas grandes
ListView.builder( // ✅ Lazy loading
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

### ❌ "Memory leak - Cubit não fecha"

**Soluções:**

```dart
// ✅ Sempre fazer dispose de Cubits manuais
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late final MyCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<MyCubit>();
  }

  @override
  void dispose() {
    _cubit.close(); // ✅ CRUCIAL
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<MyCubit, MyState>(
    bloc: _cubit,
    builder: (context, state) => Container(),
  );
}
```

---

## 🧪 Testing

### ❌ "Mock not registered"

**Sintomas:**

```text
MissingStubError: 'getAssignments'
No stub was found which matches the arguments of this method call
```

**Soluções:**

```dart
// ✅ Registrar mock com when ANTES de chamar
test('should return assignments', () async {
  // Arrange
  when(() => mockRepository.getAssignments()) // ✅ ANTES do act
      .thenAnswer((_) async => Right(tAssignments));

  // Act
  final result = await useCase();

  // Assert
  expect(result, Right(tAssignments));
});
```

### ❌ "Test timeout"

**Sintomas:**

```text
Test timed out after 30 seconds
```

**Soluções:**

```dart
// 1. Aumentar timeout
test('long test', () async {
  // ...
}, timeout: Timeout(Duration(minutes: 2))); // ✅

// 2. Usar pump em widget tests
await tester.pumpWidget(MyApp());
await tester.pumpAndSettle(); // ✅ Espera animações
```

---

## 🛠️ DevTools

### Flutter DevTools não abre

**Soluções:**

```bash
# 1. Ativar DevTools
flutter pub global activate devtools

# 2. Rodar separadamente
flutter pub global run devtools

# 3. Verificar versão Flutter
flutter doctor -v
```

### Inspector não mostra widgets

**Soluções:**

```dart
// Rodar em debug mode
flutter run --debug // ✅
flutter run --release // ❌ Não tem debug info
```

---

## 📞 Quando Tudo Falhar

### Último recurso

```bash
# 1. Limpar TUDO
flutter clean
rm -rf ~/.pub-cache/
rm -rf build/
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle

# 2. Reinstalar dependências
flutter pub get
cd ios && pod install --repo-update

# 3. Rebuild
flutter run
```

### Ainda não funciona?

1. Verificar `flutter doctor -v`
2. Atualizar Flutter: `flutter upgrade`
3. Verificar issues no GitHub do package problemático
4. Criar issue no repositório do projeto

---

**Última Revisão:** 11/10/2025
