import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/boa_model.dart';

class BoaRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  Future<BoaScreeningModel> submitBoa({
    required String sessionId,
    required List<StimulusResultModel> stimulusResults,
    String? notes,
    String? videoUrl,
    int? videoDurationSeconds,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'session_id': sessionId,
        'stimulus_results':
            stimulusResults.map((s) => s.toJson()).toList(),
      };
      if (notes != null) data['notes'] = notes;
      if (videoUrl != null) data['video_url'] = videoUrl;
      if (videoDurationSeconds != null) {
        data['video_duration_seconds'] = videoDurationSeconds;
      }

      final response =
          await _dio.post(ApiEndpoints.boa, data: data);
      return BoaScreeningModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<BoaScreeningModel?> getBoaBySession(
      String sessionId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.boaBySession(sessionId));
      return BoaScreeningModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw handleDioError(e);
    }
  }
}