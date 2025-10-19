import 'package:flutter/material.dart';
import 'package:wanikani_app/core/theme/theme.dart';

/// Card que exibe métricas de estudo (lessons ou reviews).
///
/// Substitui o DashboardMetricCard com design WaniKani.
class StudyMetricCard extends StatelessWidget {
  /// Título do card (ex: "Lessons", "Reviews").
  final String title;

  /// Valor principal a ser exibido.
  final String value;

  /// Subtítulo ou descrição adicional.
  final String? subtitle;

  /// Ícone do card.
  final IconData icon;

  /// Cor do card (usado para gradiente e ícone).
  final Color color;

  /// Callback para quando o card é pressionado.
  final VoidCallback? onTap;

  /// Se o card está habilitado.
  final bool enabled;

  const StudyMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    super.key,
  });

  /// Factory para criar card de lessons.
  const StudyMetricCard.lessons({
    required this.value,
    String? subtitle,
    this.onTap,
    this.enabled = true,
    super.key,
  }) : title = 'LESSONS',
       icon = Icons.menu_book,
       color = WaniKaniColors.textPrimary,
       subtitle = subtitle ?? 'Ready to learn';

  /// Factory para criar card de reviews.
  const StudyMetricCard.reviews({
    required this.value,
    String? subtitle,
    this.onTap,
    this.enabled = true,
    super.key,
  }) : title = 'REVIEWS',
       icon = Icons.schedule,
       color = WaniKaniColors.textPrimary,
       subtitle = subtitle ?? 'Available now';

  @override
  Widget build(BuildContext context) => Card(
    elevation: WaniKaniDesign.elevationLow,
    margin: const EdgeInsets.symmetric(
      horizontal: WaniKaniDesign.spacingMd,
      vertical: WaniKaniDesign.spacingSm,
    ),
    color: WaniKaniColors.surface,
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(WaniKaniDesign.spacingLg),
        child: Row(
          children: [
            _buildIcon(),
            SizedBox(width: WaniKaniDesign.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  SizedBox(height: WaniKaniDesign.spacingSm),
                  _buildValue(),
                  if (subtitle != null) ...[
                    SizedBox(height: WaniKaniDesign.spacingXs),
                    _buildSubtitle(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// Constrói o ícone do card.
  Widget _buildIcon() => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: WaniKaniColors.iconBackground,
      borderRadius: BorderRadius.circular(WaniKaniDesign.radiusMedium),
    ),
    child: Icon(icon, color: WaniKaniColors.textPrimary, size: 32),
  );

  /// Constrói o título do card.
  Widget _buildTitle() => Text(
    title,
    style: WaniKaniTextStyles.caption.copyWith(
      color: WaniKaniColors.secondary,
      letterSpacing: 1.2,
      fontSize: 12,
    ),
  );

  /// Constrói o valor principal.
  Widget _buildValue() => Text(
    value,
    style: WaniKaniTextStyles.cardValue.copyWith(
      color: WaniKaniColors.textPrimary,
      fontWeight: FontWeight.w300,
      fontSize: 48,
      height: 1.0,
    ),
  );

  /// Constrói o subtítulo se presente.
  Widget _buildSubtitle() => Text(
    subtitle!,
    style: WaniKaniTextStyles.caption.copyWith(
      color: WaniKaniColors.secondary,
      fontSize: 13,
    ),
  );
}
