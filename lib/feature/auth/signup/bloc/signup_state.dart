import 'package:equatable/equatable.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final String role; // 'customer' or 'provider'
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? errorMessage;
  final String? userRole;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.role = 'customer',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.errorMessage,
    this.userRole,
  });

  SignUpState copyWith({
    SignUpStatus? status,
    String? role,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? errorMessage,
    String? userRole,
  }) {
    return SignUpState(
      status: status ?? this.status,
      role: role ?? this.role,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      errorMessage: errorMessage,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [
        status,
        role,
        isPasswordVisible,
        isConfirmPasswordVisible,
        errorMessage,
        userRole,
      ];
}
