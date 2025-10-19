import 'package:dartz/dartz.dart';
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
      final response = await _datasource.getLevelProgressions();

      if (response.statusCode == 200) {
        final data =
            (response.data as Map<String, dynamic>)['data'] as List<dynamic>;

        if (data.isEmpty) {
          return Left<IError, LevelProgressionEntity>(
            InternalErrorEntity('Nenhuma progressão de nível encontrada'),
          );
        }

        // Converter todas as progressões e ordenar por nível crescente
        final List<LevelProgressionEntity> progressions =
            data
                .map(
                  (json) => LevelProgressionModel.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList()
              ..sort(
                (LevelProgressionEntity a, LevelProgressionEntity b) => a.level
                    .compareTo(b.level), // Crescente para facilitar busca
              );

        // Encontrar nível atual usando as regras da API:
        // 1. Primeiro item com passed_at == null (nível em progresso)
        // 2. OU item anterior ao que tem unlocked_at == null
        LevelProgressionEntity? currentLevel;

        // Regra 1: Procurar primeiro nível com
        //passed_at == null E unlocked_at != null
        for (final progression in progressions) {
          if (progression.passedAt == null && progression.unlockedAt != null) {
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

        // Se ainda não encontrou, pegar o último nível com unlocked_at != null
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
      final response = await _datasource.getAssignments();

      if (response.statusCode == 200) {
        final data =
            (response.data as Map<String, dynamic>)['data'] as List<dynamic>;

        final List<AssignmentEntity> assignments = data
            .map(
              (dynamic json) =>
                  AssignmentModel.fromJson(json as Map<String, dynamic>),
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
