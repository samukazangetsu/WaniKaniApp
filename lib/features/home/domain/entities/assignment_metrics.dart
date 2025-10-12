import 'package:equatable/equatable.dart';

/// Agregado de métricas calculadas a partir dos assignments.
///
/// Contém contadores de reviews e lições disponíveis,
/// derivados da lista de [AssignmentEntity].
class AssignmentMetrics extends Equatable {
  /// Quantidade de reviews disponíveis agora.
  ///
  /// Um review está disponível se:
  /// - `availableAt` não é `null`
  /// - `availableAt` <= agora
  /// - `startedAt` não é `null` (já foi iniciado)
  final int reviewCount;

  /// Quantidade de lições disponíveis.
  ///
  /// Uma lição está disponível se:
  /// - `unlockedAt` é `true`
  /// - `startedAt` é `null` (nunca foi iniciada)
  final int lessonCount;

  const AssignmentMetrics({
    required this.reviewCount,
    required this.lessonCount,
  });

  /// Métrica vazia (0 reviews, 0 lições).
  static const AssignmentMetrics empty = AssignmentMetrics(
    reviewCount: 0,
    lessonCount: 0,
  );

  /// Retorna `true` se não há nenhuma review ou lição disponível.
  bool get isEmpty => reviewCount == 0 && lessonCount == 0;

  /// Retorna `true` se há pelo menos uma review ou lição disponível.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object> get props => <Object>[reviewCount, lessonCount];
}
