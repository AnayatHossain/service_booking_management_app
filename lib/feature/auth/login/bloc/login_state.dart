import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool rememberMe;
  final String? errorMessage;
  final String? userName;
  final String? userRole;

  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.errorMessage,
    this.userName,
    this.userRole,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? rememberMe,
    String? errorMessage,
    String? userName,
    String? userRole,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        isPasswordVisible,
        rememberMe,
        errorMessage,
        userName,
        userRole,
      ];
}
