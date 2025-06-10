class LevelProgressionDataEntity {
  final DateTime createdAt;
  final int level;
  final DateTime unlockedAt;
  final DateTime startedAt;
  final DateTime? passedAt;
  final DateTime? completedAt;
  final DateTime? abandonedAt;

  LevelProgressionDataEntity({
    required this.createdAt,
    required this.level,
    required this.unlockedAt,
    required this.startedAt,
    this.passedAt,
    this.completedAt,
    this.abandonedAt,
  });
}
