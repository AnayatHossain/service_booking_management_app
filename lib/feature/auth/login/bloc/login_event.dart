import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;
  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

class LoginRememberMeToggled extends LoginEvent {
  const LoginRememberMeToggled();
}

class LoginPrefillDemo extends LoginEvent {
  const LoginPrefillDemo();
}

class LoginPrefillProviderDemo extends LoginEvent {
  const LoginPrefillProviderDemo();
}

class LoginInitRequested extends LoginEvent {
  const LoginInitRequested();
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
