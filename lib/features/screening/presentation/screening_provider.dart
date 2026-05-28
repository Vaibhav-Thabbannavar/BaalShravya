import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/screening_repository.dart';
import '../domain/screening_model.dart';

final _repository = ScreeningRepository();

// single session by id
final sessionByIdProvider =
    FutureProvider.family<ScreeningSessionModel, String>(
        (ref, sessionId) async {
  return await _repository.getSessionById(sessionId);
});

// sessions for a specific infant
final sessionsByInfantProvider =
    FutureProvider.family<List<ScreeningSessionModel>, String>(
        (ref, infantId) async {
  return await _repository.getSessionsByInfant(infantId);
});

// ANM's own sessions
final mySessionsProvider =
    FutureProvider<List<ScreeningSessionModel>>((ref) async {
  return await _repository.getMySessions();
});

// state for starting a session
class StartSessionState {
  final bool isLoading;
  final String? error;
  final ScreeningSessionModel? session;

  const StartSessionState({
    this.isLoading = false,
    this.error,
    this.session,
  });

  StartSessionState copyWith({
    bool? isLoading,
    String? error,
    ScreeningSessionModel? session,
    bool clearError = false,
  }) {
    return StartSessionState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      session: session ?? this.session,
    );
  }
}

class StartSessionNotifier extends Notifier<StartSessionState> {
  @override
  StartSessionState build() => const StartSessionState();

  Future<ScreeningSessionModel?> startSession(
      String infantId, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.startSession(infantId);
      state = state.copyWith(isLoading: false, session: session);
      // invalidate sessions list so it refreshes
      ref.invalidate(mySessionsProvider);
      return session;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final startSessionProvider =
    NotifierProvider<StartSessionNotifier, StartSessionState>(
  StartSessionNotifier.new,
);

// state for completing a session
class CompleteSessionState {
  final bool isLoading;
  final String? error;
  final bool isCompleted;

  const CompleteSessionState({
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
  });

  CompleteSessionState copyWith({
    bool? isLoading,
    String? error,
    bool? isCompleted,
    bool clearError = false,
  }) {
    return CompleteSessionState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class CompleteSessionNotifier extends Notifier<CompleteSessionState> {
  @override
  CompleteSessionState build() => const CompleteSessionState();

  Future<bool> completeSession({
    required String sessionId,
    required String outcome,
    String? referralType,
    String? referralNotes,
    required WidgetRef ref,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.completeSession(
        sessionId: sessionId,
        outcome: outcome,
        referralType: referralType,
        referralNotes: referralNotes,
      );
      state = state.copyWith(isLoading: false, isCompleted: true);
      // invalidate so session detail refreshes
      ref.invalidate(sessionByIdProvider(sessionId));
      ref.invalidate(mySessionsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final completeSessionProvider =
    NotifierProvider<CompleteSessionNotifier, CompleteSessionState>(
  CompleteSessionNotifier.new,
);