# Guia de Solução de Problemas - WaniKani App

> **Última Atualização:** 02/11/2025  
> **Versão:** 1.0.0

---

## 🔥 Problemas Críticos

### 1. Erro: "Cannot emit new states after calling close"

**Sintoma:**
```
E/flutter: Unhandled Exception: Bad state: Cannot emit new states after calling close
E/flutter: #0 BlocBase.emit (package:bloc/src/bloc_base.dart:100:9)
E/flutter: #1 SplashCubit.checkSavedToken (splash_cubit.dart:48:7)
```

**Quando Ocorre:** Durante hot reload do app, específico do `SplashCubit.checkSavedToken()` linha 48

**Causa:** Hot reload descarta widgets antigos; Cubit é fechado mas operação assíncrona ainda tenta emitir estado

**Solução:**
```dart
Future<void> checkSavedToken() async {
  try {
    final token = await _storage.read(key: 'api_key');
    if (isClosed) return;  // ✅ Guard antes de emit
    
    if (token != null) {
      emit(SplashAuthenticated());
    } else {
      emit(SplashUnauthenticated());
    }
  } catch (e) {
    if (isClosed) return;
    emit(SplashError(message: e.toString()));
  }
}
```

**Workaround:** Fazer full restart (R) ao invés de hot reload (r)

**Status:** 🔄 Fix pendente

---

### 2. Erro 401 Não Tratado em Áreas Logadas

**Sintoma:** App não redireciona para login quando token expira após estar logado

**Quando Ocorre:** Requisições em Home, Reviews, etc. retornam 401 mas app não responde adequadamente

**Causa:** Erro 401 apenas tratado no LoginCubit, não há interceptor global

**Solução Planejada:**
```dart
// Interceptor Global
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.delete(key: 'api_key');
      _router.go('/login');
    }
    handler.next(err);
  }
}
```

**Status:** 🚧 Não implementado - Prioridade alta

---

### 3. DioException Não Tratada em Repositories Antigos

**Sintoma:** UnhandledException quando API retorna erro 4xx/5xx

**Causa:** Dio lança exception em erros HTTP mas catch não trata adequadamente

**Padrão OBRIGATÓRIO (já implementado em UserRepository):**
```dart
try {
  final response = await _datasource.getAssignments();
  
  if (response.isSuccessful) {
    return tryDecode<Either<IError, List<AssignmentEntity>>>(
      () {
        // Parsing logic
        return Right(assignments);
      },
      orElse: (_) => Left(InternalErrorEntity(CoreStrings.errorUnknown)),
    );
  }
  return Left(ApiErrorEntity.fromJson(response.data));
} on Exception catch (e) {
  if (e is DioException) {  // ✅ Tratar DioException
    return Left(ApiErrorEntity.fromJson(e.response?.data));
  }
  return Left(InternalErrorEntity(e.toString()));
}
```

**Repositories Pendentes de Fix:**
- ❌ HomeRepository.getReviewStats()
- ❌ HomeRepository.getLessonStats()
- ❌ HomeRepository.getAssignments()
- ❌ HomeRepository.getCurrentLevelProgression()

**Status:** 🚧 Refactoring pendente

---

## ⚠️ Problemas de Desenvolvimento

### 4. Build Runner Não Gera Arquivos

**Soluções:**
```bash
# Limpar e rebuild
flutter clean
dart run build_runner clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

### 5. Hot Reload Não Atualiza Models

**Causa:** Hot reload não regenera código de build_runner

**Solução:**
```bash
# Watch mode (recomendado)
dart run build_runner watch

# Ou rebuild manual + Hot Restart (R)
dart run build_runner build --delete-conflicting-outputs
```

---

### 6. VS Code Não Reconhece Imports

**Soluções:**
```
1. Ctrl+Shift+P → Developer: Reload Window
2. Ctrl+Shift+P → Dart: Restart Analysis Server
3. flutter clean && flutter pub get
```

---

## 🌐 Problemas de Network

### 7. Timeout em Requisições

**Solução:** Configurar timeout do Dio
```dart
final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
));
```

---

### 8. Rate Limit (429 Too Many Requests)

**Causa:** WaniKani API limite de 60 req/min

**Status:** 🚧 Interceptor de retry não implementado

---

## 💾 Problemas de Dados

### 9. Dados Mock Não Aparecem

**Verificar:**
1. Arquivos JSON existem em `assets/mock/`
2. Assets declarados em pubspec.yaml
3. `flutter clean` e rebuild

---

## 🎨 Problemas de UI

### 10. Fontes Não Carregam

**Verificar:**
1. Arquivos `.ttf` em `assets/fonts/`
2. Declaração correta em pubspec.yaml
3. `flutter clean` e rebuild

---

### 11. UI Não Atualiza Após Estado Mudar

**Causas Comuns:**
```dart
// ❌ Falta bloc parameter
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) => ...,
)

// ✅ CORRETO
BlocBuilder<HomeCubit, HomeState>(
  bloc: widget.cubit,
  builder: (context, state) => ...,
)

// ✅ Estado deve implementar props
@override
List<Object> get props => [assignments];
```

---

## 📋 Checklist Antes de Abrir Issue

- [ ] `flutter clean` e `flutter pub get`
- [ ] `flutter doctor` sem erros
- [ ] Flutter stable atualizado
- [ ] `flutter analyze` sem warnings
- [ ] `flutter test` passando
- [ ] Consultou este guia
- [ ] Buscou em issues do GitHub

---

## 🆘 Como Pedir Ajuda

**Abrir Issue com:**
- Título descritivo
- Passos para reproduzir
- Expected vs Actual
- Stack trace completa
- `flutter --version`
- Plataforma (Android/iOS)

---

> **Dica:** Adicione novos problemas e soluções aqui quando encontrá-los! 📝
