import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services/shared_preferences_helper.dart';
import '../../../navigation/screen/main_navigation_screen.dart';

class SignUpController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> onSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter your full name.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Validation', 'Please provide a valid email address.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.register,
        apiType: ApiType.post,
        apiBody: ApiBody.json({
          'name': name,
          'email': email,
          'password': password,
          if (phone.isNotEmpty) 'phone': phone,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        final resData = response.data;
        if (resData['success'] == true && resData['data'] != null) {
          final data = resData['data'];
          final token = data['access_token'];
          final user = data['user'];

          await SharedPreferencesHelper.saveUserData(
            token: token ?? '',
            userId: user['id'] ?? '',
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            phone: user['phone'],
            avatarUrl: user['avatar_url'],
          );

          Get.snackbar('Account Created', 'Welcome to Service Booking, ${user['name']}!',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);

          Get.offAll(() => const MainNavigationScreen());
        } else {
          errorMessage.value = resData['message'] ?? 'Registration failed.';
          Get.snackbar('Error', errorMessage.value,
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
        }
      } else {
        errorMessage.value = response.data?['message'] ?? 'Registration failed. Status: ${response.statusCode}';
        Get.snackbar('Error', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      errorMessage.value = 'Connection error: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
