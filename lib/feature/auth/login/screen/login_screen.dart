import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/app_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../../../navigation/screen/main_navigation_screen.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../signup/screen/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.email.isNotEmpty && _emailController.text != state.email) {
            _emailController.text = state.email;
          }
          if (state.password.isNotEmpty && _passwordController.text != state.password) {
            _passwordController.text = state.password;
          }

          if (state.status == LoginStatus.success) {
            Get.snackbar(
              'Success',
              'Welcome back, ${state.userName}!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
            Get.offAll(() => const MainNavigationScreen());
          } else if (state.status == LoginStatus.failure && state.errorMessage != null) {
            Get.snackbar(
              'Login Error',
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
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title & Subtitle
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to manage your appointments and explore quality services.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'e.g. john@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !state.isPasswordVisible,
                        suffixIcon: state.isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixTap: () {
                          context.read<LoginBloc>().add(const LoginPasswordVisibilityToggled());
                        },
                      ),
                      const SizedBox(height: 14),

                      // Remember Me
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: state.rememberMe,
                              activeColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (_) {
                                context.read<LoginBloc>().add(const LoginRememberMeToggled());
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Remember me', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Sign In Button
                      AppButton(
                        text: 'Sign In',
                        buttonColor: AppColors.primaryColor,
                        isLoading: state.status == LoginStatus.loading,
                        onTap: state.status == LoginStatus.loading
                            ? null
                            : () {
                                context.read<LoginBloc>().add(LoginSubmitted(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ));
                              },
                      ),
                      const SizedBox(height: 20),

                      // Demo account shortcut
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            context.read<LoginBloc>().add(const LoginPrefillDemo());
                          },
                          icon: const Icon(Icons.flash_on, size: 16, color: AppColors.accentColor),
                          label: const Text(
                            'Fill Demo Credentials (testuser@example.com)',
                            style: TextStyle(color: AppColors.accentColor, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Get.to(() => const SignUpScreen()),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
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
        },
      ),
    );
  }
}
