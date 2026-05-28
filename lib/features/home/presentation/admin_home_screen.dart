import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../dashboard/presentation/dashboard_provider.dart';
import '../../dashboard/domain/dashboard_model.dart';
import '../../../shared/widgets/app_drawer.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDashboardProvider),
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
                        l10n.dashboard,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
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
              child: dashboardAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Text(e.toString()),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(adminDashboardProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (stats) => _AdminContent(
                  stats: stats,
                  l10n: l10n,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminContent extends StatelessWidget {
  final AdminStatsModel stats;
  final AppLocalizations l10n;

  const _AdminContent({required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // overview stats
          Text(
            'Overview',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // 3 column stats
          Row(
            children: [
              _MiniStat(
                label: l10n.totalScreenings,
                value: stats.totalScreenings.toString(),
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _MiniStat(
                label: l10n.totalPass,
                value: stats.totalPass.toString(),
                color: AppColors.pass,
              ),
              const SizedBox(width: 8),
              _MiniStat(
                label: l10n.totalReferrals,
                value: stats.totalRefer.toString(),
                color: AppColors.refer,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _MiniStat(
                label: 'ANMs',
                value: stats.totalAnms.toString(),
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              _MiniStat(
                label: 'Parents',
                value: stats.totalParents.toString(),
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              _MiniStat(
                label: 'Infants',
                value: stats.totalInfants.toString(),
                color: AppColors.inProgress,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // district breakdown
          Text(
            'By District',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          if (stats.byDistrict.isEmpty)
            Center(
              child: Text(
                'No data yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.byDistrict.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final district = stats.byDistrict[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        district.districtName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _DistrictBadge(
                            label: 'Total',
                            value: district.totalScreenings,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _DistrictBadge(
                            label: 'Pass',
                            value: district.totalPass,
                            color: AppColors.pass,
                          ),
                          const SizedBox(width: 8),
                          _DistrictBadge(
                            label: 'Refer',
                            value: district.totalRefer,
                            color: AppColors.refer,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistrictBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _DistrictBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}