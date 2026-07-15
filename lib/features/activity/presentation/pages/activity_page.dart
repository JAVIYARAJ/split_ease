import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/activity/domain/entities/activity_entity.dart';

import '../../../../../core/presentation/widgets/app_empty_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import '../bloc/activity_bloc.dart';
import '../widgets/activity_list_item.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.activity,
      listener: (context, state) {
        if (context.read<DataRefreshCubit>().shouldRefresh(
            RefreshType.activity)) {
          context.read<DataRefreshCubit>().clearRefresh(RefreshType.activity);
          context.read<ActivityBloc>().add(LoadActivities());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            final isLoading = state is ActivityLoading;

            if (state is ActivityError) {
              return Center(child: Text(state.message));
            }

            final List<ActivityEntity> activities = (state is ActivityLoaded)
                ? state.activities
                : [];

            final groupedActivities = _groupActivities(activities);

            return CustomRefreshIndicator(
              onRefresh: () async {
                context.read<ActivityBloc>().add(LoadActivities());
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _buildAppBar(context),
                  if (!isLoading && activities.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: AppEmptyState(
                          icon: Icons.history_rounded,
                          title: "No Activity Found",
                          subtitle: "Your split history is empty. Time to start sharing expenses!",
                        ),
                      ),
                    )
                  else
                    Skeletonizer.sliver(
                      enabled: isLoading,
                      child: SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context,
                              index) {
                            final item = groupedActivities[index];

                            // Calculate stagger delay
                            final double delay = (index * 0.05).clamp(0.0, 0.5);

                            if (item is String) {
                              return _buildStaggeredWrapper(delay: delay,
                                  child: _buildSectionHeader(item));
                            }

                            final activity = item as ActivityEntity;
                            return _buildStaggeredWrapper(
                              delay: delay,
                              child: ActivityListItem(
                                activity: activity,
                                onTap: isLoading
                                    ? null
                                    : () async {
                                  final targetId = activity.expenseId ??
                                      activity.entityId ?? activity.activityId;
                                  if ((activity.activityAction == ActivityType.expense ||
                                      activity.activityAction == ActivityType.settlement ||
                                      activity.activityAction == ActivityType.modification ||
                                      activity.activityAction == ActivityType.deleted ||
                                      activity.activityAction == ActivityType.restored) &&
                                      targetId.isNotEmpty) {
                                    NavigationUtils.handleResult(
                                      context: context,
                                      navigation: NavigationService.pushNamed(
                                          AppRoutes.expanseDetail,
                                          args: {"expanse_id": targetId}),
                                      refreshType: RefreshType.activity,
                                      onRefresh: () {
                                        context.read<ActivityBloc>().add(LoadActivities());
                                      },
                                    );
                                  } else if (activity.activityAction == ActivityType.groupCreated) {
                                    final groupId = activity.groupId ?? targetId;
                                    if (groupId.isNotEmpty) {
                                      NavigationUtils.handleResult(
                                        context: context,
                                        navigation: NavigationService.pushNamed(
                                            AppRoutes.groupDetail,
                                            args: {"group_id": groupId}),
                                        refreshType: RefreshType.activity,
                                        onRefresh: () {
                                          context.read<ActivityBloc>().add(LoadActivities());
                                        },
                                      );
                                    }
                                  } else if (activity.activityAction == ActivityType.limitExceeded) {
                                    NavigationUtils.handleResult(
                                      context: context,
                                      navigation: NavigationService.pushNamed(AppRoutes.categoryLimits),
                                      refreshType: RefreshType.activity,
                                      onRefresh: () {
                                        context.read<ActivityBloc>().add(LoadActivities());
                                      },
                                    );
                                  }
                                },
                              ),
                            );
                          }, childCount: groupedActivities.length),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Recent Activity",
              style: GoogleFonts.outfit(fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  letterSpacing: -1.0),
            ),
            Text(
              "Track transactions & updates",
              style: GoogleFonts.outfit(fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey),
              maxLines: 1,
            ),
          ],
        ),
      ),
      actions: [
        /*IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search_rounded, color: AppColors.textBlack),
          style: IconButton.styleFrom(
              backgroundColor: AppColors.backgroundLightGrey,
              padding: const EdgeInsets.all(12)),
        ),
        const SizedBox(width: 16),*/
      ],
    );
  }

  Widget _buildStaggeredWrapper(
      {required Widget child, required double delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (400 + (delay * 1000)).toInt()),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textBlack,
            letterSpacing: 2.0),
      ),
    );
  }

  List<dynamic> _groupActivities(List<ActivityEntity> activities) {
    if (activities.isEmpty) return [];

    final List<dynamic> grouped = [];
    String? lastHeader;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var activity in activities) {
      final date = DateTime(activity.createdAt.year, activity.createdAt.month,
          activity.createdAt.day);
      String header;

      if (date == today) {
        header = "Today";
      } else if (date == yesterday) {
        header = "Yesterday";
      } else if (now
          .difference(date)
          .inDays < 7) {
        header = "This Week";
      } else {
        header = DateFormat('MMMM yyyy').format(date);
      }

      if (header != lastHeader) {
        grouped.add(header);
        lastHeader = header;
      }
      grouped.add(activity);
    }

    return grouped;
  }
}
