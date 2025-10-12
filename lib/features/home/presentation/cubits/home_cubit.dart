import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_assignment_metrics_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_state.dart';

/// Cubit para gerenciar o estado da HomeScreen.
///
/// Responsável por:
/// - Orquestrar chamadas aos use cases
/// - Combinar resultados de múltiplas fontes
/// - Emitir estados apropriados (Loading, Loaded, Error)
class HomeCubit extends Cubit<HomeState> {
  final GetCurrentLevelUseCase _getCurrentLevel;
  final GetAssignmentMetricsUseCase _getAssignmentMetrics;

  HomeCubit({
    required GetCurrentLevelUseCase getCurrentLevel,
    required GetAssignmentMetricsUseCase getAssignmentMetrics,
  }) : _getCurrentLevel = getCurrentLevel,
       _getAssignmentMetrics = getAssignmentMetrics,
       super(const HomeInitial());

  /// Carrega todos os dados do dashboard.
  ///
  /// Orquestra as chamadas aos métodos individuais:
  /// - [_loadLevelProgression] para buscar o nível atual
  /// - [_loadAssignments] para buscar os assignments
  ///
  /// Emite:
  /// - [HomeLoading] ao iniciar
  /// - [HomeLoaded] se ambos tiverem sucesso
  /// - [HomeError] se qualquer um falhar
  Future<void> loadDashboardData() async {
    emit(const HomeLoading());

    // Buscar nível atual
    final Either<IError, LevelProgressionEntity> levelResult =
        await _getCurrentLevel();

    // Verificar resultado do nível
    await levelResult.fold(
      (IError error) async {
        emit(HomeError(error.message));
      },
      (LevelProgressionEntity levelProgression) async {
        // Buscar assignments apenas se o nível foi carregado com sucesso
        final Either<IError, List<AssignmentEntity>> assignmentsResult =
            await _getAssignmentMetrics();

        // Verificar resultado dos assignments
        assignmentsResult.fold(
          (IError error) {
            emit(HomeError(error.message));
          },
          (List<AssignmentEntity> assignments) {
            emit(
              HomeLoaded(
                levelProgression: levelProgression,
                assignments: assignments,
              ),
            );
          },
        );
      },
    );
  }
}
