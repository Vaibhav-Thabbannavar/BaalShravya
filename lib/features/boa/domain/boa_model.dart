class StimulusResultModel {
  final int frequencyHz;
  final int intensityDb;
  final bool responseObserved;
  final String? responseType;
  final String? videoClipUrl;

  const StimulusResultModel({
    required this.frequencyHz,
    required this.intensityDb,
    required this.responseObserved,
    this.responseType,
    this.videoClipUrl,
  });

  Map<String, dynamic> toJson() => {
        'frequency_hz': frequencyHz,
        'intensity_db': intensityDb,
        'response_observed': responseObserved,
        'response_type': responseType,
        if (videoClipUrl != null) 'video_clip_url': videoClipUrl,
      };
}

class BoaScreeningModel {
  final String id;
  final String sessionId;
  final String boaOutcome;
  final String? notes;
  final String? videoUrl;
  final String? conductedByName;
  final List<StimulusResultModel> stimulusResults;
  final String? createdAt;

  const BoaScreeningModel({
    required this.id,
    required this.sessionId,
    required this.boaOutcome,
    this.notes,
    this.videoUrl,
    this.conductedByName,
    required this.stimulusResults,
    this.createdAt,
  });

  factory BoaScreeningModel.fromJson(Map<String, dynamic> json) {
    return BoaScreeningModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      boaOutcome: json['boa_outcome']?.toString() ?? '',
      notes: json['notes']?.toString(),
      videoUrl: json['video_url']?.toString(),
      conductedByName: json['conducted_by_name']?.toString(),
      stimulusResults: (json['stimulus_results'] as List<dynamic>? ?? [])
          .map((e) => StimulusResultModel(
                frequencyHz: e['frequency_hz'] ?? 0,
                intensityDb: e['intensity_db'] ?? 0,
                responseObserved: e['response_observed'] ?? false,
                responseType: e['response_type']?.toString(),
                videoClipUrl: e['video_clip_url']?.toString(),
              ))
          .toList(),
      createdAt: json['created_at']?.toString(),
    );
  }

  bool get isPassed => boaOutcome == 'pass';
  bool get isReferred => boaOutcome == 'refer';
}