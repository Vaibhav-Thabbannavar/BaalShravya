import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/presentation/auth_provider.dart';
import 'infant_provider.dart';

class AddInfantScreen extends ConsumerStatefulWidget {
  const AddInfantScreen({super.key});

  @override
  ConsumerState<AddInfantScreen> createState() => _AddInfantScreenState();
}

class _AddInfantScreenState extends ConsumerState<AddInfantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthWeightController = TextEditingController();

  DateTime? _selectedDob;
  String? _selectedGender;
  String? _selectedDeliveryType;

  @override
  void dispose() {
    _nameController.dispose();
    _birthWeightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      // infants are 0-12 months old
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);

    // build request body
    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      // format date as YYYY-MM-DD
      'date_of_birth':
          '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}',
      'gender': _selectedGender,
    };

    if (_birthWeightController.text.isNotEmpty) {
      data['birth_weight_kg'] =
          double.parse(_birthWeightController.text);
    }

    if (_selectedDeliveryType != null) {
      data['delivery_type'] = _selectedDeliveryType;
    }

    // ANM must provide parent_id — handled in next step
    // parent role — server derives parent_id from token automatically

    final success = await ref
        .read(addInfantProvider.notifier)
        .addInfant(data, ref);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.infantRegistered),
          backgroundColor: AppColors.pass,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(addInfantProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to register infant'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(addInfantProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.registerInfant),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // section header
              _SectionHeader(title: l10n.infantDetails),
              const SizedBox(height: 16),

              // infant name
              AppTextField(
                label: l10n.infantName,
                controller: _nameController,
                prefixIcon: const Icon(Icons.child_care_outlined),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.errorRequired : null,
              ),

              const SizedBox(height: 16),

              // date of birth picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDob == null
                              ? l10n.dateOfBirth
                              : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDob == null
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // gender selector
              Text(
                l10n.gender,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SelectChip(
                    label: l10n.male,
                    isSelected: _selectedGender == 'male',
                    onTap: () => setState(() => _selectedGender = 'male'),
                  ),
                  const SizedBox(width: 8),
                  _SelectChip(
                    label: l10n.female,
                    isSelected: _selectedGender == 'female',
                    onTap: () =>
                        setState(() => _selectedGender = 'female'),
                  ),
                  const SizedBox(width: 8),
                  _SelectChip(
                    label: l10n.other,
                    isSelected: _selectedGender == 'other',
                    onTap: () =>
                        setState(() => _selectedGender = 'other'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // birth weight
              AppTextField(
                label: l10n.birthWeight,
                controller: _birthWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final weight = double.tryParse(v);
                    if (weight == null || weight < 0.5 || weight > 10) {
                      return 'Enter a valid weight between 0.5 and 10 kg';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // delivery type
              Text(
                l10n.deliveryType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SelectChip(
                    label: l10n.normal,
                    isSelected: _selectedDeliveryType == 'normal',
                    onTap: () =>
                        setState(() => _selectedDeliveryType = 'normal'),
                  ),
                  const SizedBox(width: 8),
                  _SelectChip(
                    label: l10n.cesarean,
                    isSelected: _selectedDeliveryType == 'cesarean',
                    onTap: () => setState(
                        () => _selectedDeliveryType = 'cesarean'),
                  ),
                  const SizedBox(width: 8),
                  _SelectChip(
                    label: l10n.assisted,
                    isSelected: _selectedDeliveryType == 'assisted',
                    onTap: () => setState(
                        () => _selectedDeliveryType = 'assisted'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              AppButton(
                label: l10n.registerInfant,
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// chip selector for gender and delivery type
class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}