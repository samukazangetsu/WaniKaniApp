# ADR-003: Drift para Cache Offline-First

**Status:** Aceito  
**Data:** 11/10/2025  
**Decisores:** Samuel (samukazangetsu)  
**Tags:** #persistência #offline #cache #drift #sqlite

---

## Contexto e Problema

O WaniKani App precisa funcionar offline e cachear dados da API para:

1. **Performance** - evitar requisições desnecessárias à API
2. **Offline-first** - funcionar sem internet após primeira sincronização
3. **UX** - dados disponíveis instantaneamente (sem loading)
4. **API Guidelines** - WaniKani recomenda cache de 24h para certos endpoints
5. **Rate Limiting** - evitar atingir limites de requisições

**Problema específico:** Qual solução de persistência local oferece melhor balance entre performance, type safety e facilidade de uso com Clean Architecture?

---

## Decisão

Adotaremos **Drift** (antes Moor) como solução de persistência local com SQLite.

### Arquitetura de Cache

```dart
// Camadas de dados
API (WaniKani) ↔ Datasource ↔ Repository ↔ Cache (Drift)
                      ↓
                 Use Cases
                      ↓
                   Cubit/UI
```

### Exemplo de Implementação

#### 1. Definição de Tabelas (Drift)

```dart
// lib/features/assignments/data/local/assignment_table.dart
import 'package:drift/drift.dart';

@DataClassName('AssignmentDB')
class Assignments extends Table {
  IntColumn get id => integer()();
  IntColumn get subjectId => integer()();
  TextColumn get subjectType => text()();
  IntColumn get srsStage => integer()();
  DateTimeColumn get availableAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()(); // Para TTL
  
  @override
  Set<Column> get primaryKey => {id};
}
```

#### 2. Database Class

```dart
// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(tables: [Assignments, LevelProgressions, ReviewStatistics])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'wanikani_app.db'));
      return NativeDatabase(file);
    });
  }
}
```

#### 3. DAO (Data Access Object)

```dart
// lib/features/assignments/data/local/assignment_dao.dart
import 'package:drift/drift.dart';

part 'assignment_dao.g.dart';

@DriftAccessor(tables: [Assignments])
class AssignmentDao extends DatabaseAccessor<AppDatabase> with _$AssignmentDaoMixin {
  AssignmentDao(AppDatabase db) : super(db);

  // Buscar todos assignments cacheados
  Future<List<AssignmentDB>> getAllAssignments() => select(assignments).get();

  // Buscar com filtro
  Future<List<AssignmentDB>> getAssignmentsByType(String type) =>
      (select(assignments)..where((a) => a.subjectType.equals(type))).get();

  // Inserir ou atualizar (upsert)
  Future<void> upsertAssignment(AssignmentDB assignment) =>
      into(assignments).insertOnConflictUpdate(assignment);

  // Inserir múltiplos
  Future<void> upsertAll(List<AssignmentDB> assignmentList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(assignments, assignmentList);
    });
  }

  // Deletar assignments expirados (cache TTL)
  Future<int> deleteExpired(Duration ttl) {
    final expiryTime = DateTime.now().subtract(ttl);
    return (delete(assignments)
          ..where((a) => a.cachedAt.isSmallerThanValue(expiryTime)))
        .go();
  }

  // Limpar todos
  Future<void> clearAll() => delete(assignments).go();

  // Stream para reatividade
  Stream<List<AssignmentDB>> watchAllAssignments() => select(assignments).watch();
}
```

#### 4. Repository com Cache Strategy

