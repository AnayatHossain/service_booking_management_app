import 'package:flutter/material.dart';
import '../../../../core/const/app_colors.dart';

enum ServiceSortOption { defaultSort, priceLowHigh, priceHighLow, ratingHigh }

class FilterDialog extends StatefulWidget {
  final List<String> categories;
  final String currentCategory;
  final ServiceSortOption currentSort;
  final Function(String selectedCategory, ServiceSortOption sortOption) onApply;
  final VoidCallback onReset;

  const FilterDialog({
    super.key,
    required this.categories,
    required this.currentCategory,
    required this.currentSort,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _selectedCat;
  late ServiceSortOption _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedCat = widget.currentCategory;
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppColors.primaryColor, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Filter Services',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.strokeColor, height: 20),

              // Categories Section
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories.map((cat) {
                  final isSelected = cat.toLowerCase() == _selectedCat.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    backgroundColor: AppColors.bgColor,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryColor : AppColors.strokeColor,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCat = cat;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Sort Section
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _sortChip('Recommended', ServiceSortOption.defaultSort),
                  _sortChip('Highest Rated ⭐', ServiceSortOption.ratingHigh),
                  _sortChip('Price: Low to High', ServiceSortOption.priceLowHigh),
                  _sortChip('Price: High to Low', ServiceSortOption.priceHighLow),
                ],
              ),
              const SizedBox(height: 26),

              // Action Buttons: Reset & Apply
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.strokeColor, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        widget.onReset();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Reset All',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        widget.onApply(_selectedCat, _selectedSort);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, ServiceSortOption option) {
    final isSelected = _selectedSort == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: AppColors.bgColor,
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : AppColors.strokeColor,
      ),
      onSelected: (_) {
        setState(() {
          _selectedSort = option;
        });
      },
    );
  }
}
