import 'package:flutter/foundation.dart';
import '../../../../shared/models/casal_model.dart';
import '../../data/repositories/casal_repository.dart';
import '../../../comanda/data/repositories/comanda_repository.dart';

class CasalManagementViewModel extends ChangeNotifier {
  final CasalRepository _repository;
  final ComandaRepository _comandaRepository;
  
  List<CasalModel> _casais = [];
  Map<String, double> _saldos = {}; // coupleId -> saldo
  bool _isLoading = false;
  String? _errorMessage;

  CasalManagementViewModel(this._repository, this._comandaRepository);

  List<CasalModel> get casais => _casais;
  double getSaldo(String coupleId) => _saldos[coupleId] ?? 0.0;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCasais() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _casais = await _repository.getCasais();
      
      // Busca os saldos em paralelo para cada casal
      final saldoFutures = _casais.map((c) => _comandaRepository.getOrCreateComanda(c.id));
      final comandas = await Future.wait(saldoFutures);
      
      _saldos = {
        for (var comanda in comandas) comanda.coupleId: comanda.saldoDevedor
      };
    } catch (e) {
      _errorMessage = 'Falha ao carregar casais e saldos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCasal(String nome) async {
    if (nome.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final novoCasal = await _repository.createCasal(nome);
      _casais.add(novoCasal);
      _casais.sort((a, b) => (a.nome ?? '').compareTo(b.nome ?? ''));
      
      // Inicializa saldo para o novo casal
      final comanda = await _comandaRepository.getOrCreateComanda(novoCasal.id);
      _saldos[novoCasal.id] = comanda.saldoDevedor;
    } catch (e) {
      _errorMessage = 'Falha ao criar casal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCasal(String id) async {
    try {
      await _repository.deleteCasal(id);
      _casais.removeWhere((c) => c.id == id);
      _saldos.remove(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Falha ao excluir: $e';
      notifyListeners();
    }
  }
}
