import '../domain/infant_model.dart';
import 'infant_remote_datasource.dart';

class InfantRepository {
  final _datasource = InfantRemoteDatasource();

  Future<InfantModel> createInfant(Map<String, dynamic> data) =>
      _datasource.createInfant(data);

  Future<List<InfantModel>> getMyInfants() =>
      _datasource.getMyInfants();

  Future<List<InfantModel>> getInfantsAtMyCenter() =>
      _datasource.getInfantsAtMyCenter();

  Future<InfantModel> getInfantById(String infantId) =>
      _datasource.getInfantById(infantId);
}