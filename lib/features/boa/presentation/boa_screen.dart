import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/boa_model.dart';
import '../utils/tone_generator.dart';
import 'boa_provider.dart';

class _Stimulus {
  final int frequencyHz;
  final int intensityDb;
  const _Stimulus({required this.frequencyHz, required this.intensityDb});
}

const List<_Stimulus> _stimulusSequence = [
  _Stimulus(frequencyHz: 500, intensityDb: 65),
  _Stimulus(frequencyHz: 1000, intensityDb: 65),
  _Stimulus(frequencyHz: 2000, intensityDb: 65),
  _Stimulus(frequencyHz: 4000, intensityDb: 65),
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
  // camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraInitialized = false;
  bool _isRecording = false;

  // audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // screening state
  int _currentIndex = 0;
  final List<StimulusResultModel?> _results =
      List.filled(_stimulusSequence.length, null);
  String _step = 'ready'; // ready → playing → recording
  bool? _responseObserved;
  String? _responseType;

  // recorded video paths per stimulus
  final List<String?> _videoClipPaths =
      List.filled(_stimulusSequence.length, null);

  // timer for 6 second playback
  Timer? _playTimer;
  int _secondsRemaining = 6;

  // animation for sound wave
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _waveAnimation =
        Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
          parent: _waveController, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // prefer front camera to see infant's face
      // final frontCamera = _cameras.firstWhere(
      //   (c) => c.lensDirection == CameraLensDirection.front,
      //   orElse: () => _cameras.first,
      // );

      // _cameraController = CameraController(
      //   frontCamera,
      //   ResolutionPreset.medium,
      //   enableAudio: true, // record audio with video
      // );

        final rareCamera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        rareCamera,
        ResolutionPreset.medium,
        enableAudio: true, // record audio with video
      );


      await _cameraController!.initialize();

      if (mounted) setState(() => _cameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _startPlaying() async {
    setState(() {
      _step = 'playing';
      _secondsRemaining = 6;
    });

    // start video recording for this stimulus
    await _startRecording();

    // generate and play the tone
    final stimulus = _stimulusSequence[_currentIndex];
    final toneBytes = ToneGenerator.generateTone(
      frequencyHz: stimulus.frequencyHz,
      durationSeconds: 6,
    );

    // play tone from bytes
    await _audioPlayer.play(BytesSource(toneBytes));

    // countdown timer — updates UI every second
    _playTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _onPlaybackFinished();
      }
    });
  }

  Future<void> _startRecording() async {
    if (_cameraController == null ||
        !_cameraInitialized ||
        _isRecording) return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;
    try {
      final videoFile =
          await _cameraController!.stopVideoRecording();
      _videoClipPaths[_currentIndex] = videoFile.path;
      setState(() => _isRecording = false);
    } catch (e) {
      debugPrint('Recording stop error: $e');
    }
  }

  Future<void> _onPlaybackFinished() async {
    await _audioPlayer.stop();
    await _stopRecording();
    if (mounted) {
      setState(() => _step = 'recording');
    }
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

    _results[_currentIndex] = StimulusResultModel(
      frequencyHz: stimulus.frequencyHz,
      intensityDb: stimulus.intensityDb,
      responseObserved: _responseObserved!,
      responseType: _responseType ?? 'none',
      videoClipUrl: null, //Replaced _videoClipPaths[_currentIndex] to null for phase 1 since we are not uploading videos yet, will integrate in phase 2 with cloudinary
    );

    if (_currentIndex < _stimulusSequence.length - 1) {
      setState(() {
        _currentIndex++;
        _step = 'ready';
        _responseObserved = null;
        _responseType = null;
        _secondsRemaining = 6;
      });
    } else {
      setState(() => _step = 'summary');
    }
  }

  Future<void> _submit() async {
    final validResults =
        _results.whereType<StimulusResultModel>().toList();

    // upload video clips to Cloudinary here in Phase 2
    // for now we just pass the local paths as notes

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
            borderRadius: BorderRadius.circular(20)),
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
                child: Text(isRefer ? '⚠️' : '✅',
                    style: const TextStyle(fontSize: 36)),
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
                  ? 'No response to sound stimuli.\nRefer for clinical diagnosis.'
                  : 'Infant responded to sound stimuli.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
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
  void dispose() {
    _playTimer?.cancel();
    _waveController.dispose();
    _notesController.dispose();
    _audioPlayer.dispose();
    _cameraController?.dispose();
    super.dispose();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          l10n.stimulusProgress(
              _currentIndex + 1, _stimulusSequence.length),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [

          // camera feed — takes most of the screen
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // camera preview
                _cameraInitialized && _cameraController != null
                    ? SizedBox.expand(
                        child: CameraPreview(_cameraController!),
                      )
                    : Container(
                        color: const Color(0xFF1A1A2E),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_outlined,
                                  color: Colors.white38, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Camera initializing...',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),

                // recording indicator — top right
                if (_isRecording)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle,
                              color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'REC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // stimulus info overlay — top left
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${stimulus.frequencyHz} Hz · ${stimulus.intensityDb} dB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // playing overlay — sound wave animation
                if (isPlaying)
                  Center(
                    child: AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _waveAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text('🔊',
                                  style:
                                      TextStyle(fontSize: 32)),
                              Text(
                                '${_secondsRemaining}s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // progress bar at bottom of camera
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) /
                        _stimulusSequence.length,
                    backgroundColor:
                        Colors.white.withOpacity(0.2),
                    color: AppColors.primary,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),

          // bottom panel — controls
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // ready state
                  if (_step == 'ready') ...[
                    Text(
                      'Ready to play stimulus ${_currentIndex + 1}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Place phone 30cm from infant. Ensure room is quiet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _startPlaying,
                        icon: const Icon(Icons.play_arrow_rounded,
                            size: 22),
                        label: Text(
                          'Play ${stimulus.frequencyHz} Hz Sound',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],

                  // playing state
                  if (_step == 'playing') ...[
                    Text(
                      l10n.playingSound,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Watch the infant carefully...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // countdown
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        final filled = i < (6 - _secondsRemaining);
                        return Container(
                          width: 32,
                          height: 8,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 2),
                          decoration: BoxDecoration(
                            color: filled
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_secondsRemaining seconds remaining',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  // recording state — response input
                  if (_step == 'recording') ...[
                    Text(
                      l10n.didInfantRespond,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _recordResponse(true),
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: _responseObserved == true
                                    ? AppColors.pass
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.pass,
                                  width:
                                      _responseObserved == true
                                          ? 2
                                          : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text('👍',
                                      style: TextStyle(
                                          fontSize: 24)),
                                  Text(
                                    l10n.yes,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w700,
                                      color:
                                          _responseObserved ==
                                                  true
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
                              duration: const Duration(
                                  milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: _responseObserved == false
                                    ? AppColors.refer
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.refer,
                                  width:
                                      _responseObserved == false
                                          ? 2
                                          : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text('👎',
                                      style: TextStyle(
                                          fontSize: 24)),
                                  Text(
                                    l10n.no,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w700,
                                      color:
                                          _responseObserved ==
                                                  false
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

                    // response type chips
                    if (_responseObserved == true) ...[
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _responseTypeLabels.entries
                              .where((e) => e.key != 'none')
                              .map((e) => GestureDetector(
                                    onTap: () =>
                                        _selectResponseType(
                                            e.key),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      margin:
                                          const EdgeInsets.only(
                                              right: 8),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            _responseType == e.key
                                                ? AppColors.primary
                                                : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(
                                                20),
                                        border: Border.all(
                                          color:
                                              _responseType == e.key
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
                                                    e.key] ??
                                                '',
                                            style: const TextStyle(
                                                fontSize: 14),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            e.value,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  _responseType ==
                                                          e.key
                                                      ? Colors.white
                                                      : AppColors
                                                          .textPrimary,
                                              fontWeight:
                                                  _responseType ==
                                                          e.key
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
                      ),
                    ],

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
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
                          style:
                              const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // video clips info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_videoClipPaths.where((p) => p != null).length} video clip${_videoClipPaths.where((p) => p != null).length == 1 ? '' : 's'} recorded for ML training',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // stimulus results
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
                      color: AppColors.border, width: 0.5),
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
                          style:
                              const TextStyle(fontSize: 18),
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
                    // video clip indicator
                    if (_videoClipPaths[i] != null)
                      const Icon(Icons.videocam,
                          color: AppColors.primary, size: 16),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. infant was sleepy',
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
                        style:
                            const TextStyle(fontSize: 15),
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