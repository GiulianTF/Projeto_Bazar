import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../../shared/models/comanda_model.dart';
import '../../data/repositories/comanda_repository.dart';
import '../../../casal/data/repositories/casal_repository.dart';

class ComandaDetailViewModel extends ChangeNotifier {
  final ComandaRepository _repository;
  final CasalRepository _casalRepository;
  
  ComandaModel? _comanda;
  String? _coupleName;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<ComandaModel?>? _subscription;

  ComandaDetailViewModel(this._repository, this._casalRepository);

  ComandaModel? get comanda => _comanda;
  String? get coupleName => _coupleName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadComanda(String coupleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Carrega o nome do casal (dado estático)
      final casal = await _casalRepository.getCasalById(coupleId);
      if (casal != null) {
        _coupleName = casal.nome;
      }

      // Inicia a escuta em tempo real
      await _subscription?.cancel();
      _subscription = _repository.obterComandaAtivaStream(coupleId).listen(
        (updatedComanda) {
          _comanda = updatedComanda;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = e.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      // O _isLoading será setado como false pelo listen ou aqui no erro inicial
      if (_comanda == null && _errorMessage != null) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refresh(String coupleId) async {
    await loadComanda(coupleId);
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
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
