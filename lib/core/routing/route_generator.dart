import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:split_ease/features/auth/presentation/login/pages/login_page.dart';
import 'package:split_ease/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:split_ease/features/auth/presentation/register/pages/register_page.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:split_ease/features/groups/presentation/bloc/join_group_bloc.dart';
import 'package:split_ease/features/home/presentation/pages/home_page.dart';
import 'package:split_ease/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:split_ease/features/welcome/presentation/cubit/welcome_cubit.dart';
import 'package:split_ease/features/welcome/presentation/pages/welcome_page.dart';
import '../../features/groups/presentation/bloc/create_group_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/splash/presentation/pages/splash_pages.dart';
import '../../injection_container.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/groups/presentation/pages/enter_invite_code_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import 'app_routes.dart';

// Import pages

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<SplashCubit>(),
              child: SplashPages(),
            ));
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<WelcomeCubit>(),
              child: WelcomePage(),
            ));
      case AppRoutes.login:
        return MaterialPageRoute(
            builder: (_) =>
                BlocProvider(
                  create: (context) => sl<LoginBloc>(),
                  child: LoginPage(),
                ));
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<RegisterBloc>(),
              child: RegisterPage(),
            ));
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<HomeBloc>(),
              child: HomePage(),
            ));
      case AppRoutes.createGroup:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<CreateGroupBloc>(),
              child: const CreateGroupPage(),
            ),settings: RouteSettings(name: settings.name,arguments: settings.arguments));
      case AppRoutes.groupDetail:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<GroupDetailBloc>(),
              child: GroupDetailPage(),
            ),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name)
        );
      case AppRoutes.enterInviteCode:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<JoinGroupBloc>(),
              child: EnterInviteCodePage(),
            ));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}
