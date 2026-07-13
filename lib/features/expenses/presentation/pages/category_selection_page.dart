import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';

class CategorySelectionPage extends StatefulWidget {
  final List<ExpenseCategoryEntity> categories;
  final ExpenseCategoryEntity? selectedCategory;

  const CategorySelectionPage({
    super.key,
    required this.categories,
    this.selectedCategory,
  });

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ExpenseCategoryEntity> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = widget.categories;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredCategories = widget.categories.where((c) => c.name.toLowerCase().contains(lowerQuery)).toList();
    });
  }

  IconData _getIconFromString(String iconName) {
    final lower = iconName.toLowerCase();
    switch (lower) {
      case "restaurant":
      case "food":
      case "dining":
        return Icons.restaurant_rounded;
      case "flight":
      case "travel":
        return Icons.flight_rounded;
      case "shopping_bag":
      case "shopping":
        return Icons.shopping_bag_rounded;
      case "hotel":
      case "lodging":
        return Icons.hotel_rounded;
      case "directions_car":
      case "car":
      case "taxi":
        return Icons.directions_car_rounded;
      case "movie":
      case "entertainment":
        return Icons.movie_rounded;
      case "local_gas_station":
      case "gas":
      case "fuel":
        return Icons.local_gas_station_rounded;
      case "local_grocery_store":
      case "grocery":
      case "groceries":
        return Icons.local_grocery_store_rounded;
      case "home":
      case "housing":
      case "rent":
        return Icons.home_rounded;
      case "receipt_long":
      case "utilities":
      case "bills":
        return Icons.receipt_long_rounded;
      case "wifi":
      case "internet":
        return Icons.wifi_rounded;
      case "medical_services":
      case "health":
      case "medical":
        return Icons.medical_services_rounded;
      case "pets":
      case "pet":
        return Icons.pets_rounded;
      case "sports_esports":
      case "games":
      case "gaming":
        return Icons.sports_esports_rounded;
      case "card_giftcard":
      case "gift":
      case "gifts":
        return Icons.card_giftcard_rounded;
      case "school":
      case "education":
        return Icons.school_rounded;
      case "local_bar":
      case "drinks":
      case "drink":
        return Icons.local_bar_rounded;
      case "local_cafe":
      case "coffee":
      case "cafe":
        return Icons.local_cafe_rounded;
      case "train":
      case "transit":
      case "transport":
        return Icons.train_rounded;
      case "build":
      case "repairs":
      case "maintenance":
        return Icons.build_rounded;
      case "celebration":
      case "party":
      case "event":
        return Icons.celebration_rounded;
      case "menu_book":
      case "books":
      case "book":
        return Icons.menu_book_rounded;
      default:
        // Try to match based on substrings if exact match fails
        if (lower.contains('food') || lower.contains('eat')) return Icons.restaurant_rounded;
        if (lower.contains('shop')) return Icons.shopping_bag_rounded;
        if (lower.contains('health')) return Icons.medical_services_rounded;
        if (lower.contains('travel') || lower.contains('trip')) return Icons.flight_rounded;
        if (lower.contains('car') || lower.contains('auto')) return Icons.directions_car_rounded;
        if (lower.contains('game')) return Icons.sports_esports_rounded;
        if (lower.contains('music')) return Icons.music_note_rounded;
        if (lower.contains('bill') || lower.contains('fee')) return Icons.receipt_long_rounded;
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Category",
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textBlack),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.borderGrey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.textGrey.withValues(alpha: 0.7), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterCategories,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textBlack),
                      decoration: InputDecoration(
                        hintText: "Search categories...",
                        hintStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textGrey.withValues(alpha: 0.8)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _filterCategories('');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.textGrey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: AppColors.textBlack, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      "No categories found",
                      style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = widget.selectedCategory?.id == category.id;

                      Color categoryColor;
                      try {
                        categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
                      } catch (_) {
                        categoryColor = AppColors.primaryTeal;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryTeal : AppColors.borderGrey.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIconFromString(category.icon), color: categoryColor, size: 22),
                          ),
                          title: Text(
                            category.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          trailing: isSelected 
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal)
                              : const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onTap: () {
                            Navigator.pop(context, category);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
