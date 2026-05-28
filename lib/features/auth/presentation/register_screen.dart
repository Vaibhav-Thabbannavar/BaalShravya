import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../geography/presentation/geography_provider.dart';
import '../../geography/domain/geography_model.dart';
import 'auth_provider.dart';

enum UserRole { anm, parent }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _employeeIdController = TextEditingController();

  UserRole _selectedRole = UserRole.parent;
  bool _passwordVisible = false;

  // geography selections for ANM
  DistrictModel? _selectedDistrict;
  HealthCenterModel? _selectedHealthCenter;

  // parent fields
  String? _selectedRelationship;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // ANM must select health center
    if (_selectedRole == UserRole.anm &&
        _selectedHealthCenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a health center'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole.name,
    };

    if (_selectedRole == UserRole.anm) {
      data['health_center_id'] = _selectedHealthCenter!.id;
      if (_employeeIdController.text.isNotEmpty) {
        data['employee_id'] = _employeeIdController.text.trim();
      }
    }

    if (_selectedRole == UserRole.parent) {
      data['address'] = _addressController.text.trim();
      data['relationship'] = _selectedRelationship ?? 'mother';
    }

    final success =
        await ref.read(authProvider.notifier).register(data: data);

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildRoleSelector(l10n),
                const SizedBox(height: 24),

                AppTextField(
                  label: l10n.fullName,
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (v) => v == null || v.isEmpty
                      ? l10n.errorRequired
                      : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: l10n.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (value.length != 10) {
                      return l10n.errorInvalidPhone;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: l10n.password,
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(
                        () => _passwordVisible = !_passwordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (value.length < 6) {
                      return l10n.errorPasswordShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // role specific fields
                if (_selectedRole == UserRole.anm)
                  _buildAnmFields(l10n),

                if (_selectedRole == UserRole.parent)
                  _buildParentFields(l10n),

                const SizedBox(height: 32),

                AppButton(
                  label: l10n.register,
                  isLoading: isLoading,
                  onPressed: _register,
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      l10n.alreadyHaveAccount,
                      style:
                          const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectRole,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _RoleCard(
              label: l10n.roleParent,
              emoji: '👨‍👩‍👧',
              isSelected: _selectedRole == UserRole.parent,
              onTap: () =>
                  setState(() => _selectedRole = UserRole.parent),
            ),
            const SizedBox(width: 12),
            _RoleCard(
              label: l10n.roleAnm,
              emoji: '👩‍⚕️',
              isSelected: _selectedRole == UserRole.anm,
              onTap: () =>
                  setState(() => _selectedRole = UserRole.anm),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnmFields(AppLocalizations l10n) {
    // watch districts from API
    final districtsAsync = ref.watch(districtsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // district dropdown
        Text(
          l10n.district,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        districtsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text(
            'Failed to load districts: $e',
            style: const TextStyle(color: AppColors.error),
          ),
          data: (districts) => DropdownButtonFormField<DistrictModel>(
            value: _selectedDistrict,
            decoration: InputDecoration(
              labelText: l10n.selectDistrict,
              prefixIcon: const Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            items: districts
                .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.name),
                    ))
                .toList(),
            onChanged: (district) {
              setState(() {
                _selectedDistrict = district;
                // reset health center when district changes
                _selectedHealthCenter = null;
              });
            },
            validator: (v) =>
                v == null ? l10n.errorRequired : null,
          ),
        ),

        const SizedBox(height: 16),

        // health center dropdown
        // only shown after district is selected
        if (_selectedDistrict != null) ...[
          Text(
            l10n.healthCenter,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // family provider — passes selected district id
          ref.watch(healthCentersProvider(_selectedDistrict!.id)).when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text(
              'Failed to load health centers: $e',
              style: const TextStyle(color: AppColors.error),
            ),
            data: (centers) => DropdownButtonFormField<HealthCenterModel>(
              value: _selectedHealthCenter,
              decoration: InputDecoration(
                labelText: l10n.selectHealthCenter,
                prefixIcon:
                    const Icon(Icons.local_hospital_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: centers
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (center) {
                setState(() => _selectedHealthCenter = center);
              },
              validator: (v) =>
                  v == null ? l10n.errorRequired : null,
            ),
          ),

          const SizedBox(height: 16),
        ],

        AppTextField(
          label: l10n.employeeId,
          controller: _employeeIdController,
          prefixIcon: const Icon(Icons.badge_outlined),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildParentFields(AppLocalizations l10n) {
    return Column(
      children: [
        AppTextField(
          label: l10n.address,
          controller: _addressController,
          prefixIcon: const Icon(Icons.location_on_outlined),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRelationship,
          decoration: InputDecoration(
            labelText: l10n.relationship,
            prefixIcon:
                const Icon(Icons.family_restroom_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: [
            DropdownMenuItem(
                value: 'mother', child: Text(l10n.mother)),
            DropdownMenuItem(
                value: 'father', child: Text(l10n.father)),
            DropdownMenuItem(
                value: 'guardian', child: Text(l10n.guardian)),
          ],
          onChanged: (value) =>
              setState(() => _selectedRelationship = value),
          validator: (v) =>
              v == null ? l10n.errorRequired : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySurface
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}