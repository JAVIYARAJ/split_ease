import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class GroupTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GroupTypeCard({super.key, required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80, // Approximate square size from screenshot
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.successGreen : AppColors.borderGreyLight, // Green if selected, grey otherwise
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.successGreen.withAlpha(10), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.textBlack, // Icons in screenshot look black/dark grey
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textBlack),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
