import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';
import '../../navigation/screen/main_navigation_screen.dart';

class AppointmentBookingController extends GetxController {
  final ServiceModel service;
  AppointmentBookingController({required this.service});

  var selectedDate = Rx<DateTime>(DateTime.now().add(const Duration(days: 1)));
  var selectedTimeSlot = ''.obs;
  var availableSlots = <Map<String, dynamic>>[].obs;
  final notesController = TextEditingController();

  var isLoadingSlots = false.obs;
  var isBooking = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSlotAvailability();
  }

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate.value);
  String get displayDate => DateFormat('EEE, d MMMM yyyy').format(selectedDate.value);

  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    selectedTimeSlot.value = '';
    fetchSlotAvailability();
  }

  void onSlotSelected(String slot, bool isAvailable) {
    if (!isAvailable) {
      Get.snackbar('Slot Unavailable', 'This time slot is already booked. Please choose another.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }
    selectedTimeSlot.value = slot;
  }

  Future<void> fetchSlotAvailability() async {
    try {
      isLoadingSlots.value = true;
      errorMessage.value = '';

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.checkAvailability,
        apiType: ApiType.get,
        apiParams: ApiParams.simple({
          'service_id': service.id,
          'date': formattedDate,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data['data'] != null) {
        final List<dynamic> slots = response.data['data']['slots'] ?? [];
        availableSlots.value = slots.map((s) => {
          'slot': s['slot'].toString(),
          'is_available': s['is_available'] == true,
        }).toList();

        // Auto select first available slot
        final firstAvail = availableSlots.firstWhereOrNull((s) => s['is_available'] == true);
        if (firstAvail != null && selectedTimeSlot.value.isEmpty) {
          selectedTimeSlot.value = firstAvail['slot'];
        }
      } else {
        // Fallback to service's defined time slots
        availableSlots.value = service.timeSlots.map((s) => {
          'slot': s,
          'is_available': true,
        }).toList();
      }
    } catch (e) {
      availableSlots.value = service.timeSlots.map((s) => {
        'slot': s,
        'is_available': true,
      }).toList();
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> submitBooking() async {
    if (selectedTimeSlot.value.isEmpty) {
      Get.snackbar('Selection Required', 'Please select an available time slot.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    try {
      isBooking.value = true;
      final token = await Urls.bearerToken;

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.appointments,
        apiType: ApiType.post,
        apiHeaders: {
          'Authorization': token,
        },
        apiBody: ApiBody.json({
          'service_id': service.id,
          'date': formattedDate,
          'time_slot': selectedTimeSlot.value,
          if (notesController.text.trim().isNotEmpty)
            'customer_notes': notesController.text.trim(),
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data['data'] != null) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                SizedBox(width: 10),
                Text('Booking Confirmed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: ${service.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Date: $displayDate'),
                Text('Time: ${selectedTimeSlot.value}'),
                Text('Total: \$${service.price.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                const Text('Your appointment has been successfully scheduled.', style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.offAll(() => const MainNavigationScreen(initialIndex: 1));
                },
                child: const Text('View My Bookings', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        final msg = response.data?['message'] ?? 'Failed to complete booking.';
        Get.snackbar('Booking Error', msg,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error while booking: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isBooking.value = false;
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
