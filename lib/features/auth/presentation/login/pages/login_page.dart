import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/app_validators.dart';
import 'package:split_ease/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:split_ease/features/auth/presentation/widgets/auth_background.dart';
import 'package:split_ease/features/auth/presentation/widgets/google_icon.dart';

import 'package:split_ease/core/utils/auth_utils.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
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
  final ValueNotifier<bool> _isObscured = ValueNotifier<bool>(true);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showVerificationDialog(BuildContext loginContext) {
    showDialog(
      context: loginContext,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: loginContext.read<LoginBloc>(),
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.resendSuccess) {
              Future.delayed(const Duration(seconds: 2), () {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              });
            }
          },
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final bool isSent = state.status == LoginStatus.resendSuccess;
              final bool isResendLoading = state.status == LoginStatus.resendLoading;

              return AlertDialog(
                backgroundColor: Theme.of(context).ext.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                contentPadding: const EdgeInsets.all(24),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSent ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isSent ? "Verification Sent!" : "Verify Your Identity",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).ext.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSent
                          ? "A new verification link has been sent to your email. Please check your inbox."
                          : "It looks like you haven't confirmed your email address yet. Please check your inbox to activate your account.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 15, color: Theme.of(context).ext.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    AppPrimaryButton(
                      text: isSent ? "Open Mail App" : "Check Inbox",
                      onPressed: () => AuthUtils.openMailApp(),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: (isSent || isResendLoading)
                          ? null
                          : () {
                              context.read<LoginBloc>().add(ResendEmail(email: _emailController.text.trim()));
                            },
                      child: isResendLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              isSent ? "Email Sent Successfully" : "Resend Verification Link",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSent ? Theme.of(context).ext.textTertiary : AppColors.primary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        "Close",
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textTertiary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isObscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure) {
          if (state.message.toLowerCase().contains('email not confirmed')) {
            _showVerificationDialog(context);
          } else {
            AppAlerts.showError(context, state.message);
          }
        } else if (state.status == LoginStatus.success) {
          AppAlerts.showSuccess(context, state.message);
          NavigationService.pushReplacement(AppRoutes.home);
        } else if (state.status == LoginStatus.resendSuccess) {
          AppAlerts.showSuccess(context, state.message);
        } else if (state.status == LoginStatus.registerNavigation) {
          NavigationService.pushReplacement(AppRoutes.register);
        }
      },
      child: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Content & Illustration
              const SizedBox(height: 20),
              // Using the generated illustration path from context
              Image.asset(
                'assets/images/welcome_illustration.png', // Assuming user added to assets, but for demo I'll use a placeholder or Container with icon if asset not ready
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildFallbackIllustration(),
              ),
              const SizedBox(height: 32),
              
              Text(
                "Experience Effortless\nExpense Tracking",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).ext.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Split bills, track debt, and settle up with\nfriends—all in one beautiful place.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Theme.of(context).ext.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // 3. Simple Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthField(
                      label: "Email",
                      hint: "Enter your email",
                      controller: _emailController,
                      icon: Icons.alternate_email_rounded,
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isObscured,
                      builder: (context, isObscured, child) {
                        return AuthField(
                          label: "Password",
                          hint: "Enter your password",
                          isPassword: true,
                          isObscured: isObscured,
                          controller: _passwordController,
                          icon: Icons.lock_rounded,
                          validator: AppValidators.validatePasswordLogin,
                          onToggleVisibility: () {
                            _isObscured.value = !_isObscured.value;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              if (FeatureFlags.isForgotPasswordEnabled)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // 4. Action
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return AppPrimaryButton(
                    isLoading: state.status == LoginStatus.loading,
                    text: "Continue to Split Ease",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<LoginBloc>().add(LoginUser(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ));
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

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
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (p, c) => p.status != c.status,
                  builder: (context, state) {
                    final isLoading = state.status == LoginStatus.googleLoading;
                    return SocialButton(
                      text: "Google",
                      onPressed: isLoading
                          ? () {}
                          : () => context.read<LoginBloc>().add(GoogleSignInRequested()),
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

              // 6. Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "First time here? ",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: Theme.of(context).ext.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationService.pushNamed(AppRoutes.register);
                    },
                    child: Text(
                      "Join the group",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIllustration() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simplified Graphic Composition
          Positioned(
            left: 80,
            child: Icon(Icons.person_rounded, size: 100, color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          Positioned(
            right: 80,
            child: Icon(Icons.person_rounded, size: 100, color: AppColors.brandYellow.withValues(alpha: 0.2)),
          ),
          const Center(
            child: Icon(Icons.handshake_rounded, size: 80, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
