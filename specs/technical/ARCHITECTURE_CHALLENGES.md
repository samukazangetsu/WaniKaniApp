# Desafios Arquiteturais e Roadmap de Melhorias

> **Projeto:** WaniKani App  
> **Última Atualização:** 11/10/2025  
> **Status do Projeto:** Em desenvolvimento inicial (MVP)

---

## 📊 Status Atual da Implementação

### ✅ Concluído

- [x] Estrutura base do projeto Flutter
- [x] Configuração de linting (80+ regras)
- [x] Clean Architecture skeleton (pastas data/domain/presentation)
- [x] Configuração de mocks (JSON files em `assets/mock/`)
- [x] Decisões arquiteturais documentadas (5 ADRs)
- [x] Configuração de dependências principais (BLoC, Drift, go_router, GetIt)
- [x] Tema japonês inicial (cores, tipografia Noto Sans JP)
- [x] Core error handling (IError, ApiErrorEntity, InternalErrorEntity)
- [x] DecodeModelMixin para safe parsing

### 🚧 Em Desenvolvimento (Vazio/Skeleton)

- [ ] **Features completas** - Todas as pastas em `lib/features/` estão vazias
- [ ] **Database Drift** - Tabelas e DAOs não implementados
- [ ] **API Integration** - Datasources, repositories e use cases não implementados
- [ ] **UI Screens** - Nenhuma tela implementada além de skeleton
- [ ] **Navigation** - go_router configurado mas sem rotas reais
- [ ] **Dependency Injection** - GetIt configurado mas sem registros
- [ ] **Tests** - Estrutura existe mas sem testes implementados

### ❌ Não Iniciado

- [ ] Autenticação com WaniKani API (token management)
- [ ] Dashboard com estatísticas SRS
- [ ] Visualização de assignments
- [ ] Sincronização offline
- [ ] Cache management com TTL
- [ ] Rate limiting
- [ ] Error handling UI
- [ ] Loading states
- [ ] Dark mode
- [ ] Notificações

---

## 🎯 Desafios Arquiteturais Atuais

### 1. Sincronização Offline Complexa

**Desafio:**

O sistema de cache com TTL precisa lidar com múltiplos cenários:

- Cache miss (primeira vez)
- Cache hit válido (< 24h)
- Cache expirado (> 24h)
- Conflitos entre cache local e API (user fez review no web)
- Network offline (usar cache expirado ou erro?)

**Possíveis Soluções:**

```dart
// Opção A: Cache-first com fallback
Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
  try {
    // 1. Tentar API primeiro
    final apiResult = await _datasource.getAssignments();
    if (apiResult.isSuccessful) {
      await _dao.upsertAll(apiResult.data);
      return Right(apiResult.data);
    }
  } catch (e) {
    // Network error - usar cache mesmo expirado
  }
  
  // 2. Fallback para cache
  final cached = await _dao.getAll();
  if (cached.isNotEmpty) {
    return Right(cached);
  }
  
  return Left(NetworkErrorEntity());
}

// Opção B: Cache-first agressivo
Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
  // 1. Retornar cache imediatamente se válido
  final cached = await _dao.getAll();
  if (cached.isNotEmpty && !_isExpired(cached.first)) {
    // Background refresh (não espera)
    _refreshInBackground();
    return Right(cached);
  }
  
  // 2. Fetch da API
  return _fetchFromApi();
}
```

**Decisão Pendente:**

- Como notificar UI de updates em background?
- Usar Stream no repository para emitir múltiplas respostas?
- Implementar "pull-to-refresh"?

---

### 2. State Management Complexity

**Desafio:**

Algumas features precisam coordenar múltiplos Cubits:

```dart
// Dashboard precisa de dados de 3 endpoints diferentes
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AssignmentsCubit()),
        BlocProvider(create: (_) => LevelProgressionCubit()),
        BlocProvider(create: (_) => ReviewStatisticsCubit()),
      ],
      child: BlocBuilder<...>(/* Como combinar 3 estados? */),
    );
  }
}
```

**Possíveis Soluções:**

