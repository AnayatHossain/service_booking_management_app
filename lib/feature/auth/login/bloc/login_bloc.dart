import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/core/services/shared_preferences_helper.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginInitRequested>(_onInit);
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onTogglePasswordVisibility);
    on<LoginRememberMeToggled>(_onToggleRememberMe);
    on<LoginPrefillDemo>(_onPrefillDemo);
    on<LoginPrefillProviderDemo>(_onPrefillProviderDemo);
    on<LoginSubmitted>(_onSubmitted);

    add(const LoginInitRequested());
  }

  Future<void> _onInit(LoginInitRequested event, Emitter<LoginState> emit) async {
    final remember = await SharedPreferencesHelper.getRememberMe();
    String savedEmail = '';
    if (remember) {
      savedEmail = await SharedPreferencesHelper.getUserEmail() ?? '';
    }
    emit(state.copyWith(
      rememberMe: remember,
      email: savedEmail.isNotEmpty ? savedEmail : state.email,
    ));
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void _onTogglePasswordVisibility(
      LoginPasswordVisibilityToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onToggleRememberMe(
      LoginRememberMeToggled event, Emitter<LoginState> emit) async {
    final newRemember = !state.rememberMe;
    await SharedPreferencesHelper.setRememberMe(newRemember);
    emit(state.copyWith(rememberMe: newRemember));
  }

  void _onPrefillDemo(LoginPrefillDemo event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: 'testuser@example.com',
      password: 'password123',
    ));
  }

  void _onPrefillProviderDemo(LoginPrefillProviderDemo event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: 'provider@example.com',
      password: 'password123',
    ));
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    final email = event.email.trim();
    final password = event.password.trim();

    if (email.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter your email address.',
      ));
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter a valid email address.',
      ));
      return;
    }

    if (password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter your password.',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.login,
        apiType: ApiType.post,
        apiBody: ApiBody.json({
          'email': email,
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
          final role = (user['role'] ?? 'customer').toString();
          final instName = user['institution_name']?.toString();

          await SharedPreferencesHelper.saveUserData(
            token: token ?? '',
            userId: user['id'] ?? '',
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            phone: user['phone'],
            avatarUrl: user['avatar_url'],
            role: role,
            institutionName: instName,
          );

          emit(state.copyWith(
            status: LoginStatus.success,
            userName: user['name'] ?? 'User',
            userRole: role,
          ));
        } else {
          final msg = (resData is Map && resData['message'] != null)
              ? resData['message']
              : 'Login failed. Please verify credentials.';
          emit(state.copyWith(status: LoginStatus.failure, errorMessage: msg));
        }
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Login failed. (Code: ${response.statusCode})';
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: msg));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Connection error: $e',
      ));
    }
  }
}
