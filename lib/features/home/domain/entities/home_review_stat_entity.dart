class HomeReviewStatEntity {
  final int subjectId;
  final int meaningCorrect;
  final int meaningIncorrect;
  final int readingCorrect;
  final int readingIncorrect;
  final int percentageCorrect;

  HomeReviewStatEntity({
    required this.subjectId,
    required this.meaningCorrect,
    required this.meaningIncorrect,
    required this.readingCorrect,
    required this.readingIncorrect,
    required this.percentageCorrect,
  });
}