```dart
// lib/features/assignments/data/repositories/assignment_repository.dart
class AssignmentRepository implements IAssignmentRepository {
  final WaniKaniDatasource _remoteDatasource;
  final AssignmentDao _localDatasource;
  final Duration _cacheTTL = const Duration(hours: 24);

  @override
  Future<Either<IError, List<AssignmentEntity>>> getAssignments({
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Limpar cache expirado
      await _localDatasource.deleteExpired(_cacheTTL);

      // 2. Verificar cache local (se não forçar refresh)
      if (!forceRefresh) {
        final cached = await _localDatasource.getAllAssignments();
        if (cached.isNotEmpty) {
          return Right(cached.map(_dbToEntity).toList());
        }
      }

      // 3. Buscar da API
      final response = await _remoteDatasource.getAssignments();

      if (response.isSuccessful) {
        final assignments = (response.data['data'] as List)
            .map((json) => AssignmentModel.fromJson(json).entity)
            .toList();

        // 4. Cachear localmente
        await _localDatasource.upsertAll(
          assignments.map(_entityToDb).toList(),
        );

        return Right(assignments);
      }

      return Left(ApiErrorEntity.fromResponse(response));
    } catch (e) {
      // Se offline, retornar cache mesmo se expirado
      final cached = await _localDatasource.getAllAssignments();
      if (cached.isNotEmpty) {
        return Right(cached.map(_dbToEntity).toList());
      }
      
      return Left(InternalErrorEntity('Erro ao buscar assignments: $e'));
    }
  }

  AssignmentEntity _dbToEntity(AssignmentDB db) => AssignmentEntity(
        id: db.id,
        subjectId: db.subjectId,
        subjectType: db.subjectType,
        srsStage: db.srsStage,
        availableAt: db.availableAt,
      );

  AssignmentDB _entityToDb(AssignmentEntity entity) => AssignmentDB(
        id: entity.id,
        subjectId: entity.subjectId,
        subjectType: entity.subjectType,
        srsStage: entity.srsStage,
        availableAt: entity.availableAt,
        cachedAt: DateTime.now(),
      );
}
```

---

## Justificativa

### Por Que Drift?

1. **Type Safety Total**
   - Queries type-safe em compile-time
   - Autocomplete completo para colunas
   - Erros detectados antes de runtime

2. **Reactive Streams**
   - Integração perfeita com BLoC (streams)
   - UI atualiza automaticamente com `watch()`
   - Performance otimizada (rebuild seletivo)

3. **Code Generation Inteligente**
   - DAOs gerados automaticamente
   - Boilerplate minimizado
   - Migrations automáticas

4. **Performance Excelente**
   - SQLite nativo
   - Queries otimizadas
   - Batch operations eficientes

5. **Multiplataforma**
   - Android, iOS, Desktop, Web
   - Mesmo código para todas plataformas
   - Isolate support para queries pesadas

6. **Clean Architecture Friendly**
   - DAOs atuam como datasources
   - Entities separadas de DB models
   - Fácil mockar para testes

---

## Estratégia de Cache TTL

### TTL por Endpoint (Recomendação WaniKani)

| Endpoint | TTL | Justificativa |
|----------|-----|---------------|
| `/assignments` | 24 horas | Muda pouco (apenas com reviews) |
| `/level_progressions` | 24 horas | Muda apenas ao passar de nível |
| `/review_statistics` | 1 hora | Muda após cada review |

### Implementação de TTL

```dart
class CacheConfig {
  static const Duration assignmentsTTL = Duration(hours: 24);
  static const Duration levelProgressionTTL = Duration(hours: 24);
  static const Duration reviewStatisticsTTL = Duration(hours: 1);
}

// No Repository
Future<Either<IError, List<T>>> _getCached<T>({
  required Future<List<T>> Function() fetchFromApi,
  required Future<List<T>> Function() fetchFromCache,
  required Future<void> Function(List<T>) saveToCache,
  required Future<int> Function(Duration) deleteExpired,
  required Duration ttl,
  bool forceRefresh = false,
}) async {
  await deleteExpired(ttl);
  
  if (!forceRefresh) {
    final cached = await fetchFromCache();
    if (cached.isNotEmpty) return Right(cached);
  }
  
  try {
    final fresh = await fetchFromApi();
    await saveToCache(fresh);
    return Right(fresh);
  } catch (e) {
    final cached = await fetchFromCache();
    return cached.isNotEmpty
        ? Right(cached)
        : Left(InternalErrorEntity(e.toString()));
  }
}
```

---

## Consequências

### Positivas ✅

1. **Offline-First Funcional**
   - App funciona completamente offline
   - Sincronização transparente
   - Dados sempre disponíveis

2. **Performance Excelente**
   - Startup < 1s (dados cacheados)
   - Sem loading screens desnecessários
   - Scroll suave (dados locais)

3. **Type Safety**
   - Erros de schema em compile-time
   - Refactoring seguro
   - Autocomplete perfeito

4. **Testabilidade**
   - DAOs facilmente mockáveis
   - Testes com in-memory database
   - Sem dependência de API em testes

5. **Migrations Automáticos**
   - Schema evolution gerenciado
   - Versionamento automático
   - Sem SQL manual

### Negativas ⚠️

1. **Code Generation Obrigatório**
   - Build runner necessário
   - Tempo de build aumenta
   - **Mitigação:** `flutter packages pub run build_runner watch`

2. **Curva de Aprendizado**
   - Sintaxe específica do Drift
   - Conceito de DAOs
   - **Mitigação:** Documentação e exemplos (este ADR)

