import 'package:dio/dio.dart';
import '../error/app_exception.dart';

// converts DioException into our AppException with a clean message
// every datasource calls this when catching errors
AppException handleDioError(DioException e) {
  if (e.response != null) {
    // server responded with an error
    final data = e.response?.data;
    final message = data?['message'] ?? 'Something went wrong';
    return AppException(
      message: message,
      statusCode: e.response?.statusCode,
    );
  } else if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return AppException(message: 'Connection timeout. Check your internet.');
  } else if (e.type == DioExceptionType.connectionError) {
    return AppException(message: 'No internet connection');
  }
  return AppException(message: 'Something went wrong');
}