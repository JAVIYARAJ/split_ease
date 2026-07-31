import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/common/cubit/theme_cubit.dart';
import 'package:split_ease/core/theme/theme.dart';
import 'core/routing/app_routes.dart';
import 'core/routing/route_generator.dart';
import 'core/routing/navigation_service.dart';
import 'core/common/cubit/app_user_cubit.dart';
import 'core/services/data_refresh_service.dart';
import 'injection_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AppUserCubit>()),
        BlocProvider(create: (context) => sl<DataRefreshCubit>()),
        BlocProvider(create: (context) => sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'SplitEase',
            debugShowCheckedModeBanner: false,

            // Routing
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            navigatorKey: NavigationService.navigatorKey,

            // Themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            builder: (context, child) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
