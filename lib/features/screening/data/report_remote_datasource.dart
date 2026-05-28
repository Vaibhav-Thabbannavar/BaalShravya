import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/screening_model.dart';
import '../../questionnaire/domain/questionnaire_model.dart';
import '../../boa/domain/boa_model.dart';
import '../../infant/domain/infant_model.dart';

// full report data — combines all three sources
class ReportData {
  final ScreeningSessionModel session;
  final InfantModel infant;
  final QuestionnaireResponseModel? questionnaireResponse;
  final BoaScreeningModel? boaScreening;
  final List<dynamic> questionnaireAnswers;

  const ReportData({
    required this.session,
    required this.infant,
    this.questionnaireResponse,
    this.boaScreening,
    required this.questionnaireAnswers,
  });
}