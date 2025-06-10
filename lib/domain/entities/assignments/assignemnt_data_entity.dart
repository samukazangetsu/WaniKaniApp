class AssignmentDataEntity {
  final DateTime createdAt;
  final int subjectId;
  final String subjectType;
  final int srsStage;
  final DateTime unlockedAt;
  final DateTime? startedAt;
  final DateTime? passedAt;
  final DateTime? burnedAt;
  final DateTime availableAt;
  final DateTime? resurrectedAt;
  final bool hidden;

  const AssignmentDataEntity({
    required this.createdAt,
    required this.subjectId,
    required this.subjectType,
    required this.srsStage,
    required this.unlockedAt,
    required this.availableAt,
    required this.hidden,
    this.startedAt,
    this.passedAt,
    this.burnedAt,
    this.resurrectedAt,
  });
}
