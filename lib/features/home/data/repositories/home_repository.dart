import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/api_error_entity.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/core/mixins/decode_model_mixin.dart';
import 'package:wanikani_app/core/network/extensions/response_extension.dart';
import 'package:wanikani_app/core/utils/core_strings.dart';
import 'package:wanikani_app/features/home/data/datasources/wanikani_datasource.dart';
import 'package:wanikani_app/features/home/data/models/assignment_model.dart';
import 'package:wanikani_app/features/home/data/models/lesson_stats_model.dart';
import 'package:wanikani_app/features/home/data/models/level_progression_model.dart';
import 'package:wanikani_app/features/home/data/models/review_stats_model.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/lesson_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/review_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';
import 'package:wanikani_app/features/home/utils/home_strings.dart';

/// Implementação do repositório para dados da Home/Dashboard.
///
/// Responsável por:
/// - Buscar dados do [WaniKaniDataSource]
/// - Converter JSON para entities usando models
/// - Tratar erros e retornar [Either<IError, T>]
class HomeRepository with DecodeModelMixin implements IHomeRepository {
  final WaniKaniDataSource _datasource;

  const HomeRepository({required WaniKaniDataSource datasource})
    : _datasource = datasource;

  @override
  Future<Either<IError, LevelProgressionEntity>>
  getCurrentLevelProgression() async {
    try {
      final response = await _datasource.getLevelProgressions();

      if (response.isSuccessful) {
        return tryDecode<Either<IError, LevelProgressionEntity>>(
          () {
            final data =
                (response.data as Map<String, dynamic>)['data'] as List;

            if (data.isEmpty) {
              return Left<IError, LevelProgressionEntity>(
                InternalErrorEntity(HomeStrings.errorNoLevelProgression),
              );
            }

            // Converter todas as progressões e ordenar por nível crescente
            final List<LevelProgressionEntity> progressions =
                data
                    .map(
                      (dynamic json) => LevelProgressionModel.fromJson(
                        json as Map<String, dynamic>,
                      ),
                    )
                    .toList()
                  ..sort(
                    (LevelProgressionEntity a, LevelProgressionEntity b) =>
                        a.level.compareTo(b.level),
                  );

            // Encontrar nível atual usando as regras da API
            LevelProgressionEntity? currentLevel;

            // Regra 1: Procurar primeiro nível com
            // passed_at == null E unlocked_at != null
            for (final progression in progressions) {
              if (progression.passedAt == null &&
                  progression.unlockedAt != null) {
                currentLevel = progression;
                break;
              }
            }

            // Regra 2: Se não encontrou, procurar item
            // anterior ao unlocked_at == null
            if (currentLevel == null) {
              for (var i = 0; i < progressions.length; i++) {
                if (progressions[i].unlockedAt == null && i > 0) {
                  currentLevel = progressions[i - 1];
                  break;
                }
              }
            }

            // Se ainda não encontrou, pegar o último nível com unlocked_at !=
            // null
            if (currentLevel == null) {
              for (var i = progressions.length - 1; i >= 0; i--) {
                if (progressions[i].unlockedAt != null) {
                  currentLevel = progressions[i];
                  break;
                }
              }
            }

            // Fallback final: primeiro item
            currentLevel ??= progressions.first;

            return Right<IError, LevelProgressionEntity>(currentLevel);
          },
          orElse: (_) => Left<IError, LevelProgressionEntity>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      return Left<IError, LevelProgressionEntity>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, LevelProgressionEntity>(
        InternalErrorEntity(e.toString()),
      );
    }
  }

  @override
  Future<Either<IError, List<AssignmentEntity>>> getAssignments() async {
    try {
      final response = await _datasource.getAssignments();

      if (response.isSuccessful) {
        return tryDecode<Either<IError, List<AssignmentEntity>>>(
          () {
            final data =
                (response.data as Map<String, dynamic>)['data'] as List;

            final List<AssignmentEntity> assignments = data
                .map(
                  (dynamic json) =>
                      AssignmentModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();

            return Right<IError, List<AssignmentEntity>>(assignments);
          },
          orElse: (_) => Left<IError, List<AssignmentEntity>>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      return Left<IError, List<AssignmentEntity>>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, List<AssignmentEntity>>(
        InternalErrorEntity(e.toString()),
      );
    }
  }

  @override
  Future<Either<IError, ReviewStatsEntity>> getReviewStats() async {
    try {
      final response = await _datasource.getReviews();

      if (response.isSuccessful) {
        return tryDecode<Either<IError, ReviewStatsEntity>>(
          () {
            final ReviewStatsEntity reviewStats = ReviewStatsModel.fromJson(
              response.data as Map<String, dynamic>,
            );

            return Right<IError, ReviewStatsEntity>(reviewStats);
          },
          orElse: (_) => Left<IError, ReviewStatsEntity>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      return Left<IError, ReviewStatsEntity>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, ReviewStatsEntity>(InternalErrorEntity(e.toString()));
    }
  }

  @override
  Future<Either<IError, LessonStatsEntity>> getLessonStats() async {
    try {
      final response = await _datasource.getStudyMaterials();

      if (response.isSuccessful) {
        return tryDecode<Either<IError, LessonStatsEntity>>(
          () {
            final LessonStatsEntity lessonStats = LessonStatsModel.fromJson(
              response.data as Map<String, dynamic>,
            );

            return Right<IError, LessonStatsEntity>(lessonStats);
          },
          orElse: (_) => Left<IError, LessonStatsEntity>(
            InternalErrorEntity(CoreStrings.errorUnknown),
          ),
        );
      }

      return Left<IError, LessonStatsEntity>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? CoreStrings.errorUnknown,
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, LessonStatsEntity>(InternalErrorEntity(e.toString()));
    }
  }
}
