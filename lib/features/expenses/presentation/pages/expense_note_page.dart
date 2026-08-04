import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/config/app_configs.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/theme/app_layout.dart';

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
  late FocusNode _focusNode;
  int _charCount = 0;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _charCount = widget.initialNote.length;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = Theme.of(context).ext;

    return Scaffold(
      backgroundColor: ext.scaffoldBg,
      appBar: AppBar(
        backgroundColor: ext.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: AppLayout.appBarLeadingWidth,
        leading: AppBackButton(
          onPressed: () => Navigator.pop(context),
          color: ext.textPrimary,
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        title: Text(
          "Expense Note",
          style: GoogleFonts.outfit(
            color: ext.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: isOverLimit
                  ? null
                  : () => Navigator.pop(context, _controller.text.trim()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                "Done",
                style: GoogleFonts.outfit(
                  color: isOverLimit ? ext.textTertiary : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              // Main Notebook Card
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isOverLimit
                          ? AppColors.errorRed
                          : (_isFocused
                              ? AppColors.primary
                              : ext.border.withValues(alpha: 0.6)),
                      width: _isFocused || isOverLimit ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isOverLimit
                            ? AppColors.errorRed.withValues(alpha: 0.1)
                            : (_isFocused
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : ext.shadowLight),
                        blurRadius: _isFocused ? 16 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // ── Layer 1: Notebook Paper Page (Base) ──
                        Positioned.fill(
                          child: Container(
                            color: isDark
                                ? const Color(0xFF141C2B)
                                : const Color(0xFFFAFAFA),
                            child: Column(
                              children: [
                                const SizedBox(height: 60), // Spacer for top header band

                                // Writing Paper Field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical: TextAlignVertical.top,
                                      keyboardType: TextInputType.multiline,
                                      autofocus: true,
                                      onChanged: _onNoteChanged,
                                      cursorColor: AppColors.primary,
                                      cursorWidth: 2,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        color: ext.textPrimary,
                                        height: 1.6,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            "What was this expense for? Add receipt details, breakdown, or reminders...",
                                        hintStyle: GoogleFonts.outfit(
                                          color: ext.textTertiary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),

                                if (_charCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _controller.clear();
                                            _onNoteChanged('');
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.backspace_outlined,
                                                  size: 14,
                                                  color: ext.textTertiary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "Clear note",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: ext.textTertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // ── Layer 2: Elevated Notebook Header Band (Casts Top Drop Shadow onto Paper) ──
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ext.surface,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(22)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: isDark ? 0.45 : 0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 14, 18, 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_note_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Notes & Details",
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: ext.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isOverLimit
                                              ? AppColors.errorRed
                                                  .withValues(alpha: 0.1)
                                              : (progress > 0.8
                                                  ? AppColors.warningOrange
                                                      .withValues(alpha: 0.1)
                                                  : ext.backgroundGrey),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "$_charCount / ${widget.maxCharacters}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isOverLimit
                                                ? AppColors.errorRed
                                                : (progress > 0.8
                                                    ? AppColors.warningOrange
                                                    : ext.textSecondary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Micro progress bar
                                ClipRRect(
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 2.5,
                                    backgroundColor:
                                        ext.border.withValues(alpha: 0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isOverLimit
                                          ? AppColors.errorRed
                                          : (progress > 0.8
                                              ? AppColors.warningOrange
                                              : AppColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Privacy Info Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isOverLimit
                      ? AppColors.errorRed.withValues(alpha: 0.08)
                      : ext.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOverLimit
                        ? AppColors.errorRed.withValues(alpha: 0.2)
                        : ext.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverLimit
                          ? Icons.warning_amber_rounded
                          : Icons.lock_outline_rounded,
                      size: 18,
                      color: isOverLimit ? AppColors.errorRed : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isOverLimit
                            ? "Maximum limit of ${widget.maxCharacters} characters exceeded."
                            : "Notes are private and visible only on this expense.",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isOverLimit ? AppColors.errorRed : ext.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
