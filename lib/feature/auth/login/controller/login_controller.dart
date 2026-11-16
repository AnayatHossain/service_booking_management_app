import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services/shared_preferences_helper.dart';
import '../../../navigation/screen/main_navigation_screen.dart';

class LogInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var rememberMe = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedCredentials();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleRememberMe() async {
    rememberMe.toggle();
    await SharedPreferencesHelper.setRememberMe(rememberMe.value);
  }

  Future<void> _loadRememberedCredentials() async {
    rememberMe.value = await SharedPreferencesHelper.getRememberMe();
    if (rememberMe.value) {
      emailController.text = await SharedPreferencesHelper.getUserEmail() ?? '';
    }
  }

  Future<void> onSignIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Validation', 'Please enter your email address.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Validation', 'Please enter a valid email address.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    if (password.isEmpty) {
      Get.snackbar('Validation', 'Please enter your password.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.login,
        apiType: ApiType.post,
        apiBody: ApiBody.json({
          'email': email,
          'password': password,
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

          Get.snackbar('Success', 'Welcome back, ${user['name']}!',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);

          Get.offAll(() => const MainNavigationScreen());
        } else {
          errorMessage.value = resData['message'] ?? 'Login failed. Please verify credentials.';
          Get.snackbar('Error', errorMessage.value,
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
        }
      } else {
        errorMessage.value = response.data?['message'] ?? 'Login failed. Status: ${response.statusCode}';
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
