import 'package:flutter/material.dart';

/// Card para exibir uma métrica do dashboard.
///
/// Utilizado para mostrar:
/// - Nível atual
/// - Número de reviews
/// - Número de lessons
///
/// Exibe um ícone, título e valor de forma consistente.
class DashboardMetricCard extends StatelessWidget {
  /// Título da métrica (ex: "Nível", "Reviews").
  final String title;

  /// Valor da métrica a ser exibido (ex: "5", "12").
  final String value;

  /// Ícone representativo da métrica.
  final IconData icon;

  const DashboardMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
