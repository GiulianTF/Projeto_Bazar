import 'comanda_status.dart';
import 'item_model.dart';
import 'pagamento_model.dart';

class ComandaModel {
  final String id;
  final String coupleId;
  final double total;
  final ComandaStatus status;
  final List<ItemModel> itens;
  final List<PagamentoModel> pagamentos;

  ComandaModel({
    required this.id,
    required this.coupleId,
    this.total = 0.0,
    this.status = ComandaStatus.aberta,
    this.itens = const [],
    this.pagamentos = const [],
  });

  double get totalConsumido {
    return itens.fold(0.0, (sum, item) => sum + (item.valor * item.quantidade));
  }

  double get totalPago {
    return pagamentos.fold(0.0, (sum, p) => sum + p.valor);
  }

  double get saldoDevedor {
    return totalConsumido - totalPago;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coupleId': coupleId,
      'total': totalConsumido, 
      'status': status.toMap(),
    };
  }

  factory ComandaModel.fromMap(Map<String, dynamic> map, {List<ItemModel> itens = const [], List<PagamentoModel> pagamentos = const []}) {
    return ComandaModel(
      id: map['id'],
      coupleId: map['coupleId'],
      total: map['total'],
      status: ComandaStatus.fromMap(map['status']),
      itens: itens,
      pagamentos: pagamentos,
    );
  }

  ComandaModel copyWith({
    String? id,
    String? coupleId,
    double? total,
    ComandaStatus? status,
    List<ItemModel>? itens,
    List<PagamentoModel>? pagamentos,
  }) {
    return ComandaModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      total: total ?? this.total,
      status: status ?? this.status,
      itens: itens ?? this.itens,
      pagamentos: pagamentos ?? this.pagamentos,
    );
  }
}
