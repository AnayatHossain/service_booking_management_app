import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services/shared_preferences_helper.dart';
import '../../auth/login/screen/login_screen.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  var email = ''.obs;
  var avatarUrl = ''.obs;

  var isLoading = false.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalProfile();
    fetchRemoteProfile();
  }

  Future<void> loadLocalProfile() async {
    nameController.text = await SharedPreferencesHelper.getUserName() ?? '';
    phoneController.text = await SharedPreferencesHelper.getUserPhone() ?? '';
    email.value = await SharedPreferencesHelper.getUserEmail() ?? '';
    avatarUrl.value = await SharedPreferencesHelper.getAvatarUrl() ?? '';
  }

  Future<void> fetchRemoteProfile() async {
    try {
      isLoading.value = true;
      final token = await Urls.bearerToken;

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.profile,
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
        final data = response.data['data'];
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        email.value = data['email'] ?? '';
        avatarUrl.value = data['avatar_url'] ?? '';

        await SharedPreferencesHelper.updateProfileInfo(
          name: nameController.text,
          phone: phoneController.text,
          avatarUrl: avatarUrl.value,
        );
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Name cannot be empty.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    try {
      isSaving.value = true;
      final token = await Urls.bearerToken;

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.profile,
        apiType: ApiType.put,
        apiHeaders: {
          'Authorization': token,
        },
        apiBody: ApiBody.json({
          'name': name,
          'phone': phoneController.text.trim(),
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        await SharedPreferencesHelper.updateProfileInfo(
          name: name,
          phone: phoneController.text.trim(),
        );
        Get.snackbar('Success', 'Profile updated successfully!',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
      } else {
        Get.snackbar('Error', response.data?['message'] ?? 'Failed to update profile.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.changePassword,
        apiType: ApiType.post,
        apiHeaders: {
          'Authorization': token,
        },
        apiBody: ApiBody.json({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        Get.back(); // close dialog
        Get.snackbar('Success', 'Password changed successfully.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
      } else {
        Get.snackbar('Error', response.data?['message'] ?? 'Failed to change password.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    }
  }

  Future<void> logout() async {
    try {
      final token = await Urls.bearerToken;
      FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.logout,
        apiType: ApiType.post,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
      ).call();
    } catch (_) {}

    await SharedPreferencesHelper.clearUserSession();
    Get.offAll(() => const LogInScreen());
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
