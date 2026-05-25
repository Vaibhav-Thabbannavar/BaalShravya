import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// stores JWT token securely on device
// on Android uses Android Keystore
// on iOS uses Keychain
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // save token after login
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // read token — used by Dio interceptor to attach to every request
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // clear token on logout
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // save user data as JSON string
  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  // clear everything on logout
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}