```dart
// Opção A: Cubit agregador (recomendado)
class DashboardCubit extends Cubit<DashboardState> {
  final GetAssignmentsUseCase _getAssignments;
  final GetLevelProgressionUseCase _getLevelProgression;
  final GetReviewStatisticsUseCase _getReviewStatistics;

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    
    // Fetch paralelo
    final results = await Future.wait([
      _getAssignments(),
      _getLevelProgression(),
      _getReviewStatistics(),
    ]);
    
    // Combinar resultados
    final assignments = results[0].fold((e) => null, (data) => data);
    final progression = results[1].fold((e) => null, (data) => data);
    final statistics = results[2].fold((e) => null, (data) => data);
    
    if (assignments != null && progression != null && statistics != null) {
      emit(DashboardLoaded(
        assignments: assignments,
        progression: progression,
        statistics: statistics,
      ));
    } else {
      emit(DashboardError(/* ... */));
    }
  }
}

// Opção B: Combinar streams (mais complexo)
Stream<DashboardState> _mapLoadToState() async* {
  yield DashboardLoading();
  
  await for (final combined in Rx.combineLatest3(
    _assignmentRepository.watchAll(),
    _progressionRepository.watchCurrent(),
    _statisticsRepository.watchAll(),
    (a, p, s) => DashboardData(a, p, s),
  )) {
    yield DashboardLoaded(data: combined);
  }
}
```

**Decisão Pendente:**

- Cubit agregador para cada feature complexa?
- Usar streams (rxdart) ou Futures simples?

---

### 3. Cache Invalidation Strategy

**Desafio:**

Quando invalidar cache:

- Após user fazer review no app (update local)
- Após X tentativas de refresh
- Manualmente (pull-to-refresh)
- Periodicamente em background (WorkManager)

**Possíveis Soluções:**

```dart
// TTL strategy atual (básico)
class CachePolicy {
  static const assignments = Duration(hours: 24);
  static const levelProgression = Duration(hours: 24);
  static const reviewStatistics = Duration(hours: 1);
}

// Strategy avançado (futuro)
class SmartCacheStrategy {
  Duration getTTL(String endpoint, {DateTime? lastModified}) {
    // Se usuário acabou de fazer review, TTL curto
    if (endpoint == 'review_statistics' && _hasRecentActivity()) {
      return Duration(minutes: 5);
    }
    
    // Se dados não mudaram em 7 dias, TTL longo
    if (lastModified != null) {
      final age = DateTime.now().difference(lastModified);
      if (age.inDays > 7) {
        return Duration(days: 7); // Extender TTL
      }
    }
    
    return CachePolicy.fromEndpoint(endpoint);
  }
}
```

**Decisão Pendente:**

- Implementar smart caching ou manter TTL fixo?
- Adicionar "força refresh" em todas as telas?

---

### 4. Error Handling UX

**Desafio:**

Como apresentar erros ao usuário de forma útil:

- Network timeout vs. 500 server error (diferentes UX)
- Retry vs. fallback para cache
- Toast vs. Dialog vs. Error Screen
- Logging de erros para analytics

**Possíveis Soluções:**

```dart
// Hierarquia de Error Entities
sealed class IError {
  String get message;
  ErrorSeverity get severity; // info, warning, error, critical
  ErrorRecovery get recovery; // retry, cache, ignore, fail
}

class NetworkErrorEntity extends IError {
  final DioException exception;
  
  @override
  ErrorRecovery get recovery {
    if (exception.type == DioExceptionType.connectionTimeout) {
      return ErrorRecovery.retry; // Mostrar botão retry
    }
    return ErrorRecovery.cache; // Usar cache
  }
}

class ApiErrorEntity extends IError {
  final int statusCode;
  
  @override
  ErrorRecovery get recovery {
    if (statusCode == 429) {
      return ErrorRecovery.retry; // Rate limit - aguardar
    }
    if (statusCode >= 500) {
      return ErrorRecovery.cache; // Server error - cache
    }
    return ErrorRecovery.fail; // Client error - mostrar erro
  }
}

// UI Error Handler
class ErrorHandler {
  static void handle(BuildContext context, IError error) {
    switch (error.recovery) {
      case ErrorRecovery.retry:
        _showRetrySnackbar(context, error);
      case ErrorRecovery.cache:
        _showCacheWarning(context);
      case ErrorRecovery.fail:
        _showErrorDialog(context, error);
      case ErrorRecovery.ignore:
        break;
    }
  }
}
```

**Decisão Pendente:**

- Criar ErrorHandler centralizado?
- Adicionar analytics/logging (Sentry, Firebase)?

---

### 5. Code Generation Build Time

**Desafio:**

