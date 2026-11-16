import 'package:flutter/material.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';

class BookBottomBar extends StatelessWidget {
  final double price;
  final VoidCallback? onBookTap;
  final VoidCallback? onBookNow;

  const BookBottomBar({
    super.key,
    required this.price,
    this.onBookTap,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Price', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AppButton(
                text: 'Book Appointment',
                buttonColor: AppColors.primaryColor,
                onTap: onBookNow ?? onBookTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
