import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/shared_preferences_helper.dart';

class Urls {
  // Automatically selects 10.0.2.2 for Android emulator and 127.0.0.1 for desktop/web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api';
  }

  // Auth endpoints (no leading slash to prevent double-slash in flutter_api_craft)
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String me = 'auth/me';
  static const String logout = 'auth/logout';

  // User endpoints
  static const String profile = 'users/profile';
  static const String changePassword = 'users/change-password';

  // Services endpoints
  static const String services = 'services';
  static const String featuredServices = 'services/featured';
  static const String categories = 'services/categories';
  static String serviceDetails(String id) => 'services/$id';

  // Appointments endpoints
  static const String appointments = 'appointments';
  static const String myAppointments = 'appointments/my';
  static const String checkAvailability = 'appointments/availability';
  static String appointmentDetails(String id) => 'appointments/$id';
  static String cancelAppointment(String id) => 'appointments/$id/cancel';

  // AI Assistant endpoints
  static const String aiChat = 'ai/chat';
  static const String aiPrompts = 'ai/prompts';

  // Token helper
  static Future<String?> get rawToken async {
    return await SharedPreferencesHelper.getAccessToken();
  }

  static Future<String> get bearerToken async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token != null && token.isNotEmpty) {
      return token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    return '';
  }
}
