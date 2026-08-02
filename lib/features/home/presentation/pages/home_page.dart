import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/services/realtime_service.dart';
import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
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
import '../widgets/creative_bottom_nav_bar.dart';
import '../bloc/dashboard/home_dashboard_bloc.dart';
import '../bloc/dashboard/home_dashboard_event.dart';
import '../bloc/dashboard/home_dashboard_state.dart';
import '../../../../core/presentation/widgets/animations/animated_counter_text.dart';
import 'package:split_ease/core/utils/app_formatter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../../../features/analytics/presentation/bloc/expense_breakdown_bloc.dart';
import '../../../../features/analytics/presentation/pages/expense_breakdown_page.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import 'package:intl/intl.dart';

enum HomeDashboardFilter {
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

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
      useSafeArea: false,
      backgroundColor: Theme.of(context).ext.backgroundGrey,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            final now = DateTime.now();
            return sl<HomeDashboardBloc>()..add(LoadHomeDashboard(startDate: DateTime(now.year, now.month, 1), endDate: now));
          }),
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
                    const _HomeDashboardView(),
                    const FriendsPage(),
                    const GroupsPage(),
                    const ActivityPage(),
                    const AccountPage(),
                  ],
                ),

                // Floating Glass Island Creative Bottom Nav Bar
                CreativeBottomNavBar(
                  currentIndex: state.tabIndex,
                  onTabSelected: (index) {
                    context.read<HomeBloc>().add(HomeTabChanged(index));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Home Dashboard UI ──

class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView();

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {
  HomeDashboardFilter _activeFilter = HomeDashboardFilter.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  LoadHomeDashboard _buildEvent() {
    final dates = _resolveDates(_activeFilter);
    return LoadHomeDashboard(
      startDate: dates.$1,
      endDate: dates.$2,
    );
  }

  (DateTime?, DateTime?) _resolveDates(HomeDashboardFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case HomeDashboardFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return (start, end);
      case HomeDashboardFilter.lastWeek:
        final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
        final end = startOfThisWeek.subtract(const Duration(days: 1));
        return (end.subtract(const Duration(days: 6)), end);
      case HomeDashboardFilter.thisMonth:
        return (DateTime(now.year, now.month, 1), now);
      case HomeDashboardFilter.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0);
        return (start, end);
      case HomeDashboardFilter.thisYear:
        return (DateTime(now.year, 1, 1), now);
      case HomeDashboardFilter.custom:
        return (_customStart, _customEnd);
    }
  }

  String _filterLabel(HomeDashboardFilter f) {
    switch (f) {
      case HomeDashboardFilter.thisWeek:  return 'This Week';
      case HomeDashboardFilter.lastWeek:  return 'Last Week';
      case HomeDashboardFilter.thisMonth: return 'This Month';
      case HomeDashboardFilter.lastMonth: return 'Last Month';
      case HomeDashboardFilter.thisYear:  return 'This Year';
      case HomeDashboardFilter.custom:
        if (_customStart != null && _customEnd != null) {
          final fmt = DateFormat('MMM d');
          return '${fmt.format(_customStart!)} – ${fmt.format(_customEnd!)}';
        }
        return 'Custom Range';
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HomeFilterSheet(
        activeFilter: _activeFilter,
        customStart: _customStart,
        customEnd: _customEnd,
        onFilterSelected: (filter) async {
          Navigator.pop(context);
          if (filter == HomeDashboardFilter.custom) {
            await _showDateRangePicker();
          } else {
            setState(() => _activeFilter = filter);
            if (mounted) {
              context.read<HomeDashboardBloc>().add(_buildEvent());
            }
          }
        },
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _activeFilter = HomeDashboardFilter.custom;
        _customStart = picked.start;
        _customEnd = picked.end;
      });
      context.read<HomeDashboardBloc>().add(_buildEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    final String name = (userState is AppUserLoggedIn) ? (userState.user.name.split(' ').first) : "Splitting";

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeDashboardBloc>().add(_buildEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(top: 64, left: 20, right: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey $name,",
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Your Dashboard",
                          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).ext.textPrimary, letterSpacing: -1.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          _filterLabel(_activeFilter),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
              builder: (context, state) {
                if (state.status == HomeDashboardStatus.loading && state.dashboard == null) {
                  return const _DashboardSkeleton();
                } else if (state.status == HomeDashboardStatus.failure && state.dashboard == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(state.errorMessage, style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
                    ),
                  );
                }

                final dash = state.dashboard;
                if (dash == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Metrics Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridCard(
                            "TOTAL SPENT", 
                            dash.totalSpend.amount, 
                            dash.totalSpend.expenseCount, 
                            isPrimary: true
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGridCard(
                            "YOUR SHARE", 
                            dash.moneyLost.amount, 
                            dash.moneyLost.expenseCount, 
                            isPrimary: false
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Analytics Entry Point
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (_) => sl<ExpenseBreakdownBloc>(),
                              child: const ExpenseBreakdownPage(),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.pie_chart_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Expense Breakdown", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary)),
                                  Text("See your spending breakdown", style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Personal Expenses Entry Point
                    InkWell(
                      onTap: () {
                        NavigationService.pushNamed(AppRoutes.personalExpenses);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).ext.isDark ? const Color(0xFF2A1B3D) : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).ext.isDark ? const Color(0xFF4C2882) : const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).ext.isDark ? const Color(0xFF4C2882) : const Color(0xFFE9D5FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person_rounded, color: Theme.of(context).ext.isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Personal Expenses", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary)),
                                  Text("Track your non-shared expenses", style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).ext.isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(String title, double amount, int count, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(28),
        border: isPrimary ? null : Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: isPrimary ? AppColors.primary.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: GoogleFonts.outfit(
              fontSize: 11, 
              fontWeight: FontWeight.w800, 
              color: isPrimary ? Colors.white.withValues(alpha: 0.8) : Theme.of(context).ext.textSecondary, 
              letterSpacing: 1.2
            )
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AnimatedCounterText(
                value: amount, 
                style: GoogleFonts.outfit(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  color: isPrimary ? Colors.white : Theme.of(context).ext.textPrimary, 
                  height: 1.1
                )
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white.withValues(alpha: 0.2) : Theme.of(context).ext.backgroundGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_rounded, 
                  size: 12, 
                  color: isPrimary ? Colors.white : Theme.of(context).ext.textSecondary
                ),
                const SizedBox(width: 4),
                Text(
                  "$count Trx", 
                  style: GoogleFonts.outfit(
                    fontSize: 10, 
                    fontWeight: FontWeight.w700, 
                    color: isPrimary ? Colors.white : Theme.of(context).ext.textSecondary
                  )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(color: Theme.of(context).ext.surface, borderRadius: BorderRadius.circular(28)),
          ),
          const SizedBox(height: 32),
          Container(width: 120, height: 16, color: Colors.white),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Theme.of(context).ext.surface, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Theme.of(context).ext.surface, borderRadius: BorderRadius.circular(20))),
        ],
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
                      color: Theme.of(context).ext.surface,
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
                        AppAvatar(
                          url: widget.avatarUrl,
                          radius: 22,
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

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────

class _HomeFilterSheet extends StatelessWidget {
  final HomeDashboardFilter activeFilter;
  final DateTime? customStart;
  final DateTime? customEnd;
  final void Function(HomeDashboardFilter) onFilterSelected;

  const _HomeFilterSheet({
    required this.activeFilter,
    required this.customStart,
    required this.customEnd,
    required this.onFilterSelected,
  });

  static const _options = [
    (HomeDashboardFilter.thisWeek,  'This Week',    Icons.view_week_rounded),
    (HomeDashboardFilter.lastWeek,  'Last Week',    Icons.history_rounded),
    (HomeDashboardFilter.thisMonth, 'This Month',   Icons.calendar_month_rounded),
    (HomeDashboardFilter.lastMonth, 'Last Month',   Icons.chevron_left_rounded),
    (HomeDashboardFilter.thisYear,  'This Year',    Icons.calendar_today_rounded),
    (HomeDashboardFilter.custom,    'Custom Range', Icons.date_range_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).ext.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Filter Dashboard",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).ext.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Select a time range to filter your dashboard metrics",
            style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary),
          ),
          const SizedBox(height: 20),
          // 2-column grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: _options.map((opt) {
              final (filter, label, icon) = opt;
              final isActive = activeFilter == filter;
              return GestureDetector(
                onTap: () => onFilterSelected(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Theme.of(context).ext.backgroundGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive ? AppColors.primary : Theme.of(context).ext.border.withValues(alpha: 0.5),
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: isActive ? Colors.white : Theme.of(context).ext.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? Colors.white : Theme.of(context).ext.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Show selected custom range banner if applicable
          if (activeFilter == HomeDashboardFilter.custom && customStart != null && customEnd != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Selected: ${DateFormat('MMM d, yyyy').format(customStart!)} – ${DateFormat('MMM d, yyyy').format(customEnd!)}",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
