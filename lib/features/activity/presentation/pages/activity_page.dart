import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/features/activity/domain/entities/activity_entity.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import '../widgets/activity_list_item.dart';
import '../bloc/activity_bloc.dart';
import '../../../../../core/presentation/widgets/app_empty_state.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
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
          if (state is ActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActivityLoaded) {
             if (state.activities.isEmpty) {
               return const AppEmptyState(
                 icon: Icons.history_rounded,
                 title: "No Activities Yet",
                 subtitle: "When you add expenses, settle debts, or get added to groups, your recent activities will appear here.",
               );
             }
             return CustomRefreshIndicator(
               onRefresh: () async{
                 context.read<ActivityBloc>().add(LoadActivities());
               },
               child: ListView.separated(
                itemCount: state.activities.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.backgroundLightGrey,
                  height: 1,
                  indent: 86,
                  endIndent: 24,
                ),
                itemBuilder: (context, index) {
                  final activity = state.activities[index];
                  return ActivityListItem(
                    activity: activity,
                    onTap: () {
                      if(activity.type==ActivityType.expense && activity.activityId!=null){
                        NavigationService.pushNamed(AppRoutes.expanseDetail,args: {"expanse_id":activity.activityId});
                      }
                    },
                  );
                },
                padding: const EdgeInsets.only(bottom: 100),
                           ),
             );
          } else if (state is ActivityError) {
             return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

