import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/group_picker_sheet.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/groups_bloc.dart';

import '../../../../../core/presentation/widgets/app_empty_state.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/presentation/widgets/custom_refresh_indicator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/navigation_utils.dart';
import '../widgets/group_list_item.dart';
import '../../../../core/presentation/widgets/animations/animated_counter_text.dart';
import '../../../../core/presentation/widgets/animations/smooth_animated_fab.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsBloc>().add(LoadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.groups,
      listener: (context, state) {
        if (context.read<DataRefreshCubit>().shouldRefresh(RefreshType.groups)) {
          context.read<DataRefreshCubit>().clearRefresh(RefreshType.groups);
          context.read<GroupsBloc>().add(LoadGroups());
        }
      },
      child: BaseScreen(
        backgroundColor: Colors.white,
        floatingActionButton: Padding(padding: const EdgeInsets.only(bottom: 100.0), child: _buildFAB(context)),
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final groupsBloc = context.read<GroupsBloc>();
            if (notification.direction == ScrollDirection.forward) {
              if (!groupsBloc.state.isFabExtended) groupsBloc.add(ToggleGroupsFab(true));
            } else if (notification.direction == ScrollDirection.reverse) {
              if (groupsBloc.state.isFabExtended) groupsBloc.add(ToggleGroupsFab(false));
            }
            return false;
          },
          child: CustomRefreshIndicator(
            onRefresh: () async => context.read<GroupsBloc>().add(LoadGroups()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _buildHeader(context),
                _buildCollectiveHero(context),
                _buildGroupsList(context),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        return SmoothAnimatedFAB(
          isExtended: state.isFabExtended,
          onPressed: () async {
            final group = await showGroupPickerSheet(context);
            if (group == null || !context.mounted) return;

            final isNonGroup = group.id == null;

            if (!isNonGroup && group.memberCount == 1) {
              NavigationService.pushNamed(AppRoutes.addMembers, args: {'groupId': group.id}).then((value) {
                if (value == true && context.mounted) context.read<GroupsBloc>().add(LoadGroups());
              });
            } else if (mounted) {
              NavigationUtils.handleResult(
                context: context,
                navigation: NavigationService.pushNamed(
                  AppRoutes.addExpense, 
                  args: {
                    'group': isNonGroup ? null : group, 
                    'origin': isNonGroup ? ExpenseOrigin.personal : ExpenseOrigin.group
                  }
                ),
                onRefresh: () {
                  context.read<GroupsBloc>().add(LoadGroups());
                  context.read<ActivityBloc>().add(LoadActivities());
                },
              );
            }
          },
          icon: Icons.add_rounded,
          label: "New Expense",
          backgroundColor: AppColors.primary,
          heroTag: "groups_fab",
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
              "Collaborations",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: -1.0),
            ),
            Text(
              "Track shared expenses across teams",
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textGrey),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(AppRoutes.enterInviteCode),
              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
            );
          },
          icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textBlack, size: 28),
        ),
        IconButton(
          onPressed: () {
            NavigationUtils.handleResult(
              context: context,
              navigation: NavigationService.pushNamed(AppRoutes.createGroup),
              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
            );
          },
          icon: const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCollectiveHero(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          double totalBalance = 0.0;
          for (final group in state.groups) {
            if (group.overallBalance != null) {
              final absBalance = group.overallBalance!.abs();
              if (group.status == "you_are_owed") {
                totalBalance += absBalance;
              } else if (group.status == "you_owe") {
                totalBalance -= absBalance;
              }
            }
          }

          final bool isOwed = totalBalance >= 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF512DA8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF673AB7).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Stack(
                children: [
                  Positioned(right: -10, top: -20, child: Icon(Icons.groups_rounded, size: 120, color: Colors.white.withValues(alpha: 0.1))),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "COLLECTIVE STANDING",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedCounterText(
                          value: totalBalance,
                          style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(isOwed ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              totalBalance == 0 ? "You're all squared up" : (isOwed ? "Total you are owed" : "Total you owe overall"),
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

  Widget _buildGroupsList(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state.status == GroupsStatus.loading) return const _GroupsShimmerList();

        if (state.groups.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: AppEmptyState(
                icon: Icons.layers_outlined,
                title: "No groups yet",
                subtitle: "Create your first group to start managing shared costs.",
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final group = state.groups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GroupListItem(
                  group: group,
                  onTap: () {
                    NavigationUtils.handleResult(
                      context: context,
                      navigation: NavigationService.pushNamed(AppRoutes.groupDetail, args: {"group_id": group.id}),
                      refreshType: RefreshType.groups,
                      onRefresh: () {
                        context.read<GroupsBloc>().add(LoadGroups());
                        context.read<ActivityBloc>().add(LoadActivities());
                      },
                    );
                  },
                ),
              );
            }, childCount: state.groups.length),
          ),
        );
      },
    );
  }
}

class _GroupsShimmerList extends StatelessWidget {
  const _GroupsShimmerList();

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
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const ListTile(leading: Bone.circle(size: 56), title: Bone.text(width: 120), subtitle: Bone.text(width: 80)),
              ),
            ),
          ),
          childCount: 5,
        ),
      ),
    );
  }
}
