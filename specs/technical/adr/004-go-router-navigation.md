# ADR-004: go_router para Navegação Declarativa

**Status:** Aceito  
**Data:** 11/10/2025  
**Decisores:** Samuel (samukazangetsu)  
**Tags:** #navegação #routing #go-router

---

## Contexto e Problema

O WaniKani App precisa de uma solução de navegação que:

1. **Seja type-safe** - rotas definidas de forma tipada (não strings mágicas)
2. **Suporte deep linking** - navegação direta para telas específicas
3. **Seja testável** - fácil testar fluxos de navegação
4. **Integre com estado** - navegação baseada em authentication state
5. **Seja declarativa** - rotas definidas de forma clara e centralizada

**Problema específico:** Navigator 1.0 tradicional é imperativo e não oferece type safety. Como ter rotas declarativas alinhadas com Clean Architecture?

---

## Decisão

Adotaremos **go_router** para navegação declarativa e type-safe.

### Configuração de Rotas

```dart
// lib/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  
  // Redirect para autenticação
  redirect: (BuildContext context, GoRouterState state) {
    final authState = context.read<AuthCubit>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == AppRoutes.login;

    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }
    
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.dashboard;
    }

    return null; // No redirect
  },

  routes: [
    // Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Authentication
    GoRoute(
      path: AppRoutes.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Main Shell with Bottom Navigation
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // Dashboard
        GoRoute(
          path: AppRoutes.dashboard,
          name: RouteNames.dashboard,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
          ),
        ),

        // Statistics
        GoRoute(
          path: AppRoutes.statistics,
          name: RouteNames.statistics,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const StatisticsScreen(),
          ),
        ),

        // Settings
        GoRoute(
          path: AppRoutes.settings,
          name: RouteNames.settings,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),

    // Assignment Detail (with parameter)
    GoRoute(
      path: '${AppRoutes.assignmentDetail}/:id',
      name: RouteNames.assignmentDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AssignmentDetailScreen(assignmentId: id);
      },
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);
```

### Definição de Rotas (Type-Safe)

```dart
// lib/routing/app_routes.dart
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String assignmentDetail = '/assignment';
}

class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String dashboard = 'dashboard';
  static const String statistics = 'statistics';
  static const String settings = 'settings';
  static const String assignmentDetail = 'assignmentDetail';
}
```

### Navegação Programática

```dart
// Navegação simples (por path)
context.go(AppRoutes.dashboard);

// Navegação com parâmetros (by name)
context.goNamed(
  RouteNames.assignmentDetail,
  pathParameters: {'id': '123'},
);

// Push (mantém na stack)
context.push(AppRoutes.statistics);

// Pop
context.pop();

// Replace
context.replace(AppRoutes.login);
```

### Shell Route para Bottom Navigation

```dart
// lib/presentation/widgets/main_shell.dart
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics),
          label: 'Estatísticas',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Configurações',
        ),
      ],
    ),
  );

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.statistics)) return 1;
    if (location.startsWith(AppRoutes.settings)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
      case 1:
        context.go(AppRoutes.statistics);
      case 2:
        context.go(AppRoutes.settings);
    }
  }
}
```

---

## Justificativa

### Por Que go_router?

1. **Declarativo e Type-Safe**
   - Rotas definidas centralmente
   - Parâmetros tipados
   - Compile-time errors para rotas inválidas

2. **Deep Linking Nativo**
   - URLs funcionam automaticamente
   - Suporte a web out-of-the-box
   - Mobile deep links fáceis de configurar

3. **Redirects e Guards**
   - Lógica de autenticação centralizada
   - Redirects automáticos baseados em estado
   - Proteção de rotas simples

4. **Nested Navigation**
   - ShellRoute para bottom navigation
   - Múltiplos navigators
   - Preservação de estado

5. **Testabilidade**
   - Mock de router em testes
   - Testar redirects facilmente
   - Verificar parâmetros de rota

6. **IA-Friendly**
   - Padrão claro e repetitivo
   - Fácil gerar novas rotas
   - Documentação estruturada

---

## Consequências

### Positivas ✅

1. **Navegação Type-Safe**
   - Erros de rota em compile-time
   - Autocomplete para nomes de rotas
   - Refactoring seguro

2. **Autenticação Simplificada**
   - Redirect automático para login
   - Proteção de rotas centralizada
   - Estado de auth integrado

