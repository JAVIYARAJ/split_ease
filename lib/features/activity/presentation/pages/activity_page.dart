import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';

import '../widgets/activity_list_item.dart';
import '../bloc/activity_bloc.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const SizedBox(),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 28),
          onPressed: () {},
        ),
      ),
      child: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActivityLoaded) {
             if (state.activities.isEmpty) {
               return const Center(child: Text("No activity found"));
             }
             return ListView.separated(
              itemCount: state.activities.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade100,
                height: 1,
                indent: 80,
                endIndent: 24,
              ),
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                return ActivityListItem(
                  activity: activity,
                  onTap: () {
                    // Navigate to activity details
                  },
                );
              },
              padding: const EdgeInsets.only(bottom: 100),
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
