import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _accessTokenKey = 'token';
  static const String _isLoginKey = 'isLogin';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _emailKey = 'email';
  static const String _phoneKey = 'phone';
  static const String _avatarUrlKey = 'avatarUrl';
  static const String _roleKey = 'role';
  static const String _institutionNameKey = 'institutionName';
  static const String _rememberMeKey = 'rememberMe';

  // Save full user session
  static Future<void> saveUserData({
    required String token,
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
    String? role,
    String? institutionName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_emailKey, email);
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (avatarUrl != null) await prefs.setString(_avatarUrlKey, avatarUrl);
    if (role != null) await prefs.setString(_roleKey, role);
    if (institutionName != null) await prefs.setString(_institutionNameKey, institutionName);
    await prefs.setBool(_isLoginKey, true);
  }

  // Getters
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<String?> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarUrlKey);
  }

  static Future<String?> getUserAvatar() async {
    return getAvatarUrl();
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<void> setUserAvatar(String? avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (avatarUrl != null) {
      await prefs.setString(_avatarUrlKey, avatarUrl);
    } else {
      await prefs.remove(_avatarUrlKey);
    }
  }

  static Future<void> updateProfileInfo({required String name, String? phone, String? avatarUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (avatarUrl != null) await prefs.setString(_avatarUrlKey, avatarUrl);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey) ?? 'customer';
  }

  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getInstitutionName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_institutionNameKey);
  }

  static Future<void> setInstitutionName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null && name.isNotEmpty) {
      await prefs.setString(_institutionNameKey, name);
    } else {
      await prefs.remove(_institutionNameKey);
    }
  }

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Clear session
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMeKey) ?? false;
    final email = prefs.getString(_emailKey);

    await prefs.clear();

    if (remember && email != null) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_emailKey, email);
    }
  }

  static Future<void> clearUserData() async {
    await clearUserSession();
  }
}
