import 'dart:io';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';

class ExpenseMediaList extends StatelessWidget {
  final ExpenseDetailEntity entity;
  final bool canManageExpense;

  const ExpenseMediaList({
    super.key,
    required this.entity,
    required this.canManageExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (entity.media.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entity.media.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final media = entity.media[index];
          return GestureDetector(
            onTap: () async {
              final ext = media.fileName.toLowerCase().split('.').last;
              final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext) || (media.mediaType == 'image' && ext != 'csv' && ext != 'pdf');
              final isPdf = ext == 'pdf' || ((media.mediaType == 'pdf' || media.mimeType == 'application/pdf') && ext != 'csv' && ext != 'jpg' && ext != 'png');
              final isPreviewable = isImage || isPdf;

              showDialog(
                context: context,
                builder: (dialogContext) => Dialog(
                  backgroundColor: Theme.of(context).ext.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isImage 
                                ? Icons.image_rounded 
                                : (isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded), 
                              color: AppColors.primaryTeal, 
                              size: 40
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          media.fileName,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).ext.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Type: ${media.fileName.split('.').last.toUpperCase()} Document",
                          style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).ext.textSecondary),
                        ),
                        if (!isPreviewable) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Download to view this attachment",
                                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primaryTeal, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (isPreviewable) ...[
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () async {
                                Navigator.pop(dialogContext); // Close the detail dialog
                                if (isImage) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.zero,
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Colors.black.withValues(alpha: 0.9),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              InteractiveViewer(
                                                minScale: 0.5,
                                                maxScale: 4.0,
                                                child: Hero(
                                                  tag: 'media_${media.url}',
                                                  child: CachedNetworkImage(
                                                    imageUrl: media.url,
                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                                                    errorWidget: (context, url, error) => const Icon(Icons.error_outline, color: Colors.white, size: 50),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 50,
                                                right: 20,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (isPdf) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
                                  );
                                  try {
                                    final response = await http.get(Uri.parse(media.url));
                                    if (context.mounted) Navigator.pop(context); // close loader
                                    if (response.statusCode == 200) {
                                      final dir = await getTemporaryDirectory();
                                      final file = File('${dir.path}/${media.fileName}');
                                      await file.writeAsBytes(response.bodyBytes);
                                      if (context.mounted) {
                                        NavigationService.pushNamed(
                                          AppRoutes.expensePdfPreview,
                                          args: {'pdfPath': file.path, 'expenseDescription': media.fileName},
                                        );
                                      }
                                    } else {
                                      if (context.mounted) AppAlerts.showError(context, "Failed to download PDF: ${response.statusCode}");
                                    }
                                  } catch (e) {
                                    if (context.mounted) Navigator.pop(context);
                                    debugPrint("PDF Download Error: $e");
                                    if (context.mounted) AppAlerts.showError(context, "Error: $e");
                                  }
                                }
                              },
                              icon: const Icon(Icons.visibility_rounded, color: AppColors.primaryTeal),
                              label: Text("View File", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () async {
                              Navigator.pop(dialogContext); // Close the detail dialog
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
                              );
                              try {
                                final response = await http.get(Uri.parse(media.url));
                                if (context.mounted) Navigator.pop(context); // Close loader
                                if (response.statusCode == 200) {
                                  final dir = await getTemporaryDirectory();
                                  final file = File('${dir.path}/${media.fileName}');
                                  await file.writeAsBytes(response.bodyBytes);
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(file.path)],
                                      text: 'Attached file: ${media.fileName}',
                                    ),
                                  );
                                } else {
                                  if (context.mounted) AppAlerts.showError(context, "Failed to download document: ${response.statusCode}");
                                }
                              } catch (e) {
                                if (context.mounted) Navigator.pop(context);
                                debugPrint("File Download Error: $e");
                                if (context.mounted) AppAlerts.showError(context, "Error: $e");
                              }
                            },
                            icon: const Icon(Icons.download_rounded, color: Colors.white),
                            label: Text("Download File", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(media.fileName.toLowerCase().split('.').last) || media.mediaType == 'image') && media.fileName.toLowerCase().split('.').last != 'csv' ? Theme.of(context).ext.surface : AppColors.primaryTeal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(media.fileName.toLowerCase().split('.').last) || media.mediaType == 'image') && media.fileName.toLowerCase().split('.').last != 'csv' ? Theme.of(context).ext.border : AppColors.primaryTeal.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(media.fileName.toLowerCase().split('.').last) || media.mediaType == 'image') && media.fileName.toLowerCase().split('.').last != 'csv'
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'media_${media.url}',
                                child: CachedNetworkImage(
                                  imageUrl: media.url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: AppColors.primaryTeal, strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.broken_image_rounded, color: Theme.of(context).ext.textSecondary),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                                    ),
                                  ),
                                  child: const Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                (media.fileName.toLowerCase().endsWith('.pdf') || ((media.mimeType == 'application/pdf' || media.mediaType == 'pdf') && !media.fileName.toLowerCase().endsWith('.csv')))
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.description_rounded,
                                color: AppColors.primaryTeal,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  media.fileName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).ext.textPrimary,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (canManageExpense && media.id != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: Theme.of(context).ext.surface,
                              title: Text("Delete Attachment", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary)),
                              content: Text("Are you sure you want to permanently delete this attachment?", style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text("Cancel", style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.errorRed,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    context.read<ExpenseDetailBloc>().add(
                                          DeleteExpenseMediaEvent(
                                            expenseId: entity.id,
                                            mediaId: media.id!,
                                          ),
                                        );
                                  },
                                  child: Text("Delete", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );
                          }
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
