import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:wanikani_app/core/error/api_error_entity.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/features/home/data/datasources/wanikani_datasource.dart';
import 'package:wanikani_app/features/home/data/models/assignment_model.dart';
import 'package:wanikani_app/features/home/data/models/level_progression_model.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

/// Implementação do repositório para dados da Home/Dashboard.
///
/// Responsável por:
/// - Buscar dados do [WaniKaniDataSource]
/// - Converter JSON para entities usando models
/// - Tratar erros e retornar [Either<IError, T>]
class HomeRepository implements IHomeRepository {
  final WaniKaniDataSource _datasource;

  const HomeRepository({required WaniKaniDataSource datasource})
    : _datasource = datasource;

  @override
  Future<Either<IError, LevelProgressionEntity>>
  getCurrentLevelProgression() async {
    try {
      final Response<dynamic> response = await _datasource
          .getLevelProgressions();

      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data as Map<String, dynamic>)['data'] as List<dynamic>;

        if (data.isEmpty) {
          return Left<IError, LevelProgressionEntity>(
            InternalErrorEntity('Nenhuma progressão de nível encontrada'),
          );
        }

        // Converter todas as progressões e ordenar por nível decrescente
        final List<LevelProgressionEntity> progressions =
            data
                .map(
                  (json) => LevelProgressionModel.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList()
              ..sort(
                (LevelProgressionEntity a, LevelProgressionEntity b) =>
                    b.level.compareTo(a.level),
              );

        // Retornar a progressão do nível mais alto (nível atual)
        return Right<IError, LevelProgressionEntity>(progressions.first);
      }

      return Left<IError, LevelProgressionEntity>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? 'Erro desconhecido',
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
      final Response<dynamic> response = await _datasource.getAssignments();

      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data as Map<String, dynamic>)['data'] as List<dynamic>;

        final List<AssignmentEntity> assignments = data
            .map(
              (json) => AssignmentModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return Right<IError, List<AssignmentEntity>>(assignments);
      }

      return Left<IError, List<AssignmentEntity>>(
        ApiErrorEntity(
          response.data?['error']?.toString() ?? 'Erro desconhecido',
          statusCode: response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left<IError, List<AssignmentEntity>>(
        InternalErrorEntity(e.toString()),
      );
    }
  }
}
