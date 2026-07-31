import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/app_validators.dart';
import 'package:split_ease/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:split_ease/features/auth/presentation/widgets/auth_background.dart';
import 'package:split_ease/features/auth/presentation/widgets/google_icon.dart';

import 'package:split_ease/core/theme/app_color_tokens.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/auth_field.dart';
import '../../login/widgets/primary_button.dart';
import '../../login/widgets/social_button.dart';
import '../../../../../core/config/feature_flags.dart';
import 'register_success_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final ValueNotifier<bool> _isObscured = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterSuccessPage(),
            ),
          );
        } else if (state is RegisterGoogleSuccess) {
          AppAlerts.showSuccess(context, state.message);
          NavigationService.pushReplacement(AppRoutes.home);
        } else if (state is RegisterFailure) {
          AppAlerts.showError(context, state.message);
        }
      },
      child: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Refined Navigation & Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => NavigationService.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).ext.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Theme.of(context).ext.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "INSTANT ACCESS",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. Immersive Greeting
              Text(
                "Create Account",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).ext.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join thousands of users splitting expenses\neasily every single day.",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Theme.of(context).ext.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 48),

              // 3. Optimized Form Layout
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Enhanced Name Field
                    AuthField(
                      label: "Full Name",
                      hint: "John Doe",
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      validator: AppValidators.validateName,
                    ),
                    const SizedBox(height: 20),

                    // Enhanced Email Field
                    AuthField(
                      label: "Work Email",
                      hint: "yourname@provider.com",
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Enhanced Password Field
                    ValueListenableBuilder<bool>(
                      valueListenable: _isObscured,
                      builder: (context, isObscured, child) {
                        return AuthField(
                          label: "Secure Password",
                          hint: "Min. 6 characters",
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
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 4. Primary Action with Security Hint
              Column(
                children: [
                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (_, state) {
                      return AppPrimaryButton(
                        isLoading: state is RegisterLoading,
                        text: "Create My Account",
                        onPressed: () {
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: Theme.of(context).ext.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Your data is encrypted and secure",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Theme.of(context).ext.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 5. Social Options
              if (FeatureFlags.isSocialAuthEnabled) ...[
                Row(
                  children: [
                    Expanded(child: Divider(color: Theme.of(context).ext.border.withValues(alpha: 0.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "QUICK ACCESS",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).ext.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Theme.of(context).ext.border.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<RegisterBloc, RegisterState>(
                  builder: (context, state) {
                    final isLoading = state is RegisterGoogleLoading;
                    return SocialButton(
                      text: "Google",
                      onPressed: isLoading
                          ? () {}
                          : () => context.read<RegisterBloc>().add(
                              GoogleSignInRequested(),
                            ),
                      icon: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const GoogleIcon(size: 20),
                    );
                  },
                ),
              ],

              const SizedBox(height: 48),

              // 6. Seamless Transition to Login
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: Theme.of(context).ext.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: "Already a member? "),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () => NavigationService.pop(),
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
