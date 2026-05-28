import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/questionnaire_repository.dart';
import '../domain/questionnaire_model.dart';

final _repository = QuestionnaireRepository();

// fetch questionnaire structure — sections and questions
final questionnaireProvider =
    FutureProvider<List<SectionModel>>((ref) async {
  return await _repository.getQuestionnaire();
});

// get submitted response for a session
// returns null if not submitted yet
final questionnaireResponseProvider =
    FutureProvider.family<QuestionnaireResponseModel?, String>(
        (ref, sessionId) async {
  return await _repository.getResponse(sessionId);
});

// state for submitting questionnaire
class SubmitQuestionnaireState {
  final bool isLoading;
  final String? error;
  final QuestionnaireResponseModel? response;

  const SubmitQuestionnaireState({
    this.isLoading = false,
    this.error,
    this.response,
  });

  SubmitQuestionnaireState copyWith({
    bool? isLoading,
    String? error,
    QuestionnaireResponseModel? response,
    bool clearError = false,
  }) {
    return SubmitQuestionnaireState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      response: response ?? this.response,
    );
  }
}

class SubmitQuestionnaireNotifier
    extends Notifier<SubmitQuestionnaireState> {
  @override
  SubmitQuestionnaireState build() => const SubmitQuestionnaireState();

  Future<bool> submit({
    required String sessionId,
    required List<AnswerModel> answers,
    required WidgetRef ref,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.submitQuestionnaire(
        sessionId: sessionId,
        answers: answers,
      );
      state = state.copyWith(isLoading: false, response: response);

      // invalidate so session dashboard refreshes
      ref.invalidate(questionnaireResponseProvider(sessionId));

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final submitQuestionnaireProvider = NotifierProvider<
    SubmitQuestionnaireNotifier, SubmitQuestionnaireState>(
  SubmitQuestionnaireNotifier.new,
);