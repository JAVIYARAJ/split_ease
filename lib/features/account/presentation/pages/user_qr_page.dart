import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/clipboard_utils.dart';
import 'package:split_ease/core/utils/file_utils.dart';

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
          "My Code",
          style: GoogleFonts.openSans(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
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
                      const SizedBox(height: 24),
                      Text(
                        widget.userName,
                        style: GoogleFonts.openSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Split Ease",
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              "Share this code with friends to let them add you easily.",
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isSharing,
                    builder: (context, isSharing, child) {
                      return OutlinedButton.icon(
                        onPressed: isSharing ? null : _shareQrCode,
                        icon: isSharing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.share_rounded, size: 20),
                        label: Text(isSharing ? "Sharing..." : "Share"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ClipboardUtils.copyToClipboard(context, widget.userId, successMessage: "User ID copied!");
                    },
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    label: const Text("Copy ID"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      textStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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
