import 'package:flutter/material.dart';
import 'dart:ui';
import '../enums/app_enums.dart';

class AppAlerts {
  // --- Success SnackBar ---
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message, type: AppAlertType.success, duration: duration);
  }

  // --- Error SnackBar ---
  static void showError(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message, type: AppAlertType.error, duration: duration);
  }

  // --- Warning SnackBar ---
  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message, type: AppAlertType.warning, duration: duration);
  }

  // --- Info SnackBar ---
  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message, type: AppAlertType.info, duration: duration);
  }

  static OverlayEntry? _activeEntry;

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required AppAlertType type,
    Duration? duration,
  }) {
    // Remove existing entry if any
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context);
    
    final config = _getAlertConfig(type);
    final displayDuration = duration ?? const Duration(seconds: 4);

    _activeEntry = OverlayEntry(
      builder: (context) => _TopAlertWidget(
        message: message,
        config: config,
        duration: displayDuration,
        onDismiss: () {
          if (_activeEntry != null) {
            _activeEntry?.remove();
            _activeEntry = null;
          }
        },
      ),
    );

    overlay.insert(_activeEntry!);
  }

  static _AlertConfig _getAlertConfig(AppAlertType type) {
    switch (type) {
      case AppAlertType.success:
        return _AlertConfig(
          title: "Success",
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981), // Vibrant Green
          backgroundColor: const Color(0xFFECFDF5), // Mint bg
        );
      case AppAlertType.error:
        return _AlertConfig(
          title: "Error",
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444), // Vibrant Red
          backgroundColor: const Color(0xFFFEF2F2), // Light Red bg
        );
      case AppAlertType.warning:
        return _AlertConfig(
          title: "Warning",
          icon: Icons.warning_rounded,
          color: const Color(0xFFF59E0B), // Vibrant Amber
          backgroundColor: const Color(0xFFFFFBEB), // Light Amber bg
        );
      case AppAlertType.info:
        return _AlertConfig(
          title: "Info",
          icon: Icons.info_rounded,
          color: const Color(0xFF3B82F6), // Vibrant Blue
          backgroundColor: const Color(0xFFEFF6FF), // Light Blue bg
        );
    }
  }
}

class _AlertConfig {
  final String title;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  _AlertConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class _TopAlertWidget extends StatefulWidget {
  final String message;
  final _AlertConfig config;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopAlertWidget({
    required this.message,
    required this.config,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopAlertWidget> createState() => _TopAlertWidgetState();
}

class _TopAlertWidgetState extends State<_TopAlertWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Show
    _controller.forward();

    // Auto Hide
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: widget.config.backgroundColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.config.color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.config.color.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient accent bar on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.config.color,
                        widget.config.color.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.config.color.withValues(alpha: 0.15),
                            widget.config.color.withValues(alpha: 0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.config.color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.config.icon,
                        color: widget.config.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.config.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: widget.config.color,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withValues(alpha: 0.75),
                              height: 1.4,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close button
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.config.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: widget.config.color.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
