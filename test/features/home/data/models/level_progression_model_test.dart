import 'package:flutter_test/flutter_test.dart';
import 'package:wanikani_app/features/home/data/models/level_progression_model.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';

void main() {
  group('LevelProgressionModel', () {
    final tJson = <String, dynamic>{
      'id': 3691690,
      'object': 'level_progression',
      'url': 'https://api.wanikani.com/v2/level_progressions/3691690',
      'data_updated_at': '2025-06-05T04:44:18.789073Z',
      'data': <String, dynamic>{
        'created_at': '2025-06-05T02:04:43.770655Z',
        'level': 4,
        'unlocked_at': '2025-06-05T02:04:43.768478Z',
        'started_at': '2025-06-05T04:44:18.785283Z',
        'passed_at': null,
        'completed_at': null,
        'abandoned_at': null,
      },
    };

    final tEntity = LevelProgressionEntity(
      id: 3691690,
      level: 4,
      unlockedAt: DateTime.parse('2025-06-05T02:04:43.768478Z'),
      startedAt: DateTime.parse('2025-06-05T04:44:18.785283Z'),
      passedAt: null,
      completedAt: null,
      abandonedAt: null,
    );

    test('deve criar model a partir de JSON', () {
      // Act
      final model = LevelProgressionModel.fromJson(tJson);

      // Assert
      expect(model.id, equals(3691690));
      expect(model.level, equals(4));
      expect(
        model.unlockedAt,
        equals(DateTime.parse('2025-06-05T02:04:43.768478Z')),
      );
      expect(
        model.startedAt,
        equals(DateTime.parse('2025-06-05T04:44:18.785283Z')),
      );
      expect(model.passedAt, isNull);
      expect(model.completedAt, isNull);
      expect(model.abandonedAt, isNull);
    });

    test('deve implementar LevelProgressionEntity', () {
      // Arrange
      final model = LevelProgressionModel.fromJson(tJson);

      // Assert
      expect(model, isA<LevelProgressionEntity>());
    });

    test('deve ter acesso às propriedades da entity', () {
      // Arrange
      final model = LevelProgressionModel.fromJson(tJson);

      // Assert - computed properties da entity devem funcionar
      expect(
        model.isActive,
        isTrue,
      ); // startedAt != null && completedAt == null
      expect(model.isCompleted, isFalse);
      expect(model.isAbandoned, isFalse);
    });

    test('deve converter para JSON', () {
      // Arrange
      final model = LevelProgressionModel(tEntity);

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], equals(3691690));
      expect(json['level'], equals(4));
      expect(
        DateTime.parse(json['unlocked_at'] as String),
        equals(DateTime.parse('2025-06-05T02:04:43.768478Z')),
      );
      expect(
        DateTime.parse(json['started_at'] as String),
        equals(DateTime.parse('2025-06-05T04:44:18.785283Z')),
      );
      expect(json['passed_at'], isNull);
      expect(json['completed_at'], isNull);
      expect(json['abandoned_at'], isNull);
    });

    test('deve lidar com campos nullable no JSON', () {
      // Arrange
      final tJsonWithNulls = <String, dynamic>{
        'id': 1,
        'object': 'level_progression',
        'data': <String, dynamic>{
          'level': 1,
          'unlocked_at': null,
          'started_at': null,
          'passed_at': null,
          'completed_at': null,
          'abandoned_at': null,
        },
      };

      // Act
      final model = LevelProgressionModel.fromJson(tJsonWithNulls);

      // Assert
      expect(model.id, equals(1));
      expect(model.level, equals(1));
      expect(model.unlockedAt, isNull);
      expect(model.startedAt, isNull);
      expect(model.passedAt, isNull);
      expect(model.completedAt, isNull);
      expect(model.abandonedAt, isNull);
    });
  });
}
