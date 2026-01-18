
// --- Light Theme Auth Field ---
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final bool isObscured;
  final IconData? icon;
  final VoidCallback? onToggleVisibility;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.isObscured = false,
    this.icon,
    this.onToggleVisibility,
    this.controller,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller?.text, // Sync initial value from controller
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Focus(
              onFocusChange: (hasFocus) {
                setState(() => _isFocused = hasFocus);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite, // Very light grey
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    // Border becomes Yellow when focused, Red when error, grey otherwise
                    color: state.hasError
                        ? AppColors.errorRed
                        : _isFocused
                            ? AppColors.primaryAccentDark
                            : AppColors.borderGrey,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isObscured,
                  style: Theme.of(context).textTheme.bodyLarge,
                  cursorColor: AppColors.primaryAccentDark,
                  onChanged: (value) {
                    state.didChange(value);
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGrey,
                        ),
                    prefixIcon: widget.icon != null
                        ? Icon(widget.icon,
                            color: _isFocused ? AppColors.primaryAccentDark : Colors.grey,
                            size: 20)
                        : null,
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
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                child: Text(
                  state.errorText ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.errorRed,
                        fontSize: 12,
                      ),
                ),
              ),
          ],
        );
      },
    );
  }
}
