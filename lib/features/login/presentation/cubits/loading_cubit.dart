import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/core/storage/local_data_manager.dart';
import 'package:wanikani_app/features/login/domain/usecases/get_user_usecase.dart';
import 'package:wanikani_app/features/login/presentation/cubits/loading_state.dart';

/// Cubit responsável por gerenciar o estado da tela de loading.
///
/// Responsabilidade única:
/// - Verificar se existe token salvo
/// - Validar token na API se existir
/// - Emitir estados apropriados para navegação
class LoadingCubit extends Cubit<LoadingState> {
  final GetUserUseCase _getUserUseCase;
  final LocalDataManager _localDataManager;

  /// Cria uma instância de [LoadingCubit].
  ///
  /// Requer:
  /// - [GetUserUseCase] para validar token na API
  /// - [LocalDataManager] para recuperar token salvo
  LoadingCubit({
    required GetUserUseCase getUserUseCase,
    required LocalDataManager localDataManager,
  }) : _getUserUseCase = getUserUseCase,
       _localDataManager = localDataManager,
       super(LoadingInitial());

  /// Verifica se existe token salvo e valida na API.
  ///
  /// Fluxo:
  /// 1. Emite [LoadingChecking]
  /// 2. Busca token salvo no storage
  /// 3. Se não existir, emite [LoadingNoToken] (vai para login)
  /// 4. Se existir, valida na API
  /// 5. Emite [LoadingSuccess] se válido OU [LoadingError] se inválido
  ///
  /// Este método é chamado automaticamente ao abrir a tela de loading.
  Future<void> checkSavedToken() async {
    emit(LoadingChecking());

    // 1. Buscar token salvo
    final token = await _localDataManager.getToken();

    // 2. Se não existir token, vai para login
    if (token == null) {
      emit(LoadingNoToken());
      return;
    }

    // 3. Validar token na API
    final validationResult = await _getUserUseCase();

    // 4. Emitir estado com base no resultado
    validationResult.fold(
      (error) => emit(LoadingError(message: error.message)),
      (user) => emit(LoadingSuccess(user: user)),
    );
  }
}