Build runner é lento (especialmente Drift):

```bash
$ flutter pub run build_runner build
[INFO] Running build...
[INFO] 45.2s elapsed, 15/28 actions completed.
[INFO] 67.8s elapsed, 28/28 actions completed.
[INFO] Succeeded after 68.1s
```

**Possíveis Soluções:**

- Usar `--delete-conflicting-outputs` sempre
- Evitar regenerar tudo: `build_runner watch` em dev
- Excluir arquivos `.g.dart` do Git (já feito)
- Considerar alternatives ao Drift? (ObjectBox, Isar)

**Decisão Pendente:**

- Manter Drift (type-safe) ou migrar para Isar (mais rápido)?

---

### 6. Dependency Injection Scalability

**Desafio:**

GetIt com registros manuais cresce rápido:

```dart
void setupDependencies() {
  // Datasources
  getIt.registerLazySingleton(() => AssignmentDataSource(getIt()));
  getIt.registerLazySingleton(() => LevelProgressionDataSource(getIt()));
  getIt.registerLazySingleton(() => ReviewStatisticsDataSource(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<IAssignmentRepository>(
    () => AssignmentRepository(datasource: getIt()),
  );
  // ... 20+ linhas por feature
  
  // UseCases
  getIt.registerLazySingleton(() => GetAssignmentsUseCase(repository: getIt()));
  // ...
  
  // Cubits
  getIt.registerFactory(() => AssignmentsCubit(useCase: getIt()));
  // ...
}
```

**Possíveis Soluções:**

```dart
// Opção A: Auto registration com get_it_mixins
@Injectable()
class AssignmentDataSource { /* ... */ }

void main() {
  configureDependencies(); // Auto-generated
  runApp(MyApp());
}

// Opção B: Feature modules
class AssignmentModule {
  static void register(GetIt getIt) {
    getIt.registerLazySingleton(() => AssignmentDataSource(getIt()));
    getIt.registerLazySingleton<IAssignmentRepository>(
      () => AssignmentRepository(datasource: getIt()),
    );
    getIt.registerLazySingleton(() => GetAssignmentsUseCase(repository: getIt()));
    getIt.registerFactory(() => AssignmentsCubit(useCase: getIt()));
  }
}

void setupDependencies() {
  AssignmentModule.register(getIt);
  LevelProgressionModule.register(getIt);
  ReviewStatisticsModule.register(getIt);
}
```

**Decisão Pendente:**

- Adicionar `injectable` package + code gen?
- Manter manual com feature modules?

---

## 🚀 Roadmap de Melhorias

### Fase 1: MVP Funcional (4-6 semanas)

**Objetivo:** App funcional com features básicas

- [ ] Implementar autenticação (token storage)
- [ ] Dashboard com estatísticas básicas
- [ ] Lista de assignments por SRS stage
- [ ] Sincronização offline básica (cache + API)
- [ ] Error handling UX
- [ ] Tests unitários (>80% coverage)

### Fase 2: Polimento UX (2-3 semanas)

**Objetivo:** Melhorar experiência do usuário

- [ ] Dark mode
- [ ] Pull-to-refresh em todas as telas
- [ ] Skeleton loaders
- [ ] Animações de transição
- [ ] Empty states personalizados
- [ ] Feedback visual (haptics, toasts)

### Fase 3: Features Avançadas (3-4 semanas)

**Objetivo:** Recursos que diferenciam o app

- [ ] Widgets home screen (iOS 16+, Android 12+)
- [ ] Notificações de reviews disponíveis
- [ ] Gráficos de progresso (fl_chart)
- [ ] Export de estatísticas (CSV, PDF)
- [ ] Temas customizáveis (além de dark/light)
- [ ] Integração com Apple Watch / Wear OS

### Fase 4: Otimização (2-3 semanas)

**Objetivo:** Performance e qualidade

- [ ] Performance profiling (DevTools)
- [ ] Reduzir tamanho do APK/IPA
- [ ] CI/CD (GitHub Actions)
- [ ] Crashlytics / Analytics
- [ ] A/B testing de features
- [ ] Localization (i18n) - Japonês, Inglês

### Fase 5: Release (1-2 semanas)

**Objetivo:** Publicar nas stores

- [ ] App Store listing (screenshots, descrição)
- [ ] Play Store listing
- [ ] Beta testing (TestFlight, Internal Testing)
- [ ] Review de privacidade (GDPR, CCPA)
- [ ] Documentação de usuário
- [ ] Marketing/website

