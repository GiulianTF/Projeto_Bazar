import 'comanda_status.dart';
import 'item_model.dart';

class ComandaModel {
  final String id;
  final String coupleId;
  final double total;
  final ComandaStatus status;
  final List<ItemModel> itens;

  ComandaModel({
    required this.id,
    required this.coupleId,
    this.total = 0.0,
    this.status = ComandaStatus.aberta,
    this.itens = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coupleId': coupleId,
      'total': total,
      'status': status.toMap(),
    };
  }

  factory ComandaModel.fromMap(Map<String, dynamic> map, {List<ItemModel> itens = const []}) {
    return ComandaModel(
      id: map['id'],
      coupleId: map['coupleId'],
      total: map['total'],
      status: ComandaStatus.fromMap(map['status']),
      itens: itens,
    );
  }

  ComandaModel copyWith({
    String? id,
    String? coupleId,
    double? total,
    ComandaStatus? status,
    List<ItemModel>? itens,
  }) {
    return ComandaModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      total: total ?? this.total,
      status: status ?? this.status,
      itens: itens ?? this.itens,
    );
  }
}
