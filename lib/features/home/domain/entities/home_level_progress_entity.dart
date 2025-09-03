class HomeLevelProgressEntity {
  final int level;
  final DateTime unlockedAt;
  final DateTime startedAt;
  final DateTime? passedAt;
  final DateTime? completedAt;

  HomeLevelProgressEntity({
    required this.level,
    required this.unlockedAt,
    required this.startedAt,
    this.passedAt,
    this.completedAt,
  });
}
