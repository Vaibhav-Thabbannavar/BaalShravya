import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/api_helper.dart';
import '../domain/infant_model.dart';

class InfantRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  // parent calls this — server derives parent_id from token
  // ANM calls this with parent_id in body
  Future<InfantModel> createInfant(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.infants, data: data);
      return InfantModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // parent sees their own infants
  Future<List<InfantModel>> getMyInfants() async {
    try {
      final response = await _dio.get(ApiEndpoints.myInfants);
      final List data = response.data['data'];
      return data.map((e) => InfantModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ANM sees infants in their health center
  Future<List<InfantModel>> getInfantsAtMyCenter() async {
    try {
      final response = await _dio.get(ApiEndpoints.myCenter);
      final List data = response.data['data'];
      return data.map((e) => InfantModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // get single infant by id
  Future<InfantModel> getInfantById(String infantId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.infantById(infantId));
      return InfantModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}