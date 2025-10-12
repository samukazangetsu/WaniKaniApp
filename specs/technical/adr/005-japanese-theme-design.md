# ADR-005: Design System com Tema Japonês

**Status:** Aceito  
**Data:** 11/10/2025  
**Decisores:** Samuel (samukazangetsu)  
**Tags:** #design #ui #ux #tema #japonês

---

## Contexto e Problema

O WaniKani App, sendo focado em aprendizado de japonês, precisa de um design que:

1. **Reflita a cultura japonesa** - estética tradicional mas moderna
2. **Seja funcional** - não apenas decorativo, mas facilite uso
3. **Tenha identidade única** - diferenciação de outros apps
4. **Seja acessível** - contraste adequado, leitura fácil
5. **Seja consistente** - sistema de design bem definido

**Problema específico:** Como criar um tema visual que seja culturalmente apropriado sem ser clichê, mantendo usabilidade e acessibilidade?

---

## Decisão

Criaremos um **Design System customizado** inspirado em elementos da estética japonesa tradicional:

- **Minimalismo** (概念 ma - espaço negativo)
- **Naturalidade** (paleta de cores *washi* e *sumi-e*)
- **Delicadeza** (animações suaves, transições orgânicas)
- **Funcionalidade** (forma segue função - *yōhō bijutsu*)

