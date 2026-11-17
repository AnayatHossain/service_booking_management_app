import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/feature/users/normal_user/navigation/screen/main_navigation_screen.dart';
import '../../../users/service_provider/navigation/screens/provider_navigation_screen.dart';
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
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _currentRole = 'customer';
  String _passwordInput = '';
  String _confirmPasswordInput = '';

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password strength calculation: 0 to 4
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  Color _getStrengthColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF10B981);
      default:
        return Colors.grey.shade300;
    }
  }

  String _getStrengthLabel(int score) {
    switch (score) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Enter password';
    }
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
              state.userRole == 'provider'
                  ? 'Welcome to Service Booking Provider Portal!'
                  : 'Welcome to Service Booking!',
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
          } else if (state.status == SignUpStatus.failure && state.errorMessage != null) {
            Get.snackbar(
              'Registration Failed',
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
          final bloc = context.read<SignUpBloc>();
          final strengthScore = _calculatePasswordStrength(_passwordInput);
          final passwordsMatch = _passwordInput.isNotEmpty &&
              _confirmPasswordInput.isNotEmpty &&
              _passwordInput == _confirmPasswordInput;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Role Toggle Tabs (Customer vs Service Provider)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildRoleTab(
                              title: 'Customer',
                              subtitle: 'Book services',
                              icon: Icons.person_rounded,
                              isSelected: _currentRole == 'customer',
                              onTap: () {
                                setState(() => _currentRole = 'customer');
                                bloc.add(const SignUpRoleChanged('customer'));
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildRoleTab(
                              title: 'Provider',
                              subtitle: 'Offer services',
                              icon: Icons.business_center_rounded,
                              isSelected: _currentRole == 'provider',
                              onTap: () {
                                setState(() => _currentRole = 'provider');
                                bloc.add(const SignUpRoleChanged('provider'));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Full Name
                    const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _nameController,
                      hintText: _currentRole == 'provider' ? 'e.g. David Miller' : 'e.g. Alex Johnson',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // 3. Institution / Company Name (Only for Service Provider)
                    if (_currentRole == 'provider') ...[
                      const Text(
                        'Business / Company Name',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: _institutionController,
                        hintText: 'e.g. Apex Home Solutions Ltd',
                        prefixIcon: Icons.storefront_outlined,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Email Address
                    const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'name@example.com',
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // 5. Phone Number
                    const Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _phoneController,
                      hintText: '+1 (555) 000-0000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // 6. Password
                    const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _passwordController,
                      hintText: 'Create a strong password (min 6 chars)',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !state.isPasswordVisible,
                      onChanged: (val) {
                        setState(() => _passwordInput = val);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          state.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => bloc.add(const SignUpPasswordVisibilityToggled()),
                      ),
                    ),

                    // Real-time Live Password Strength Indicator
                    if (_passwordInput.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Row(
                                children: List.generate(4, (index) {
                                  final isActive = index < strengthScore;
                                  return Expanded(
                                    child: Container(
                                      height: 4,
                                      margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                                      color: isActive ? _getStrengthColor(strengthScore) : Colors.grey.shade200,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getStrengthLabel(strengthScore),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStrengthColor(strengthScore),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildCriteriaChip('8+ chars', _passwordInput.length >= 8),
                          _buildCriteriaChip('Number', RegExp(r'[0-9]').hasMatch(_passwordInput)),
                          _buildCriteriaChip('Case (Aa)', RegExp(r'[A-Z]').hasMatch(_passwordInput) && RegExp(r'[a-z]').hasMatch(_passwordInput)),
                          _buildCriteriaChip('Symbol', RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordInput)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 7. Confirm Password
                    const Text('Confirm Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      hintText: 'Re-enter your password',
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: !state.isConfirmPasswordVisible,
                      onChanged: (val) {
                        setState(() => _confirmPasswordInput = val);
                      },
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_confirmPasswordInput.isNotEmpty)
                            Icon(
                              passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: passwordsMatch ? const Color(0xFF10B981) : AppColors.error,
                              size: 18,
                            ),
                          IconButton(
                            icon: Icon(
                              state.isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => bloc.add(const SignUpConfirmPasswordVisibilityToggled()),
                          ),
                        ],
                      ),
                    ),

                    if (_confirmPasswordInput.isNotEmpty && !passwordsMatch) ...[
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.error),
                          SizedBox(width: 4),
                          Text(
                            'Passwords do not match',
                            style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 28),

                    // 8. Submit Button
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
                          onTap: state.status == SignUpStatus.loading
                              ? null
                              : () {
                                  bloc.add(SignUpSubmitted(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    phone: _phoneController.text,
                                    password: _passwordController.text,
                                    confirmPassword: _confirmPasswordController.text,
                                    role: _currentRole,
                                    institutionName: _currentRole == 'provider' ? _institutionController.text : null,
                                  ));
                                },
                          child: Center(
                            child: state.status == SignUpStatus.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentRole == 'provider' ? 'Register as Provider' : 'Create Customer Account',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 9. Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleTab({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primaryColor : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppColors.primaryColor : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaChip(String label, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 13,
          color: isMet ? const Color(0xFF10B981) : Colors.grey.shade400,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isMet ? const Color(0xFF10B981) : Colors.grey.shade600,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
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
          prefixIcon: Icon(prefixIcon, color: AppColors.primaryColor, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
