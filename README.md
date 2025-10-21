# WaniKani App

Um cliente alternativo para o [WaniKani](https://www.wanikani.com/), plataforma de aprendizado de japonês baseada em Spaced Repetition System (SRS).

## 🤖 Desenvolvido com IA

Este projeto é desenvolvido 100% com auxílio de Inteligência Artificial, utilizando:
- **GitHub Copilot** para sugestões de código e autocompletar
- **Claude 4.5 Sonnet** (Anthropic) via API para arquitetura, refatorações e pair programming
- **VS Code** como IDE principal com extensões de IA integradas
- **Chat GPT-4** (OpenAI) para consultas pontuais e documentação

## 🎯 Objetivo

Criar um cliente mobile moderno e eficiente para acompanhamento de progresso no WaniKani, com foco em:
- ✅ **Offline-first**: Funciona sem internet usando cache local
- ✅ **Performance**: Interface fluida e responsiva
- ✅ **Design japonês**: Tipografia e cores culturalmente apropriadas
- ✅ **Clean Architecture**: Código manutenível e testável

## 📚 Documentação

Para informações técnicas completas, consulte:
- 📘 [Documentação Técnica](specs/technical/index.md) - Índice completo
- 🏛️ [Decisões Arquiteturais](specs/technical/adr/) - ADRs 001-005
- 🤖 [Guia de Desenvolvimento IA](specs/technical/CLAUDE.meta.md) - Padrões de código
- 🗺️ [Guia da Base de Código](specs/technical/CODEBASE_GUIDE.md) - Navegação
- 🎨 [Design System](specs/design/DESIGN_SYSTEM.md) - UI/UX Guidelines

## 🚀 Stack Tecnológica

- **Framework**: Flutter 3.x (Dart 3.8.0+)
- **Arquitetura**: Clean Architecture + BLoC (Cubit)
- **State Management**: flutter_bloc
- **Offline Cache**: Drift (SQLite type-safe)
- **Networking**: Dio + Interceptors customizados
- **Navegação**: go_router
- **Dependency Injection**: GetIt
- **Functional Programming**: Dartz (Either monad)
- **Logging**: Logger (logs estruturados)

## 🛠️ Setup e Execução

### Pré-requisitos
- Flutter SDK 3.8.0+
- Dart SDK 3.8.0+

### Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Rodar em modo MOCK (sem API real)
flutter run -t lib/main_mock.dart

# Rodar em modo PRODUÇÃO (API real - requer token)
flutter run

# Executar testes
flutter test

# Gerar código (Drift, JSON)
dart run build_runner build --delete-conflicting-outputs

# Verificar qualidade do código
flutter analyze
```

## 📱 Funcionalidades

### Implementadas
- ✅ Dashboard com nível atual, reviews e lessons
- ✅ Modo mock para desenvolvimento offline
- ✅ Logging estruturado de requisições/respostas

### Em Desenvolvimento
- 🚧 Sistema de reviews interativo
- 🚧 Sistema de lessons com progressão
- 🚧 Modo offline completo com sincronização

### Planejadas
- � Estatísticas detalhadas de progresso
- 📋 Gráficos de desempenho por tipo de item
- 📋 Sistema de notificações para reviews disponíveis
- � **Toggle de idioma**: Alternar entre japonês e idioma regional do sistema
- 📋 Temas personalizáveis (claro/escuro/automático)

## 📄 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

---

**Nota**: Este é um cliente não oficial. WaniKani é marca registrada da Tofugu LLC.
