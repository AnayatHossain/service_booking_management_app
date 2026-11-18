import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/global_widegts/app_button.dart';
import 'package:service_booking_management_app/core/global_widegts/custom_text_field.dart';
import 'package:service_booking_management_app/core/services/shared_preferences_helper.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialAvatarUrl;
  final String initialOrganizationName;
  final String userRole;

  const EditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialPhone = '',
    this.initialAvatarUrl = '',
    this.initialOrganizationName = '',
    this.userRole = 'Customer',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _orgController;
  late String _currentAvatarUrl;
  bool _isProvider = false;

  static const String _defaultDemoAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _orgController = TextEditingController(text: widget.initialOrganizationName);
    _currentAvatarUrl = widget.initialAvatarUrl.isNotEmpty
        ? widget.initialAvatarUrl
        : _defaultDemoAvatar;

    _initProviderData();
  }

  Future<void> _initProviderData() async {
    final role = await SharedPreferencesHelper.getUserRole();
    final isProv = widget.userRole.toLowerCase().contains('provider') ||
        widget.userRole.toLowerCase().contains('service') ||
        (role != null && (role.toLowerCase().contains('provider') || role.toLowerCase().contains('service')));
    if (mounted) {
      setState(() => _isProvider = isProv);
    }
    if (_orgController.text.trim().isEmpty) {
      final savedOrg = await SharedPreferencesHelper.getInstitutionName();
      if (mounted && savedOrg != null && savedOrg.isNotEmpty && _orgController.text.trim().isEmpty) {
        setState(() => _orgController.text = savedOrg);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _showImageStorageWarningDialog() {
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
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppSvgIcons.addImage,
                        width: 26,
                        height: 26,
                        colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Profile Photo',
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
                      'Preview your profile with a high-resolution online avatar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _currentAvatarUrl = _defaultDemoAvatar;
                          });
                          Get.snackbar(
                            'Avatar Updated',
                            'Profile photo selected successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blue.shade100,
                            colorText: Colors.blue.shade900,
                          );
                        },
                        child: const Text(
                          'Select Avatar',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
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
          if (state.message != null && !state.isUpdating) {
            Get.back(result: true);
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
          final displayInitial = _nameController.text.isNotEmpty
              ? _nameController.text[0].toUpperCase()
              : 'U';

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
                onPressed: () => Get.back(),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Avatar with add_image / edit photo SVG button
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(color: const Color(0xFF2563EB), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.18),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _currentAvatarUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _currentAvatarUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => _buildInitialAvatar(displayInitial),
                                    errorWidget: (_, __, ___) => _buildInitialAvatar(displayInitial),
                                  )
                                : _buildInitialAvatar(displayInitial),
                          ),
                        ),
                        // Photo Change Badge with add_image SVG
                        Positioned(
                          bottom: 0,
                          right: -2,
                          child: GestureDetector(
                            onTap: _showImageStorageWarningDialog,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                AppSvgIcons.addImage,
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. Full Name (Filled SVG icon)
                  const Text(
                    'Full Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter your name',
                    prefixIcon: AppSvgIcons.userFilled,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 18),

                  // 3. Organization Name (For Service Providers)
                  if (_isProvider) ...[
                    const Text(
                      'Business / Organization Name',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'e.g. Apex Home Solutions',
                      prefixIcon: AppSvgIcons.enterprise,
                      controller: _orgController,
                    ),
                    const SizedBox(height: 18),
                  ],

                  // 4. Phone Number (Filled SVG icon)
                  const Text(
                    'Phone Number',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'e.g. +1 (555) 234-5678',
                    prefixIcon: AppSvgIcons.telephone,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),

                  // 5. Email Address (Registered, Read-Only, Filled SVG icon)
                  const Text(
                    'Email Address (Registered)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: state.email.isNotEmpty ? state.email : 'testuser@example.com',
                    prefixIcon: AppSvgIcons.mailFilled,
                    enabled: false,
                  ),
                  const SizedBox(height: 36),

                  // 6. Save Changes Button
                  AppButton(
                    text: 'Save Changes',
                    buttonColor: const Color(0xFF2563EB),
                    isLoading: state.isUpdating,
                    onTap: state.isUpdating
                        ? null
                        : () {
                            context.read<ProfileBloc>().add(ProfileUpdateRequested(
                                  name: _nameController.text,
                                  phone: _phoneController.text,
                                  avatarUrl: _currentAvatarUrl,
                                  organizationName: _isProvider ? _orgController.text : null,
                                ));
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}
