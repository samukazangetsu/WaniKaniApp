import 'package:equatable/equatable.dart';

/// Representa um assignment (item de estudo) do WaniKani.
///
/// Um assignment é a relação entre um subject (radical, kanji ou vocabulário)
/// e o progresso do usuário com aquele item específico.
class AssignmentEntity extends Equatable {
  /// ID único do assignment.
  final int id;

  /// ID do subject (radical, kanji, vocabulário) associado.
  final int subjectId;

  /// Tipo do subject: 'radical', 'kanji' ou 'vocabulary'.
  final String subjectType;

  /// Estágio SRS atual (0-9).
  ///
  /// - 0: Initiate (lição não iniciada)
  /// - 1-4: Apprentice
  /// - 5-6: Guru
  /// - 7: Master
  /// - 8: Enlightened
  /// - 9: Burned
  final int srsStage;

  /// Data/hora em que o assignment ficará disponível para review.
  ///
  /// `null` se não há review pendente (item queimado ou não iniciado).
  final DateTime? availableAt;

  /// Se `true`, o assignment está desbloqueado e pode ser estudado.
  final bool unlockedAt;

  /// Data/hora em que o assignment foi iniciado pela primeira vez.
  ///
  /// `null` se ainda não foi iniciado (lição pendente).
  final DateTime? startedAt;

  /// Data/hora em que o assignment passou para o estágio "Passed" (SRS 5+).
  ///
  /// `null` se ainda não passou.
  final DateTime? passedAt;

  /// Data/hora em que o assignment foi queimado (SRS 9).
  ///
  /// `null` se ainda não foi queimado.
  final DateTime? burnedAt;

  const AssignmentEntity({
    required this.id,
    required this.subjectId,
    required this.subjectType,
    required this.srsStage,
    required this.availableAt,
    required this.unlockedAt,
    required this.startedAt,
    required this.passedAt,
    required this.burnedAt,
  });

  /// Retorna `true` se o assignment está disponível para review agora.
  bool get isAvailableForReview {
    if (availableAt == null) return false;
    return availableAt!.isBefore(DateTime.now()) ||
        availableAt!.isAtSameMomentAs(DateTime.now());
  }

  /// Retorna `true` se o assignment é uma lição (não iniciada ainda).
  bool get isLesson => unlockedAt && startedAt == null;

  /// Retorna `true` se o assignment foi queimado (SRS 9).
  bool get isBurned => srsStage == 9;

  @override
  List<Object?> get props => <Object?>[
    id,
    subjectId,
    subjectType,
    srsStage,
    availableAt,
    unlockedAt,
    startedAt,
    passedAt,
    burnedAt,
  ];
}
