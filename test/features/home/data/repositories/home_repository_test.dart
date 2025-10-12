import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wanikani_app/core/error/api_error_entity.dart';
import 'package:wanikani_app/core/error/ierror.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/features/home/data/datasources/wanikani_datasource.dart';
import 'package:wanikani_app/features/home/data/repositories/home_repository.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';

// Mocks
class MockWaniKaniDataSource extends Mock implements WaniKaniDataSource {}

void main() {
  late HomeRepository repository;
  late MockWaniKaniDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockWaniKaniDataSource();
    repository = HomeRepository(datasource: mockDataSource);
  });

  group('getCurrentLevelProgression', () {
    final List<Map<String, dynamic>> tLevelProgressionsData =
        <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 3557312,
            'object': 'level_progression',
            'data': <String, dynamic>{
              'level': 1,
              'unlocked_at': '2025-03-09T10:11:11.814388Z',
              'started_at': '2025-03-09T10:17:23.016685Z',
              'passed_at': '2025-04-10T15:21:50.960905Z',
              'completed_at': null,
              'abandoned_at': null,
            },
          },
          <String, dynamic>{
            'id': 3608058,
            'object': 'level_progression',
            'data': <String, dynamic>{
              'level': 2,
              'unlocked_at': '2025-04-10T15:21:50.981094Z',
              'started_at': '2025-04-10T17:50:43.521981Z',
              'passed_at': '2025-04-25T20:37:47.039562Z',
              'completed_at': null,
              'abandoned_at': null,
            },
          },
          <String, dynamic>{
            'id': 3691690,
            'object': 'level_progression',
            'data': <String, dynamic>{
              'level': 4,
              'unlocked_at': '2025-06-05T02:04:43.768478Z',
              'started_at': '2025-06-05T04:44:18.785283Z',
              'passed_at': null,
              'completed_at': null,
              'abandoned_at': null,
            },
          },
          <String, dynamic>{
            'id': 3631332,
            'object': 'level_progression',
            'data': <String, dynamic>{
              'level': 3,
              'unlocked_at': '2025-04-25T20:37:47.059316Z',
              'started_at': '2025-04-26T22:45:52.061420Z',
              'passed_at': '2025-06-05T02:04:43.747597Z',
              'completed_at': null,
              'abandoned_at': null,
            },
          },
        ];

    final Map<String, dynamic> tLevelProgressionsResponse = <String, dynamic>{
      'object': 'collection',
      'data': tLevelProgressionsData,
    };

    test(
      'deve retornar nível atual (maior nível) quando chamada for bem-sucedida',
      () async {
        // Arrange
        when(() => mockDataSource.getLevelProgressions()).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/level_progressions'),
            data: tLevelProgressionsResponse,
            statusCode: 200,
          ),
        );

        // Act
        final Either<IError, LevelProgressionEntity> result = await repository
            .getCurrentLevelProgression();

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return Right'), (
          LevelProgressionEntity entity,
        ) {
          expect(entity.id, equals(3691690)); // Nível 4
          expect(entity.level, equals(4)); // Maior nível
          expect(entity.startedAt, isNotNull);
        });
        verify(() => mockDataSource.getLevelProgressions()).called(1);
      },
    );

    test('deve retornar erro quando lista de progressões está vazia', () async {
      // Arrange
      when(() => mockDataSource.getLevelProgressions()).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/level_progressions'),
          data: <String, dynamic>{
            'object': 'collection',
            'data': <Map<String, dynamic>>[],
          },
          statusCode: 200,
        ),
      );

      // Act
      final Either<IError, LevelProgressionEntity> result = await repository
          .getCurrentLevelProgression();

      // Assert
      expect(result.isLeft(), true);
      result.fold((IError error) {
        expect(error, isA<InternalErrorEntity>());
        expect(error.message, equals('Nenhuma progressão de nível encontrada'));
      }, (_) => fail('Should return Left'));
    });

    test('deve retornar ApiErrorEntity quando statusCode != 200', () async {
      // Arrange
      when(() => mockDataSource.getLevelProgressions()).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/level_progressions'),
          data: <String, dynamic>{'error': 'Unauthorized'},
          statusCode: 401,
        ),
      );

      // Act
      final Either<IError, LevelProgressionEntity> result = await repository
          .getCurrentLevelProgression();

      // Assert
      expect(result.isLeft(), true);
      result.fold((IError error) {
        expect(error, isA<ApiErrorEntity>());
        expect((error as ApiErrorEntity).statusCode, equals(401));
      }, (_) => fail('Should return Left'));
    });

    test('deve retornar InternalErrorEntity quando ocorre exceção', () async {
      // Arrange
      when(
        () => mockDataSource.getLevelProgressions(),
      ).thenThrow(Exception('Network error'));

      // Act
      final Either<IError, LevelProgressionEntity> result = await repository
          .getCurrentLevelProgression();

      // Assert
      expect(result.isLeft(), true);
      result.fold((IError error) {
        expect(error, isA<InternalErrorEntity>());
      }, (_) => fail('Should return Left'));
    });
  });

  group('getAssignments', () {
    final List<Map<String, dynamic>> tAssignmentsData = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'data': <String, dynamic>{
          'subject_id': 100,
          'subject_type': 'kanji',
          'srs_stage': 3,
          'unlocked_at': '2025-06-05T10:00:00.000000Z',
          'started_at': '2025-06-05T12:00:00.000000Z',
          'passed_at': null,
          'burned_at': null,
          'available_at': '2025-06-10T10:00:00.000000Z',
        },
      },
      <String, dynamic>{
        'id': 2,
        'data': <String, dynamic>{
          'subject_id': 200,
          'subject_type': 'radical',
          'srs_stage': 0,
          'unlocked_at': '2025-06-06T10:00:00.000000Z',
          'started_at': null,
          'passed_at': null,
          'burned_at': null,
          'available_at': null,
        },
      },
    ];

    final Map<String, dynamic> tAssignmentsResponse = <String, dynamic>{
      'object': 'collection',
      'data': tAssignmentsData,
    };

    test(
      'deve retornar lista de AssignmentEntity quando chamada for bem-sucedida',
      () async {
        // Arrange
        when(() => mockDataSource.getAssignments()).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/assignments'),
            data: tAssignmentsResponse,
            statusCode: 200,
          ),
        );

        // Act
        final Either<IError, List<AssignmentEntity>> result = await repository
            .getAssignments();

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return Right'), (
          List<AssignmentEntity> entities,
        ) {
          expect(entities.length, equals(2));
          expect(entities[0].id, equals(1));
          expect(entities[0].subjectId, equals(100));
          expect(entities[1].id, equals(2));
          expect(entities[1].isLesson, isTrue);
        });
        verify(() => mockDataSource.getAssignments()).called(1);
      },
    );

    test('deve retornar lista vazia quando data está vazia', () async {
      // Arrange
      when(() => mockDataSource.getAssignments()).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/assignments'),
          data: <String, dynamic>{
            'object': 'collection',
            'data': <Map<String, dynamic>>[],
          },
          statusCode: 200,
        ),
      );

      // Act
      final Either<IError, List<AssignmentEntity>> result = await repository
          .getAssignments();

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return Right'), (
        List<AssignmentEntity> entities,
      ) {
        expect(entities, isEmpty);
      });
    });

    test('deve retornar ApiErrorEntity quando statusCode != 200', () async {
      // Arrange
      when(() => mockDataSource.getAssignments()).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/assignments'),
          data: <String, dynamic>{'error': 'Not Found'},
          statusCode: 404,
        ),
      );

      // Act
      final Either<IError, List<AssignmentEntity>> result = await repository
          .getAssignments();

      // Assert
      expect(result.isLeft(), true);
      result.fold((IError error) {
        expect(error, isA<ApiErrorEntity>());
        expect((error as ApiErrorEntity).statusCode, equals(404));
      }, (_) => fail('Should return Left'));
    });

    test('deve retornar InternalErrorEntity quando ocorre exceção', () async {
      // Arrange
      when(
        () => mockDataSource.getAssignments(),
      ).thenThrow(Exception('Parse error'));

      // Act
      final Either<IError, List<AssignmentEntity>> result = await repository
          .getAssignments();

      // Assert
      expect(result.isLeft(), true);
      result.fold((IError error) {
        expect(error, isA<InternalErrorEntity>());
      }, (_) => fail('Should return Left'));
    });
  });
}
