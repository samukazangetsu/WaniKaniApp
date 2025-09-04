import 'package:wanikani_app/features/home/domain/entities/home_actions_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_level_progress_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_user_entity.dart';

class HomeDashboardEntity {
  final HomeUserEntity userInfo;
  final HomeLevelProgressEntity levelProgress;
  final HomeStatsEntity stats;
  final HomeActionsEntity actions;

  HomeDashboardEntity({
    required this.userInfo,
    required this.levelProgress,
    required this.stats,
    required this.actions,
  });
}
