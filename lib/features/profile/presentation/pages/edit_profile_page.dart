import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:split_ease/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:split_ease/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:split_ease/injection_container.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showImagePickerModal(BuildContext context, ProfileBloc bloc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: AppColors.primaryTeal),
                ),
                title: Text("Take Photo", style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  bloc.add(const PickProfileImage(ImageSource.camera));
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: Colors.purple),
                ),
                title: Text("Choose from Gallery", style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  bloc.add(const PickProfileImage(ImageSource.gallery));
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure) {
            AppAlerts.showError(context, state.errorMessage ?? "An error occurred");
          } else if (state.status == ProfileStatus.success) {
            AppAlerts.showSuccess(context, "Profile updated successfully");
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final bloc = context.read<ProfileBloc>();
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "Edit Profile",
                style: GoogleFonts.openSans(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textBlack),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AppPrimaryButton(
                  text: "Save Changes",
                  isLoading: state.status == ProfileStatus.loading,
                  onPressed: () {
                    bloc.add(UpdateProfile(
                      name: _nameController.text.trim(),
                    ));
                  },
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ProfileAvatar(
                    avatarUrl: widget.user.avatarUrl,
                    pickedImage: state.pickedImage,
                    onPickTrigger: () => _showImagePickerModal(context, bloc),
                  ),
                  const SizedBox(height: 48),

                  // Name Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Full Name",
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundLightGrey,
                      hintText: "Enter your full name",
                      hintStyle: GoogleFonts.openSans(fontSize: 16, color: AppColors.textGrey.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textGrey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email Field (Read-only)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email Address",
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: widget.user.email,
                    readOnly: true,
                    style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textGrey),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundLightGrey.withValues(alpha: 0.5),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textGrey),
                      suffixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textGrey, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                   const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        "Email address cannot be changed.",
                        style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.7)),
                      ),
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
}
