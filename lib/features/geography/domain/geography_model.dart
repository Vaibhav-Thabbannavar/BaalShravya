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
      id: json['id'],
      name: json['name'],
      state: json['state'],
    );
  }
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
      id: json['id'],
      districtId: json['district_id'],
      name: json['name'],
      address: json['address'],
    );
  }
}