---

## 🔮 Visão de Longo Prazo (v2.0+)

### Features Exploratórias

- **Modo Offline Completo**: Sincronização bidirecional (fazer reviews offline)
- **Gamificação**: Badges, streaks, achievements
- **Social**: Comparar progresso com amigos
- **AI Assistant**: Sugestões de estudo personalizadas
- **Desktop App**: Flutter Windows/macOS/Linux
- **Web App**: Flutter Web (PWA)
- **Widgets Avançados**: Mini-games, flashcards rápidos
- **Voice Input**: Praticar pronúncia (speech-to-text)
- **AR Kanji**: Reconhecer kanji com câmera

### Decisões Arquiteturais Futuras

- Migrar para Riverpod? (state management mais moderno)
- Adicionar BFF (Backend-for-Frontend) próprio?
- Implementar GraphQL em vez de REST?
- Usar Firebase para features sociais?
- Multi-plataforma real (shared codebase com web/desktop)?

---

## 📝 Technical Debt Atual

### Alta Prioridade

1. **Features vazias** - Implementar esqueletos de data/domain/presentation
2. **Testes inexistentes** - Adicionar tests para camadas existentes (error, mixins)
3. **API não integrada** - Ainda 100% mock, precisa integrar API real
4. **DI não configurado** - GetIt não tem registros reais

### Média Prioridade

1. **Documentação de código** - Adicionar dartdoc comments
2. **CI/CD ausente** - Configurar GitHub Actions
3. **Logging básico** - Apenas debugPrint, precisa de logger estruturado
4. **Error handling incompleto** - Faltam recovery strategies

### Baixa Prioridade

1. **Código morto** - Remover imports não usados
2. **Magic numbers** - Extrair para constantes (TTL durations)
3. **Build warnings** - Resolver deprecations de packages

---

## 🎓 Lições Aprendidas (Para Futuros Projetos)

### O Que Funcionou Bem

- ✅ **Clean Architecture** - Separação clara facilita testes e manutenção
- ✅ **Documentação primeiro** - ADRs ajudam a tomar decisões conscientes
- ✅ **Linting rigoroso** - 80+ regras forçam código consistente
- ✅ **Tema japonês** - Diferencial visual alinhado com propósito do app
- ✅ **Mocks desde o início** - Permitiu desenvolvimento sem dependência de API

### O Que Pode Melhorar

- ⚠️ **Planejar DI antes** - GetIt manual é verboso, considerar injectable desde início
- ⚠️ **Drift overhead** - Build time alto, avaliar alternatives antes de commitar
- ⚠️ **Testing strategy** - Definir meta de coverage ANTES de codificar
- ⚠️ **Feature flags** - Adicionar desde MVP para controlar rollout

### O Que Evitar

- ❌ **God classes** - Manter Cubits focados em uma responsabilidade
- ❌ **Over-engineering** - Não criar abstrações até precisar (YAGNI)
- ❌ **Ignorar performance** - Profiling desde o início, não deixar para depois

---

## 📊 Métricas de Sucesso

### Qualidade de Código

| Métrica | Meta Atual | v1.0 | v2.0 |
|---------|------------|------|------|
| Test Coverage | >80% | >90% | >95% |
| Linting Errors | 0 | 0 | 0 |
| Code Smells (SonarQube) | - | <20 | <10 |
| Cyclomatic Complexity | - | <10 | <8 |

### Performance

| Métrica | Meta Atual | v1.0 | v2.0 |
|---------|------------|------|------|
| App Startup Time | - | <2s | <1.5s |
| Time to Interactive | - | <3s | <2s |
| Frame Drops (99th %ile) | - | <1% | <0.5% |
| Memory Usage (avg) | - | <100MB | <80MB |
| APK Size | - | <20MB | <15MB |

### Negócio

| Métrica | Meta Atual | v1.0 | v2.0 |
|---------|------------|------|------|
| App Store Rating | - | >4.5★ | >4.7★ |
| Daily Active Users | - | 100+ | 1000+ |
| Retention (Day 7) | - | >40% | >60% |
| Crash-free Rate | - | >99.5% | >99.9% |

---

**Última Revisão:** 11/10/2025  
**Próxima Revisão:** Após cada fase do roadmap
