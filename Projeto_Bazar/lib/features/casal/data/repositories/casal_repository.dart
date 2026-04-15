import 'package:uuid/uuid.dart';
import '../../../../shared/models/casal_model.dart';
import '../services/casal_remote_service.dart';
import '../../../comanda/data/services/comanda_remote_service.dart';

class CasalRepository {
  final CasalRemoteService _remoteService;
  final ComandaRemoteService _comandaRemoteService;
  final _uuid = const Uuid();

  CasalRepository(this._remoteService, this._comandaRemoteService);

  Future<List<CasalModel>> getCasais() async {
    return await _remoteService.getCasais();
  }

  Future<CasalModel?> getCasalById(String id) async {
    return await _remoteService.getCasalById(id);
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
    // 1. Deletar todos os dados associados (Comandas, Itens, Pagamentos)
    await _comandaRemoteService.deleteAllDataByCasal(id);
    // 2. Deletar o casal
    await _remoteService.deleteCasal(id);
  }
}
