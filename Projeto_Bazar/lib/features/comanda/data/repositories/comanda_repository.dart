import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../shared/models/comanda_model.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/models/pagamento_model.dart';
import '../../../../shared/models/comanda_status.dart';
import '../services/comanda_remote_service.dart';

class ComandaRepository {
  final ComandaRemoteService _remoteService;
  final _uuid = const Uuid();

  ComandaRepository(this._remoteService);

  Future<ComandaModel> getOrCreateComanda(String coupleId) async {
    var comanda = await _remoteService.getComandaAtivaPorCasal(coupleId);
    if (comanda == null) {
      comanda = ComandaModel(
        id: _uuid.v4(),
        coupleId: coupleId,
        total: 0.0,
        status: ComandaStatus.aberta,
        itens: [],
        pagamentos: [],
      );
      await _remoteService.createComanda(comanda);
    }
    return comanda;
  }

  Stream<ComandaModel?> obterComandaAtivaStream(String coupleId) {
    // 1. Ouvir a comanda ativa
    return _remoteService.getComandaStream(coupleId).switchMap((comanda) {
      if (comanda == null) return Stream.value(null);

      // 2. Se a comanda existe, ouvir seus itens e pagamentos em tempo real
      return Rx.combineLatest2(
        _remoteService.getItensStream(comanda.id),
        _remoteService.getPagamentosStream(comanda.id),
        (itens, pagamentos) {
          return comanda.copyWith(
            itens: itens,
            pagamentos: pagamentos,
          );
        },
      );
    });
  }

  Future<ComandaModel> addItem(ComandaModel comanda, String descricao, double valor, int quantidade) async {
    if (comanda.status == ComandaStatus.paga) {
      throw Exception('Não é possível adicionar itens em uma comanda encerrada.');
    }

    final item = ItemModel(
      id: _uuid.v4(),
      comandaId: comanda.id,
      descricao: descricao,
      valor: valor,
      quantidade: quantidade,
      dataHora: DateTime.now(),
    );

    await _remoteService.saveItem(item);

    final updatedItens = List<ItemModel>.from(comanda.itens)..insert(0, item);
    final updatedComanda = comanda.copyWith(itens: updatedItens);
    await _remoteService.updateComanda(updatedComanda);

    return updatedComanda;
  }

  Future<ComandaModel> addPagamento(ComandaModel comanda, double valor) async {
    if (comanda.status == ComandaStatus.paga) {
      throw Exception('Comanda já está encerrada.');
    }

    final pagamento = PagamentoModel(
      id: _uuid.v4(),
      comandaId: comanda.id,
      valor: valor,
      dataHora: DateTime.now(),
    );

    await _remoteService.savePagamento(pagamento);

    final updatedPagamentos = List<PagamentoModel>.from(comanda.pagamentos)..insert(0, pagamento);
    final updatedComanda = comanda.copyWith(pagamentos: updatedPagamentos);
    await _remoteService.updateComanda(updatedComanda);

    return updatedComanda;
  }
}
