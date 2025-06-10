import 'package:wanikani_app/domain/entities/level_progression/level_progression_data_entity.dart';

class LevelProgressionEntity {
  final int id;
  final String object;
  final String url;
  final DateTime dataUpdatedAt;
  final LevelProgressionDataEntity data;

  LevelProgressionEntity({
    required this.id,
    required this.object,
    required this.url,
    required this.dataUpdatedAt,
    required this.data,
  });
}
