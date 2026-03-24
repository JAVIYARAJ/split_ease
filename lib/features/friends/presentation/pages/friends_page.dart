import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/add_expense_source_sheet.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/success_dialog.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/friend_list_item.dart';
import '../bloc/friends_bloc.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/injection_container.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/activity/presentation/bloc/activity_bloc.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  void dispose() {
    super.dispose();
  }

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
        backgroundColor: AppColors.backgroundWhite,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90.0), // Raise FAB above custom bottom nav
          child: BlocBuilder<FriendsBloc, FriendsState>(
            buildWhen: (previous, current) => previous.isFabExtended != current.isFabExtended,
            builder: (context, state) {
              return AnimatedScale(
                duration: const Duration(milliseconds: 500),
                scale: state.isFabExtended ? 1.0 : 0.9,
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: state.isFabExtended ? 1.0 : 0.9,
                  curve: Curves.fastOutSlowIn,
                  child: FloatingActionButton.extended(
                    heroTag: "friends_fab",
                    isExtended: state.isFabExtended,
                    onPressed: () {
                      showAddExpenseFromFriendsSheet(context);
                    },
                    backgroundColor: AppColors.primaryTeal,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: Text(
                      "Add expense",
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        child: BlocListener<FriendsBloc, FriendsState>(
          listener: (context, state) {
            if (state.joinStatus == FriendJoinStatus.success) {
              showDialog(
                context: context,
                builder: (context) =>
                    SuccessDialog(description: "Friend request sent successfully", buttonText: "Okay", onContinue: () => Navigator.pop(context)),
              );
            } else if (state.joinStatus == FriendJoinStatus.failure) {
              AppAlerts.showError(context, state.joinErrorMessage);
            }
          },
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final friendsBloc = context.read<FriendsBloc>();
              if (notification.direction == ScrollDirection.forward) {
                if (!friendsBloc.state.isFabExtended) {
                  friendsBloc.add(ToggleFriendsFab(true));
                }
              } else if (notification.direction == ScrollDirection.reverse) {
                if (friendsBloc.state.isFabExtended) {
                  friendsBloc.add(ToggleFriendsFab(false));
                }
              }
              return false;
            },

            child: CustomRefreshIndicator(
              onRefresh: () async {
                context.read<FriendsBloc>().add(LoadFriends());
                context.read<ActivityBloc>().add(LoadActivities());
              },
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context),
                  _buildSummarySection(context),
                  _buildFriendsList(context),
                  SliverToBoxAdapter(child: SizedBox(height: 170)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      centerTitle: false,
      titleSpacing: 24,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        "Friends",
        style: GoogleFonts.outfit(color: AppColors.textBlack, fontWeight: FontWeight.w700, fontSize: 26, letterSpacing: -0.5),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: BlocBuilder<FriendsBloc, FriendsState>(
            buildWhen: (previous, current) => previous.unreadRequestCount != current.unreadRequestCount,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: _navigateToRequests,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGreyLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Requests",
                          style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        if (state.unreadRequestCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.warningOrange, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              state.unreadRequestCount > 99 ? '99+' : '${state.unreadRequestCount}',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          onPressed: () async {
            final result = await NavigationService.pushNamed(AppRoutes.qrScanner);
            if (result != null && result is String && context.mounted) {
              context.read<FriendsBloc>().add(FriendQrJoinEvent(friendId: result));
            }
          },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.borderGreyLight),
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textBlack),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<FriendsBloc, FriendsState>(
        builder: (context, state) {
          double totalYouOwe = 0;
          double totalOwesYou = 0;
          if (state.status == FriendsStatus.success) {
            for (var friend in state.friends) {
              if (friend.overallBalance < 0) {
                totalYouOwe += friend.overallBalance.abs();
              } else if (friend.overallBalance > 0) {
                totalOwesYou += friend.overallBalance;
              }
            }
          }

          final netBalance = totalOwesYou - totalYouOwe;
          final isOwe = netBalance < 0;
          final balanceColor = netBalance == 0 ? AppColors.textBlack : (isOwe ? AppColors.warningOrange : AppColors.successGreen);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGreyLight),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.textGrey, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Total Balance",
                        style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    netBalance == 0 ? "You are settled up" : (isOwe ? "You owe overall" : "You are owed overall"),
                    style: GoogleFonts.outfit(color: AppColors.textBlack, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${netBalance.abs().toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(color: balanceColor, fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Text(
                              "Details",
                              style: GoogleFonts.outfit(color: AppColors.textBlack, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textBlack, size: 12),
                          ],
                        ),
                      ),
                    ],
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
      builder: (context, state) {
        if (state.status == FriendsStatus.loading) {
          return _FriendsShimmerList();
        } else if (state.status == FriendsStatus.success) {
          if (state.friends.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text("No friends found", style: GoogleFonts.openSans(color: Colors.grey.shade500, fontSize: 16)),
                  ],
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final friend = state.friends[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
          );
        } else if (state.status == FriendsStatus.failure) {
          return SliverFillRemaining(child: Center(child: Text(state.errorMessage)));
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton for the friends list
// ─────────────────────────────────────────────────────────────────────────────

class _FriendsShimmerList extends StatelessWidget {
  const _FriendsShimmerList();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Skeletonizer(
            enabled: true,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Circle avatar
                    Bone.circle(size: 50),
                    const SizedBox(width: 16),
                    // Name
                    Expanded(child: Bone.text(width: 130, fontSize: 16)),
                    // Balance chip placeholder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [Bone.text(width: 55, fontSize: 12), const SizedBox(height: 4), Bone.text(width: 70, fontSize: 16)],
                    ),
                    const SizedBox(width: 8),
                    // Chevron
                    Bone.icon(size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        childCount: 7,
      ),
    );
  }
}
