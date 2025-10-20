/// Strings centralizadas da feature Home.
///
/// Todas as strings visíveis ao usuário devem estar aqui
/// para facilitar manutenção e futura internacionalização (i18n).
class HomeStrings {
  /// Título da AppBar.
  static const String appBarTitle = 'WaniKani';

  /// Saudação na AppBar (japonês: "Bem-vindo de volta").
  static const String greetingWelcomeBack = 'おかえり';

  /// Label do card de nível.
  static const String levelLabel = 'Nível';

  /// Label do card de reviews.
  static const String reviewsLabel = 'Reviews';

  /// Label do card de lições.
  static const String lessonsLabel = 'Lições';

  /// Título do diálogo de erro.
  static const String errorTitle = 'Erro';

  /// Mensagem genérica de erro.
  static const String errorMessage = 'Não foi possível carregar os dados';

  /// Mensagem de erro quando dashboard não carrega.
  static const String errorDashboardLoad =
      'Não foi possível carregar os dados do dashboard';

  /// Mensagem quando nenhuma progressão de nível foi encontrada.
  static const String errorNoLevelProgression =
      'Nenhuma progressão de nível encontrada';

  /// Botão para tentar novamente.
  static const String retryButton = 'Tentar Novamente';

  /// Mensagem exibida durante carregamento.
  static const String loadingMessage = 'Carregando...';

  /// Mensagem de erro desconhecido (usado no cubit).
  static const String unknownError = 'Erro desconhecido';

  /// Tooltip do botão de configurações.
  static const String settingsTooltip = 'Configurações';
}
