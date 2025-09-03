import 'package:dartz/dartz.dart';
import 'package:wanikani_app/features/home/domain/entities/home_item_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_level_progress_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_review_stat_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/home_user_entity.dart';

abstract class HomeRepository {
  Future<Either<Exception, HomeUserEntity>> getUserInfo();
  Future<Either<Exception, List<HomeItemEntity>>> getHomeItems();
  Future<Either<Exception, List<HomeReviewStatEntity>>> getReviewStats();
  Future<Either<Exception, HomeLevelProgressEntity>> getLevelProgress();
}
