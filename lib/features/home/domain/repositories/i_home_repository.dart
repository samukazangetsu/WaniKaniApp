import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/home_actions_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_level_progress_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_user_entity.dart';

abstract class IHomeRepository {
  Future<Either<IError, HomeUserEntity>> getUserInfo();
  Future<Either<IError, HomeLevelProgressEntity>> getLevelProgress();
  Future<Either<IError, HomeDashboardEntity>> getDashboard();
  Future<Either<IError, HomeStatsEntity>> getStats();
  Future<Either<IError, HomeActionsEntity>> getActions();
}
