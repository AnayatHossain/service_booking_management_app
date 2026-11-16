import 'package:flutter/material.dart';
import '../../../../core/const/app_colors.dart';

class TimeSlotSelector extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final String selectedSlot;
  final Function(String slot, bool isAvailable) onSlotSelected;
  final bool isLoading;

  const TimeSlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No time slots available for this date.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final item = slots[index];
        final String slot = item['slot'];
        final bool isAvailable = item['is_available'] == true;
        final bool isSelected = (slot == selectedSlot && isAvailable);

        Color bgColor;
        Color textColor;
        Border? border;

        if (!isAvailable) {
          bgColor = Colors.grey.shade100;
          textColor = Colors.grey.shade400;
          border = Border.all(color: Colors.grey.shade300);
        } else if (isSelected) {
          bgColor = AppColors.primaryColor;
          textColor = Colors.white;
          border = Border.all(color: AppColors.primaryColor);
        } else {
          bgColor = Colors.white;
          textColor = AppColors.textPrimary;
          border = Border.all(color: AppColors.strokeColor);
        }

        return GestureDetector(
          onTap: () => onSlotSelected(slot, isAvailable),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: border,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                    decoration: !isAvailable ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!isAvailable)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
