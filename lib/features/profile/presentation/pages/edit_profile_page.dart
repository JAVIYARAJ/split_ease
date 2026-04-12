import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:split_ease/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
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
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Update Photo",
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                ),
                const SizedBox(height: 24),
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  title: "Take a Photo",
                  subtitle: "Open camera to capture",
                  color: Colors.black,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.add(const PickProfileImage(ImageSource.camera));
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  title: "Choose from Gallery",
                  subtitle: "Upload from your library",
                  color: Colors.black,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.add(const PickProfileImage(ImageSource.gallery));
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      leading: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
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
            AppAlerts.showSuccess(context, "Profile Updated");
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final bloc = context.read<ProfileBloc>();
          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 32),
                      _buildStaggeredWrapper(
                        delay: 0.1,
                        child: Center(
                          child: ProfileAvatar(
                            avatarUrl: widget.user.avatarUrl,
                            pickedImage: state.pickedImage,
                            onPickTrigger: () => _showImagePickerModal(context, bloc),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildStaggeredWrapper(
                        delay: 0.2,
                        child: _buildInputField(
                          label: "Full Name",
                          controller: _nameController,
                          icon: Icons.person_rounded,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStaggeredWrapper(
                        delay: 0.3,
                        child: _buildInputField(
                          label: "Email Address",
                          initialValue: widget.user.email,
                          icon: Icons.email_rounded,
                          readOnly: true,
                          helperText: "Your email cannot be modified",
                        ),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomActions(context, state),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
      leadingWidth: 80,
      leading: AppBackButton(onPressed: () => Navigator.pop(context)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Account Settings",
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: -0.5),
          ),
          Text(
            "Personalize your appearance",
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textGrey),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildInputField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    bool readOnly = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textBlack.withValues(alpha: 0.4), letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: readOnly ? AppColors.textGrey : AppColors.textBlack),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? AppColors.backgroundLightGrey.withValues(alpha: 0.5) : AppColors.backgroundLightGrey,
            prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
            suffixIcon: readOnly ? const Icon(Icons.lock_rounded, color: AppColors.textGrey, size: 16) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
            hintText: "Enter $label",
            hintStyle: GoogleFonts.outfit(color: AppColors.textGrey.withValues(alpha: 0.4)),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              helperText,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, ProfileState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: InkWell(
          onTap: state.status == ProfileStatus.loading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  context.read<ProfileBloc>().add(UpdateProfile(name: _nameController.text.trim()));
                },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: state.status == ProfileStatus.loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(
                      "Update Profile",
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredWrapper({required Widget child, required double delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (600 + (delay * 1000)).toInt()),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
