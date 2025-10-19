import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wanikani_app/core/error/internal_error_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/lesson_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/level_progression_entity.dart';
import 'package:wanikani_app/features/home/domain/entities/review_stats_entity.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_current_level_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_lesson_stats_usecase.dart';
import 'package:wanikani_app/features/home/domain/usecases/get_review_stats_usecase.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_state.dart';

// Mocks
class MockGetCurrentLevelUseCase extends Mock
    implements GetCurrentLevelUseCase {}

class MockGetReviewStatsUseCase extends Mock implements GetReviewStatsUseCase {}

class MockGetLessonStatsUseCase extends Mock implements GetLessonStatsUseCase {}

void main() {
  late HomeCubit cubit;
  late MockGetCurrentLevelUseCase mockGetCurrentLevel;
  late MockGetReviewStatsUseCase mockGetReviewStats;
  late MockGetLessonStatsUseCase mockGetLessonStats;

  setUp(() {
    mockGetCurrentLevel = MockGetCurrentLevelUseCase();
    mockGetReviewStats = MockGetReviewStatsUseCase();
    mockGetLessonStats = MockGetLessonStatsUseCase();
    cubit = HomeCubit(
      getCurrentLevel: mockGetCurrentLevel,
      getReviewStats: mockGetReviewStats,
      getLessonStats: mockGetLessonStats,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tLevelProgression = LevelProgressionEntity(
    id: 1,
    level: 4,
    unlockedAt: DateTime(2025, 6, 5),
    startedAt: DateTime(2025, 6, 5),
    passedAt: null,
    completedAt: null,
    abandonedAt: null,
  );

  const tReviewStats = ReviewStatsEntity(totalCount: 42);
  const tLessonStats = LessonStatsEntity(totalCount: 88);

  group('HomeCubit', () {
    test('estado inicial deve ser HomeInitial', () {
      expect(cubit.state, equals(const HomeInitial()));
    });

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Loaded] quando todos use cases retornam sucesso',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(
          () => mockGetReviewStats(),
        ).thenAnswer((_) async => const Right(tReviewStats));
        when(
          () => mockGetLessonStats(),
        ).thenAnswer((_) async => const Right(tLessonStats));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => <HomeState>[
        const HomeLoading(),
        HomeLoaded(
          levelProgression: tLevelProgression,
          reviewCount: 42,
          lessonCount: 88,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetReviewStats()).called(1);
        verify(() => mockGetLessonStats()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Error] apenas quando TODAS as requisições falham',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        when(
          () => mockGetReviewStats(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        when(
          () => mockGetLessonStats(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => const <HomeState>[
        HomeLoading(),
        HomeError('Não foi possível carregar os dados do dashboard'),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetReviewStats()).called(1);
        verify(() => mockGetLessonStats()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Loaded] com dados parciais quando apenas getCurrentLevel falha',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        when(
          () => mockGetReviewStats(),
        ).thenAnswer((_) async => const Right(tReviewStats));
        when(
          () => mockGetLessonStats(),
        ).thenAnswer((_) async => const Right(tLessonStats));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => <HomeState>[
        const HomeLoading(),
        const HomeLoaded(
          levelProgression: null,
          reviewCount: 42,
          lessonCount: 88,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetReviewStats()).called(1);
        verify(() => mockGetLessonStats()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Loaded] com dados parciais quando apenas getReviewStats falha',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(() => mockGetReviewStats()).thenAnswer(
          (_) async => Left(InternalErrorEntity('Erro ao buscar reviews')),
        );
        when(
          () => mockGetLessonStats(),
        ).thenAnswer((_) async => const Right(tLessonStats));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => <HomeState>[
        const HomeLoading(),
        HomeLoaded(
          levelProgression: tLevelProgression,
          reviewCount: null,
          lessonCount: 88,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetReviewStats()).called(1);
        verify(() => mockGetLessonStats()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Loaded] com dados parciais quando apenas getLessonStats falha',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(
          () => mockGetReviewStats(),
        ).thenAnswer((_) async => const Right(tReviewStats));
        when(() => mockGetLessonStats()).thenAnswer(
          (_) async => Left(InternalErrorEntity('Erro ao buscar lições')),
        );
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => <HomeState>[
        const HomeLoading(),
        HomeLoaded(
          levelProgression: tLevelProgression,
          reviewCount: 42,
          lessonCount: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetReviewStats()).called(1);
        verify(() => mockGetLessonStats()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'deve emitir [Loading, Loaded] com dados parciais quando duas requisições falham',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(
          () => mockGetReviewStats(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        when(
          () => mockGetLessonStats(),
        ).thenAnswer((_) async => Left(InternalErrorEntity('Erro de rede')));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      expect: () => <HomeState>[
        const HomeLoading(),
        HomeLoaded(
          levelProgression: tLevelProgression,
          reviewCount: null,
          lessonCount: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCurrentLevel()).called(1);
        verify(() => mockGetReviewStats()).called(1);
        verify(() => mockGetLessonStats()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'HomeLoaded deve usar reviewCount e lessonCount dos endpoints',
      build: () {
        when(
          () => mockGetCurrentLevel(),
        ).thenAnswer((_) async => Right(tLevelProgression));
        when(
          () => mockGetReviewStats(),
        ).thenAnswer((_) async => const Right(tReviewStats));
        when(
          () => mockGetLessonStats(),
        ).thenAnswer((_) async => const Right(tLessonStats));
        return cubit;
      },
      act: (HomeCubit cubit) => cubit.loadDashboardData(),
      verify: (_) {
        final state = cubit.state;
        expect(state, isA<HomeLoaded>());
        final loadedState = state as HomeLoaded;
        expect(loadedState.currentLevel, equals(4));
        expect(loadedState.reviewCount, equals(42)); // Do endpoint /reviews
        expect(
          loadedState.lessonCount,
          equals(88),
        ); // Do endpoint /study_materials
      },
    );

    test('hasAnyData deve retornar true quando há pelo menos um dado', () {
      const stateComTodos = HomeLoaded(
        levelProgression: LevelProgressionEntity(
          id: 1,
          level: 4,
          unlockedAt: null,
          startedAt: null,
          passedAt: null,
          completedAt: null,
          abandonedAt: null,
        ),
        reviewCount: 42,
        lessonCount: 88,
      );
      expect(stateComTodos.hasAnyData, isTrue);

      const stateParcial = HomeLoaded(
        levelProgression: null,
        reviewCount: null,
        lessonCount: 88,
      );
      expect(stateParcial.hasAnyData, isTrue);

      const stateVazio = HomeLoaded(
        levelProgression: null,
        reviewCount: null,
        lessonCount: null,
      );
      expect(stateVazio.hasAnyData, isFalse);
    });
  });
}
