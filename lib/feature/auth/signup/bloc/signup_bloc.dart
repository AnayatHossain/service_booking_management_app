import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services/shared_preferences_helper.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(const SignUpState()) {
    on<SignUpPasswordVisibilityToggled>(_onTogglePasswordVisibility);
    on<SignUpSubmitted>(_onSubmitted);
  }

  void _onTogglePasswordVisibility(
      SignUpPasswordVisibilityToggled event, Emitter<SignUpState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onSubmitted(
      SignUpSubmitted event, Emitter<SignUpState> emit) async {
    final name = event.name.trim();
    final email = event.email.trim();
    final phone = event.phone.trim();
    final password = event.password.trim();

    if (name.isEmpty) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Please enter your full name.',
      ));
      return;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Please enter a valid email address.',
      ));
      return;
    }

    if (password.length < 6) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Password must be at least 6 characters.',
      ));
      return;
    }

    emit(state.copyWith(status: SignUpStatus.loading, errorMessage: null));

    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.register,
        apiType: ApiType.post,
        apiBody: ApiBody.json({
          'name': name,
          'email': email,
          'phone': phone.isNotEmpty ? phone : null,
          'password': password,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        final resData = response.data;
        if (resData is Map && resData['success'] == true && resData['data'] != null) {
          final data = resData['data'];
          final token = data['access_token'];
          final user = data['user'];

          await SharedPreferencesHelper.saveUserData(
            token: token ?? '',
            userId: user['id'] ?? '',
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            phone: user['phone'],
            avatarUrl: user['avatar_url'],
          );

          emit(state.copyWith(status: SignUpStatus.success));
        } else {
          final msg = (resData is Map && resData['message'] != null)
              ? resData['message']
              : 'Registration failed. Please check information.';
          emit(state.copyWith(status: SignUpStatus.failure, errorMessage: msg));
        }
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Registration failed. (Code: ${response.statusCode})';
        emit(state.copyWith(status: SignUpStatus.failure, errorMessage: msg));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Connection error: $e',
      ));
    }
  }
}
