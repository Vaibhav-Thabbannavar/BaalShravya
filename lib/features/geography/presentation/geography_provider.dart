import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/geography_remote_datasource.dart';
import '../domain/geography_model.dart';

final _datasource = GeographyRemoteDatasource();

final districtsProvider =
    FutureProvider<List<DistrictModel>>((ref) async {
  return await _datasource.getDistricts();
});

// family provider — takes districtId as parameter
final healthCentersProvider =
    FutureProvider.family<List<HealthCenterModel>, String>(
        (ref, districtId) async {
  return await _datasource.getHealthCenters(districtId);
});