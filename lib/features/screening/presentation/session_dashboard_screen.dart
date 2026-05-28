import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../questionnaire/presentation/questionnaire_provider.dart';
import '../../boa/presentation/boa_provider.dart';
import 'screening_provider.dart';
import 'complete_session_sheet.dart';

class SessionDashboardScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDashboardScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessionAsync = ref.watch(sessionByIdProvider(sessionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.sessionDashboard),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.invalidate(sessionByIdProvider(sessionId)),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (session) {
          // if session is already completed go to report
          if (session.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pushReplacement('/report/$sessionId');
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _SessionDashboardContent(
            session: session,
            sessionId: sessionId,
            l10n: l10n,
            ref: ref,
          );
        },
      ),
    );
  }
}

class _SessionDashboardContent extends StatelessWidget {
  final session;
  final String sessionId;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _SessionDashboardContent({
    required this.session,
    required this.sessionId,
    required this.l10n,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    // check if questionnaire and BOA are done
    final questionnaireAsync =
        ref.watch(questionnaireResponseProvider(sessionId));
    final boaAsync = ref.watch(boaBySessionProvider(sessionId));

    final questionnaireCompleted = questionnaireAsync.maybeWhen(
      data: (data) => data != null,
      orElse: () => false,
    );

    final boaCompleted = boaAsync.maybeWhen(
      data: (data) => data != null,
      orElse: () => false,
    );

    final canComplete = questionnaireCompleted && boaCompleted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // infant info card
          _InfantInfoCard(session: session, l10n: l10n),

          const SizedBox(height: 20),

          Text(
            'Screening Tasks',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // questionnaire card
          _TaskCard(
            title: l10n.questionnaire,
            subtitle: '11 risk factor questions',
            icon: Icons.assignment_outlined,
            isCompleted: questionnaireCompleted,
            isLoading: questionnaireAsync.isLoading,
            onTap: questionnaireCompleted
                ? null // already done — no action
                : () => context.push(
                    '/questionnaire/$sessionId'),
          ),

          const SizedBox(height: 10),

          // BOA card
          _TaskCard(
            title: l10n.boaScreening,
            subtitle: 'Sound stimuli + response recording',
            icon: Icons.hearing_outlined,
            isCompleted: boaCompleted,
            isLoading: boaAsync.isLoading,
            onTap: boaCompleted
                ? null
                : () => context.push('/boa/$sessionId'),
          ),

          const SizedBox(height: 24),

          // complete session button
          // disabled until both tasks are done
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: canComplete
                  ? () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => CompleteSessionSheet(
                          sessionId: sessionId,
                        ),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canComplete
                    ? AppColors.primary
                    : AppColors.border,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                canComplete
                    ? l10n.completeSession
                    : 'Complete both tasks first',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),

          if (!canComplete) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${questionnaireCompleted ? '✅' : '⏳'} Questionnaire   ${boaCompleted ? '✅' : '⏳'} BOA',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// infant info at top of session
class _InfantInfoCard extends StatelessWidget {
  final session;
  final AppLocalizations l10n;

  const _InfantInfoCard({required this.session, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('👶', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.infantName ?? 'Infant',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Session date: ${session.sessionDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.inProgress,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.ongoing,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// task card — questionnaire or BOA
class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isLoading;
  final VoidCallback? onTap;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? AppColors.pass
                : onTap != null
                    ? AppColors.primary
                    : AppColors.border,
            width: isCompleted || onTap != null ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.passSurface
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      isCompleted ? Icons.check_circle : icon,
                      color: isCompleted
                          ? AppColors.pass
                          : AppColors.primary,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Text('✅', style: TextStyle(fontSize: 18))
            else if (onTap != null)
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}