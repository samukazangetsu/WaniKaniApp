import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wanikani_app/core/theme/theme.dart';
import 'package:wanikani_app/features/login/presentation/cubits/loading_cubit.dart';
import 'package:wanikani_app/features/login/presentation/cubits/loading_state.dart';
import 'package:wanikani_app/features/login/utils/login_strings.dart';
import 'package:wanikani_app/routing/app_routes.dart';

/// Tela de loading exibida durante validação do token.
///
/// Mostra:
/// - Logo/título do app
/// - Barra de progresso indeterminada
/// - Mensagem de carregamento
///
/// Navega automaticamente para:
/// - Home se token for válido
/// - Login se token for inválido ou não existir
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Verifica token salvo após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoadingCubit>().checkSavedToken();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LoadingCubit, LoadingState>(
      listener: (context, state) {
        // Navega para home se validação for bem-sucedida
        if (state is LoadingSuccess) {
          context.go(AppRoutes.home.path);
        }

        // Navega para login se não houver token ou for inválido
        if (state is LoadingError || state is LoadingNoToken) {
          context.go(AppRoutes.login.path);
        }
      },
      child: Scaffold(
        backgroundColor: WaniKaniColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Título do app
              Text(
                LoginStrings.loadingAppTitle,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo em japonês
              Text(
                LoginStrings.loadingSubtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 64),

              // Barra de progresso animada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => LinearProgressIndicator(
                    value: _animation.value,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mensagem de carregamento
              Text(
                LoginStrings.loadingMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
