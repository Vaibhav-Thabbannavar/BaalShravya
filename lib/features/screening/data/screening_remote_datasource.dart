import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/screening_model.dart';

class ScreeningRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  Future<ScreeningSessionModel> startSession(String infantId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sessions,
        data: {'infant_id': infantId},
      );
      return ScreeningSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<ScreeningSessionModel> completeSession({
    required String sessionId,
    required String outcome,
    String? referralType,
    String? referralNotes,
  }) async {
    try {
      final Map<String, dynamic> data = {'outcome': outcome};
      if (referralType != null) data['referral_type'] = referralType;
      if (referralNotes != null) data['referral_notes'] = referralNotes;

      final response = await _dio.patch(
        ApiEndpoints.completeSession(sessionId),
        data: data,
      );
      return ScreeningSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<ScreeningSessionModel> getSessionById(String sessionId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.sessionById(sessionId));
      return ScreeningSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<List<ScreeningSessionModel>> getSessionsByInfant(
      String infantId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.sessionsByInfant(infantId));
      final List data = response.data['data'];
      return data
          .map((e) => ScreeningSessionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<List<ScreeningSessionModel>> getMySessions() async {
    try {
      final response = await _dio.get(ApiEndpoints.mySessions);
      final List data = response.data['data'];
      return data
          .map((e) => ScreeningSessionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}