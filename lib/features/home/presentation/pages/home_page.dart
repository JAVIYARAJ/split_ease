import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/services/realtime_service.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RealtimeService _realtimeService = sl<RealtimeService>();

  @override
  void initState() {
    super.initState();
    _initRealtimeListener();
  }

  void _initRealtimeListener() {
    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is AppUserLoggedIn) {
      _realtimeService.subscribeFriendRequests(
        userId: appUserState.user.id,
        onNewRequest: _onNewFriendRequest,
      );
    }
  }

  void _onNewFriendRequest(Map<String, dynamic> requesterInfo) {
    if (!mounted) return;
    final name = requesterInfo['full_name'] ?? 'Someone';
    final avatarUrl = requesterInfo['avtar'] as String?;
    _showFriendRequestNotification(name: name, avatarUrl: avatarUrl);
  }

  static OverlayEntry? _notificationEntry;

  void _showFriendRequestNotification({
    required String name,
    String? avatarUrl,
  }) {
    // Remove existing notification
    _notificationEntry?.remove();
    _notificationEntry = null;

    final overlay = Overlay.of(context);

    _notificationEntry = OverlayEntry(
      builder: (context) => _FriendRequestNotification(
        name: name,
        avatarUrl: avatarUrl,
        onDismiss: () {
          _notificationEntry?.remove();
          _notificationEntry = null;
        },
      ),
    );

    overlay.insert(_notificationEntry!);
  }

  @override
  void dispose() {
    _realtimeService.unsubscribeFriendRequests();
    super.dispose();
  }

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
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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

// ── Custom Rich Notification for Friend Requests ──

class _FriendRequestNotification extends StatefulWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback onDismiss;

  const _FriendRequestNotification({
    required this.name,
    this.avatarUrl,
    required this.onDismiss,
  });

  @override
  State<_FriendRequestNotification> createState() =>
      _FriendRequestNotificationState();
}

class _FriendRequestNotificationState extends State<_FriendRequestNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _dismiss();
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
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -5) {
                  _dismiss();
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFE8E8E8), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: widget.avatarUrl != null
                              ? NetworkImage(widget.avatarUrl!)
                              : null,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: widget.avatarUrl == null
                              ? Text(
                                  widget.name[0].toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Name + Message
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'wants to connect with you',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Person icon accent
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
