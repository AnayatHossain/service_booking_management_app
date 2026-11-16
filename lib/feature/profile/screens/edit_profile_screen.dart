import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryLight,
                    child: Obx(() => Text(
                      controller.nameController.text.isNotEmpty ? controller.nameController.text[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryColor,
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            CustomTextField(
              label: 'Full Name',
              hintText: 'Enter your name',
              prefixIconData: Icons.person_outline,
              controller: controller.nameController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Phone Number',
              hintText: 'e.g. +1 555 123 4567',
              prefixIconData: Icons.phone_outlined,
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email (read only)
            Obx(() => CustomTextField(
              label: 'Email Address (Registered)',
              hintText: controller.email.value,
              prefixIconData: Icons.email_outlined,
              readOnly: true,
            )),
            const SizedBox(height: 36),

            Obx(() => AppButton(
              text: 'Save Changes',
              buttonColor: AppColors.primaryColor,
              isLoading: controller.isSaving.value,
              onTap: controller.isSaving.value ? null : () async {
                await controller.updateProfile();
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }
}
