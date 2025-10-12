import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wanikani_app/core/di/service_locator.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:wanikani_app/features/home/presentation/screens/home_screen.dart';

/// Configuração de rotas da aplicação usando go_router.
mixin AppRouter {
  static GoRouter router({String? initialLocation}) => GoRouter(
    initialLocation: initialLocation ?? '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<HomeCubit>(
              create: (BuildContext context) =>
                  getIt<HomeCubit>()..loadDashboardData(),
              child: const HomeScreen(),
            ),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        Scaffold(body: Center(child: Text('Erro: ${state.error}'))),
  );
}
