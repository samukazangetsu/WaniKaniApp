# Desafios Arquiteturais e Melhorias Futuras

> **Última Atualização:** 02/11/2025  
> **Versão:** 1.0.0

---

## 🎯 Visão Geral

Este documento lista desafios técnicos identificados, débitos técnicos conhecidos e melhorias planejadas para o WaniKani App. Use como referência para priorização de refactorings e evoluções arquiteturais.

---

## 🔥 Prioridade ALTA - Corretude e Segurança

### 1. Padronizar Error Handling em Todos os Repositories

**Problema Atual:**
- `UserRepository` segue padrão correto de tratamento de `DioException`
- `HomeRepository` e futuros repositories não seguem o mesmo padrão
- Inconsistência causa bugs difíceis de rastrear

**Impacto:**
- 🔴 Erros de API não são tratados corretamente
- 🔴 UI recebe erro genérico ao invés de mensagem específica
- 🔴 Possíveis crashes em produção

**Solução:**
Refatorar todos os repositories para seguir o padrão estabelecido em `UserRepository.getUser()`:

```dart
// Padrão OBRIGATÓRIO para todos os repositories
@override
Future<Either<IError, T>> metodoDoRepository() async {
  try {
    final response = await _datasource.metodo();
    
    if (response.isSuccessful) {
      return tryDecode<Either<IError, T>>(
        () {
          // Parsing logic
          final entity = Model.fromJson(response.data);
          return Right(entity);
        },
        orElse: (_) => Left(InternalErrorEntity(CoreStrings.errorUnknown)),
      );
    }
    
    // ✅ CRÍTICO: Retornar ApiErrorEntity quando !isSuccessful
    return Left(ApiErrorEntity.fromJson(response.data));
  } on Exception catch (e) {
    // ✅ CRÍTICO: Tratar DioException especificamente
    if (e is DioException) {
      return Left(ApiErrorEntity.fromJson(e.response?.data));
    }
    return Left(InternalErrorEntity(e.toString()));
  }
}
```

**Arquivos Afetados:**
- ✅ `lib/features/login/data/repositories/user_repository.dart` - **OK**
- ❌ `lib/features/home/data/repositories/home_repository.dart` - **PRECISA REFACTORING**
  - `getCurrentLevelProgression()`
  - `getAssignments()`
  - `getReviewStats()`
  - `getLessonStats()`

**Estimativa:** 2-3 horas  
**Prioridade:** 🔴 CRÍTICA  
**Status:** Pendente

---

### 2. Implementar Tratamento Global de Erro 401 (Unauthorized)

**Problema Atual:**
- Erro 401 apenas tratado no `LoginCubit`
- Se token expira enquanto usuário navega, app não redireciona para login
- Telas exibem erro genérico

**Impacto:**
- 🔴 UX ruim quando token expira
- 🔴 Usuário não sabe que precisa fazer login novamente
- 🟡 Possível loop de requisições falhadas

**Solução Opção 1: Interceptor Global**
```dart
// lib/core/network/interceptors/auth_interceptor.dart

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final GoRouter _router;
  
  AuthInterceptor({
    required FlutterSecureStorage storage,
    required GoRouter router,
  }) : _storage = storage, _router = router;
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 1. Limpar token
      await _storage.delete(key: 'api_key');
      
      // 2. Limpar dados do usuário (quando implementado)
      // await _localDataManager.clearUser();
      
      // 3. Redirecionar para login
      _router.go('/login');
      
      // 4. Mostrar notificação (toast ou snackbar)
      // _notificationService.show('Sessão expirada. Faça login novamente.');
    }
    
    handler.next(err);
  }
}
```

**Solução Opção 2: Stream Global de Autenticação**
```dart
// lib/core/auth/auth_service.dart

class AuthService {
  final _authStateController = StreamController<AuthState>.broadcast();
  
  Stream<AuthState> get authState => _authStateController.stream;
  
  void signOut() {
    _authStateController.add(AuthState.unauthenticated);
    // Limpar storage
    // Redirecionar
  }
}

// Em cada repository
if (e is DioException && e.response?.statusCode == 401) {
  GetIt.I<AuthService>().signOut();
  return Left(AuthErrorEntity('Sessão expirada'));
}
```

**Estimativa:** 4-6 horas  
**Prioridade:** 🔴 ALTA  
**Status:** Pendente

---

### 3. Fix: Cubit Emit Após Close (Hot Reload)

**Problema Atual:**
- SplashCubit tenta emitir estado após hot reload
- Causa erro `Cannot emit new states after calling close`

**Impacto:**
- 🟡 Erro em desenvolvimento (logs poluídos)
- 🟢 Não afeta produção

**Solução:**
Adicionar guards `isClosed` antes de todos os `emit()` em operações assíncronas:

