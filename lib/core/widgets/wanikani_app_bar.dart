import 'package:flutter/material.dart';
import 'package:wanikani_app/core/theme/theme.dart';

/// AppBar customizada com gradiente WaniKani.
///
/// Mantém consistência visual com o design original,
/// incluindo gradiente azul característico.
class WaniKaniAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título da AppBar.
  final String title;

  /// Ações à direita da AppBar.
  final List<Widget>? actions;

  /// Se deve mostrar botão de voltar.
  final bool automaticallyImplyLeading;

  /// Callback para botão de voltar customizado.
  final VoidCallback? onLeadingPressed;

  /// Ícone customizado para leading.
  final Widget? leading;

  const WaniKaniAppBar({
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.onLeadingPressed,
    this.leading,
    super.key,
  });

  /// Cria AppBar simples com apenas título.
  const WaniKaniAppBar.simple(this.title, {super.key})
    : actions = null,
      automaticallyImplyLeading = true,
      onLeadingPressed = null,
      leading = null;

  /// Cria AppBar com ações.
  const WaniKaniAppBar.withActions(this.title, this.actions, {super.key})
    : automaticallyImplyLeading = true,
      onLeadingPressed = null,
      leading = null;

  /// Cria AppBar sem botão de voltar.
  const WaniKaniAppBar.root(this.title, {this.actions, super.key})
    : automaticallyImplyLeading = false,
      onLeadingPressed = null,
      leading = null;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: WaniKaniDesign.spacingMd),
    child: AppBar(
      backgroundColor: WaniKaniColors.background,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading:
          leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: WaniKaniColors.onPrimary,
                  ),
                  onPressed: onLeadingPressed ?? () => Navigator.pop(context),
                )
              : null),
      title: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WaniKaniColors.onPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '蟹',
                style: TextStyle(
                  fontSize: 24,
                  color: WaniKaniColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: WaniKaniDesign.spacingMd),
          Text(
            title,
            style: WaniKaniTextStyles.appBarTitle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
      actions: actions,
      // Remove padding padrão para alinhar com os cards
      leadingWidth: automaticallyImplyLeading ? null : 0,
    ),
  );

  @override
  Size get preferredSize => const Size.fromHeight(WaniKaniDesign.appBarHeight);
}
