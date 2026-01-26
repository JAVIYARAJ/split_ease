import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/widgets/auth_field.dart';
import '../widgets/group_type_card.dart';
import '../bloc/create_group_bloc.dart';
import '../../domain/entities/group_type.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CreateGroupBloc>().add(const GenerateInviteCode());
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateGroupBloc, CreateGroupState>(
      listener: (context, state) {
        if (state.status == CreateGroupStatus.success) {
          AppAlerts.showSuccess(context, "Group created successfully");
          NavigationService.pushReplacement(AppRoutes.groupDetail,args: {"group_id":state.createdGroupId});
        } else if (state.status == CreateGroupStatus.failure) {
          AppAlerts.showError(context, state.errorMessage ?? "An error occurred");
        }
      },
      builder: (context, state) {
        return BaseScreen(
          backgroundColor: AppColors.backgroundWhite,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundWhite,
            elevation: 0,
            leadingWidth: 80,
            leading: TextButton(
              onPressed: () {
                NavigationService.pop();
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.openSans(
                  color: AppColors.successGreen, // Green
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              "Create a group",
              style: GoogleFonts.openSans(color: AppColors.textBlack, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () {
                    context.read<CreateGroupBloc>().add(CreateGroupSubmitted(name: _groupNameController.text, type: state.selectedType));
                  },
                  child: state.status == CreateGroupStatus.loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          "Done",
                          style: GoogleFonts.openSans(
                            color: AppColors.successGreen, // Green
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section: Photo + Name
                // 1. Header Section: Photo + Name
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Camera Icon Container
                      GestureDetector(
                        onTap: () {
                          context.read<CreateGroupBloc>().add(const PickGroupImage());
                        },
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLightGrey, // Light grey background
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderGreyLight, width: 1, style: BorderStyle.solid),
                              image: state.groupImage != null ? DecorationImage(image: FileImage(state.groupImage!), fit: BoxFit.cover) : null,
                            ),
                            child: state.groupImage == null
                                ? const Center(child: Icon(Icons.camera_alt_outlined, color: AppColors.textGrey, size: 28))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Group Name Input
                      Expanded(
                        child: AuthField(hint: "Enter your group name", controller: _groupNameController),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 2. Type Section
                Text(
                  "Type",
                  style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GroupTypeCard(
                      icon: Icons.flight_takeoff,
                      label: "Trip",
                      isSelected: state.selectedType == GroupType.trip,
                      onTap: () => context.read<CreateGroupBloc>().add(const SelectGroupType(GroupType.trip)),
                    ),
                    GroupTypeCard(
                      icon: Icons.home_outlined,
                      label: "Home",
                      isSelected: state.selectedType == GroupType.home,
                      onTap: () => context.read<CreateGroupBloc>().add(const SelectGroupType(GroupType.home)),
                    ),
                    GroupTypeCard(
                      icon: Icons.favorite_border,
                      label: "Couple",
                      isSelected: state.selectedType == GroupType.couple,
                      onTap: () => context.read<CreateGroupBloc>().add(const SelectGroupType(GroupType.couple)),
                    ),
                    GroupTypeCard(
                      icon: Icons.list_alt,
                      label: "Other",
                      isSelected: state.selectedType == GroupType.other,
                      onTap: () => context.read<CreateGroupBloc>().add(const SelectGroupType(GroupType.other)),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Invite Code Section
                Text(
                  "Invite Code",
                  style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                const SizedBox(height: 8),
                Text(
                  "Share this code with your friends to join the group",
                  style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.inviteCode,
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.textBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: state.isGeneratingCode
                            ? null
                            : () {
                          context.read<CreateGroupBloc>().add(const GenerateInviteCode());
                        },
                        icon: state.isGeneratingCode
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh, color: AppColors.primaryTeal),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}
