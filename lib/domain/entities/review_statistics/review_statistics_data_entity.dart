class ReviewStatisticsDataEntity {
  final DateTime createdAt;
  final int subjectId;
  final String subjectType;
  final int meaningCorrect;
  final int meaningIncorrect;
  final int meaningMaxStreak;
  final int meaningCurrentStreak;
  final int readingCorrect;
  final int readingIncorrect;
  final int readingMaxStreak;
  final int readingCurrentStreak;
  final double percentageCorrect;
  final bool hidden;

  ReviewStatisticsDataEntity({
    required this.createdAt,
    required this.subjectId,
    required this.subjectType,
    required this.meaningCorrect,
    required this.meaningIncorrect,
    required this.meaningMaxStreak,
    required this.meaningCurrentStreak,
    required this.readingCorrect,
    required this.readingIncorrect,
    required this.readingMaxStreak,
    required this.readingCurrentStreak,
    required this.percentageCorrect,
    required this.hidden,
  });
}
