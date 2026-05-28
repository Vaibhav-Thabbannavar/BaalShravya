class ScreeningSessionModel {
  final String id;
  final String infantId;
  final String anmId;
  final String sessionDate;
  final String status;
  final String? outcome;
  final String? infantName;
  final String? anmName;
  final String? parentName;
  final String? referralType;
  final String? referralNotes;
  final String? reportId;
  final String? createdAt;

  const ScreeningSessionModel({
    required this.id,
    required this.infantId,
    required this.anmId,
    required this.sessionDate,
    required this.status,
    this.outcome,
    this.infantName,
    this.anmName,
    this.parentName,
    this.referralType,
    this.referralNotes,
    this.reportId,
    this.createdAt,
  });

  factory ScreeningSessionModel.fromJson(Map<String, dynamic> json) {
    return ScreeningSessionModel(
      id: json['id']?.toString() ?? '',
      infantId: json['infant_id']?.toString() ?? '',
      anmId: json['anm_id']?.toString() ?? '',
      sessionDate: json['session_date']?.toString().split('T')[0] ?? '',
      status: json['status']?.toString() ?? '',
      outcome: json['outcome']?.toString(),
      infantName: json['infant_name']?.toString(),
      anmName: json['anm_name']?.toString(),
      parentName: json['parent_name']?.toString(),
      referralType: json['referral_type']?.toString(),
      referralNotes: json['notes']?.toString(),
      reportId: json['report_id']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isPassed => outcome == 'pass';
  bool get isReferred => outcome == 'refer';
}