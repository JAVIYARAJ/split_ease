
// --- Light Theme Auth Field ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AuthField extends StatefulWidget {
  final String? label;
  final String hint;
  final bool isPassword;
  final bool isObscured;
  final IconData? icon;
  final VoidCallback? onToggleVisibility;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isReadyOnly;

  const AuthField({
    super.key,
    this.label,
    required this.hint,
    this.isPassword = false,
    this.isObscured = false,
    this.icon,
    this.onToggleVisibility,
    this.controller,
    this.validator,
    this.isReadyOnly = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isObscured,
          readOnly: widget.isReadyOnly,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderGreyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderGreyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, color: Colors.grey, size: 20)
                : null,
            prefixIconColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.focused)
                    ? AppColors.primary
                    : Colors.grey),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      widget.isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: widget.onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
