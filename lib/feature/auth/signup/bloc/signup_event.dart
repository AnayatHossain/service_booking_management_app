import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpPasswordVisibilityToggled extends SignUpEvent {
  const SignUpPasswordVisibilityToggled();
}

class SignUpSubmitted extends SignUpEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const SignUpSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}
