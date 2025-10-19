import 'package:flutter/material.dart';

/// Paleta de cores baseada no design system do WaniKani.
///
/// Mantém consistência visual com a aplicação original,
/// incluindo cores específicas para diferentes tipos de conteúdo.
class WaniKaniColors {
  // Private constructor para prevenir instanciação
  WaniKaniColors._();

  // ===== CORES PRINCIPAIS DO WANIKANI =====

  /// Azul vibrante - Cor dos radicais
  static const Color radical = Color(0xFF00AAFF);

  /// Rosa/Magenta - Cor dos kanjis
  static const Color kanji = Color(0xFFFF00AA);

  /// Roxo - Cor do vocabulário
  static const Color vocabulary = Color(0xFF9900FF);

  // ===== CORES DE NÍVEL SRS =====

  /// Rosa escuro - Nível Apprentice (1-4)
  static const Color apprentice = Color(0xFFDD0093);

  /// Roxo - Nível Guru (5-6)
  static const Color guru = Color(0xFF882D9E);

  /// Azul - Nível Master (7)
  static const Color master = Color(0xFF294DDB);

  /// Azul claro - Nível Enlightened (8)
  static const Color enlightened = Color(0xFF0093DD);

  /// Cinza escuro - Nível Burned (9)
  static const Color burned = Color(0xFF434343);

  // ===== CORES DE INTERFACE (DARK THEME) =====

  /// Cor de fundo principal - Preto quase puro
  static const Color background = Color(0xFF0f0f0f);

  /// Cor de superfície (cards, dialogs) - Cinza escuro
  static const Color surface = Color(0xFF232323);

  /// Cor primária do app (rosa/vermelho WaniKani)
  static const Color primary = Color(0xFFff0066);

  /// Cor do texto sobre primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Cor secundária (textos auxiliares) - Cinza claro
  static const Color secondary = Color(0xFF9ca3af);

  /// Cor do texto sobre secondary
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Cor para textos principais - Branco
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Cor para ícones de fundo - Cinza médio escuro
  static const Color iconBackground = Color(0xFF3d3d3d);

  // ===== CORES DE ESTADO =====

  /// Verde - Sucessos e confirmações
  static const Color success = Color(0xFF28A745);

  /// Amarelo - Avisos e alertas
  static const Color warning = Color(0xFFFFC107);

  /// Vermelho - Erros e falhas
  static const Color error = Color(0xFFDC3545);

  // ===== CORES ESPECÍFICAS PARA PROGRESS =====

  /// Cor da barra de progresso preenchida - Rosa/vermelho
  static const Color progressFilled = Color(0xFFff0066);

  /// Cor da barra de progresso não preenchida - Cinza escuro
  static const Color progressUnfilled = Color(0xFF3a3a3a);

  // ===== MÉTODOS UTILITÁRIOS =====

  /// Retorna a cor apropriada baseada no nível SRS.
  static Color getSrsColor(int srsStage) => switch (srsStage) {
    1 || 2 || 3 || 4 => apprentice,
    5 || 6 => guru,
    7 => master,
    8 => enlightened,
    9 => burned,
    _ => secondary,
  };

  /// Retorna a cor do tipo de subject (radical, kanji, vocabulário).
  static Color getSubjectTypeColor(String subjectType) =>
      switch (subjectType.toLowerCase()) {
        'radical' => radical,
        'kanji' => kanji,
        'vocabulary' => vocabulary,
        _ => secondary,
      };
}
