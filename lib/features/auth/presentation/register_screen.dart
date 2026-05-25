import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'auth_provider.dart';

// available roles for registration
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

  // these will be populated from API later
  // for now we use them to store selected values
  String? _selectedDistrictId;
  String? _selectedHealthCenterId;
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

    // build the request body based on role
    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole.name, // 'anm' or 'parent'
    };

    if (_selectedRole == UserRole.anm) {
      data['health_center_id'] = _selectedHealthCenterId;
      data['employee_id'] = _employeeIdController.text.trim();
    }

    if (_selectedRole == UserRole.parent) {
      data['address'] = _addressController.text.trim();
      data['relationship'] = _selectedRelationship ?? 'mother';
    }

    final success = await ref.read(authProvider.notifier).register(data: data);

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
          icon: const Icon(Icons.arrow_back),
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

                // role selector
                _buildRoleSelector(l10n),

                const SizedBox(height: 24),

                // common fields
                AppTextField(
                  label: l10n.fullName,
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? l10n.errorRequired : null,
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
                    if (value.length != 10) return l10n.errorInvalidPhone;
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
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (value.length < 6) return l10n.errorPasswordShort;
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // role specific fields
                if (_selectedRole == UserRole.anm) ...[
                  _buildAnmFields(l10n),
                ],

                if (_selectedRole == UserRole.parent) ...[
                  _buildParentFields(l10n),
                ],

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
                      style: const TextStyle(color: AppColors.primary),
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

  // role selector — two cards side by side
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
              onTap: () => setState(() => _selectedRole = UserRole.parent),
            ),
            const SizedBox(width: 12),
            _RoleCard(
              label: l10n.roleAnm,
              emoji: '👩‍⚕️',
              isSelected: _selectedRole == UserRole.anm,
              onTap: () => setState(() => _selectedRole = UserRole.anm),
            ),
          ],
        ),
      ],
    );
  }

  // ANM specific fields
  Widget _buildAnmFields(AppLocalizations l10n) {
    return Column(
      children: [
        // district and health center dropdowns
        // will be populated from API in next step
        // for now just show placeholder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'District and health center selection coming in next step',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.employeeId,
          controller: _employeeIdController,
          prefixIcon: const Icon(Icons.badge_outlined),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // parent specific fields
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
        // relationship dropdown
        DropdownButtonFormField<String>(
          value: _selectedRelationship,
          decoration: InputDecoration(
            labelText: l10n.relationship,
            prefixIcon: const Icon(Icons.family_restroom_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: [
            DropdownMenuItem(value: 'mother', child: Text(l10n.mother)),
            DropdownMenuItem(value: 'father', child: Text(l10n.father)),
            DropdownMenuItem(value: 'guardian', child: Text(l10n.guardian)),
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

// role selection card widget
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
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