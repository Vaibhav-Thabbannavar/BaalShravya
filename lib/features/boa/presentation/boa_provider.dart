import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/boa_repository.dart';
import '../domain/boa_model.dart';

final _repository = BoaRepository();

// get BOA for a session — null if not submitted yet
final boaBySessionProvider =
    FutureProvider.family<BoaScreeningModel?, String>(
        (ref, sessionId) async {
  return await _repository.getBoaBySession(sessionId);
});

// state for submitting BOA
class SubmitBoaState {
  final bool isLoading;
  final String? error;
  final BoaScreeningModel? result;

  const SubmitBoaState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  SubmitBoaState copyWith({
    bool? isLoading,
    String? error,
    BoaScreeningModel? result,
    bool clearError = false,
  }) {
    return SubmitBoaState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      result: result ?? this.result,
    );
  }
}

class SubmitBoaNotifier extends Notifier<SubmitBoaState> {
  @override
  SubmitBoaState build() => const SubmitBoaState();

  Future<bool> submit({
    required String sessionId,
    required List<StimulusResultModel> stimulusResults,
    String? notes,
    required WidgetRef ref,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.submitBoa(
        sessionId: sessionId,
        stimulusResults: stimulusResults,
        notes: notes,
      );
      state = state.copyWith(isLoading: false, result: result);

      // invalidate so session dashboard refreshes
      ref.invalidate(boaBySessionProvider(sessionId));

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final submitBoaProvider =
    NotifierProvider<SubmitBoaNotifier, SubmitBoaState>(
  SubmitBoaNotifier.new,
);