```dart
// Em splash_cubit.dart e outros cubits com operações assíncronas
Future<void> checkSavedToken() async {
  try {
    final token = await _storage.read(key: 'api_key');
    
    if (isClosed) return;  // ✅ Guard
    
    if (token != null) {
      emit(SplashAuthenticated());
    } else {
      emit(SplashUnauthenticated());
    }
  } catch (e) {
    if (isClosed) return;  // ✅ Guard no catch também
    emit(SplashError(message: e.toString()));
  }
}
```

**Estimativa:** 1 hora  
**Prioridade:** 🟡 MÉDIA  
**Status:** Pendente

---

## 🚀 Prioridade MÉDIA - Features e Performance

### 4. Implementar Cache Offline com Drift

**Problema Atual:**
- App não funciona offline (apenas mocks em desenvolvimento)
- Toda requisição vai para API mesmo se dados não mudaram

**Impacto:**
- 🔴 Objetivo offline-first não cumprido
- 🟡 Consumo desnecessário de API rate limit
- 🟡 UX ruim em conexões lentas

**Solução:**
Implementar camada de cache com Drift (SQLite):

**1. Setup Drift Database:**
```dart
// lib/core/database/app_database.dart

@DriftDatabase(tables: [
  Assignments,
  LevelProgressions,
  ReviewStatistics,
  Users,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'wanikani_app_db',
      logStatements: true,
    );
  }
}
```

**2. Criar DAOs:**
```dart
// lib/core/database/daos/assignment_dao.dart

@DriftAccessor(tables: [Assignments])
class AssignmentDao extends DatabaseAccessor<AppDatabase> 
    with _$AssignmentDaoMixin {
  
  AssignmentDao(AppDatabase db) : super(db);
  
  Future<List<AssignmentEntity>> getAll() async {
    final query = select(assignments);
    final results = await query.get();
    return results.map((row) => row.toEntity()).toList();
  }
  
  Future<void> upsertAll(List<AssignmentEntity> entities) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        assignments,
        entities.map((e) => e.toCompanion()).toList(),
      );
    });
  }
  
  Future<void> deleteExpired(Duration ttl) async {
    final cutoff = DateTime.now().subtract(ttl);
    await (delete(assignments)
      ..where((tbl) => tbl.cachedAt.isSmallerThanValue(cutoff))
    ).go();
  }
}
```

**3. Atualizar Repositories com Cache:**
```dart
// Padrão offline-first
@override
Future<Either<IError, List<AssignmentEntity>>> getAssignments({
  bool forceRefresh = false,
}) async {
  try {
    // 1. Limpar cache expirado
    await _assignmentDao.deleteExpired(Duration(hours: 24));
    
    // 2. Checar cache se não for force refresh
    if (!forceRefresh) {
      final cached = await _assignmentDao.getAll();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
    }
    
    // 3. Buscar da API
    final response = await _datasource.getAssignments();
    if (response.isSuccessful) {
      final entities = (response.data['data'] as List)
        .map((json) => AssignmentModel.fromJson(json))
        .toList();
      
      // 4. Cachear dados
      await _assignmentDao.upsertAll(entities);
      
      return Right(entities);
    }
    
    return Left(ApiErrorEntity.fromJson(response.data));
  } on Exception catch (e) {
    // 5. Fallback para cache expirado em caso de erro de rede
    if (e is DioException) {
      final cached = await _assignmentDao.getAll();
      if (cached.isNotEmpty) {
        // Retornar cache mesmo expirado (melhor que nada)
        return Right(cached);
      }
      return Left(ApiErrorEntity.fromJson(e.response?.data));
    }
    return Left(InternalErrorEntity(e.toString()));
  }
}
```

**TTLs por Endpoint:**
- Assignments: 24 horas
- Level Progressions: 24 horas
- Review Statistics: 1 hora
- User: 7 dias

**Estimativa:** 20-30 horas  
**Prioridade:** 🟠 ALTA  
**Status:** Não iniciado

---

### 5. Persistir Dados do User Após Login

**Problema Atual:**
- Login valida token via GET /user
- Response não é salva localmente
- Home e outras features podem precisar fazer nova requisição GET /user

**Impacto:**
- 🟡 Chamadas duplicadas à API
- 🟡 Consumo desnecessário de rate limit
- 🟡 Dados do usuário não disponíveis offline

**Solução:**
Salvar resposta do GET /user localmente após login bem-sucedido:

```dart
// 1. Criar LocalDataManager (ou usar Drift DAO)
class LocalDataManager {
  final FlutterSecureStorage _storage;
  
  static const String _userKey = 'cached_user';
  
  Future<void> saveUser(UserEntity user) async {
    final json = UserModel(user).toJson();
    await _storage.write(
      key: _userKey,
      value: jsonEncode(json),
    );
  }
  
  Future<UserEntity?> getUser() async {
    final jsonString = await _storage.read(key: _userKey);
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString);
    return UserModel.fromJson(json);
  }
  
  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}

// 2. Atualizar LoginCubit
Future<void> login(String apiKey) async {
  emit(LoginLoading());
  
  // Salvar API key
  await _storage.write(key: 'api_key', value: apiKey);
  
  // Validar com GET /user
  final result = await _getUserUseCase(apiKey);
  
  result.fold(
    (error) {
      emit(LoginError(message: error.message));
    },
    (user) async {
      // ✅ Salvar user localmente
      await _localDataManager.saveUser(user);
      
      emit(LoginSuccess(user: user));
    },
  );
}

// 3. Outras features consomem cache
class HomeCubit extends Cubit<HomeState> {
  Future<void> loadDashboard() async {
    // Buscar user do cache local (não da API)
    final user = await _localDataManager.getUser();
    
    if (user != null) {
      // Usar dados do user
      emit(HomeLoaded(username: user.username, level: user.level));
    }
  }
}
```

