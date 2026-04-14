class CasalModel {
  final String id;
  final String? nome;
  final String qrCode;

  CasalModel({
    required this.id,
    this.nome,
    required this.qrCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'qrCode': qrCode,
    };
  }

  factory CasalModel.fromMap(Map<String, dynamic> map) {
    return CasalModel(
      id: map['id'],
      nome: map['nome'],
      qrCode: map['qrCode'],
    );
  }
}
