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

      // print exact response to debug
      print('RAW districts response type: ${response.data.runtimeType}');
      print('RAW districts response: ${response.data}');

      List<dynamic> list = [];

      if (response.data is Map) {
        // standard shape { success: true, data: [...] }
        final data = response.data['data'];
        if (data is List) {
          list = data;
        }
      } else if (response.data is List) {
        // direct array response
        list = response.data;
      }

      return list
          .map((e) => DistrictModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<List<HealthCenterModel>> getHealthCenters(
      String districtId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.healthCenters(districtId));

      print('RAW health centers response type: ${response.data.runtimeType}');
      print('RAW health centers response: ${response.data}');

      List<dynamic> list = [];

      if (response.data is Map) {
        final data = response.data['data'];
        if (data is List) {
          list = data;
        }
      } else if (response.data is List) {
        list = response.data;
      }

      return list
          .map((e) =>
              HealthCenterModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}