import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../auth/login/screen/login_screen.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/change_password_dialog.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, ProfileBloc bloc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(const ProfileLogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.isLoggedOut) {
            Get.offAll(() => const LoginScreen());
          } else if (state.message != null) {
            Get.snackbar(
              'Success',
              state.message!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
          } else if (state.errorMessage != null) {
            Get.snackbar(
              'Error',
              state.errorMessage!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<ProfileBloc>();

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
                  ProfileHeader(
                    name: state.name.isNotEmpty ? state.name : 'Alex Johnson',
                    email: state.email.isNotEmpty ? state.email : 'testuser@example.com',
                    phone: state.phone ?? 'Not specified',
                    avatarUrl: state.avatarUrl,
                    onEditTap: () async {
                      final updated = await Get.to(() => EditProfileScreen(
                            initialName: state.name,
                            initialPhone: state.phone ?? '',
                            initialAvatarUrl: state.avatarUrl ?? '',
                          ));
                      if (updated == true) {
                        bloc.add(const ProfileLoadRequested());
                      }
                    },
                  ),
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
                    onTap: () async {
                      final updated = await Get.to(() => EditProfileScreen(
                            initialName: state.name,
                            initialPhone: state.phone ?? '',
                            initialAvatarUrl: state.avatarUrl ?? '',
                          ));
                      if (updated == true) {
                        bloc.add(const ProfileLoadRequested());
                      }
                    },
                  ),

                  ProfileMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your account security password',
                    onTap: () {
                      showChangePasswordDialog(
                        context,
                        onSubmit: (curr, next) {
                          bloc.add(ProfilePasswordChangeRequested(
                            currentPassword: curr,
                            newPassword: next,
                          ));
                        },
                      );
                    },
                  ),

                  ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQs, contact team, and booking assistance',
                    onTap: () {
                      Get.snackbar(
                        'Support',
                        'Contact our 24/7 support at support@servicebooking.com',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.shade100,
                      );
                    },
                  ),

                  ProfileMenuItem(
                    icon: Icons.policy_outlined,
                    title: 'Terms & Privacy Policy',
                    subtitle: 'Review privacy practices and terms of use',
                    onTap: () {
                      Get.snackbar(
                        'Privacy',
                        'We take your data security seriously.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.shade100,
                      );
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
                    onTap: () => _showLogoutDialog(context, bloc),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      'Service Booking App v1.0.0 (FastAPI + MongoDB + BLoC)',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
