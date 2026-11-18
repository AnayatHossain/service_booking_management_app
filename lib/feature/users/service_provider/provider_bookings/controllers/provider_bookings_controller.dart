import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../normal_user/my_bookings/model/booking_model.dart';
import '../screens/provider_appointment_details_screen.dart';
import '../widgets/provider_appointment_dialogs.dart';

class ProviderBookingsController {
  static void navigateToDetails(
    BuildContext context,
    BookingModel booking, {
    VoidCallback? onStatusChanged,
  }) {
    Get.to(() => ProviderAppointmentDetailsScreen(
          booking: booking,
          onStatusChanged: onStatusChanged,
        ));
  }

  static void showConfirmDialog(
    BuildContext context, {
    required BookingModel booking,
    required VoidCallback onConfirm,
  }) {
    ProviderAppointmentDialogs.showConfirmDialog(
      context,
      serviceName: booking.serviceName,
      serviceImage: booking.serviceImage,
      clientName: booking.userName,
      date: booking.date,
      timeSlot: booking.timeSlot,
      price: booking.servicePrice,
      onConfirm: onConfirm,
    );
  }

  static void showDeclineDialog(
    BuildContext context, {
    required BookingModel booking,
    required VoidCallback onDecline,
  }) {
    ProviderAppointmentDialogs.showDeclineDialog(
      context,
      serviceName: booking.serviceName,
      serviceImage: booking.serviceImage,
      clientName: booking.userName,
      date: booking.date,
      timeSlot: booking.timeSlot,
      price: booking.servicePrice,
      onDecline: onDecline,
    );
  }

  static void showCompleteDialog(
    BuildContext context, {
    required BookingModel booking,
    required VoidCallback onComplete,
  }) {
    ProviderAppointmentDialogs.showCompleteDialog(
      context,
      serviceName: booking.serviceName,
      serviceImage: booking.serviceImage,
      clientName: booking.userName,
      date: booking.date,
      timeSlot: booking.timeSlot,
      price: booking.servicePrice,
      onComplete: onComplete,
    );
  }
}
