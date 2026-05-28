import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/boa_model.dart';
import 'boa_provider.dart';

// the fixed stimulus sequence
// 4 frequencies × 1 intensity level = 4 stimuli
class _Stimulus {
  final int frequencyHz;
  final int intensityDb;

  const _Stimulus({
    required this.frequencyHz,
    required this.intensityDb,
  });
}

const List<_Stimulus> _stimulusSequence = [
  _Stimulus(frequencyHz: 500, intensityDb: 65),
  _Stimulus(frequencyHz: 1000, intensityDb: 65),
  _Stimulus(frequencyHz: 2000, intensityDb: 65),
  _Stimulus(frequencyHz: 4000, intensityDb: 65),
];

const List<String> _responseTypes = [
  'startle',
  'eye_blink',
  'head_turn',
  'arousal',
  'none',
];

const Map<String, String> _responseTypeLabels = {
  'startle': 'Startle',
  'eye_blink': 'Eye Blink',
  'head_turn': 'Head Turn',
  'arousal': 'Arousal',
  'none': 'No Response',
};

const Map<String, String> _responseTypeEmojis = {
  'startle': '😮',
  'eye_blink': '👁️',
  'head_turn': '↩️',
  'arousal': '😯',
  'none': '😐',
};

class BoaScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const BoaScreen({super.key, required this.sessionId});

  @override
  ConsumerState<BoaScreen> createState() => _BoaScreenState();
}

