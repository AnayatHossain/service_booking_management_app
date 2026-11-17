import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/global_widegts/app_button.dart';
import 'package:service_booking_management_app/core/global_widegts/custom_text_field.dart';
import '../../home_screen/model/service_model.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import '../widgets/date_picker_timeline.dart';
import '../widgets/time_slot_selector.dart';
import '../../my_bookings/screens/my_bookings_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final ServiceModel service;

  const AppointmentBookingScreen({super.key, required this.service});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> confirmation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Your appointment for ${widget.service.name} has been placed successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'View My Bookings',
              buttonColor: AppColors.primaryColor,
              onTap: () {
                Navigator.pop(ctx);
                Get.off(() => const MyBookingsScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentBloc(service: widget.service),
      child: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state.slotWarning != null) {
            Get.snackbar(
              'Slot Unavailable',
              state.slotWarning!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.amber.shade100,
              colorText: Colors.amber.shade900,
            );
          }
          if (state.status == AppointmentStatus.success && state.bookingConfirmation != null) {
            _showSuccessDialog(context, state.bookingConfirmation!);
          } else if (state.status == AppointmentStatus.failure && state.errorMessage != null) {
            Get.snackbar(
              'Booking Failed',
              state.errorMessage!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
            );
          }
        },
        builder: (context, state) {
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
                            widget.service.imageUrl,
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
                                widget.service.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.service.category} • ${widget.service.durationMinutes} mins',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${widget.service.price.toStringAsFixed(2)}',
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
                  DatePickerTimeline(
                    selectedDate: state.selectedDate,
                    onDateSelected: (date) {
                      context.read<AppointmentBloc>().add(AppointmentDateChanged(date));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Select Time Slot
                  const Text(
                    '2. Select Time Slot',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TimeSlotSelector(
                    slots: state.slots.map((s) => {'slot': s.slot, 'is_available': s.isAvailable}).toList(),
                    selectedSlot: state.selectedTimeSlot ?? '',
                    isLoading: state.isLoadingSlots,
                    onSlotSelected: (slot, isAvail) {
                      context.read<AppointmentBloc>().add(AppointmentSlotSelected(slot, isAvail));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Customer Notes
                  const Text(
                    '3. Special Instructions (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _notesController,
                    hintText: 'e.g. Please bring extra wire / Ring the bell twice',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  AppButton(
                    text: 'Confirm & Book Appointment',
                    buttonColor: AppColors.primaryColor,
                    isLoading: state.isBooking,
                    onTap: state.isBooking
                        ? null
                        : () {
                            context.read<AppointmentBloc>().add(AppointmentSubmitRequested(notes: _notesController.text));
                          },
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
