import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/config/app_configs.dart';

class ExpenseNotePage extends StatefulWidget {
  final String initialNote;
  final int maxCharacters;

  const ExpenseNotePage({
    super.key,
    required this.initialNote,
    this.maxCharacters = AppConfigs.maxExpenseNoteCharacters,
  });

  @override
  State<ExpenseNotePage> createState() => _ExpenseNotePageState();
}

class _ExpenseNotePageState extends State<ExpenseNotePage> {
  late TextEditingController _controller;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _charCount = widget.initialNote.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNoteChanged(String text) {
    setState(() {
      _charCount = text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = _charCount > widget.maxCharacters;
    final double progress = (_charCount / widget.maxCharacters).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Theme.of(context).ext.textPrimary, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notes",
          style: GoogleFonts.outfit(color: Theme.of(context).ext.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: isOverLimit ? null : () => Navigator.pop(context, _controller.text),
              style: TextButton.styleFrom(
                foregroundColor: isOverLimit ? AppColors.textGrey : AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text(
                "Done",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Character count progress header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).ext.surface,
              border: Border(bottom: BorderSide(color: Theme.of(context).ext.border.withValues(alpha: 0.2), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Expense notes",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).ext.textPrimary,
                      ),
                    ),
                    Text(
                      "$_charCount / ${widget.maxCharacters} characters",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isOverLimit ? AppColors.errorRed : AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).ext.border.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverLimit ? AppColors.errorRed : AppColors.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Note Field Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).ext.inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOverLimit ? AppColors.errorRed : Theme.of(context).ext.border.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: true,
                onChanged: _onNoteChanged,
                cursorColor: AppColors.primaryTeal,
                cursorWidth: 2,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Theme.of(context).ext.textPrimary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "What was this for?...",
                  hintStyle: GoogleFonts.outfit(
                    color: Theme.of(context).ext.textTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          
          // Bottom Helper Bar
          Container(
            padding: EdgeInsets.only(
              left: 24, 
              right: 24, 
              top: 12, 
              bottom: MediaQuery.of(context).padding.bottom + 12
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).ext.surface,
              border: Border(top: BorderSide(color: Theme.of(context).ext.border.withValues(alpha: 0.1), width: 1)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Theme.of(context).ext.textSecondary),
                const SizedBox(width: 8),
                Text(
                   isOverLimit 
                    ? "Maximum character limit reached."
                    : "Notes are private to this expense entry.",
                   style: GoogleFonts.outfit(
                     fontSize: 12,
                     fontWeight: FontWeight.w600,
                     color: isOverLimit ? AppColors.errorRed : Theme.of(context).ext.textSecondary,
                   ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
