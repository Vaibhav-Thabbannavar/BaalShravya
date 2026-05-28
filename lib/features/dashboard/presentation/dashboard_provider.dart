import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_remote_datasource.dart';
import '../domain/dashboard_model.dart';

final _datasource = DashboardRemoteDatasource();

// ANM dashboard — FutureProvider fetches data once
// and caches it until invalidated
final anmDashboardProvider = FutureProvider<AnmStatsModel>((ref) async {
  return await _datasource.getAnmStats();
});

final adminDashboardProvider = FutureProvider<AdminStatsModel>((ref) async {
  return await _datasource.getAdminStats();
});