import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/clipboard_utils.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/widgets/auth_field.dart';
import '../bloc/create_group_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/group_type.dart';
import '../../domain/entities/group_entity.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['is_edit'] == true) {
        final group = args['group'] as GroupEntity;
        _groupNameController.text = group.name ?? '';
        context.read<CreateGroupBloc>().add(InitializeCreateGroup(group: group));
      } else {
        context.read<CreateGroupBloc>().add(const GenerateInviteCode());
      }
    });
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
          AppAlerts.showSuccess(context, state.isEditMode ? "Group updated successfully" : "Group created successfully");
          if (state.isEditMode) {
             Navigator.pop(context, true);
          } else {
             NavigationService.pushReplacement(AppRoutes.groupDetail,args: {"group_id":state.createdGroupId}, result: true);
          }
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
              onPressed: () => NavigationService.pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.openSans(
                  color: AppColors.textGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              state.isEditMode ? "Edit Group" : "New Group",
              style: GoogleFonts.openSans(
                color: AppColors.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: state.status == CreateGroupStatus.loading ? null : () {
                    if (state.isEditMode) {
                      context.read<CreateGroupBloc>().add(UpdateGroupSubmitted(
                        groupId: state.createdGroupId!, 
                        name: _groupNameController.text, 
                        type: state.selectedType
                      ));
                    } else {
                      context.read<CreateGroupBloc>().add(CreateGroupSubmitted(name: _groupNameController.text, type: state.selectedType));
                    }
                  },
                  child: state.status == CreateGroupStatus.loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          state.isEditMode ? "Save" : "Create",
                          style: GoogleFonts.openSans(
                            color: AppColors.primaryTeal,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // 1. Centered Image Picker
                GestureDetector(
                  onTap: () {
                    context.read<CreateGroupBloc>().add(const PickGroupImage());
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundLightGrey,
                          image: state.groupImage != null 
                              ? DecorationImage(image: FileImage(state.groupImage!), fit: BoxFit.cover) 
                              : (state.existingIconUrl != null 
                                  ? DecorationImage(image: CachedNetworkImageProvider(state.existingIconUrl!), fit: BoxFit.cover)
                                  : null),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: state.groupImage == null && state.existingIconUrl == null
                            ? Icon(Icons.camera_alt_outlined, color: AppColors.textGrey.withValues(alpha: 0.5), size: 40)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // 2. Group Name Input
                AuthField(
                  hint: "Group Name",
                  controller: _groupNameController,
                  // Since AuthField might not support centered text directly via property, we rely on its default. 
                  // If we need centered, we might need to modify AuthField or wrap/replace it.
                  // For now, let's stick to standard left align but clean look.
                ),

                const SizedBox(height: 40),

                // 3. Group Type Selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Group Type",
                    style: GoogleFonts.openSans(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildTypeChip(context, state, GroupType.trip, Icons.flight_takeoff, "Trip"),
                      _buildTypeChip(context, state, GroupType.home, Icons.home_outlined, "Home"),
                      _buildTypeChip(context, state, GroupType.couple, Icons.favorite_border, "Couple"),
                      _buildTypeChip(context, state, GroupType.other, Icons.list_alt, "Other"),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 4. Invite Code Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Invite Code",
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                           IconButton(
                            onPressed: state.isGeneratingCode
                                ? null
                                : () {
                              context.read<CreateGroupBloc>().add(const GenerateInviteCode());
                            },
                            icon: state.isGeneratingCode
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.refresh, color: AppColors.primaryTeal, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.inviteCode,
                              style: GoogleFonts.robotoMono( 
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.textBlack,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ClipboardUtils.copyToClipboard(context, state.inviteCode, successMessage: "Invite code copied!");
                              },
                              icon: const Icon(Icons.copy_rounded, color: AppColors.textGrey, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: "Copy Code",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Share this code with friends to let them join.",
                        style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey),
                        textAlign: TextAlign.center,
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

  Widget _buildTypeChip(BuildContext context, CreateGroupState state, GroupType type, IconData icon, String label) {
    final isSelected = state.selectedType == type;
    return GestureDetector(
      onTap: () => context.read<CreateGroupBloc>().add(SelectGroupType(type)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.openSans(
                color: isSelected ? Colors.white : AppColors.textGrey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
