import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import '../../../../../core/utils/navigation_utils.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/presentation/widgets/custom_refresh_indicator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/group_list_item.dart';
import '../bloc/groups_bloc.dart';
import '../../../../../core/routing/app_routes.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      backgroundColor: AppColors.backgroundWhite,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          heroTag: "groups_fab",
          onPressed: () {},
          backgroundColor: AppColors.primaryTealDark,
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: Text(
            "Add expense",
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildSummarySection(context),
          _buildGroupsList(context),
        ],
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
      surfaceTintColor: Colors.transparent,
      title: Text(
        "Groups",
        style: GoogleFonts.openSans(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
          fontSize: 28, // Slightly larger for "Page Title" feel
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textBlack, size: 28),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: AppColors.textBlack),
          onPressed: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(AppRoutes.enterInviteCode),
              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.group_add_outlined, color: AppColors.primaryTeal, size: 28),
          onPressed: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(AppRoutes.createGroup),
              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
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
            boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Balance",
                style: GoogleFonts.openSans(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w600),
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
                        "You owe",
                        style: GoogleFonts.openSans(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹4,131.68",
                        style: GoogleFonts.openSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "Details >",
                      style: GoogleFonts.openSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildGroupsList(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state.status == GroupsStatus.loading) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
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
                      navigation: NavigationService.pushNamed(AppRoutes.groupDetail, args: {"group_id": group.id, "preview_group": group}),
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
