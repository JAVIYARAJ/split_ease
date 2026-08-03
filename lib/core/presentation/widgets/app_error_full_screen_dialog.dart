import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';

/// A dynamic, reusable full-screen error widget/dialog.
/// Displays an error state with an interactive "Try Again" button for unlimited retries.
class AppErrorFullScreenWidget extends StatefulWidget {
  final String? errorMessage;
  final Future<bool> Function() onRefresh;
  final VoidCallback? onClose;

  const AppErrorFullScreenWidget({
    super.key,
    required this.onRefresh,
    this.errorMessage,
    this.onClose,
  });

  @override
  State<AppErrorFullScreenWidget> createState() => _AppErrorFullScreenWidgetState();
}

class _AppErrorFullScreenWidgetState extends State<AppErrorFullScreenWidget> with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      final success = await widget.onRefresh();
      if (success) {
        widget.onClose?.call();
        return;
      }
    } catch (_) {
      // Catch any unexpected error during refresh
    }

    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).ext;

    final String displayMessage = kDebugMode
        ? (widget.errorMessage != null && widget.errorMessage!.isNotEmpty
            ? widget.errorMessage!
            : "An unexpected error occurred. Please try again.")
        : "Something went wrong while processing your request. Please try again.";

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(),
              // Animated Icon Container
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                "Something Went Wrong",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Subtitle / Error Message
              Text(
                displayMessage,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Actions: Try Again Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _handleRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppColors.primaryTeal.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Try Again",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (widget.onClose != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Dismiss",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              const SizedBox(height: 100), // Bottom clearance for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper dialog class to present [AppErrorFullScreenWidget] modally.
class AppErrorFullScreenDialog {
  static Future<void> show({
    required BuildContext context,
    required Future<bool> Function() onRefresh,
    String? errorMessage,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (dialogContext) => AppErrorFullScreenWidget(
        onRefresh: onRefresh,
        errorMessage: errorMessage,
        onClose: () {
          Navigator.of(dialogContext).pop();
          onClose?.call();
        },
      ),
    );
  }
}
