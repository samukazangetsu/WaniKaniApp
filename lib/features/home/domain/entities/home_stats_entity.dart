class HomeStatsEntity {
  final int reviewsAvailable;
  final int lessonsAvailable;
  final double accuracyPercentage;
  final int dayStreak;
  final int totalStudied;

  HomeStatsEntity({
    required this.reviewsAvailable,
    required this.lessonsAvailable,
    required this.accuracyPercentage,
    required this.dayStreak,
    required this.totalStudied,
  });
}
