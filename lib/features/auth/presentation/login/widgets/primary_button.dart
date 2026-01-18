import 'package:flutter/cupertino.dart'; // Required for the Loader
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        // Logic: Pass empty function if loading to disable clicks
        // but keep the Yellow color (passing null turns it grey)
        onPressed: isLoading ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const CupertinoActivityIndicator(
          color: Colors.black, // Matches text color
        )
            : Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}