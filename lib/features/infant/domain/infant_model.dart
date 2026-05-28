class InfantModel {
  final String id;
  final String? parentId;      // nullable — not always returned by API
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? birthWeightKg;
  final String? deliveryType;
  final String? parentName;    // add this — returned by some endpoints
  final String? parentPhone;   // add this — returned by some endpoints
  final String? createdAt;

  const InfantModel({
    required this.id,
    this.parentId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.birthWeightKg,
    this.deliveryType,
    this.parentName,
    this.parentPhone,
    this.createdAt,
  });

  factory InfantModel.fromJson(Map<String, dynamic> json) {
    return InfantModel(
      id: json['id']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      name: json['name']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString().split('T')[0] ?? '',
      gender: json['gender']?.toString() ?? '',
      birthWeightKg: json['birth_weight_kg'] != null
          ? double.tryParse(json['birth_weight_kg'].toString())
          : null,
      deliveryType: json['delivery_type']?.toString(),
      parentName: json['parent_name']?.toString(),
      parentPhone: json['parent_phone']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  int get ageInMonths {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      return (now.year - dob.year) * 12 + (now.month - dob.month);
    } catch (_) {
      return 0;
    }
  }

  String get ageString {
    final months = ageInMonths;
    if (months < 12) return '$months month${months == 1 ? '' : 's'}';
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years year${years == 1 ? '' : 's'} $remaining month${remaining == 1 ? '' : 's'}';
  }
}