import 'package:flutter/material.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;

  const SearchFilterBar({
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
    this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.strokeColor.withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Search services (cleaning, repair, salon...)',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
              onPressed: () {
                controller.clear();
                onChanged('');
                if (onClear != null) onClear!();
              },
            ),
          Container(
            height: 28,
            width: 1,
            color: AppColors.strokeColor,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
