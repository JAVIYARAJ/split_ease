// --- Social Button (Light Mode) ---
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({super.key, required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: AppColors.borderGrey), // Grey border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white, // White fill
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}