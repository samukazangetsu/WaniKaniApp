# Contexto - Melhorias Técnicas de Infraestrutura

**Feature Branch**: `feature/technical-improvements`  
**Data de Início**: 19 de Outubro de 2025  
**Tipo**: Refatoração Técnica (sem impacto visual/funcional ao usuário)

---

## 🎯 Por Que Estamos Construindo Isso?

### Problema Atual
O projeto está em fase inicial, mas já apresenta alguns padrões que podem ser melhorados:
- **Debugging ineficiente**: Necessidade de breakpoints para inspecionar requisições/respostas
- **Código repetitivo**: Validação `if (response.statusCode == 200)` em todos os repositories
- **Strings espalhadas**: Textos hardcoded dificultam manutenção e futura internacionalização
- **README genérico**: Ainda é o boilerplate padrão do Flutter
- **Strings mágicas**: Rotas definidas como strings literais sem type safety
- **DI monolítico**: Arquivo único `service_locator.dart` que vai crescer descontroladamente
- **Error handling inconsistente**: Parsing sem tratamento padronizado

### Objetivo da Refatoração
Estabelecer **fundações técnicas sólidas** antes que o projeto cresça:
- ✅ Melhorar observabilidade (logs estruturados)
- ✅ Reduzir código duplicado (extension methods, mixins)
- ✅ Preparar para internacionalização (strings centralizadas)
- ✅ Aumentar type safety (enums para rotas)
- ✅ Facilitar escalabilidade (DI modular por feature)
- ✅ Documentar adequadamente (README profissional)

---

## 📦 O Que Será Construído?

### 1. LoggingInterceptor com package `logger`
**Arquivo**: `lib/core/network/interceptors/logging_interceptor.dart`

**Funcionalidade**:
- Interceptor do Dio que loga todas as requisições e respostas
- Usar package `logger` para logs coloridos e estruturados
- Indicador visual `[🔷 MOCK]` quando em modo mock
- Logs apenas em modo debug (`kDebugMode`)

**Informações a logar**:
- **Request**: Método HTTP, URL completa, headers, body (se houver)
- **Response**: StatusCode, URL, body
- **Error**: Tipo de erro, mensagem, stacktrace

---

### 2. ResponseExtension
**Arquivo**: `lib/core/network/extensions/response_extension.dart`

**Funcionalidade**:
- Extension do `Response<dynamic>` do Dio
- Getter `isSuccessful` que valida `statusCode >= 200 && statusCode < 300`
- Elimina necessidade de validar `statusCode == 200` manualmente

**Uso**:
```dart
// ANTES
if (response.statusCode == 200) { ... }

// DEPOIS
if (response.isSuccessful) { ... }
```

---

### 3. Centralização de Strings (Estrutura em 2 Camadas)

#### Camada Core
**Arquivo**: `lib/core/utils/core_strings.dart`

**Conteúdo**:
- Strings genéricas compartilhadas entre features
- Mensagens de erro padrão
- Labels comuns (ex: "Carregando...", "Tentar Novamente")
- Preparado para i18n futura

#### Camada Feature
**Arquivo**: `lib/features/home/utils/home_strings.dart` (já existe, será expandido)

**Conteúdo**:
- Strings específicas da feature Home
- Títulos de tela
- Labels de cards
- Mensagens de erro específicas do contexto

**Migração**:
- Mapear TODAS as strings hardcoded no projeto
- Substituir por constantes nos arquivos de strings
- Atualizar imports

---

### 4. README Atualizado
**Arquivo**: `README.md` (raiz do projeto)

**Conteúdo**:
- Breve descrição: Cliente alternativo WaniKani
- Nota: "Desenvolvido 100% com auxílio de IA"
- Link para documentação em `specs/`
- Stack tecnológica resumida

---

### 5. AppRoutes Enum
**Arquivo**: `lib/routing/app_routes.dart`

**Funcionalidade**:
- Enum type-safe para todas as rotas do app
- Elimina strings mágicas como `'/'`, `'/home'`
- Facilita refatoração e autocomplete

**Estrutura**:
```dart
enum AppRoutes {
  home('/');
  
  const AppRoutes(this.path);
  final String path;
}
```

**Uso**:
```dart
// ANTES
GoRoute(path: '/', ...)

// DEPOIS
GoRoute(path: AppRoutes.home.path, ...)
```

---

### 6. DI Modular (Preparado para Features Futuras)

**Estrutura Nova**:
```
lib/core/dependency_injection/
├── dependency_injection.dart      # Orquestrador principal
├── core_di.dart                   # Dio, interceptors, network
└── features/
    └── home_di.dart               # Feature Home
    └── reviews_di.dart            # [FUTURO] Feature Reviews
    └── lessons_di.dart            # [FUTURO] Feature Lessons
```

**Migração**:
- Renomear: `lib/core/di/` → `lib/core/dependency_injection/`
- Deletar: `service_locator.dart`
- Criar: Arquivos modulares por responsabilidade
- Atualizar: Todos os imports no projeto

**Vantagens**:
- Cada feature gerencia suas próprias dependências
- Facilita adição de novas features
- Reduz tamanho de arquivos individuais
- Melhora navegabilidade do código

---

### 7. DecodeModelMixin em Repositories
**Arquivo**: `lib/features/home/data/repositories/home_repository.dart`

**Funcionalidade**:
- Adicionar `with DecodeModelMixin` na classe `HomeRepository`
- Wrappear **apenas parsing/conversão** (fromJson) com `tryDecode()`
- Log automático de erros via `FlutterError.reportError`
- Fallback para `Left(InternalErrorEntity)` em caso de exceção

**Aplicar em 4 métodos**:
- `getCurrentLevelProgression()`
- `getAssignments()`
- `getReviewStats()`
- `getLessonStats()`

