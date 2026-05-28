class AnmStatsModel {
  final int totalScreenings;
  final int totalPass;
  final int totalRefer;
  final int inProgress;
  final List<CaseItemModel> caseList;

  const AnmStatsModel({
    required this.totalScreenings,
    required this.totalPass,
    required this.totalRefer,
    required this.inProgress,
    required this.caseList,
  });

  factory AnmStatsModel.fromJson(Map<String, dynamic> json) {
    return AnmStatsModel(
      totalScreenings: json['total_screenings'] ?? 0,
      totalPass: json['total_pass'] ?? 0,
      totalRefer: json['total_refer'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      caseList: (json['case_list'] as List<dynamic>? ?? [])
          .map((e) => CaseItemModel.fromJson(e))
          .toList(),
    );
  }
}

class CaseItemModel {
  final String sessionId;
  final String infantName;
  final String parentName;
  final String parentPhone;
  final String sessionDate;
  final String status;
  final String? outcome;

  const CaseItemModel({
    required this.sessionId,
    required this.infantName,
    required this.parentName,
    required this.parentPhone,
    required this.sessionDate,
    required this.status,
    this.outcome,
  });

  factory CaseItemModel.fromJson(Map<String, dynamic> json) {
    return CaseItemModel(
      sessionId: json['session_id'],
      infantName: json['infant_name'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      sessionDate: json['session_date'],
      status: json['status'],
      outcome: json['outcome'],
    );
  }
}

class AdminStatsModel {
  final int totalScreenings;
  final int totalPass;
  final int totalRefer;
  final int totalAnms;
  final int totalParents;
  final int totalInfants;
  final List<DistrictStatModel> byDistrict;

  const AdminStatsModel({
    required this.totalScreenings,
    required this.totalPass,
    required this.totalRefer,
    required this.totalAnms,
    required this.totalParents,
    required this.totalInfants,
    required this.byDistrict,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalScreenings: json['total_screenings'] ?? 0,
      totalPass: json['total_pass'] ?? 0,
      totalRefer: json['total_refer'] ?? 0,
      totalAnms: json['total_anms'] ?? 0,
      totalParents: json['total_parents'] ?? 0,
      totalInfants: json['total_infants'] ?? 0,
      byDistrict: (json['by_district'] as List<dynamic>? ?? [])
          .map((e) => DistrictStatModel.fromJson(e))
          .toList(),
    );
  }
}

class DistrictStatModel {
  final String districtName;
  final int totalScreenings;
  final int totalPass;
  final int totalRefer;

  const DistrictStatModel({
    required this.districtName,
    required this.totalScreenings,
    required this.totalPass,
    required this.totalRefer,
  });

  factory DistrictStatModel.fromJson(Map<String, dynamic> json) {
    return DistrictStatModel(
      districtName: json['district_name'],
      totalScreenings: int.parse(json['total_screenings'].toString()),
      totalPass: int.parse(json['total_pass'].toString()),
      totalRefer: int.parse(json['total_refer'].toString()),
    );
  }
}