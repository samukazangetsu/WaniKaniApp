import 'package:equatable/equatable.dart';

/// Entidade que representa as estatísticas de reviews.
///
/// Contém o total de reviews disponíveis para o usuário,
/// extraído do campo `total_count` da API WaniKani.
class ReviewStatsEntity extends Equatable {
  /// Total de reviews disponíveis agora.
  final int totalCount;

  const ReviewStatsEntity({required this.totalCount});

  /// Estatística vazia (0 reviews).
  static const ReviewStatsEntity empty = ReviewStatsEntity(totalCount: 0);

  /// Retorna `true` se não há reviews disponíveis.
  bool get isEmpty => totalCount == 0;

  /// Retorna `true` se há pelo menos um review disponível.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object> get props => <Object>[totalCount];
}
