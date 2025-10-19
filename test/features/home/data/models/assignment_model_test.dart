import 'package:flutter_test/flutter_test.dart';
import 'package:wanikani_app/features/home/data/models/assignment_model.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';

void main() {
  group('AssignmentModel', () {
    final tJson = <String, dynamic>{
      'id': 526070297,
      'object': 'assignment',
      'url': 'https://api.wanikani.com/v2/assignments/526070297',
      'data_updated_at': '2025-05-07T16:01:03.323735Z',
      'data': <String, dynamic>{
        'created_at': '2025-03-09T10:11:11.837344Z',
        'subject_id': 16,
        'subject_type': 'radical',
        'srs_stage': 8,
        'unlocked_at': '2025-03-09T10:11:11.835272Z',
        'started_at': '2025-03-09T10:22:41.880267Z',
        'passed_at': '2025-03-13T16:34:41.509446Z',
        'burned_at': null,
        'available_at': '2025-09-04T15:00:00.000000Z',
        'resurrected_at': null,
        'hidden': false,
      },
    };

    final tEntity = AssignmentEntity(
      id: 526070297,
      subjectId: 16,
      subjectType: 'radical',
      srsStage: 8,
      availableAt: DateTime.parse('2025-09-04T15:00:00.000000Z'),
      unlockedAt: true,
      startedAt: DateTime.parse('2025-03-09T10:22:41.880267Z'),
      passedAt: DateTime.parse('2025-03-13T16:34:41.509446Z'),
      burnedAt: null,
    );

    test('deve criar model a partir de JSON', () {
      // Act
      final model = AssignmentModel.fromJson(tJson);

      // Assert
      expect(model.id, equals(526070297));
      expect(model.subjectId, equals(16));
      expect(model.subjectType, equals('radical'));
      expect(model.srsStage, equals(8));
      expect(
        model.availableAt,
        equals(DateTime.parse('2025-09-04T15:00:00.000000Z')),
      );
      expect(model.unlockedAt, isTrue);
      expect(
        model.startedAt,
        equals(DateTime.parse('2025-03-09T10:22:41.880267Z')),
      );
      expect(
        model.passedAt,
        equals(DateTime.parse('2025-03-13T16:34:41.509446Z')),
      );
      expect(model.burnedAt, isNull);
    });

    test('deve implementar AssignmentEntity', () {
      // Arrange
      final model = AssignmentModel.fromJson(tJson);

      // Assert
      expect(model, isA<AssignmentEntity>());
    });

    test('deve ter acesso às propriedades da entity', () {
      // Arrange
      final model = AssignmentModel.fromJson(tJson);

      // Assert - computed properties da entity devem funcionar
      expect(model.isBurned, isFalse); // srsStage == 8, não 9
      expect(model.isLesson, isFalse); // startedAt != null
    });

    test('deve converter para JSON', () {
      // Arrange
      final model = AssignmentModel(tEntity);

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], equals(526070297));
      expect(json['subject_id'], equals(16));
      expect(json['subject_type'], equals('radical'));
      expect(json['srs_stage'], equals(8));
      expect(
        DateTime.parse(json['available_at'] as String),
        equals(DateTime.parse('2025-09-04T15:00:00.000000Z')),
      );
      expect(
        DateTime.parse(json['started_at'] as String),
        equals(DateTime.parse('2025-03-09T10:22:41.880267Z')),
      );
      expect(
        DateTime.parse(json['passed_at'] as String),
        equals(DateTime.parse('2025-03-13T16:34:41.509446Z')),
      );
      expect(json['burned_at'], isNull);
    });

    test('deve lidar com campos nullable no JSON', () {
      // Arrange
      final tJsonWithNulls = <String, dynamic>{
        'id': 1,
        'object': 'assignment',
        'data': <String, dynamic>{
          'subject_id': 100,
          'subject_type': 'kanji',
          'srs_stage': 0,
          'unlocked_at': null,
          'started_at': null,
          'passed_at': null,
          'burned_at': null,
          'available_at': null,
        },
      };

      // Act
      final model = AssignmentModel.fromJson(tJsonWithNulls);

      // Assert
      expect(model.id, equals(1));
      expect(model.subjectId, equals(100));
      expect(model.unlockedAt, isFalse); // null = false
      expect(model.startedAt, isNull);
      expect(model.passedAt, isNull);
      expect(model.burnedAt, isNull);
      expect(model.availableAt, isNull);
    });

    test('deve identificar lição corretamente', () {
      // Arrange - lição não iniciada
      final tLessonJson = <String, dynamic>{
        'id': 2,
        'data': <String, dynamic>{
          'subject_id': 200,
          'subject_type': 'radical',
          'srs_stage': 0,
          'unlocked_at': '2025-06-05T10:00:00.000000Z',
          'started_at': null,
          'passed_at': null,
          'burned_at': null,
          'available_at': null,
        },
      };

      // Act
      final model = AssignmentModel.fromJson(tLessonJson);

      // Assert
      expect(model.isLesson, isTrue); // unlockedAt = true && startedAt = null
    });
  });
}
