import 'package:flutter/foundation.dart';
import '../../../../shared/models/casal_model.dart';
import '../../data/repositories/casal_repository.dart';

class CasalManagementViewModel extends ChangeNotifier {
  final CasalRepository _repository;
  
  List<CasalModel> _casais = [];
  bool _isLoading = false;
  String? _errorMessage;

  CasalManagementViewModel(this._repository);

  List<CasalModel> get casais => _casais;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCasais() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _casais = await _repository.getCasais();
    } catch (e) {
      _errorMessage = 'Falha ao carregar casais: $e';
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
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Falha ao excluir: $e';
      notifyListeners();
    }
  }
}
