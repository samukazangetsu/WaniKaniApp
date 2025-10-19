import 'package:equatable/equatable.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';

/// Estados da HomeScreen.
///
/// Usa sealed class (Dart 3.0+) para garantir exhaustiveness checking
/// nos switch expressions.
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial - antes de carregar dados.
final class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Estado de carregamento - enquanto busca dados da API.
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Estado de erro - quando falha ao carregar dados.
final class HomeError extends HomeState {
  /// Mensagem de erro para exibir ao usuário.
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => <Object>[message];
}

/// Estado de sucesso - dados carregados com sucesso.
///
/// Permite valores opcionais para cada seção do dashboard.
/// Se alguma requisição falhar, apenas aquela seção será ocultada.
final class HomeLoaded extends HomeState {
  /// Progressão do nível atual (null se falhou ao carregar).
  final LevelProgressionEntity? levelProgression;

  /// Total de reviews disponíveis (null se falhou ao carregar).
  final int? reviewCount;

  /// Total de lições disponíveis (null se falhou ao carregar).
  final int? lessonCount;

  const HomeLoaded({this.levelProgression, this.reviewCount, this.lessonCount});

  /// Número do nível atual (extraído de levelProgression).
  int? get currentLevel => levelProgression?.level;

  /// Verifica se há pelo menos um dado disponível.
  bool get hasAnyData =>
      levelProgression != null || reviewCount != null || lessonCount != null;

  @override
  List<Object?> get props => <Object?>[
    levelProgression,
    reviewCount,
    lessonCount,
  ];
}
