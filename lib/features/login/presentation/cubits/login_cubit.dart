import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/core/error/api_error_entity.dart';
import 'package:wanikani_app/core/storage/local_data_manager.dart';
import 'package:wanikani_app/features/login/domain/usecases/get_user_usecase.dart';
import 'package:wanikani_app/features/login/presentation/cubits/login_state.dart';

/// Cubit responsável por gerenciar o estado da tela de login.
///
/// Funções principais:
/// - Validar formato do token em tempo real
/// - Salvar token no storage seguro
/// - Validar token na API WaniKani
/// - Emitir estados apropriados (Loading, Success, Error)
class LoginCubit extends Cubit<LoginState> {
  final GetUserUseCase _getUserUseCase;
  final LocalDataManager _localDataManager;

  /// Expressão regular para validar formato do token WaniKani.
  ///
  /// Formato esperado: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
  /// - 8 caracteres alfanuméricos
  /// - Traço
  /// - 4 caracteres alfanuméricos
  /// - Traço
  /// - 4 caracteres alfanuméricos
  /// - Traço
  /// - 4 caracteres alfanuméricos
  /// - Traço
  /// - 12 caracteres alfanuméricos
  static final _tokenRegex = RegExp(
    r'^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-'
    r'[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$',
  );

  /// Cria uma instância de [LoginCubit].
  ///
  /// Requer:
  /// - [GetUserUseCase] para validar token na API
  /// - [LocalDataManager] para salvar/recuperar token
  LoginCubit({
    required GetUserUseCase getUserUseCase,
    required LocalDataManager localDataManager,
  }) : _getUserUseCase = getUserUseCase,
       _localDataManager = localDataManager,
       super(LoginInitial());

  /// Valida o formato do token em tempo real.
  ///
  /// Emite [LoginValidating] com `isValid = true` se o token
  /// corresponder ao formato esperado.
  ///
  /// Este método é chamado a cada caractere digitado pelo usuário.
  ///
  /// Exemplo:
  /// ```dart
  /// onChanged: (value) => cubit.validateTokenFormat(value)
  /// ```
  void validateTokenFormat(String token) {
    final isValid = _tokenRegex.hasMatch(token);
    emit(LoginValidating(isValid: isValid));
  }

  /// Realiza o processo completo de login.
  ///
  /// Passos:
  /// 1. Emite [LoginLoading]
  /// 2. Valida token chamando API (GET /user) com o token fornecido
  /// 3. Se válido, salva token no storage seguro
  /// 4. Emite [LoginSuccess] com dados do usuário OU
  ///    [LoginError] com mensagem de erro
  ///
  /// **IMPORTANTE:** O token é validado ANTES de ser salvo. Assim, evitamos
  /// salvar tokens inválidos no storage.
  ///
  /// Exemplo:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => cubit.login(tokenController.text),
  ///   child: Text('Fazer login'),
  /// )
  /// ```
  Future<void> login(String token) async {
    emit(LoginLoading());

    // 1. Validar token chamando API (passa token explicitamente)
    final result = await _getUserUseCase(apiToken: token);

    // 2. Emitir estado com base no resultado
    await result.fold(
      (error) async {
        // If API returned an HTTP status code (e.g. 401), expose it to the UI
        int? status;
        if (error is ApiErrorEntity) {
          status = error.statusCode;
        }
        emit(LoginError(message: error.message, statusCode: status));
      },
      (user) async {
        // 3. Salvar token apenas se validação foi bem-sucedida
        await _localDataManager.saveToken(token);
        emit(LoginSuccess(user: user));
      },
    );
  }
}
