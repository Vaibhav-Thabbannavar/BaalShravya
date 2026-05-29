import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/awareness_model.dart';

class AwarenessRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  Future<List<AwarenessContentModel>> getAwareness() async {
    try {
      final response = await _dio.get(ApiEndpoints.awareness);
      final List data = response.data['data'];
      return data
          .map((e) => AwarenessContentModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AwarenessContentModel> createAwareness(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.awareness, data: data);
      return AwarenessContentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AwarenessContentModel> updateAwareness(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
          ApiEndpoints.awarenessById(id),
          data: data);
      return AwarenessContentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> deleteAwareness(String id) async {
    try {
      await _dio.delete(ApiEndpoints.awarenessById(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}