3. **Tamanho do App**
   - SQLite embarcado aumenta APK/IPA
   - ~2-3MB adicionais
   - **Mitigação:** Aceitável para benefícios

---

## Alternativas Consideradas

### 1. Hive (NoSQL Key-Value)

**Prós:**
- Muito rápido
- Sem code generation (com TypeAdapters simples)
- Pequeno tamanho

**Contras:**
- ❌ Sem queries complexas (only get/put)
- ❌ Sem relações entre dados
- ❌ Difícil implementar TTL
- ❌ Sem type safety em queries

**Decisão:** Rejeitado - insufficient query capabilities

### 2. SharedPreferences + JSON

**Prós:**
- Muito simples
- Nativo do Flutter
- Zero setup

**Contras:**
- ❌ Não escala (apenas para configs pequenas)
- ❌ Sem queries
- ❌ Performance ruim com dados grandes
- ❌ Sem type safety

**Decisão:** Rejeitado - inadequado para volume de dados

### 3. ObjectBox

**Prós:**
- Performance excepcional
- Type-safe queries
- Relações entre objetos

**Contras:**
- ❌ Menos maduro que Drift
- ❌ Ecosystem menor
- ❌ Sintaxe proprietária
- ❌ IA menos familiarizada

**Decisão:** Rejeitado - Drift tem melhor suporte

### 4. sqflite (SQLite Raw)

**Prós:**
- Controle total
- Sem code generation
- Popular

**Contras:**
- ❌ Sem type safety (raw SQL strings)
- ❌ Muito boilerplate
- ❌ Erros apenas em runtime
- ❌ Difícil manter

**Decisão:** Rejeitado - Drift oferece type safety

---

## Padrões e Convenções

### Estrutura de Arquivos

```
lib/
├── core/
│   └── database/
│       ├── app_database.dart       # Database principal
│       └── app_database.g.dart     # Generated
│
└── features/
    └── assignments/
        └── data/
            └── local/
                ├── assignment_table.dart   # Table definition
                ├── assignment_dao.dart     # Data Access Object
                └── assignment_dao.g.dart   # Generated
```

### Nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Table Class | `<Plural>` | `Assignments` |
| DB Model | `<Singular>DB` | `AssignmentDB` |
| DAO | `<Singular>Dao` | `AssignmentDao` |
| Database | `AppDatabase` | - |

### Build Runner Commands

```bash
# Gerar código uma vez
flutter pub run build_runner build

# Watch mode (recomendado durante desenvolvimento)
flutter pub run build_runner watch

# Limpar e regenerar
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Estratégia de Migration

### Schema Version 1 (Inicial)

```dart
@override
int get schemaVersion => 1;
```

### Futuras Migrations

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration v1 → v2
          await m.addColumn(assignments, assignments.newColumn);
        }
        if (from < 3) {
          // Migration v2 → v3
          await m.createTable(newTable);
        }
      },
    );
```

---

## Validação e Compliance

### Checklist para Nova Tabela

- [ ] Table class extends `Table`
- [ ] Primary key definida
- [ ] Coluna `cachedAt` para TTL
- [ ] DAO criado com queries necessárias
- [ ] Upsert implementado (insert or update)
- [ ] Método de limpeza por TTL
- [ ] Stream para reatividade (`watch()`)
- [ ] Code generation executado (`build_runner`)

### Exemplo de Teste com In-Memory DB

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late AssignmentDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = AssignmentDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('should insert and retrieve assignment', () async {
    final assignment = AssignmentDB(
      id: 1,
      subjectId: 100,
      subjectType: 'kanji',
      srsStage: 5,
      cachedAt: DateTime.now(),
    );

    await dao.upsertAssignment(assignment);
    final result = await dao.getAllAssignments();

    expect(result, contains(assignment));
  });

  test('should delete expired assignments', () async {
    final old = AssignmentDB(
      id: 1,
      cachedAt: DateTime.now().subtract(Duration(days: 2)),
    );
    final fresh = AssignmentDB(
      id: 2,
      cachedAt: DateTime.now(),
    );

    await dao.upsertAll([old, fresh]);
    await dao.deleteExpired(Duration(hours: 24));
    final result = await dao.getAllAssignments();

    expect(result, hasLength(1));
    expect(result.first.id, 2);
  });
}
```

---

## Referências

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift Migration Guide](https://drift.simonbinder.eu/docs/advanced-features/migrations/)
- [SQLite Best Practices](https://www.sqlite.org/bestpractice.html)

---

**Última Revisão:** 11/10/2025  
**Próxima Revisão:** Após implementação completa de cache
