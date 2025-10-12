import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_assignment_metrics_usecase.dart';

// Mock do repository
class MockHomeRepository extends Mock implements IHomeRepository {}

void main() {
  late GetAssignmentMetricsUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetAssignmentMetricsUseCase(repository: mockRepository);
  });

  group('GetAssignmentMetricsUseCase', () {
    final List<AssignmentEntity> tAssignments = <AssignmentEntity>[
      // Review disponível (availableAt no passado, startedAt != null)
      AssignmentEntity(
        id: 1,
        subjectId: 100,
        subjectType: 'kanji',
        srsStage: 3,
        availableAt: DateTime.now().subtract(const Duration(hours: 1)),
        unlockedAt: true,
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
        passedAt: null,
        burnedAt: null,
      ),
      // Review disponível
      AssignmentEntity(
        id: 2,
        subjectId: 101,
        subjectType: 'vocabulary',
        srsStage: 5,
        availableAt: DateTime.now().subtract(const Duration(minutes: 30)),
        unlockedAt: true,
        startedAt: DateTime.now().subtract(const Duration(days: 5)),
        passedAt: DateTime.now().subtract(const Duration(days: 1)),
        burnedAt: null,
      ),
      // Lição disponível (unlockedAt = true, startedAt = null)
      const AssignmentEntity(
        id: 3,
        subjectId: 102,
        subjectType: 'radical',
        srsStage: 0,
        availableAt: null,
        unlockedAt: true,
        startedAt: null,
        passedAt: null,
        burnedAt: null,
      ),
      // Lição disponível
      const AssignmentEntity(
        id: 4,
        subjectId: 103,
        subjectType: 'kanji',
        srsStage: 0,
        availableAt: null,
        unlockedAt: true,
        startedAt: null,
        passedAt: null,
        burnedAt: null,
      ),
      // Review futuro (não disponível ainda)
      AssignmentEntity(
        id: 5,
        subjectId: 104,
        subjectType: 'vocabulary',
        srsStage: 4,
        availableAt: DateTime.now().add(const Duration(hours: 2)),
        unlockedAt: true,
        startedAt: DateTime.now().subtract(const Duration(days: 3)),
        passedAt: null,
        burnedAt: null,
      ),
      // Item queimado (não conta)
      AssignmentEntity(
        id: 6,
        subjectId: 105,
        subjectType: 'kanji',
        srsStage: 9,
        availableAt: null,
        unlockedAt: true,
        startedAt: DateTime.now().subtract(const Duration(days: 100)),
        passedAt: DateTime.now().subtract(const Duration(days: 50)),
        burnedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    test(
      'deve retornar lista de assignments quando repository retorna sucesso',
      () async {
        // Arrange
        when(
          () => mockRepository.getAssignments(),
        ).thenAnswer((_) async => Right(tAssignments));

        // Act
        final Either<IError, List<AssignmentEntity>> result = await useCase();

        // Assert
        expect(
          result,
          equals(Right<IError, List<AssignmentEntity>>(tAssignments)),
        );
        verify(() => mockRepository.getAssignments()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('deve retornar erro quando repository retorna erro', () async {
      // Arrange
      final InternalErrorEntity tError = InternalErrorEntity('Erro de rede');
      when(
        () => mockRepository.getAssignments(),
      ).thenAnswer((_) async => Left(tError));

      // Act
      final Either<IError, List<AssignmentEntity>> result = await useCase();

      // Assert
      expect(result, equals(Left<IError, List<AssignmentEntity>>(tError)));
      verify(() => mockRepository.getAssignments()).called(1);
    });

    test('deve retornar lista vazia quando não há assignments', () async {
      // Arrange
      when(
        () => mockRepository.getAssignments(),
      ).thenAnswer((_) async => const Right(<AssignmentEntity>[]));

      // Act
      final Either<IError, List<AssignmentEntity>> result = await useCase();

      // Assert
      expect(
        result,
        equals(
          const Right<IError, List<AssignmentEntity>>(<AssignmentEntity>[]),
        ),
      );
    });
  });
}
