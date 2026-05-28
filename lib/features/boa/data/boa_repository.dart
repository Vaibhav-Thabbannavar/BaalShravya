import '../domain/boa_model.dart';
import 'boa_remote_datasource.dart';

class BoaRepository {
  final _datasource = BoaRemoteDatasource();

  Future<BoaScreeningModel> submitBoa({
    required String sessionId,
    required List<StimulusResultModel> stimulusResults,
    String? notes,
  }) =>
      _datasource.submitBoa(
        sessionId: sessionId,
        stimulusResults: stimulusResults,
        notes: notes,
      );

  Future<BoaScreeningModel?> getBoaBySession(String sessionId) =>
      _datasource.getBoaBySession(sessionId);
}