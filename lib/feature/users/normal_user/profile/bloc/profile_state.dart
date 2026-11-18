import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? organizationName;
  final int totalBookings;
  final int activeBookings;
  final int completedBookings;
  final int cancelledBookings;
  final String role;
  final String? createdAt;
  final bool isUpdating;
  final bool isChangingPassword;
  final bool isDeletingAccount;
  final bool isAccountDeleted;
  final bool isLoggedOut;
  final String? message;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.name = '',
    this.email = '',
    this.phone,
    this.avatarUrl,
    this.organizationName,
    this.totalBookings = 0,
    this.activeBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.role = 'Customer',
    this.createdAt,
    this.isUpdating = false,
    this.isChangingPassword = false,
    this.isDeletingAccount = false,
    this.isAccountDeleted = false,
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
    String? organizationName,
    int? totalBookings,
    int? activeBookings,
    int? completedBookings,
    int? cancelledBookings,
    String? role,
    String? createdAt,
    bool? isUpdating,
    bool? isChangingPassword,
    bool? isDeletingAccount,
    bool? isAccountDeleted,
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
      organizationName: organizationName ?? this.organizationName,
      totalBookings: totalBookings ?? this.totalBookings,
      activeBookings: activeBookings ?? this.activeBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isUpdating: isUpdating ?? this.isUpdating,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      isAccountDeleted: isAccountDeleted ?? this.isAccountDeleted,
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
        organizationName,
        totalBookings,
        activeBookings,
        completedBookings,
        cancelledBookings,
        role,
        createdAt,
        isUpdating,
        isChangingPassword,
        isDeletingAccount,
        isAccountDeleted,
        isLoggedOut,
        message,
        errorMessage,
      ];
}
