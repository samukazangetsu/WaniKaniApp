/// Strings centralizadas da feature Login.
///
/// Todas as strings visíveis ao usuário devem estar aqui
/// para facilitar manutenção e futura internacionalização (i18n).
class LoginStrings {
  // === LoginScreen ===

  /// Saudação em japonês (おかえり = "Bem-vindo de volta").
  static const String greetingWelcomeBack = 'おかえり';

  /// Subtítulo da tela de login.
  static const String loginSubtitle =
      'Por favor, insira seu token de API do WaniKani';

  /// Texto do botão de login.
  static const String loginButton = 'Fazer login';

  /// Link para tutorial.
  static const String tutorialLink = 'Onde consigo meu token?';

  // === TokenTextField ===

  /// Label do campo de token.
  static const String tokenFieldLabel = 'Token de API';

  /// Hint do campo de token.
  static const String tokenFieldHint = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';

  /// Tooltip do botão de mostrar token.
  static const String showTokenTooltip = 'Mostrar token';

  /// Tooltip do botão de ocultar token.
  static const String hideTokenTooltip = 'Ocultar token';

  // === TutorialBottomSheet ===

  /// Título do tutorial.
  static const String tutorialTitle = 'Como conseguir um token do WaniKani?';

  /// Passo 1 do tutorial.
  static const String tutorialStep1 =
      'Para conseguir um token de API do WaniKani, você deverá primeiro '
      'criar uma conta no site WaniKani, caso não tenha.';

  /// Passo 2 do tutorial.
  static const String tutorialStep2 =
      'Após o login, entre no seu perfil pelo seu ícone de usuário, clique '
      'em "API Tokens", caso não possua nenhum token ativo, gere um novo '
      'token com todas as permissões e copie o token.';

  /// Botão para abrir WaniKani.
  static const String tutorialOpenWaniKani = 'Fazer login no WaniKani';

  /// Botão para fechar tutorial.
  static const String tutorialClose = 'Voltar para a tela de login';

  // === SplashScreen ===

  /// Título do app na tela de splash.
  static const String loadingAppTitle = 'WaniKani';

  /// Subtítulo em japonês na tela de splash.
  static const String loadingSubtitle = '日本語を学ぼう';

  /// Mensagem de carregamento.
  static const String loadingMessage = 'Carregando...';

  // === Erros ===

  /// Erro ao abrir URL externa.
  static const String errorOpenUrl = 'Não foi possível abrir';
}
