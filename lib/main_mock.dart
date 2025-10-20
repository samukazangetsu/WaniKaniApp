import 'package:flutter/material.dart';
import 'package:wanikani_app/core/dependency_injection/dependency_injection.dart';
import 'package:wanikani_app/core/theme/theme.dart';
import 'package:wanikani_app/routing/app_router.dart';

/// Entrypoint da aplicação em modo MOCK.
///
/// Utiliza dados mockados de `assets/mock/` para desenvolvimento
/// sem necessidade de conexão com a API real da WaniKani.
///
/// Para executar:
/// ```
/// flutter run -t lib/main_mock.dart
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar dependências em modo mock
  setupDependencies(useMock: true);

  runApp(const WaniKaniAppMock());
}

/// Aplicação em modo mock.
class WaniKaniAppMock extends StatelessWidget {
  const WaniKaniAppMock({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'WaniKani App (Mock)',
    debugShowCheckedModeBanner: true, // Mostrar banner MOCK
    theme: WaniKaniTheme.lightTheme,
    darkTheme: WaniKaniTheme.darkTheme,
    routerConfig: AppRouter.router(),
  );
}