**Estimativa:** 3-4 horas  
**Prioridade:** 🟠 MÉDIA  
**Status:** Pendente

---

### 6. Implementar Rate Limiting e Retry com Backoff

**Problema Atual:**
- App não trata erro 429 (Too Many Requests)
- Não há retry automático em falhas temporárias

**Impacto:**
- 🟡 UX ruim quando rate limit é atingido
- 🟡 Usuário precisa fazer refresh manual

**Solução:**
Interceptor de retry com exponential backoff:

```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;
  
  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        final waitTime = _calculateWaitTime(err, retryCount);
        await Future.delayed(waitTime);
        
        try {
          final response = await _retry(err.requestOptions, retryCount + 1);
          handler.resolve(response);
          return;
        } catch (e) {
          // Se retry falhar, continuar normalmente
        }
      }
    }
    
    handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.response?.statusCode == 429 ||  // Rate limit
           err.response?.statusCode == 503 ||  // Service unavailable
           err.type == DioExceptionType.connectionTimeout;
  }
  
  Duration _calculateWaitTime(DioException err, int retryCount) {
    // Verificar header Retry-After
    if (err.response?.statusCode == 429) {
      final retryAfter = err.response?.headers['Retry-After']?.first;
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          return Duration(seconds: seconds);
        }
      }
    }
    
    // Exponential backoff: 1s, 2s, 4s, 8s...
    return initialDelay * (1 << retryCount);
  }
}
```

**Estimativa:** 4-5 horas  
**Prioridade:** 🟡 MÉDIA  
**Status:** Pendente

---

## 🎨 Prioridade BAIXA - UX e Qualidade de Vida

### 7. Implementar Internacionalização (i18n)

**Problema Atual:**
- Strings hardcoded em PT-BR
- Não suporta EN (planejado)

**Solução:**
Usar package de i18n (a definir):
- `flutter_localizations`
- `easy_localization`
- `intl`

**Estimativa:** 8-10 horas  
**Prioridade:** 🟢 BAIXA  
**Status:** Futuro (pós-v1.0)

---

### 8. Implementar CI/CD com GitHub Actions

**Problema Atual:**
- Sem automação de testes
- Sem verificação automática de quality gates

**Solução:**
Criar workflow `.github/workflows/pr.yml`:

```yaml
name: PR Checks

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter format --dry-run --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

**Estimativa:** 3-4 horas  
**Prioridade:** 🟡 MÉDIA  
**Status:** Planejado para futuro próximo

---

### 9. Adicionar GitHub Copilot Pro Review em PRs

**Problema Atual:**
- Code review apenas manual

**Solução:**
Habilitar GitHub Copilot Pro review automático em PRs

**Estimativa:** 1 hora (configuração)  
**Prioridade:** 🟢 BAIXA  
**Status:** Planejado

---

## 📊 Métricas e Monitoramento (Futuro)

### 10. Implementar Analytics e Crash Reporting

**Problema Atual:**
- Sem visibilidade de crashes em produção
- Sem métricas de uso

**Solução (Opções):**
- Firebase Crashlytics
- Sentry
- Firebase Analytics (opcional)

**Estimativa:** 6-8 horas  
**Prioridade:** 🟢 BAIXA (pós-loja)  
**Status:** Futuro

---

## 📋 Resumo de Prioridades

### Sprint Atual (Próximas 2 semanas)
1. 🔴 Padronizar error handling em HomeRepository
2. 🔴 Implementar tratamento global de 401
3. 🟡 Fix cubit emit após close

### Próximo Sprint (2-4 semanas)
4. 🟠 Implementar cache offline com Drift
5. 🟠 Persistir dados do user após login

### Backlog (1-3 meses)
6. 🟡 Rate limiting e retry
7. 🟡 CI/CD com GitHub Actions
8. 🟢 i18n PT-BR + EN
9. 🟢 Copilot Pro review
10. 🟢 Analytics e crash reporting

---

## 🔗 Referências

- [ADR-003: Offline-First com Drift](adr/003-offline-first-drift.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problemas conhecidos
- [GitHub Issues](https://github.com/samukazangetsu/WaniKaniApp/issues) - Track de tasks

---

> **Nota:** Este documento é vivo. Adicione novos desafios conforme identificados, marque como resolvidos quando concluídos. 🚀
