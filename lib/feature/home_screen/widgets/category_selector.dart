import 'package:flutter/material.dart';
import '../../../../core/const/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
    super.key,
  });

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('all')) return Icons.grid_view_rounded;
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('repair') || lower.contains('appliance')) return Icons.build_circle_rounded;
    if (lower.contains('salon') || lower.contains('beauty') || lower.contains('hair')) return Icons.content_cut_rounded;
    if (lower.contains('paint')) return Icons.format_paint_rounded;
    if (lower.contains('electric')) return Icons.electric_bolt_rounded;
    return Icons.handyman_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.toLowerCase() == selectedCategory.toLowerCase();

          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : AppColors.strokeColor,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(cat),
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
