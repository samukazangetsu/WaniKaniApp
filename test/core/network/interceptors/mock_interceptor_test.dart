import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanikani_app/core/network/interceptors/mock_interceptor.dart';

void main() {
  late MockInterceptor mockInterceptor;
  late Dio dio;

  // Inicializar Flutter binding para testes
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockInterceptor = MockInterceptor();
    dio = Dio(BaseOptions(baseUrl: 'https://api.wanikani.com/v2'));
    dio.interceptors.add(mockInterceptor);
  });

  group('MockInterceptor', () {
    test(
      'deve retornar mock de assignments quando path contém "assignments"',
      () async {
        // Arrange
        const String expectedPath = '/assignments';

        // Act
        final Response<dynamic> response = await dio.get<dynamic>(expectedPath);

        // Assert
        expect(response.statusCode, equals(200));
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data['object'], equals('collection'));
        expect(response.data['data'], isA<List<dynamic>>());
      },
    );

    test('deve retornar mock de level_progressions quando '
        'path contém "level_progressions"', () async {
      // Arrange
      const String expectedPath = '/level_progressions';

      // Act
      final Response<dynamic> response = await dio.get<dynamic>(expectedPath);

      // Assert
      expect(response.statusCode, equals(200));
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['object'], equals('collection'));
      expect(response.data['data'], isA<List<dynamic>>());
    });

    test('deve simular delay de rede de aproximadamente 500ms', () async {
      // Arrange
      const String path = '/assignments';
      final Stopwatch stopwatch = Stopwatch()..start();

      // Act
      await dio.get<dynamic>(path);
      stopwatch.stop();

      // Assert
      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(400),
      ); // Tolerância de 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(700)); // Máximo 700ms
    });

    test('deve rejeitar quando mock não existe', () async {
      // Arrange
      const String invalidPath = '/invalid_endpoint';

      // Act & Assert
      expect(() => dio.get<dynamic>(invalidPath), throwsA(isA<DioException>()));
    });

    test('deve preservar requestOptions no response', () async {
      // Arrange
      const String path = '/assignments';

      // Act
      final Response<dynamic> response = await dio.get<dynamic>(path);

      // Assert
      expect(response.requestOptions.path, equals(path));
      expect(
        response.requestOptions.baseUrl,
        equals('https://api.wanikani.com/v2'),
      );
    });
  });
}
