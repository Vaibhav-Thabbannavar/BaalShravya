class DistrictModel {
  final String id;
  final String name;
  final String state;

  const DistrictModel({
    required this.id,
    required this.name,
    required this.state,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }

  // needed for DropdownMenuItem value comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class HealthCenterModel {
  final String id;
  final String districtId;
  final String name;
  final String? address;

  const HealthCenterModel({
    required this.id,
    required this.districtId,
    required this.name,
    this.address,
  });

  factory HealthCenterModel.fromJson(Map<String, dynamic> json) {
    return HealthCenterModel(
      id: json['id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthCenterModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}