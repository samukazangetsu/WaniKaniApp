import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/core/storage/local_data_manager.dart';
import 'package:wanikani_app/features/login/domain/usecases/get_user_usecase.dart';
import 'package:wanikani_app/features/login/presentation/cubits/splash_state.dart';

/// Cubit responsável por gerenciar o estado da tela de splash.
///
/// Responsabilidade única:
/// - Verificar se existe token salvo
/// - Validar token na API se existir
/// - Emitir estados apropriados para navegação
class SplashCubit extends Cubit<SplashState> {
  final GetUserUseCase _getUserUseCase;
  final LocalDataManager _localDataManager;

  /// Cria uma instância de [SplashCubit].
  ///
  /// Requer:
  /// - [GetUserUseCase] para validar token na API
  /// - [LocalDataManager] para recuperar token salvo
  SplashCubit({
    required GetUserUseCase getUserUseCase,
    required LocalDataManager localDataManager,
  }) : _getUserUseCase = getUserUseCase,
       _localDataManager = localDataManager,
       super(SplashInitial());

  /// Verifica se existe token salvo e valida na API.
  ///
  /// Fluxo:
  /// 1. Emite [SplashChecking]
  /// 2. Busca token salvo no storage
  /// 3. Se não existir, emite [SplashNoToken] (vai para login)
  /// 4. Se existir, valida na API
  /// 5. Emite [SplashSuccess] se válido OU [SplashError] se inválido
  ///
  /// Este método é chamado automaticamente ao abrir a tela de splash.
  Future<void> checkSavedToken() async {
    emit(SplashChecking());

    // 1. Buscar token salvo
    final token = await _localDataManager.getToken();

    // 2. Se não existir token, vai para login
    if (token == null) {
      emit(SplashNoToken());
      return;
    }

    // 3. Validar token na API
    final validationResult = await _getUserUseCase();

    // 4. Emitir estado com base no resultado
    validationResult.fold(
      (error) => emit(SplashError(message: error.message)),
      (user) => emit(SplashSuccess(user: user)),
    );
  }
}
