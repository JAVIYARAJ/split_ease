import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/presentation/widgets/app_error_full_screen_dialog.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/clipboard_utils.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
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
  String _initialName = '';
  GroupType _initialType = GroupType.other;
  String _initialCode = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['is_edit'] == true) {
        final group = args['group'] as GroupEntity;
        _initialName = group.name ?? '';
        _initialCode = group.inviteCode ?? '';
        
        // Correct string to enum mapping
        try {
          _initialType = GroupType.values.firstWhere(
            (e) => e.name == group.groupType,
            orElse: () => GroupType.other
          );
        } catch (_) {
          _initialType = GroupType.other;
        }

        _groupNameController.text = _initialName;
        context.read<CreateGroupBloc>().add(InitializeCreateGroup(group: group));
      } else {
        _initialType = GroupType.trip;
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
            NavigationService.pushReplacement(AppRoutes.groupDetail, args: {"group_id": state.createdGroupId}, result: true);
          }
        } else if (state.status == CreateGroupStatus.failure) {
          AppAlerts.showError(context, state.errorMessage ?? "An error occurred");
        }
      },
      builder: (context, state) {
        if (state.status == CreateGroupStatus.failure && state.inviteCode.isEmpty) {
          return AppErrorFullScreenWidget(
            errorMessage: state.errorMessage,
            onRefresh: () async {
              final bloc = context.read<CreateGroupBloc>();
              bloc.add(const GenerateInviteCode());
              final nextState = await bloc.stream.firstWhere(
                (s) => s.status != CreateGroupStatus.loading,
              );
              return nextState.status != CreateGroupStatus.failure;
            },
          );
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final canGoBack = await _onWillPop(state);
            if (canGoBack && mounted) {
              NavigationService.pop();
            }
          },
          child: BaseScreen(
            backgroundColor: Theme.of(context).ext.scaffoldBg,
            appBar: AppBar(
              backgroundColor: Theme.of(context).ext.scaffoldBg,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: AppBackButton(onPressed: () => _onWillPop(state).then((canPop) {
                if (canPop) NavigationService.pop();
              })),
              title: Text(
                state.isEditMode ? "Edit Group" : "Create Group",
                style: GoogleFonts.outfit(
                  color: Theme.of(context).ext.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _fadeInUp(_buildImagePicker(context, state), 0),
                        const SizedBox(height: 24),
                        _fadeInUp(_buildSectionLabel("GROUP NAME"), 1),
                        const SizedBox(height: 12),
                        _fadeInUp(_buildGroupNameInput(state), 2),
                        const SizedBox(height: 24),
                        _fadeInUp(_buildSectionLabel("CHOOSE CATEGORY"), 3),
                        const SizedBox(height: 12),
                        _fadeInUp(_buildTypeSelector(context, state), 4),
                      const SizedBox(height: 24),
                      _fadeInUp(_buildInviteCard(context, state), 5),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildFloatingSubmitButton(context, state),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).ext.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, CreateGroupState state) {
    return Center(
      child: GestureDetector(
        onTap: () => context.read<CreateGroupBloc>().add(const PickGroupImage()),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).ext.inputFill,
                border: Border.all(color: Theme.of(context).ext.border, width: 3),
                image: state.groupImage != null
                    ? DecorationImage(image: FileImage(state.groupImage!), fit: BoxFit.cover)
                    : (state.existingIconUrl != null
                        ? DecorationImage(image: CachedNetworkImageProvider(state.existingIconUrl!), fit: BoxFit.cover)
                        : null),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: state.groupImage == null && state.existingIconUrl == null
                  ? Icon(Icons.camera_alt_rounded, color: Theme.of(context).ext.textTertiary, size: 32)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupNameInput(CreateGroupState state) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _groupNameController,
        maxLines: 1,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "E.g. Weekend Trip",
          hintStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).ext.textTertiary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, CreateGroupState state) {
    final types = [GroupType.trip, GroupType.home, GroupType.couple, GroupType.other];
    final selectedIndex = types.indexOf(state.selectedType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / 4;

        return Container(
          height: 68,
          decoration: BoxDecoration(
            color: Theme.of(context).ext.inputFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              // Sliding Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                left: (selectedIndex * segmentWidth) + 4,
                top: 4,
                bottom: 4,
                width: segmentWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                ),
              ),
              // Interactive Segments
              Row(
                children: [
                  _buildTypeSegment(context, state, GroupType.trip, Icons.flight_rounded, "Trip"),
                  _buildTypeSegment(context, state, GroupType.home, Icons.home_rounded, "Home"),
                  _buildTypeSegment(context, state, GroupType.couple, Icons.favorite_rounded, "Duo"),
                  _buildTypeSegment(context, state, GroupType.other, Icons.more_horiz_rounded, "Other"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeSegment(BuildContext context, CreateGroupState state, GroupType type, IconData icon, String label) {
    final isSelected = state.selectedType == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<CreateGroupBloc>().add(SelectGroupType(type));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedIconTheme(
              duration: const Duration(milliseconds: 300),
              color: isSelected ? Colors.white : Theme.of(context).ext.textTertiary,
              size: 20,
              child: Icon(icon),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Theme.of(context).ext.textTertiary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, CreateGroupState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Invite Code", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              IconButton(
                onPressed: state.isGeneratingCode ? null : () => context.read<CreateGroupBloc>().add(const GenerateInviteCode()),
                icon: state.isGeneratingCode
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
                  child: Text(
                    state.inviteCode,
                    key: ValueKey<String>(state.inviteCode),
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 2, color: Theme.of(context).ext.textPrimary),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => ClipboardUtils.copyToClipboard(context, state.inviteCode, successMessage: "Code copied!"),
                icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                style: IconButton.styleFrom(backgroundColor: Theme.of(context).ext.scaffoldBg, padding: const EdgeInsets.all(10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Invite friends to join your group using this code.", style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).ext.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFloatingSubmitButton(BuildContext context, CreateGroupState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      color: Theme.of(context).ext.surface,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: state.status == CreateGroupStatus.loading
              ? null
              : () {
                  if (state.isEditMode) {
                    context.read<CreateGroupBloc>().add(UpdateGroupSubmitted(groupId: state.createdGroupId!, name: _groupNameController.text, type: state.selectedType));
                  } else {
                    context.read<CreateGroupBloc>().add(CreateGroupSubmitted(name: _groupNameController.text, type: state.selectedType));
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: state.status == CreateGroupStatus.loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(state.isEditMode ? "Save Changes" : "Create Group", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(CreateGroupState state) async {
    final bool nameChanged = _groupNameController.text.trim() != _initialName;
    final bool typeChanged = state.selectedType != _initialType;
    final bool imageChanged = state.groupImage != null;
    final bool codeChanged = _initialCode.isNotEmpty && state.inviteCode != _initialCode;

    if (!nameChanged && !typeChanged && !imageChanged && !codeChanged) return true;

    final discard = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => _DiscardDialog(),
    );

    return discard ?? false;
  }

  Widget _fadeInUp(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 15 * (1 - value)), child: child)),
      child: child,
    );
  }
}

class _DiscardDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              "Unsaved Changes",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).ext.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              "You have unsaved changes that will be lost if you leave this page.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).ext.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("Discard Changes", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("Continue Editing", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textSecondary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widget for Icon Animation ──
class AnimatedIconTheme extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;
  final Duration duration;

  const AnimatedIconTheme({
    super.key,
    required this.child,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: duration,
      style: TextStyle(color: color, fontSize: size),
      child: IconTheme(
        data: IconThemeData(color: color, size: size),
        child: child,
      ),
    );
  }
}

