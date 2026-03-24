import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class ExpenseNotePage extends StatefulWidget {
  final String initialNote;
  final int maxWords;

  const ExpenseNotePage({
    super.key,
    required this.initialNote,
    this.maxWords = 1000,
  });

  @override
  State<ExpenseNotePage> createState() => _ExpenseNotePageState();
}

class _ExpenseNotePageState extends State<ExpenseNotePage> {
  late TextEditingController _controller;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _wordCount = _getWordCount(widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  void _onNoteChanged(String text) {
    setState(() {
      _wordCount = _getWordCount(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = _wordCount > widget.maxWords;
    final double progress = _wordCount / widget.maxWords;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "Expense Note",
          style: GoogleFonts.outfit(color: AppColors.textBlack, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: isOverLimit
                  ? null
                  : () => Navigator.pop(context, _controller.text),
              style: TextButton.styleFrom(
                backgroundColor: isOverLimit ? AppColors.borderGrey : AppColors.primaryTeal.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.outfit(
                  color: isOverLimit ? AppColors.textGrey : AppColors.primaryTeal,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Word count indicator & Progress bar
          Container(
             margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withValues(alpha: 0.03),
                   blurRadius: 10,
                   offset: const Offset(0, 4),
                 ),
               ],
             ),
             child: Column(
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       "Writing context",
                       style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey),
                     ),
                     Text(
                       "$_wordCount / ${widget.maxWords} words",
                       style: GoogleFonts.outfit(
                         fontSize: 13,
                         fontWeight: FontWeight.w700,
                         color: isOverLimit ? AppColors.errorRed : AppColors.primaryTeal,
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 12),
                 ClipRRect(
                   borderRadius: BorderRadius.circular(4),
                   child: LinearProgressIndicator(
                     value: progress.clamp(0.0, 1.0),
                     backgroundColor: AppColors.backgroundLightGrey,
                     valueColor: AlwaysStoppedAnimation<Color>(
                       isOverLimit ? AppColors.errorRed : AppColors.primaryTeal,
                     ),
                     minHeight: 6,
                   ),
                 ),
               ],
             ),
          ),
          
          // Note typing area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: true,
                onChanged: _onNoteChanged,
                cursorColor: AppColors.primaryTeal,
                decoration: InputDecoration(
                  hintText: "What was this expense for? Add receipt details, reminders, or specific notes here...",
                  hintStyle: GoogleFonts.outfit(
                    color: AppColors.textGrey.withValues(alpha: 0.5),
                    fontSize: 16,
                    height: 1.6,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  color: AppColors.textBlack,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
