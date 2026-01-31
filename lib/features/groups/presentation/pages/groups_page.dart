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
      appBar: AppBar(
        title:  const SizedBox(), 
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: AppColors.textBlack, size: 28),
          onPressed: () {},
        ),
        actions: [
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
          TextButton(
            onPressed: () async {
              NavigationUtils.handleResult(
                context: context,
                navigation: NavigationService.pushNamed(AppRoutes.createGroup),
                onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
              );
            },
            child: Text(
              "Create group",
              style: GoogleFonts.openSans(
                color: AppColors.primaryTeal, // Teal color
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
         padding: const EdgeInsets.only(bottom: 90.0),
         child: FloatingActionButton.extended(
          heroTag: "groups_fab",
          onPressed: () {},
          backgroundColor:  AppColors.primaryTealDark, 
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
      child: Column(
        children: [
          // Overall Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Overall, you owe ',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '₹4,131.68',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          color: AppColors.warningOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, color: Colors.black), // Filter icon
                ),
              ],
            ),
          ),
          
          // Groups List
          Expanded(
            child: BlocBuilder<GroupsBloc, GroupsState>(
              builder: (context, state) {
                if (state.status == GroupsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == GroupsStatus.success ||
                    (state.status == GroupsStatus.failure &&
                        state.groups.isNotEmpty)) { // Show cache if failure occurs
                  // Note: The original request implies handling failure.
                  // If failure, we check below.
                  // But usually success implies we have valid data.
                  // Let's stick to the logic:
                  // if success, show list (empty or populated).
                  
                   if (state.groups.isEmpty) {
                    return CustomRefreshIndicator(
                      onRefresh: () async {
                        context.read<GroupsBloc>().add(LoadGroups());
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: const Center(child: Text("No groups found")),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return CustomRefreshIndicator(
                    onRefresh: () async {
                      context.read<GroupsBloc>().add(LoadGroups());
                    },
                    child: ListView.separated(
                      itemCount: state.groups.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                        indent: 80,
                        endIndent: 24,
                      ),
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        return GroupListItem(
                          group: group,
                          onTap: () {
                            NavigationUtils.handleResult(
                              context: context,
                              navigation: NavigationService.pushNamed(
                                AppRoutes.groupDetail,
                                args: {"group_id": group.id, "preview_group": group},
                              ),
                              onRefresh: () => context.read<GroupsBloc>().add(LoadGroups()),
                            );
                          },
                        );
                      },
                      padding: const EdgeInsets.only(bottom: 100), // Add padding for FAB + Nav Bar
                    ),
                  );

                } else if (state.status == GroupsStatus.failure) {
                  return CustomRefreshIndicator(
                    onRefresh: () async {
                      context.read<GroupsBloc>().add(LoadGroups());
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(child: Text(state.errorMessage ?? "Unknown error")),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
