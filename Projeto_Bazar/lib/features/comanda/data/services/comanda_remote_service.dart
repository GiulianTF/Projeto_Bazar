import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/comanda_model.dart';
import '../../../../shared/models/comanda_status.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/models/pagamento_model.dart';

class ComandaRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ComandaModel?> getComandaAtivaPorCasal(String coupleId) async {
    final snapshot = await _firestore
        .collection('comandas')
        .where('coupleId', isEqualTo: coupleId)
        .where('status', isNotEqualTo: ComandaStatus.paga.toMap())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final comandaMap = doc.data();
      comandaMap['id'] = doc.id; // ensuring ID is mapped from document ID if needed, though we set it
      
      final String id = comandaMap['id'] as String;
      final itens = await getItensPorComanda(id);
      final pagamentos = await getPagamentosPorComanda(id);
      
      return ComandaModel.fromMap(comandaMap, itens: itens, pagamentos: pagamentos);
    }
    return null;
  }

  Stream<ComandaModel?> getComandaStream(String coupleId) {
    return _firestore
        .collection('comandas')
        .where('coupleId', isEqualTo: coupleId)
        .where('status', isNotEqualTo: ComandaStatus.paga.toMap())
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final comandaMap = doc.data();
        comandaMap['id'] = doc.id;
        return ComandaModel.fromMap(comandaMap);
      }
      return null;
    });
  }

  Stream<List<ItemModel>> getItensStream(String comandaId) {
    return _firestore
        .collection('itens')
        .where('comandaId', isEqualTo: comandaId)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ItemModel.fromMap(doc.data())).toList());
  }

  Stream<List<PagamentoModel>> getPagamentosStream(String comandaId) {
    return _firestore
        .collection('pagamentos')
        .where('comandaId', isEqualTo: comandaId)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PagamentoModel.fromMap(doc.data())).toList());
  }

  Future<List<ItemModel>> getItensPorComanda(String comandaId) async {
    final snapshot = await _firestore
        .collection('itens')
        .where('comandaId', isEqualTo: comandaId)
        .orderBy('dataHora', descending: true)
        .get();

    return snapshot.docs.map((doc) => ItemModel.fromMap(doc.data())).toList();
  }
  
  Future<List<PagamentoModel>> getPagamentosPorComanda(String comandaId) async {
    final snapshot = await _firestore
        .collection('pagamentos')
        .where('comandaId', isEqualTo: comandaId)
        .orderBy('dataHora', descending: true)
        .get();

    return snapshot.docs.map((doc) => PagamentoModel.fromMap(doc.data())).toList();
  }

  Future<void> createComanda(ComandaModel comanda) async {
    await _firestore.collection('comandas').doc(comanda.id).set(comanda.toMap());
  }

  Future<void> updateComanda(ComandaModel comanda) async {
    await _firestore.collection('comandas').doc(comanda.id).update(comanda.toMap());
  }

  Future<void> saveItem(ItemModel item) async {
    await _firestore.collection('itens').doc(item.id).set(item.toMap());
  }
  
  Future<void> savePagamento(PagamentoModel pagamento) async {
    await _firestore.collection('pagamentos').doc(pagamento.id).set(pagamento.toMap());
  }

  Future<void> deleteAllDataByCasal(String coupleId) async {
    final batch = _firestore.batch();

    // 1. Buscar todas as comandas do casal
    final comandaSnap = await _firestore.collection('comandas').where('coupleId', isEqualTo: coupleId).get();

    for (var comandaDoc in comandaSnap.docs) {
      final comandaId = comandaDoc.id;

      // 2. Buscar e deletar itens da comanda
      final itemSnap = await _firestore.collection('itens').where('comandaId', isEqualTo: comandaId).get();
      for (var itemDoc in itemSnap.docs) {
        batch.delete(itemDoc.reference);
      }

      // 3. Buscar e deletar pagamentos da comanda
      final pagamentoSnap = await _firestore.collection('pagamentos').where('comandaId', isEqualTo: comandaId).get();
      for (var pagamentoDoc in pagamentoSnap.docs) {
        batch.delete(pagamentoDoc.reference);
      }

      // 4. Deletar a comanda
      batch.delete(comandaDoc.reference);
    }

    await batch.commit();
  }
}