class _BoaScreenState extends ConsumerState<BoaScreen>
    with TickerProviderStateMixin {
  // current stimulus index
  int _currentIndex = 0;

  // stored results for each stimulus
  final List<StimulusResultModel?> _results =
      List.filled(_stimulusSequence.length, null);

  // current step — 'ready', 'playing', 'recording'
  String _step = 'ready';

  // selected response for current stimulus
  bool? _responseObserved;
  String? _responseType;

  // animation controller for sound wave
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  // notes controller
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startPlaying() {
    setState(() => _step = 'playing');
    // simulate sound playing for 3 seconds
    // in Phase 2 this will use audioplayers package
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _step = 'recording');
    });
  }

  void _recordResponse(bool observed) {
    setState(() {
      _responseObserved = observed;
      if (!observed) _responseType = 'none';
    });
  }

  void _selectResponseType(String type) {
    setState(() => _responseType = type);
  }

  void _saveAndNext() {
    if (_responseObserved == null) return;
    if (_responseObserved! && _responseType == null) return;

    final stimulus = _stimulusSequence[_currentIndex];

    // save result for this stimulus
    _results[_currentIndex] = StimulusResultModel(
      frequencyHz: stimulus.frequencyHz,
      intensityDb: stimulus.intensityDb,
      responseObserved: _responseObserved!,
      responseType: _responseType ?? 'none',
    );

    if (_currentIndex < _stimulusSequence.length - 1) {
      // move to next stimulus
      setState(() {
        _currentIndex++;
        _step = 'ready';
        _responseObserved = null;
        _responseType = null;
      });
    } else {
      // all stimuli done — show summary
      setState(() => _step = 'summary');
    }
  }

  Future<void> _submit() async {
    final validResults =
        _results.whereType<StimulusResultModel>().toList();

    final success = await ref
        .read(submitBoaProvider.notifier)
        .submit(
          sessionId: widget.sessionId,
          stimulusResults: validResults,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          ref: ref,
        );

    if (!mounted) return;

    if (success) {
      final result = ref.read(submitBoaProvider).result;
      _showResultDialog(result!.boaOutcome);
    } else {
      final error = ref.read(submitBoaProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to submit BOA'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showResultDialog(String outcome) {
    final isRefer = outcome == 'refer';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
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
                  ? 'No response observed to any stimulus.\nRefer for clinical diagnosis.'
                  : 'Infant responded to sound stimuli.',
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
                onPressed: () {
                  Navigator.pop(context);
                  context.pop(); // back to session dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isRefer ? AppColors.refer : AppColors.pass,
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final submitState = ref.watch(submitBoaProvider);

    if (_step == 'summary') {
      return _buildSummaryScreen(l10n, submitState);
    }

    return _buildStimulusScreen(l10n);
  }

  Widget _buildStimulusScreen(AppLocalizations l10n) {
    final stimulus = _stimulusSequence[_currentIndex];
    final isPlaying = _step == 'playing';
    final isRecording = _step == 'recording';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.boaTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [

          // progress indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.stimulusProgress(
                          _currentIndex + 1,
                          _stimulusSequence.length),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${((_currentIndex + 1) / _stimulusSequence.length * 100).round()}%',
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
                    value: (_currentIndex + 1) /
                        _stimulusSequence.length,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // stimulus info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? AppColors.primarySurface
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPlaying
                            ? AppColors.primary
                            : AppColors.border,
                        width: isPlaying ? 2 : 0.5,
                      ),
                    ),
                    child: Column(
                      children: [

                        // animated sound wave when playing
                        AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isPlaying
                                  ? _waveAnimation.value
                                  : 1.0,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? AppColors.primary
                                      : AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '🔊',
                                    style:
                                        TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        Text(
                          isPlaying
                              ? l10n.playingSound
                              : 'Ready to play',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isPlaying
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // frequency and intensity
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            _StimTag(
                                label: l10n.hz(stimulus.frequencyHz)),
                            const SizedBox(width: 8),
                            _StimTag(
                                label: l10n.db(stimulus.intensityDb)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // camera feed placeholder
                  // Phase 2 — replace with actual camera widget
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_outlined,
                                  color: Colors.white54, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Camera feed\n(Phase 2)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // recording indicator
                        if (isPlaying || isRecording)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'REC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ready state — play button
                  if (_step == 'ready')
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _startPlaying,
                        icon: const Icon(Icons.play_arrow_rounded,
                            size: 24),
                        label: const Text(
                          'Play Sound',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),

                  // playing state — waiting
                  if (_step == 'playing')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Playing for 3 seconds...',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // recording state — record response
                  if (_step == 'recording') ...[
                    Text(
                      l10n.didInfantRespond,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _recordResponse(true),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              decoration: BoxDecoration(
                                color: _responseObserved == true
                                    ? AppColors.pass
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.pass,
                                  width: _responseObserved == true
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '👍',
                                    style: const TextStyle(
                                        fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.yes,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          _responseObserved == true
                                              ? Colors.white
                                              : AppColors.pass,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _recordResponse(false),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              decoration: BoxDecoration(
                                color: _responseObserved == false
                                    ? AppColors.refer
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.refer,
                                  width: _responseObserved == false
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '👎',
                                    style: const TextStyle(
                                        fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.no,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          _responseObserved == false
                                              ? Colors.white
                                              : AppColors.refer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // response type — only shown when YES
                    if (_responseObserved == true) ...[
                      const SizedBox(height: 16),
                      Text(
                        'What type of response?',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _responseTypes
                            .where((t) => t != 'none')
                            .map((type) => GestureDetector(
                                  onTap: () =>
                                      _selectResponseType(type),
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 150),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _responseType == type
                                          ? AppColors.primary
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _responseType == type
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Text(
                                          _responseTypeEmojis[
                                                  type] ??
                                              '',
                                          style: const TextStyle(
                                              fontSize: 14),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _responseTypeLabels[
                                                  type] ??
                                              type,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                _responseType ==
                                                        type
                                                    ? Colors.white
                                                    : AppColors
                                                        .textPrimary,
                                            fontWeight:
                                                _responseType ==
                                                        type
                                                    ? FontWeight.w600
                                                    : FontWeight
                                                        .normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // next button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_responseObserved != null &&
                                (_responseObserved == false ||
                                    _responseType != null))
                            ? _saveAndNext
                            : null,
                        child: Text(
                          _currentIndex < _stimulusSequence.length - 1
                              ? 'Next Stimulus →'
                              : 'View Summary',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryScreen(
      AppLocalizations l10n, SubmitBoaState submitState) {
    // calculate outcome locally for preview
    final anyResponse = _results
        .whereType<StimulusResultModel>()
        .any((r) => r.responseObserved);
    final previewOutcome = anyResponse ? 'pass' : 'refer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BOA Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() {
            _currentIndex = _stimulusSequence.length - 1;
            _step = 'recording';
          }),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // outcome preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: previewOutcome == 'pass'
                    ? AppColors.passSurface
                    : AppColors.referSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: previewOutcome == 'pass'
                      ? AppColors.pass
                      : AppColors.refer,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    previewOutcome == 'pass' ? '✅' : '⚠️',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    previewOutcome == 'pass' ? 'PASS' : 'REFER',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: previewOutcome == 'pass'
                          ? AppColors.pass
                          : AppColors.refer,
                    ),
                  ),
                  Text(
                    previewOutcome == 'pass'
                        ? 'Infant responded to sound stimuli'
                        : 'No response — refer for diagnosis',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // stimulus results table
            const Text(
              'Stimulus Results',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // results list
            ...List.generate(_results.length, (i) {
              final result = _results[i];
              final stimulus = _stimulusSequence[i];
              if (result == null) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: result.responseObserved
                            ? AppColors.passSurface
                            : AppColors.referSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          result.responseObserved ? '✅' : '❌',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stimulus.frequencyHz} Hz · ${stimulus.intensityDb} dB',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            result.responseObserved
                                ? _responseTypeLabels[
                                        result.responseType] ??
                                    ''
                                : 'No response',
                            style: TextStyle(
                              fontSize: 12,
                              color: result.responseObserved
                                  ? AppColors.pass
                                  : AppColors.refer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // optional notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. infant was sleepy during testing',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

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
                      color: AppColors.refer, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    submitState.isLoading ? null : _submit,
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
                        l10n.submitBoa,
                        style: const TextStyle(fontSize: 15),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StimTag extends StatelessWidget {
  final String label;

  const _StimTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}