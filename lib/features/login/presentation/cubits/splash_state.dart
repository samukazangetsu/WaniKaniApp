import 'package:equatable/equatable.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';

/// Estados possíveis da tela de splash.
///
/// Sealed class para garantir type safety e exhaustiveness checking.
sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando token.
final class SplashInitial extends SplashState {}

/// Estado de carregamento - validando token na API.
final class SplashChecking extends SplashState {}

/// Estado de sucesso - token válido, navegar para home.
final class SplashSuccess extends SplashState {
  /// Dados do usuário autenticado.
  final UserEntity user;

  const SplashSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

/// Estado quando não há token salvo - navegar para login.
final class SplashNoToken extends SplashState {}

/// Estado de erro - token inválido ou erro na API.
final class SplashError extends SplashState {
  /// Mensagem de erro para exibir ao usuário.
  final String message;

  const SplashError({required this.message});

  @override
  List<Object> get props => [message];
}
