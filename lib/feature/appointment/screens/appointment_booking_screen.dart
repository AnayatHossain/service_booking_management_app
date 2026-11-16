import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../../home_screen/model/service_model.dart';
import '../controllers/appointment_booking_controller.dart';
import '../widgets/date_picker_timeline.dart';
import '../widgets/time_slot_selector.dart';

class AppointmentBookingScreen extends StatelessWidget {
  final ServiceModel service;

  const AppointmentBookingScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentBookingController(service: service), tag: service.id);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.strokeColor),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.handyman, color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.category} • ${service.durationMinutes} mins',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Date
            const Text(
              '1. Select Appointment Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Obx(() => DatePickerTimeline(
              selectedDate: controller.selectedDate.value,
              onDateSelected: controller.onDateSelected,
            )),
            const SizedBox(height: 24),

            // Select Time Slot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. Select Time Slot',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Booked', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => TimeSlotSelector(
              slots: controller.availableSlots,
              selectedSlot: controller.selectedTimeSlot.value,
              isLoading: controller.isLoadingSlots.value,
              onSlotSelected: controller.onSlotSelected,
            )),
            const SizedBox(height: 24),

            // Customer Notes
            const Text(
              '3. Special Instructions / Notes (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'e.g. Ring bell, gate code #1234, special requests...',
              maxLines: 3,
              controller: controller.notesController,
            ),
            const SizedBox(height: 32),

            // Confirm Booking CTA
            Obx(() => AppButton(
              text: 'Confirm & Book Appointment',
              buttonColor: AppColors.primaryColor,
              isLoading: controller.isBooking.value,
              onTap: controller.isBooking.value ? null : controller.submitBooking,
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
