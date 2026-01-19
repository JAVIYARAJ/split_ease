import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/group_list_item.dart';
import '../bloc/groups_bloc.dart';

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
          icon: const Icon(Icons.search, color: Colors.black, size: 28),
          onPressed: () {},
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Create group",
              style: GoogleFonts.openSans(
                color: const Color(0xFF009688), // Teal color
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
          backgroundColor:  const Color(0xFF00A99D), 
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
                if (state is GroupsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupsLoaded) {
                  if (state.groups.isEmpty) {
                     return const Center(child: Text("No groups found"));
                  }
                  return ListView.separated(
                    itemCount: state.groups.length,
                    separatorBuilder: (context, index) =>  Divider(
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
                          // Navigate to group details
                        },
                      );
                    },
                    padding: const EdgeInsets.only(bottom: 100), // Add padding for FAB + Nav Bar
                  );
                } else if (state is GroupsError) {
                   return Center(child: Text(state.message));
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
