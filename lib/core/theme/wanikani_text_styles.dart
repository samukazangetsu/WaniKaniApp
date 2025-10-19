import 'package:flutter/material.dart';
import 'package:wanikani_app/core/theme/wanikani_colors.dart';

/// Estilos de texto padronizados para o app WaniKani.
///
/// Utiliza Noto Sans JP para suporte completo ao japonês
/// com hierarquia clara e boa legibilidade.
class WaniKaniTextStyles {
  // Private constructor para prevenir instanciação
  WaniKaniTextStyles._();

  /// Nome da família de fonte primária
  static const String _fontFamily = 'Noto Sans JP';

  // ===== HEADERS =====

  /// H1 - Título principal
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: WaniKaniColors.primary,
    height: 1.2,
  );

  /// H2 - Subtítulo
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// H3 - Título de seção
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ===== BODY TEXT =====

  /// Texto do corpo - regular
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Texto do corpo - medium
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// Texto pequeno/caption
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: WaniKaniColors.secondary,
    height: 1.4,
  );

  // ===== COMPONENTES ESPECÍFICOS =====

  /// Título de cards
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: WaniKaniColors.secondary,
    height: 1.2,
  );

  /// Valor principal em cards de métrica
  static const TextStyle cardValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.1,
  );

  /// Valor grande (nível atual)
  static const TextStyle levelValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// Estilo para títulos de AppBar
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: WaniKaniColors.onPrimary,
    height: 1.2,
  );

  /// Estilo para botões primários
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Estilo para botões secundários
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // ===== MÉTODOS UTILITÁRIOS =====

  /// Aplica cor específica mantendo outras propriedades
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Aplica cor baseada no tipo de subject
  static TextStyle withSubjectColor(TextStyle style, String subjectType) {
    final color = WaniKaniColors.getSubjectTypeColor(subjectType);
    return style.copyWith(color: color);
  }

  /// Aplica cor baseada no nível SRS
  static TextStyle withSrsColor(TextStyle style, int srsStage) {
    final color = WaniKaniColors.getSrsColor(srsStage);
    return style.copyWith(color: color);
  }
}
