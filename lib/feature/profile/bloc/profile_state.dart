import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isUpdating;
  final bool isChangingPassword;
  final bool isLoggedOut;
  final String? message;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.name = '',
    this.email = '',
    this.phone,
    this.avatarUrl,
    this.isUpdating = false,
    this.isChangingPassword = false,
    this.isLoggedOut = false,
    this.message,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isUpdating,
    bool? isChangingPassword,
    bool? isLoggedOut,
    String? message,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isUpdating: isUpdating ?? this.isUpdating,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        email,
        phone,
        avatarUrl,
        isUpdating,
        isChangingPassword,
        isLoggedOut,
        message,
        errorMessage,
      ];
}
