# WaniKani API v2 - Especificação e Integração

> **Base URL:** `https://api.wanikani.com/v2`  
> **Documentação Oficial:** https://docs.api.wanikani.com/20170710/  
> **Versão API:** 2.0 (2017-07-10 revision)  
> **Última Atualização deste Doc:** 03/11/2025

---

## 🔐 Autenticação

### API Key (Bearer Token)

Toda requisição à API WaniKani requer autenticação via Bearer Token.

```dart
// Header obrigatório
Authorization: Bearer YOUR_API_KEY_HERE
```

### Obtenção do API Key

1. Usuário acessa https://www.wanikani.com/settings/personal_access_tokens
2. Gera novo token com permissões desejadas
3. Token é inserido no app (armazenado com flutter_secure_storage)

### Armazenamento Seguro

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final FlutterSecureStorage _storage;
  static const String _apiKeyKey = 'wanikani_api_key';

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
}
```

---

## 📡 Endpoints Utilizados

### 1. GET /assignments

**Propósito:** Retorna lista de assignments (items de estudo) do usuário.

**URL Completa:** `https://api.wanikani.com/v2/assignments`

**Recomendação de Cache:** **24 horas** (dados mudam pouco)

**Parâmetros Query (Opcionais):**

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `subject_types` | string | Filtrar por tipo: `radical`, `kanji`, `vocabulary` |
| `srs_stages` | string | Filtrar por SRS stage (1-9) |
| `available_after` | datetime | Assignments disponíveis após data |
| `available_before` | datetime | Assignments disponíveis antes de data |

**Exemplo de Request:**

```dart
final response = await dio.get(
  '/assignments',
  options: Options(
    headers: {'Authorization': 'Bearer $apiKey'},
  ),
  queryParameters: {
    'subject_types': 'kanji,vocabulary',
    'srs_stages': '5,6,7,8',
  },
);
```

**Exemplo de Response:**

```json
{
  "object": "collection",
  "url": "https://api.wanikani.com/v2/assignments",
  "pages": {
    "per_page": 500,
    "next_url": null,
    "previous_url": null
  },
  "total_count": 422,
  "data_updated_at": "2025-06-10T14:17:31.693587Z",
  "data": [
    {
      "id": 526070297,
      "object": "assignment",
      "url": "https://api.wanikani.com/v2/assignments/526070297",
      "data_updated_at": "2025-05-07T16:01:03.323735Z",
      "data": {
        "created_at": "2025-03-09T10:11:11.837344Z",
        "subject_id": 16,
        "subject_type": "radical",
        "srs_stage": 8,
        "unlocked_at": "2025-03-09T10:11:11.835272Z",
        "started_at": "2025-03-09T10:22:41.880267Z",
        "passed_at": "2025-03-13T16:34:41.509446Z",
        "burned_at": null,
        "available_at": "2025-09-04T15:00:00.000000Z",
        "resurrected_at": null,
        "hidden": false
      }
    }
  ]
}
```

**Campos Importantes:**

- `id`: ID único do assignment
- `subject_id`: ID do radical/kanji/vocabulário
- `subject_type`: `"radical"`, `"kanji"`, ou `"vocabulary"`
- `srs_stage`: Nível SRS (0-9)
  - 0: Initiate (locked)
  - 1-4: Apprentice
  - 5-6: Guru
  - 7: Master
  - 8: Enlightened
  - 9: Burned
- `available_at`: Quando próximo review está disponível
- `passed_at`: Quando usuário passou (guru+)
- `burned_at`: Quando foi "queimado" (completado)

---

### 2. GET /level_progressions

**Propósito:** Retorna progressão por níveis do WaniKani (1-60).

**URL Completa:** `https://api.wanikani.com/v2/level_progressions`

**Recomendação de Cache:** **24 horas**

**Exemplo de Response:**

