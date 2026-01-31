import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class BaseScreen extends StatelessWidget {
  /// The main content of the screen.
  final Widget child;

  /// Optional AppBar.
  final PreferredSizeWidget? appBar;

  /// Whether to show a full-screen loading overlay.
  final bool isLoading;

  /// Error message to display. If provided, replaces [child] with an error view.
  final String? errorMessage;

  /// Callback for the retry button in the error view.
  final VoidCallback? onRetry;

  /// Custom background color. Defaults to [Scaffold] background color from theme.
  final Color? backgroundColor;

  /// Whether to wrap the body in a [SafeArea]. Defaults to true.
  final bool useSafeArea;

  /// Whether to unfocus the keyboard when tapping outside input fields. Defaults to true.
  final bool unfocusOnTap;

  /// Whether the body should resize when the keyboard appears.
  final bool resizeToAvoidBottomInset;

  /// Custom [SystemUiOverlayStyle] for status bar appearance.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Intercept back button press. Return `true` to allow pop, `false` to prevent.
  final Future<bool> Function()? onWillPop;

  /// Floating Action Button.
  final Widget? floatingActionButton;

  /// Whether to extend the body behind the AppBar.
  final bool extendBodyBehindAppBar;

  /// Bottom Navigation Bar
  final Widget? bottomNavigationBar;

  const BaseScreen({
    super.key,
    required this.child,
    this.appBar,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.backgroundColor,
    this.useSafeArea = true,
    this.unfocusOnTap = true,
    this.resizeToAvoidBottomInset = true,
    this.systemOverlayStyle,
    this.onWillPop,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status bar brightness based on background color or theme
    final brightness = Theme.of(context).colorScheme.brightness;
    
    // Default system overlay style based on brightness
    final defaultOverlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    Widget content = AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle ?? defaultOverlayStyle,
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        appBar: appBar,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: _buildBody(context),
      ),
    );

    // Unfocus keyboard on touch outside
    if (unfocusOnTap) {
      content = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: content,
      );
    }

    // Handle back button interception
    if (onWillPop != null) {
      content = PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await onWillPop!();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop(result);
          }
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildBody(BuildContext context) {
    Widget bodyContent = child;

    // Show Error View if errorMessage is present
    if (errorMessage != null) {
      bodyContent = _ErrorView(
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    // Apply SafeArea if requested
    if (useSafeArea) {
      bodyContent = SafeArea(child: bodyContent);
    }

    // Stack Loading Overlay on top
    return Stack(
      children: [
        bodyContent,
        if (isLoading)
          const _LoadingOverlay(),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              "Oops, something went wrong",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3), // Semi-transparent black
      child: const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}