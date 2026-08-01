import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:google_fonts/google_fonts.dart';

class SmoothAnimatedFAB extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color? foregroundColor;
  final String heroTag;

  const SmoothAnimatedFAB({
    super.key,
    required this.isExtended,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.foregroundColor,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = foregroundColor ?? Colors.white;
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 16 : 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha:0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: fgColor, size: 28),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  width: isExtended ? 8 : 0,
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    child: SizedBox(
                      height: 56,
                      child: Center(
                        child: isExtended
                            ? Text(
                                label,
                                style: GoogleFonts.outfit(
                                  color: fgColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
