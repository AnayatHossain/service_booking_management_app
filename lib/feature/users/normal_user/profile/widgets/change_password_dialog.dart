import 'package:flutter/material.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/global_widegts/app_button.dart';
import 'package:service_booking_management_app/core/global_widegts/custom_text_field.dart';

void showChangePasswordDialog(
  BuildContext context, {
  required Function(String currentPw, String newPw) onSubmit,
}) {
  final currentPw = TextEditingController();
  final newPw = TextEditingController();
  final confirmPw = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
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
              const Text('Current Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              CustomTextField(
                hintText: 'Enter current password',
                obscureText: true,
                controller: currentPw,
              ),
              const SizedBox(height: 12),
              const Text('New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              CustomTextField(
                hintText: 'At least 6 characters',
                obscureText: true,
                controller: newPw,
              ),
              const SizedBox(height: 12),
              const Text('Confirm New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              CustomTextField(
                hintText: 'Re-enter new password',
                obscureText: true,
                controller: confirmPw,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Save',
                      buttonColor: AppColors.primaryColor,
                      onTap: () {
                        if (currentPw.text.isEmpty || newPw.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all password fields.')),
                          );
                          return;
                        }
                        if (newPw.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New password must be at least 6 characters.')),
                          );
                          return;
                        }
                        if (newPw.text != confirmPw.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match.')),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        onSubmit(currentPw.text, newPw.text);
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
