import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_lesson_stats_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_review_stats_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_state.dart';

/// Cubit para gerenciar o estado da HomeScreen.
///
/// Responsável por:
/// - Orquestrar chamadas aos use cases
/// - Combinar resultados de múltiplas fontes
/// - Emitir estados apropriados (Loading, Loaded, Error)
class HomeCubit extends Cubit<HomeState> {
  final GetCurrentLevelUseCase _getCurrentLevel;
  final GetReviewStatsUseCase _getReviewStats;
  final GetLessonStatsUseCase _getLessonStats;

  HomeCubit({
    required GetCurrentLevelUseCase getCurrentLevel,
    required GetReviewStatsUseCase getReviewStats,
    required GetLessonStatsUseCase getLessonStats,
  }) : _getCurrentLevel = getCurrentLevel,
       _getReviewStats = getReviewStats,
       _getLessonStats = getLessonStats,
       super(const HomeInitial());

  /// Carrega todos os dados do dashboard em paralelo.
  ///
  /// Usa [Future.wait] para disparar as três requisições simultaneamente:
  /// - [_getCurrentLevel] para buscar o nível atual
  /// - [_getReviewStats] para buscar o total de reviews disponíveis
  /// - [_getLessonStats] para buscar o total de lições disponíveis
  ///
  /// Estratégia de erro resiliente:
  /// - Se TODAS as requisições falharem → emite [HomeError]
  /// - Se PELO MENOS UMA tiver sucesso → emite [HomeLoaded] com dados parciais
  /// - Cards com erro são ocultados (valores null)
  ///
  /// Emite:
  /// - [HomeLoading] ao iniciar
  /// - [HomeLoaded] se pelo menos uma requisição teve sucesso
  /// - [HomeError] apenas se todas as três falharam
  Future<void> loadDashboardData() async {
    emit(const HomeLoading());

    // Dispara as três requisições em paralelo usando Future.wait
    final results = await Future.wait<dynamic>([
      _loadLevelProgression(),
      _loadReviewCount(),
      _loadLessonCount(),
    ]);

    // Extrai os resultados com cast explícito
    final levelProgression = results[0] as LevelProgressionEntity?;
    final reviewCount = results[1] as int?;
    final lessonCount = results[2] as int?;

    // Verifica se TODAS as requisições falharam
    if (levelProgression == null &&
        reviewCount == null &&
        lessonCount == null) {
      emit(const HomeError('Não foi possível carregar os dados do dashboard'));
      return;
    }

    // Pelo menos uma requisição teve sucesso - exibe a tela
    emit(
      HomeLoaded(
        levelProgression: levelProgression,
        reviewCount: reviewCount,
        lessonCount: lessonCount,
      ),
    );
  }

  /// Carrega a progressão de nível atual.
  ///
  /// Retorna a entidade em caso de sucesso ou null em caso de erro.
  Future<LevelProgressionEntity?> _loadLevelProgression() async {
    final result = await _getCurrentLevel();
    return result.fold(
      (_) => null, // Erro: retorna null
      (level) => level, // Sucesso: retorna a entidade
    );
  }

  /// Carrega o total de reviews disponíveis.
  ///
  /// Retorna o total em caso de sucesso ou null em caso de erro.
  Future<int?> _loadReviewCount() async {
    final result = await _getReviewStats();
    return result.fold(
      (_) => null, // Erro: retorna null
      (stats) => stats.totalCount, // Sucesso: retorna o total
    );
  }

  /// Carrega o total de lições disponíveis.
  ///
  /// Retorna o total em caso de sucesso ou null em caso de erro.
  Future<int?> _loadLessonCount() async {
    final result = await _getLessonStats();
    return result.fold(
      (_) => null, // Erro: retorna null
      (stats) => stats.totalCount, // Sucesso: retorna o total
    );
  }
}
