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
import 'package:split_ease/injection_container.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';

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
          'Activity',
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

          return CustomRefreshIndicator(
            onRefresh: () async {
              context.read<ActivityBloc>().add(LoadActivities());
            },
            child: Skeletonizer(
              enabled: isLoading,
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.backgroundLightGrey,
                  height: 1,
                  indent: 86,
                  endIndent: 24,
                ),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ActivityListItem(
                    activity: activity,
                    onTap: isLoading ? null : () async {
                      if (activity.activityAction == ActivityType.expense && activity.activityId.isNotEmpty) {
                        NavigationUtils.handleResult(
                          context: context,
                          navigation: NavigationService.pushNamed(AppRoutes.expanseDetail, args: {"expanse_id": activity.activityId}),
                          refreshType: RefreshType.activity,
                          onRefresh: () {
                            context.read<ActivityBloc>().add(LoadActivities());
                          },
                        );
                      }
                    },
                  );
                },
                padding: const EdgeInsets.only(bottom: 100),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  List<ActivityEntity> _getDummyActivities() {
    return List.generate(
      8,
      (index) => ActivityEntity(
        activityId: index.toString(),
        type: 'expense',
        actorId: 'dummy_id',
        actorName: 'Milan Chudasama',
        description: 'Dummy activity description text',
        amountType: 'you_are_owed',
        balanceEffect: 0.0,
        createdAt: DateTime.now(),
      ),
    );
  }
}
