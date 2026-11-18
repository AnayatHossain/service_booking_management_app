import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/feature/auth/login/screen/login_screen.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../profile/widgets/change_password_dialog.dart';
import '../../profile/widgets/profile_menu_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context, ProfileBloc bloc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFECDD3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppSvgIcons.logout,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Color(0xFFE11D48), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sign Out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Are you sure you want to sign out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                backgroundColor: const Color(0xFFF8FAFC),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                bloc.add(const ProfileLogoutRequested());
                              },
                              child: const Text(
                                'Sign Out',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, ProfileBloc bloc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFECDD3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppSvgIcons.delete,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Color(0xFFDC2626), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Delete Account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Permanently erase your account and all data?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                backgroundColor: const Color(0xFFF8FAFC),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                bloc.add(const ProfileDeleteAccountRequested());
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.isLoggedOut || state.isAccountDeleted) {
            Get.offAll(() => const LoginScreen());
            if (state.isAccountDeleted) {
              Get.snackbar(
                'Account Deleted',
                'Your account has been permanently removed.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
            }
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
              centerTitle: true,
              leading: IconButton(
                icon: SvgPicture.asset(
                  AppSvgIcons.backArrow,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Header Card (Overflow Handled & Using edit_image SVG)
                  _buildSettingsHeaderCard(context, state, bloc),
                  const SizedBox(height: 24),

                  const Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // 1. Edit Personal Details (Short subtitle)
                  ProfileMenuItem(
                    svgAsset: AppSvgIcons.userFilled,
                    title: 'Edit Personal Details',
                    subtitle: 'Name & contact details',
                    onTap: () async {
                      final updated = await Get.to(() => EditProfileScreen(
                            initialName: state.name,
                            initialPhone: state.phone ?? '',
                            initialAvatarUrl: state.avatarUrl ?? '',
                            initialOrganizationName: state.organizationName ?? '',
                            userRole: state.role,
                          ));
                      if (updated == true) {
                        bloc.add(const ProfileLoadRequested());
                      }
                    },
                  ),

                  // 2. Change Password (Short subtitle)
                  ProfileMenuItem(
                    svgAsset: AppSvgIcons.lockFilled,
                    title: 'Change Password',
                    subtitle: 'Update account password',
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

                  const SizedBox(height: 16),

                  // 3. Delete Account (Short subtitle)
                  ProfileMenuItem(
                    svgAsset: AppSvgIcons.delete,
                    title: 'Delete Account',
                    subtitle: 'Permanently erase account',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () => _showDeleteAccountDialog(context, bloc),
                  ),

                  // 4. Logout Action (Short subtitle)
                  ProfileMenuItem(
                    svgAsset: AppSvgIcons.logout,
                    title: 'Sign Out',
                    subtitle: 'End current session',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () => _showLogoutDialog(context, bloc),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsHeaderCard(BuildContext context, ProfileState state, ProfileBloc bloc) {
    final displayName = state.name.isNotEmpty ? state.name : 'Alex Johnson';
    final displayEmail = state.email.isNotEmpty ? state.email : 'testuser@example.com';
    final displayPhone = state.phone != null && state.phone!.isNotEmpty ? state.phone! : 'No phone specified';
    final hasAvatar = state.avatarUrl != null && state.avatarUrl!.isNotEmpty && state.avatarUrl!.startsWith('http');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: const Color(0xFF2563EB), width: 2),
            ),
            child: ClipOval(
              child: hasAvatar
                  ? CachedNetworkImage(
                      imageUrl: state.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _initials(displayName),
                      errorWidget: (_, __, ___) => _initials(displayName),
                    )
                  : _initials(displayName),
            ),
          ),
          const SizedBox(width: 14),

          // User Info with overflow protection
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Edit Profile Action Button using edit_image SVG
          InkWell(
            onTap: () async {
              final updated = await Get.to(() => EditProfileScreen(
                    initialName: state.name,
                    initialPhone: state.phone ?? '',
                    initialAvatarUrl: state.avatarUrl ?? '',
                    initialOrganizationName: state.organizationName ?? '',
                    userRole: state.role,
                  ));
              if (updated == true) {
                bloc.add(const ProfileLoadRequested());
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppSvgIcons.editImage,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials(String name) {
    String initials = 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0][0].toUpperCase();
    }
    return Container(
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
