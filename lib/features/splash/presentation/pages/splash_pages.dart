import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_assets.dart';
import 'package:split_ease/features/splash/presentation/cubit/splash_cubit.dart';

class SplashPages extends StatefulWidget {
  const SplashPages({super.key});

  @override
  State<SplashPages> createState() => _SplashPagesState();
}

class _SplashPagesState extends State<SplashPages> {
  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToWelcome) {
          NavigationService.pushReplacement(AppRoutes.welcome);
        }else if(state is SplashNavigateToLogin){
          NavigationService.pushReplacement(AppRoutes.login);
        }else if(state is SplashNavigateToHome){
          NavigationService.pushReplacement(AppRoutes.home);
        }
      },
      child: BaseScreen(
        child: Center(
          child: Lottie.asset(AppAssets.icWelcomeBanner, width: double.maxFinite, height: 200, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
