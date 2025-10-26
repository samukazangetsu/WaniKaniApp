import 'package:equatable/equatable.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';

/// Estados possíveis da tela de loading.
///
/// Sealed class para garantir type safety e exhaustiveness checking.
sealed class LoadingState extends Equatable {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando token.
final class LoadingInitial extends LoadingState {}

/// Estado de carregamento - validando token na API.
final class LoadingChecking extends LoadingState {}

/// Estado de sucesso - token válido, navegar para home.
final class LoadingSuccess extends LoadingState {
  /// Dados do usuário autenticado.
  final UserEntity user;

  const LoadingSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

/// Estado quando não há token salvo - navegar para login.
final class LoadingNoToken extends LoadingState {}

/// Estado de erro - token inválido ou erro na API.
final class LoadingError extends LoadingState {
  /// Mensagem de erro para exibir ao usuário.
  final String message;

  const LoadingError({required this.message});

  @override
  List<Object> get props => [message];
}
