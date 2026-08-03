import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/presentation/widgets/animations/animated_counter_text.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_formatter.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import '../../domain/entities/category_expense_item_entity.dart';
import '../../domain/entities/expense_breakdown_entity.dart';

class CategoryTransactionsBottomSheet extends StatefulWidget {
  final CategoryDetailEntity category;
  final DateTime? startDate;
  final DateTime? endDate;
  final Future<List<CategoryExpenseItemEntity>> Function(int offset, int limit) fetchTransactions;
  final Function(String expenseId)? onExpenseTap;

  const CategoryTransactionsBottomSheet({
    super.key,
    required this.category,
    this.startDate,
    this.endDate,
    required this.fetchTransactions,
    this.onExpenseTap,
  });

  @override
  State<CategoryTransactionsBottomSheet> createState() => _CategoryTransactionsBottomSheetState();
}

class _CategoryTransactionsBottomSheetState extends State<CategoryTransactionsBottomSheet> {
  final List<CategoryExpenseItemEntity> _items = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 15;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirstPage = true;
      _errorMessage = null;
      _offset = 0;
      _items.clear();
    });

    try {
      final newItems = await widget.fetchTransactions(_offset, _limit);
      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _offset += newItems.length;
          _hasMore = newItems.length >= _limit;
          _isLoadingFirstPage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingFirstPage = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newItems = await widget.fetchTransactions(_offset, _limit);
      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _offset += newItems.length;
          _hasMore = newItems.length >= _limit;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _parseColor(widget.category.color);
    final iconData = IconUtils.getIconFromString(widget.category.icon);

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.40,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).ext.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag Handle Bar ──
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.border.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header Summary Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(iconData, color: catColor, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.name,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).ext.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.category.expenseCount} Transactions",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).ext.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedCounterText(
                            value: widget.category.amount,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: catColor,
                            ),
                          ),
                          if (widget.category.expenseCount > 0)
                            Text(
                              "Avg: ${AppFormatter.formatCurrency(widget.category.amount / widget.category.expenseCount)}",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).ext.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Theme.of(context).ext.borderLight),

              // ── Transactions List / Loading / Empty State ──
              Expanded(
                child: _isLoadingFirstPage
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _items.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                itemCount: _items.length + (_hasMore ? 1 : 0),
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (index == _items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }
                                  final item = _items[index];
                                  return _buildTransactionTile(context, item, catColor);
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(BuildContext context, CategoryExpenseItemEntity item, Color catColor) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final isGroup = item.expenseType == 'group';
    final isPersonal = item.expenseType == 'personal';

    final badgeColor = isGroup
        ? AppColors.primary
        : isPersonal
            ? const Color(0xFF00E5FF)
            : const Color(0xFF7C4DFF);

    return InkWell(
      onTap: () {
        if (widget.onExpenseTap != null) {
          widget.onExpenseTap!(item.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).ext.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).ext.border.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left Category Indicator Dot
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),

            // Center Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).ext.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Scope badge (Group / Personal / Non-Group)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isGroup && item.groupName != null
                                ? item.groupName!
                                : isGroup
                                    ? "Group"
                                    : isPersonal
                                        ? "Personal"
                                        : "Non-Group",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(item.expenseDate),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).ext.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Amount & Paid By
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatter.formatCurrency(item.amount),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).ext.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.paidBy == 'You' ? 'Paid by You' : 'Paid by ${item.paidBy}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).ext.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 44, color: Theme.of(context).ext.textTertiary),
          const SizedBox(height: 12),
          Text(
            "No Transactions Found",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).ext.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "There are no recorded expenses for this category in the selected period.",
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Theme.of(context).ext.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
          const SizedBox(height: 10),
          Text(
            "Failed to load transactions",
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadFirstPage,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
