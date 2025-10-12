import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/repositories/i_home_repository.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';

// Mock do repository
class MockHomeRepository extends Mock implements IHomeRepository {}

void main() {
  late GetCurrentLevelUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetCurrentLevelUseCase(repository: mockRepository);
  });

  group('GetCurrentLevelUseCase', () {
    final LevelProgressionEntity tCurrentLevel = LevelProgressionEntity(
      id: 3691690,
      level: 4,
      unlockedAt: DateTime(2025, 6, 5, 2, 4, 43),
      startedAt: DateTime(2025, 6, 5, 4, 44, 18),
      passedAt: null,
      completedAt: null,
      abandonedAt: null,
    );

    test(
      'deve retornar progressão do nível atual quando repository retorna sucesso',
      () async {
        // Arrange
        when(
          () => mockRepository.getCurrentLevelProgression(),
        ).thenAnswer((_) async => Right(tCurrentLevel));

        // Act
        final Either<IError, LevelProgressionEntity> result = await useCase();

        // Assert
        expect(
          result,
          equals(Right<IError, LevelProgressionEntity>(tCurrentLevel)),
        );
        verify(() => mockRepository.getCurrentLevelProgression()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('deve retornar erro quando repository retorna erro', () async {
      // Arrange
      final InternalErrorEntity tError = InternalErrorEntity('Erro de rede');
      when(
        () => mockRepository.getCurrentLevelProgression(),
      ).thenAnswer((_) async => Left(tError));

      // Act
      final Either<IError, LevelProgressionEntity> result = await useCase();

      // Assert
      expect(result, equals(Left<IError, LevelProgressionEntity>(tError)));
      verify(() => mockRepository.getCurrentLevelProgression()).called(1);
    });
  });
}
