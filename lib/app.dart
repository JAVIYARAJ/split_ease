import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/theme.dart';
import 'core/routing/app_routes.dart';
import 'core/routing/route_generator.dart';
import 'core/routing/navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/common/cubit/app_user_cubit.dart';
import 'injection_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AppUserCubit>(),
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
    
        // Routing
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
        navigatorKey: NavigationService.navigatorKey,
    
        // Theme (optional)
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
