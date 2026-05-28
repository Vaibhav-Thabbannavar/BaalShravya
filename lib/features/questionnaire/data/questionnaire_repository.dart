import '../domain/questionnaire_model.dart';
import 'questionnaire_remote_datasource.dart';

class QuestionnaireRepository {
  final _datasource = QuestionnaireRemoteDatasource();

  Future<List<SectionModel>> getQuestionnaire() =>
      _datasource.getQuestionnaire();

  Future<QuestionnaireResponseModel> submitQuestionnaire({
    required String sessionId,
    required List<AnswerModel> answers,
  }) =>
      _datasource.submitQuestionnaire(
        sessionId: sessionId,
        answers: answers,
      );

  Future<QuestionnaireResponseModel?> getResponse(
          String sessionId) =>
      _datasource.getResponse(sessionId);
}