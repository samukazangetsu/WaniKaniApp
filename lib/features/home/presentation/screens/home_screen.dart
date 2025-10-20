import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanikani_app/core/theme/theme.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_state.dart';
import 'package:wanikani_app/features/home/utils/home_strings.dart';

/// Tela principal do dashboard WaniKani.
///
/// Exibe:
/// - Nível atual do usuário
/// - Número de reviews disponíveis
/// - Número de lessons disponíveis
///
/// Consome [HomeCubit] para gerenciar estado.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<HomeCubit>();
        if (cubit.state is HomeInitial) {
          cubit.loadDashboardData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: WaniKaniColors.background,
    appBar: WaniKaniAppBar.root(
      HomeStrings.greetingWelcomeBack,
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined),
          tooltip: HomeStrings.settingsTooltip,
          onPressed: () {
            // TODO: Navegar para configurações
          },
        ),
      ],
    ),
    body: BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) => switch (state) {
        HomeInitial() => const SizedBox.shrink(),
        HomeLoading() => const Center(child: CircularProgressIndicator()),
        HomeError(:final String message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(HomeStrings.errorTitle, style: WaniKaniTextStyles.h2),
              const SizedBox(height: 16),
              Text(message, style: WaniKaniTextStyles.body),
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
          :final int? currentLevel,
          :final int? reviewCount,
          :final int? lessonCount,
        ) =>
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: WaniKaniDesign.spacingMd),

                // Card de progresso do nível (oculta se não carregou)
                if (currentLevel != null)
                  LevelProgressCard(
                    currentLevel: currentLevel,
                    progress: 0.75, // 75% como na imagem
                    totalItems: 20, // 20 itens como na imagem
                    completedItems: 15, // 15 completados
                    onTap: () {
                      // TODO: Navegar para detalhes do nível
                    },
                  ),

                if (currentLevel != null)
                  SizedBox(height: WaniKaniDesign.spacingSm),

                // Card de Reviews (oculta se não carregou)
                if (reviewCount != null)
                  StudyMetricCard.reviews(
                    value: reviewCount.toString(),
                    enabled: reviewCount > 0,
                    onTap: reviewCount > 0
                        ? () {
                            // TODO: Navegar para reviews
                          }
                        : null,
                  ),

                // Card de Lessons (oculta se não carregou)
                if (lessonCount != null)
                  StudyMetricCard.lessons(
                    value: lessonCount.toString(),
                    enabled: lessonCount > 0,
                    onTap: lessonCount > 0
                        ? () {
                            // TODO: Navegar para lessons
                          }
                        : null,
                  ),
              ],
            ),
          ),
      },
    ),
  );
}
