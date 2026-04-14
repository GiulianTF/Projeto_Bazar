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
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory PagamentoModel.fromMap(Map<String, dynamic> map) {
    return PagamentoModel(
      id: map['id'],
      comandaId: map['comandaId'],
      valor: map['valor'],
      dataHora: DateTime.parse(map['dataHora']),
    );
  }
}
