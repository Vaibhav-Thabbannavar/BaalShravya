import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/geography_model.dart';

class GeographyRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  Future<List<DistrictModel>> getDistricts() async {
    try {
      final response = await _dio.get(ApiEndpoints.districts);
      final List data = response.data['data'];
      return data.map((e) => DistrictModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<List<HealthCenterModel>> getHealthCenters(
      String districtId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.healthCenters(districtId));
      final List data = response.data['data'];
      return data.map((e) => HealthCenterModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}