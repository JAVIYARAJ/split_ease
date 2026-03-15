import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/account/presentation/bloc/feedback/feedback_cubit.dart';
import 'package:split_ease/features/account/presentation/bloc/feedback/feedback_state.dart';
import 'package:split_ease/injection_container.dart';

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<FeedbackCubit>(),
        child: const FeedbackSheet(),
      ),
    );
  }

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _onSuccessTransition(BuildContext context) {
    // Wait for the success animation to be visible to the user before popping
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        NavigationService.pop();
      }
    });
  }

  Widget _buildStar(BuildContext context, int index, int currentRating) {
    final isSelected = index <= currentRating;
    return GestureDetector(
      onTap: () {
        context.read<FeedbackCubit>().updateRating(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 44,
          color: isSelected ? Colors.amber : AppColors.borderGrey.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<FeedbackCubit, FeedbackState>(
      listener: (context, state) {
        if (state.status == FeedbackStatus.success) {
          _onSuccessTransition(context);
        } else if (state.status == FeedbackStatus.failure && state.errorMessage != null) {
          AppAlerts.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        bool isSuccess = state.status == FeedbackStatus.success;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: bottomInset > 0 ? bottomInset + 24 : 32,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: isSuccess
                ? _buildSuccessUI()
                : _buildFeedbackForm(context, state),
          ),
        );
      },
    );
  }

  // --- Success UI Section ---
  Widget _buildSuccessUI() {
    return Container(
      key: const ValueKey('success_state'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryTeal,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Thank you!",
            style: GoogleFonts.openSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Your feedback helps us improve Splitwise.",
            style: GoogleFonts.openSans(
              fontSize: 15,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Feedback Form Entry Section ---
  Widget _buildFeedbackForm(BuildContext context, FeedbackState state) {
    bool isSubmitting = state.status == FeedbackStatus.loading;

    return Column(
      key: const ValueKey('form_state'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderGrey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          "How's your experience?",
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "We'd love to hear your thoughts so we can improve.",
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Star Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => _buildStar(context, index + 1, state.rating)),
        ),

        const SizedBox(height: 32),

        // Feedback Text Field
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLightGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _feedbackController,
            onChanged: (val) => context.read<FeedbackCubit>().updateDescription(val),
            maxLines: 4,
            maxLength: 500,
            style: GoogleFonts.openSans(
              fontSize: 15,
              color: AppColors.textBlack,
            ),
            decoration: InputDecoration(
              hintText: "Tell us what you love or what could be better...",
              hintStyle: GoogleFonts.openSans(
                color: AppColors.textGrey.withValues(alpha: 0.7),
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              counterText: "",
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () {
                    FocusScope.of(context).unfocus(); // Dismiss keyboard on submit
                    context.read<FeedbackCubit>().submitFeedback();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    "Submit Feedback",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
