import 'package:flutter/material.dart';
import 'package:wanikani_app/core/theme/theme.dart';

/// Card que exibe o progresso do nível atual.
///
/// Mostra informações sobre o nível atual do usuário,
/// incluindo progresso visual e estatísticas.
class LevelProgressCard extends StatelessWidget {
  /// Nível atual do usuário.
  final int currentLevel;

  /// Progresso no nível atual (0.0 a 1.0).
  final double progress;

  /// Total de itens no nível.
  final int totalItems;

  /// Itens completados no nível.
  final int completedItems;

  /// Callback para quando o card é pressionado.
  final VoidCallback? onTap;

  const LevelProgressCard({
    required this.currentLevel,
    required this.progress,
    required this.totalItems,
    required this.completedItems,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: WaniKaniDesign.elevationLow,
    margin: const EdgeInsets.symmetric(
      horizontal: WaniKaniDesign.spacingMd,
      vertical: WaniKaniDesign.spacingSm,
    ),
    color: WaniKaniColors.surface,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(WaniKaniDesign.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: WaniKaniDesign.spacingLg),
            _buildProgressBar(),
            SizedBox(height: WaniKaniDesign.spacingSm),
            _buildProgressText(),
          ],
        ),
      ),
    ),
  );

  /// Constrói o cabeçalho com nível atual.
  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'CURRENT LEVEL',
        style: WaniKaniTextStyles.caption.copyWith(
          color: WaniKaniColors.secondary,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: WaniKaniDesign.spacingSm),
      Text(
        '$currentLevel',
        style: WaniKaniTextStyles.levelValue.copyWith(
          color: WaniKaniColors.textPrimary,
          fontSize: 72,
          fontWeight: FontWeight.w300,
          height: 1.0,
        ),
      ),
    ],
  );

  /// Constrói a barra de progresso horizontal.
  Widget _buildProgressBar() => ClipRRect(
    borderRadius: BorderRadius.circular(WaniKaniDesign.radiusSmall),
    child: LinearProgressIndicator(
      value: progress,
      backgroundColor: WaniKaniColors.progressUnfilled,
      valueColor: AlwaysStoppedAnimation<Color>(WaniKaniColors.progressFilled),
      minHeight: 6,
    ),
  );

  /// Constrói o texto de progresso abaixo da barra com porcentagem à direita.
  Widget _buildProgressText() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        '$completedItems of $totalItems items completed',
        style: WaniKaniTextStyles.caption.copyWith(
          color: WaniKaniColors.secondary,
          fontSize: 13,
        ),
      ),
      Text(
        '${(progress * 100).toInt()}%',
        style: WaniKaniTextStyles.caption.copyWith(
          color: WaniKaniColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ],
  );
}
