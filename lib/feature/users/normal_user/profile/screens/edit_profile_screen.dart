import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/global_widegts/app_button.dart';
import 'package:service_booking_management_app/core/global_widegts/custom_text_field.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialAvatarUrl;

  const EditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialPhone = '',
    this.initialAvatarUrl = '',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryColor,
                            child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),

                  const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'e.g. +1 555 123 4567',
                    prefixIcon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  const Text('Email Address (Registered)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: state.email.isNotEmpty ? state.email : 'testuser@example.com',
                    prefixIcon: Icons.email_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 36),

                  AppButton(
                    text: 'Save Changes',
                    buttonColor: AppColors.primaryColor,
                    isLoading: state.isUpdating,
                    onTap: state.isUpdating
                        ? null
                        : () {
                            context.read<ProfileBloc>().add(ProfileUpdateRequested(
                                  name: _nameController.text,
                                  phone: _phoneController.text,
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
}
