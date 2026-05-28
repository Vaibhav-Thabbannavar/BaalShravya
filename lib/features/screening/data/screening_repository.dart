import '../domain/screening_model.dart';
import 'screening_remote_datasource.dart';

class ScreeningRepository {
  final _datasource = ScreeningRemoteDatasource();

  Future<ScreeningSessionModel> startSession(String infantId) =>
      _datasource.startSession(infantId);

  Future<ScreeningSessionModel> completeSession({
    required String sessionId,
    required String outcome,
    String? referralType,
    String? referralNotes,
  }) =>
      _datasource.completeSession(
        sessionId: sessionId,
        outcome: outcome,
        referralType: referralType,
        referralNotes: referralNotes,
      );

  Future<ScreeningSessionModel> getSessionById(String sessionId) =>
      _datasource.getSessionById(sessionId);

  Future<List<ScreeningSessionModel>> getSessionsByInfant(
          String infantId) =>
      _datasource.getSessionsByInfant(infantId);

  Future<List<ScreeningSessionModel>> getMySessions() =>
      _datasource.getMySessions();
}