import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/presentation/widgets/success_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:split_ease/features/groups/presentation/pages/qr_scanner_page.dart';
import 'friend_requests_page.dart';
import '../widgets/friend_list_item.dart';
import '../bloc/friends_bloc.dart';
import 'package:split_ease/core/routing/app_routes.dart';

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
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendRequestsPage()));
    if (!mounted) return;
    context.read<FriendsBloc>().add(LoadUnreadFriendRequestCount());
    if (result == true) {
      context.read<FriendsBloc>().add(LoadFriends());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      backgroundColor: AppColors.backgroundWhite,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), // Raise FAB above custom bottom nav
        child: FloatingActionButton.extended(
          heroTag: "friends_fab",
          onPressed: () {},
          backgroundColor: AppColors.primaryTealDark,
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: Text(
            "Add expense",
            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
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
        child: CustomRefreshIndicator(
          onRefresh: () async{
            context.read<FriendsBloc>().add(LoadFriends());
          },
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              _buildSummarySection(context),
              _buildFriendsList(context),
            ],
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
      surfaceTintColor: Colors.transparent,
      title: Text(
        "Friends",
        style: GoogleFonts.openSans(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: BlocBuilder<FriendsBloc, FriendsState>(
            buildWhen: (previous, current) => previous.unreadRequestCount != current.unreadRequestCount,
            builder: (context, state) {
              return InkWell(
                onTap: _navigateToRequests,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mark_email_unread_outlined, color: AppColors.primaryTeal, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Requests",
                        style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      if (state.unreadRequestCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warningOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            state.unreadRequestCount > 99 ? '99+' : '${state.unreadRequestCount}',
                            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScannerPage()));
            if (result != null && result is String && context.mounted) {
              context.read<FriendsBloc>().add(FriendQrJoinEvent(friendId: result));
            }
          },
          icon: const Icon(Icons.qr_code_scanner, color: AppColors.textBlack),
        ),
         IconButton(
          icon: const Icon(Icons.search, color: AppColors.textBlack, size: 28),
          onPressed: () {},
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

          return Padding(
             padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
             child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Balance",
                    style: GoogleFonts.openSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            isOwe ? "You owe" : "You are owed",
                            style: GoogleFonts.openSans(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "₹${netBalance.abs().toStringAsFixed(2)}",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Details >",
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
                    Text(
                      "No friends found",
                      style: GoogleFonts.openSans(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final friend = state.friends[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: FriendListItem(
                    friend: friend,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.friendDetail,
                        arguments: {'friend': friend},
                      );
                    },
                  ),
                );
              },
              childCount: state.friends.length,
            ),
          );
        } else if (state.status == FriendsStatus.failure) {
          return SliverFillRemaining(
            child: Center(child: Text(state.errorMessage)),
          );
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
                    Expanded(
                      child: Bone.text(width: 130, fontSize: 16),
                    ),
                    // Balance chip placeholder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Bone.text(width: 55, fontSize: 12),
                        const SizedBox(height: 4),
                        Bone.text(width: 70, fontSize: 16),
                      ],
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
