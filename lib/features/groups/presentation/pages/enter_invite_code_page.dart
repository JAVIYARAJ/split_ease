import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/groups/presentation/bloc/join_group_bloc.dart';
import '../widgets/congratulation_dialog.dart';

class EnterInviteCodePage extends StatelessWidget {
  const EnterInviteCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<JoinGroupBloc, JoinGroupState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == JoinGroupStatus.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CongratulationDialog(
              onContinue: () async {
                Navigator.of(context).pop(); // Pop dialog
                if (state.joinedGroupId != null) {
                  await NavigationService.pushReplacement(
                    AppRoutes.groupDetail,
                    args: {"group_id": state.joinedGroupId},
                    result: true,
                  );
                }
              },
            ),
          );
          // AppAlerts.showSuccess(context, 'Successfully joined the group!');
        } else if (state.status == JoinGroupStatus.failure) {
          AppAlerts.showError(context, state.errorMessage ?? 'Failed to join group');
        }
      },
      child: BaseScreen(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textBlack),
            onPressed: () => NavigationService.pop(),
          ),
          title: Text(
            'Enter Invite Code',
            style: GoogleFonts.openSans(color: AppColors.textBlack, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Code',
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlack),
              ),
              const SizedBox(height: 8),
              Text(
                'To join your new group, copy the invite code from the invitation you received and add it below.',
                style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              BlocBuilder<JoinGroupBloc, JoinGroupState>(
                buildWhen: (previous, current) => previous.code != current.code,
                builder: (context, state) {
                  return TextField(
                    onChanged: (value) {
                      context.read<JoinGroupBloc>().add(JoinGroupCodeChanged(value));
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      hintText: 'ex: AbCd',
                      hintStyle: GoogleFonts.openSans(color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<JoinGroupBloc, JoinGroupState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isValid && state.status != JoinGroupStatus.loading
                          ? () {
                              context.read<JoinGroupBloc>().add(const JoinGroupSubmitted());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: state.status == JoinGroupStatus.loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Confirm Your Code',
                              style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
