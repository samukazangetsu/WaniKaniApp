import 'package:equatable/equatable.dart';

/// Entidade que representa as estatísticas de lições.
///
/// Contém o total de lições disponíveis para o usuário,
/// extraído do campo `total_count` da API WaniKani endpoint `/study_materials`.
class LessonStatsEntity extends Equatable {
  /// Total de lições disponíveis agora.
  final int totalCount;

  const LessonStatsEntity({required this.totalCount});

  /// Estatística vazia (0 lições).
  static const LessonStatsEntity empty = LessonStatsEntity(totalCount: 0);

  /// Retorna `true` se não há lições disponíveis.
  bool get isEmpty => totalCount == 0;

  /// Retorna `true` se há pelo menos uma lição disponível.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object> get props => <Object>[totalCount];
}
