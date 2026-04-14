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
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      comandaId: map['comandaId'],
      descricao: map['descricao'],
      valor: map['valor'],
      quantidade: map['quantidade'],
      dataHora: DateTime.parse(map['dataHora']),
    );
  }
}
