import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/add_expense_source_sheet.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/activity/presentation/bloc/activity_bloc.dart';

import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/animations/animated_counter_text.dart';
import '../../../../core/presentation/widgets/animations/smooth_animated_fab.dart';
import '../../../../core/presentation/widgets/success_dialog.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../../core/presentation/widgets/app_empty_state.dart';
import '../bloc/friends_bloc.dart';
import '../widgets/friend_list_item.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FriendsBloc>().add(LoadFriends());
    context.read<FriendsBloc>().add(LoadUnreadFriendRequestCount());
  }

  void _navigateToRequests() async {
    final result = await NavigationService.pushNamed(AppRoutes.friendRequests);
    if (!mounted) return;
    context.read<FriendsBloc>().add(LoadUnreadFriendRequestCount());
    if (result == true) {
      context.read<FriendsBloc>().add(LoadFriends());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.friends,
      listener: (context, state) {
        if (context.read<DataRefreshCubit>().shouldRefresh(RefreshType.friends)) {
          context.read<DataRefreshCubit>().clearRefresh(RefreshType.friends);
          context.read<FriendsBloc>().add(LoadFriends());
        }
      },
      child: BaseScreen(
        backgroundColor: Colors.white,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: _buildFAB(context),
        ),
        child: BlocListener<FriendsBloc, FriendsState>(
          listener: (context, state) {
            if (state.joinStatus == FriendJoinStatus.success) {
              showDialog(
                context: context,
                builder: (context) => SuccessDialog(
                  description: "Friend request sent successfully",
                  buttonText: "Okay",
                  onContinue: () => Navigator.pop(context),
                ),
              );
            } else if (state.joinStatus == FriendJoinStatus.failure) {
              AppAlerts.showError(context, state.joinErrorMessage);
            }
          },
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final friendsBloc = context.read<FriendsBloc>();
              if (notification.direction == ScrollDirection.forward) {
                if (!friendsBloc.state.isFabExtended) friendsBloc.add(ToggleFriendsFab(true));
              } else if (notification.direction == ScrollDirection.reverse) {
                if (friendsBloc.state.isFabExtended) friendsBloc.add(ToggleFriendsFab(false));
              }
              return false;
            },
            child: CustomRefreshIndicator(
              onRefresh: () async {
                context.read<FriendsBloc>().add(LoadFriends());
                context.read<ActivityBloc>().add(LoadActivities());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildHeader(context),
                  _buildBalanceHero(context),
                  _buildFriendsList(context),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      buildWhen: (prev, curr) => prev.isFabExtended != curr.isFabExtended,
      builder: (context, state) {
        return SmoothAnimatedFAB(
          isExtended: state.isFabExtended,
          onPressed: () => showAddExpenseFromFriendsSheet(context),
          icon: Icons.add_rounded,
          label: "Quick Split",
          backgroundColor: AppColors.primary,
          heroTag: "friends_fab",
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your Circle",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: -1.0),
            ),
            Text(
              "Manage sharing with your network",
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textGrey),
              maxLines: 1,
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<FriendsBloc, FriendsState>(
          buildWhen: (prev, curr) => prev.unreadRequestCount != curr.unreadRequestCount,
          builder: (context, state) {
            return Badge(
              isLabelVisible: state.unreadRequestCount > 0,
              label: Text(state.unreadRequestCount.toString()),
              backgroundColor: AppColors.warningOrange,
              offset: const Offset(-8, 8),
              child: IconButton(
                onPressed: _navigateToRequests,
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textBlack, size: 28),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () async {
            final result = await NavigationService.pushNamed(AppRoutes.qrScanner);
            if (result != null && result is String && context.mounted) {
              context.read<FriendsBloc>().add(FriendQrJoinEvent(friendId: result));
            }
          },
          icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textBlack, size: 28),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBalanceHero(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<FriendsBloc, FriendsState>(
        buildWhen: (prev, curr) => prev.status != curr.status || prev.friends != curr.friends,
        builder: (context, state) {
          double totalYouOwe = 0;
          double totalOwesYou = 0;
          if (state.status == FriendsStatus.success) {
            for (var friend in state.friends) {
              if (friend.overallBalance < 0) {
                totalYouOwe += friend.overallBalance.abs();
              } else if (friend.overallBalance > 0){
                totalOwesYou += friend.overallBalance;
              }
            }
          }

          final double netBalance = totalOwesYou - totalYouOwe;
          final bool isOwe = netBalance < 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: -20,
                    child: Icon(Icons.account_balance_wallet_rounded, size: 120, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NET NETWORK VALUE",
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 4),
                        AnimatedCounterText(
                          value: netBalance.abs(),
                          style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(isOwe ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              netBalance == 0 ? "Perfectly Balanced" : (isOwe ? "You owe overall" : "You are owed overall"),
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.friends != curr.friends ||
          prev.errorMessage != curr.errorMessage,
      builder: (context, state) {
        if (state.status == FriendsStatus.loading) return const _FriendsShimmerList();
        if (state.status == FriendsStatus.failure) return SliverToBoxAdapter(child: Center(child: Text(state.errorMessage)));
        
        if (state.friends.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 160),
              child: AppEmptyState(
                icon: Icons.people_outline_rounded,
                title: "Your circle is empty",
                subtitle: "Scan a friend's QR code to start splitting expenses together.",
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final friend = state.friends[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FriendListItem(
                  friend: friend,
                  onTap: () {
                    NavigationUtils.handleResult(
                      context: context,
                      navigation: NavigationService.pushNamed(AppRoutes.friendDetail, args: {'friend': friend}),
                      refreshType: RefreshType.friends,
                      onRefresh: () {
                        context.read<FriendsBloc>().add(LoadFriends());
                        context.read<ActivityBloc>().add(LoadActivities());
                      },
                    );
                  },
                ),
              );
            }, childCount: state.friends.length),
          ),
        );
      },
    );
  }
}

class _FriendsShimmerList extends StatelessWidget {
  const _FriendsShimmerList();
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Skeletonizer(
              enabled: true,
              child: Container(
                height: 80,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
                child: const ListTile(leading: Bone.circle(size: 48), title: Bone.text(width: 100)),
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
