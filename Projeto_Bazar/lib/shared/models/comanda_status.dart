enum ComandaStatus {
  aberta,
  fechada,
  paga;

  String toMap() => name;
  static ComandaStatus fromMap(String status) => values.firstWhere((e) => e.name == status);
}
