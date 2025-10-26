import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wanikani_app/core/theme/theme.dart';
import 'package:wanikani_app/features/login/presentation/cubits/login_cubit.dart';
import 'package:wanikani_app/features/login/presentation/cubits/login_state.dart';
import 'package:wanikani_app/features/login/presentation/widgets/token_text_field.dart';
import 'package:wanikani_app/features/login/presentation/widgets/tutorial_bottom_sheet.dart';
import 'package:wanikani_app/features/login/utils/login_strings.dart';
import 'package:wanikani_app/routing/app_routes.dart';

/// Tela de login onde o usuário insere seu token de API do WaniKani.
///
/// Features:
/// - Campo de texto com máscara automática
/// - Validação em tempo real do formato
/// - Botão habilitado apenas quando token é válido
/// - Link para tutorial (bottom sheet)
/// - Versão do app no rodapé
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenController = TextEditingController();
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  /// Carrega a versão do app do pubspec.yaml
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  /// Mostra tutorial de como conseguir token
  void _showTutorial() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TutorialBottomSheet(),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        // Navega para home em caso de sucesso
        if (state is LoginSuccess) {
          context.go(AppRoutes.home.path);
        }

        // Mostra erro em SnackBar
        if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: WaniKaniColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // Saudação em japonês
                Text(
                  LoginStrings.greetingWelcomeBack,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 64,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtítulo
                Text(
                  LoginStrings.loginSubtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Campo de token
                TokenTextField(
                  controller: _tokenController,
                  onChanged: (value) {
                    context.read<LoginCubit>().validateTokenFormat(value);
                  },
                ),
                const SizedBox(height: 16),

                // Link para tutorial
                TextButton(
                  onPressed: _showTutorial,
                  child: Text(LoginStrings.tutorialLink),
                ),

                const Spacer(flex: 3),

                // Botão de login
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    final isValid = state is LoginValidating && state.isValid;
                    final isLoading = state is LoginLoading;

                    return FilledButton(
                      onPressed: isValid && !isLoading
                          ? () {
                              context.read<LoginCubit>().login(
                                _tokenController.text,
                              );
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(LoginStrings.loginButton),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Versão do app
                if (_appVersion.isNotEmpty)
                  Text(
                    _appVersion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
