import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String name;
  final String? phone;
  final String? avatarUrl;
  final String? organizationName;

  const ProfileUpdateRequested({
    required this.name,
    this.phone,
    this.avatarUrl,
    this.organizationName,
  });

  @override
  List<Object?> get props => [name, phone, avatarUrl, organizationName];
}

class ProfilePasswordChangeRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfilePasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ProfileDeleteAccountRequested extends ProfileEvent {
  const ProfileDeleteAccountRequested();
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}
