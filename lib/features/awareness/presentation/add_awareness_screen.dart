import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'awareness_provider.dart';

class AddAwarenessSheet extends ConsumerStatefulWidget {
  const AddAwarenessSheet({super.key});

  @override
  ConsumerState<AddAwarenessSheet> createState() =>
      _AddAwarenessSheetState();
}

class _AddAwarenessSheetState
    extends ConsumerState<AddAwarenessSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': _titleController.text.trim(),
      'body': _bodyController.text.trim(),
      if (_imageUrlController.text.isNotEmpty)
        'image_url': _imageUrlController.text.trim(),
    };

    final success = await ref
        .read(awarenessAdminProvider.notifier)
        .create(data, ref);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Awareness content created'),
          backgroundColor: AppColors.pass,
        ),
      );
    } else {
      final error = ref.read(awarenessAdminProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to create content'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading =
        ref.watch(awarenessAdminProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // handle
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

              const Text(
                'Add Awareness Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: l10n.title,
                controller: _titleController,
                prefixIcon: const Icon(Icons.title),
                validator: (v) => v == null || v.isEmpty
                    ? l10n.errorRequired
                    : null,
              ),

              const SizedBox(height: 14),

              AppTextField(
                label: 'Content',
                controller: _bodyController,
                maxLines: 4,
                prefixIcon: const Icon(Icons.article_outlined),
                validator: (v) => v == null || v.isEmpty
                    ? l10n.errorRequired
                    : null,
              ),

              const SizedBox(height: 14),

              AppTextField(
                label: 'Image URL (optional)',
                controller: _imageUrlController,
                prefixIcon: const Icon(Icons.image_outlined),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish'),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}