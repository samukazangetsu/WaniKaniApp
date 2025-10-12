import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_state.dart';
import 'package:wanikani_app/features/home/presentation/widgets/dashboard_metric_card.dart';
import 'package:wanikani_app/features/home/utils/home_strings.dart';

/// Tela principal do dashboard WaniKani.
///
/// Exibe:
/// - Nível atual do usuário
/// - Número de reviews disponíveis
/// - Número de lessons disponíveis
///
/// Consome [HomeCubit] para gerenciar estado.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(HomeStrings.appBarTitle), centerTitle: true),
    body: BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) => switch (state) {
        HomeInitial() => const SizedBox.shrink(),
        HomeLoading() => const Center(child: CircularProgressIndicator()),
        HomeError(:final String message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                HomeStrings.errorTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(message),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().loadDashboardData();
                },
                child: Text(HomeStrings.retryButton),
              ),
            ],
          ),
        ),
        HomeLoaded(
          :final int currentLevel,
          :final int reviewCount,
          :final int lessonCount,
        ) =>
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DashboardMetricCard(
                  title: HomeStrings.levelLabel,
                  value: currentLevel.toString(),
                  icon: Icons.grade,
                ),
                const SizedBox(height: 16),
                DashboardMetricCard(
                  title: HomeStrings.reviewsLabel,
                  value: reviewCount.toString(),
                  icon: Icons.rate_review,
                ),
                const SizedBox(height: 16),
                DashboardMetricCard(
                  title: HomeStrings.lessonsLabel,
                  value: lessonCount.toString(),
                  icon: Icons.school,
                ),
              ],
            ),
          ),
      },
    ),
  );
}
