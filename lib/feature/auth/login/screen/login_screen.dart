import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_logo.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/feature/users/normal_user/navigation/screen/main_navigation_screen.dart';
import '../../../users/service_provider/navigation/screens/provider_navigation_screen.dart';
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
              'Welcome Back',
              'Successfully logged in as ${state.userName ?? 'User'}!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE8F5E9),
              colorText: const Color(0xFF1B5E20),
              icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
              margin: const EdgeInsets.all(16),
              borderRadius: 14,
            );

            if (state.userRole == 'provider') {
              Get.offAll(() => const ProviderNavigationScreen());
            } else {
              Get.offAll(() => const MainNavigationScreen());
            }
          } else if (state.status == LoginStatus.failure && state.errorMessage != null) {
            Get.snackbar(
              'Sign In Failed',
              state.errorMessage!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFFFEBEE),
              colorText: const Color(0xFFB71C1C),
              icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
              margin: const EdgeInsets.all(16),
              borderRadius: 14,
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginBloc>();

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. App Branded Emblem
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            AppLogo.appLogo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Headings
                      const Center(
                        child: Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Sign in to access your appointments and services.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. Email Input Field
                      const Text(
                        'Email Address',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: _emailController,
                        hintText: 'name@example.com',
                        prefixIcon: AppSvgIcons.mailOutline,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => bloc.add(LoginEmailChanged(val)),
                      ),
                      const SizedBox(height: 18),

                      // 4. Password Input Field
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: AppSvgIcons.lockOutline,
                        obscureText: !state.isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            state.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => bloc.add(const LoginPasswordVisibilityToggled()),
                        ),
                        onChanged: (val) => bloc.add(LoginPasswordChanged(val)),
                      ),
                      const SizedBox(height: 12),

                      // 5. Remember Me Checkbox
                      GestureDetector(
                        onTap: () => bloc.add(const LoginRememberMeToggled()),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: state.rememberMe,
                                onChanged: (_) => bloc.add(const LoginRememberMeToggled()),
                                activeColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Sign In Primary Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: state.status == LoginStatus.loading
                                ? null
                                : () {
                                    bloc.add(LoginSubmitted(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ));
                                  },
                            child: Center(
                              child: state.status == LoginStatus.loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 7. Quick Demo Login Chips
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF59E0B)),
                                SizedBox(width: 6),
                                Text(
                                  'Quick Demo Access',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () => bloc.add(const LoginPrefillDemo()),
                                    icon: const Icon(Icons.person_rounded, size: 16, color: AppColors.primaryColor),
                                    label: const Text(
                                      'Customer',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: const Color(0xFF7B1FA2).withOpacity(0.3)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () => bloc.add(const LoginPrefillProviderDemo()),
                                    icon: const Icon(Icons.business_center_rounded, size: 16, color: Color(0xFF7B1FA2)),
                                    label: const Text(
                                      'Provider',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 8. Sign Up Navigation Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Get.to(() => const SignUpScreen()),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required dynamic prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    Widget? prefixWidget;
    if (prefixIcon is String) {
      prefixWidget = Padding(
        padding: const EdgeInsets.all(13),
        child: SvgPicture.asset(
          prefixIcon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
        ),
      );
    } else if (prefixIcon is IconData) {
      prefixWidget = Icon(prefixIcon, color: AppColors.primaryColor, size: 20);
    } else if (prefixIcon is Widget) {
      prefixWidget = prefixIcon;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: prefixWidget,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
