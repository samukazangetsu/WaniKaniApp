import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wanikani_app/core/dependency_injection/dependency_injection.dart';
import 'package:wanikani_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:wanikani_app/features/home/presentation/screens/home_screen.dart';
import 'package:wanikani_app/features/login/presentation/cubits/loading_cubit.dart';
import 'package:wanikani_app/features/login/presentation/cubits/login_cubit.dart';
import 'package:wanikani_app/features/login/presentation/screens/loading_screen.dart';
import 'package:wanikani_app/features/login/presentation/screens/login_screen.dart';
import 'package:wanikani_app/routing/app_routes.dart';

/// Configuração de rotas da aplicação usando go_router.
mixin AppRouter {
  static GoRouter router({String? initialLocation}) => GoRouter(
    initialLocation: initialLocation ?? AppRoutes.loading.path,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.loading.path,
        name: AppRoutes.loading.name,
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<LoadingCubit>(
              create: (_) => getIt<LoadingCubit>(),
              child: const LoadingScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<LoginCubit>(
              create: (_) => getIt<LoginCubit>(),
              child: const LoginScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<HomeCubit>.value(
              value: getIt<HomeCubit>(),
              child: const HomeScreen(),
            ),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        Scaffold(body: Center(child: Text('Erro: ${state.error}'))),
  );
}
