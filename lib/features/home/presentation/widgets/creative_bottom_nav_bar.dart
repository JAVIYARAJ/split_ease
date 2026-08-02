import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class NavItemData {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavItemData({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

/// Creative Floating Glass Island Bottom Navigation Bar for SplitEase
class CreativeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  static const List<NavItemData> items = [
    NavItemData(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: "Home",
    ),
    NavItemData(
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: "Friends",
    ),
    NavItemData(
      activeIcon: Icons.groups_rounded,
      inactiveIcon: Icons.groups_outlined,
      label: "Groups",
    ),
    NavItemData(
      activeIcon: Icons.receipt_long_rounded,
      inactiveIcon: Icons.receipt_long_outlined,
      label: "Activity",
    ),
    NavItemData(
      activeIcon: Icons.account_circle_rounded,
      inactiveIcon: Icons.account_circle_outlined,
      label: "Account",
    ),
  ];

  const CreativeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).isDark;
    final AppColorTokens tokens = Theme.of(context).ext;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.surface.withValues(alpha: isDark ? 0.85 : 0.92),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : tokens.borderLight.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double totalWidth = constraints.maxWidth;
                    final int itemCount = items.length;
                    final double itemWidth = totalWidth / itemCount;

                    return Stack(
                      children: [
                        // 1. Fluid Sliding Active Pill Background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * itemWidth + 2,
                          top: 2,
                          width: itemWidth - 4,
                          height: constraints.maxHeight - 4,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        AppColors.primary.withValues(alpha: 0.28),
                                        AppColors.secondary.withValues(alpha: 0.18),
                                      ]
                                    : [
                                        AppColors.primary.withValues(alpha: 0.14),
                                        AppColors.primary.withValues(alpha: 0.06),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: isDark ? 0.35 : 0.2,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? 0.25 : 0.08,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Interactive Navigation Items
                        Row(
                          children: List.generate(itemCount, (index) {
                            final item = items[index];
                            final bool isActive = currentIndex == index;

                            return Expanded(
                              child: _CreativeNavItem(
                                item: item,
                                isActive: isActive,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onTabSelected(index);
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreativeNavItem extends StatefulWidget {
  final NavItemData item;
  final bool isActive;
  final VoidCallback onTap;

  const _CreativeNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CreativeNavItem> createState() => _CreativeNavItemState();
}

class _CreativeNavItemState extends State<_CreativeNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).isDark;
    final AppColorTokens tokens = Theme.of(context).ext;

    final Color activeColor = AppColors.primary;
    final Color inactiveColor = isDark
        ? tokens.textTertiary.withValues(alpha: 0.8)
        : tokens.textSecondary.withValues(alpha: 0.7);

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Icon with Scale + Switcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: child,
                  );
                },
                child: Icon(
                  widget.isActive
                      ? widget.item.activeIcon
                      : widget.item.inactiveIcon,
                  key: ValueKey(widget.isActive),
                  color: widget.isActive ? activeColor : inactiveColor,
                  size: widget.isActive ? 21 : 19,
                ),
              ),

              const SizedBox(height: 1),

              // Animated Label
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    height: 1.1,
                    fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isActive ? activeColor : inactiveColor,
                    letterSpacing: 0.1,
                  ),
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(height: 1),

              // Active Accent Dot Indicator (Brand Yellow Glow)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: widget.isActive ? 3.5 : 0,
                height: widget.isActive ? 3.5 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandYellow,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandYellow.withValues(alpha: 0.8),
                      blurRadius: 3,
                      spreadRadius: 0.5,
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
