import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/auth_model.dart';

class AuthRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'phone': phone, 'password': password},
      );
      // response.data['data'] is the actual payload
      // { user: {...}, token: '...' }
      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AuthResponse> register({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: data,
      );
      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}