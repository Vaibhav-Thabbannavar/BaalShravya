import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  static Dio? _instance;

  // singleton — only one Dio instance throughout the app
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // add auth interceptor
    dio.interceptors.add(_AuthInterceptor());

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // read token from secure storage
    final token = await SecureStorage.getToken();

    // if token exists, attach it to every request header
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // if 401 — token expired or invalid
    // clear storage so user gets sent to login
    if (err.response?.statusCode == 401) {
      SecureStorage.clearAll();
    }
    handler.next(err);
  }
}