```json
{
  "object": "collection",
  "url": "https://api.wanikani.com/v2/level_progressions",
  "total_count": 4,
  "data": [
    {
      "id": 3557312,
      "object": "level_progression",
      "data": {
        "created_at": "2025-03-09T10:11:11.814773Z",
        "level": 1,
        "unlocked_at": "2025-03-09T10:11:11.814388Z",
        "started_at": "2025-03-09T10:17:23.016685Z",
        "passed_at": "2025-04-10T15:21:50.960905Z",
        "completed_at": null,
        "abandoned_at": null
      }
    }
  ]
}
```

**Campos Importantes:**

- `level`: Nível do WaniKani (1-60)
- `unlocked_at`: Quando nível foi desbloqueado
- `started_at`: Quando primeiro lesson foi feito
- `passed_at`: Quando 90% dos kanji passaram guru
- `completed_at`: Quando burned
- `abandoned_at`: Se usuário resetou

---

### 3. GET /reviews

**Propósito:** Retorna lista de reviews (sessões de revisão) do usuário.

**URL Completa:** `https://api.wanikani.com/v2/reviews`

**Recomendação de Cache:** **1 hora** (muda frequentemente)

**Uso no Dashboard:** Pegar `total_count` para exibir número de reviews disponíveis.

**Parâmetros Query (Opcionais):**

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `subject_ids` | string | Filtrar por IDs de subjects |
| `updated_after` | datetime | Reviews atualizados após data |

**Exemplo de Request:**

```dart
final response = await dio.get(
  '/reviews',
  options: Options(
    headers: {'Authorization': 'Bearer $apiKey'},
  ),
);
```

**Exemplo de Response:**

```json
{
  "object": "collection",
  "url": "https://api.wanikani.com/v2/reviews",
  "pages": {
    "per_page": 1000,
    "next_url": null,
    "previous_url": null
  },
  "total_count": 127,
  "data_updated_at": "2025-10-19T03:45:36.251730Z",
  "data": [
    {
      "id": 487053453,
      "object": "review",
      "url": "https://api.wanikani.com/v2/reviews/487053453",
      "data_updated_at": "2025-04-16T13:24:55.258721Z",
      "data": {
        "created_at": "2025-04-16T13:24:55.258721Z",
        "assignment_id": 526070297,
        "spaced_repetition_system_id": 1,
        "subject_id": 16,
        "starting_srs_stage": 7,
        "ending_srs_stage": 8,
        "incorrect_meaning_answers": 0,
        "incorrect_reading_answers": 0
      }
    }
  ]
}
```

**Campos Importantes:**

- `total_count`: **USAR ESTE CAMPO** para contagem de reviews disponíveis no dashboard
- `assignment_id`: ID do assignment relacionado
- `subject_id`: ID do radical/kanji/vocabulário
- `starting_srs_stage`: SRS stage antes do review
- `ending_srs_stage`: SRS stage após o review
- `incorrect_meaning_answers`: Erros no significado
- `incorrect_reading_answers`: Erros na leitura

**⚠️ Importante para o Dashboard:**
- Não é necessário processar o array `data` para contar reviews
- Use apenas o campo `total_count` da resposta
- Muito mais eficiente que filtrar assignments por `available_at`

---

### 4. GET /study_materials

**Propósito:** Retorna materiais de estudo (notas, sinônimos) criados pelo usuário.

**URL Completa:** `https://api.wanikani.com/v2/study_materials`

**Recomendação de Cache:** **24 horas**

**Uso no Dashboard:** Pegar `total_count` para exibir número de lições (lessons) disponíveis.

**Parâmetros Query (Opcionais):**

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `subject_ids` | string | Filtrar por IDs de subjects |
| `subject_types` | string | Filtrar por tipo: `radical`, `kanji`, `vocabulary` |
| `updated_after` | datetime | Study materials atualizados após data |

**Exemplo de Request:**

```dart
final response = await dio.get(
  '/study_materials',
  options: Options(
    headers: {'Authorization': 'Bearer $apiKey'},
  ),
);
```

**Exemplo de Response:**

