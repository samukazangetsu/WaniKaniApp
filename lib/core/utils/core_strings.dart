/// Strings centralizadas da camada core.
///
/// Contém textos genéricos compartilhados entre features.
/// Preparado para internacionalização (i18n) futura.
///
/// Para strings específicas de uma feature, use o arquivo
/// de strings da própria feature (ex: `home_strings.dart`).
class CoreStrings {
  // Mensagens de Erro Genéricas

  /// Mensagem de erro desconhecido/genérico.
  ///
  /// Usado quando não há informação específica sobre o erro.
  static const String errorUnknown = 'Erro desconhecido';

  /// Mensagem quando não há dados disponíveis.
  static const String errorNoData = 'Nenhum dado disponível';

  /// Mensagem quando falha comunicação com API.
  static const String errorApiFailure = 'Falha na comunicação com o servidor';

  /// Mensagem quando não há conexão com internet.
  static const String errorNoConnection = 'Sem conexão com a internet';

  // Labels de Ações Comuns

  /// Botão para tentar novamente após erro.
  static const String actionRetry = 'Tentar Novamente';

  /// Botão para confirmar ação.
  static const String actionConfirm = 'Confirmar';

  /// Botão para cancelar ação.
  static const String actionCancel = 'Cancelar';

  /// Botão para fechar.
  static const String actionClose = 'Fechar';

  // Estados

  /// Texto exibido durante carregamento.
  static const String stateLoading = 'Carregando...';

  /// Texto quando não há itens.
  static const String stateEmpty = 'Nenhum item encontrado';
}