**Escopo do tryDecode**: Apenas a conversão JSON → Entity, NÃO validações de negócio.

---

## 🛠️ Como Será Construído?

### Ordem de Implementação (3 Fases)

#### **Fase 1: Fundação** (Não quebra código existente)
1. ✅ Adicionar package `logger` ao `pubspec.yaml`
2. ✅ Criar `LoggingInterceptor` 
3. ✅ Criar `ResponseExtension`
4. ✅ Criar `AppRoutes` enum
5. ✅ Criar `CoreStrings` (novo arquivo)
6. ✅ Atualizar `README.md`

#### **Fase 2: Reorganização** (Requer updates de imports)
7. ✅ Criar estrutura modular de DI:
   - `core_di.dart`
   - `features/home_di.dart`
   - `dependency_injection.dart` (orquestrador)
8. ✅ Atualizar todos os imports:
   - `main.dart`
   - `main_mock.dart`
   - `app_router.dart`
9. ✅ Deletar `lib/core/di/service_locator.dart` (após migração completa)

#### **Fase 3: Refatoração** (Modificações em arquivos existentes)
10. ✅ Expandir `HomeStrings` com novas constantes
11. ✅ Adicionar `with DecodeModelMixin` em `HomeRepository`
12. ✅ Substituir `statusCode == 200` por `isSuccessful` (4 métodos)
13. ✅ Wrappear parsing com `tryDecode()` (4 métodos)
14. ✅ Substituir todas strings hardcoded por constantes
15. ✅ Atualizar `AppRouter` para usar `AppRoutes` enum

---

## 🧪 Como Será Testado?

### Critérios de Sucesso
- ✅ **Logs funcionando**: Request/Response aparecem no console formatados
- ✅ **Indicador [MOCK]**: Aparece quando `useMock: true`
- ✅ **isSuccessful correto**: Valida statusCodes 200-299
- ✅ **Sem strings hardcoded**: Grep não encontra strings literais em UI/logic
- ✅ **README atualizado**: Conteúdo profissional e específico do projeto
- ✅ **Rotas type-safe**: Navegação funciona via enum
- ✅ **DI modular funciona**: App inicializa sem erros
- ✅ **DecodeModelMixin loga erros**: Exceções aparecem no FlutterError
- ✅ **Testes existentes passam**: Nenhum teste quebrado

### Validação Manual
1. Rodar app em modo mock (`main_mock.dart`)
2. Verificar logs no console
3. Navegar entre telas (quando houver mais rotas)
4. Rodar testes: `flutter test`

---

## 📚 Dependências

### Novas Dependências
- **logger** (^2.0.0): Logging estruturado e colorido

### APIs/Ferramentas Utilizadas
- **Dio Interceptors**: Sistema de interceptação de requisições
- **Extension Methods**: Dart 3.0+ para estender classes
- **Enums**: Type-safe routing
- **Mixins**: Reuso de código com `DecodeModelMixin`

### Arquivos Afetados (Total: ~15 arquivos)

**Novos arquivos (7)**:
- `lib/core/network/interceptors/logging_interceptor.dart`
- `lib/core/network/extensions/response_extension.dart`
- `lib/routing/app_routes.dart`
- `lib/core/utils/core_strings.dart`
- `lib/core/dependency_injection/dependency_injection.dart`
- `lib/core/dependency_injection/core_di.dart`
- `lib/core/dependency_injection/features/home_di.dart`

**Modificados (8)**:
- `pubspec.yaml` (adicionar logger)
- `README.md` (novo conteúdo)
- `lib/features/home/utils/home_strings.dart` (expandir)
- `lib/features/home/data/repositories/home_repository.dart` (mixin + refactor)
- `lib/routing/app_router.dart` (usar AppRoutes)
- `main.dart` (atualizar import DI)
- `main_mock.dart` (atualizar import DI)

**Deletados (1)**:
- `lib/core/di/service_locator.dart` (após migração)

---

## 🚧 Restrições e Suposições

### Restrições
- ✅ **Zero mudanças visuais**: Nenhum impacto na UI
- ✅ **Zero mudanças comportamentais**: App funciona idêntico
- ✅ **Manter testes passando**: Não quebrar testes existentes
- ✅ **Seguir padrões existentes**: Clean Architecture, BLoC, Dartz

### Suposições
- ✅ Package `logger` é aceitável (aprovado pelo usuário)
- ✅ Estrutura em 2 camadas para strings é adequada
- ✅ Features futuras seguirão mesmo padrão de DI modular
- ✅ DecodeModelMixin já está testado (usado em projetos Banese)

---

## ✅ Resultado Esperado

Ao final desta issue, teremos:

1. **Observabilidade melhorada**: Logs claros de todas requisições/respostas
2. **Código mais limpo**: Menos repetição, mais reutilização
3. **Type safety aumentada**: Enums em vez de strings
4. **Preparado para i18n**: Strings centralizadas e estruturadas
5. **Escalabilidade facilitada**: DI modular por feature
6. **Documentação profissional**: README adequado ao projeto
7. **Error handling robusto**: Parsing seguro com logging automático

**Sem quebrar nada**: Todas funcionalidades continuam operando normalmente.

---

## 📎 Referências

- [Requisitos Completos](../../../specs/technical/features/technical-improvements.md)
- [ADR-001: Clean Architecture](../../../specs/technical/adr/001-clean-architecture.md)
- [CODEBASE_GUIDE.md](../../../specs/technical/CODEBASE_GUIDE.md)
- [Dio Interceptors Documentation](https://pub.dev/packages/dio#interceptors)
- [Logger Package](https://pub.dev/packages/logger)
- [Extension Methods - Dart](https://dart.dev/guides/language/extension-methods)
