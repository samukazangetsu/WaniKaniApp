import 'package:wanikani_app/domain/entities/review_statistics/review_statistics_data_entity.dart';

class ReviewStatisticsEntity {
  final int id;
  final String object;
  final String url;
  final DateTime dataUpdatedAt;
  final ReviewStatisticsDataEntity data;

  ReviewStatisticsEntity({
    required this.id,
    required this.object,
    required this.url,
    required this.dataUpdatedAt,
    required this.data,
  });
}
