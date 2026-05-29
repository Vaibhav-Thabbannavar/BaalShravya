import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/awareness_remote_datasource.dart';
import '../domain/awareness_model.dart';

final _datasource = AwarenessRemoteDatasource();

final awarenessProvider =
    FutureProvider<List<AwarenessContentModel>>((ref) async {
  return await _datasource.getAwareness();
});

// state for admin create/edit/delete
class AwarenessAdminState {
  final bool isLoading;
  final String? error;
  final bool success;

  const AwarenessAdminState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AwarenessAdminState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return AwarenessAdminState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class AwarenessAdminNotifier extends Notifier<AwarenessAdminState> {
  @override
  AwarenessAdminState build() => const AwarenessAdminState();

  Future<bool> create(Map<String, dynamic> data, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.createAwareness(data);
      state = state.copyWith(isLoading: false, success: true);
      ref.invalidate(awarenessProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> update(
      String id, Map<String, dynamic> data, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.updateAwareness(id, data);
      state = state.copyWith(isLoading: false, success: true);
      ref.invalidate(awarenessProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteAwareness(id);
      state = state.copyWith(isLoading: false, success: true);
      ref.invalidate(awarenessProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final awarenessAdminProvider =
    NotifierProvider<AwarenessAdminNotifier, AwarenessAdminState>(
  AwarenessAdminNotifier.new,
);