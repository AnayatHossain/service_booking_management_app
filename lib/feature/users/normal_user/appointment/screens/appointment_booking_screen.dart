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
import '../../navigation/screen/main_navigation_screen.dart';

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
    final bookingDate = confirmation['date'] ?? confirmation['appointment_date'] ?? '';
    final bookingTime = confirmation['time_slot'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        elevation: 20,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Layered Glowing Success Badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFFDCFCE7), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDCFCE7),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Color(0xFF16A34A),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Centered Headline
              const Text(
                'Booking Confirmed! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // 3. Subtitle
              const Text(
                'Your appointment has been successfully scheduled with the service provider.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              // 4. Booking Summary Capsule
              Container(
                margin: const EdgeInsets.only(top: 18, bottom: 22),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.service.imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.design_services_outlined, size: 20, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            bookingDate.isNotEmpty && bookingTime.isNotEmpty
                                ? '$bookingDate • $bookingTime'
                                : widget.service.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${widget.service.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Navigate to Bookings tab on BottomNavigationBar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.offAll(() => const MainNavigationScreen(initialIndex: 1));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'View My Bookings',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              centerTitle: true,
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
