import 'package:flutter/material.dart';
import '../../home_screen/model/service_model.dart';
import '../screens/appointment_booking_screen.dart';

class AppointmentScreen extends StatelessWidget {
  final ServiceModel service;
  const AppointmentScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return AppointmentBookingScreen(service: service);
  }
}
