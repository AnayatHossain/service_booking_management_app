import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRoleChanged extends SignUpEvent {
  final String role;
  const SignUpRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class SignUpPasswordVisibilityToggled extends SignUpEvent {
  const SignUpPasswordVisibilityToggled();
}

class SignUpConfirmPasswordVisibilityToggled extends SignUpEvent {
  const SignUpConfirmPasswordVisibilityToggled();
}

class SignUpSubmitted extends SignUpEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String role;
  final String? institutionName;

  const SignUpSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.institutionName,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        confirmPassword,
        role,
        institutionName,
      ];
}
