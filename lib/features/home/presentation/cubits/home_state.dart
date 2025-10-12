import 'package:equatable/equatable.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
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
final class HomeLoaded extends HomeState {
  /// Progressão do nível atual.
  final LevelProgressionEntity levelProgression;

  /// Lista de todos os assignments.
  final List<AssignmentEntity> assignments;

  const HomeLoaded({required this.levelProgression, required this.assignments});

  /// Número do nível atual (extraído de levelProgression).
  int get currentLevel => levelProgression.level;

  /// Quantidade de reviews disponíveis agora.
  int get reviewCount =>
      assignments.where((AssignmentEntity a) => a.isAvailableForReview).length;

  /// Quantidade de lições disponíveis.
  int get lessonCount =>
      assignments.where((AssignmentEntity a) => a.isLesson).length;

  @override
  List<Object> get props => <Object>[levelProgression, assignments];
}
