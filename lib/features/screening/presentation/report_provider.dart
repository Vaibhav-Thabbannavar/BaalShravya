import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/screening_remote_datasource.dart';
import '../domain/screening_model.dart';
import '../../questionnaire/data/questionnaire_remote_datasource.dart';
import '../../questionnaire/domain/questionnaire_model.dart';
import '../../boa/data/boa_remote_datasource.dart';
import '../../boa/domain/boa_model.dart';
import '../../infant/data/infant_remote_datasource.dart';
import '../../infant/domain/infant_model.dart';

// full report data assembled from multiple API calls
class ReportData {
  final ScreeningSessionModel session;
  final InfantModel infant;
  final QuestionnaireResponseModel? questionnaireResponse;
  final BoaScreeningModel? boaScreening;
  final List<dynamic> answers;

  const ReportData({
    required this.session,
    required this.infant,
    this.questionnaireResponse,
    this.boaScreening,
    required this.answers,
  });
}

final reportDataProvider =
    FutureProvider.family<ReportData, String>((ref, sessionId) async {
  final screeningDatasource = ScreeningRemoteDatasource();
  final questionnaireDatasource = QuestionnaireRemoteDatasource();
  final boaDatasource = BoaRemoteDatasource();
  final infantDatasource = InfantRemoteDatasource();

  // fetch session first — need infant_id from it
  final session = await screeningDatasource.getSessionById(sessionId);

  // fetch all other data in parallel
  final results = await Future.wait([
    infantDatasource.getInfantById(session.infantId),
    questionnaireDatasource.getResponse(sessionId),
    boaDatasource.getBoaBySession(sessionId),
  ]);

  final infant = results[0] as InfantModel;
  final questionnaireResponse =
      results[1] as QuestionnaireResponseModel?;
  final boaScreening = results[2] as BoaScreeningModel?;

  // get answers with full question text for report
  List<dynamic> answers = [];
  if (questionnaireResponse != null) {
    try {
      final response = await questionnaireDatasource
          .getResponse(sessionId);
      // answers with section and question text come from
      // the detailed response endpoint
    } catch (_) {}
  }

  return ReportData(
    session: session,
    infant: infant,
    questionnaireResponse: questionnaireResponse,
    boaScreening: boaScreening,
    answers: answers,
  );
});