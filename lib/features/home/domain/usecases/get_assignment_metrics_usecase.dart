import 'package:dartz/dartz.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';

/// Use case para obter todos os assignments do usuário.
///
/// Busca todos os assignments via [IHomeRepository].
/// O cálculo das métricas (reviewCount, lessonCount) será feito no Cubit.
class GetAssignmentMetricsUseCase {
  final IHomeRepository _repository;

  const GetAssignmentMetricsUseCase({required IHomeRepository repository})
    : _repository = repository;

  /// Executa o use case.
  ///
  /// Retorna:
  /// - [Right] com lista de [AssignmentEntity]
  /// - [Left] com [IError] se falhar
  Future<Either<IError, List<AssignmentEntity>>> call() async =>
      _repository.getAssignments();
}