```json
{
  "object": "collection",
  "url": "https://api.wanikani.com/v2/study_materials",
  "pages": {
    "per_page": 500,
    "next_url": null,
    "previous_url": null
  },
  "total_count": 88,
  "data_updated_at": "2025-10-19T03:45:36.251730Z",
  "data": [
    {
      "id": 12345,
      "object": "study_material",
      "url": "https://api.wanikani.com/v2/study_materials/12345",
      "data_updated_at": "2025-10-19T03:45:36.251730Z",
      "data": {
        "created_at": "2025-03-09T10:17:23.012469Z",
        "subject_id": 1,
        "subject_type": "radical",
        "meaning_note": "Nota personalizada do usuário",
        "reading_note": "Dica de leitura",
        "meaning_synonyms": ["sinônimo1", "sinônimo2"],
        "hidden": false
      }
    }
  ]
}
```

**Campos Importantes:**

- `total_count`: **USAR ESTE CAMPO** para contagem de lições (lessons) disponíveis no dashboard
- `subject_id`: ID do radical/kanji/vocabulário
- `subject_type`: Tipo do subject
- `meaning_note`: Nota personalizada do usuário sobre o significado
- `reading_note`: Nota personalizada sobre a leitura
- `meaning_synonyms`: Sinônimos aceitos como corretos

**⚠️ Importante para o Dashboard:**
- Não é necessário processar o array `data` para contar lessons
- Use apenas o campo `total_count` da resposta
- Muito mais eficiente que filtrar assignments por `srs_stage == 0`

---

### 5. GET /review_statistics

**Propósito:** Estatísticas de reviews por subject (acertos, erros, streaks).

**URL Completa:** `https://api.wanikani.com/v2/review_statistics`

**Recomendação de Cache:** **1 hora** (muda frequentemente com reviews)

**Exemplo de Response:**

```json
{
  "object": "collection",
  "total_count": 393,
  "data": [
    {
      "id": 481608946,
      "object": "review_statistic",
      "data": {
        "created_at": "2025-03-09T10:17:23.012469Z",
        "subject_id": 1,
        "subject_type": "radical",
        "meaning_correct": 7,
        "meaning_incorrect": 0,
        "meaning_max_streak": 7,
        "meaning_current_streak": 7,
        "reading_correct": 7,
        "reading_incorrect": 0,
        "reading_max_streak": 7,
        "reading_current_streak": 7,
        "percentage_correct": 100,
        "hidden": false
      }
    }
  ]
}
```

**Campos Importantes:**

- `subject_id`: ID do radical/kanji/vocabulário
- `meaning_correct/incorrect`: Acertos/erros no significado
- `reading_correct/incorrect`: Acertos/erros na leitura
- `meaning_current_streak`: Streak atual de acertos
- `percentage_correct`: Porcentagem de acerto geral

---

## ⚙️ Rate Limiting

**Limites da API:**

- **60 requests por minuto** por API key
- Header de resposta inclui:
  - `RateLimit-Limit`: Limite total
  - `RateLimit-Remaining`: Requests restantes
  - `RateLimit-Reset`: Quando reseta (Unix timestamp)

**Estratégia de Handling:**

```dart
class RateLimitInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final remaining = response.headers.value('ratelimit-remaining');
    final reset = response.headers.value('ratelimit-reset');
    
    if (remaining != null && int.parse(remaining) < 5) {
      // Log warning - approaching rate limit
      debugPrint('⚠️ Rate limit warning: $remaining requests remaining');
    }
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 429) {
      final reset = err.response?.headers.value('ratelimit-reset');
      // Handle rate limit exceeded
      throw RateLimitExceededException(resetAt: reset);
    }
    super.onError(err, handler);
  }
}
```

---

## 📦 Estrutura de Resposta Padrão

Todas as respostas seguem este formato:

```json
{
  "object": "collection" | "radical" | "kanji" | "vocabulary" | "assignment" | ...,
  "url": "https://api.wanikani.com/v2/...",
  "data_updated_at": "2025-10-11T10:00:00.000000Z",
  "data": {...} | [...]
}
```

Para collections (lista de items):

```json
{
  "object": "collection",
  "url": "...",
  "pages": {
    "per_page": 500,
    "next_url": "..." | null,
    "previous_url": "..." | null
  },
  "total_count": 123,
  "data_updated_at": "...",
  "data": [...]
}
```

---

## 🚨 Error Handling

### Status Codes

