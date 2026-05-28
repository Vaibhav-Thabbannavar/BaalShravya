import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/infant_repository.dart';
import '../domain/infant_model.dart';

final _repository = InfantRepository();

// list of infants — FutureProvider caches the list
// invalidated after adding a new infant so list refreshes
final myInfantsProvider = FutureProvider<List<InfantModel>>((ref) async {
  return await _repository.getMyInfants();
});

final centerInfantsProvider = FutureProvider<List<InfantModel>>((ref) async {
  return await _repository.getInfantsAtMyCenter();
});

// single infant by id — family modifier passes the id
final infantByIdProvider =
    FutureProvider.family<InfantModel, String>((ref, infantId) async {
  return await _repository.getInfantById(infantId);
});

// state notifier for add infant form
class AddInfantState {
  final bool isLoading;
  final String? error;
  final InfantModel? createdInfant;

  const AddInfantState({
    this.isLoading = false,
    this.error,
    this.createdInfant,
  });

  AddInfantState copyWith({
    bool? isLoading,
    String? error,
    InfantModel? createdInfant,
    bool clearError = false,
  }) {
    return AddInfantState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      createdInfant: createdInfant ?? this.createdInfant,
    );
  }
}

class AddInfantNotifier extends Notifier<AddInfantState> {
  @override
  AddInfantState build() => const AddInfantState();

  Future<bool> addInfant(Map<String, dynamic> data, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final infant = await _repository.createInfant(data);
      state = state.copyWith(isLoading: false, createdInfant: infant);

      // invalidate both lists so they refresh
      ref.invalidate(myInfantsProvider);
      ref.invalidate(centerInfantsProvider);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final addInfantProvider =
    NotifierProvider<AddInfantNotifier, AddInfantState>(
  AddInfantNotifier.new,
);