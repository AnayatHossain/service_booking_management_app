import 'package:flutter/material.dart';
import '../../../../core/const/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String currentQuery;

  const SearchFilterBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    required this.currentQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search services, e.g. Cleaning, AC, Spa...',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 22),
          suffixIcon: currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