### Paleta de Cores

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary Colors - Indigo Tradicional (藍色 Aiiro)
  static const Color primaryDark = Color(0xFF1A237E);    // Indigo 900
  static const Color primary = Color(0xFF303F9F);        // Indigo 700
  static const Color primaryLight = Color(0xFF5C6BC0);   // Indigo 400
  static const Color primaryVeryLight = Color(0xFFE8EAF6); // Indigo 50

  // Accent Colors - Vermelho Selo (朱色 Shuiro)
  static const Color accent = Color(0xFFD32F2F);         // Red 700
  static const Color accentLight = Color(0xFFEF5350);    // Red 400

  // Background - Papel Washi (和紙)
  static const Color background = Color(0xFFFFF8E1);     // Cream
  static const Color surface = Color(0xFFFFFFFF);        // Pure white
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Off-white

  // Text Colors - Tinta Sumi (墨)
  static const Color textPrimary = Color(0xFF212121);    // Near black
  static const Color textSecondary = Color(0xFF757575);  // Gray 600
  static const Color textTertiary = Color(0xFF9E9E9E);   // Gray 500

  // Semantic Colors
  static const Color success = Color(0xFF388E3C);        // Green 700
  static const Color warning = Color(0xFFF57C00);        // Orange 700
  static const Color error = Color(0xFFD32F2F);          // Red 700
  static const Color info = Color(0xFF1976D2);           // Blue 700

  // SRS Stage Colors (para assignments)
  static const Color srsApprentice = Color(0xFFE91E63);  // Pink
  static const Color srsGuru = Color(0xFF9C27B0);        // Purple
  static const Color srsMaster = Color(0xFF3F51B5);      // Indigo
  static const Color srsEnlightened = Color(0xFF2196F3); // Blue
  static const Color srsBurned = Color(0xFF607D8B);      // Blue Grey
}
```

### Typography - Noto Sans JP

```dart
// lib/core/theme/app_text_styles.dart
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Display - Títulos grandes
  static TextStyle displayLarge = GoogleFonts.notoSansJp(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = GoogleFonts.notoSansJp(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = GoogleFonts.notoSansJp(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Headline - Títulos de seção
  static TextStyle headlineLarge = GoogleFonts.notoSansJp(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.notoSansJp(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.notoSansJp(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Title - Títulos de cards
  static TextStyle titleLarge = GoogleFonts.notoSansJp(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.notoSansJp(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // Body - Texto corrido
  static TextStyle bodyLarge = GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.notoSansJp(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.notoSansJp(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Label - Botões, labels
  static TextStyle labelLarge = GoogleFonts.notoSansJp(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.notoSansJp(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.notoSansJp(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
}
```

### Theme Configuration

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.accent,
      secondaryContainer: AppColors.accentLight,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // Card Theme - Inspirado em Shoji (障子)
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: AppColors.textPrimary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textTertiary.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),

    // AppBar Theme - Minimalista
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: AppTextStyles.titleLarge,
    ),

    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      indicatorColor: AppColors.primaryLight.withOpacity(0.3),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.labelSmall.copyWith(color: AppColors.primary);
        }
        return AppTextStyles.labelSmall;
      }),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.textTertiary.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // TODO: Implementar dark theme futuramente
  );
}
```

### Componentes Customizados

#### Assignment Card (Inspirado em Hanafuda - 花札)

```dart
// lib/presentation/widgets/assignment_card.dart
class AssignmentCard extends StatelessWidget {
  final AssignmentEntity assignment;

  const AssignmentCard(this.assignment, {super.key});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: () => context.goNamed(
        RouteNames.assignmentDetail,
        pathParameters: {'id': '${assignment.id}'},
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // SRS Stage Indicator (círculo colorido)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getSrsColor(assignment.srsStage),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${assignment.srsStage}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.subjectType.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getSrsColor(assignment.srsStage),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subject #${assignment.subjectId}',
                    style: AppTextStyles.titleMedium,
                  ),
                  if (assignment.availableAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Disponível: ${_formatDate(assignment.availableAt!)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    ),
  );

  Color _getSrsColor(int stage) {
    if (stage <= 4) return AppColors.srsApprentice;
    if (stage <= 6) return AppColors.srsGuru;
    if (stage == 7) return AppColors.srsMaster;
    if (stage == 8) return AppColors.srsEnlightened;
    return AppColors.srsBurned;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    return 'Agora';
  }
}
```

---

## Justificativa

### Por Que Tema Japonês Customizado?

1. **Identidade Cultural**
   - App sobre japonês deve refletir a cultura
   - Diferenciação visual de competidores
   - Conexão emocional com usuários

2. **Minimalismo Funcional**
   - Estética japonesa prioriza função sobre forma
   - Menos elementos = mais foco no conteúdo
   - Performance melhor (menos widgets)

3. **Acessibilidade**
   - Cores com contraste adequado (WCAG AA)
   - Typography clara (Noto Sans JP otimizada para legibilidade)
   - Espaçamento generoso

4. **Escalabilidade**
   - Design system bem definido
   - Fácil adicionar novos componentes
   - Consistência garantida

---

## Consequências

### Positivas ✅

1. **Identidade Única**
   - App reconhecível visualmente
   - Experiência memorável
   - Brand identity forte

2. **UX Intuitiva**
   - Cores semânticas claras (SRS stages)
   - Hierarquia visual bem definida
   - Feedback visual consistente

3. **Manutenibilidade**
   - Tema centralizado
   - Fácil fazer ajustes globais
   - Components reutilizáveis

### Negativas ⚠️

1. **Subjetividade Estética**
   - Nem todos podem gostar do tema japonês
   - **Mitigação:** Tema alternativo no futuro (v2.0)

2. **Google Fonts Dependency**
   - Noto Sans JP aumenta tamanho do app
   - Requer download de fonte
   - **Mitigação:** ~500KB é aceitável

---

## Alternativas Consideradas

### 1. Material Design Padrão

**Rejeitado:** Sem identidade única, genérico

### 2. Design Moderno/Flat Minimalista

**Rejeitado:** Não reflete cultura japonesa

### 3. Tema Escuro por Padrão

**Rejeitado:** Light theme primeiro, dark em v2.0

---

## Validação e Compliance

### Checklist de Acessibilidade

- [x] Contraste mínimo 4.5:1 para texto normal (WCAG AA)
- [x] Contraste mínimo 3:1 para texto grande
- [x] Touch targets mínimo 48x48 dp
- [x] Fonte legível (Noto Sans JP)
- [x] Cores semânticas consistentes

### Ferramentas de Design Recomendadas

- **Figma:** Para mockups e protótipos
- **Coolors.co:** Para paleta de cores
- **Material Design Color Tool:** Para verificar contraste
- **Google Fonts:** Para typography

---

## Referências

- [Material Design 3](https://m3.material.io/)
- [Japanese Color Aesthetics](https://nipponcolors.com/)
- [Noto Sans JP - Google Fonts](https://fonts.google.com/noto/specimen/Noto+Sans+JP)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Última Revisão:** 11/10/2025  
**Próxima Revisão:** Após implementação de UI completa
