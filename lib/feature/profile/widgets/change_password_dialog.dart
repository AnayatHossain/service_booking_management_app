import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../controllers/profile_controller.dart';

void showChangePasswordDialog(BuildContext context, ProfileController controller) {
  final currentPw = TextEditingController();
  final newPw = TextEditingController();
  final confirmPw = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: AppColors.primaryColor, size: 24),
                  SizedBox(width: 10),
                  Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Current Password',
                isPassword: true,
                controller: currentPw,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'New Password',
                hintText: 'At least 6 characters',
                isPassword: true,
                controller: newPw,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Confirm New Password',
                isPassword: true,
                controller: confirmPw,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Update',
                      buttonColor: AppColors.primaryColor,
                      onTap: () {
                        if (currentPw.text.isEmpty || newPw.text.isEmpty) {
                          Get.snackbar('Validation', 'Please fill in all fields.',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
                          return;
                        }
                        if (newPw.text.length < 6) {
                          Get.snackbar('Validation', 'New password must be at least 6 characters.',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
                          return;
                        }
                        if (newPw.text != confirmPw.text) {
                          Get.snackbar('Validation', 'New passwords do not match.',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade100);
                          return;
                        }
                        controller.changePassword(
                          currentPassword: currentPw.text.trim(),
                          newPassword: newPw.text.trim(),
                        );
                      },
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
