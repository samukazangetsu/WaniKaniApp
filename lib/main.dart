import 'package:flutter/material.dart';
import 'package:wanikani_app/core/di/service_locator.dart';
import 'package:wanikani_app/routing/app_router.dart';

/// Entrypoint da aplicação em modo PRODUÇÃO.
///
/// Conecta com a API real da WaniKani usando token de autenticação.
///
/// Para executar:
/// ```
/// flutter run
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar dependências em modo produção
  setupDependencies(useMock: false);

  runApp(const WaniKaniApp());
}

/// Aplicação em modo produção.
class WaniKaniApp extends StatelessWidget {
  const WaniKaniApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'WaniKani App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    routerConfig: AppRouter.router(),
  );
}
