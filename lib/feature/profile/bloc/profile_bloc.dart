import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services/shared_preferences_helper.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadProfile);
    on<ProfileUpdateRequested>(_onUpdateProfile);
    on<ProfilePasswordChangeRequested>(_onChangePassword);
    on<ProfileLogoutRequested>(_onLogout);

    add(const ProfileLoadRequested());
  }

  Future<void> _onLoadProfile(
      ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    final name = await SharedPreferencesHelper.getUserName() ?? 'Alex Johnson';
    final email = await SharedPreferencesHelper.getUserEmail() ?? 'testuser@example.com';
    final phone = await SharedPreferencesHelper.getUserPhone();
    final avatar = await SharedPreferencesHelper.getUserAvatar();

    emit(state.copyWith(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatar,
    ));

    // Also fetch fresh from API
    try {
      final token = await Urls.rawToken;
      if (token == null || token.isEmpty) return;

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.profile,
        apiType: ApiType.get,
        apiAuthorization: ApiAuthorization.bearer(token),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final u = response.data['data'];
        final updatedName = u['name'] ?? name;
        final updatedEmail = u['email'] ?? email;
        final updatedPhone = u['phone'] ?? phone;
        final updatedAvatar = u['avatar_url'] ?? avatar;
        final role = u['role'] ?? 'Customer';
        final createdAt = u['created_at'];
        final total = u['total_bookings'] ?? 0;
        final active = u['active_bookings'] ?? 0;
        final completed = u['completed_bookings'] ?? 0;
        final cancelled = u['cancelled_bookings'] ?? 0;

        final token = await SharedPreferencesHelper.getAccessToken() ?? '';
        final userId = await SharedPreferencesHelper.getUserId() ?? '';
        await SharedPreferencesHelper.saveUserData(
          token: token,
          userId: userId,
          name: updatedName,
          email: updatedEmail,
          phone: updatedPhone,
          avatarUrl: updatedAvatar,
        );

        emit(state.copyWith(
          status: ProfileStatus.success,
          name: updatedName,
          email: updatedEmail,
          phone: updatedPhone,
          avatarUrl: updatedAvatar,
          role: role,
          createdAt: createdAt,
          totalBookings: total,
          activeBookings: active,
          completedBookings: completed,
          cancelledBookings: cancelled,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onUpdateProfile(
      ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isUpdating: true, message: null, errorMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.profile,
        apiType: ApiType.put,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        apiBody: ApiBody.json({
          'name': event.name.trim(),
          if (event.phone != null) 'phone': event.phone!.trim(),
          if (event.avatarUrl != null) 'avatar_url': event.avatarUrl!.trim(),
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final u = response.data['data'];
        final token = await SharedPreferencesHelper.getAccessToken() ?? '';
        final userId = await SharedPreferencesHelper.getUserId() ?? '';

        await SharedPreferencesHelper.saveUserData(
          token: token,
          userId: userId,
          name: u['name'] ?? event.name,
          email: u['email'] ?? state.email,
          phone: u['phone'],
          avatarUrl: u['avatar_url'],
        );

        emit(state.copyWith(
          isUpdating: false,
          name: u['name'] ?? event.name,
          phone: u['phone'] ?? event.phone,
          avatarUrl: u['avatar_url'] ?? event.avatarUrl,
          message: 'Profile updated successfully.',
        ));
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Profile update failed.';
        emit(state.copyWith(
          isUpdating: false,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: 'Update failed: $e',
      ));
    }
  }

  Future<void> _onChangePassword(
      ProfilePasswordChangeRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isChangingPassword: true, message: null, errorMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.changePassword,
        apiType: ApiType.post,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        apiBody: ApiBody.json({
          'current_password': event.currentPassword,
          'new_password': event.newPassword,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        emit(state.copyWith(
          isChangingPassword: false,
          message: 'Password changed successfully.',
        ));
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Failed to change password.';
        emit(state.copyWith(
          isChangingPassword: false,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isChangingPassword: false,
        errorMessage: 'Password change error: $e',
      ));
    }
  }

  Future<void> _onLogout(
      ProfileLogoutRequested event, Emitter<ProfileState> emit) async {
    try {
      final token = await Urls.rawToken;
      if (token != null && token.isNotEmpty) {
        final api = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.logout,
          apiType: ApiType.post,
          apiAuthorization: ApiAuthorization.bearer(token),
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        await api.call();
      }
    } catch (_) {}

    await SharedPreferencesHelper.clearUserData();
    emit(state.copyWith(isLoggedOut: true));
  }
}