3. **Deep Linking Gratuito**
   - URLs funcionam sem config extra
   - Compartilhamento de links
   - Navegação via notificações

4. **Manutenibilidade**
   - Rotas centralizadas
   - Fácil adicionar/remover rotas
   - Lógica de navegação isolada

### Negativas ⚠️

1. **Curva de Aprendizado**
   - Sintaxe diferente do Navigator tradicional
   - Conceito de ShellRoute pode confundir
   - **Mitigação:** Documentação (este ADR)

2. **Breaking Changes Frequentes**
   - go_router ainda evoluindo
   - Migrations entre versões
   - **Mitigação:** Lock version em pubspec

3. **Debug Mais Complexo**
   - Stack de navegação menos óbvio
   - Redirects podem confundir
   - **Mitigação:** `debugLogDiagnostics: true`

---

## Alternativas Consideradas

### 1. Navigator 1.0 (Tradicional)

**Prós:**
- Nativo do Flutter
- Simples para casos básicos
- Familiar

**Contras:**
- ❌ Imperativo (push/pop manual)
- ❌ Sem type safety
- ❌ Deep linking difícil
- ❌ Estado de navegação complexo

**Decisão:** Rejeitado - muito limitado

### 2. Navigator 2.0 (Raw)

**Prós:**
- Declarativo
- Deep linking suportado
- Controle total

**Contras:**
- ❌ Muito boilerplate
- ❌ Complexo de implementar
- ❌ Difícil manter
- ❌ IA tem dificuldade

**Decisão:** Rejeitado - go_router abstrai complexidade

### 3. auto_route

**Prós:**
- Type-safe com code generation
- Bom suporte a nested routes
- Popular

**Contras:**
- ❌ Code generation obrigatório
- ❌ Sintaxe mais verbosa
- ❌ Menos atualizado que go_router

**Decisão:** Rejeitado - go_router é oficial Flutter

### 4. beamer

**Prós:**
- Declarativo
- Bom para web

**Contras:**
- ❌ Menos popular
- ❌ Documentação inferior
- ❌ Ecosystem menor

**Decisão:** Rejeitado - go_router tem melhor suporte

---

## Padrões e Convenções

### Estrutura de Arquivos

```
lib/
└── routing/
    ├── app_router.dart          # Configuração principal
    ├── app_routes.dart          # Constantes de rotas
    └── route_guards.dart        # Lógica de autenticação (futuro)
```

### Nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Path Constant | `/lowercase-dash` | `/assignment-detail` |
| Name Constant | `camelCase` | `assignmentDetail` |
| Screen | `<Name>Screen` | `DashboardScreen` |

### Convenções de Navegação

```dart
// ✅ BOM - usar context extensions
context.go(AppRoutes.dashboard);
context.goNamed(RouteNames.statistics);

// ❌ EVITAR - Navigator tradicional (quebra deep linking)
Navigator.of(context).push(MaterialPageRoute(...));

// ✅ BOM - usar constantes
context.go(AppRoutes.dashboard);

// ❌ EVITAR - strings hardcoded
context.go('/dashboard');
```

---

## Validação e Compliance

### Checklist para Nova Rota

- [ ] Path definido em `AppRoutes`
- [ ] Name definido em `RouteNames`
- [ ] Route adicionada em `app_router.dart`
- [ ] Parâmetros tipados (se houver)
- [ ] Redirect logic considerada (se protegida)
- [ ] Transition apropriada (NoTransition para tabs)
- [ ] Error handling configurado

### Exemplo de Teste

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('should navigate to assignment detail', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/assignment/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AssignmentDetailScreen(assignmentId: int.parse(id));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Navegar programaticamente
    router.go('/assignment/123');
    await tester.pumpAndSettle();

    // Verificar tela carregada
    expect(find.byType(AssignmentDetailScreen), findsOneWidget);
  });
}
```

---

## Deep Linking Setup

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="wanikani-app.com"
        android:pathPrefix="/" />
</intent-filter>
```

### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wanikaniapp</string>
        </array>
    </dict>
</array>
```

---

## Referências

- [go_router Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation 2.0](https://docs.flutter.dev/ui/navigation)
- [Deep Linking Guide](https://docs.flutter.dev/ui/navigation/deep-linking)

---

**Última Revisão:** 11/10/2025  
**Próxima Revisão:** Após implementação de todas rotas principais
