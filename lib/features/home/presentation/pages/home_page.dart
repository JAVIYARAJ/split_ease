import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
import 'package:split_ease/core/services/realtime_service.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';

import '../../../../../core/presentation/widgets/app_error_full_screen_dialog.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../core/presentation/widgets/animations/animated_counter_text.dart';
import '../../../../core/presentation/widgets/app_image_view.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../../../features/analytics/presentation/bloc/expense_breakdown_bloc.dart';
import '../../../../features/analytics/presentation/pages/expense_breakdown_page.dart';
import '../../../../injection_container.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../../../activity/presentation/pages/activity_page.dart';
import '../../../friends/presentation/bloc/friends_bloc.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../groups/presentation/bloc/groups_bloc.dart';
import '../../../groups/presentation/pages/groups_page.dart';
import '../../domain/usecases/get_advertisements_usecase.dart';
import '../../domain/usecases/update_user_last_active_usecase.dart';
import '../bloc/dashboard/home_dashboard_bloc.dart';
import '../bloc/dashboard/home_dashboard_event.dart';
import '../bloc/dashboard/home_dashboard_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/app_advertisement_dialog.dart';
import '../widgets/creative_bottom_nav_bar.dart';

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
    _checkAdvertisements();
    _updateUserActivity();
  }

  void _updateUserActivity() {
    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is AppUserLoggedIn) {
      sl<UpdateUserLastActiveUseCase>()(appUserState.user.id);
    }
  }

  Future<void> _checkAdvertisements() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = sl<SharedPreferences>();
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final lastSeenDate = prefs.getString('last_advertisement_seen_date');

        if (lastSeenDate == todayStr) {
          // Already displayed to user today
          return;
        }

        final getAdvertisements = sl<GetAdvertisementsUseCase>();
        final result = await getAdvertisements(DateTime.now());
        result.fold(
          (failure) => null,
          (ads) async {
            if (mounted && ads.isNotEmpty) {
              await prefs.setString('last_advertisement_seen_date', todayStr);
              if (mounted) {
                AppAdvertisementDialog.show(context, ads);
              }
            }
          },
        );
      } catch (_) {}
    });
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

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    final String name = (userState is AppUserLoggedIn) ? (userState.user.name.split(' ').first) : "Splitting";
    final String fullName = (userState is AppUserLoggedIn) ? userState.user.name : "Splitting";
    final String? avatarUrl = (userState is AppUserLoggedIn) ? userState.user.avatarUrl : null;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeDashboardBloc>().add(_buildEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          bottom: 140 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // User Avatar with glowing halo ring & long press preview
                      GestureDetector(
                        onLongPress: () {
                          ProfilePictureDialog.show(context, avatarUrl: avatarUrl, name: fullName);
                        },
                        onTap: () {
                          ProfilePictureDialog.show(context, avatarUrl: avatarUrl, name: fullName);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF00C853)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: AppAvatar(
                            url: avatarUrl,
                            radius: 23,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_getTimeBasedGreeting()},",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).ext.textSecondary,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).ext.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Filter Pill Button
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Theme.of(context).ext.isDark
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),
            const SizedBox(height: 22),

            // 2. Metrics & Dashboard Content
            BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
              builder: (context, state) {
                if (state.status == HomeDashboardStatus.loading && state.dashboard == null) {
                  return const _DashboardSkeleton();
                } else if (state.status == HomeDashboardStatus.failure && state.dashboard == null) {
                  return AppErrorFullScreenWidget(
                    errorMessage: state.errorMessage,
                    onRefresh: () async {
                      final bloc = context.read<HomeDashboardBloc>();
                      bloc.add(_buildEvent());
                      final nextState = await bloc.stream.firstWhere(
                        (s) => s.status != HomeDashboardStatus.loading,
                      );
                      return nextState.status == HomeDashboardStatus.success;
                    },
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
                            isPrimary: true,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildGridCard(
                            "YOUR SHARE",
                            dash.moneyLost.amount,
                            dash.moneyLost.expenseCount,
                            isPrimary: false,
                            icon: Icons.pie_chart_rounded,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),
                    const SizedBox(height: 18),

                    // Quick Insights Hub Header
                    Text(
                      "Quick Insights",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).ext.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2-Card Quick Hub Grid (Expense Breakdown & Personal Expenses)
                    Row(
                      children: [
                        // Expense Breakdown Card
                        Expanded(
                          child: _buildQuickHubCard(
                            title: "Expense Breakdown",
                            subtitle: "Category split",
                            icon: Icons.donut_large_rounded,
                            gradientColors: const [Color(0xFF009688), Color(0xFF00BFA5)],
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
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Personal Expenses Card
                        Expanded(
                          child: _buildQuickHubCard(
                            title: "Personal Expenses",
                            subtitle: "Non-shared log",
                            icon: Icons.person_rounded,
                            gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                            onTap: () {
                              NavigationService.pushNamed(AppRoutes.personalExpenses);
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 450.ms, delay: 180.ms).slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 24),

                    // Recent Transactions Section
                    _buildRecentTransactionsSection(context, dash.recentTransactions)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 250.ms),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    double amount,
    int count, {
    required bool isPrimary,
    required IconData icon,
  }) {
    return Container(
      height: 148,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF002720)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF2E1065), Color(0xFF17072B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color(0xFF004D40).withValues(alpha: 0.4)
                : const Color(0xFF2E1065).withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decorative Ambient Circle
          Positioned(
            right: -15,
            top: -15,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.82),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 13, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(
                  height: 32,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedCounterText(
                      value: amount,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$count ${count == 1 ? 'Trx' : 'Trxs'}",
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).ext.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).ext.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Theme.of(context).ext.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 19),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).ext.textPrimary,
                        height: 1.15,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).ext.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context, List<RecentTransactionEntity> transactions) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Activity",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).ext.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Latest 5 expenses",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).ext.textSecondary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                context.read<HomeBloc>().add(HomeTabChanged(3));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "See All",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).ext.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 32,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "No transactions yet",
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).ext.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Expenses added in groups, with friends, or personal will show up here",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Theme.of(context).ext.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionCard(context, tx, formatter);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, RecentTransactionEntity tx, NumberFormat formatter) {
    final String subtitleText;
    if (tx.originType == 'group') {
      subtitleText = "In ${tx.groupName ?? 'Group'}";
    } else if (tx.originType == 'friend') {
      subtitleText = tx.isPaidByMe
          ? "Shared expense"
          : "Paid by ${tx.paidByName ?? 'Friend'}";
    } else {
      subtitleText = "Personal • ${tx.categoryName ?? 'Expense'}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).ext.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(
                AppRoutes.expanseDetail,
                args: {"expanse_id": tx.id},
              ),
              onRefresh: () {
                context.read<HomeDashboardBloc>().add(_buildEvent());
              },
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                // Avatar with Gradient Background & Mini Type Badge
                Stack(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: _getAvatarGradient(tx.originType),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: tx.groupIcon != null && tx.groupIcon!.isNotEmpty
                            ? AppImageView(
                                url: tx.groupIcon,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                _getTransactionIcon(tx.originType),
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(tx.originType),
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).ext.surface, width: 1.8),
                        ),
                        child: Icon(
                          _getBadgeIcon(tx.originType),
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Title & Subtitle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).ext.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${_formatDate(tx.expenseDate)} · $subtitleText",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).ext.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount Column & Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${formatter.format(tx.totalAmount)}",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).ext.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: tx.isPaidByMe
                            ? Color(0xFF00C853).withValues(alpha: 0.1)
                            : Color(0xFFFF6D00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.isPaidByMe
                            ? "You paid"
                            : "Share ₹${formatter.format(tx.userShare)}",
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: tx.isPaidByMe
                              ? const Color(0xFF00C853)
                              : const Color(0xFFFF6D00),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getAvatarGradient(String originType) {
    switch (originType) {
      case 'group':
        return const [Color(0xFF009688), Color(0xFF00BFA5)];
      case 'friend':
        return const [Color(0xFF0284C7), Color(0xFF38BDF8)];
      default:
        return const [Color(0xFF8B5CF6), Color(0xFFA855F7)];
    }
  }

  IconData _getTransactionIcon(String originType) {
    switch (originType) {
      case 'group':
        return Icons.groups_rounded;
      case 'friend':
        return Icons.handshake_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getBadgeColor(String originType) {
    switch (originType) {
      case 'group':
        return AppColors.primaryTeal;
      case 'friend':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getBadgeIcon(String originType) {
    switch (originType) {
      case 'group':
        return Icons.groups_rounded;
      case 'friend':
        return Icons.person_add_rounded;
      default:
        return Icons.lock_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return "Today";
    if (date == yesterday) return "Yesterday";
    return DateFormat("MMM d").format(dt);
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
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(width: 120, height: 16, color: Colors.white),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(width: 140, height: 18, color: Colors.white),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 72, decoration: BoxDecoration(color: Theme.of(context).ext.surface, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 72, decoration: BoxDecoration(color: Theme.of(context).ext.surface, borderRadius: BorderRadius.circular(20))),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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

