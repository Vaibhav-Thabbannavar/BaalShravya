import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import 'screening_provider.dart';

class CompleteSessionSheet extends ConsumerStatefulWidget {
  final String sessionId;

  const CompleteSessionSheet({super.key, required this.sessionId});

  @override
  ConsumerState<CompleteSessionSheet> createState() =>
      _CompleteSessionSheetState();
}

class _CompleteSessionSheetState
    extends ConsumerState<CompleteSessionSheet> {
  String? _selectedOutcome;
  String? _selectedReferralType;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedOutcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an outcome')),
      );
      return;
    }

    if (_selectedOutcome == 'refer' && _selectedReferralType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select referral type')),
      );
      return;
    }

    final success = await ref
        .read(completeSessionProvider.notifier)
        .completeSession(
          sessionId: widget.sessionId,
          outcome: _selectedOutcome!,
          referralType: _selectedReferralType,
          referralNotes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          ref: ref,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // close sheet
      context.pushReplacement('/report/${widget.sessionId}');
    } else {
      final error = ref.read(completeSessionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to complete session'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(completeSessionProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // sheet handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.completeSession,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // outcome selector
            Text(
              'Select Outcome',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _OutcomeButton(
                    label: l10n.pass,
                    color: AppColors.pass,
                    isSelected: _selectedOutcome == 'pass',
                    onTap: () => setState(() {
                      _selectedOutcome = 'pass';
                      _selectedReferralType = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutcomeButton(
                    label: l10n.refer,
                    color: AppColors.refer,
                    isSelected: _selectedOutcome == 'refer',
                    onTap: () =>
                        setState(() => _selectedOutcome = 'refer'),
                  ),
                ),
              ],
            ),

            // referral type — only shown when outcome is refer
            if (_selectedOutcome == 'refer') ...[
              const SizedBox(height: 16),
              Text(
                l10n.referralType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ReferralTypeButton(
                      label: 'OAE',
                      isSelected: _selectedReferralType == 'oae',
                      onTap: () => setState(
                          () => _selectedReferralType = 'oae'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReferralTypeButton(
                      label: 'AABR',
                      isSelected: _selectedReferralType == 'aabr',
                      onTap: () => setState(
                          () => _selectedReferralType = 'aabr'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.referralNotes,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOutcome == 'refer'
                      ? AppColors.refer
                      : AppColors.pass,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.completeSession,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OutcomeButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReferralTypeButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}