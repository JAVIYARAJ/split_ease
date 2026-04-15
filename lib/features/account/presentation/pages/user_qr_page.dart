import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/clipboard_utils.dart';
import 'package:split_ease/core/utils/file_utils.dart';
import 'package:split_ease/core/presentation/widgets/animations/staggered_entry_column.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';

class UserQrPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const UserQrPage({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  State<UserQrPage> createState() => _UserQrPageState();
}

class _UserQrPageState extends State<UserQrPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ValueNotifier<bool> _isSharing = ValueNotifier<bool>(false);

  Future<void> _shareQrCode() async {
    HapticFeedback.mediumImpact();
    _isSharing.value = true;

    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final file = await FileUtils.saveBytesToFile(imageBytes, 'user_qr.png');
        SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Add me on Split Ease! Scan this QR code',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to share QR code');
      }
    } finally {
      _isSharing.value = false;
    }
  }

  @override
  void dispose() {
    _isSharing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My QR Code",
          style: GoogleFonts.outfit(
            color: AppColors.textBlack,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        leading: AppBackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: StaggeredEntryColumn(
          verticalOffset: 30,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: widget.userId,
                        version: QrVersions.auto,
                        size: 240.0,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.primary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        widget.userName,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          "SPLIT EASE",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              "Friends can scan this tag with their camera to add you to their network instantly.",
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isSharing,
                builder: (context, isSharing, child) {
                  return ElevatedButton.icon(
                    onPressed: isSharing ? null : _shareQrCode,
                    icon: isSharing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                        : const Icon(Icons.share_rounded, size: 22),
                    label: Text(isSharing ? "HOLD ON..." : "SHARE TAG"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textBlack,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                      textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
