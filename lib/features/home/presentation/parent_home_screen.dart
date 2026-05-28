import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../infant/presentation/infant_provider.dart';
import '../../infant/domain/infant_model.dart';
import '../../../shared/widgets/app_drawer.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final infantsAsync = ref.watch(myInfantsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myInfantsProvider),
        child: CustomScrollView(
          slivers: [

            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        l10n.welcome,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // my infants section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.myInfants,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/infants'),
                          icon: const Icon(Icons.arrow_forward,
                              size: 16, color: AppColors.primary),
                          label: Text(
                            'See all',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // infant list
                    infantsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.referSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          e.toString(),
                          style:
                              const TextStyle(color: AppColors.refer),
                        ),
                      ),
                      data: (infants) {
                        if (infants.isEmpty) {
                          return _EmptyInfants(l10n: l10n);
                        }
                        return Column(
                          children: infants
                              .take(3) // show max 3 on home screen
                              .map((infant) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10),
                                    child: _InfantHomeCard(
                                        infant: infant, l10n: l10n),
                                  ))
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // awareness section
                    Text(
                      l10n.awareness,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => context.push(AppRoutes.awareness),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.border, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('👂',
                                    style: TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Signs of Hearing Loss',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Tap to learn more',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 14,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class _EmptyInfants extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyInfants({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          children: [
            const Text('👶', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              l10n.noInfantsYet,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addInfant),
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.addInfant),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfantHomeCard extends StatelessWidget {
  final InfantModel infant;
  final AppLocalizations l10n;

  const _InfantHomeCard({required this.infant, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/infant/${infant.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: infant.gender == 'male'
                    ? const Color(0xFFE3F2FD)
                    : infant.gender == 'female'
                        ? const Color(0xFFFCE4EC)
                        : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  infant.gender == 'male'
                      ? '👦'
                      : infant.gender == 'female'
                          ? '👧'
                          : '👶',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infant.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    infant.ageString,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}