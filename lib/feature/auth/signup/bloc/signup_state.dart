import 'package:equatable/equatable.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final bool isPasswordVisible;
  final String? errorMessage;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.isPasswordVisible = false,
    this.errorMessage,
  });

  SignUpState copyWith({
    SignUpStatus? status,
    bool? isPasswordVisible,
    String? errorMessage,
  }) {
    return SignUpState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isPasswordVisible, errorMessage];
}
