import 'dart:convert';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_model.dart';
import 'auth_remote_datasource.dart';

class AuthRepository {
  final _datasource = AuthRemoteDatasource();

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    // call API
    final response = await _datasource.login(
      phone: phone,
      password: password,
    );

    // save token and user to secure storage
    await SecureStorage.saveToken(response.token);
    await SecureStorage.saveUser(jsonEncode(response.user.toJson()));

    return response.user;
  }

  Future<UserModel> register({
    required Map<String, dynamic> data,
  }) async {
    final response = await _datasource.register(data: data);
    await SecureStorage.saveToken(response.token);
    await SecureStorage.saveUser(jsonEncode(response.user.toJson()));
    return response.user;
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
  }

  // reads saved user from storage — used on app startup
  // to check if user is already logged in
  Future<UserModel?> getSavedUser() async {
    final userJson = await SecureStorage.getUser();
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }
}