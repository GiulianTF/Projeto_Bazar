import 'package:uuid/uuid.dart';
import '../../../../shared/models/comanda_model.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/models/comanda_status.dart';
import '../services/comanda_local_service.dart';

class ComandaRepository {
  final ComandaLocalService _localService;
  final _uuid = const Uuid();

  ComandaRepository(this._localService);

  Future<ComandaModel> getOrCreateComanda(String coupleId) async {
    var comanda = await _localService.getComandaAtivaPorCasal(coupleId);
    if (comanda == null) {
      comanda = ComandaModel(
        id: _uuid.v4(),
        coupleId: coupleId,
        total: 0.0,
        status: ComandaStatus.aberta,
        itens: [],
      );
      await _localService.createComanda(comanda);
    }
    return comanda;
  }

  Future<ComandaModel> addItem(ComandaModel comanda, String descricao, double valor, int quantidade) async {
    if (comanda.status == ComandaStatus.paga) {
      throw Exception('Não é possível adicionar itens em uma comanda paga.');
    }

    final item = ItemModel(
      id: _uuid.v4(),
      comandaId: comanda.id,
      descricao: descricao,
      valor: valor,
      quantidade: quantidade,
      dataHora: DateTime.now(),
    );

    await _localService.saveItem(item);

    final updatedItens = List<ItemModel>.from(comanda.itens)..insert(0, item);
    final updatedTotal = comanda.total + (valor * quantidade);

    final updatedComanda = comanda.copyWith(itens: updatedItens, total: updatedTotal);
    await _localService.updateComanda(updatedComanda);

    return updatedComanda;
  }

  Future<ComandaModel> fecharComanda(ComandaModel comanda) async {
    final updatedComanda = comanda.copyWith(status: ComandaStatus.fechada);
    await _localService.updateComanda(updatedComanda);
    return updatedComanda;
  }

  Future<ComandaModel> pagarComanda(ComandaModel comanda) async {
    final updatedComanda = comanda.copyWith(status: ComandaStatus.paga);
    await _localService.updateComanda(updatedComanda);
    return updatedComanda;
  }
}
