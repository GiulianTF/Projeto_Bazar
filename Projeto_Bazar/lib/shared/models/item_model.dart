import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String comandaId;
  final String descricao;
  final double valor;
  final int quantidade;
  final DateTime dataHora;

  ItemModel({
    required this.id,
    required this.comandaId,
    required this.descricao,
    required this.valor,
    required this.quantidade,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comandaId': comandaId,
      'descricao': descricao,
      'valor': valor,
      'quantidade': quantidade,
      'dataHora': Timestamp.fromDate(dataHora),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      comandaId: map['comandaId'],
      descricao: map['descricao'],
      valor: map['valor'],
      quantidade: map['quantidade'],
      dataHora: map['dataHora'] is Timestamp 
          ? (map['dataHora'] as Timestamp).toDate() 
          : DateTime.parse(map['dataHora'].toString()),
    );
  }
}
