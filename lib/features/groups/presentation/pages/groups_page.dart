import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/group_picker_sheet.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import '../../../../../core/utils/navigation_utils.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/presentation/widgets/custom_refresh_indicator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/group_list_item.dart';
import '../bloc/groups_bloc.dart';
import 'package:intl/intl.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      backgroundColor: AppColors.backgroundLightGrey,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          heroTag: "groups_fab",
          onPressed: () async {
            final group = await showGroupPickerSheet(context);
            if(group == null || !context.mounted) return;

            if(group.memberCount == 1){
              NavigationService.pushNamed(
                AppRoutes.addMembers,
                args: {'groupId': group.id},
              ).then((value) {
                if (value == true) {
                  context.read<GroupsBloc>().add(LoadGroups());
                }
              });
            }else{
              NavigationService.pushNamed(AppRoutes.addExpense, args: {'group': group});
            }
          },
          backgroundColor: AppColors.primaryTeal,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            "Add expense",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: CustomRefreshIndicator(
        onRefresh: () async{
          context.read<GroupsBloc>().add(LoadGroups());
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            _buildSummarySection(context),
            _buildGroupsList(context),
            SliverToBoxAdapter(child: SizedBox(
              height: 100,
            ),)
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      centerTitle: false,
      titleSpacing: 24, // Align with body content padding
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        "Groups",
        style: GoogleFonts.outfit(
          color: AppColors.textBlack,
          fontWeight: FontWeight.w700,
          fontSize: 26, 
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderGreyLight),
            ),
          ),
          icon: const Icon(Icons.search_rounded, color: AppColors.textBlack),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(AppRoutes.enterInviteCode),
              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
            );
          },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderGreyLight),
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textBlack),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(AppRoutes.createGroup),
              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
            );
          },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderGreyLight),
            ),
          ),
          icon: const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        double totalBalance = 0.0;
        if (state.status == GroupsStatus.success || (state.status == GroupsStatus.failure && state.groups.isNotEmpty)) {
          for (final group in state.groups) {
            if (group.overallBalance != null) {
               // We use absolute value here because we are manually applying the sign based on status
               final absBalance = group.overallBalance!.abs();
               if (group.status == "you_are_owed") {
                 totalBalance += absBalance;
               } else if (group.status == "you_owe") {
                 totalBalance -= absBalance;
               }
            }
          }
        }

        final formatter = NumberFormat('#,##0.00', 'en_IN');
        final isOwed = totalBalance >= 0;
        final absoluteBalance = totalBalance.abs();
        final balanceColor = totalBalance == 0 ? AppColors.textBlack : (isOwed ? AppColors.successGreen : AppColors.warningOrange);
        final label = totalBalance == 0 ? "Settled up" : (isOwed ? "You are owed overall" : "You owe overall");
        
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGreyLight),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                    label,
                    style: GoogleFonts.outfit(color: AppColors.textBlack, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${formatter.format(absoluteBalance)}",
                        style: GoogleFonts.outfit(color: balanceColor, fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
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
          ),
        );
      }
    );
  }


  Widget _buildGroupsList(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state.status == GroupsStatus.loading) {
          return _GroupsShimmerList();
        } else if (state.status == GroupsStatus.success || (state.status == GroupsStatus.failure && state.groups.isNotEmpty)) {
          if (state.groups.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No groups yet",
                      style: GoogleFonts.openSans(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final group = state.groups[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: GroupListItem(
                  group: group,
                  onTap: () {
                    NavigationUtils.handleResult(
                      context: context,
                      navigation: NavigationService.pushNamed(AppRoutes.groupDetail, args: {"group_id": group.id}),
                      onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
                    );
                  },
                ),
              );
            }, childCount: state.groups.length),
          );
        } else if (state.status == GroupsStatus.failure) {
          return SliverFillRemaining(child: Center(child: Text(state.errorMessage ?? "Unknown error")));
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton for the groups list
// ─────────────────────────────────────────────────────────────────────────────

class _GroupsShimmerList extends StatelessWidget {
  const _GroupsShimmerList();

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
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Circle avatar placeholder
                    Bone.circle(size: 56),
                    const SizedBox(width: 16),
                    // Name + type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bone.text(width: 140, fontSize: 16),
                          const SizedBox(height: 6),
                          Bone.text(width: 80, fontSize: 13),
                        ],
                      ),
                    ),
                    // Arrow icon placeholder
                    Bone.square(size: 36, borderRadius: BorderRadius.circular(8)),
                  ],
                ),
              ),
            ),
          ),
        ),
        childCount: 6,
      ),
    );
  }
}
