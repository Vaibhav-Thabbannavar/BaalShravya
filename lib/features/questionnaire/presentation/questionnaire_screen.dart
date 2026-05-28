import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/questionnaire_model.dart';
import 'questionnaire_provider.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const QuestionnaireScreen({super.key, required this.sessionId});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState
    extends ConsumerState<QuestionnaireScreen> {
  // stores answer for each question id
  // true = YES, false = NO, null = not answered yet
  final Map<String, bool> _answers = {};

  // which section is currently expanded
  int _expandedSection = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questionnaireAsync = ref.watch(questionnaireProvider);
    final submitState = ref.watch(submitQuestionnaireProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.questionnaireTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: questionnaireAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (sections) {
          // count total questions across all sections
          final totalQuestions = sections
              .fold(0, (sum, s) => sum + s.questions.length);

          // count answered questions
          final answeredCount = _answers.length;

          return Column(
            children: [

              // progress bar at top
              _ProgressHeader(
                answered: answeredCount,
                total: totalQuestions,
              ),

              // sections list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    return _SectionCard(
                      section: sections[index],
                      isExpanded: _expandedSection == index,
                      answers: _answers,
                      onToggle: () => setState(() =>
                          _expandedSection =
                              _expandedSection == index ? -1 : index),
                      onAnswer: (questionId, value) {
                        setState(() => _answers[questionId] = value);
                        // auto expand next section when current is complete
                        final allAnswered = sections[index]
                            .questions
                            .every((q) => _answers.containsKey(q.id));
                        if (allAnswered &&
                            index < sections.length - 1) {
                          setState(
                              () => _expandedSection = index + 1);
                        }
                      },
                    );
                  },
                ),
              ),

              // submit button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (submitState.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.referSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          submitState.error!,
                          style: const TextStyle(
                              color: AppColors.refer,
                              fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        // only enable when all questions answered
                        onPressed: answeredCount < totalQuestions ||
                                submitState.isLoading
                            ? null
                            : () => _submit(sections),
                        child: submitState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                answeredCount < totalQuestions
                                    ? '$answeredCount / $totalQuestions answered'
                                    : l10n.submit,
                                style: const TextStyle(fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(List<SectionModel> sections) async {
    // build answers list from map
    final answers = _answers.entries
        .map((e) => AnswerModel(
              questionId: e.key,
              answerValue: e.value,
            ))
        .toList();

    final success = await ref
        .read(submitQuestionnaireProvider.notifier)
        .submit(
          sessionId: widget.sessionId,
          answers: answers,
          ref: ref,
        );

    if (!mounted) return;

    if (success) {
      final response =
          ref.read(submitQuestionnaireProvider).response;

      // show result dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ResultDialog(
          outcome: response?.outcome ?? 'pass',
          yesCount: response?.totalYesCount ?? 0,
          onDone: () {
            Navigator.pop(context); // close dialog
            context.pop(); // go back to session dashboard
          },
        ),
      );
    }
  }
}

// progress header
class _ProgressHeader extends StatelessWidget {
  final int answered;
  final int total;

  const _ProgressHeader({
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? answered / total : 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$answered of $total questions answered',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// one section with its questions
class _SectionCard extends StatelessWidget {
  final SectionModel section;
  final bool isExpanded;
  final Map<String, bool> answers;
  final VoidCallback onToggle;
  final Function(String questionId, bool value) onAnswer;

  const _SectionCard({
    required this.section,
    required this.isExpanded,
    required this.answers,
    required this.onToggle,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final answeredInSection =
        section.questions.where((q) => answers.containsKey(q.id)).length;
    final allAnswered = answeredInSection == section.questions.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allAnswered ? AppColors.pass : AppColors.border,
          width: allAnswered ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        children: [

          // section header — tappable to expand/collapse
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: allAnswered
                          ? AppColors.passSurface
                          : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      allAnswered
                          ? Icons.check_circle
                          : Icons.assignment_outlined,
                      size: 18,
                      color: allAnswered
                          ? AppColors.pass
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$answeredInSection / ${section.questions.length} answered',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // questions — only shown when expanded
          if (isExpanded) ...[
            const Divider(height: 1),
            ...section.questions.map(
              (question) => _QuestionTile(
                question: question,
                answer: answers[question.id],
                onAnswer: (value) => onAnswer(question.id, value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// one question with YES/NO buttons
class _QuestionTile extends StatelessWidget {
  final QuestionModel question;
  final bool? answer;
  final Function(bool value) onAnswer;

  const _QuestionTile({
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // YES button
              Expanded(
                child: GestureDetector(
                  onTap: () => onAnswer(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: answer == true
                          ? AppColors.refer
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: answer == true
                            ? AppColors.refer
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'YES',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          // YES is red — signals risk
                          color: answer == true
                              ? Colors.white
                              : AppColors.refer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // NO button
              Expanded(
                child: GestureDetector(
                  onTap: () => onAnswer(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: answer == false
                          ? AppColors.pass
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: answer == false
                            ? AppColors.pass
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'NO',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: answer == false
                              ? Colors.white
                              : AppColors.pass,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// result dialog shown after submission
class _ResultDialog extends StatelessWidget {
  final String outcome;
  final int yesCount;
  final VoidCallback onDone;

  const _ResultDialog({
    required this.outcome,
    required this.yesCount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isRefer = outcome == 'refer';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isRefer
                  ? AppColors.referSurface
                  : AppColors.passSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isRefer ? '⚠️' : '✅',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRefer ? 'REFER' : 'PASS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isRefer ? AppColors.refer : AppColors.pass,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRefer
                ? '$yesCount risk factor${yesCount == 1 ? '' : 's'} identified.\nRefer for OAE/AABR diagnosis.'
                : 'No risk factors identified.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRefer ? AppColors.refer : AppColors.pass,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}