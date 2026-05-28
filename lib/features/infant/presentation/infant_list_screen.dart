import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/presentation/auth_provider.dart';
import 'infant_provider.dart';
import '../domain/infant_model.dart';

class InfantListScreen extends ConsumerWidget {
  const InfantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    // ANM sees health center infants, parent sees their own
    final infantsAsync = user?.role == 'parent'
        ? ref.watch(myInfantsProvider)
        : ref.watch(centerInfantsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myInfants),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (user?.role == 'parent') {
                ref.invalidate(myInfantsProvider);
              } else {
                ref.invalidate(centerInfantsProvider);
              }
            },
          ),
        ],
      ),
      body: infantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => user?.role == 'parent'
                    ? ref.invalidate(myInfantsProvider)
                    : ref.invalidate(centerInfantsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (infants) {
          if (infants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👶', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noInfantsYet,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.addInfant),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addInfant),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => user?.role == 'parent'
                ? ref.invalidate(myInfantsProvider)
                : ref.invalidate(centerInfantsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: infants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _InfantCard(infant: infants[index], l10n: l10n);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addInfant),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addInfant,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _InfantCard extends StatelessWidget {
  final InfantModel infant;
  final AppLocalizations l10n;

  const _InfantCard({required this.infant, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // navigate to infant profile with infant id
      onTap: () => context.push('/infant/${infant.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [

            // gender colored avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: infant.gender == 'male'
                    ? const Color(0xFFE3F2FD)
                    : infant.gender == 'female'
                        ? const Color(0xFFFCE4EC)
                        : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  infant.gender == 'male' ? '👦' : infant.gender == 'female' ? '👧' : '👶',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // infant info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infant.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    infant.ageString,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (infant.birthWeightKg != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${infant.birthWeightKg} kg · ${infant.deliveryType ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}