| Código | Significado | Ação |
|--------|-------------|------|
| 200 | Success | Processar resposta normalmente |
| 304 | Not Modified | Usar cache (se enviou If-Modified-Since) |
| 401 | Unauthorized | API key inválida - logout usuário |
| 403 | Forbidden | Permissões insuficientes |
| 404 | Not Found | Resource não existe |
| 422 | Unprocessable Entity | Dados inválidos |
| 429 | Too Many Requests | Rate limit excedido - aguardar |
| 500 | Internal Server Error | Erro no servidor WaniKani - retry |
| 503 | Service Unavailable | Manutenção - retry com backoff |

### Formato de Erro

```json
{
  "error": "Unauthorized",
  "code": 401
}
```

### Handling no Repository

**⚠️ CRITICAL: DioException Handling Pattern**

**IMPORTANTE:** Dio **lança exceções** em status codes 4xx/5xx. Você DEVE usar try-catch com verificação explícita de `DioException`.

**❌ ERRADO - Crasheia em 401/429/500:**
```dart
Future<Either<IError, UserEntity>> getUser() async {
  final response = await _datasource.getUser();
  
  if (response.isSuccessful) {
    return Right(UserModel.fromJson(response.data['data']).entity);
  }
  
  // Nunca chega aqui em 4xx/5xx - Dio já lançou exceção
  return Left(ApiErrorEntity.fromJson(response.data));
}
```

**✅ CORRETO - Trata DioException explicitamente:**
```dart
@override
Future<Either<IError, UserEntity>> getUser() async {
  try {
    final Response<dynamic> response = await _datasource.getUser();

    if (response.isSuccessful) {
      return tryDecode<Either<IError, UserEntity>>(
        () => Right(UserModel.fromJson(response.data['data']).entity),
        orElse: (_) => Left(
          InternalErrorEntity(CoreStrings.errorUnknown),
        ),
      );
    }

    // Quando !isSuccessful MAS não lançou exceção (raro)
    return Left(ApiErrorEntity.fromJson(response.data));
  } on Exception catch (e) {
    // ⚠️ CRITICAL: Verificar DioException explicitamente
    if (e is DioException) {
      // Erro está em e.response?.data, NÃO no response original
      return Left(
        ApiErrorEntity.fromJson(e.response?.data ?? <String, dynamic>{}),
      );
    }

    // Outros erros (parsing, etc)
    return Left(InternalErrorEntity(e.toString()));
  }
}
```

**Por que esse padrão é mandatório:**

1. **Dio lança exceções em 4xx/5xx** - Sem try-catch, app crasheia
2. **Erro está em `e.response?.data`** - Não no response normal
3. **ApiErrorEntity.fromJson** espera formato WaniKani: `{"error": "...", "code": 401}`
4. **Sem `if (e is DioException)`** - App mostra "Unknown error" em vez da mensagem real

**Referência:**
- ✅ `lib/features/login/data/repositories/user_repository.dart` - Implementação CORRETA
- ❌ `lib/features/home/data/repositories/home_repository.dart` - NEEDS REFACTOR (4 métodos)

**Handling Específico por Status:**

```dart
on Exception catch (e) {
  if (e is DioException) {
    // 401 - Unauthorized (API key inválida)
    if (e.response?.statusCode == 401) {
      // TODO: Implementar AuthInterceptor global
      return Left(UnauthorizedErrorEntity('API key inválida'));
    }
    
    // 429 - Rate Limit
    if (e.response?.statusCode == 429) {
      final reset = e.response?.headers.value('ratelimit-reset');
      return Left(RateLimitErrorEntity(resetAt: reset));
    }
    
    // 500/503 - Server Error (retry recomendado)
    if (e.response?.statusCode == 500 || e.response?.statusCode == 503) {
      return Left(ServerErrorEntity('WaniKani server error - try again later'));
    }
    
    // Outros erros da API
    return Left(ApiErrorEntity.fromJson(e.response?.data ?? {}));
  }
  
  // Timeout errors
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Left(NetworkErrorEntity('Request timeout'));
    }
  }
  
  return Left(InternalErrorEntity(e.toString()));
}
```

