import 'package:flutter/material.dart';
import 'package:wanikani_app/core/theme/wanikani_colors.dart';
import 'package:wanikani_app/core/theme/wanikani_design.dart';
import 'package:wanikani_app/core/theme/wanikani_text_styles.dart';

/// Tema principal do app WaniKani.
///
/// Configura cores, tipografia e componentes para manter
/// consistência visual com o design system.
class WaniKaniTheme {
  // Private constructor para prevenir instanciação
  WaniKaniTheme._();

  /// Tema escuro do WaniKani (padrão)
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ===== ESQUEMA DE CORES =====
    colorScheme: const ColorScheme.dark(
      primary: WaniKaniColors.primary,
      onPrimary: WaniKaniColors.onPrimary,
      secondary: WaniKaniColors.secondary,
      onSecondary: WaniKaniColors.onSecondary,
      surface: WaniKaniColors.surface,
      onSurface: WaniKaniColors.textPrimary,
      error: WaniKaniColors.error,
      onError: Colors.white,
    ),

    // ===== TIPOGRAFIA =====
    fontFamily: 'Noto Sans JP',
    textTheme: const TextTheme(
      headlineLarge: WaniKaniTextStyles.h1,
      headlineMedium: WaniKaniTextStyles.h2,
      headlineSmall: WaniKaniTextStyles.h3,
      bodyLarge: WaniKaniTextStyles.body,
      bodyMedium: WaniKaniTextStyles.bodyMedium,
      bodySmall: WaniKaniTextStyles.caption,
      titleLarge: WaniKaniTextStyles.cardTitle,
      displayMedium: WaniKaniTextStyles.cardValue,
      displayLarge: WaniKaniTextStyles.levelValue,
    ),

    // ===== APP BAR =====
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: WaniKaniColors.background,
      foregroundColor: WaniKaniColors.textPrimary,
      titleTextStyle: WaniKaniTextStyles.appBarTitle,
      toolbarHeight: WaniKaniDesign.appBarHeight,
      iconTheme: IconThemeData(color: WaniKaniColors.textPrimary),
    ),

    // ===== CARDS =====
    cardTheme: CardThemeData(
      elevation: WaniKaniDesign.elevationMedium,
      color: WaniKaniColors.surface,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
      ),
      margin: const EdgeInsets.all(WaniKaniDesign.spacingSm),
    ),

    // ===== BOTÕES =====
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: WaniKaniDesign.elevationLow,
        backgroundColor: WaniKaniColors.primary,
        foregroundColor: WaniKaniColors.onPrimary,
        textStyle: WaniKaniTextStyles.buttonPrimary,
        minimumSize: const Size.fromHeight(WaniKaniDesign.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WaniKaniColors.primary,
        textStyle: WaniKaniTextStyles.buttonSecondary,
        minimumSize: const Size.fromHeight(WaniKaniDesign.buttonHeight),
        side: const BorderSide(color: WaniKaniColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: WaniKaniColors.primary,
        textStyle: WaniKaniTextStyles.buttonSecondary,
        minimumSize: const Size.fromHeight(WaniKaniDesign.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        ),
      ),
    ),

    // ===== INPUT FIELDS =====
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WaniKaniColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        borderSide: const BorderSide(color: WaniKaniColors.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        borderSide: const BorderSide(color: WaniKaniColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
        borderSide: const BorderSide(color: WaniKaniColors.error),
      ),
    ),

    // ===== DIALOG =====
    dialogTheme: DialogThemeData(
      elevation: WaniKaniDesign.elevationHigh,
      backgroundColor: WaniKaniColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WaniKaniDesign.radiusLarge),
      ),
    ),

    // ===== BOTTOM SHEET =====
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: WaniKaniColors.surface,
      elevation: WaniKaniDesign.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WaniKaniDesign.radiusLarge),
        ),
      ),
    ),

    // ===== SCAFFOLD =====
    scaffoldBackgroundColor: WaniKaniColors.background,
  );

  /// Tema escuro do WaniKani (para futuro)
  // TODO: Implementar tema escuro quando necessário
  static ThemeData get darkTheme =>
      lightTheme.copyWith(brightness: Brightness.dark);
}
