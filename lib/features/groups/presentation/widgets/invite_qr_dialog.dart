import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/clipboard_utils.dart';
import 'package:split_ease/core/utils/file_utils.dart';

class InviteQrDialog extends StatefulWidget {
  final String inviteCode;
  final String groupName;

  const InviteQrDialog({super.key, required this.inviteCode, required this.groupName});

  @override
  State<InviteQrDialog> createState() => _InviteQrDialogState();
}

class _InviteQrDialogState extends State<InviteQrDialog> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareQrCode() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final file = await FileUtils.saveBytesToFile(imageBytes, 'invite_qr.png');
        SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Join my group "${widget.groupName}" on Split Ease using this code: ${widget.inviteCode}'),
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to share QR code');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer for centering
                Text(
                  "Scan to Join",
                  style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                ),
                InkWell(
                  onTap: () => NavigationService.pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Share this QR code with friends to add them to '${widget.groupName}'",
              style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Screenshot(
              controller: _screenshotController,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8))],
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: widget.inviteCode,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                      // foregroundColor: AppColors.textBlack, // Deprecated, handled by dataModuleStyle
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primary),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.inviteCode,
                      style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack, letterSpacing: 2.0),
                    ),
                    Text(
                      "Scan to join group", // Helper text in image
                      style: GoogleFonts.openSans(fontSize: 10, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSharing ? null : _shareQrCode,
                    icon: _isSharing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.share_rounded, size: 18),
                    label: Text(_isSharing ? "Sharing..." : "Share"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ClipboardUtils.copyToClipboard(context, widget.inviteCode, successMessage: "Invite code copied!");
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text("Copy Code"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
