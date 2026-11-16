import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../controller/signup_controller.dart';
import '../../login/widgets/auth_header.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                title: 'Create Account',
                subtitle: 'Sign up to discover and book professional services in seconds.',
                icon: Icons.person_add_alt_1_rounded,
              ),
              const SizedBox(height: 28),

              // Full Name
              CustomTextField(
                label: 'Full Name',
                hintText: 'e.g. John Doe',
                prefixIconData: Icons.person_outline,
                controller: controller.nameController,
              ),
              const SizedBox(height: 16),

              // Email Address
              CustomTextField(
                label: 'Email Address',
                hintText: 'e.g. john@example.com',
                prefixIconData: Icons.email_outlined,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone Number
              CustomTextField(
                label: 'Phone Number (Optional)',
                hintText: 'e.g. +1 555 123 4567',
                prefixIconData: Icons.phone_outlined,
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Password
              Obx(() => CustomTextField(
                label: 'Password',
                hintText: 'At least 6 characters',
                prefixIconData: Icons.lock_outline,
                controller: controller.passwordController,
                isPassword: true,
                isPasswordVisible: controller.isPasswordVisible.value,
                onTogglePassword: controller.togglePasswordVisibility,
              )),
              const SizedBox(height: 32),

              // Sign Up Button
              Obx(() => AppButton(
                text: 'Create Account',
                buttonColor: AppColors.primaryColor,
                isLoading: controller.isLoading.value,
                onTap: controller.isLoading.value ? null : controller.onSignUp,
              )),
              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
