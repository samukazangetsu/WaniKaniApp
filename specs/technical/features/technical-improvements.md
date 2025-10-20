# Melhorias Técnicas - Infraestrutura e Qualidade de Código

## POR QUE

### 1. Camada de Log para Requisições
- **Debugging eficiente**: Eliminar necessidade de breakpoints para inspecionar requisições/respostas
- **Rastreabilidade**: Facilitar identificação de problemas em chamadas de API
- **Diferenciação de ambientes**: Identificar rapidamente quando está em modo MOCK vs produção

### 2. Extensão Response do Dio
- **DRY (Don't Repeat Yourself)**: Eliminar validação repetitiva de `statusCode == 200` em todos os repositories
- **Manutenibilidade**: Centralizar lógica de validação de sucesso em um único lugar
- **Facilidade de mudança**: Caso seja necessário ajustar critério de sucesso (ex: aceitar 201, 204), alterar em apenas um local

### 3. Refatoração de Strings Hardcoded
- **Internacionalização**: Preparar estrutura para suporte multi-idioma no futuro
- **Manutenção**: Facilitar atualização de textos sem procurar strings espalhadas
- **Consistência**: Garantir uso de terminologia uniforme em todo o app
- **Testabilidade**: Facilitar testes de UI com strings centralizadas

### 4. Atualização do README
- **Transparência**: Documentar natureza do projeto (desenvolvido com IA)
- **Onboarding**: Fornecer descrição clara para novos colaboradores ou usuários
- **Profissionalismo**: Substituir README genérico por conteúdo específico do projeto

### 5. Arquivo Centralizado de Rotas
- **Type safety**: Usar enums para evitar typos em strings de rotas
- **Manutenção**: Facilitar refatoração e renomeação de rotas
- **Documentação implícita**: Ter visão centralizada de todas as rotas do app
- **IDE support**: Autocomplete e navegação via Ctrl+Click

### 6. Reorganização da Injeção de Dependências
- **Clareza**: Nome `dependency_injection` mais descritivo que `service_locator`
- **Escalabilidade**: Separação por feature facilita crescimento do projeto
- **Organização**: Reduzir tamanho de arquivo único, melhorar navegabilidade
- **Responsabilidade única**: Cada arquivo DI gerencia dependências de sua feature

### 7. Aplicar DecodeModelMixin nos Repositories
- **Error handling consistente**: Logging automático de erros de parsing
- **Reuso de código**: Mixin já testado e usado em projetos Banese
- **Segurança**: Tratamento robusto de exceções durante conversão de modelos
- **Debugging**: FlutterError.reportError registra erros automaticamente

---

## O QUE

### 1. Camada de Log para Requisições
**Criar:**
- `lib/core/network/interceptors/logging_interceptor.dart`
  - Implementar `Interceptor` do Dio
  - Métodos: `onRequest`, `onResponse`, `onError`
  - Log formatado e colorido (opcional: usar package `logger`)
  - Indicador visual para modo MOCK (ex: prefixo "[🔷 MOCK]")

**Informações a logar:**
- **Request**: URL completa, método HTTP, headers, body (se existir)
- **Response**: URL, statusCode, body completo
- **Error**: URL, tipo de erro, mensagem

**Modificar:**
- `lib/core/dependency_injection/core_di.dart` (após renomeação)
  - Adicionar `LoggingInterceptor` ao Dio em ambos os modos (mock e produção)
  - Ordem: LoggingInterceptor → MockInterceptor (se mock)

### 2. Extensão Response do Dio
**Criar:**
- `lib/core/network/extensions/response_extension.dart`
  ```dart
  extension ResponseExtension on Response {
    bool get isSuccessful => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  }
  ```

**Modificar:**
- `lib/features/home/data/repositories/home_repository.dart`
  - Substituir `if (response.statusCode == 200)` por `if (response.isSuccessful)`
  - Aplicar em todos os 4 métodos:
    - `getCurrentLevelProgression()`
    - `getAssignments()`
    - `getReviewStats()`
    - `getLessonStats()`

### 3. Refatoração de Strings Hardcoded
**Modificar:**
- `lib/features/home/utils/home_strings.dart`
  - Adicionar constantes para TODAS as strings hardcoded encontradas:
    - `errorUnknown` (já existe)
    - `errorNoLevelProgression` → 'Nenhuma progressão de nível encontrada'
    - `errorApiFailure` → Mensagem genérica de falha de API
    - Adicionar comentários JSDoc para i18n futura

**Refatorar em:**
- `lib/features/home/data/repositories/home_repository.dart`
  - Substituir `'Erro desconhecido'` por `HomeStrings.errorUnknown`
  - Substituir `'Nenhuma progressão de nível encontrada'` por `HomeStrings.errorNoLevelProgression`
  - Importar `home_strings.dart`

- `lib/routing/app_router.dart`
  - Substituir `'Erro: ${state.error}'` por string centralizada (criar `CoreStrings` se necessário)

- **Outros arquivos** com strings hardcoded (verificar com grep):
  - Cubits
  - Screens/Widgets
  - Models (se houver mensagens de erro)

### 4. Atualização do README
**Modificar:**
- `README.md` (raiz do projeto)
  
**Conteúdo sugerido:**
```markdown
# WaniKani App

Um cliente alternativo para o [WaniKani](https://www.wanikani.com/), plataforma de aprendizado de japonês baseada em Spaced Repetition System (SRS).

## 🤖 Desenvolvido com IA

Este projeto é desenvolvido 100% com auxílio de Inteligência Artificial, utilizando:
- GitHub Copilot
- Claude (Anthropic)
- Cursor/Windsurf

## 📚 Documentação

Para informações técnicas completas, consulte:
- [Documentação Técnica](specs/technical/index.md)
- [Guia de Contribuição](specs/technical/CONTRIBUTING.md)
- [Decisões Arquiteturais](specs/technical/adr/)

## 🚀 Stack Tecnológica

- **Framework**: Flutter 3.x
- **Arquitetura**: Clean Architecture + BLoC (Cubit)
- **Offline-first**: Drift (SQLite)
- **State Management**: flutter_bloc
- **Navegação**: go_router
```

### 5. Arquivo Centralizado de Rotas
**Criar:**
- `lib/routing/app_routes.dart`
  ```dart
  /// Rotas da aplicação.
  ///
  /// Centraliza todas as rotas para facilitar manutenção e evitar strings mágicas.
  enum AppRoutes {
    /// Rota inicial - Home/Dashboard
    home('/');

    const AppRoutes(this.path);
    
    /// Caminho da rota
    final String path;
  }
  ```

**Modificar:**
- `lib/routing/app_router.dart`
  - Importar `app_routes.dart`
  - Substituir `'/'` por `AppRoutes.home.path`
  - Atualizar `initialLocation` e `path` do GoRoute

### 6. Reorganização da Injeção de Dependências
**Renomear/Mover:**
- `lib/core/di/` → `lib/core/dependency_injection/`
- `service_locator.dart` → `dependency_injection.dart`

**Criar estrutura modular:**
```
lib/core/dependency_injection/
├── dependency_injection.dart      # Orquestrador principal
├── core_di.dart                   # Dio, interceptors, network
└── home_di.dart                   # Feature Home (datasources, repos, usecases, cubits)
```

**Implementar:**
- `core_di.dart`: Registrar Dio e interceptors (mock + logging)
- `home_di.dart`: Registrar toda cadeia de dependências da feature Home
- `dependency_injection.dart`: 
  - Função `setupDependencies({required bool useMock})`
  - Chamar `setupCoreDependencies()` e `setupHomeDependencies()`
  - Manter `resetDependencies()` para testes

**Atualizar imports em:**
- `main.dart`
- `main_mock.dart`
- `app_router.dart`
- Qualquer outro arquivo que importe `service_locator.dart`

### 7. Aplicar DecodeModelMixin nos Repositories
**Modificar:**
- `lib/features/home/data/repositories/home_repository.dart`
  - Adicionar `with DecodeModelMixin` na declaração da classe
  - Importar `package:wanikani_app/core/mixins/decode_model_mixin.dart`
  - Wrappear todas as conversões de modelo com `tryDecode<T>()`

**Exemplo de aplicação:**
```dart
// ANTES
final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
final List<AssignmentEntity> assignments = data
    .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
    .toList();

// DEPOIS
return tryDecode<Either<IError, List<AssignmentEntity>>>(
  () {
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    final List<AssignmentEntity> assignments = data
        .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return Right(assignments);
  },
  orElse: (_) => Left(InternalErrorEntity(HomeStrings.errorUnknown)),
);
```

**Aplicar em todos os métodos:**
- `getCurrentLevelProgression()`
- `getAssignments()`
- `getReviewStats()`
- `getLessonStats()`

---

## COMO

### Ordem de Implementação Recomendada

**Fase 1 - Fundação (não quebra código existente):**
1. ✅ Criar `LoggingInterceptor`
2. ✅ Criar `ResponseExtension`
3. ✅ Criar `AppRoutes` enum
4. ✅ Atualizar `README.md`

**Fase 2 - Reorganização (requer updates de imports):**
5. ✅ Renomear e modularizar Dependency Injection
   - Criar novos arquivos (`core_di.dart`, `home_di.dart`)
   - Migrar código
   - Atualizar imports
   - Deletar arquivo antigo

**Fase 3 - Refatoração (modificações em arquivos existentes):**
6. ✅ Adicionar novas strings em `HomeStrings`
7. ✅ Aplicar `DecodeModelMixin` em `HomeRepository`
8. ✅ Substituir `statusCode == 200` por `isSuccessful`
9. ✅ Substituir strings hardcoded por constantes
10. ✅ Atualizar `AppRouter` para usar `AppRoutes` enum

### Detalhes Técnicos

#### LoggingInterceptor
- **Formatação**: Usar emojis/cores para distinguir Request/Response/Error
- **Condicional**: Incluir flag `[MOCK]` quando `MockInterceptor` estiver ativo
- **Performance**: Logs apenas em modo debug (usar `kDebugMode`)
- **Pretty print**: Formatar JSON com indentação para legibilidade

#### ResponseExtension
- **Range de sucesso**: 200-299 (padrão HTTP)
- **Null safety**: Validar `statusCode != null`
- **Localização**: `lib/core/network/extensions/` (criar pasta se não existir)

#### Strings para i18n
- **Estrutura**: Preparar para uso com `flutter_localizations`
- **Nomenclatura**: `<feature><Context><Type>` (ex: `homeErrorUnknown`)
- **Documentação**: JSDoc indicando onde cada string é usada

#### Modularização DI
- **Isolamento**: Cada feature gerencia suas próprias dependências
- **Ordem**: Core DI primeiro (Dio), depois features (dependem do Dio)
- **Testabilidade**: Facilitar mock de dependências por feature

#### DecodeModelMixin
- **Try-catch**: Mixin já encapsula lógica de try-catch
- **Logging**: `FlutterError.reportError` registra stacktrace completo
- **Fallback**: Sempre fornecer `orElse` retornando `Left(InternalErrorEntity)`

### Testes Necessários

- ✅ Testar `LoggingInterceptor` com requests mock e real
- ✅ Validar `ResponseExtension` com diferentes statusCodes (200, 201, 404, 500)
- ✅ Verificar navegação usando `AppRoutes` enum
- ✅ Confirmar que todas as strings estão centralizadas
- ✅ Testar `DecodeModelMixin` com JSON inválido (deve logar erro)
- ✅ Validar que DI modular funciona corretamente

### Checklist de Validação

- [ ] Logs aparecem corretamente no console com formatação adequada
- [ ] Indicador [MOCK] aparece quando em modo mock
- [ ] `isSuccessful` funciona para statusCodes 200-299
- [ ] Nenhuma string hardcoded permanece em UI/business logic
- [ ] README está atualizado e profissional
- [ ] Rotas funcionam via `AppRoutes` enum
- [ ] DI modular não quebra inicialização do app
- [ ] `DecodeModelMixin` loga erros automaticamente
- [ ] Todos os imports foram atualizados corretamente
- [ ] Testes unitários continuam passando

---

## Referências

- [ADR-001: Clean Architecture](../adr/001-clean-architecture.md)
- [CODEBASE_GUIDE.md](../CODEBASE_GUIDE.md)
- [CLAUDE.meta.md](../CLAUDE.meta.md) - Padrões de código
- [Dio Interceptors](https://pub.dev/packages/dio#interceptors)
- [Extension Methods](https://dart.dev/guides/language/extension-methods)
