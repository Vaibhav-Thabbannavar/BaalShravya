import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../infant/presentation/infant_provider.dart';
import 'screening_provider.dart';

class StartSessionScreen extends ConsumerWidget {
  final String infantId;

  const StartSessionScreen({super.key, required this.infantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final infantAsync = ref.watch(infantByIdProvider(infantId));
    final startState = ref.watch(startSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.startScreening),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: infantAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (infant) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // infant summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: infant.gender == 'male'
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          infant.gender == 'male' ? '👦' : '👧',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            infant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            infant.ageString,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (infant.birthWeightKg != null)
                            Text(
                              '${infant.birthWeightKg} kg',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // what happens in a session
              Text(
                'Screening includes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              _StepCard(
                number: '1',
                title: l10n.questionnaire,
                description:
                    '11 questions covering prenatal, perinatal and postnatal risk factors',
                icon: Icons.assignment_outlined,
              ),

              const SizedBox(height: 10),

              _StepCard(
                number: '2',
                title: l10n.boaScreening,
                description:
                    'Play calibrated sounds and record infant responses at 4 frequencies',
                icon: Icons.hearing_outlined,
              ),

              const SizedBox(height: 10),

              _StepCard(
                number: '3',
                title: l10n.screeningReport,
                description:
                    'Generate downloadable PDF report with outcome',
                icon: Icons.description_outlined,
              ),

              const SizedBox(height: 32),

              // error message
              if (startState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.referSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    startState.error!,
                    style:
                        const TextStyle(color: AppColors.refer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // start button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: startState.isLoading
                      ? null
                      : () async {
                          final session = await ref
                              .read(startSessionProvider.notifier)
                              .startSession(infantId, ref);

                          if (!context.mounted) return;

                          if (session != null) {
                            // navigate to session dashboard
                            context.pushReplacement(
                                '/session/${session.id}');
                          }
                        },
                  icon: startState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    startState.isLoading
                        ? 'Starting...'
                        : l10n.startScreening,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}