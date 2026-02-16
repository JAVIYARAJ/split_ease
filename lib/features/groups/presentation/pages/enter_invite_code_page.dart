import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/groups/presentation/bloc/join_group_bloc.dart';
import 'package:split_ease/features/groups/presentation/pages/qr_scanner_page.dart';
import 'package:split_ease/core/presentation/widgets/success_dialog.dart';

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
            builder: (context) => SuccessDialog(
              title: "Woohoo!",
              description: "You're in! Get ready to split bills and settle up seamlessly.",
              buttonText: "Open Group",
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
          centerTitle: true,
        ),
        // positioning the button at the bottom
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 24, 
            right: 24, 
            bottom: MediaQuery.of(context).viewInsets.bottom + 24 // Handle keyboard
          ),
          child: BlocBuilder<JoinGroupBloc, JoinGroupState>(
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
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: AppColors.backgroundLightGrey,
                    disabledForegroundColor: AppColors.textGrey.withValues(alpha: 0.5),
                  ),
                  child: state.status == JoinGroupStatus.loading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          'Join Group',
                          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              );
            },
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.mark_email_unread_outlined, size: 72, color: AppColors.primaryTeal.withValues(alpha: 0.8)),
              const SizedBox(height: 24),
              Text(
                'Join Group',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold, 
                  fontSize: 28, 
                  color: AppColors.textBlack
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the invitation code shared with you to join the group.',
                style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              BlocBuilder<JoinGroupBloc, JoinGroupState>(
                buildWhen: (previous, current) => previous.code != current.code,
                builder: (context, state) {
                  return TextField(
                    onChanged: (value) {
                      context.read<JoinGroupBloc>().add(JoinGroupCodeChanged(value));
                    },
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppColors.textBlack,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundLightGrey,
                      hintText: 'CODE',
                      hintStyle: GoogleFonts.robotoMono(
                        color: Colors.grey.shade400,
                        fontSize: 24,
                        letterSpacing: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), 
                        borderSide: BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), 
                        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.borderGrey.withValues(alpha: 0.5))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.borderGrey.withValues(alpha: 0.5))),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QrScannerPage()),
                    );
                    if (result != null && result is String && context.mounted) {
                      context.read<JoinGroupBloc>().add(JoinGroupQrScanned(result));
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: Text("Scan QR Code", style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textBlack,
                    side: const BorderSide(color: AppColors.borderGrey),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
