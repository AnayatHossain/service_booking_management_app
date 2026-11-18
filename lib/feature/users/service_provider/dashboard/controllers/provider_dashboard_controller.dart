import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../notifications/screens/notification_screen.dart';
import '../../../normal_user/my_bookings/model/booking_model.dart';
import '../../provider_bookings/screens/provider_appointment_details_screen.dart';

class ProviderDashboardController {
  static void navigateToNotifications(BuildContext context, {VoidCallback? onBack}) {
    Get.to(() => const NotificationScreen(isProvider: true))?.then((_) {
      onBack?.call();
    });
  }

  static void navigateToBookingDetails(
    BuildContext context,
    BookingModel booking, {
    VoidCallback? onStatusChanged,
  }) {
    Get.to(() => ProviderAppointmentDetailsScreen(
          booking: booking,
          onStatusChanged: onStatusChanged,
        ));
  }
}