**Retry Strategy com Exponential Backoff:**

Para 429 (Rate Limit) e 500/503 (Server Errors):

```dart
import 'dart:math';

class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryable = err.response?.statusCode == 429 ||
        err.response?.statusCode == 500 ||
        err.response?.statusCode == 503;

    if (retryable && (err.requestOptions.extra['retryCount'] ?? 0) < maxRetries) {
      final retryCount = (err.requestOptions.extra['retryCount'] ?? 0) + 1;
      final delay = initialDelay * pow(2, retryCount - 1); // Exponential

      debugPrint('⏳ Retrying request in ${delay.inSeconds}s (attempt $retryCount)');

      await Future.delayed(delay);

      err.requestOptions.extra['retryCount'] = retryCount;
      
      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
```

**Registrar no Dio:**
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.wanikani.com/v2',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
));

dio.interceptors.addAll([
  AuthInterceptor(),      // Adiciona Bearer token
  RetryInterceptor(),     // Retry automático em 429/500/503
  LoggingInterceptor(),   // Logs de debug
  MockInterceptor(),      // Mock mode (apenas em main_mock.dart)
]);
```

---

## 💾 Estratégia de Cache

### TTL por Endpoint

```dart
class CacheConfig {
  static const Duration assignmentsTTL = Duration(hours: 24);
  static const Duration levelProgressionsTTL = Duration(hours: 24);
  static const Duration reviewsTTL = Duration(hours: 1); // Muda frequentemente
  static const Duration studyMaterialsTTL = Duration(hours: 24);
  static const Duration reviewStatisticsTTL = Duration(hours: 1);
}
```

**⚠️ Nota sobre Dashboard:**
- Para o dashboard home, usar endpoints `/reviews` e `/study_materials` em vez de `/assignments`
- Muito mais eficiente: apenas ler `total_count` em vez de processar arrays grandes
- `/reviews` → total de reviews disponíveis
- `/study_materials` → total de lições (lessons) disponíveis

### Cache Headers (Conditional Requests)

```dart
// Se temos dado cacheado, enviar If-Modified-Since
final cachedAssignment = await dao.getById(id);
if (cachedAssignment != null) {
  final response = await dio.get(
    '/assignments/$id',
    options: Options(
      headers: {
        'If-Modified-Since': cachedAssignment.dataUpdatedAt.toUtc().toIso8601String(),
      },
    ),
  );
  
  if (response.statusCode == 304) {
    // Not modified - usar cache
    return Right(cachedAssignment);
  }
}
```

---

## 🧪 Mock Development

Para desenvolvimento sem atingir API real:

```dart
// lib/config/main_mock.dart
void main() {
  runApp(MyApp(
    environment: Environment.mock,
  ));
}

// Dio Mock Interceptor
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final mockPath = _getMockPath(options.path);
    final mockData = await rootBundle.loadString('assets/mock/$mockPath.json');
    
    handler.resolve(
      Response(
        requestOptions: options,
        data: jsonDecode(mockData),
        statusCode: 200,
      ),
    );
  }

  String _getMockPath(String path) {
    if (path.contains('/assignments')) return 'all_assignments';
    if (path.contains('/level_progressions')) return 'all_level_progression';
    if (path.contains('/reviews')) return 'all_reviews';
    if (path.contains('/study_materials')) return 'all_study_material';
    if (path.contains('/review_statistics')) return 'all_review_statistics';
    return 'unknown';
  }
}
```

---

## 📚 Referências

- [WaniKani API Documentation](https://docs.api.wanikani.com/)
- [API Getting Started](https://docs.api.wanikani.com/20170710/#getting-started)
- [Rate Limiting](https://docs.api.wanikani.com/20170710/#rate-limit)
- [Caching](https://docs.api.wanikani.com/20170710/#caching)

---

**Última Revisão:** 19/10/2025  
**Próxima Revisão:** Após testes de integração completos

**Changelog:**
- **19/10/2025**: Adicionados endpoints `/reviews` e `/study_materials` para dashboard
- **11/10/2025**: Versão inicial com `/assignments`, `/level_progressions`, `/review_statistics`
