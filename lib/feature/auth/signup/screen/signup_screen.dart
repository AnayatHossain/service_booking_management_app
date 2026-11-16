import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../../../navigation/screen/main_navigation_screen.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(),
      child: BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == SignUpStatus.success) {
            Get.snackbar(
              'Account Created',
              'Welcome! Your account has been registered.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
            Get.offAll(() => const MainNavigationScreen());
          } else if (state.status == SignUpStatus.failure && state.errorMessage != null) {
            Get.snackbar(
              'Registration Error',
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join today to book appointments and consult with our AI Assistant.',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // Full Name
                      const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'e.g. Alex Johnson',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'e.g. alex@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      const Text('Phone Number (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '+1 (555) 000-0000',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'At least 6 characters',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !state.isPasswordVisible,
                        suffixIcon: state.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        onSuffixTap: () {
                          context.read<SignUpBloc>().add(const SignUpPasswordVisibilityToggled());
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      AppButton(
                        text: 'Create Account',
                        buttonColor: AppColors.primaryColor,
                        isLoading: state.status == SignUpStatus.loading,
                        onTap: state.status == SignUpStatus.loading
                            ? null
                            : () {
                                context.read<SignUpBloc>().add(SignUpSubmitted(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      phone: _phoneController.text,
                                      password: _passwordController.text,
                                    ));
                              },
                      ),
                      const SizedBox(height: 20),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Text('Sign In', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
