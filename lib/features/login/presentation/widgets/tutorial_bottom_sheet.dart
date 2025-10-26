import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanikani_app/features/login/utils/login_strings.dart';

/// Bottom sheet com tutorial de como conseguir token do WaniKani.
///
/// Exibe:
/// - Instruções passo a passo
/// - Botão para abrir WaniKani.com
/// - Botão para fechar o tutorial
class TutorialBottomSheet extends StatelessWidget {
  const TutorialBottomSheet({super.key});

  /// Abre o site do WaniKani no navegador externo.
  Future<void> _launchWaniKaniWebsite() async {
    final url = Uri.parse('https://www.wanikani.com');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception(LoginStrings.errorOpenUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Título
          Text(
            LoginStrings.tutorialTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Passo 1
          Text(
            LoginStrings.tutorialStep1,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Passo 2
          Text(
            LoginStrings.tutorialStep2,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Botão primário - Abrir WaniKani
          FilledButton.icon(
            onPressed: () {
              _launchWaniKaniWebsite();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.open_in_new),
            label: Text(LoginStrings.tutorialOpenWaniKani),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Botão secundário - Fechar
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(LoginStrings.tutorialClose),
          ),
        ],
      ),
    );
  }
}
