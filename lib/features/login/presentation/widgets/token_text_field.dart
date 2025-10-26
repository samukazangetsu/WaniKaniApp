import 'package:flutter/material.dart';
import 'package:wanikani_app/features/login/utils/login_strings.dart';

/// Widget de campo de texto customizado para entrada de token API.
///
/// Features:
/// - Máscara automática: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
/// - Alternar visibilidade (obscureText)
/// - Validação em tempo real via callback
class TokenTextField extends StatefulWidget {
  /// Controller para gerenciar o texto
  final TextEditingController controller;

  /// Callback chamado quando o texto muda
  final ValueChanged<String> onChanged;

  const TokenTextField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  @override
  State<TokenTextField> createState() => _TokenTextFieldState();
}

class _TokenTextFieldState extends State<TokenTextField> {
  bool _obscureText = true;

  /// Aplica máscara ao token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
  ///
  /// Insere traços nas posições 8, 13, 18, 23 automaticamente.
  String _applyMask(String text) {
    // Remove todos os traços existentes
    final clean = text.replaceAll('-', '');

    // Limita a 36 caracteres (sem contar os traços)
    if (clean.length > 36) {
      return widget.controller.text; // Retorna valor anterior
    }

    // Constrói string mascarada usando StringBuffer
    final masked = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      // Adiciona traço nas posições corretas
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        masked.write('-');
      }
      masked.write(clean[i]);
    }

    return masked.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      maxLength: 40, // 36 caracteres + 4 traços
      decoration: InputDecoration(
        labelText: LoginStrings.tokenFieldLabel,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintText: LoginStrings.tokenFieldHint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          tooltip: _obscureText
              ? LoginStrings.showTokenTooltip
              : LoginStrings.hideTokenTooltip,
        ),
        counterText: '', // Remove contador de caracteres
      ),
      onChanged: (value) {
        final masked = _applyMask(value);

        // Atualiza o controller apenas se a máscara mudou
        if (masked != value) {
          widget.controller.value = TextEditingValue(
            text: masked,
            selection: TextSelection.collapsed(offset: masked.length),
          );
        }

        // Chama callback com valor mascarado
        widget.onChanged(masked);
      },
    );
  }
}
