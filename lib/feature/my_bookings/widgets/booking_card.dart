import 'package:flutter/material.dart';
import '../../../../core/const/app_colors.dart';
import '../model/booking_model.dart';
import 'booking_status_chip.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancelTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancelTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.serviceCategory,
                  style: const TextStyle(color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              BookingStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 12),

          // Service Title
          Text(
            booking.serviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Date & Time Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Text(
                  booking.date,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.access_time_rounded, size: 15, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Text(
                  booking.timeSlot,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Optional notes
          if (booking.customerNotes != null && booking.customerNotes!.isNotEmpty) ...[
            Text(
              'Notes: ${booking.customerNotes}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
          ],

          const Divider(height: 1, color: AppColors.strokeColor),
          const SizedBox(height: 10),

          // Footer: Price & Cancel Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    '\$${booking.servicePrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (booking.canBeCancelled && (onCancelTap != null || onCancel != null))
                OutlinedButton(
                  onPressed: onCancelTap ?? onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: const Text('Cancel Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
