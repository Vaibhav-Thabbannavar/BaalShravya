import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../dashboard/presentation/dashboard_provider.dart';
import '../../dashboard/domain/dashboard_model.dart';
import '../../../shared/widgets/app_drawer.dart';

class AnmHomeScreen extends ConsumerWidget {
  const AnmHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final dashboardAsync = ref.watch(anmDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        // pull to refresh — invalidates provider so data reloads
        onRefresh: () async {
          ref.invalidate(anmDashboardProvider);
        },
        child: CustomScrollView(
          slivers: [

            // custom app bar with greeting
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _getGreeting(l10n),
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
                      const SizedBox(height: 2),
                      Text(
                        'ANM',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // content
            SliverToBoxAdapter(
              child: dashboardAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: _ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(anmDashboardProvider),
                  ),
                ),
                data: (stats) => _AnmDashboardContent(stats: stats, l10n: l10n),
              ),
            ),
          ],
        ),
      ),

      // FAB — start new screening
      // in AnmHomeScreen build method — update FAB
  floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/infants'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.newScreening,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }
}

class _AnmDashboardContent extends StatelessWidget {
  final AnmStatsModel stats;
  final AppLocalizations l10n;

  const _AnmDashboardContent({
    required this.stats,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // stats cards row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.totalScreenings,
                  value: stats.totalScreenings.toString(),
                  color: AppColors.primary,
                  icon: Icons.medical_services_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: l10n.totalReferrals,
                  value: stats.totalRefer.toString(),
                  color: AppColors.refer,
                  icon: Icons.warning_amber_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.totalPass,
                  value: stats.totalPass.toString(),
                  color: AppColors.pass,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: l10n.inProgress,
                  value: stats.inProgress.toString(),
                  color: AppColors.inProgress,
                  icon: Icons.hourglass_empty_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // recent cases header
          Text(
            l10n.recentCases,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // case list
          if (stats.caseList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noSessionsYet,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              // shrinkWrap because it's inside CustomScrollView
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.caseList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _CaseCard(
                  item: stats.caseList[index],
                  l10n: l10n,
                );
              },
            ),

          // bottom padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// stat card widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// case list item
class _CaseCard extends StatelessWidget {
  final CaseItemModel item;
  final AppLocalizations l10n;

  const _CaseCard({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final outcome = item.outcome;
    final isPass = outcome == 'pass';
    final isRefer = outcome == 'refer';

    Color badgeColor = isPass
        ? AppColors.pass
        : isRefer
            ? AppColors.refer
            : AppColors.inProgress;

    String badgeText = isPass
        ? l10n.pass
        : isRefer
            ? l10n.refer
            : l10n.ongoing;

    return GestureDetector(
      onTap: () => context.push('/session/${item.sessionId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [

            // avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('👶', style: TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 12),

            // infant and parent info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.infantName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.parentName} · ${item.sessionDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // outcome badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}