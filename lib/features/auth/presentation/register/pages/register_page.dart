import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/app_validators.dart';
import 'package:split_ease/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:split_ease/core/presentation/widgets/animations/staggered_entry_column.dart';
import 'package:split_ease/features/auth/presentation/widgets/rotating_logo.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/auth_field.dart';
import '../../login/widgets/primary_button.dart';
import '../../login/widgets/social_button.dart';
import '../../../../../core/config/feature_flags.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Local State
  final ValueNotifier<bool> _isObscured = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _isObscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          AppAlerts.showSuccess(context, state.message);
          NavigationService.pop();
        } else if (state is RegisterFailure) {
          AppAlerts.showError(context, state.message);
        }
      },
      child: BaseScreen(
        backgroundColor: AppColors.backgroundWhite,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        child: Stack(
          children: [
            // 1. Ambient Background ( consistent with Login )
            Positioned(
              top: -80,
              right: -80, // Different position for variety
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.05)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
              ),
            ),

            // 2. Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StaggeredEntryColumn(
                  children: [
                    const SizedBox(height: 80),

                    // Logo
                    const RotatingLogo(),
                    const SizedBox(height: 24),

                    // Header
                    Text(
                      "Create Account",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Join Split Ease today and start managing\nyour expenses effortlessly.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // White Form Card
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
                            // --- 1. Full Name Field (New) ---
                            AuthField(
                              label: "Full Name",
                              hint: "John Doe",
                              controller: _nameController,
                              icon: Icons.person_outline_rounded,
                              validator: AppValidators.validateName,
                            ),

                            const SizedBox(height: 20),

                            // --- 2. Email Field ---
                            AuthField(
                              label: "Email Address",
                              hint: "user@splitease.com",
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              validator: AppValidators.validateEmail,
                            ),

                            const SizedBox(height: 20),

                            // --- 3. Password Field ---
                            ValueListenableBuilder<bool>(
                              valueListenable: _isObscured,
                              builder: (context, isObscured, child) {
                                return AuthField(
                                  label: "Password",
                                  hint: "Create a strong password",
                                  isPassword: true,
                                  isObscured: isObscured,
                                  controller: _passwordController,
                                  icon: Icons.lock_outline_rounded,
                                  onToggleVisibility: () {
                                    _isObscured.value = !_isObscured.value;
                                  },
                                  validator: AppValidators.validatePasswordRegister,
                                );
                              },
                            ),

                          const SizedBox(height: 30),

                          // Sign Up Button
                          BlocBuilder<RegisterBloc, RegisterState>(
                            builder: (_, state) {
                              return AppPrimaryButton(
                                isLoading: state is RegisterLoading,
                                text: "Sign Up",
                                onPressed: () {
                                  // Handle Registration Logic
                                  if (_formKey.currentState!.validate()) {
                                    context.read<RegisterBloc>().add(
                                          RegisterUser(
                                            email: _emailController.text.trim(),
                                            name: _nameController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),),

                    if (FeatureFlags.isSocialAuthEnabled) ...[
                      const SizedBox(height: 30),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.borderGrey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("Or sign up with",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
                          ),
                          const Expanded(child: Divider(color: AppColors.borderGrey)),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SocialButton(
                              text: "Google",
                              onPressed: () {},
                              icon: const Text(
                                "G",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    fontFamily: 'Roboto'),
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

                    // Footer (Navigate back to Login)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey, fontSize: 14)),
                        GestureDetector(
                          onTap: () {
                            NavigationService.pop();
                          },
                          child: const Text(
                            "Log In",
                            style: TextStyle(color: Color(0xFFDAB318), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
