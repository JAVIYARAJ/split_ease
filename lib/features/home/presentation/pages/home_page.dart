import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../groups/presentation/pages/groups_page.dart';
import '../../../activity/presentation/pages/activity_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../friends/presentation/bloc/friends_bloc.dart';
import '../../../groups/presentation/bloc/groups_bloc.dart';
import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      backgroundColor: AppColors.backgroundWhite,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<FriendsBloc>()..add(LoadFriends())),
          BlocProvider(create: (_) => sl<GroupsBloc>()..add(LoadGroups())),
          BlocProvider(create: (_) => sl<ActivityBloc>()..add(LoadActivities())),
          BlocProvider(create: (_) => sl<AccountBloc>()),
        ],
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Body Content (Switch based on tabIndex)
                IndexedStack(
                  index: state.tabIndex,
                  children: [
                    Center(
                      child: Text(
                        "Home Tab Content",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    const FriendsPage(),
                    const GroupsPage(),
                    const ActivityPage(),
                    const AccountPage(),
                  ],
                ),

                // Floating Bottom Nav Bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8), // Semi-transparent for glass effect
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism
                          child: Material(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildNavItem(
                                  context,
                                  activeIcon: Icons.home_rounded,
                                  inactiveIcon: Icons.home_outlined,
                                  label: "Home",
                                  isActive: state.tabIndex == 0,
                                  onTap: () => context.read<HomeBloc>().add(HomeTabChanged(0)),
                                ),
                                _buildNavItem(
                                  context,
                                  activeIcon: Icons.person_rounded,
                                  inactiveIcon: Icons.person_outline_rounded,
                                  label: "Friends",
                                  isActive: state.tabIndex == 1,
                                  onTap: () => context.read<HomeBloc>().add(HomeTabChanged(1)),
                                ),
                                _buildNavItem(
                                  context,
                                  activeIcon: Icons.groups_rounded,
                                  inactiveIcon: Icons.groups_outlined,
                                  label: "Groups",
                                  isActive: state.tabIndex == 2,
                                  onTap: () => context.read<HomeBloc>().add(HomeTabChanged(2)),
                                ),
                                _buildNavItem(
                                  context,
                                  activeIcon: Icons.receipt_long_rounded,
                                  inactiveIcon: Icons.receipt_long_outlined,
                                  label: "Activity",
                                  isActive: state.tabIndex == 3,
                                  onTap: () => context.read<HomeBloc>().add(HomeTabChanged(3)),
                                ),
                                _buildNavItem(
                                  context,
                                  activeIcon: Icons.account_circle_rounded,
                                  inactiveIcon: Icons.account_circle_outlined,
                                  label: "Account",
                                  isActive: state.tabIndex == 4,
                                  onTap: () => context.read<HomeBloc>().add(HomeTabChanged(4)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primary : AppColors.iconGrey,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.iconGrey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
