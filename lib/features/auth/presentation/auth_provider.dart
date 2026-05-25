import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/auth_model.dart';

// auth state — what the UI watches
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  // copyWith lets us update only specific fields
  // leaving the rest unchanged
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = AuthRepository();
    // check if user is already logged in when app starts
    _checkSavedUser();
    return const AuthState();
  }

  Future<void> _checkSavedUser() async {
    final user = await _repository.getSavedUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    // set loading state — UI shows spinner
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(
        phone: phone,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true; // success
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false; // failure
    }
  }

  Future<bool> register({required Map<String, dynamic> data}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(data: data);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(); // reset to empty state
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// convenience provider — just the user
// widgets that only need the user don't need to watch the full state
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});