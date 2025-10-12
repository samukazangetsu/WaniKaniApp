import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';

/// Interface do repositório para dados da Home/Dashboard.
///
/// Define os contratos para obtenção de dados de nível e assignments
/// da API WaniKani (ou cache local).
abstract class IHomeRepository {
  /// Obtém a progressão do nível atual do usuário.
  ///
  /// Chama o endpoint `/level_progressions` (sem ID) que retorna
  /// automaticamente o nível atual do usuário.
  ///
  /// Retorna:
  /// - [Right] com [LevelProgressionEntity] do nível atual em caso de sucesso
  /// - [Left] com [IError] em caso de falha (rede, parsing, etc)
  Future<Either<IError, LevelProgressionEntity>> getCurrentLevelProgression();

  /// Obtém todos os assignments do usuário.
  ///
  /// Retorna:
  /// - [Right] com lista de [AssignmentEntity] em caso de sucesso
  /// - [Left] com [IError] em caso de falha (rede, parsing, etc)
  Future<Either<IError, List<AssignmentEntity>>> getAssignments();
}
