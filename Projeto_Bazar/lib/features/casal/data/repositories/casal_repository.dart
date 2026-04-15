import 'package:uuid/uuid.dart';
import '../../../../shared/models/casal_model.dart';
import '../services/casal_remote_service.dart';

class CasalRepository {
  final CasalRemoteService _remoteService;
  final _uuid = const Uuid();

  CasalRepository(this._remoteService);

  Future<List<CasalModel>> getCasais() async {
    return await _remoteService.getCasais();
  }

  Future<CasalModel> createCasal(String nome) async {
    final id = _uuid.v4();
    final casal = CasalModel(
      id: id,
      nome: nome,
      qrCode: id, // O QR Code contém o ID único
    );

    await _remoteService.createCasal(casal);
    return casal;
  }

  Future<void> deleteCasal(String id) async {
    await _remoteService.deleteCasal(id);
  }
}
