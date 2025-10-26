import 'package:equatable/equatable.dart';
import 'package:wanikani_app/features/login/domain/entities/user_entity.dart';

/// Estados possíveis da tela de login.
///
/// Utiliza sealed class para garantir exhaustiveness checking
/// no switch/pattern matching.
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial da tela de login.
///
/// Exibido quando o usuário abre a tela pela primeira vez.
final class LoginInitial extends LoginState {}

/// Estado de validação do formato do token em tempo real.
///
/// Emitido a cada caractere digitado pelo usuário.
final class LoginValidating extends LoginState {
  /// Indica se o token possui formato válido (regex match).
  ///
  /// Se `true`, o botão "Fazer login" é habilitado.
  final bool isValid;

  const LoginValidating({required this.isValid});

  @override
  List<Object> get props => [isValid];
}

/// Estado de carregamento durante a autenticação.
///
/// Exibido enquanto a API WaniKani está validando o token.
final class LoginLoading extends LoginState {}

/// Estado de sucesso após login bem-sucedido.
///
/// Contém os dados do usuário retornados pela API.
final class LoginSuccess extends LoginState {
  /// Dados do usuário autenticado.
  final UserEntity user;

  const LoginSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

/// Estado de erro durante o processo de login.
///
/// Exibido quando ocorre falha na autenticação ou erro de rede.
final class LoginError extends LoginState {
  /// Mensagem de erro amigável para o usuário.
  final String message;

  const LoginError({required this.message});

  @override
  List<Object> get props => [message];
}
