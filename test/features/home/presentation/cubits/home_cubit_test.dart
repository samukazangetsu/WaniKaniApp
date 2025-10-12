import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/assignment_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_assignment_metrics_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_state.dart';

// Mocks
class MockGetCurrentLevelUseCase extends Mock
    implements GetCurrentLevelUseCase {}

class MockGetAssignmentMetricsUseCase extends Mock
    implements GetAssignmentMetricsUseCase {}

void main() {
  late HomeCubit cubit;
  late MockGetCurrentLevelUseCase mockGetCurrentLevel;
  late MockGetAssignmentMetricsUseCase mockGetAssignmentMetrics;

  setUp(() {
    mockGetCurrentLevel = MockGetCurrentLevelUseCase();
    mockGetAssignmentMetrics = MockGetAssignmentMetricsUseCase();
    cubit = HomeCubit(
      getCurrentLevel: mockGetCurrentLevel,
      getAssignmentMetrics: mockGetAssignmentMetrics,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final LevelProgressionEntity tLevelProgression = LevelProgressionEntity(
    id: 1,
    level: 4,
    unlockedAt: DateTime(2025, 6, 5),
    startedAt: DateTime(2025, 6, 5),
    passedAt: null,
    completedAt: null,
    abandonedAt: null,
  );

  final List<AssignmentEntity> tAssignments = <AssignmentEntity>[
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
    const AssignmentEntity(
      id: 2,
      subjectId: 200,
      subjectType: 'radical',
      srsStage: 0,
      availableAt: null,
      unlockedAt: true,
      startedAt: null,
      passedAt: null,
      burnedAt: null,
    ),
  ];

  group('HomeCubit', () {
    test('estado inicial deve ser HomeInitial', () {
      expect(cubit.state, equals(const HomeInitial()));
    });

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Loaded] quando ambos use cases retornam sucesso',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(
          () => mockGetAssignmentMetrics(),
        ).thenAnswer((_) async => Right(tAssignments));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => <HomeState>[
        const HomeLoading(),
        HomeLoaded(
          levelProgression: tLevelProgression,
          assignments: tAssignments,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetAssignmentMetrics()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Error] quando getCurrentLevel falha',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        when(
          () => mockGetAssignmentMetrics(),
        ).thenAnswer((_) async => Right(tAssignments));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => const <HomeState>[HomeLoading(), HomeError('Erro de rede')],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        // Não deve chamar getAssignments se getCurrentLevel falha
        verifyNever(() => mockGetAssignmentMetrics());
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Error] quando getAssignmentMetrics falha',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(() => mockGetAssignmentMetrics()).thenAnswer(
          (_) async => Left(InternalErrorEntity('Erro ao buscar assignments')),
        );
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => const <HomeState>[
        HomeLoading(),
        HomeError('Erro ao buscar assignments'),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetAssignmentMetrics()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'HomeLoaded deve calcular reviewCount e lessonCount corretamente',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(
          () => mockGetAssignmentMetrics(),
        ).thenAnswer((_) async => Right(tAssignments));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      verify: (_) {
        final HomeState state = cubit.state;
        expect(state, isA<HomeLoaded>());
        final HomeLoaded loadedState = state as HomeLoaded;
        expect(loadedState.currentLevel, equals(4));
        expect(loadedState.reviewCount, equals(1)); // 1 review disponível
        expect(loadedState.lessonCount, equals(1)); // 1 lição disponível
      },
    );
  });
}
