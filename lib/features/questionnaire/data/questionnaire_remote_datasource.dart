import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/questionnaire_model.dart';

class QuestionnaireRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  // fetch all sections with questions
  Future<List<SectionModel>> getQuestionnaire() async {
    try {
      final response = await _dio.get(ApiEndpoints.questions);
      final List data = response.data['data'];
      return data.map((e) => SectionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // submit all answers at once
  Future<QuestionnaireResponseModel> submitQuestionnaire({
    required String sessionId,
    required List<AnswerModel> answers,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.submitQuestionnaire,
        data: {
          'session_id': sessionId,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );
      return QuestionnaireResponseModel.fromJson(
          response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // get submitted response for a session
  Future<QuestionnaireResponseModel?> getResponse(
      String sessionId) async {
    try {
      final response = await _dio
          .get(ApiEndpoints.questionnaireBySession(sessionId));
      return QuestionnaireResponseModel.fromJson(
          response.data['data']);
    } on DioException catch (e) {
      // 404 means questionnaire not submitted yet — return null
      if (e.response?.statusCode == 404) return null;
      throw handleDioError(e);
    }
  }
}