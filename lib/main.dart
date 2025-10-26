import 'package:flutter/material.dart';
import 'package:wanikani_app/core/dependency_injection/dependency_injection.dart';
import 'package:wanikani_app/core/theme/theme.dart';
import 'package:wanikani_app/routing/app_router.dart';

/// Entrypoint da aplicação em modo PRODUÇÃO.
///
/// Conecta com a API real da WaniKani usando token de autenticação.
///
/// Fluxo de inicialização:
/// 1. Configurar dependências
/// 2. Iniciar na tela de loading que verifica token salvo
/// 3. Loading redireciona para /login ou /home conforme necessário
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
    theme: WaniKaniTheme.lightTheme,
    darkTheme: WaniKaniTheme.darkTheme,
    routerConfig: AppRouter.router(),
  );
}
