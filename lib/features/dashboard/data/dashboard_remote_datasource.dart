import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/dashboard_model.dart';

class DashboardRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  Future<AnmStatsModel> getAnmStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.anmDashboard);
      return AnmStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AdminStatsModel> getAdminStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminDashboard);
      return AdminStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}