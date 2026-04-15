import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class ExpensePdfPreviewPage extends StatelessWidget {
  final String pdfPath;
  final String expenseDescription;

  const ExpensePdfPreviewPage({
    super.key,
    required this.pdfPath,
    required this.expenseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGrey,
      appBar: AppBar(
        title: Text(
          "Receipt Preview",
          style: GoogleFonts.outfit(
            color: AppColors.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBlack),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            onPressed: () async {
              await Share.shareXFiles(
                [XFile(pdfPath)],
                text: 'Here is the expense receipt for "$expenseDescription".',
              );
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}
