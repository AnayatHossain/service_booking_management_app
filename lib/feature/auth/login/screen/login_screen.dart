import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../controller/login_controller.dart';
import '../widgets/auth_header.dart';
import '../../signup/screen/signup_screen.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LogInController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Welcome Back!',
                  subtitle: 'Sign in to manage your appointments and explore quality services.',
                ),
                const SizedBox(height: 32),

                // Email field
                CustomTextField(
                  label: 'Email Address',
                  hintText: 'e.g. alex@example.com',
                  prefixIconData: Icons.email_outlined,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                Obx(() => CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIconData: Icons.lock_outline,
                  controller: controller.passwordController,
                  isPassword: true,
                  isPasswordVisible: controller.isPasswordVisible.value,
                  onTogglePassword: controller.togglePasswordVisibility,
                )),
                const SizedBox(height: 12),

                // Remember Me
                Row(
                  children: [
                    Obx(() => SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.rememberMe.value,
                        activeColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (_) => controller.toggleRememberMe(),
                      ),
                    )),
                    const SizedBox(width: 8),
                    const Text('Remember me', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 28),

                // Sign In Button
                Obx(() => AppButton(
                  text: 'Sign In',
                  buttonColor: AppColors.primaryColor,
                  isLoading: controller.isLoading.value,
                  onTap: controller.isLoading.value ? null : controller.onSignIn,
                )),
                const SizedBox(height: 20),

                // Demo account shortcut for reviewer convenience
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      controller.emailController.text = 'testuser@example.com';
                      controller.passwordController.text = 'password123';
                    },
                    icon: const Icon(Icons.flash_on, size: 16, color: AppColors.accentColor),
                    label: const Text(
                      'Fill Demo Credentials (testuser@example.com)',
                      style: TextStyle(color: AppColors.accentColor, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Get.to(() => const SignUpScreen()),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
