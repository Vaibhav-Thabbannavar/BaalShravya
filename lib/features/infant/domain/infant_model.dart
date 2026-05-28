class InfantModel {
  final String id;
  final String parentId;
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? birthWeightKg;
  final String? deliveryType;
  final String? createdAt;

  const InfantModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.birthWeightKg,
    this.deliveryType,
    this.createdAt,
  });

  factory InfantModel.fromJson(Map<String, dynamic> json) {
    return InfantModel(
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      // API returns date as "2024-06-15T00:00:00.000Z"
      // we take only the date part
      dateOfBirth: json['date_of_birth'].toString().split('T')[0],
      gender: json['gender'],
      birthWeightKg: json['birth_weight_kg'] != null
          ? double.parse(json['birth_weight_kg'].toString())
          : null,
      deliveryType: json['delivery_type'],
      createdAt: json['created_at'],
    );
  }

  // calculates age in months from date of birth
  int get ageInMonths {
    final dob = DateTime.parse(dateOfBirth);
    final now = DateTime.now();
    return (now.year - dob.year) * 12 + (now.month - dob.month);
  }

  // formatted age string like "3 months" or "1 year 2 months"
  String get ageString {
    final months = ageInMonths;
    if (months < 12) return '$months month${months == 1 ? '' : 's'}';
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years year${years == 1 ? '' : 's'} $remaining month${remaining == 1 ? '' : 's'}';
  }
}