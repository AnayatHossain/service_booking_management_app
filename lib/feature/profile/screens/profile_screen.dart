import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/change_password_dialog.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header Card
            Obx(() => ProfileHeader(
              name: controller.nameController.text,
              email: controller.email.value,
              phone: controller.phoneController.text,
              avatarUrl: controller.avatarUrl.value,
              onEditTap: () => Get.to(() => const EditProfileScreen()),
            )),
            const SizedBox(height: 24),

            const Text(
              'Account Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            ProfileMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Edit Personal Details',
              subtitle: 'Update your display name and contact phone',
              onTap: () => Get.to(() => const EditProfileScreen()),
            ),

            ProfileMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              subtitle: 'Update your account security password',
              onTap: () => showChangePasswordDialog(context, controller),
            ),

            ProfileMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs, contact team, and booking assistance',
              onTap: () {
                Get.snackbar('Support', 'Contact our 24/7 support at support@servicebooking.com',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue.shade100);
              },
            ),

            ProfileMenuItem(
              icon: Icons.policy_outlined,
              title: 'Terms & Privacy Policy',
              subtitle: 'Review privacy practices and terms of use',
              onTap: () {
                Get.snackbar('Privacy', 'We take your data security seriously.',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue.shade100);
              },
            ),
            const SizedBox(height: 16),

            // Logout Action
            ProfileMenuItem(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: 'Log out of your current session',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _showLogoutDialog(context, controller),
            ),
            const SizedBox(height: 30),

            Center(
              child: Text(
                'Service Booking App v1.0.0 (FastAPI + MongoDB)',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
