import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/icon_utils.dart';
import '../bloc/category_limits/category_limits_bloc.dart';

class CategoryLimitsPage extends StatefulWidget {
  const CategoryLimitsPage({super.key});

  @override
  State<CategoryLimitsPage> createState() => _CategoryLimitsPageState();
}

class _CategoryLimitsPageState extends State<CategoryLimitsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryLimitsBloc>().add(LoadCategoryLimitsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  Color _parseColor(String hexString) {
    hexString = hexString.replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }
    return Color(int.parse(hexString, radix: 16));
  }



  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryLimitsBloc, CategoryLimitsState>(
      listener: (context, state) {
        if (state is CategoryLimitsActionSuccess) {
          AppAlerts.showSuccess(context, state.message);
        } else if (state is CategoryLimitsActionError) {
          AppAlerts.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Category Limits",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Set monthly spending limits for your categories. We'll track your expenses and help you stay on budget!",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  return TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<CategoryLimitsBloc>().add(SearchCategoryLimitsEvent(query: query));
                    },
                    decoration: InputDecoration(
                      hintText: "Search categories...",
                      hintStyle: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textGrey),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.iconGrey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<CategoryLimitsBloc>().add(const SearchCategoryLimitsEvent(query: ''));
                                // Optional: unfocus keyboard
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<CategoryLimitsBloc, CategoryLimitsState>(
                buildWhen: (previous, current) => current is CategoryLimitsLoading || current is CategoryLimitsLoaded || current is CategoryLimitsError,
                builder: (context, state) {
                  if (state is CategoryLimitsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLimitsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.outfit(color: AppColors.errorRed, fontSize: 16),
                      ),
                    );
                  } else if (state is CategoryLimitsLoaded) {
                    final searchQuery = state.searchQuery ?? '';
                    final categories = state.limits.where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
                    categories.sort((a, b) {
                      final aHasLimit = a.limitAmount != null;
                      final bHasLimit = b.limitAmount != null;
                      if (aHasLimit && !bHasLimit) return -1;
                      if (!aHasLimit && bHasLimit) return 1;
                      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                    });
                    final expandedCategoryId = state.expandedCategoryId;
                    
                    if (categories.isEmpty) {
                      return Center(
                        child: Text(
                          "No categories found.",
                          style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 16),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final color = _parseColor(category.color);
                        final iconData = IconUtils.getIconFromString(category.icon);
                        final isExpanded = category.id == expandedCategoryId;
                        
                        return _ExpandableCategoryTile(
                          category: category,
                          color: color,
                          iconData: iconData,
                          isExpanded: isExpanded,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableCategoryTile extends StatefulWidget {
  final dynamic category;
  final Color color;
  final IconData iconData;
  final bool isExpanded;

  const _ExpandableCategoryTile({
    required this.category,
    required this.color,
    required this.iconData,
    required this.isExpanded,
  });

  @override
  State<_ExpandableCategoryTile> createState() => _ExpandableCategoryTileState();
}

class _ExpandableCategoryTileState extends State<_ExpandableCategoryTile> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.category.limitAmount != null ? widget.category.limitAmount.toString() : '',
    );
  }

  @override
  void didUpdateWidget(_ExpandableCategoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.limitAmount != widget.category.limitAmount) {
      _controller.text = widget.category.limitAmount != null ? widget.category.limitAmount.toString() : '';
    }
    if (!oldWidget.isExpanded && widget.isExpanded) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    } else if (oldWidget.isExpanded && !widget.isExpanded) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final limitAmount = widget.category.limitAmount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.isExpanded ? AppColors.primary : Colors.grey.shade200, width: widget.isExpanded ? 1.5 : 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.read<CategoryLimitsBloc>().add(ToggleCategoryLimitEvent(categoryId: widget.category.id)),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.iconData, color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        if (limitAmount != null)
                          Text(
                            "Limit: ₹${limitAmount.toStringAsFixed(2)}/mo",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          )
                        else
                          Text(
                            "No limit set",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.iconGrey,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: widget.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            sizeCurve: Curves.easeInOutCubic,
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          final amount = double.tryParse(value);
                          if (amount != null && amount > 0) {
                            context.read<CategoryLimitsBloc>().add(SetCategoryLimitEvent(categoryId: widget.category.id, limitAmount: amount));
                            context.read<CategoryLimitsBloc>().add(ToggleCategoryLimitEvent(categoryId: widget.category.id));
                            _focusNode.unfocus();
                          } else {
                            AppAlerts.showError(context, 'Enter a valid amount');
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: "₹ ",
                          labelText: "Monthly Limit",
                          labelStyle: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade200)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.primary)
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundLightGrey,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (limitAmount != null) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<CategoryLimitsBloc>().add(DeleteCategoryLimitEvent(categoryId: widget.category.id));
                                  context.read<CategoryLimitsBloc>().add(ToggleCategoryLimitEvent(categoryId: widget.category.id));
                                  _focusNode.unfocus();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  "Remove",
                                  style: GoogleFonts.outfit(color: AppColors.errorRed, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final amount = double.tryParse(_controller.text);
                                if (amount != null && amount > 0) {
                                  context.read<CategoryLimitsBloc>().add(SetCategoryLimitEvent(categoryId: widget.category.id, limitAmount: amount));
                                  context.read<CategoryLimitsBloc>().add(ToggleCategoryLimitEvent(categoryId: widget.category.id));
                                  _focusNode.unfocus();
                                } else {
                                  AppAlerts.showError(context, 'Enter a valid amount');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                "Save Limit",
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
