import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/features/activity/domain/entities/activity_entity.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import '../widgets/activity_list_item.dart';
import '../bloc/activity_bloc.dart';
import '../../../../../core/presentation/widgets/app_empty_state.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.activity,
      listener: (context, state) {
        if (context.read<DataRefreshCubit>().shouldRefresh(RefreshType.activity)) {
          context.read<DataRefreshCubit>().clearRefresh(RefreshType.activity);
          context.read<ActivityBloc>().add(LoadActivities());
        }
      },
      child: BaseScreen(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Activity Log',
            style: GoogleFonts.outfit(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textBlack, size: 26),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        child: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            final isLoading = state is ActivityLoading;
            
            if (state is ActivityError) {
              return Center(child: Text(state.message));
            }

            final List<ActivityEntity> activities = (state is ActivityLoaded) 
                ? state.activities 
                : _getDummyActivities();

            if (!isLoading && activities.isEmpty) {
              return const AppEmptyState(
                icon: Icons.history_rounded,
                title: "No Activities Yet",
                subtitle: "When you add expenses, settle debts, or get added to groups, your recent activities will appear here.",
              );
            }

            final groupedActivities = _groupActivities(activities);

            return CustomRefreshIndicator(
              onRefresh: () async {
                context.read<ActivityBloc>().add(LoadActivities());
              },
              child: Skeletonizer(
                enabled: isLoading,
                child: ListView.builder(
                  itemCount: groupedActivities.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final item = groupedActivities[index];
                    
                    if (item is String) {
                      return _buildSectionHeader(item);
                    }
                    
                    final activity = item as ActivityEntity;
                    return ActivityListItem(
                      activity: activity,
                      onTap: isLoading ? null : () async {
                        final targetId = activity.expenseId ?? activity.entityId ?? activity.activityId;
                        if ((activity.activityAction == ActivityType.expense || activity.activityAction == ActivityType.settlement || activity.activityAction == ActivityType.modification || activity.activityAction == ActivityType.deleted || activity.activityAction == ActivityType.restored) && targetId.isNotEmpty) {
                          NavigationUtils.handleResult(
                            context: context,
                            navigation: NavigationService.pushNamed(AppRoutes.expanseDetail, args: {"expanse_id": targetId}),
                            refreshType: RefreshType.activity,
                            onRefresh: () {
                              context.read<ActivityBloc>().add(LoadActivities());
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      color: Colors.white,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.iconGrey,
          letterSpacing: 1.2,
        ),
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
      final date = DateTime(activity.createdAt.year, activity.createdAt.month, activity.createdAt.day);
      String header;
      
      if (date == today) {
        header = "Today";
      } else if (date == yesterday) {
        header = "Yesterday";
      } else if (now.difference(date).inDays < 7) {
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

  List<ActivityEntity> _getDummyActivities() {
    return List.generate(
      10,
      (index) => ActivityEntity(
        activityId: index.toString(),
        type: 'expense',
        actorId: 'dummy_id',
        actorName: 'Milan Chudasama',
        description: 'Dummy activity description text',
        amountType: 'you_are_owed',
        balanceEffect: 0.0,
        createdAt: DateTime.now().subtract(Duration(days: index ~/ 3)),
        expenseId: 'dummy_expense_id',
        isUnread: index < 2,
      ),
    );
  }
}
