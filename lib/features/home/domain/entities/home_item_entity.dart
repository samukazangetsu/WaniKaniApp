enum HomeItemType { radical, kanji, vocabulary, kanaVocabulary }

class HomeItemEntity {
  final int id;
  final HomeItemType type;
  final int srsStage;
  final bool isUnlocked;
  final bool isBurned;
  final bool isHidden;

  HomeItemEntity({
    required this.id,
    required this.type,
    required this.srsStage,
    required this.isUnlocked,
    required this.isBurned,
    required this.isHidden,
  });
}
