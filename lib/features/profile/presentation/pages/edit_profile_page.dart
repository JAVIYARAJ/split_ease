
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/widgets/auth_field.dart';
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black87),
                title: Text("Take Photo", style: GoogleFonts.openSans(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  bloc.add(const PickProfileImage(ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: Text("Choose from Gallery", style: GoogleFonts.openSans(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  bloc.add(const PickProfileImage(ImageSource.gallery));
                },
              ),
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
            NavigationService.pop();
          }
        },
        builder: (context, state) {
          final bloc = context.read<ProfileBloc>();
          return BaseScreen(
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Edit Profile"),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.textBlack),
                titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ProfileAvatar(
                      avatarUrl: widget.user.avatarUrl,
                      pickedImage: state.pickedImage,
                      onPickTrigger: () => _showImagePickerModal(context, bloc),
                    ),
                    const SizedBox(height: 32),
                    AuthField(
                      label: "Full Name",
                      hint: "Enter your full name",
                      controller: _nameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      label: "Email Address",
                      hint: widget.user.email,
                      controller: TextEditingController(text: widget.user.email), // Read-only mostly
                      icon: Icons.email_outlined,
                      isReadyOnly: true,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          "Email address cannot be changed.",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                    BlocBuilder<ProfileBloc,ProfileState>(builder: (context, state) {
                      return AppPrimaryButton(
                        isLoading: state.status == ProfileStatus.loading,
                        text: "Save Changes",
                        onPressed: () {
                          bloc.add(UpdateProfile(
                            name: _nameController.text.trim(),
                          ));
                        },
                      );
                    },)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
