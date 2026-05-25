// custom exception class for all API errors
// instead of raw DioException we throw this with a clean message
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}