import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/app_validators.dart';
import 'package:split_ease/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:split_ease/core/presentation/widgets/animations/staggered_entry_column.dart';
import 'package:split_ease/features/auth/presentation/widgets/rotating_logo.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/auth_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import '../../../../../core/config/feature_flags.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  final TextEditingController _emailController = TextEditingController(text: "test@mailinator.com");
  final TextEditingController _passwordController = TextEditingController(text: "Test@123");

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure) {
          AppAlerts.showError(context, state.message);
        } else if (state.status == LoginStatus.success) {
          AppAlerts.showSuccess(context, state.message);
          NavigationService.pushReplacement(AppRoutes.home);
        } else if (state.status == LoginStatus.registerNavigation) {
          NavigationService.pushReplacement(AppRoutes.register);
        }
      },
      child: BaseScreen(
        backgroundColor: AppColors.backgroundWhite,
        extendBodyBehindAppBar: true,
        child: Stack(
          children: [
            // 1. Static Ambient Background (Clean, no breathing)
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryAccent.withValues(alpha: 0.1)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueGrey.withValues(alpha: 0.05)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
              ),
            ),

            // 2. Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StaggeredEntryColumn(
                  children: [
                    const SizedBox(height: 60),

                    // Inside build method:
                    // Logo
                    const RotatingLogo(),
                    const SizedBox(height: 24),

                    // Titles
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.2, color: AppColors.textBlack),
                        children: const [
                          TextSpan(text: "Welcome Back to\n"),
                          TextSpan(
                            text: "Split Ease",
                            style: TextStyle(color: Color(0xFFDAB318)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Track shared expenses, manage group bills,\nand travel debt-free.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey, height: 1.5),
                    ),
                    const SizedBox(height: 40),

                    // White Card Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email
                            AuthField(
                              label: "Email Address",
                              hint: "user@splitease.com",
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              validator: AppValidators.validateEmail,
                            ),

                            const SizedBox(height: 20),

                            // Password
                            AuthField(
                              label: "Password",
                              hint: "• • • • • •",
                              isPassword: true,
                              isObscured: _isObscured,
                              controller: _passwordController,
                              icon: Icons.lock_outline_rounded,
                              validator: AppValidators.validatePasswordLogin,
                              onToggleVisibility: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            if (FeatureFlags.isForgotPasswordEnabled) ...[
                              // Forgot PW
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Color(0xFFDAB318), fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            BlocBuilder<LoginBloc, LoginState>(
                              buildWhen: (previous, current) => previous != current,
                              builder: (context, state) {
                                return AppPrimaryButton(
                                  isLoading: state.status == LoginStatus.loading,
                                  text: "Log In",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<LoginBloc>().add(LoginUser(email: _emailController.text, password: _passwordController.text));
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (FeatureFlags.isSocialAuthEnabled) ...[
                      const SizedBox(height: 30),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.borderGrey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("Or continue with", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
                          ),
                          const Expanded(child: Divider(color: AppColors.borderGrey)),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Socials
                      Row(
                        children: [
                          Expanded(
                            child: SocialButton(
                              text: "Google",
                              onPressed: () {},
                              icon: const Text(
                                "G",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Roboto'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SocialButton(
                              text: "Apple",
                              onPressed: () {},
                              icon: const Icon(Icons.apple, color: Colors.black, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New to Split Ease? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey, fontSize: 14)),
                        GestureDetector(
                          onTap: () {
                            NavigationService.pushNamed(AppRoutes.register);
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Color(0xFFDAB318), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
