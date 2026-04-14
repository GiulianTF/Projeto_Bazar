import 'package:flutter/foundation.dart';
import '../../../../shared/models/comanda_model.dart';
import '../../data/repositories/comanda_repository.dart';

class ComandaDetailViewModel extends ChangeNotifier {
  final ComandaRepository _repository;
  ComandaModel? _comanda;
  bool _isLoading = false;
  String? _errorMessage;

  ComandaDetailViewModel(this._repository);

  ComandaModel? get comanda => _comanda;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadComanda(String coupleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comanda = await _repository.getOrCreateComanda(coupleId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String descricao, double valor, int quantidade) async {
    if (_comanda == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _comanda = await _repository.addItem(_comanda!, descricao, valor, quantidade);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPagamento(double valor) async {
    if (_comanda == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _comanda = await _repository.addPagamento(_comanda!, valor);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> encerrarComanda() async {
    if (_comanda == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comanda = await _repository.pagarComanda(_comanda!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
