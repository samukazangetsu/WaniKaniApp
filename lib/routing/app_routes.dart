/// Rotas da aplicação.
///
/// Enum type-safe para centralizar todas as rotas e evitar strings mágicas.
/// Facilita refatoração e fornece autocomplete no IDE.
///
/// Exemplo de uso:
/// ```dart
/// GoRoute(
///   path: AppRoutes.home.path,
///   name: AppRoutes.home.name,
///   builder: (context, state) => HomeScreen(),
/// )
/// ```
enum AppRoutes {
  /// Tela de loading - verificação inicial de token.
  loading('/'),

  /// Tela de login - autenticação com token API.
  login('/login'),

  /// Home/Dashboard - tela principal após login.
  home('/home');

  // [FUTURAS - Preparadas para expansão]
  // /// Tela de reviews.
  // reviews('/reviews'),
  //
  // /// Tela de lessons.
  // lessons('/lessons'),
  //
  // /// Tela de configurações.
  // settings('/settings'),
  //
  // /// Detalhes de um nível específico.
  // levelDetails('/level/:id'),

  const AppRoutes(this.path);

  /// Caminho da rota usado pelo go_router.
  final String path;
}
