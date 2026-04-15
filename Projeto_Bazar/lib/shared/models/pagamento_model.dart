import 'package:cloud_firestore/cloud_firestore.dart';

class PagamentoModel {
  final String id;
  final String comandaId;
  final double valor;
  final DateTime dataHora;

  PagamentoModel({
    required this.id,
    required this.comandaId,
    required this.valor,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comandaId': comandaId,
      'valor': valor,
      'dataHora': Timestamp.fromDate(dataHora),
    };
  }

  factory PagamentoModel.fromMap(Map<String, dynamic> map) {
    return PagamentoModel(
      id: map['id'],
      comandaId: map['comandaId'],
      valor: map['valor'],
      dataHora: map['dataHora'] is Timestamp 
          ? (map['dataHora'] as Timestamp).toDate() 
          : DateTime.parse(map['dataHora'].toString()),
    );
  }
}
