import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../model/booking_model.dart';

class MyBookingsController extends GetxController {
  var allBookings = <BookingModel>[].obs;
  var selectedTab = 'All'.obs; // 'All', 'Upcoming', 'Completed', 'Cancelled'
  var isLoading = false.obs;
  var isCancelling = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  List<BookingModel> get filteredBookings {
    if (selectedTab.value == 'All') return allBookings;
    if (selectedTab.value == 'Upcoming') {
      return allBookings.where((b) => b.isPending || b.isConfirmed).toList();
    }
    if (selectedTab.value == 'Completed') {
      return allBookings.where((b) => b.isCompleted).toList();
    }
    if (selectedTab.value == 'Cancelled') {
      return allBookings.where((b) => b.isCancelled).toList();
    }
    return allBookings;
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await Urls.bearerToken;

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.myAppointments,
        apiType: ApiType.get,
        apiHeaders: {
          'Authorization': token,
        },
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data['data'] != null) {
        final List<dynamic> list = response.data['data'];
        allBookings.value = list.map((item) => BookingModel.fromJson(item)).toList();
      } else {
        errorMessage.value = response.data?['message'] ?? 'Failed to load bookings.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load bookings: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      isCancelling.value = true;
      final token = await Urls.bearerToken;

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.cancelAppointment(appointmentId),
        apiType: ApiType.patch,
        apiHeaders: {
          'Authorization': token,
        },
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        Get.snackbar('Cancelled', 'Your appointment has been cancelled.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
        await fetchBookings();
      } else {
        Get.snackbar('Error', response.data?['message'] ?? 'Failed to cancel appointment.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error cancelling: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isCancelling.value = false;
    }
  }
}
