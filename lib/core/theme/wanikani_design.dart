/// Constantes de design para manter consistência visual.
///
/// Define espaçamentos, bordas, elevações e outras propriedades
/// visuais padronizadas do design system WaniKani.
class WaniKaniDesign {
  // Private constructor para prevenir instanciação
  WaniKaniDesign._();

  // ===== ESPAÇAMENTOS =====

  /// Extra pequeno - 4dp
  static const double spacingXs = 4.0;

  /// Pequeno - 8dp
  static const double spacingSm = 8.0;

  /// Médio - 16dp (padrão)
  static const double spacingMd = 16.0;

  /// Grande - 24dp
  static const double spacingLg = 24.0;

  /// Extra grande - 32dp
  static const double spacingXl = 32.0;

  /// Extra extra grande - 48dp
  static const double spacingXxl = 48.0;

  // ===== BORDAS E RAIOS =====

  /// Raio pequeno para elementos sutis
  static const double radiusSmall = 8.0;

  /// Raio padrão para cards e botões
  static const double radiusMedium = 12.0;

  /// Raio grande para elementos destacados
  static const double radiusLarge = 16.0;

  /// Raio extra grande para modais
  static const double radiusXLarge = 24.0;

  // ===== ELEVAÇÕES =====

  /// Elevação sutil (1dp)
  static const double elevationSubtle = 1.0;

  /// Elevação baixa para cards (2dp)
  static const double elevationLow = 2.0;

  /// Elevação média para cards destacados (4dp)
  static const double elevationMedium = 4.0;

  /// Elevação alta para modais (8dp)
  static const double elevationHigh = 8.0;

  /// Elevação da AppBar (2dp)
  static const double elevationAppBar = 2.0;

  // ===== TAMANHOS DE COMPONENTES =====

  /// Altura padrão de botões
  static const double buttonHeight = 48.0;

  /// Altura pequena de botões
  static const double buttonHeightSmall = 32.0;

  /// Altura da AppBar
  static const double appBarHeight = 56.0;

  /// Tamanho de ícones pequenos
  static const double iconSizeSmall = 16.0;

  /// Tamanho padrão de ícones
  static const double iconSizeMedium = 24.0;

  /// Tamanho de ícones grandes
  static const double iconSizeLarge = 32.0;

  /// Tamanho de ícones em cards de métrica
  static const double iconSizeMetric = 48.0;

  // ===== DIMENSÕES DE CARDS =====

  /// Altura mínima de cards
  static const double cardMinHeight = 120.0;

  /// Altura do card de nível atual
  static const double levelCardHeight = 140.0;

  /// Altura dos cards de métrica (lessons/reviews)
  static const double metricCardHeight = 100.0;

  // ===== ANIMAÇÕES =====

  /// Duração rápida para micro-interações
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Duração normal para transições
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Duração lenta para animações complexas
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ===== BREAKPOINTS RESPONSIVOS =====

  /// Largura mínima para tablet
  static const double tabletBreakpoint = 768.0;

  /// Largura mínima para desktop
  static const double desktopBreakpoint = 1024.0;

  /// Largura máxima do conteúdo
  static const double maxContentWidth = 1200.0;

  // ===== GRID E LAYOUT =====

  /// Quantidade de colunas no grid móvel
  static const int mobileGridColumns = 2;

  /// Quantidade de colunas no grid tablet
  static const int tabletGridColumns = 3;

  /// Quantidade de colunas no grid desktop
  static const int desktopGridColumns = 4;

  /// Espaçamento entre itens do grid
  static const double gridSpacing = spacingMd;

  /// Aspect ratio dos cards de métrica
  static const double metricCardAspectRatio = 1.5;
}
